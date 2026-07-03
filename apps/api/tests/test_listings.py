"""M4 acceptance: listing CRUD + ownership, search, pagination, moderation gate,
no N+1 on GET /listings (spec §14 M4)."""

from typing import Any

import httpx
import pytest
from sqlalchemy import event

from app.db.session import engine
from tests.helpers import make_user

LISTING = {
    "title": "Calculus textbook 9th edition",
    "description": "Barely used, no highlights.",
    "price_cents": 4500,
    "category": "textbooks",
    "condition": "like_new",
}


async def _create_listing(
    client: httpx.AsyncClient, headers: dict[str, str], **overrides: Any
) -> dict[str, Any]:
    resp = await client.post("/api/v1/listings", json={**LISTING, **overrides}, headers=headers)
    assert resp.status_code == 201, resp.text
    data: dict[str, Any] = resp.json()
    return data


async def test_crud_and_ownership(client: httpx.AsyncClient) -> None:
    seller = await make_user(client, "seller@campus.edu")
    intruder = await make_user(client, "intruder@campus.edu")

    listing = await _create_listing(client, seller)
    listing_id = listing["id"]
    assert listing["status"] == "active"
    assert listing["seller"]["display_name"] == "seller"

    # Owner can update.
    resp = await client.patch(
        f"/api/v1/listings/{listing_id}", json={"price_cents": 4000}, headers=seller
    )
    assert resp.status_code == 200 and resp.json()["price_cents"] == 4000

    # Cross-user mutation is 403 (spec §8).
    for attempt in (
        client.patch(f"/api/v1/listings/{listing_id}", json={"price_cents": 1}, headers=intruder),
        client.post(f"/api/v1/listings/{listing_id}/mark-sold", headers=intruder),
        client.delete(f"/api/v1/listings/{listing_id}", headers=intruder),
    ):
        assert (await attempt).status_code == 403

    # Mark sold, then delete.
    assert (
        await client.post(f"/api/v1/listings/{listing_id}/mark-sold", headers=seller)
    ).status_code == 200
    assert (
        await client.delete(f"/api/v1/listings/{listing_id}", headers=seller)
    ).status_code == 204
    assert (await client.get(f"/api/v1/listings/{listing_id}", headers=seller)).status_code == 404


async def test_unauthenticated_rejected(client: httpx.AsyncClient) -> None:
    assert (await client.get("/api/v1/listings")).status_code == 401
    assert (await client.post("/api/v1/listings", json=LISTING)).status_code == 401


async def test_search_filters_and_ranking(client: httpx.AsyncClient) -> None:
    seller = await make_user(client, "seller@campus.edu")
    await _create_listing(client, seller)
    await _create_listing(
        client,
        seller,
        title="Mini fridge for dorm",
        description="Cold and quiet.",
        category="electronics",
        price_cents=8000,
    )

    # Full-text hit.
    resp = await client.get("/api/v1/listings", params={"q": "calculus"}, headers=seller)
    assert resp.status_code == 200
    items = resp.json()["items"]
    assert len(items) == 1 and "Calculus" in items[0]["title"]

    # Typo tolerance via trigram (spec §5.3).
    resp = await client.get("/api/v1/listings", params={"q": "calclus textbok"}, headers=seller)
    assert any("Calculus" in i["title"] for i in resp.json()["items"])

    # Category + price filters are WHERE clauses.
    resp = await client.get(
        "/api/v1/listings",
        params={"category": "electronics", "min_price": 5000},
        headers=seller,
    )
    items = resp.json()["items"]
    assert len(items) == 1 and items[0]["category"] == "electronics"

    # Sold listings drop out of browse.
    listing = await _create_listing(client, seller, title="Soon sold lamp")
    await client.post(f"/api/v1/listings/{listing['id']}/mark-sold", headers=seller)
    resp = await client.get("/api/v1/listings", headers=seller)
    assert all(i["id"] != listing["id"] for i in resp.json()["items"])


async def test_cursor_pagination(client: httpx.AsyncClient) -> None:
    seller = await make_user(client, "seller@campus.edu")
    for i in range(5):
        await _create_listing(client, seller, title=f"Numbered listing {i:02d}")

    seen: list[str] = []
    cursor: str | None = None
    for _ in range(3):
        params: dict[str, Any] = {"limit": 2}
        if cursor:
            params["cursor"] = cursor
        resp = await client.get("/api/v1/listings", params=params, headers=seller)
        assert resp.status_code == 200
        page = resp.json()
        seen.extend(i["id"] for i in page["items"])
        cursor = page["next_cursor"]
        if cursor is None:
            break
    assert len(seen) == len(set(seen)) == 5

    # Garbage cursor is a 400, not a 500.
    resp = await client.get("/api/v1/listings", params={"cursor": "!!!"}, headers=seller)
    assert resp.status_code == 400


async def test_image_upload_and_moderation_gate(client: httpx.AsyncClient) -> None:
    seller = await make_user(client, "seller@campus.edu")
    listing = await _create_listing(client, seller)

    resp = await client.post(
        f"/api/v1/listings/{listing['id']}/image-upload-url",
        json={"content_type": "image/jpeg"},
        headers=seller,
    )
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["upload_url"] and body["key"].startswith(f"listings/{listing['id']}/")

    detail = await client.get(f"/api/v1/listings/{listing['id']}", headers=seller)
    images = detail.json()["images"]
    assert len(images) == 1 and images[0]["moderation_status"] == "approved"

    # Disallowed content type rejected at the boundary.
    resp = await client.post(
        f"/api/v1/listings/{listing['id']}/image-upload-url",
        json={"content_type": "application/x-msdownload"},
        headers=seller,
    )
    assert resp.status_code == 400


@pytest.mark.parametrize("n_listings", [8])
async def test_browse_has_no_n_plus_1(client: httpx.AsyncClient, n_listings: int) -> None:
    """Query count must not scale with row count (spec §7.2)."""
    seller = await make_user(client, "seller@campus.edu")
    for i in range(n_listings):
        await _create_listing(client, seller, title=f"Bulk listing {i:02d}")

    queries: list[str] = []

    def _before_cursor_execute(
        conn: Any, cursor: Any, statement: str, *args: Any, **kwargs: Any
    ) -> None:
        if statement.lstrip().upper().startswith("SELECT"):
            queries.append(statement)

    sync_engine = engine.sync_engine
    event.listen(sync_engine, "before_cursor_execute", _before_cursor_execute)
    try:
        resp = await client.get("/api/v1/listings", params={"limit": 50}, headers=seller)
        assert resp.status_code == 200
        assert len(resp.json()["items"]) == n_listings
    finally:
        event.remove(sync_engine, "before_cursor_execute", _before_cursor_execute)

    # 1 auth-user lookup + 1 listings + selectinload(seller) + selectinload(images).
    assert len(queries) <= 5, f"possible N+1: {len(queries)} SELECTs\n" + "\n".join(queries)
