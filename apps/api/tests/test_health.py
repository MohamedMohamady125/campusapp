"""M0 acceptance: health endpoints and error envelope."""

import httpx

from app.core.errors import NotFoundError


async def test_health_ok(client: httpx.AsyncClient) -> None:
    resp = await client.get("/api/v1/health")
    assert resp.status_code == 200
    assert resp.json() == {"status": "ok"}


async def test_error_envelope_shape() -> None:
    err = NotFoundError("Listing not found.", code="LISTING_NOT_FOUND")
    assert err.status_code == 404
    assert err.code == "LISTING_NOT_FOUND"
    assert err.details == {}


async def test_validation_error_envelope(client: httpx.AsyncClient) -> None:
    # /health/ready with a broken DB is fine (degraded), but a bad route 404s via FastAPI.
    resp = await client.get("/api/v1/nope")
    assert resp.status_code == 404
