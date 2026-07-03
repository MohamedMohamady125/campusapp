"""Idempotent async job bodies (spec §5.4) — called by Celery tasks and tests.

Kept separate from Celery task wrappers so tests can invoke them directly
without a broker.
"""

from datetime import UTC, datetime
from typing import Any, cast

import structlog
from sqlalchemy import CursorResult, delete, func, or_, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.scoring import GLOBAL_MEAN_SEED
from app.models import Listing, Rating, VerificationCode
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
