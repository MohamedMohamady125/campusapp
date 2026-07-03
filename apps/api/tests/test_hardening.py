"""M8 hardening tests: security headers, flags endpoint, cache, WS gating."""

import asyncio
import uuid

import httpx
from fastapi import FastAPI
from sqlalchemy import update
from starlette.testclient import TestClient

from app.core.cache import reset_cache
from app.db.session import async_session_factory
from app.models import Flag
from app.services.flag_service import is_enabled
from tests.helpers import PASSWORD, make_user


async def _seed_flag(key: str, *, enabled: bool, rollout_percent: int = 100) -> None:
    async with async_session_factory() as session:
        session.add(Flag(key=key, enabled=enabled, rollout_percent=rollout_percent))
        await session.commit()


# -- security headers -----------------------------------------------------------


async def test_security_headers_present(client: httpx.AsyncClient) -> None:
    resp = await client.get("/api/v1/health")
    assert resp.status_code == 200
    assert resp.headers["x-content-type-options"] == "nosniff"
    assert resp.headers["x-frame-options"] == "DENY"
    assert resp.headers["referrer-policy"] == "no-referrer"
    assert "max-age=" in resp.headers["strict-transport-security"]
    assert "camera=()" in resp.headers["permissions-policy"]


# -- flags ------------------------------------------------------------------


async def test_flags_endpoint_and_cache(client: httpx.AsyncClient) -> None:
    await _seed_flag("realtime", enabled=False)
    await _seed_flag("escrow", enabled=True, rollout_percent=50)

    resp = await client.get("/api/v1/flags")
    assert resp.status_code == 200
    by_key = {f["key"]: f for f in resp.json()}
    assert by_key["realtime"]["enabled"] is False
    assert by_key["escrow"] == {"key": "escrow", "enabled": True, "rollout_percent": 50}

    # Cached: a direct DB change is invisible until TTL/invalidation.
    async with async_session_factory() as session:
        await session.execute(update(Flag).where(Flag.key == "realtime").values(enabled=True))
        await session.commit()
    resp = await client.get("/api/v1/flags")
    assert {f["key"]: f["enabled"] for f in resp.json()}["realtime"] is False  # stale by design

    reset_cache()
    resp = await client.get("/api/v1/flags")
    assert {f["key"]: f["enabled"] for f in resp.json()}["realtime"] is True


async def test_is_enabled_rollout(client: httpx.AsyncClient) -> None:
    await _seed_flag("full_on", enabled=True, rollout_percent=100)
    await _seed_flag("dark", enabled=False, rollout_percent=100)
    await _seed_flag("partial", enabled=True, rollout_percent=50)

    user_id = uuid.uuid4()
    async with async_session_factory() as session:
        assert await is_enabled(session, "full_on") is True
        assert await is_enabled(session, "dark", user_id=user_id) is False
        assert await is_enabled(session, "missing") is False
        # partial rollout: deterministic per user, dark for anonymous callers
        first = await is_enabled(session, "partial", user_id=user_id)
        assert await is_enabled(session, "partial", user_id=user_id) is first
        assert await is_enabled(session, "partial") is False


# -- websocket gating (flags.realtime) ---------------------------------------


def _login_ws_user(tc: TestClient, email: str) -> str:
    """Register + verify + login via TestClient; returns raw access token."""
    from app.integrations.email.provider import get_email_provider
    from app.integrations.email.stub import StubEmailProvider

    assert (
        tc.post(
            "/api/v1/auth/register",
            json={"email": email, "password": PASSWORD, "display_name": email.split("@")[0]},
        ).status_code
        == 201
    )
    provider = get_email_provider()
    assert isinstance(provider, StubEmailProvider)
    code = [m for m in provider.sent if m["to"] == email][-1]["body"].split()[-1].rstrip(".")
    assert tc.post("/api/v1/auth/verify", json={"email": email, "code": code}).status_code == 200
    login = tc.post("/api/v1/auth/login", json={"email": email, "password": PASSWORD})
    assert login.status_code == 200
    return str(login.json()["access_token"])


def test_ws_dark_without_flag_and_live_with_it(app: FastAPI) -> None:
    with TestClient(app) as tc:
        token = _login_ws_user(tc, "wsuser@campus.edu")
        headers = {"Authorization": f"Bearer {token}"}
        chat = tc.post("/api/v1/chats", json={"name": "WS Chat"}, headers=headers).json()

        # Flag missing → forbidden (dark by default).
        with tc.websocket_connect(f"/api/v1/ws/chats/{chat['id']}?token={token}") as ws:
            assert ws.receive()["type"] == "websocket.close"

        # Bad token → 4401 close.
        with tc.websocket_connect(f"/api/v1/ws/chats/{chat['id']}?token=nope") as ws:
            msg = ws.receive()
            assert msg["type"] == "websocket.close"
            assert msg["code"] == 4401

        # Enable the flag → member receives messages posted over HTTP.
        asyncio.run(_seed_flag("realtime", enabled=True))
        reset_cache()

        with tc.websocket_connect(f"/api/v1/ws/chats/{chat['id']}?token={token}") as ws:
            resp = tc.post(
                f"/api/v1/chats/{chat['id']}/messages", json={"body": "live!"}, headers=headers
            )
            assert resp.status_code == 201
            event = ws.receive_json()
            assert event["type"] == "chat_message"
            assert event["body"] == "live!"
            assert event["chat_id"] == chat["id"]


async def test_tutor_search_cache_invalidated_on_offering_change(
    client: httpx.AsyncClient,
) -> None:
    from app.models import Course

    tutor = await make_user(client, "tutor@campus.edu")
    seeker = await make_user(client, "seeker@campus.edu")
    async with async_session_factory() as session:
        course = Course(code="CS999", title="Cache Systems", department="CS")
        session.add(course)
        await session.commit()
        course_id = str(course.id)

    # Prime the cache with an empty result.
    resp = await client.get("/api/v1/tutoring/tutors", params={"course": "CS999"}, headers=seeker)
    assert resp.status_code == 200 and resp.json()["items"] == []

    # Creating an offering must invalidate the cached ranked list.
    resp = await client.post(
        "/api/v1/tutoring/offerings",
        json={"course_id": course_id, "term_taken": "2025-fall", "grade_received": "A"},
        headers=tutor,
    )
    assert resp.status_code == 201, resp.text
    resp = await client.get("/api/v1/tutoring/tutors", params={"course": "CS999"}, headers=seeker)
    assert len(resp.json()["items"]) == 1
