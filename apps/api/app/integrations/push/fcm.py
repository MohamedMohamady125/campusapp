"""FCM HTTP v1 adapter — real pushes to iOS (via APNs) and Android.

Auth: mint a short-lived OAuth2 access token by signing a JWT with the
Firebase service-account key (RS256), exchanging it at the token endpoint.
Selected only when `FCM_SERVICE_ACCOUNT_JSON` is configured (see provider.py).
"""

import asyncio
import json
import time
from typing import Any

import httpx
import jwt
import structlog

from app.integrations.push.base import PushMessage, PushProvider

log = structlog.get_logger()

_OAUTH_SCOPE = "https://www.googleapis.com/auth/firebase.messaging"
_TOKEN_SKEW_S = 60
_SEND_TIMEOUT_S = 10.0


class FcmPushProvider(PushProvider):
    def __init__(self, service_account_json: str) -> None:
        account = json.loads(service_account_json)
        self._client_email: str = account["client_email"]
        self._private_key: str = account["private_key"]
        self._token_uri: str = account.get("token_uri", "https://oauth2.googleapis.com/token")
        self._project_id: str = account["project_id"]
        self._access_token: str | None = None
        self._access_token_exp: float = 0.0
        self._lock = asyncio.Lock()

    async def _token(self, client: httpx.AsyncClient) -> str:
        async with self._lock:
            now = time.time()
            if self._access_token and now < self._access_token_exp - _TOKEN_SKEW_S:
                return self._access_token
            assertion = jwt.encode(
                {
                    "iss": self._client_email,
                    "scope": _OAUTH_SCOPE,
                    "aud": self._token_uri,
                    "iat": int(now),
                    "exp": int(now) + 3600,
                },
                self._private_key,
                algorithm="RS256",
            )
            resp = await client.post(
                self._token_uri,
                data={
                    "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
                    "assertion": assertion,
                },
            )
            resp.raise_for_status()
            payload = resp.json()
            self._access_token = str(payload["access_token"])
            self._access_token_exp = now + float(payload.get("expires_in", 3600))
            return self._access_token

    def _message(self, token: str, message: PushMessage) -> dict[str, Any]:
        apns_headers: dict[str, str] = {"apns-priority": "10"}
        aps: dict[str, Any] = {"sound": "default"}
        if message.collapse_key:
            apns_headers["apns-collapse-id"] = message.collapse_key
        if message.critical:
            aps["interruption-level"] = "time-sensitive"
        android: dict[str, Any] = {"priority": "HIGH"}
        if message.collapse_key:
            android["collapse_key"] = message.collapse_key
        return {
            "message": {
                "token": token,
                "notification": {"title": message.title, "body": message.body},
                "data": message.data,
                "android": android,
                "apns": {"headers": apns_headers, "payload": {"aps": aps}},
            }
        }

    async def send(self, *, tokens: list[str], message: PushMessage) -> list[str]:
        dead: list[str] = []
        url = f"https://fcm.googleapis.com/v1/projects/{self._project_id}/messages:send"
        try:
            async with httpx.AsyncClient(timeout=_SEND_TIMEOUT_S) as client:
                auth = {"Authorization": f"Bearer {await self._token(client)}"}
                for token in tokens:
                    resp = await client.post(url, json=self._message(token, message), headers=auth)
                    if resp.status_code == 404 or (
                        resp.status_code == 400 and "UNREGISTERED" in resp.text
                    ):
                        dead.append(token)
                    elif resp.status_code >= 300:
                        log.warning(
                            "push.fcm_send_failed", status=resp.status_code, body=resp.text[:300]
                        )
        except (httpx.HTTPError, jwt.PyJWTError) as exc:  # best-effort: never break the caller
            log.warning("push.fcm_error", error=str(exc))
        return dead
