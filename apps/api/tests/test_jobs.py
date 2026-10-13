"""Background job tests (spec §5.4): idempotent expiry and purge."""

from datetime import UTC, datetime, timedelta

import httpx
from sqlalchemy import func, select

from app.db.session import async_session_factory
from app.models import DailyMetric, Listing, Notification, User
from app.models.enums import ListingStatus
from app.workers.jobs import (
    expire_listings_job,
    purge_notifications_job,
    purge_verification_codes_job,
    recompute_global_mean_job,
)
from app.workers.maintenance import maintenance_tick
from tests.helpers import make_user


async def test_expire_listings_idempotent(client: httpx.AsyncClient) -> None:
    seller = await make_user(client, "seller@campus.edu")
    resp = await client.post(
        "/api/v1/listings",
        json={
            "title": "Old lamp",
            "description": "x",
            "price_cents": 100,
            "category": "other",
            "condition": "good",
        },
        headers=seller,
    )
    listing_id = resp.json()["id"]

    async with async_session_factory() as session:
        listing = await session.get(Listing, listing_id)
        assert listing is not None
        listing.expires_at = datetime.now(UTC) - timedelta(days=1)
        await session.commit()

    async with async_session_factory() as session:
        assert await expire_listings_job(session) == 1
        assert await expire_listings_job(session) == 0  # idempotent

    async with async_session_factory() as session:
        listing = await session.get(Listing, listing_id)
        assert listing is not None and listing.status == ListingStatus.removed


async def test_purge_verification_codes(client: httpx.AsyncClient) -> None:
    # Registering + verifying leaves one consumed code behind.
    await make_user(client, "someone@campus.edu")
    async with async_session_factory() as session:
        assert await purge_verification_codes_job(session) >= 1
        assert await purge_verification_codes_job(session) == 0


async def test_global_mean_seeded_when_empty() -> None:
    async with async_session_factory() as session:
        assert await recompute_global_mean_job(session) == 4.0


async def test_purge_notifications_respects_retention(client: httpx.AsyncClient) -> None:
    await make_user(client, "belle@campus.edu")
    now = datetime.now(UTC)
    async with async_session_factory() as session:
        user_id = (await session.execute(select(User.id).limit(1))).scalar_one()
        old = Notification(user_id=user_id, type="system", payload={})
        fresh = Notification(user_id=user_id, type="system", payload={})
        session.add_all([old, fresh])
        await session.flush()
        old.created_at = now - timedelta(days=120)
        await session.commit()

    async with async_session_factory() as session:
        assert await purge_notifications_job(session) == 1
        assert await purge_notifications_job(session) == 0  # idempotent
        remaining = (await session.execute(select(Notification.id))).scalars().all()
        assert len(remaining) == 1


async def test_maintenance_tick_runs_daily_batch_once() -> None:
    """The daily batch runs when yesterday has no metrics rows, then goes
    quiet: aggregate_daily_metrics_job's output is the done-marker."""
    yesterday = datetime.now(UTC).date() - timedelta(days=1)
    async with async_session_factory() as session:
        await maintenance_tick(session)
        rows = (
            (await session.execute(select(DailyMetric).where(DailyMetric.day == yesterday)))
            .scalars()
            .all()
        )
        assert rows, "daily batch should have written yesterday's metrics marker"

    # Second tick: marker present, batch skipped — row set unchanged.
    async with async_session_factory() as session:
        await maintenance_tick(session)
        count = (
            await session.execute(
                select(func.count()).select_from(DailyMetric).where(DailyMetric.day == yesterday)
            )
        ).scalar_one()
        assert count == len(rows)
