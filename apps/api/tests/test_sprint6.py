"""Sprint 6 tests: tombstone deletes, @mentions, notification dedup,
DM notifications, and owner-only promote."""

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
    body: dict[str, object] = {"name": "Sprint Six Chat", "description": "testing"}
    body.update(overrides)
    resp = await client.post("/api/v1/chats", json=body, headers=headers)
    assert resp.status_code == 201, resp.text
    return dict(resp.json())


async def _post(
    client: httpx.AsyncClient, chat_id: object, headers: dict[str, str], body: str
) -> dict[str, object]:
    resp = await client.post(
        f"/api/v1/chats/{chat_id}/messages", json={"body": body}, headers=headers
    )
    assert resp.status_code == 201, resp.text
    return dict(resp.json())


async def _notifications(client: httpx.AsyncClient, headers: dict[str, str]) -> dict[str, object]:
    resp = await client.get("/api/v1/notifications", headers=headers)
    assert resp.status_code == 200
    return dict(resp.json())


# -- tombstoned deletes ---------------------------------------------------------


async def test_tombstone_delete_with_reason(client: httpx.AsyncClient) -> None:
    owner = await make_user(client, "owner@campus.edu")
    member = await make_user(client, "member@campus.edu")
    chat = await _create_chat(client, owner)
    await client.post(f"/api/v1/chats/{chat['id']}/join", headers=member)
    message = await _post(client, chat["id"], member, "rude message")

    # Reason is mandatory: no body → 422.
    resp = await client.post(
        f"/api/v1/chats/{chat['id']}/messages/{message['id']}/delete", headers=owner
    )
    assert resp.status_code in (400, 422)
    # Too-short reason is rejected too.
    resp = await client.post(
        f"/api/v1/chats/{chat['id']}/messages/{message['id']}/delete",
        json={"reason": "no"},
        headers=owner,
    )
    assert resp.status_code in (400, 422)

    # Non-mods cannot delete even with a reason.
    resp = await client.post(
        f"/api/v1/chats/{chat['id']}/messages/{message['id']}/delete",
        json={"reason": "self delete"},
        headers=member,
    )
    assert resp.status_code == 403

    resp = await client.post(
        f"/api/v1/chats/{chat['id']}/messages/{message['id']}/delete",
        json={"reason": "harassment"},
        headers=owner,
    )
    assert resp.status_code == 204

    # The message stays in the feed as a tombstone: blank body, reason, deleter name.
    resp = await client.get(f"/api/v1/chats/{chat['id']}/messages", headers=member)
    items = resp.json()["items"]
    assert len(items) == 1
    tombstone = items[0]
    assert tombstone["id"] == message["id"]
    assert tombstone["body"] == ""
    assert tombstone["deleted_at"] is not None
    assert tombstone["deleted_reason"] == "harassment"
    assert tombstone["deleted_by_name"] == "owner"

    # AuditLog row with the reason.
    async with async_session_factory() as session:
        stmt = select(AuditLog).where(AuditLog.action == "chat_message.delete")
        logs = (await session.execute(stmt)).scalars().all()
    assert len(logs) == 1
    assert logs[0].metadata_["reason"] == "harassment"


# -- @mentions ------------------------------------------------------------------


async def test_mention_notification_replaces_generic(client: httpx.AsyncClient) -> None:
    owner = await make_user(client, "owner@campus.edu")
    ava = await make_user(client, "ava@campus.edu")  # display_name "ava"
    other = await make_user(client, "other@campus.edu")
    chat = await _create_chat(client, owner)
    for h in (ava, other):
        await client.post(f"/api/v1/chats/{chat['id']}/join", headers=h)

    message = await _post(client, chat["id"], owner, "@Ava hi there")

    # Ava gets ONLY a chat_mention (no generic chat_message for the same message).
    data = await _notifications(client, ava)
    assert data["unread_count"] == 1
    items = list(data["items"])  # type: ignore[arg-type]
    assert items[0]["type"] == "chat_mention"
    payload = items[0]["payload"]
    assert payload["chat_id"] == chat["id"]
    assert payload["message_id"] == message["id"]
    assert payload["sender_name"] == "owner"
    assert payload["chat_name"] == chat["name"]

    # Non-mentioned members still get the generic chat_message notification.
    data = await _notifications(client, other)
    items = list(data["items"])  # type: ignore[arg-type]
    assert [n["type"] for n in items] == ["chat_message"]

    # Mentions are never deduplicated: a second mention → a second notification.
    await _post(client, chat["id"], owner, "@ava again!")
    data = await _notifications(client, ava)
    items = list(data["items"])  # type: ignore[arg-type]
    assert [n["type"] for n in items] == ["chat_mention", "chat_mention"]
    assert data["unread_count"] == 2


# -- 60-minute dedup for chat_message --------------------------------------------


async def test_chat_message_notifications_dedup(client: httpx.AsyncClient) -> None:
    owner = await make_user(client, "owner@campus.edu")
    fan = await make_user(client, "fan@campus.edu")
    chat = await _create_chat(client, owner)
    await client.post(f"/api/v1/chats/{chat['id']}/join", headers=fan)

    for body in ("one", "two", "three"):
        last = await _post(client, chat["id"], owner, body)

    # ONE unread notification, count == 3, pointing at the latest message.
    data = await _notifications(client, fan)
    assert data["unread_count"] == 1
    items = list(data["items"])  # type: ignore[arg-type]
    assert len(items) == 1
    payload = items[0]["payload"]
    assert payload["count"] == 3
    assert payload["message_id"] == last["id"]
    assert payload["sender_name"] == "owner"
    assert payload["chat_name"] == chat["name"]

    # After marking read, the next message starts a NEW notification with count 1.
    assert (
        await client.post("/api/v1/notifications/read", json={}, headers=fan)
    ).status_code == 204
    await _post(client, chat["id"], owner, "four")
    data = await _notifications(client, fan)
    assert data["unread_count"] == 1
    items = list(data["items"])  # type: ignore[arg-type]
    unread = [n for n in items if n["read_at"] is None]
    assert len(unread) == 1
    assert unread[0]["payload"]["count"] == 1


# -- DM notifications -------------------------------------------------------------


async def test_dm_notifications_with_dedup(client: httpx.AsyncClient) -> None:
    alice = await make_user(client, "alice@campus.edu")
    bob = await make_user(client, "bob@campus.edu")
    bob_id = await _user_id(client, bob)
    alice_id = await _user_id(client, alice)

    resp = await client.post(
        "/api/v1/conversations",
        json={"recipient_id": bob_id, "context_type": "direct", "context_id": None},
        headers=alice,
    )
    assert resp.status_code == 201, resp.text
    conv_id = resp.json()["id"]

    resp = await client.post(
        f"/api/v1/conversations/{conv_id}/messages", json={"body": "hey!"}, headers=alice
    )
    assert resp.status_code == 201

    data = await _notifications(client, bob)
    assert data["unread_count"] == 1
    items = list(data["items"])  # type: ignore[arg-type]
    assert items[0]["type"] == "dm_message"
    payload = items[0]["payload"]
    assert payload["conversation_id"] == conv_id
    assert payload["sender_id"] == alice_id
    assert payload["sender_name"] == "alice"
    assert payload["count"] == 1

    # Second DM within the window folds into the same notification.
    await client.post(
        f"/api/v1/conversations/{conv_id}/messages", json={"body": "you there?"}, headers=alice
    )
    data = await _notifications(client, bob)
    assert data["unread_count"] == 1
    items = list(data["items"])  # type: ignore[arg-type]
    assert len(items) == 1
    assert items[0]["payload"]["count"] == 2

    # The sender gets nothing.
    assert (await _notifications(client, alice))["unread_count"] == 0


# -- promote ----------------------------------------------------------------------


async def test_promote_member(client: httpx.AsyncClient) -> None:
    owner = await make_user(client, "owner@campus.edu")
    member = await make_user(client, "member@campus.edu")
    third = await make_user(client, "third@campus.edu")
    chat = await _create_chat(client, owner)
    for h in (member, third):
        await client.post(f"/api/v1/chats/{chat['id']}/join", headers=h)
    member_id = await _user_id(client, member)
    third_id = await _user_id(client, third)

    # Non-owner (plain member) cannot promote.
    resp = await client.post(
        f"/api/v1/chats/{chat['id']}/members/{third_id}/promote", headers=member
    )
    assert resp.status_code == 403

    # Owner promotes member → mod.
    resp = await client.post(
        f"/api/v1/chats/{chat['id']}/members/{member_id}/promote", headers=owner
    )
    assert resp.status_code == 200, resp.text
    assert resp.json()["role"] == "mod"

    # A mod (not owner) still cannot promote.
    resp = await client.post(
        f"/api/v1/chats/{chat['id']}/members/{third_id}/promote", headers=member
    )
    assert resp.status_code == 403

    # Promoting an existing mod → 409.
    resp = await client.post(
        f"/api/v1/chats/{chat['id']}/members/{member_id}/promote", headers=owner
    )
    assert resp.status_code == 409
    assert resp.json()["error"]["code"] == "ALREADY_MOD"

    # Unknown member → 404.
    outsider = await make_user(client, "outsider@campus.edu")
    outsider_id = await _user_id(client, outsider)
    resp = await client.post(
        f"/api/v1/chats/{chat['id']}/members/{outsider_id}/promote", headers=owner
    )
    assert resp.status_code == 404

    # Audit trail written.
    async with async_session_factory() as session:
        actions = [a[0] for a in (await session.execute(select(AuditLog.action))).all()]
    assert "chat_member.promote" in actions
