"""Behavioural analytics: client ingest + admin behavior insights (spec §12)."""

from datetime import UTC, datetime

import httpx
import pytest
from sqlalchemy import select, update

from app.db.session import async_session_factory
from app.models import AnalyticsEvent, User
from app.models.enums import UserRole

from .helpers import make_user

pytestmark = pytest.mark.anyio


def _batch(session_id: str = "session-abc-123", **overrides: object) -> dict[str, object]:
    now = datetime.now(UTC).isoformat()
    payload: dict[str, object] = {
        "session_id": session_id,
        "platform": "ios",
        "events": [
            {
                "name": "screen_view",
                "occurred_at": now,
                "screen": "/runs",
                "duration_ms": 12_000,
            },
            {
                "name": "screen_view",
                "occurred_at": now,
                "screen": "/runs/run/:id",
                "duration_ms": 30_000,
            },
            {
                "name": "run_order_placed",
                "occurred_at": now,
                "properties": {"prepay": True},
            },
        ],
    }
    payload.update(overrides)
    return payload


async def test_ingest_requires_auth_and_validates(client: httpx.AsyncClient) -> None:
    assert (await client.post("/api/v1/analytics/events", json=_batch())).status_code == 401

    headers = await make_user(client, "tracker@campus.edu")
    # Bad event name (uppercase) rejected at the boundary.
    bad = _batch(events=[{"name": "DROP TABLE", "occurred_at": datetime.now(UTC).isoformat()}])
    assert (
        await client.post("/api/v1/analytics/events", json=bad, headers=headers)
    ).status_code == 400
    # Oversized batch rejected.
    event = {"name": "tap", "occurred_at": datetime.now(UTC).isoformat()}
    too_big = _batch(events=[event] * 51)
    assert (
        await client.post("/api/v1/analytics/events", json=too_big, headers=headers)
    ).status_code == 400


async def test_ingest_stores_events_with_context(client: httpx.AsyncClient) -> None:
    headers = await make_user(client, "tracker@campus.edu")
    resp = await client.post("/api/v1/analytics/events", json=_batch(), headers=headers)
    assert resp.status_code == 204

    async with async_session_factory() as session:
        rows = (await session.execute(select(AnalyticsEvent))).scalars().all()
        client_rows = [r for r in rows if r.name.startswith("app.")]
        assert len(client_rows) == 3
        view = next(r for r in client_rows if r.properties.get("screen") == "/runs")
        assert view.name == "app.screen_view"
        assert view.properties["session_id"] == "session-abc-123"
        assert view.properties["platform"] == "ios"
        assert view.properties["duration_ms"] == 12_000
        assert view.user_id is not None
        action = next(r for r in client_rows if r.name == "app.run_order_placed")
        assert action.properties["prepay"] is True


async def test_admin_behavior_aggregates(client: httpx.AsyncClient) -> None:
    student = await make_user(client, "student@campus.edu")
    admin = await make_user(client, "admin@campus.edu")
    async with async_session_factory() as session:
        await session.execute(
            update(User).where(User.email == "admin@campus.edu").values(role=UserRole.admin)
        )
        await session.commit()

    # Students can't read behaviour data.
    assert (await client.get("/api/v1/admin/behavior", headers=student)).status_code == 403

    # Two sessions from two users.
    for who, sid in ((student, "sess-student-01"), (admin, "sess-admin-001")):
        resp = await client.post(
            "/api/v1/analytics/events", json=_batch(session_id=sid), headers=who
        )
        assert resp.status_code == 204

    resp = await client.get("/api/v1/admin/behavior?days=7", headers=admin)
    assert resp.status_code == 200
    body = resp.json()

    screens = {s["screen"]: s for s in body["screens"]}
    assert screens["/runs"]["views"] == 2
    assert screens["/runs"]["unique_users"] == 2
    assert screens["/runs"]["avg_seconds"] == 12.0
    assert screens["/runs/run/:id"]["avg_seconds"] == 30.0

    top = {e["name"]: e for e in body["top_events"]}
    assert top["app.run_order_placed"]["count"] == 2
    assert "app.screen_view" not in top

    assert body["daily"], "daily rollup missing"
    today = body["daily"][0]
    assert today["active_users"] >= 2
    assert today["sessions"] >= 2
