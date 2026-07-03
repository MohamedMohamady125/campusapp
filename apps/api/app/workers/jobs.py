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
from app.models.enums import ListingStatus

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
