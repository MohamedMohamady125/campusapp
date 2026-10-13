"""Idempotent async job bodies (spec §5.4) — called by Celery tasks and tests.

Kept separate from Celery task wrappers so tests can invoke them directly
without a broker.
"""

from datetime import UTC, date, datetime, time, timedelta
from typing import Any, cast

import structlog
from sqlalchemy import CursorResult, delete, func, or_, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.scoring import GLOBAL_MEAN_SEED
from app.models import AnalyticsEvent, DailyMetric, Listing, Notification, Rating, VerificationCode
from app.models.enums import ListingStatus, RunOrderStatus, RunStatus

log = structlog.get_logger()


async def expire_listings_job(session: AsyncSession) -> int:
    """Mark active listings past expires_at as removed. Idempotent."""
    now = datetime.now(UTC)
    result = cast(
        CursorResult[Any],
        await session.execute(
            update(Listing)
            .where(
                Listing.status == ListingStatus.active,
                Listing.expires_at < now,
                Listing.deleted_at.is_(None),
            )
            .values(status=ListingStatus.removed)
        ),
    )
    await session.commit()
    count = int(result.rowcount or 0)
    log.info("jobs.expire_listings", expired=count)
    return count


async def expire_runs_job(session: AsyncSession) -> dict[str, int]:
    """Food-runs expiry sweep (every 5 min). Idempotent.

    - open run past leaving_at with no accepted orders → quiet `expired`;
    - open run past leaving_at with >=1 accepted order → auto-`locked`;
    - any still-active run 90 min past leaving_at → `expired` (runner ghosted).
    Accepted orders are left untouched — no automatic no_show judgments.
    """
    from app.repositories.run_repo import RunRepository
    from app.services.run_service import RUN_HARD_EXPIRY

    now = datetime.now(UTC)
    expired = locked = 0
    for run in await RunRepository(session).expirable(now=now):
        overdue = now - run.leaving_at
        has_accepted = any(
            o.status in (RunOrderStatus.accepted, RunOrderStatus.delivered) for o in run.orders
        )
        if overdue >= RUN_HARD_EXPIRY:
            run.status = RunStatus.expired
            expired += 1
        elif run.status == RunStatus.open:
            if has_accepted:
                run.status = RunStatus.locked
                locked += 1
            else:
                run.status = RunStatus.expired
                for order in run.orders:
                    if order.status == RunOrderStatus.requested:
                        order.status = RunOrderStatus.declined
                expired += 1
    await session.commit()
    log.info("jobs.expire_runs", expired=expired, locked=locked)
    return {"expired": expired, "locked": locked}


SETTLE_REMINDER_AFTER = timedelta(hours=2)


async def settle_up_reminder_job(session: AsyncSession) -> int:
    """One-time "settle up" nudge ~2h after a run is done with payment still
    unconfirmed (neither requester proof nor runner confirmation). Idempotent
    via run_orders.settle_reminder_sent_at. Money copy stays loud: the push
    carries the exact dollars owed (estimate-or-actual + fee).
    """
    from sqlalchemy.orm import selectinload

    from app.models import Run, RunOrder
    from app.repositories.chat_repo import NotificationRepository
    from app.services.notification_dispatch import upsert_deduped_notification
    from app.services.run_service import NOTIFICATION_TYPE_SETTLE_REMINDER

    now = datetime.now(UTC)
    cutoff = now - SETTLE_REMINDER_AFTER
    rows = (
        await session.execute(
            select(RunOrder, Run)
            .join(Run, RunOrder.run_id == Run.id)
            .options(
                selectinload(Run.food_spot),
                selectinload(Run.runner),
                selectinload(RunOrder.requester),
            )
            .where(
                Run.status == RunStatus.done,
                Run.updated_at < cutoff,
                RunOrder.status.in_(
                    (RunOrderStatus.accepted, RunOrderStatus.delivered, RunOrderStatus.received)
                ),
                RunOrder.requester_id != Run.runner_id,  # self-orders owe nobody
                RunOrder.payment_confirmed_at.is_(None),
                RunOrder.payment_submitted_at.is_(None),
                RunOrder.settle_reminder_sent_at.is_(None),
            )
        )
    ).all()
    notifications = NotificationRepository(session)
    sent = 0
    for order, run in rows:
        order.settle_reminder_sent_at = now  # stamp first — never re-nag on error
        opted_out = await notifications.disabled_types_for(
            [order.requester_id], NOTIFICATION_TYPE_SETTLE_REMINDER
        )
        if order.requester_id in opted_out:
            continue
        owed = (
            order.actual_price_cents
            if order.actual_price_cents is not None
            else order.item_price_cents
        ) + run.fee_cents
        payload: dict[str, str] = {
            "run_id": str(run.id),
            "order_id": str(order.id),
            "owed_cents": str(owed),
            "spot_name": run.food_spot.name,
            "runner_name": run.runner.display_name,
        }
        await upsert_deduped_notification(
            notifications,
            user_id=order.requester_id,
            type_=NOTIFICATION_TYPE_SETTLE_REMINDER,
            dedup_key="order_id",
            dedup_value=str(order.id),
            payload=payload,
            now=now,
        )
        # Email twin of the push (email program T1) — same loud money copy.
        from app.services.email_program import send_payment_reminder_email

        await send_payment_reminder_email(
            session, order=order, run=run, requester=order.requester, owed_cents=owed
        )
        sent += 1
    await session.commit()
    log.info("jobs.settle_up_reminder", sent=sent, scanned=len(rows))
    return sent


async def recompute_global_mean_job(session: AsyncSession) -> float:
    """Recompute global mean rating m (spec §5.2), seeded to 4.0 when no data."""
    mean = (
        await session.execute(select(func.avg(Rating.stars)).where(Rating.deleted_at.is_(None)))
    ).scalar()
    value = float(mean) if mean is not None else GLOBAL_MEAN_SEED
    log.info("jobs.recompute_global_mean", mean=value)
    return value


async def purge_verification_codes_job(session: AsyncSession) -> int:
    """Delete consumed or expired verification codes (spec §5.4). Idempotent."""
    now = datetime.now(UTC)
    result = cast(
        CursorResult[Any],
        await session.execute(
            delete(VerificationCode).where(
                or_(
                    VerificationCode.consumed_at.is_not(None),
                    VerificationCode.expires_at < now,
                )
            )
        ),
    )
    await session.commit()
    count = int(result.rowcount or 0)
    log.info("jobs.purge_verification_codes", purged=count)
    return count


NOTIFICATION_RETENTION = timedelta(days=90)


async def purge_notifications_job(session: AsyncSession) -> int:
    """Delete notifications older than NOTIFICATION_RETENTION (data-minimisation,
    spec §8). The bell UI only pages recent items, so nothing user-visible is
    lost — this just stops the table growing forever. Idempotent."""
    cutoff = datetime.now(UTC) - NOTIFICATION_RETENTION
    result = cast(
        CursorResult[Any],
        await session.execute(delete(Notification).where(Notification.created_at < cutoff)),
    )
    await session.commit()
    count = int(result.rowcount or 0)
    log.info("jobs.purge_notifications", purged=count)
    return count


# Tier-2 marketing (email program): windows + budget. The global daily budget
# keeps marketing volume well under the provider's free-tier quota so
# transactional email (codes, receipts) always has headroom.
DAILY_MARKETING_BUDGET = 60
NUDGE_MIN_AGE = timedelta(days=3)
NUDGE_MAX_AGE = timedelta(days=7)
WIN_BACK_MIN_IDLE = timedelta(days=30)
WIN_BACK_MAX_IDLE = timedelta(days=45)
WIN_BACK_COOLDOWN = timedelta(days=60)
DIGEST_ACTIVE_WINDOW = timedelta(days=21)
# Finals-week windows (month, first day, last day) for Semester Wrapped.
WRAPPED_WINDOWS = ((12, 7, 13), (4, 19, 25))


def _wrapped_window_open(now: datetime) -> bool:
    return any(m == now.month and lo <= now.day <= hi for m, lo, hi in WRAPPED_WINDOWS)


def _semester_start(now: datetime) -> datetime:
    year, month = (now.year, 8) if now.month >= 8 else (now.year, 1)
    return datetime(year, month, 1, tzinfo=UTC)


async def marketing_emails_job(session: AsyncSession) -> dict[str, int]:
    """Daily Tier-2 marketing batch (email program).

    Priority order: Semester Wrapped > first-order nudge > win-back > weekly
    digest. Per-user consent, the 1-marketing-email/week ceiling and the
    unsubscribe footer are all enforced inside ``send_program_email``; this
    job only selects audiences and respects the global daily budget.
    Idempotent: every send is recorded in email_log and re-selected users are
    filtered by it.
    """
    from sqlalchemy.orm import selectinload

    from app.models import EmailLog, FoodSpot, Run, RunOrder, User
    from app.models.enums import RunOrderStatus, UserStatus
    from app.services import email_program as ep

    now = datetime.now(UTC)
    budget = DAILY_MARKETING_BUDGET - await ep.marketing_sends_today(session)
    sent = {"wrapped": 0, "nudge": 0, "win_back": 0, "digest": 0}

    def _spend(ok: bool) -> None:
        nonlocal budget
        budget -= int(ok)

    # 1) Semester Wrapped — finals week only; the shareability/retention lever.
    if _wrapped_window_open(now) and budget > 0:
        start = _semester_start(now)
        users = (
            (
                await session.execute(
                    select(User)
                    .join(RunOrder, RunOrder.requester_id == User.id)
                    .where(
                        RunOrder.status == RunOrderStatus.received,
                        RunOrder.created_at >= start,
                        User.email_verified_at.is_not(None),
                        User.status == UserStatus.active,
                    )
                    .distinct()
                )
            )
            .scalars()
            .all()
        )
        for user in users:
            if budget <= 0:
                break
            orders = (
                (
                    await session.execute(
                        select(RunOrder)
                        .join(Run, RunOrder.run_id == Run.id)
                        .options(selectinload(RunOrder.run).selectinload(Run.runner))
                        .where(
                            RunOrder.requester_id == user.id,
                            RunOrder.status == RunOrderStatus.received,
                            RunOrder.created_at >= start,
                        )
                    )
                )
                .scalars()
                .all()
            )
            if not orders:
                continue
            spent = sum(
                (o.actual_price_cents if o.actual_price_cents is not None else o.item_price_cents)
                + o.run.fee_cents
                for o in orders
                if o.requester_id != o.run.runner_id
            )
            runner_names = [o.run.runner.display_name for o in orders if o.run.runner_id != user.id]
            top_runner = max(set(runner_names), key=runner_names.count) if runner_names else None
            lines = [
                f"{len(orders)} runs this semester.",
                f"{ep.format_dollars(spent)} of food hauled across campus.",
            ]
            if top_runner:
                lines.append(f"Top runner: {top_runner}.")
            body = "Your semester, delivered:\n\n" + "\n".join(lines) + "\n\nSee you next semester."
            ok = await ep.send_program_email(
                session,
                user=user,
                kind=ep.KIND_SEMESTER_WRAPPED,
                subject="Your semester, delivered",
                body=body,
                marketing=True,
            )
            sent["wrapped"] += int(ok)
            _spend(ok)

    # 2) First-order nudge — verified 3-7 days ago, zero orders ever, once-ever.
    if budget > 0:
        nudge_users = (
            (
                await session.execute(
                    select(User).where(
                        User.email_verified_at.between(now - NUDGE_MAX_AGE, now - NUDGE_MIN_AGE),
                        User.status == UserStatus.active,
                        ~select(RunOrder.id).where(RunOrder.requester_id == User.id).exists(),
                        ~select(EmailLog.id)
                        .where(
                            EmailLog.user_id == User.id,
                            EmailLog.kind == ep.KIND_FIRST_ORDER_NUDGE,
                        )
                        .exists(),
                    )
                )
            )
            .scalars()
            .all()
        )
        for user in nudge_users:
            if budget <= 0:
                break
            ok = await ep.send_program_email(
                session,
                user=user,
                kind=ep.KIND_FIRST_ORDER_NUDGE,
                subject="Your first run is waiting",
                body=(
                    "People around campus are posting food runs right now.\n\n"
                    "Add your order to one — or post your own and keep the fees."
                ),
                marketing=True,
            )
            sent["nudge"] += int(ok)
            _spend(ok)

    # 3) Win-back — idle 30-45 days, 60-day cool-down between attempts.
    if budget > 0:
        winback_users = (
            (
                await session.execute(
                    select(User).where(
                        User.last_active_at.between(
                            now - WIN_BACK_MAX_IDLE, now - WIN_BACK_MIN_IDLE
                        ),
                        User.email_verified_at.is_not(None),
                        User.status == UserStatus.active,
                        ~select(EmailLog.id)
                        .where(
                            EmailLog.user_id == User.id,
                            EmailLog.kind == ep.KIND_WIN_BACK,
                            EmailLog.created_at >= now - WIN_BACK_COOLDOWN,
                        )
                        .exists(),
                    )
                )
            )
            .scalars()
            .all()
        )
        for user in winback_users:
            if budget <= 0:
                break
            ok = await ep.send_program_email(
                session,
                user=user,
                kind=ep.KIND_WIN_BACK,
                subject="Campus kept eating",
                body=(
                    "It's been a minute.\n\n"
                    "Runs are still rolling every day — open the app and see "
                    "what's heading out tonight."
                ),
                marketing=True,
            )
            sent["win_back"] += int(ok)
            _spend(ok)

    # 4) Weekly digest — Sundays, only when the week actually had runs.
    if budget > 0 and now.weekday() == 6:
        week_ago = now - timedelta(days=7)
        total_runs = (
            await session.execute(select(func.count(Run.id)).where(Run.created_at >= week_ago))
        ).scalar_one()
        if total_runs:
            top_spots = (
                await session.execute(
                    select(FoodSpot.name, func.count(Run.id).label("n"))
                    .join(Run, Run.food_spot_id == FoodSpot.id)
                    .where(Run.created_at >= week_ago)
                    .group_by(FoodSpot.name)
                    .order_by(func.count(Run.id).desc())
                    .limit(3)
                )
            ).all()
            spot_lines = "\n".join(
                f"{i + 1}. {name} ({n} run{'s' if n != 1 else ''})"
                for i, (name, n) in enumerate(top_spots)
            )
            body = (
                f"{total_runs} runs on Trot this week. Busiest spots:\n\n"
                f"{spot_lines}\n\n"
                "Post a run this week and keep the fees."
            )
            digest_users = (
                (
                    await session.execute(
                        select(User).where(
                            User.last_active_at >= now - DIGEST_ACTIVE_WINDOW,
                            User.email_verified_at.is_not(None),
                            User.status == UserStatus.active,
                        )
                    )
                )
                .scalars()
                .all()
            )
            for user in digest_users:
                if budget <= 0:
                    break
                ok = await ep.send_program_email(
                    session,
                    user=user,
                    kind=ep.KIND_WEEKLY_DIGEST,
                    subject="This week on Trot",
                    body=body,
                    marketing=True,
                )
                sent["digest"] += int(ok)
                _spend(ok)

    await session.commit()
    log.info("jobs.marketing_emails", **sent, budget_left=budget)
    return sent


async def aggregate_daily_metrics_job(
    session: AsyncSession, *, day: date | None = None
) -> dict[str, float]:
    """Aggregate yesterday's analytics events into daily_metrics (spec §12). Idempotent:
    reruns delete-and-rewrite the day's rows instead of duplicating them."""
    target = day or (datetime.now(UTC).date() - timedelta(days=1))
    start = datetime.combine(target, time.min, tzinfo=UTC)
    end = start + timedelta(days=1)

    rows = await session.execute(
        select(AnalyticsEvent.name, func.count(AnalyticsEvent.id))
        .where(AnalyticsEvent.created_at >= start, AnalyticsEvent.created_at < end)
        .group_by(AnalyticsEvent.name)
    )
    counts = {str(name): float(count) for name, count in rows}
    # North-star input (spec §12): distinct users completing >=1 core action.
    active_peers = (
        await session.execute(
            select(func.count(func.distinct(AnalyticsEvent.user_id))).where(
                AnalyticsEvent.created_at >= start,
                AnalyticsEvent.created_at < end,
                AnalyticsEvent.user_id.is_not(None),
            )
        )
    ).scalar_one()
    counts["active_peers"] = float(active_peers)

    await session.execute(delete(DailyMetric).where(DailyMetric.day == target))
    for name, value in counts.items():
        session.add(DailyMetric(day=target, name=name, value=value))
    await session.commit()
    log.info("jobs.aggregate_daily_metrics", day=str(target), metrics=len(counts))
    return counts
