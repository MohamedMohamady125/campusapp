"""Food runs: lifecycle, orders, authz, expiry, run-context ratings."""

import uuid
from datetime import UTC, datetime, timedelta

import httpx
from sqlalchemy import select, update

from app.db.session import async_session_factory
from app.models import (
    DropoffLocation,
    FoodSpot,
    Notification,
    Run,
    User,
)
from app.models.enums import FoodSpotCategory, UserRole
from app.workers.jobs import expire_runs_job
from tests.helpers import make_user


async def _make_spot(name: str = "Chick-fil-A") -> str:
    async with async_session_factory() as session:
        spot = FoodSpot(name=name, category=FoodSpotCategory.campus, description=None, active=True)
        session.add(spot)
        await session.commit()
        return str(spot.id)


async def _make_dropoff(name: str | None = None) -> str:
    # Unique default name so a test can create several catalog entries without
    # tripping the name uniqueness constraint.
    async with async_session_factory() as session:
        loc = DropoffLocation(
            name=name or f"Hall {uuid.uuid4().hex[:8]}", description=None, active=True
        )
        session.add(loc)
        await session.commit()
        return str(loc.id)


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


def _order_body(order_text: str = "food", *, dropoff_id: str) -> dict[str, str]:
    """A requester's order body — order text plus a picked drop-off location id."""
    return {"order_text": order_text, "dropoff_location_id": dropoff_id}


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
    saved = [{"type": m["type"], "handle": m["handle"]} for m in me.json()["payment_methods"]]
    assert saved == methods


async def test_payment_method_qr_code(client: httpx.AsyncClient) -> None:
    """A runner can attach a payment-app QR code image to a method."""
    runner = await make_user(client, "runner@campus.edu")

    signed = await client.post(
        "/api/v1/users/me/payment-qr-upload-url",
        json={"content_type": "image/png"},
        headers=runner,
    )
    assert signed.status_code == 200, signed.text
    key = signed.json()["key"]
    assert key.startswith("payment-qr/")

    patch = await client.patch(
        "/api/v1/users/me",
        json={"payment_methods": [{"type": "venmo", "handle": "@ben", "qr_key": key}]},
        headers=runner,
    )
    assert patch.status_code == 200, patch.text
    method = patch.json()["payment_methods"][0]
    assert method["qr_key"] == key
    assert method["qr_url"]  # derived, non-empty

    # Keys outside the payment-qr namespace are rejected (can't point a
    # handle at someone else's private object).
    bad = await client.patch(
        "/api/v1/users/me",
        json={"payment_methods": [{"type": "venmo", "handle": "@ben", "qr_key": "avatars/x.png"}]},
        headers=runner,
    )
    assert bad.status_code == 400, bad.text

    # Unsupported content type is refused.
    bad_type = await client.post(
        "/api/v1/users/me/payment-qr-upload-url",
        json={"content_type": "application/pdf"},
        headers=runner,
    )
    assert bad_type.status_code == 400, bad_type.text


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
        json=_payload(spot_id, leaving_at=(datetime.now(UTC) - timedelta(minutes=5)).isoformat()),
        headers=runner,
    )
    assert resp.json()["error"]["code"] == "LEAVING_AT_PAST"

    # Fee without a payment method is blocked; adding one unblocks it.
    resp = await client.post("/api/v1/runs", json=_payload(spot_id, fee_cents=200), headers=runner)
    assert resp.json()["error"]["code"] == "PAYMENT_METHOD_REQUIRED"
    await _set_payment(client, runner)
    run = await _create_run(client, runner, spot_id, fee_cents=200)
    assert run["fee_cents"] == 200


async def test_create_spot_is_admin_only(client: httpx.AsyncClient) -> None:
    student = await make_user(client, "student@campus.edu")
    admin = await make_user(client, "admin@campus.edu")
    async with async_session_factory() as session:
        await session.execute(
            update(User).where(User.email == "admin@campus.edu").values(role=UserRole.admin)
        )
        await session.commit()

    body = {"name": "The Grid Café", "category": "campus", "description": "Union coffee bar"}

    # Students are locked out of creating spots.
    forbidden = await client.post("/api/v1/runs/spots", json=body, headers=student)
    assert forbidden.status_code == 403
    assert forbidden.json()["error"]["code"] == "INSUFFICIENT_ROLE"

    # Admin creates it, and it shows up in the catalog.
    created = await client.post("/api/v1/runs/spots", json=body, headers=admin)
    assert created.status_code == 201, created.text
    assert created.json()["name"] == "The Grid Café"

    # Duplicate names are rejected.
    dupe = await client.post("/api/v1/runs/spots", json=body, headers=admin)
    assert dupe.status_code == 409
    assert dupe.json()["error"]["code"] == "FOOD_SPOT_EXISTS"

    spots = (await client.get("/api/v1/runs/spots", headers=student)).json()
    assert "The Grid Café" in {s["name"] for s in spots}


async def test_create_dropoff_is_admin_only(client: httpx.AsyncClient) -> None:
    student = await make_user(client, "student@campus.edu")
    admin = await make_user(client, "admin@campus.edu")
    async with async_session_factory() as session:
        await session.execute(
            update(User).where(User.email == "admin@campus.edu").values(role=UserRole.admin)
        )
        await session.commit()

    body = {"name": "Juniper Hall lobby", "description": "Main lobby"}

    # Students cannot add drop-off locations.
    forbidden = await client.post("/api/v1/runs/dropoffs", json=body, headers=student)
    assert forbidden.status_code == 403
    assert forbidden.json()["error"]["code"] == "INSUFFICIENT_ROLE"

    # Admin creates one, and it appears in the dropdown catalog.
    created = await client.post("/api/v1/runs/dropoffs", json=body, headers=admin)
    assert created.status_code == 201, created.text
    assert created.json()["name"] == "Juniper Hall lobby"

    # Duplicate names are rejected.
    dupe = await client.post("/api/v1/runs/dropoffs", json=body, headers=admin)
    assert dupe.status_code == 409
    assert dupe.json()["error"]["code"] == "DROPOFF_EXISTS"

    locations = (await client.get("/api/v1/runs/dropoffs", headers=student)).json()
    assert "Juniper Hall lobby" in {loc["name"] for loc in locations}


# -- orders -------------------------------------------------------------------


async def test_order_request_accept_flow(client: httpx.AsyncClient) -> None:
    runner = await make_user(client, "runner@campus.edu")
    req = await make_user(client, "req@campus.edu")
    spot_id = await _make_spot()
    dropoff_id = await _make_dropoff("Willow Hall room 214")
    run = await _create_run(client, runner, spot_id)

    # A random drop-off id (not in the catalog) is rejected.
    resp = await client.post(
        f"/api/v1/runs/{run['id']}/orders",
        json=_order_body("x", dropoff_id=str(uuid.uuid4())),
        headers=req,
    )
    assert resp.json()["error"]["code"] == "DROPOFF_NOT_FOUND"

    # Runner CAN attach their own order: auto-accepted, no spot consumed.
    resp = await client.post(
        f"/api/v1/runs/{run['id']}/orders",
        json=_order_body("runner's own burrito", dropoff_id=dropoff_id),
        headers=runner,
    )
    assert resp.status_code == 201
    self_body = resp.json()
    assert self_body["my_order"]["status"] == "accepted"
    assert self_body["accepted_count"] == 0  # self-order never takes a spot

    resp = await client.post(
        f"/api/v1/runs/{run['id']}/orders",
        json=_order_body("Spicy deluxe", dropoff_id=dropoff_id),
        headers=req,
    )
    assert resp.status_code == 201
    order = resp.json()["my_order"]
    assert order["status"] == "requested"
    # The order's drop-off is the picked catalog location's name.
    assert order["dropoff"] == "Willow Hall room 214"

    # Duplicate blocked.
    resp = await client.post(
        f"/api/v1/runs/{run['id']}/orders",
        json=_order_body("again", dropoff_id=dropoff_id),
        headers=req,
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
    by_id = {o["id"]: o["status"] for o in body["orders"]}
    assert by_id[order["id"]] == "accepted"


async def test_run_full_and_decline_and_withdraw(client: httpx.AsyncClient) -> None:
    runner = await make_user(client, "runner@campus.edu")
    r1 = await make_user(client, "r1@campus.edu")
    r2 = await make_user(client, "r2@campus.edu")
    r3 = await make_user(client, "r3@campus.edu")
    spot_id = await _make_spot()
    run = await _create_run(client, runner, spot_id, spots_max=1)

    async def order(headers: dict[str, str]) -> dict:
        dropoff_id = await _make_dropoff()
        resp = await client.post(
            f"/api/v1/runs/{run['id']}/orders",
            json=_order_body("food", dropoff_id=dropoff_id),
            headers=headers,
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
    dropoff_id = await _make_dropoff()
    resp = await client.post(
        f"/api/v1/runs/{run['id']}/orders",
        json=_order_body("bowl", dropoff_id=dropoff_id),
        headers=req,
    )
    oid = resp.json()["my_order"]["id"]
    await client.post(f"/api/v1/runs/{run['id']}/orders/{oid}/accept", headers=runner)

    view = (await client.get(f"/api/v1/runs/{run['id']}", headers=visitor)).json()
    assert view["orders"] == []
    assert view["my_order"] is None
    assert view["runner"]["payment_methods"] == []  # payment info hidden from passers-by
    assert view["accepted_count"] == 1

    # The accepted requester sees the methods (they're the payment instruction).
    view = (await client.get(f"/api/v1/runs/{run['id']}", headers=req)).json()
    revealed = [
        {"type": m["type"], "handle": m["handle"]} for m in view["runner"]["payment_methods"]
    ]
    assert revealed == [{"type": "venmo", "handle": "@runner-gcu"}]


# -- state machine ------------------------------------------------------------


async def test_payment_proof_flow(client: httpx.AsyncClient) -> None:
    runner = await make_user(client, "runner@campus.edu")
    req = await make_user(client, "req@campus.edu")
    other = await make_user(client, "other@campus.edu")
    spot_id = await _make_spot()
    dropoff_id = await _make_dropoff()
    await _set_payment(client, runner)
    run = await _create_run(client, runner, spot_id, fee_cents=300)
    resp = await client.post(
        f"/api/v1/runs/{run['id']}/orders",
        json=_order_body("bowl", dropoff_id=dropoff_id),
        headers=req,
    )
    oid = resp.json()["my_order"]["id"]
    base = f"/api/v1/runs/{run['id']}/orders/{oid}"

    # Cannot submit payment before the runner accepts.
    early = await client.post(
        f"{base}/payment-proof-upload-url", json={"content_type": "image/png"}, headers=req
    )
    assert early.json()["error"]["code"] == "ORDER_NOT_ACCEPTED"

    await client.post(f"{base}/accept", headers=runner)

    # Only the requester (not a bystander) may request an upload URL.
    forbidden = await client.post(
        f"{base}/payment-proof-upload-url", json={"content_type": "image/png"}, headers=other
    )
    assert forbidden.status_code == 403
    assert forbidden.json()["error"]["code"] == "NOT_REQUESTER"

    # Unsupported content types are rejected.
    bad = await client.post(
        f"{base}/payment-proof-upload-url", json={"content_type": "application/pdf"}, headers=req
    )
    assert bad.json()["error"]["code"] == "UNSUPPORTED_CONTENT_TYPE"

    signed = await client.post(
        f"{base}/payment-proof-upload-url", json={"content_type": "image/png"}, headers=req
    )
    assert signed.status_code == 200, signed.text
    key = signed.json()["key"]
    assert key.startswith("run-payments/")

    # Requester submits the proof; it surfaces on the runner's order card.
    submit = await client.post(
        f"{base}/payment-proof", json={"proof_key": key, "note": "sent via Venmo"}, headers=req
    )
    assert submit.status_code == 200, submit.text
    my_order = submit.json()["my_order"]
    assert my_order["payment_note"] == "sent via Venmo"
    assert my_order["payment_proof_url"] is not None
    assert my_order["payment_submitted_at"] is not None

    # Runner sees the proof on the order in their view.
    runner_view = (await client.get(f"/api/v1/runs/{run['id']}", headers=runner)).json()
    assert runner_view["orders"][0]["payment_proof_url"] is not None
    assert runner_view["orders"][0]["payment_note"] == "sent via Venmo"

    # The runner was notified.
    async with async_session_factory() as session:
        types = (await session.execute(select(Notification.type))).scalars().all()
    assert "run_payment_submitted" in types


async def test_prepay_run_accept_before_payment_proof(client: httpx.AsyncClient) -> None:
    """Prepay flow is accept-first: the runner accepts, THEN the requester pays.

    Regression: gating accept on payment proof deadlocked prepay runs — proof
    upload requires an accepted order, so neither side could ever move.
    """
    runner = await make_user(client, "runner@campus.edu")
    req = await make_user(client, "req@campus.edu")
    spot_id = await _make_spot()
    dropoff_id = await _make_dropoff()
    await _set_payment(client, runner)
    run = await _create_run(client, runner, spot_id, fee_cents=200, prepay_required=True)
    resp = await client.post(
        f"/api/v1/runs/{run['id']}/orders",
        json=_order_body("wrap", dropoff_id=dropoff_id),
        headers=req,
    )
    oid = resp.json()["my_order"]["id"]
    base = f"/api/v1/runs/{run['id']}/orders/{oid}"

    # Accept succeeds with no proof submitted.
    accept = await client.post(f"{base}/accept", headers=runner)
    assert accept.status_code == 200, accept.text

    # Only now does the accepted requester see the runner's payment methods,
    # and the proof upload path is open.
    view = (await client.get(f"/api/v1/runs/{run['id']}", headers=req)).json()
    assert view["runner"]["payment_methods"], "accepted requester must see payment rails"
    signed = await client.post(
        f"{base}/payment-proof-upload-url", json={"content_type": "image/png"}, headers=req
    )
    assert signed.status_code == 200, signed.text


async def _accepted_run(
    client: httpx.AsyncClient, runner: dict[str, str], req: dict[str, str], spot_id: str
) -> tuple[dict, str]:
    dropoff_id = await _make_dropoff()
    run = await _create_run(client, runner, spot_id)
    resp = await client.post(
        f"/api/v1/runs/{run['id']}/orders",
        json=_order_body("food", dropoff_id=dropoff_id),
        headers=req,
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
    late_dropoff = await _make_dropoff()
    resp = await client.post(
        f"/api/v1/runs/{run['id']}/orders",
        json=_order_body("late", dropoff_id=late_dropoff),
        headers=late,
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
    other_dropoff = await _make_dropoff()
    resp = await client.post(
        f"/api/v1/runs/{run['id']}/orders",
        json=_order_body("x", dropoff_id=other_dropoff),
        headers=other,
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
    lonely_dropoff = await _make_dropoff()
    resp = await client.post(
        f"/api/v1/runs/{lonely['id']}/orders",
        json=_order_body("x", dropoff_id=lonely_dropoff),
        headers=req,
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


# -- demo keep-alive ----------------------------------------------------------


async def test_demo_keepalive_tick_tops_up_and_is_idempotent(
    client: httpx.AsyncClient,
) -> None:
    from app.workers.demo_keepalive import TARGET_OPEN_RUNS, demo_keepalive_tick

    # The keep-alive posts as the seeded demo users against real spots.
    for email in ("ben1@campus.edu", "chloe2@campus.edu", "dan3@campus.edu"):
        await make_user(client, email)
    await _make_spot()

    async with async_session_factory() as session:
        created = await demo_keepalive_tick(session)
    assert created == TARGET_OPEN_RUNS

    viewer = await make_user(client, "viewer@campus.edu")
    feed = (await client.get("/api/v1/runs", headers=viewer)).json()
    assert len(feed["items"]) == TARGET_OPEN_RUNS
    assert all(r["status"] == "open" for r in feed["items"])

    # Second tick: target already met → no-op.
    async with async_session_factory() as session:
        assert await demo_keepalive_tick(session) == 0


# -- run order chat -----------------------------------------------------------


async def test_run_order_chat_is_runner_and_orderer_only(
    client: httpx.AsyncClient,
) -> None:
    """context_type='run' conversations are gated to the runner and that
    order's requester (spec §8 authz); anyone else gets 403 NOT_RUN_PARTY."""
    runner = await make_user(client, "chatrunner@campus.edu")
    requester = await make_user(client, "chatreq@campus.edu")
    outsider = await make_user(client, "chatout@campus.edu")
    spot_id = await _make_spot("Chat Spot")
    dropoff_id = await _make_dropoff()
    run = await _create_run(client, runner, spot_id)
    runner_id = run["runner"]["id"]

    order = await client.post(
        f"/api/v1/runs/{run['id']}/orders",
        json=_order_body("1 spicy deluxe", dropoff_id=dropoff_id),
        headers=requester,
    )
    assert order.status_code == 201, order.text
    order_id = order.json()["my_order"]["id"]

    body = {"recipient_id": runner_id, "context_type": "run", "context_id": order_id}
    resp = await client.post("/api/v1/conversations", json=body, headers=requester)
    assert resp.status_code == 201, resp.text
    conv_id = resp.json()["id"]

    # Re-opening reuses the same thread.
    again = await client.post("/api/v1/conversations", json=body, headers=requester)
    assert again.json()["id"] == conv_id

    # Messages flow both ways inside the run thread.
    sent = await client.post(
        f"/api/v1/conversations/{conv_id}/messages",
        json={"body": "They're out of fries — chips ok?"},
        headers=runner,
    )
    assert sent.status_code == 201, sent.text

    # An outsider can't open a chat on someone else's order.
    forbidden = await client.post("/api/v1/conversations", json=body, headers=outsider)
    assert forbidden.status_code == 403
    assert forbidden.json()["error"]["code"] == "NOT_RUN_PARTY"

    # Unknown order id is a 404, and run chats require a context_id.
    missing = await client.post(
        "/api/v1/conversations",
        json={**body, "context_id": str(uuid.uuid4())},
        headers=requester,
    )
    assert missing.status_code == 404
    no_ctx = await client.post(
        "/api/v1/conversations",
        json={"recipient_id": runner_id, "context_type": "run"},
        headers=requester,
    )
    assert no_ctx.status_code == 422
