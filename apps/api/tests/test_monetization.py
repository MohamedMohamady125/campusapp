"""M9 monetization + analytics tests (spec §12, §13): all rails dark by default."""

import httpx
from sqlalchemy import func, select, update

from app.core.cache import reset_cache
from app.db.session import async_session_factory
from app.models import AnalyticsEvent, DailyMetric, Flag, Payment, User
from app.models.enums import UserRole
from app.workers.jobs import aggregate_daily_metrics_job
from tests.helpers import make_user


async def _enable_flag(key: str) -> None:
    async with async_session_factory() as session:
        session.add(Flag(key=key, enabled=True))
        await session.commit()
    reset_cache()  # the flags list is cached (30s TTL); drop it so the change is visible


async def _create_listing(
    client: httpx.AsyncClient, headers: dict[str, str], title: str
) -> dict[str, object]:
    resp = await client.post(
        "/api/v1/listings",
        json={
            "title": title,
            "description": "Barely used, great condition.",
            "price_cents": 4500,
            "category": "textbooks",
            "condition": "good",
        },
        headers=headers,
    )
    assert resp.status_code == 201, resp.text
    return dict(resp.json())


# -- promoted listings (spec §13.1) -------------------------------------------


async def test_promote_dark_by_default(client: httpx.AsyncClient) -> None:
    seller = await make_user(client, "seller@campus.edu")
    listing = await _create_listing(client, seller, "Calculus Textbook")
    resp = await client.post(f"/api/v1/listings/{listing['id']}/promote", headers=seller)
    assert resp.status_code == 403
    assert resp.json()["error"]["code"] == "FEATURE_DISABLED"


async def test_promote_boosts_search_rank(client: httpx.AsyncClient) -> None:
    """Acceptance (spec §14 M9): enabling flags.promoted_listings boosts a listing's rank."""
    await _enable_flag("promoted_listings")
    seller = await make_user(client, "seller@campus.edu")
    first = await _create_listing(client, seller, "Physics Textbook Vol 1")
    second = await _create_listing(client, seller, "Physics Textbook Vol 2")

    # Newest-first tie ordering: without a boost, `second` ranks above `first`.
    resp = await client.get("/api/v1/listings", params={"q": "physics textbook"}, headers=seller)
    ids = [x["id"] for x in resp.json()["items"]]
    assert ids.index(second["id"]) < ids.index(first["id"])

    # Owner promotes the older listing -> it now ranks first.
    resp = await client.post(f"/api/v1/listings/{first['id']}/promote", headers=seller)
    assert resp.status_code == 200, resp.text
    assert resp.json()["id"] == first["id"]
    resp = await client.get("/api/v1/listings", params={"q": "physics textbook"}, headers=seller)
    ids = [x["id"] for x in resp.json()["items"]]
    assert ids.index(first["id"]) < ids.index(second["id"])

    # Ledger row written by the stub provider — no real charge path.
    async with async_session_factory() as session:
        payment = (await session.execute(select(Payment))).scalar_one()
        assert payment.provider == "stub"
        assert payment.status == "succeeded"
        assert payment.idempotency_key.startswith("promote:")

    # Retry is idempotent: no second ledger row, boost not double-extended.
    resp = await client.post(f"/api/v1/listings/{first['id']}/promote", headers=seller)
    assert resp.status_code == 200
    async with async_session_factory() as session:
        count = (await session.execute(select(func.count(Payment.id)))).scalar_one()
        assert count == 1

    # Only the owner can promote.
    other = await make_user(client, "other@campus.edu")
    resp = await client.post(f"/api/v1/listings/{second['id']}/promote", headers=other)
    assert resp.status_code == 403
    assert resp.json()["error"]["code"] == "NOT_OWNER"


# -- tutor premium (spec §13.2) -----------------------------------------------


async def test_tutor_premium_subscription_and_entitlement(client: httpx.AsyncClient) -> None:
    tutor = await make_user(client, "tutor@campus.edu")

    # Dark by default.
    resp = await client.post("/api/v1/tutoring/premium/subscription", headers=tutor)
    assert resp.status_code == 403
    assert resp.json()["error"]["code"] == "FEATURE_DISABLED"

    await _enable_flag("tutor_premium")
    resp = await client.post("/api/v1/tutoring/premium/subscription", headers=tutor)
    assert resp.status_code == 201, resp.text
    sub = resp.json()
    assert sub["plan"] == "tutor_premium" and sub["status"] == "active"

    # Idempotent while active; ledger has exactly one row.
    resp = await client.post("/api/v1/tutoring/premium/subscription", headers=tutor)
    assert resp.status_code == 201
    async with async_session_factory() as session:
        count = (await session.execute(select(func.count(Payment.id)))).scalar_one()
        assert count == 1

    # Cancel keeps entitlement until period end (status canceled).
    resp = await client.delete("/api/v1/tutoring/premium/subscription", headers=tutor)
    assert resp.status_code == 200
    assert resp.json()["status"] == "canceled"


# -- analytics pipeline (spec §12) --------------------------------------------


async def test_analytics_events_land_in_table(client: httpx.AsyncClient) -> None:
    """Acceptance (spec §14 M9): analytics events land in the table."""
    seller = await make_user(client, "seller@campus.edu")  # emits signup_completed
    await _create_listing(client, seller, "Econ Textbook")  # emits listing_created

    async with async_session_factory() as session:
        names = set((await session.execute(select(AnalyticsEvent.name))).scalars().all())
    assert {"signup_completed", "listing_created"} <= names


async def test_daily_metrics_job_idempotent(client: httpx.AsyncClient) -> None:
    from datetime import UTC, datetime

    seller = await make_user(client, "seller@campus.edu")
    await _create_listing(client, seller, "Bio Textbook")

    today = datetime.now(UTC).date()
    async with async_session_factory() as session:
        first = await aggregate_daily_metrics_job(session, day=today)
    assert first["listing_created"] == 1.0
    assert first["active_peers"] >= 1.0

    # Rerun rewrites, never duplicates.
    async with async_session_factory() as session:
        await aggregate_daily_metrics_job(session, day=today)
        rows = (
            await session.execute(
                select(func.count(DailyMetric.id)).where(DailyMetric.day == today)
            )
        ).scalar_one()
    assert rows == len(first)


async def test_admin_metrics_endpoint(client: httpx.AsyncClient) -> None:
    from datetime import UTC, datetime

    student = await make_user(client, "student@campus.edu")
    admin = await make_user(client, "admin@campus.edu")
    async with async_session_factory() as session:
        await session.execute(
            update(User).where(User.email == "admin@campus.edu").values(role=UserRole.admin)
        )
        await session.commit()
        await aggregate_daily_metrics_job(session, day=datetime.now(UTC).date())

    # Students are locked out.
    assert (await client.get("/api/v1/admin/metrics", headers=student)).status_code == 403

    resp = await client.get("/api/v1/admin/metrics", headers=admin)
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["totals"]["users"] == 2
    assert any(m["name"] == "signup_completed" for m in body["daily"])
