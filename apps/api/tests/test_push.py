"""Push notifications: device registration, fan-out policy, anti-spam fold."""

import httpx

from app.integrations.push.base import PushMessage
from app.integrations.push.provider import get_push_provider
from app.integrations.push.stub import StubPushProvider
from app.services.push_copy import render_push
from tests.helpers import make_user
from tests.test_runs import _create_run, _make_dropoff, _make_spot, _order_body


def _stub() -> StubPushProvider:
    provider = get_push_provider()
    assert isinstance(provider, StubPushProvider)
    provider.sent.clear()
    return provider


async def _register(
    client: httpx.AsyncClient, headers: dict[str, str], token: str, platform: str = "ios"
) -> None:
    resp = await client.post(
        "/api/v1/notifications/devices",
        json={"platform": platform, "token": token},
        headers=headers,
    )
    assert resp.status_code == 204, resp.text


async def test_push_full_run_flow(client: httpx.AsyncClient) -> None:
    """Order request pushes the runner; accept pushes the requester; a second
    requester folding into the runner's unread run_request does NOT re-push."""
    stub = _stub()
    spot_id = await _make_spot()
    dropoff_id = await _make_dropoff()
    runner = await make_user(client, "runner@campus.edu")
    rachel = await make_user(client, "rachel@campus.edu")
    nolan = await make_user(client, "nolan@campus.edu")
    await _register(client, runner, "tok-runner")
    await _register(client, rachel, "tok-rachel")

    run = await _create_run(client, runner, spot_id, spots_max=3)
    assert stub.sent == []  # creating a run interrupts nobody

    order = await client.post(
        f"/api/v1/runs/{run['id']}/orders",
        json=_order_body(dropoff_id=dropoff_id),
        headers=rachel,
    )
    assert order.status_code == 201, order.text
    assert len(stub.sent) == 1
    first = stub.sent[0]
    assert first["tokens"] == ["tok-runner"]
    assert "wants in on your Chick-fil-A run" in str(first["title"])
    assert first["collapse_key"] == f"run:{run['id']}"

    # Second requester within the dedup window folds — no second interruption.
    order2 = await client.post(
        f"/api/v1/runs/{run['id']}/orders",
        json=_order_body(dropoff_id=dropoff_id),
        headers=nolan,
    )
    assert order2.status_code == 201, order2.text
    assert len(stub.sent) == 1

    # Accept pushes the requester (fresh context: order_id dedup key).
    accept = await client.post(
        f"/api/v1/runs/{run['id']}/orders/{order.json()['my_order']['id']}/accept",
        headers=runner,
    )
    assert accept.status_code == 200, accept.text
    accepted = [p for p in stub.sent if p["tokens"] == ["tok-rachel"]]
    assert len(accepted) == 1
    assert "order was accepted" in str(accepted[0]["title"])
    # Nolan has no device registered — no push targeted him.
    assert all(p["tokens"] in (["tok-runner"], ["tok-rachel"]) for p in stub.sent)


async def test_device_unregister_and_token_reassignment(client: httpx.AsyncClient) -> None:
    stub = _stub()
    spot_id = await _make_spot()
    dropoff_id = await _make_dropoff()
    runner = await make_user(client, "runner@campus.edu")
    rachel = await make_user(client, "rachel@campus.edu")

    # Same physical device: registered to runner, then re-registered to rachel.
    await _register(client, runner, "tok-shared")
    await _register(client, rachel, "tok-shared")

    run = await _create_run(client, runner, spot_id)
    resp = await client.post(
        f"/api/v1/runs/{run['id']}/orders",
        json=_order_body(dropoff_id=dropoff_id),
        headers=rachel,
    )
    assert resp.status_code == 201, resp.text
    # Token moved to rachel — the runner's order-request push has no target.
    assert stub.sent == []

    # Logout flow: remove the token; accept should then push nothing either.
    removed = await client.post(
        "/api/v1/notifications/devices/remove", json={"token": "tok-shared"}, headers=rachel
    )
    assert removed.status_code == 204
    accept = await client.post(
        f"/api/v1/runs/{run['id']}/orders/{resp.json()['my_order']['id']}/accept",
        headers=runner,
    )
    assert accept.status_code == 200, accept.text
    assert stub.sent == []


def test_push_copy_policy() -> None:
    """chat_message chatter is feed-only; arrived is time-sensitive."""
    assert render_push("chat_message", {"chat_id": "x", "sender_name": "A"}) is None
    arrived = render_push("run_runner_arrived", {"run_id": "r1", "dropoff": "Juniper Hall"})
    assert isinstance(arrived, PushMessage)
    assert arrived.critical is True
    assert "5 minutes" in arrived.title
    cancelled = render_push(
        "run_status", {"run_id": "r1", "run_status": "cancelled", "spot_name": "Panda"}
    )
    assert isinstance(cancelled, PushMessage)
    assert "cancelled" in cancelled.title
    # Money copy stays loud: prepaid users are told how to settle up.
    assert "paid" in cancelled.body
