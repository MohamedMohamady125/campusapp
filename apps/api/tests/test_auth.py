"""M2 acceptance: register → verify → login → guarded route → refresh → logout,
brute-force 429, cross-account protections (spec §14 M2)."""

import httpx

from app.integrations.email.provider import get_email_provider
from app.integrations.email.stub import StubEmailProvider

EMAIL = "student@campus.edu"
PASSWORD = "Sup3rSecret!pw"


def _last_code_for(email: str) -> str:
    provider = get_email_provider()
    assert isinstance(provider, StubEmailProvider)
    sent = [m for m in provider.sent if m["to"] == email]
    assert sent, f"no email sent to {email}"
    # Body format: "Your code is 123456."
    return sent[-1]["body"].split()[-1].rstrip(".")


async def _register_and_verify(client: httpx.AsyncClient, email: str = EMAIL) -> None:
    resp = await client.post(
        "/api/v1/auth/register",
        json={"email": email, "password": PASSWORD, "display_name": "Student One"},
    )
    assert resp.status_code == 201, resp.text
    resp = await client.post(
        "/api/v1/auth/verify", json={"email": email, "code": _last_code_for(email)}
    )
    assert resp.status_code == 200, resp.text


async def _login(client: httpx.AsyncClient, email: str = EMAIL) -> dict[str, str]:
    resp = await client.post("/api/v1/auth/login", json={"email": email, "password": PASSWORD})
    assert resp.status_code == 200, resp.text
    data: dict[str, str] = resp.json()
    return data


async def test_full_auth_journey(client: httpx.AsyncClient) -> None:
    await _register_and_verify(client)
    tokens = await _login(client)

    # Guarded route works with the access token…
    me = await client.get(
        "/api/v1/users/me", headers={"Authorization": f"Bearer {tokens['access_token']}"}
    )
    assert me.status_code == 200
    assert me.json()["email"] == EMAIL

    # …and fails without it.
    assert (await client.get("/api/v1/users/me")).status_code == 401

    # Refresh rotates the token.
    refreshed = await client.post(
        "/api/v1/auth/refresh", json={"refresh_token": tokens["refresh_token"]}
    )
    assert refreshed.status_code == 200
    new_refresh = refreshed.json()["refresh_token"]
    assert new_refresh != tokens["refresh_token"]

    # Reusing the rotated (old) token revokes the family.
    reused = await client.post(
        "/api/v1/auth/refresh", json={"refresh_token": tokens["refresh_token"]}
    )
    assert reused.status_code == 401
    assert reused.json()["error"]["code"] == "REFRESH_REUSED"

    # The new token is dead too (family revoked).
    dead = await client.post("/api/v1/auth/refresh", json={"refresh_token": new_refresh})
    assert dead.status_code == 401

    # Logout is idempotent and safe.
    out = await client.post("/api/v1/auth/logout", json={"refresh_token": new_refresh})
    assert out.status_code == 200


async def test_non_campus_email_rejected(client: httpx.AsyncClient) -> None:
    resp = await client.post(
        "/api/v1/auth/register",
        json={"email": "x@gmail.com", "password": PASSWORD, "display_name": "Rando"},
    )
    assert resp.status_code == 422
    assert resp.json()["error"]["code"] == "EMAIL_DOMAIN_NOT_ALLOWED"


async def test_unverified_login_blocked(client: httpx.AsyncClient) -> None:
    resp = await client.post(
        "/api/v1/auth/register",
        json={"email": EMAIL, "password": PASSWORD, "display_name": "Student"},
    )
    assert resp.status_code == 201
    resp = await client.post("/api/v1/auth/login", json={"email": EMAIL, "password": PASSWORD})
    assert resp.status_code == 401
    assert resp.json()["error"]["code"] == "EMAIL_NOT_VERIFIED"


async def test_login_bruteforce_429(client: httpx.AsyncClient) -> None:
    await _register_and_verify(client)
    for _ in range(5):
        resp = await client.post(
            "/api/v1/auth/login", json={"email": EMAIL, "password": "wrong-password!!"}
        )
        assert resp.status_code == 401
    resp = await client.post("/api/v1/auth/login", json={"email": EMAIL, "password": PASSWORD})
    assert resp.status_code == 429
    assert resp.headers.get("Retry-After") is not None


async def test_verify_code_single_use(client: httpx.AsyncClient) -> None:
    resp = await client.post(
        "/api/v1/auth/register",
        json={"email": EMAIL, "password": PASSWORD, "display_name": "Student"},
    )
    assert resp.status_code == 201
    code = _last_code_for(EMAIL)
    assert (
        await client.post("/api/v1/auth/verify", json={"email": EMAIL, "code": code})
    ).status_code == 200
    resp = await client.post("/api/v1/auth/verify", json={"email": EMAIL, "code": code})
    assert resp.status_code == 401


async def test_password_reset_flow(client: httpx.AsyncClient) -> None:
    await _register_and_verify(client)
    resp = await client.post("/api/v1/auth/forgot-password", json={"email": EMAIL})
    assert resp.status_code == 200
    code = _last_code_for(EMAIL)
    resp = await client.post(
        "/api/v1/auth/reset-password",
        json={"email": EMAIL, "code": code, "new_password": "N3w-Passw0rd!!"},
    )
    assert resp.status_code == 200
    # Old password rejected, new one works.
    bad = await client.post("/api/v1/auth/login", json={"email": EMAIL, "password": PASSWORD})
    assert bad.status_code == 401
    good = await client.post(
        "/api/v1/auth/login", json={"email": EMAIL, "password": "N3w-Passw0rd!!"}
    )
    assert good.status_code == 200


async def test_cross_user_profile_hides_email(client: httpx.AsyncClient) -> None:
    await _register_and_verify(client)
    await _register_and_verify(client, email="other@campus.edu")
    tokens = await _login(client)
    other_login = await _login(client, email="other@campus.edu")

    other_me = await client.get(
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {other_login['access_token']}"},
    )
    other_id = other_me.json()["id"]

    resp = await client.get(
        f"/api/v1/users/{other_id}",
        headers={"Authorization": f"Bearer {tokens['access_token']}"},
    )
    assert resp.status_code == 200
    assert "email" not in resp.json()  # public profile never leaks email (spec §8)
