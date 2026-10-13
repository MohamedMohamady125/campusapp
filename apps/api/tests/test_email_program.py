"""Email program: Tier-1 lifecycle emails, consent gates, Tier-2 batch job."""

import uuid
from datetime import UTC, datetime, timedelta

import httpx
from sqlalchemy import select, update

from app.db.session import async_session_factory
from app.integrations.email.provider import get_email_provider
from app.integrations.email.stub import StubEmailProvider
from app.models import EmailLog, NotificationPreference, User
from app.services.email_program import (
    KIND_FIRST_ORDER_NUDGE,
    KIND_WIN_BACK,
    PREF_MARKETING,
    PREF_RUN_POSTED,
    make_unsubscribe_token,
    parse_unsubscribe_token,
    send_program_email,
)
from app.workers.jobs import _semester_start, _wrapped_window_open, marketing_emails_job
from tests.helpers import make_user
from tests.test_runs import _create_run, _make_dropoff, _make_spot, _order_body


def _provider() -> StubEmailProvider:
    provider = get_email_provider()
    assert isinstance(provider, StubEmailProvider)
    return provider


def _mail(sent: list[dict[str, str]], *, to: str, subject_part: str) -> list[dict[str, str]]:
    return [m for m in sent if m["to"] == to and subject_part in m["subject"]]


async def _user_by_email(email: str) -> User:
    async with async_session_factory() as session:
        return (await session.execute(select(User).where(User.email == email))).scalar_one()


# -- Tier 1 ---------------------------------------------------------------------


async def test_welcome_email_sent_after_verify(client: httpx.AsyncClient) -> None:
    provider = _provider()
    start = len(provider.sent)
    await make_user(client, "newbie@campus.edu")
    welcomes = _mail(provider.sent[start:], to="newbie@campus.edu", subject_part="You're in")
    assert len(welcomes) == 1
    assert "Trot in 15 seconds" in welcomes[0]["body"]


async def test_order_lifecycle_emails(client: httpx.AsyncClient) -> None:
    """Confirmed on request, accepted on accept, loud-money receipt at done."""
    provider = _provider()
    runner = await make_user(client, "runner@campus.edu")
    requester = await make_user(client, "req@campus.edu")
    spot = await _make_spot()
    dropoff = await _make_dropoff()
    run = await _create_run(client, runner, spot, fee_cents=150)
    start = len(provider.sent)

    resp = await client.post(
        f"/api/v1/runs/{run['id']}/orders",
        json=_order_body("Spicy deluxe", dropoff_id=dropoff, item_price_cents=850),
        headers=requester,
    )
    assert resp.status_code == 201, resp.text
    oid = resp.json()["my_order"]["id"]

    confirmed = _mail(provider.sent[start:], to="req@campus.edu", subject_part="Order's in")
    assert len(confirmed) == 1
    assert "ESTIMATED TOTAL YOU'LL OWE: $10.00" in confirmed[0]["body"]
    assert "RUNNER FEE: $1.50" in confirmed[0]["body"]

    base = f"/api/v1/runs/{run['id']}"
    accept = await client.post(f"{base}/orders/{oid}/accept", headers=runner)
    assert accept.status_code == 200, accept.text
    accepted = _mail(provider.sent[start:], to="req@campus.edu", subject_part="Accepted")
    assert len(accepted) == 1
    assert "$10.00" in accepted[0]["body"]
    assert "PREPAY" not in accepted[0]["body"]  # non-prepay run, no prepay call-out

    for status in ("at_store", "delivering"):
        assert (
            await client.post(f"{base}/status", json={"status": status}, headers=runner)
        ).status_code == 200
    assert (await client.post(f"{base}/orders/{oid}/delivered", headers=runner)).status_code == 200
    done = await client.post(f"{base}/status", json={"status": "done"}, headers=runner)
    assert done.status_code == 200, done.text

    receipts = _mail(provider.sent[start:], to="req@campus.edu", subject_part="Delivered")
    assert len(receipts) == 1
    body = receipts[0]["body"]
    assert "TOTAL YOU OWE RUNNER: $10.00" in body  # money loud: who + exact dollars
    assert "Settle up in the app" in body
    assert "Unsubscribe" not in body  # receipts are pure transactional — no footer


async def test_accepted_email_calls_out_prepay(client: httpx.AsyncClient) -> None:
    provider = _provider()
    runner = await make_user(client, "runner@campus.edu")
    requester = await make_user(client, "req@campus.edu")
    spot = await _make_spot()
    dropoff = await _make_dropoff()
    run = await _create_run(client, runner, spot, fee_cents=100, prepay_required=True)
    start = len(provider.sent)

    resp = await client.post(
        f"/api/v1/runs/{run['id']}/orders",
        json=_order_body(dropoff_id=dropoff, item_price_cents=500),
        headers=requester,
    )
    oid = resp.json()["my_order"]["id"]
    await client.post(f"/api/v1/runs/{run['id']}/orders/{oid}/accept", headers=runner)

    accepted = _mail(provider.sent[start:], to="req@campus.edu", subject_part="Accepted")
    assert len(accepted) == 1
    assert "PREPAY run — pay runner now in the app" in accepted[0]["body"]


async def _complete_run_with_order(
    client: httpx.AsyncClient,
    runner: dict[str, str],
    requester: dict[str, str],
    spot: str,
    dropoff: str,
) -> None:
    run = await _create_run(client, runner, spot)
    resp = await client.post(
        f"/api/v1/runs/{run['id']}/orders",
        json=_order_body(dropoff_id=dropoff),
        headers=requester,
    )
    oid = resp.json()["my_order"]["id"]
    base = f"/api/v1/runs/{run['id']}"
    await client.post(f"{base}/orders/{oid}/accept", headers=runner)
    for status in ("at_store", "delivering"):
        await client.post(f"{base}/status", json={"status": status}, headers=runner)
    await client.post(f"{base}/orders/{oid}/delivered", headers=runner)
    done = await client.post(f"{base}/status", json={"status": "done"}, headers=runner)
    assert done.status_code == 200, done.text


async def test_run_posted_fanout_to_past_customers_with_daily_cap(
    client: httpx.AsyncClient,
) -> None:
    provider = _provider()
    runner1 = await make_user(client, "runner1@campus.edu")
    runner2 = await make_user(client, "runner2@campus.edu")
    requester = await make_user(client, "fan@campus.edu")
    spot = await _make_spot()
    dropoff = await _make_dropoff()
    # Establish "past customer of this spot" via a completed order.
    await _complete_run_with_order(client, runner1, requester, spot, dropoff)
    start = len(provider.sent)

    # A new run at the same spot alerts the past customer...
    await _create_run(client, runner2, spot)
    alerts = _mail(provider.sent[start:], to="fan@campus.edu", subject_part="is running to")
    assert len(alerts) == 1
    assert "Unsubscribe" in alerts[0]["body"]  # individually opt-out-able
    # ...but not the runner posting it, and nobody uninvolved.
    assert _mail(provider.sent[start:], to="runner2@campus.edu", subject_part="is running") == []

    # 24h per-user cap: a second run the same day sends nothing.
    await _create_run(client, runner1, spot)
    alerts = _mail(provider.sent[start:], to="fan@campus.edu", subject_part="is running to")
    assert len(alerts) == 1


# -- Unsubscribe ------------------------------------------------------------------


async def test_unsubscribe_token_round_trip_and_forgery(client: httpx.AsyncClient) -> None:
    uid = uuid.uuid4()
    token = make_unsubscribe_token(uid, PREF_MARKETING)
    assert parse_unsubscribe_token(token) == (uid, PREF_MARKETING)
    assert parse_unsubscribe_token("garbage") is None
    # Tampered scope must fail the HMAC check.
    forged = make_unsubscribe_token(uid, PREF_MARKETING)[:-4] + "AAAA"
    assert parse_unsubscribe_token(forged) is None


async def test_unsubscribe_endpoint_disables_marketing(client: httpx.AsyncClient) -> None:
    await make_user(client, "optout@campus.edu")
    user = await _user_by_email("optout@campus.edu")

    resp = await client.get(
        "/api/v1/emails/unsubscribe",
        params={"token": make_unsubscribe_token(user.id, PREF_MARKETING)},
    )
    assert resp.status_code == 200
    assert "unsubscribed" in resp.text

    async with async_session_factory() as session:
        pref = (
            await session.execute(
                select(NotificationPreference).where(
                    NotificationPreference.user_id == user.id,
                    NotificationPreference.type == PREF_MARKETING,
                )
            )
        ).scalar_one()
        assert pref.enabled is False
        # Consent gate now blocks marketing sends for this user.
        ok = await send_program_email(
            session,
            user=user,
            kind=KIND_WIN_BACK,
            subject="x",
            body="x",
            marketing=True,
        )
        assert ok is False

    bad = await client.get("/api/v1/emails/unsubscribe", params={"token": "nonsense"})
    assert bad.status_code == 400


async def test_unsubscribe_run_posted_scope(client: httpx.AsyncClient) -> None:
    provider = _provider()
    runner1 = await make_user(client, "runner1@campus.edu")
    runner2 = await make_user(client, "runner2@campus.edu")
    requester = await make_user(client, "fan@campus.edu")
    spot = await _make_spot()
    dropoff = await _make_dropoff()
    await _complete_run_with_order(client, runner1, requester, spot, dropoff)

    user = await _user_by_email("fan@campus.edu")
    resp = await client.get(
        "/api/v1/emails/unsubscribe",
        params={"token": make_unsubscribe_token(user.id, PREF_RUN_POSTED)},
    )
    assert resp.status_code == 200
    assert "new-run alerts" in resp.text

    start = len(provider.sent)
    await _create_run(client, runner2, spot)
    assert _mail(provider.sent[start:], to="fan@campus.edu", subject_part="is running") == []


# -- Tier 2 batch job --------------------------------------------------------------


async def _backdate_user(email: str, **values: datetime) -> None:
    async with async_session_factory() as session:
        await session.execute(update(User).where(User.email == email).values(**values))
        await session.commit()


async def test_marketing_job_first_order_nudge_once_ever(client: httpx.AsyncClient) -> None:
    provider = _provider()
    await make_user(client, "idle@campus.edu")  # verified, zero orders
    await _backdate_user("idle@campus.edu", email_verified_at=datetime.now(UTC) - timedelta(days=4))
    start = len(provider.sent)

    async with async_session_factory() as session:
        sent = await marketing_emails_job(session)
    assert sent["nudge"] == 1
    nudges = _mail(provider.sent[start:], to="idle@campus.edu", subject_part="first run")
    assert len(nudges) == 1
    assert "Unsubscribe" in nudges[0]["body"]  # CAN-SPAM footer on marketing

    # Once-ever: a second batch run never re-nudges.
    async with async_session_factory() as session:
        sent = await marketing_emails_job(session)
    assert sent["nudge"] == 0


async def test_marketing_job_win_back_window_and_cooldown(client: httpx.AsyncClient) -> None:
    provider = _provider()
    await make_user(client, "ghost@campus.edu")
    await make_user(client, "fresh@campus.edu")  # active today — never targeted
    now = datetime.now(UTC)
    await _backdate_user(
        "ghost@campus.edu",
        last_active_at=now - timedelta(days=35),
        email_verified_at=now - timedelta(days=90),  # outside the nudge window
    )
    start = len(provider.sent)

    async with async_session_factory() as session:
        sent = await marketing_emails_job(session)
    assert sent["win_back"] == 1
    assert len(_mail(provider.sent[start:], to="ghost@campus.edu", subject_part="eating")) == 1
    assert _mail(provider.sent[start:], to="fresh@campus.edu", subject_part="eating") == []

    # 60-day cooldown (and the 7-day marketing ceiling) block an immediate repeat.
    async with async_session_factory() as session:
        sent = await marketing_emails_job(session)
    assert sent["win_back"] == 0
    async with async_session_factory() as session:
        logs = (
            (
                await session.execute(
                    select(EmailLog).where(
                        EmailLog.kind.in_({KIND_WIN_BACK, KIND_FIRST_ORDER_NUDGE})
                    )
                )
            )
            .scalars()
            .all()
        )
        assert len(logs) == 1


def test_wrapped_window_open() -> None:
    assert _wrapped_window_open(datetime(2026, 12, 10, tzinfo=UTC)) is True
    assert _wrapped_window_open(datetime(2026, 4, 20, tzinfo=UTC)) is True
    assert _wrapped_window_open(datetime(2026, 12, 14, tzinfo=UTC)) is False
    assert _wrapped_window_open(datetime(2026, 10, 13, tzinfo=UTC)) is False


def test_semester_start() -> None:
    assert _semester_start(datetime(2026, 12, 10, tzinfo=UTC)) == datetime(2026, 8, 1, tzinfo=UTC)
    assert _semester_start(datetime(2026, 4, 20, tzinfo=UTC)) == datetime(2026, 1, 1, tzinfo=UTC)
