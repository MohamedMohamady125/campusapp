"""Trot email program — composition, consent and dispatch (email strategy doc).

Two tiers:

* **Tier 1 — transactional.** Welcome (post-verify), order confirmed, order
  accepted, delivered receipt, settle-up reminder, and the behavior-targeted
  "new run at a spot you've ordered from". Receipts stay PURE — one promo
  banner legally reclassifies a transactional email as marketing (CAN-SPAM
  primary-purpose test), so no upsell copy is ever appended here.
* **Tier 2 — marketing.** First-order nudge, win-back, weekly digest and
  Semester Wrapped live in ``workers/jobs.marketing_emails_job`` and funnel
  through :func:`send_program_email` with ``marketing=True``, which enforces
  the hard ceiling of ONE marketing email per user per 7 days and appends the
  CAN-SPAM footer (unsubscribe link + postal line).

Delivery mirrors ``push_dispatch``: fire-and-forget off the request path in
prod, awaited inline under ``app_env == "test"`` so the stub provider is
deterministic to assert against. The :class:`~app.models.EmailLog` row is
added to the *caller's* session and commits with the business transaction —
a rolled-back order never leaves a phantom "we emailed you" record.

Money copy stays LOUD (exact dollars, who owes whom) per the product rule;
everything else is terse. Subjects ≤50 chars, verb-first.
"""

import asyncio
import base64
import hashlib
import hmac
import uuid
from datetime import UTC, datetime, timedelta

import structlog
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.integrations.email.provider import get_email_provider
from app.models import EmailLog, NotificationPreference, Run, RunOrder, User
from app.models.enums import RunOrderStatus, UserStatus

log = structlog.get_logger()

# --- Kinds (stable machine names; stored in email_log.kind) -----------------

KIND_WELCOME = "welcome"
KIND_ORDER_CONFIRMED = "order_confirmed"
KIND_ORDER_ACCEPTED = "order_accepted"
KIND_RUN_RECEIPT = "run_receipt"
KIND_PAYMENT_REMINDER = "payment_reminder"
KIND_RUN_POSTED = "run_posted"
KIND_FIRST_ORDER_NUDGE = "first_order_nudge"
KIND_WIN_BACK = "win_back"
KIND_WEEKLY_DIGEST = "weekly_digest"
KIND_SEMESTER_WRAPPED = "semester_wrapped"

MARKETING_KINDS = frozenset(
    {KIND_FIRST_ORDER_NUDGE, KIND_WIN_BACK, KIND_WEEKLY_DIGEST, KIND_SEMESTER_WRAPPED}
)

# Opt-out preference types (NotificationPreference.type; default = enabled).
PREF_MARKETING = "email_marketing"
PREF_RUN_POSTED = "email_run_posted"

# Hard ceiling: one marketing email per user per week (strategy doc rule).
MARKETING_COOLDOWN = timedelta(days=7)
# "New run" alerts: at most one per user per day, 50 recipients per run —
# the engagement engine must never feel like spam (.edu deliverability is
# fragile; one bad batch can block the whole domain at GCU's mail gateway).
RUN_POSTED_COOLDOWN = timedelta(hours=24)
RUN_POSTED_MAX_RECIPIENTS = 50

# CAN-SPAM physical-address line for marketing footers.
_POSTAL_LINE = "Trot · Grand Canyon University area · Phoenix, AZ"

# Keep strong refs to in-flight fire-and-forget sends (asyncio GC rule).
_background_sends: set[asyncio.Task[None]] = set()


def format_dollars(cents: int) -> str:
    return f"${cents / 100:.2f}"


# --- Unsubscribe tokens (HMAC-signed, no DB round-trip to mint) --------------


def make_unsubscribe_token(user_id: uuid.UUID, scope: str) -> str:
    """Signed, non-expiring one-click unsubscribe token: ``user_id:scope:sig``."""
    payload = f"{user_id}:{scope}"
    sig = hmac.new(
        get_settings().jwt_secret.encode(), payload.encode(), hashlib.sha256
    ).hexdigest()[:32]
    return base64.urlsafe_b64encode(f"{payload}:{sig}".encode()).decode()


def parse_unsubscribe_token(token: str) -> tuple[uuid.UUID, str] | None:
    """Return (user_id, scope) or None if the token is malformed/forged."""
    try:
        payload_user, scope, sig = base64.urlsafe_b64decode(token.encode()).decode().rsplit(":", 2)
        user_id = uuid.UUID(payload_user)
    except (ValueError, UnicodeDecodeError):
        return None
    expected = hmac.new(
        get_settings().jwt_secret.encode(), f"{user_id}:{scope}".encode(), hashlib.sha256
    ).hexdigest()[:32]
    if not hmac.compare_digest(sig, expected):
        return None
    return user_id, scope


def _unsubscribe_footer(user_id: uuid.UUID, scope: str) -> str:
    url = (
        f"{get_settings().public_base_url}/api/v1/emails/unsubscribe"
        f"?token={make_unsubscribe_token(user_id, scope)}"
    )
    label = "these alerts" if scope == PREF_RUN_POSTED else "emails like this"
    return f"\n\n—\nUnsubscribe from {label}: {url}\n{_POSTAL_LINE}"


# --- Consent / cap queries ----------------------------------------------------


async def _pref_disabled(session: AsyncSession, user_id: uuid.UUID, pref: str) -> bool:
    row = await session.execute(
        select(NotificationPreference.id).where(
            NotificationPreference.user_id == user_id,
            NotificationPreference.type == pref,
            NotificationPreference.enabled.is_(False),
        )
    )
    return row.first() is not None


async def _sent_within(
    session: AsyncSession, user_id: uuid.UUID, kinds: frozenset[str] | set[str], window: timedelta
) -> bool:
    row = await session.execute(
        select(EmailLog.id).where(
            EmailLog.user_id == user_id,
            EmailLog.kind.in_(kinds),
            EmailLog.created_at >= datetime.now(UTC) - window,
        )
    )
    return row.first() is not None


async def marketing_sends_today(session: AsyncSession) -> int:
    """Global daily marketing volume — the batch job budgets against this."""
    midnight = datetime.now(UTC).replace(hour=0, minute=0, second=0, microsecond=0)
    count = await session.execute(
        select(func.count(EmailLog.id)).where(
            EmailLog.kind.in_(MARKETING_KINDS), EmailLog.created_at >= midnight
        )
    )
    return int(count.scalar_one())


# --- Dispatch -----------------------------------------------------------------


async def send_program_email(
    session: AsyncSession,
    *,
    user: User,
    kind: str,
    subject: str,
    body: str,
    marketing: bool = False,
) -> bool:
    """Send one program email if every consent/cap gate passes.

    Returns True when the email was dispatched (and an EmailLog row added to
    the caller's session — the caller commits).
    """
    if user.email_verified_at is None or user.status != UserStatus.active:
        return False
    if marketing:
        if await _pref_disabled(session, user.id, PREF_MARKETING):
            return False
        if await _sent_within(session, user.id, MARKETING_KINDS, MARKETING_COOLDOWN):
            return False
        body += _unsubscribe_footer(user.id, PREF_MARKETING)
    elif kind == KIND_RUN_POSTED:
        if await _pref_disabled(session, user.id, PREF_RUN_POSTED):
            return False
        if await _sent_within(session, user.id, {KIND_RUN_POSTED}, RUN_POSTED_COOLDOWN):
            return False
        body += _unsubscribe_footer(user.id, PREF_RUN_POSTED)
    session.add(EmailLog(user_id=user.id, kind=kind))
    await _dispatch(to=user.email, subject=subject, body=body, kind=kind)
    return True


async def _dispatch(*, to: str, subject: str, body: str, kind: str) -> None:
    provider = get_email_provider()

    async def _send() -> None:
        await provider.send(to=to, subject=subject, body=body)
        log.info("email_program.sent", to=to, kind=kind)

    if get_settings().app_env == "test":
        # Awaited inline so the stub provider is deterministic to assert on.
        await _send()
        return
    task = asyncio.create_task(_send())
    _background_sends.add(task)
    task.add_done_callback(_background_sends.discard)


# --- Tier 1 composition + triggers -------------------------------------------


async def send_welcome_email(session: AsyncSession, *, user: User) -> None:
    """Post-verification welcome — folds "how Trot works" into the moment of
    highest attention (verification emails see ~68% opens)."""
    body = (
        f"Hey {user.display_name.split(' ')[0]},\n\n"
        "Your campus email is verified. Trot in 15 seconds:\n\n"
        '1. Someone posts a run — "Chick-fil-A, leaving at 6".\n'
        "2. You add your order and a drop-off spot.\n"
        "3. They bring it back. You pay them directly, plus their small fee.\n\n"
        "Heading out yourself? Post the run and keep the fees.\n\n"
        "— Trot"
    )
    await send_program_email(
        session,
        user=user,
        kind=KIND_WELCOME,
        subject="You're in — here's how Trot works",
        body=body,
    )


def _order_total_cents(order: RunOrder, run: Run) -> tuple[int, bool]:
    """(total owed, is_final) — actual price when set, else the estimate."""
    final = order.actual_price_cents is not None
    item = order.actual_price_cents if final else order.item_price_cents
    assert item is not None
    return item + run.fee_cents, final


async def send_order_confirmed_email(
    session: AsyncSession, *, order: RunOrder, run: Run, requester: User
) -> None:
    # `requester` is passed explicitly: the order was created this request and
    # its relationship isn't loaded yet (async lazy-load would blow up).
    total, _ = _order_total_cents(order, run)
    body = (
        f"Your order is in for {run.runner.display_name}'s {run.food_spot.name} run.\n\n"
        f"ORDER: {order.order_text}\n"
        f"ITEM (estimate): {format_dollars(order.item_price_cents)}\n"
        f"RUNNER FEE: {format_dollars(run.fee_cents)}\n"
        f"ESTIMATED TOTAL YOU'LL OWE: {format_dollars(total)}\n\n"
        f"You'll get an email when {run.runner.display_name} accepts."
    )
    await send_program_email(
        session,
        user=requester,
        kind=KIND_ORDER_CONFIRMED,
        subject=f"Order's in — {run.food_spot.name}"[:50],
        body=body,
    )


async def send_order_accepted_email(session: AsyncSession, *, order: RunOrder, run: Run) -> None:
    total, _ = _order_total_cents(order, run)
    prepay = (
        f"\n\nThis is a PREPAY run — pay {run.runner.display_name} now in the app."
        if run.prepay_required
        else ""
    )
    body = (
        f"{run.runner.display_name} accepted your {run.food_spot.name} order.\n\n"
        f"ORDER: {order.order_text}\n"
        f"ESTIMATED TOTAL YOU'LL OWE: {format_dollars(total)} "
        f"(item {format_dollars(order.item_price_cents)} + fee {format_dollars(run.fee_cents)})"
        f"{prepay}"
    )
    await send_program_email(
        session,
        user=order.requester,
        kind=KIND_ORDER_ACCEPTED,
        subject=f"Accepted — {run.food_spot.name} run"[:50],
        body=body,
    )


async def send_run_receipt_email(session: AsyncSession, *, order: RunOrder, run: Run) -> None:
    """Delivered receipt — pure transactional record, money loud, no promo."""
    total, final = _order_total_cents(order, run)
    item = order.actual_price_cents if final else order.item_price_cents
    assert item is not None
    paid = order.payment_confirmed_at is not None or order.payment_submitted_at is not None
    settle = "Payment is settled — all done." if paid else "Settle up in the app if you haven't."
    body = (
        f"{run.runner.display_name} delivered your {run.food_spot.name} order.\n\n"
        f"ORDER: {order.order_text}\n"
        f"ITEM{' (final price)' if final else ' (estimate)'}: {format_dollars(item)}\n"
        f"RUNNER FEE: {format_dollars(run.fee_cents)}\n"
        f"TOTAL YOU OWE {run.runner.display_name.upper()}: {format_dollars(total)}\n\n"
        f"{settle}"
    )
    await send_program_email(
        session,
        user=order.requester,
        kind=KIND_RUN_RECEIPT,
        subject="Delivered — your receipt",
        body=body,
    )


async def send_payment_reminder_email(
    session: AsyncSession, *, order: RunOrder, run: Run, requester: User, owed_cents: int
) -> None:
    body = (
        f"Friendly reminder: you still owe {run.runner.display_name} "
        f"{format_dollars(owed_cents)} for the {run.food_spot.name} run.\n\n"
        f"ORDER: {order.order_text}\n"
        f"TOTAL OWED: {format_dollars(owed_cents)}\n\n"
        "Open the app to see their payment handles and settle up."
    )
    await send_program_email(
        session,
        user=requester,
        kind=KIND_PAYMENT_REMINDER,
        subject=f"You owe {format_dollars(owed_cents)} — {run.food_spot.name}"[:50],
        body=body,
    )


async def send_run_posted_emails(session: AsyncSession, *, run: Run) -> int:
    """Alert past customers of this spot that a new run just opened.

    "Favorites" proxy: anyone whose order at this spot reached delivered /
    received has demonstrated real interest. Capped, per-user rate-limited,
    and individually unsubscribable (PREF_RUN_POSTED).
    """
    rows = await session.execute(
        select(User)
        .join(RunOrder, RunOrder.requester_id == User.id)
        .join(Run, RunOrder.run_id == Run.id)
        .where(
            Run.food_spot_id == run.food_spot_id,
            Run.id != run.id,
            RunOrder.requester_id != run.runner_id,
            RunOrder.status.in_((RunOrderStatus.delivered, RunOrderStatus.received)),
            User.email_verified_at.is_not(None),
            User.status == UserStatus.active,
        )
        .distinct()
        .limit(RUN_POSTED_MAX_RECIPIENTS)
    )
    fee = f"{format_dollars(run.fee_cents)} fee" if run.fee_cents else "no fee"
    leaving = run.leaving_at.strftime("%-I:%M %p").lstrip("0")
    sent = 0
    for user in rows.scalars():
        body = (
            f"{run.runner.display_name} is heading to {run.food_spot.name} "
            f"and leaving around {leaving} ({fee}).\n\n"
            "Want something? Add your order before the spots fill."
        )
        ok = await send_program_email(
            session,
            user=user,
            kind=KIND_RUN_POSTED,
            subject=f"{run.runner.display_name} is running to {run.food_spot.name}"[:50],
            body=body,
        )
        sent += int(ok)
    return sent
