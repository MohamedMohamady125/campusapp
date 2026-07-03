"""Background job tests (spec §5.4): idempotent expiry and purge."""

from datetime import UTC, datetime, timedelta

import httpx

from app.db.session import async_session_factory
from app.models import Listing
from app.models.enums import ListingStatus
from app.workers.jobs import (
    expire_listings_job,
    purge_verification_codes_job,
    recompute_global_mean_job,
)
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
