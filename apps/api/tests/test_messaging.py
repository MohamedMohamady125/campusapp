"""Messaging tests (spec §14 M5): exchange, read state, cross-user 403."""

import uuid

import httpx

from tests.helpers import make_user


async def _listing_id(client: httpx.AsyncClient, headers: dict[str, str]) -> str:
    resp = await client.post(
        "/api/v1/listings",
        json={
            "title": "Calc textbook",
            "description": "Barely used",
            "price_cents": 2500,
            "category": "textbooks",
            "condition": "good",
        },
        headers=headers,
    )
    assert resp.status_code == 201
    return str(resp.json()["id"])


async def _user_id(client: httpx.AsyncClient, headers: dict[str, str]) -> str:
    resp = await client.get("/api/v1/users/me", headers=headers)
    return str(resp.json()["id"])


async def test_two_users_exchange_messages(client: httpx.AsyncClient) -> None:
    seller = await make_user(client, "seller@campus.edu")
    buyer = await make_user(client, "buyer@campus.edu")
    listing_id = await _listing_id(client, seller)
    seller_id = await _user_id(client, seller)

    # Buyer opens a conversation from the listing CTA.
    resp = await client.post(
        "/api/v1/conversations",
        json={"recipient_id": seller_id, "context_type": "listing", "context_id": listing_id},
        headers=buyer,
    )
    assert resp.status_code == 201, resp.text
    conv_id = resp.json()["id"]
    assert len(resp.json()["participants"]) == 2

    # Re-creating the same thread reuses it — no duplicates.
    resp2 = await client.post(
        "/api/v1/conversations",
        json={"recipient_id": seller_id, "context_type": "listing", "context_id": listing_id},
        headers=buyer,
    )
    assert resp2.json()["id"] == conv_id

    # Exchange in both directions.
    for headers, body in ((buyer, "Is this available?"), (seller, "Yes it is!")):
        resp = await client.post(
            f"/api/v1/conversations/{conv_id}/messages", json={"body": body}, headers=headers
        )
        assert resp.status_code == 201, resp.text

    resp = await client.get(f"/api/v1/conversations/{conv_id}/messages", headers=seller)
    bodies = [m["body"] for m in resp.json()["items"]]
    assert bodies == ["Yes it is!", "Is this available?"]  # newest first

    # Both see the conversation in their list.
    for headers in (buyer, seller):
        resp = await client.get("/api/v1/conversations", headers=headers)
        assert conv_id in [c["id"] for c in resp.json()["items"]]


async def test_read_state(client: httpx.AsyncClient) -> None:
    alice = await make_user(client, "alice@campus.edu")
    bob = await make_user(client, "bob@campus.edu")
    bob_id = await _user_id(client, bob)

    resp = await client.post("/api/v1/conversations", json={"recipient_id": bob_id}, headers=alice)
    conv_id = resp.json()["id"]
    await client.post(
        f"/api/v1/conversations/{conv_id}/messages", json={"body": "hi"}, headers=alice
    )

    resp = await client.get(f"/api/v1/conversations/{conv_id}/messages", headers=bob)
    assert resp.json()["items"][0]["read_at"] is None

    assert (
        await client.post(f"/api/v1/conversations/{conv_id}/read", headers=bob)
    ).status_code == 204
    resp = await client.get(f"/api/v1/conversations/{conv_id}/messages", headers=bob)
    assert resp.json()["items"][0]["read_at"] is not None


async def test_cross_user_conversation_access_403(client: httpx.AsyncClient) -> None:
    alice = await make_user(client, "alice@campus.edu")
    bob = await make_user(client, "bob@campus.edu")
    eve = await make_user(client, "eve@campus.edu")
    bob_id = await _user_id(client, bob)

    resp = await client.post("/api/v1/conversations", json={"recipient_id": bob_id}, headers=alice)
    conv_id = resp.json()["id"]

    resp = await client.get(f"/api/v1/conversations/{conv_id}/messages", headers=eve)
    assert resp.status_code == 403
    assert resp.json()["error"]["code"] == "NOT_PARTICIPANT"
    resp = await client.post(
        f"/api/v1/conversations/{conv_id}/messages", json={"body": "intruder"}, headers=eve
    )
    assert resp.status_code == 403


async def test_conversation_guards(client: httpx.AsyncClient) -> None:
    alice = await make_user(client, "alice@campus.edu")
    alice_id = await _user_id(client, alice)

    # Cannot message yourself.
    resp = await client.post(
        "/api/v1/conversations", json={"recipient_id": alice_id}, headers=alice
    )
    assert resp.status_code == 422
    assert resp.json()["error"]["code"] == "SELF_CONVERSATION"

    # Unknown recipient → 404.
    resp = await client.post(
        "/api/v1/conversations", json={"recipient_id": str(uuid.uuid4())}, headers=alice
    )
    assert resp.status_code == 404

    # listing context requires context_id.
    bob = await make_user(client, "bob@campus.edu")
    bob_id = await _user_id(client, bob)
    resp = await client.post(
        "/api/v1/conversations",
        json={"recipient_id": bob_id, "context_type": "listing"},
        headers=alice,
    )
    assert resp.status_code == 422
    assert resp.json()["error"]["code"] == "CONTEXT_ID_REQUIRED"
