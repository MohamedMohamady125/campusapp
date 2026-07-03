"""Test helpers: quick user factory returning auth headers."""

import httpx

PASSWORD = "Sup3rSecret!pw"


async def make_user(client: httpx.AsyncClient, email: str) -> dict[str, str]:
    """Register + verify + login; returns Authorization headers."""
    from app.integrations.email.provider import get_email_provider
    from app.integrations.email.stub import StubEmailProvider

    resp = await client.post(
        "/api/v1/auth/register",
        json={"email": email, "password": PASSWORD, "display_name": email.split("@")[0]},
    )
    assert resp.status_code == 201, resp.text
    provider = get_email_provider()
    assert isinstance(provider, StubEmailProvider)
    code = [m for m in provider.sent if m["to"] == email][-1]["body"].split()[-1].rstrip(".")
    assert (
        await client.post("/api/v1/auth/verify", json={"email": email, "code": code})
    ).status_code == 200
    login = await client.post("/api/v1/auth/login", json={"email": email, "password": PASSWORD})
    assert login.status_code == 200, login.text
    return {"Authorization": f"Bearer {login.json()['access_token']}"}
