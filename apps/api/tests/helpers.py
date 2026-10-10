"""Test helpers: quick user factory returning auth headers."""

import httpx

PASSWORD = "Sup3rSecret!pw"


async def make_user(
    client: httpx.AsyncClient,
    email: str,
    *,
    avatar: bool = True,
    payment: bool = True,
) -> dict[str, str]:
    """Register + verify + login; returns Authorization headers.

    Sets a profile photo and a payment method by default (posting a run
    requires BOTH — AVATAR_REQUIRED / PAYMENT_METHOD_REQUIRED gates); pass
    avatar=False / payment=False to test the gates themselves.
    """
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
    headers = {"Authorization": f"Bearer {login.json()['access_token']}"}
    if avatar:
        patched = await client.patch(
            "/api/v1/users/me",
            json={"avatar_key": "avatars/test/selfie.png"},
            headers=headers,
        )
        assert patched.status_code == 200, patched.text
    if payment:
        paid = await client.patch(
            "/api/v1/users/me",
            json={"payment_methods": [{"type": "venmo", "handle": f"@{email.split('@')[0]}"}]},
            headers=headers,
        )
        assert paid.status_code == 200, paid.text
    return headers
