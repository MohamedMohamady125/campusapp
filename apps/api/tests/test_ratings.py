"""Reputation §5.2 unit tests (incl. cold start) + rating/report API tests."""

import httpx
import pytest
from sqlalchemy import update

from app.core.scoring import GLOBAL_MEAN_SEED, bayesian_reputation
from app.db.session import async_session_factory
from app.models import User
from app.models.enums import UserRole
from tests.helpers import make_user

# --- §5.2 unit tests -------------------------------------------------------


def test_bayesian_cold_start_neutral() -> None:
    """A brand-new user sits at the global mean, not at 0."""
    assert bayesian_reputation(
        ratings_sum=0, ratings_count=0, global_mean=GLOBAL_MEAN_SEED
    ) == pytest.approx(4.0)


def test_bayesian_small_sample_does_not_outrank_large() -> None:
    """Two 5★ must not outrank two hundred 4.8★ (spec §5.2)."""
    two_fives = bayesian_reputation(ratings_sum=10, ratings_count=2, global_mean=4.0)
    many_high = bayesian_reputation(ratings_sum=4.8 * 200, ratings_count=200, global_mean=4.0)
    assert many_high > two_fives
    assert two_fives == pytest.approx((8 * 4.0 + 10) / 10)


def test_bayesian_converges_to_true_mean() -> None:
    assert bayesian_reputation(
        ratings_sum=3.0 * 10_000, ratings_count=10_000, global_mean=4.0
    ) == pytest.approx(3.0, abs=0.01)


# --- API tests --------------------------------------------------------------


async def _setup_listing(
    client: httpx.AsyncClient,
) -> tuple[dict[str, str], dict[str, str], str, str]:
    seller = await make_user(client, "seller@campus.edu")
    buyer = await make_user(client, "buyer@campus.edu")
    resp = await client.post(
        "/api/v1/listings",
        json={
            "title": "Mini fridge",
            "description": "Cold",
            "price_cents": 4000,
            "category": "electronics",
            "condition": "good",
        },
        headers=seller,
    )
    listing_id = str(resp.json()["id"])
    seller_id = str(resp.json()["seller"]["id"])
    return seller, buyer, listing_id, seller_id


async def test_rating_updates_cached_score_in_transaction(client: httpx.AsyncClient) -> None:
    _seller, buyer, listing_id, seller_id = await _setup_listing(client)

    resp = await client.post(
        "/api/v1/ratings",
        json={
            "rated_user_id": seller_id,
            "context_type": "listing",
            "context_id": listing_id,
            "stars": 5,
            "comment": "Great seller",
        },
        headers=buyer,
    )
    assert resp.status_code == 201, resp.text

    # Cached score visible immediately on the public profile.
    profile = (await client.get(f"/api/v1/users/{seller_id}", headers=buyer)).json()
    assert profile["rating_count"] == 1
    # First platform rating: m = avg = 5 → (8*5 + 5) / 9 = 5.0
    assert profile["reputation_score"] == pytest.approx(5.0)

    # Ratings listable on the profile endpoint.
    ratings = (await client.get(f"/api/v1/users/{seller_id}/ratings", headers=buyer)).json()
    assert [r["stars"] for r in ratings["items"]] == [5]


async def test_double_rating_conflicts(client: httpx.AsyncClient) -> None:
    _seller, buyer, listing_id, seller_id = await _setup_listing(client)
    body = {
        "rated_user_id": seller_id,
        "context_type": "listing",
        "context_id": listing_id,
        "stars": 4,
    }
    assert (await client.post("/api/v1/ratings", json=body, headers=buyer)).status_code == 201
    resp = await client.post("/api/v1/ratings", json=body, headers=buyer)
    assert resp.status_code == 409
    assert resp.json()["error"]["code"] == "ALREADY_RATED"


async def test_rating_guards(client: httpx.AsyncClient) -> None:
    seller, _buyer, listing_id, seller_id = await _setup_listing(client)

    # Self-rating blocked.
    resp = await client.post(
        "/api/v1/ratings",
        json={
            "rated_user_id": seller_id,
            "context_type": "listing",
            "context_id": listing_id,
            "stars": 5,
        },
        headers=seller,
    )
    assert resp.status_code == 422
    assert resp.json()["error"]["code"] == "SELF_RATING"

    # Stars outside 1-5 rejected by Pydantic.
    buyer = await make_user(client, "buyer2@campus.edu")
    resp = await client.post(
        "/api/v1/ratings",
        json={
            "rated_user_id": seller_id,
            "context_type": "listing",
            "context_id": listing_id,
            "stars": 6,
        },
        headers=buyer,
    )
    assert resp.status_code == 400  # boundary validation → envelope 400


async def test_report_flow_with_moderation(client: httpx.AsyncClient) -> None:
    _seller, buyer, listing_id, _seller_id = await _setup_listing(client)

    resp = await client.post(
        "/api/v1/reports",
        json={"target_type": "listing", "target_id": listing_id, "reason": "Spam listing"},
        headers=buyer,
    )
    assert resp.status_code == 201
    report_id = resp.json()["id"]
    assert resp.json()["status"] == "open"

    # Plain students cannot access the moderation queue.
    assert (await client.get("/api/v1/admin/reports", headers=buyer)).status_code == 403

    # Promote a moderator and action the report.
    mod = await make_user(client, "mod@campus.edu")
    async with async_session_factory() as session:
        await session.execute(
            update(User).where(User.email == "mod@campus.edu").values(role=UserRole.moderator)
        )
        await session.commit()

    queue = (await client.get("/api/v1/admin/reports", headers=mod)).json()
    assert report_id in [r["id"] for r in queue["items"]]

    resp = await client.patch(
        f"/api/v1/admin/reports/{report_id}", json={"status": "actioned"}, headers=mod
    )
    assert resp.status_code == 200
    assert resp.json()["status"] == "actioned"
    assert resp.json()["handled_by_id"] is not None
