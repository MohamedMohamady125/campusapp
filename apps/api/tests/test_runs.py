"""Food runs: lifecycle, orders, authz, expiry, run-context ratings."""

import uuid
from datetime import UTC, datetime, timedelta

import httpx
from sqlalchemy import select

from app.db.session import async_session_factory
from app.models import Conversation, ConversationParticipant, FoodSpot, Notification, Run
from app.models.enums import FoodSpotCategory
from app.workers.jobs import expire_runs_job
from tests.helpers import make_user


async def _make_spot(name: str = "Chick-fil-A") -> str:
    async with async_session_factory() as session:
        spot = FoodSpot(name=name, category=FoodSpotCategory.campus, description=None, active=True)
        session.add(spot)
        await session.commit()
        return str(spot.id)


def _payload(spot_id: str, **overrides: object) -> dict[str, object]:
    body: dict[str, object] = {
        "food_spot_id": spot_id,
        "leaving_at": (datetime.now(UTC) + timedelta(minutes=30)).isoformat(),
        "fee_cents": 0,
        "spots_max": 2,
        "prepay_required": False,
    }
    body.update(overrides)
    return body


def _order_body(order_text: str = "food", dropoff: str = "Chaparral Hall lobby") -> dict[str, str]:
    """A requester's order body — order text plus their own drop-off spot."""
    return {"order_text": order_text, "dropoff": dropoff}


async def _set_payment(client: httpx.AsyncClient, headers: dict[str, str]) -> None:
    resp = await client.patch(
        "/api/v1/users/me",
        json={"payment_methods": [{"type": "venmo", "handle": "@runner-gcu"}]},
        headers=headers,
    )
    assert resp.status_code == 200, resp.text


async def _create_run(
    client: httpx.AsyncClient, headers: dict[str, str], spot_id: str, **overrides: object
) -> dict:
    resp = await client.post("/api/v1/runs", json=_payload(spot_id, **overrides), headers=headers)
    assert resp.status_code == 201, resp.text
    return resp.json()


# -- creation -----------------------------------------------------------------


async def test_payment_methods_accept_rail_specific_handles(
    client: httpx.AsyncClient,
) -> None:
    # Regression: Cash App cashtags ($foo) and PayPal.me links must round-trip.
    # A too-strict handle validator once 500'd GET /users/me on saved data.
    runner = await make_user(client, "runner@campus.edu")
    methods = [
        {"type": "cashapp", "handle": "$ben1"},
        {"type": "paypal", "handle": "paypal.me/ben1"},
        {"type": "zelle", "handle": "ben1@campus.edu"},
    ]
    patch = await client.patch(
        "/api/v1/users/me", json={"payment_methods": methods}, headers=runner
    )
    assert patch.status_code == 200, patch.text

    me = await client.get("/api/v1/users/me", headers=runner)
    assert me.status_code == 200, me.text
    assert me.json()["payment_methods"] == methods


async def test_create_and_feed(client: httpx.AsyncClient) -> None:
    runner = await make_user(client, "runner@campus.edu")
    spot_id = await _make_spot()
    run = await _create_run(client, runner, spot_id)
    assert run["status"] == "open"
    assert run["accepted_count"] == 0

    feed = await client.get("/api/v1/runs", headers=runner)
    assert feed.status_code == 200
    assert [r["id"] for r in feed.json()["items"]] == [run["id"]]

    spots = await client.get("/api/v1/runs/spots", headers=runner)
    assert [s["id"] for s in spots.json()] == [spot_id]


async def test_create_validations(client: httpx.AsyncClient) -> None:
    runner = await make_user(client, "runner@campus.edu")
    spot_id = await _make_spot()

    resp = await client.post("/api/v1/runs", json=_payload(str(uuid.uuid4())), headers=runner)
    assert resp.json()["error"]["code"] == "FOOD_SPOT_NOT_FOUND"

    resp = await client.post(
        "/api/v1/runs",
        json=_payload(spot_id, leaving_at=(datetime.now(UTC) - timedelta(minutes=1)).isoformat()),
        headers=runner,
    )
    assert resp.json()["error"]["code"] == "LEAVING_AT_PAST"

    # Fee without a payment method is blocked; adding one unblocks it.
    resp = await client.post("/api/v1/runs", json=_payload(spot_id, fee_cents=200), headers=runner)
    assert resp.json()["error"]["code"] == "PAYMENT_METHOD_REQUIRED"
    await _set_payment(client, runner)
    run = await _create_run(client, runner, spot_id, fee_cents=200)
    assert run["fee_cents"] == 200


async def test_dining_dollars_flag_and_filter(client: httpx.AsyncClient) -> None:
    runner = await make_user(client, "runner@campus.edu")
    spot_id = await _make_spot()

    # Defaults to False and round-trips on the response.
    plain = await _create_run(client, runner, spot_id)
    assert plain["pays_with_dining_dollars"] is False
    dining = await _create_run(client, runner, spot_id, pays_with_dining_dollars=True)
    assert dining["pays_with_dining_dollars"] is True

    # Unfiltered feed shows both runs.
    feed = (await client.get("/api/v1/runs", headers=runner)).json()
    assert {r["id"] for r in feed["items"]} == {plain["id"], dining["id"]}

    # dining_dollars=true narrows to just the dining-dollar run (filtered in SQL).
    filtered = (
        await client.get("/api/v1/runs", params={"dining_dollars": "true"}, headers=runner)
    ).json()
    assert [r["id"] for r in filtered["items"]] == [dining["id"]]


# -- orders -------------------------------------------------------------------


async def test_order_request_accept_flow(client: httpx.AsyncClient) -> None:
    runner = await make_user(client, "runner@campus.edu")
    req = await make_user(client, "req@campus.edu")
    spot_id = await _make_spot()
    run = await _create_run(client, runner, spot_id)

    # Runner cannot join own run.
    resp = await client.post(
        f"/api/v1/runs/{run['id']}/orders", json=_order_body("x"), headers=runner
    )
    assert resp.json()["error"]["code"] == "SELF_ORDER"

    resp = await client.post(
        f"/api/v1/runs/{run['id']}/orders",
        json=_order_body("Spicy deluxe", dropoff="Willow Hall room 214"),
        headers=req,
    )
    assert resp.status_code == 201
    order = resp.json()["my_order"]
    assert order["status"] == "requested"
    # Each requester carries their own drop-off (their hall/dorm).
    assert order["dropoff"] == "Willow Hall room 214"

    # Duplicate blocked.
    resp = await client.post(
        f"/api/v1/runs/{run['id']}/orders", json=_order_body("again"), headers=req
    )
    assert resp.json()["error"]["code"] == "DUPLICATE_ORDER"

    # Only the runner may accept.
    resp = await client.post(f"/api/v1/runs/{run['id']}/orders/{order['id']}/accept", headers=req)
    assert resp.json()["error"]["code"] == "NOT_RUNNER"

    resp = await client.post(
        f"/api/v1/runs/{run['id']}/orders/{order['id']}/accept", headers=runner
    )
    assert resp.status_code == 200
    body = resp.json()
    assert body["accepted_count"] == 1
    assert body["orders"][0]["status"] == "accepted"
    assert body["conversation_id"] is not None

    # Group chat exists with both participants.
    async with async_session_factory() as session:
        convo = (await session.execute(select(Conversation))).scalars().one()
        assert str(convo.context_id) == run["id"]
        participants = (
            (await session.execute(select(ConversationParticipant.user_id))).scalars().all()
        )
        assert len(participants) == 2


async def test_run_full_and_decline_and_withdraw(client: httpx.AsyncClient) -> None:
    runner = await make_user(client, "runner@campus.edu")
    r1 = await make_user(client, "r1@campus.edu")
    r2 = await make_user(client, "r2@campus.edu")
    r3 = await make_user(client, "r3@campus.edu")
    spot_id = await _make_spot()
    run = await _create_run(client, runner, spot_id, spots_max=1)

    async def order(headers: dict[str, str]) -> dict:
        resp = await client.post(
            f"/api/v1/runs/{run['id']}/orders", json=_order_body("food"), headers=headers
        )
        return resp.json()

    o1 = (await order(r1))["my_order"]
    o2 = (await order(r2))["my_order"]

    accept = await client.post(f"/api/v1/runs/{run['id']}/orders/{o1['id']}/accept", headers=runner)
    assert accept.status_code == 200

    # Cap reached: further requests + accepts rejected.
    assert (await order(r3))["error"]["code"] == "RUN_FULL"
    resp = await client.post(f"/api/v1/runs/{run['id']}/orders/{o2['id']}/accept", headers=runner)
    assert resp.json()["error"]["code"] == "RUN_FULL"

    # Decline the leftover request.
    resp = await client.post(f"/api/v1/runs/{run['id']}/orders/{o2['id']}/decline", headers=runner)
    assert resp.status_code == 200

    # r1 cannot withdraw an accepted order; a declined one is not pending either.
    resp = await client.delete(f"/api/v1/runs/{run['id']}/orders/{o1['id']}", headers=r1)
    assert resp.json()["error"]["code"] == "ORDER_NOT_PENDING"
    # r1 cannot withdraw r2's order.
    resp = await client.delete(f"/api/v1/runs/{run['id']}/orders/{o2['id']}", headers=r1)
    assert resp.status_code == 403


async def test_visitor_sees_counts_only(client: httpx.AsyncClient) -> None:
    runner = await make_user(client, "runner@campus.edu")
    req = await make_user(client, "req@campus.edu")
    visitor = await make_user(client, "visitor@campus.edu")
    spot_id = await _make_spot()
    await _set_payment(client, runner)
    run = await _create_run(client, runner, spot_id, fee_cents=300)
    resp = await client.post(
        f"/api/v1/runs/{run['id']}/orders", json=_order_body("bowl"), headers=req
    )
    oid = resp.json()["my_order"]["id"]
    await client.post(f"/api/v1/runs/{run['id']}/orders/{oid}/accept", headers=runner)

    view = (await client.get(f"/api/v1/runs/{run['id']}", headers=visitor)).json()
    assert view["orders"] == []
    assert view["my_order"] is None
    assert view["conversation_id"] is None
    assert view["runner"]["payment_methods"] == []  # payment info hidden from passers-by
    assert view["accepted_count"] == 1

    # The accepted requester sees the methods (they're the payment instruction).
    view = (await client.get(f"/api/v1/runs/{run['id']}", headers=req)).json()
    assert view["runner"]["payment_methods"] == [{"type": "venmo", "handle": "@runner-gcu"}]


# -- state machine ------------------------------------------------------------


async def _accepted_run(
    client: httpx.AsyncClient, runner: dict[str, str], req: dict[str, str], spot_id: str
) -> tuple[dict, str]:
    run = await _create_run(client, runner, spot_id)
    resp = await client.post(
        f"/api/v1/runs/{run['id']}/orders", json=_order_body("food"), headers=req
    )
    oid = resp.json()["my_order"]["id"]
    await client.post(f"/api/v1/runs/{run['id']}/orders/{oid}/accept", headers=runner)
    return run, oid


async def test_full_happy_path_to_done(client: httpx.AsyncClient) -> None:
    runner = await make_user(client, "runner@campus.edu")
    req = await make_user(client, "req@campus.edu")
    spot_id = await _make_spot()
    run, oid = await _accepted_run(client, runner, req, spot_id)

    async def status(to: str) -> httpx.Response:
        return await client.post(
            f"/api/v1/runs/{run['id']}/status", json={"status": to}, headers=runner
        )

    assert (await status("at_store")).status_code == 200
    assert (await status("delivering")).status_code == 200

    # Cannot finish with an accepted order unresolved.
    resp = await status("done")
    assert resp.json()["error"]["code"] == "ORDERS_UNRESOLVED"

    resp = await client.post(f"/api/v1/runs/{run['id']}/orders/{oid}/delivered", headers=runner)
    assert resp.json()["orders"][0]["status"] == "delivered"

    # Delivered counts as resolved — a silent requester can't block the runner.
    resp = await status("done")
    assert resp.status_code == 200
    assert resp.json()["status"] == "done"

    # Requester can still confirm receipt after done.
    resp = await client.post(f"/api/v1/runs/{run['id']}/orders/{oid}/received", headers=req)
    assert resp.json()["my_order"]["status"] == "received"


async def test_illegal_transitions_and_at_store_declines(client: httpx.AsyncClient) -> None:
    runner = await make_user(client, "runner@campus.edu")
    req = await make_user(client, "req@campus.edu")
    late = await make_user(client, "late@campus.edu")
    spot_id = await _make_spot()
    run, _ = await _accepted_run(client, runner, req, spot_id)
    resp = await client.post(
        f"/api/v1/runs/{run['id']}/orders", json=_order_body("late"), headers=late
    )
    assert resp.status_code == 201

    for bad in ("delivering", "done", "open"):
        resp = await client.post(
            f"/api/v1/runs/{run['id']}/status", json={"status": bad}, headers=runner
        )
        assert resp.json()["error"]["code"] == "INVALID_TRANSITION", bad

    resp = await client.post(
        f"/api/v1/runs/{run['id']}/status", json={"status": "at_store"}, headers=runner
    )
    orders = {o["requester"]["display_name"]: o["status"] for o in resp.json()["orders"]}
    assert orders == {"req": "accepted", "late": "declined"}

    # New orders are closed once at the store.
    other = await make_user(client, "other@campus.edu")
    resp = await client.post(
        f"/api/v1/runs/{run['id']}/orders", json=_order_body("x"), headers=other
    )
    assert resp.json()["error"]["code"] == "RUN_NOT_OPEN"


async def test_cancel_and_no_show(client: httpx.AsyncClient) -> None:
    runner = await make_user(client, "runner@campus.edu")
    req = await make_user(client, "req@campus.edu")
    spot_id = await _make_spot()

    run, _oid = await _accepted_run(client, runner, req, spot_id)
    resp = await client.post(f"/api/v1/runs/{run['id']}/cancel", headers=runner)
    assert resp.json()["status"] == "cancelled"
    view = (await client.get(f"/api/v1/runs/{run['id']}", headers=req)).json()
    assert view["my_order"]["status"] == "cancelled"

    run2, oid2 = await _accepted_run(client, runner, req, spot_id)
    await client.post(
        f"/api/v1/runs/{run2['id']}/status", json={"status": "at_store"}, headers=runner
    )
    resp = await client.post(f"/api/v1/runs/{run2['id']}/orders/{oid2}/no-show", headers=runner)
    assert resp.json()["orders"][0]["status"] == "no_show"
    # Cancelled past at_store is illegal.
    resp = await client.post(f"/api/v1/runs/{run2['id']}/cancel", headers=runner)
    assert resp.json()["error"]["code"] == "INVALID_TRANSITION"


# -- live location ------------------------------------------------------------


async def test_live_location_sharing(client: httpx.AsyncClient) -> None:
    runner = await make_user(client, "runner@campus.edu")
    req = await make_user(client, "req@campus.edu")
    visitor = await make_user(client, "visitor@campus.edu")
    spot_id = await _make_spot()
    run, _oid = await _accepted_run(client, runner, req, spot_id)

    loc = {"lat": 33.5095, "lng": -112.122}

    # Not en route yet (still open): sharing is rejected.
    resp = await client.post(f"/api/v1/runs/{run['id']}/location", json=loc, headers=runner)
    assert resp.json()["error"]["code"] == "RUN_NOT_EN_ROUTE"

    # Runner heads to the store — now en route.
    await client.post(
        f"/api/v1/runs/{run['id']}/status", json={"status": "at_store"}, headers=runner
    )

    # Before any ping, the accepted requester sees no location.
    view = (await client.get(f"/api/v1/runs/{run['id']}", headers=req)).json()
    assert view["runner_location"] is None

    # Only the runner may report position.
    resp = await client.post(f"/api/v1/runs/{run['id']}/location", json=loc, headers=req)
    assert resp.status_code == 403

    # Out-of-range coordinates are rejected by validation.
    resp = await client.post(
        f"/api/v1/runs/{run['id']}/location", json={"lat": 200, "lng": 0}, headers=runner
    )
    assert resp.status_code == 400

    # Runner pings their live position.
    resp = await client.post(f"/api/v1/runs/{run['id']}/location", json=loc, headers=runner)
    assert resp.status_code == 200

    # Accepted requester sees the live point...
    view = (await client.get(f"/api/v1/runs/{run['id']}", headers=req)).json()
    assert view["runner_location"]["lat"] == loc["lat"]
    assert view["runner_location"]["lng"] == loc["lng"]
    assert view["runner_location"]["updated_at"] is not None

    # ...but a passer-by never does (privacy gate).
    view = (await client.get(f"/api/v1/runs/{run['id']}", headers=visitor)).json()
    assert view["runner_location"] is None


# -- expiry job ---------------------------------------------------------------


async def _shift_leaving_at(run_id: str, *, minutes_ago: int) -> None:
    async with async_session_factory() as session:
        run = await session.get(Run, uuid.UUID(run_id))
        assert run is not None
        run.leaving_at = datetime.now(UTC) - timedelta(minutes=minutes_ago)
        await session.commit()


async def test_expire_runs_job_branches(client: httpx.AsyncClient) -> None:
    runner = await make_user(client, "runner@campus.edu")
    req = await make_user(client, "req@campus.edu")
    spot_id = await _make_spot()

    # a) open, no accepted → expired quietly (pending request declined).
    lonely = await _create_run(client, runner, spot_id)
    resp = await client.post(
        f"/api/v1/runs/{lonely['id']}/orders", json=_order_body("x"), headers=req
    )
    assert resp.status_code == 201
    # b) open with an accepted order → auto-locked.
    busy, _ = await _accepted_run(client, runner, req, spot_id)
    # c) active but 90+ min overdue → hard-expired.
    ghost, _ = await _accepted_run(client, runner, req, spot_id)
    await client.post(
        f"/api/v1/runs/{ghost['id']}/status", json={"status": "at_store"}, headers=runner
    )

    await _shift_leaving_at(lonely["id"], minutes_ago=5)
    await _shift_leaving_at(busy["id"], minutes_ago=5)
    await _shift_leaving_at(ghost["id"], minutes_ago=120)

    async with async_session_factory() as session:
        counts = await expire_runs_job(session)
    assert counts == {"expired": 2, "locked": 1}

    async def status_of(run: dict) -> str:
        return (await client.get(f"/api/v1/runs/{run['id']}", headers=runner)).json()["status"]

    assert await status_of(lonely) == "expired"
    assert await status_of(busy) == "locked"
    assert await status_of(ghost) == "expired"

    # Idempotent: second sweep is a no-op (locked run stays until hard expiry).
    async with async_session_factory() as session:
        assert await expire_runs_job(session) == {"expired": 0, "locked": 0}


# -- ratings ------------------------------------------------------------------


async def test_run_ratings_two_way(client: httpx.AsyncClient) -> None:
    runner = await make_user(client, "runner@campus.edu")
    req = await make_user(client, "req@campus.edu")
    stranger = await make_user(client, "stranger@campus.edu")
    spot_id = await _make_spot()
    run, oid = await _accepted_run(client, runner, req, spot_id)

    runner_id = run["runner"]["id"]
    req_id = (await client.get("/api/v1/users/me", headers=req)).json()["id"]

    def rating(rated: str) -> dict[str, object]:
        return {"rated_user_id": rated, "context_type": "run", "context_id": oid, "stars": 5}

    # Not done yet.
    resp = await client.post("/api/v1/ratings", json=rating(runner_id), headers=req)
    assert resp.json()["error"]["code"] == "RUN_NOT_COMPLETED"

    for s in ("at_store", "delivering"):
        await client.post(f"/api/v1/runs/{run['id']}/status", json={"status": s}, headers=runner)
    await client.post(f"/api/v1/runs/{run['id']}/orders/{oid}/delivered", headers=runner)
    await client.post(f"/api/v1/runs/{run['id']}/orders/{oid}/received", headers=req)
    await client.post(f"/api/v1/runs/{run['id']}/status", json={"status": "done"}, headers=runner)

    # Stranger cannot rate either party on this order.
    resp = await client.post("/api/v1/ratings", json=rating(runner_id), headers=stranger)
    assert resp.json()["error"]["code"] == "INVALID_RATING_PARTY"

    # Two-way ratings on the same order both succeed; duplicates blocked.
    assert (
        await client.post("/api/v1/ratings", json=rating(runner_id), headers=req)
    ).status_code == 201
    assert (
        await client.post("/api/v1/ratings", json=rating(req_id), headers=runner)
    ).status_code == 201
    resp = await client.post("/api/v1/ratings", json=rating(runner_id), headers=req)
    assert resp.json()["error"]["code"] == "ALREADY_RATED"

    # Reputation cache updated.
    profile = (await client.get(f"/api/v1/users/{runner_id}", headers=req)).json()
    assert profile["rating_count"] == 1
    assert profile["reputation_score"] > 4.0


# -- notifications ------------------------------------------------------------


async def test_run_notifications(client: httpx.AsyncClient) -> None:
    runner = await make_user(client, "runner@campus.edu")
    req = await make_user(client, "req@campus.edu")
    spot_id = await _make_spot()
    run, _oid = await _accepted_run(client, runner, req, spot_id)
    await client.post(
        f"/api/v1/runs/{run['id']}/status", json={"status": "at_store"}, headers=runner
    )

    async with async_session_factory() as session:
        types = (await session.execute(select(Notification.type))).scalars().all()
    assert set(types) == {"run_request", "run_request_accepted", "run_status"}


async def test_expired_runs_leave_the_feed(client: httpx.AsyncClient) -> None:
    runner = await make_user(client, "runner@campus.edu")
    spot_id = await _make_spot()
    run = await _create_run(client, runner, spot_id)
    await _shift_leaving_at(run["id"], minutes_ago=1)
    feed = (await client.get("/api/v1/runs", headers=runner)).json()
    assert feed["items"] == []  # past leaving_at → hidden even before the sweep

    mine = (await client.get("/api/v1/runs/mine", headers=runner)).json()
    assert [r["id"] for r in mine["items"]] == [run["id"]]
