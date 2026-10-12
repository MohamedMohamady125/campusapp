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
from app.models import AnalyticsEvent, DailyMetric, Listing, Rating, VerificationCode
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
            .options(selectinload(Run.food_spot), selectinload(Run.runner))
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
