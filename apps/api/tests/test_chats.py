"""Community chat tests (spec §14 M7): J3 E2E, caps, moderation + audit, notifications."""

import httpx
from sqlalchemy import select

from app.db.session import async_session_factory
from app.models import AuditLog
from tests.helpers import make_user


async def _user_id(client: httpx.AsyncClient, headers: dict[str, str]) -> str:
    return str((await client.get("/api/v1/users/me", headers=headers)).json()["id"])


async def _create_chat(
    client: httpx.AsyncClient, headers: dict[str, str], **overrides: object
) -> dict[str, object]:
    body: dict[str, object] = {"name": "CS Study Group", "description": "Algorithms & more"}
    body.update(overrides)
    resp = await client.post("/api/v1/chats", json=body, headers=headers)
    assert resp.status_code == 201, resp.text
    return dict(resp.json())


async def test_j3_browse_join_post(client: httpx.AsyncClient) -> None:
    """E2E J3: browse directory → join → post (spec §1)."""
    owner = await make_user(client, "owner@campus.edu")
    member = await make_user(client, "member@campus.edu")
    chat = await _create_chat(client, owner)

    # Directory shows the chat with member count; slug generated.
    resp = await client.get("/api/v1/chats/directory", headers=member)
    listed = [c for c in resp.json()["items"] if c["id"] == chat["id"]]
    assert listed and listed[0]["slug"] == "cs-study-group"
    assert listed[0]["member_count"] == 1  # owner auto-joined

    # Join and post.
    assert (
        await client.post(f"/api/v1/chats/{chat['id']}/join", headers=member)
    ).status_code == 201
    resp = await client.post(
        f"/api/v1/chats/{chat['id']}/messages", json={"body": "hello!"}, headers=member
    )
    assert resp.status_code == 201

    # Both members see it; appears in "my chats".
    resp = await client.get(f"/api/v1/chats/{chat['id']}/messages", headers=owner)
    assert [m["body"] for m in resp.json()["items"]] == ["hello!"]
    resp = await client.get("/api/v1/chats", headers=member)
    assert chat["id"] in [c["id"] for c in resp.json()["items"]]

    # Non-members cannot read or post.
    outsider = await make_user(client, "outsider@campus.edu")
    assert (
        await client.get(f"/api/v1/chats/{chat['id']}/messages", headers=outsider)
    ).status_code == 403


async def test_member_cap_and_visibility(client: httpx.AsyncClient) -> None:
    owner = await make_user(client, "owner@campus.edu")
    chat = await _create_chat(client, owner, member_cap=2)

    second = await make_user(client, "second@campus.edu")
    third = await make_user(client, "third@campus.edu")
    assert (
        await client.post(f"/api/v1/chats/{chat['id']}/join", headers=second)
    ).status_code == 201
    resp = await client.post(f"/api/v1/chats/{chat['id']}/join", headers=third)
    assert resp.status_code == 422
    assert resp.json()["error"]["code"] == "CHAT_FULL"

    # Private chats are hidden from the directory and cannot be joined.
    private = await _create_chat(client, owner, name="Secret Society", visibility="private")
    resp = await client.get("/api/v1/chats/directory", headers=third)
    assert private["id"] not in [c["id"] for c in resp.json()["items"]]
    resp = await client.post(f"/api/v1/chats/{private['id']}/join", headers=third)
    assert resp.status_code == 403

    # Leave frees a slot; owner cannot leave.
    assert (
        await client.post(f"/api/v1/chats/{chat['id']}/leave", headers=second)
    ).status_code == 204
    assert (await client.post(f"/api/v1/chats/{chat['id']}/join", headers=third)).status_code == 201
    resp = await client.post(f"/api/v1/chats/{chat['id']}/leave", headers=owner)
    assert resp.status_code == 422
    assert resp.json()["error"]["code"] == "OWNER_CANNOT_LEAVE"


async def test_moderation_with_audit_log(client: httpx.AsyncClient) -> None:
    """A mod can delete/mute/ban — each action writes an AuditLog (M7 acceptance)."""
    owner = await make_user(client, "owner@campus.edu")
    member = await make_user(client, "member@campus.edu")
    chat = await _create_chat(client, owner)
    member_id = await _user_id(client, member)
    await client.post(f"/api/v1/chats/{chat['id']}/join", headers=member)

    resp = await client.post(
        f"/api/v1/chats/{chat['id']}/messages", json={"body": "spam"}, headers=member
    )
    message_id = resp.json()["id"]

    # Plain members cannot moderate.
    resp = await client.post(
        f"/api/v1/chats/{chat['id']}/messages/{message_id}/delete",
        json={"reason": "not a mod"},
        headers=member,
    )
    assert resp.status_code == 403

    # Owner deletes the message → it stays in the feed as a tombstone (Sprint 6).
    resp = await client.post(
        f"/api/v1/chats/{chat['id']}/messages/{message_id}/delete",
        json={"reason": "spam content"},
        headers=owner,
    )
    assert resp.status_code == 204
    resp = await client.get(f"/api/v1/chats/{chat['id']}/messages", headers=owner)
    tombstone = resp.json()["items"][0]
    assert tombstone["deleted_at"] is not None
    assert tombstone["body"] == ""

    # Mute → posting blocked with MUTED.
    resp = await client.post(
        f"/api/v1/chats/{chat['id']}/members/{member_id}/mute",
        json={"minutes": 30, "reason": "spamming"},
        headers=owner,
    )
    assert resp.status_code == 200 and resp.json()["muted_until"] is not None
    resp = await client.post(
        f"/api/v1/chats/{chat['id']}/messages", json={"body": "still here"}, headers=member
    )
    assert resp.status_code == 403
    assert resp.json()["error"]["code"] == "MUTED"

    # Ban → no access, and rejoin is blocked.
    resp = await client.post(f"/api/v1/chats/{chat['id']}/members/{member_id}/ban", headers=owner)
    assert resp.status_code == 200 and resp.json()["banned_at"] is not None
    assert (
        await client.get(f"/api/v1/chats/{chat['id']}/messages", headers=member)
    ).status_code == 403
    resp = await client.post(f"/api/v1/chats/{chat['id']}/join", headers=member)
    assert resp.status_code == 403
    assert resp.json()["error"]["code"] == "BANNED"

    # The owner cannot be moderated.
    owner_id = await _user_id(client, owner)
    resp = await client.post(f"/api/v1/chats/{chat['id']}/members/{owner_id}/ban", headers=owner)
    assert resp.status_code == 403

    # Every action left an audit trail.
    async with async_session_factory() as session:
        actions = [a[0] for a in (await session.execute(select(AuditLog.action))).all()]
    assert "chat_message.delete" in actions
    assert "chat_member.mute" in actions
    assert "chat_member.ban" in actions


async def test_notifications_fire_per_preferences(client: httpx.AsyncClient) -> None:
    owner = await make_user(client, "owner@campus.edu")
    fan = await make_user(client, "fan@campus.edu")
    quiet = await make_user(client, "quiet@campus.edu")
    chat = await _create_chat(client, owner)
    for h in (fan, quiet):
        await client.post(f"/api/v1/chats/{chat['id']}/join", headers=h)

    # quiet opts out of chat_message notifications.
    resp = await client.patch(
        "/api/v1/notifications/preferences",
        json={"preferences": [{"type": "chat_message", "enabled": False}]},
        headers=quiet,
    )
    assert resp.status_code == 200

    await client.post(
        f"/api/v1/chats/{chat['id']}/messages", json={"body": "big news"}, headers=owner
    )

    # fan gets a notification + bell badge; quiet gets none; sender gets none.
    resp = await client.get("/api/v1/notifications", headers=fan)
    assert resp.json()["unread_count"] == 1
    assert resp.json()["items"][0]["type"] == "chat_message"
    assert resp.json()["items"][0]["payload"]["chat_id"] == chat["id"]
    assert (await client.get("/api/v1/notifications", headers=quiet)).json()["unread_count"] == 0
    assert (await client.get("/api/v1/notifications", headers=owner)).json()["unread_count"] == 0

    # Mark read clears the badge.
    assert (
        await client.post("/api/v1/notifications/read", json={}, headers=fan)
    ).status_code == 204
    assert (await client.get("/api/v1/notifications", headers=fan)).json()["unread_count"] == 0
