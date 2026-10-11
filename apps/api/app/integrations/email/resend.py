"""Resend HTTP adapter — real transactional email in prod (spec §2.5).

Activated when EMAIL_PROVIDER_API_KEY is set. Failures are logged, never
raised: a verification email that bounces must not 500 the register call.
"""

import httpx
import structlog

from app.core.config import get_settings
from app.integrations.email.base import EmailProvider

log = structlog.get_logger()

_API_URL = "https://api.resend.com/emails"


class ResendEmailProvider(EmailProvider):
    async def send(self, *, to: str, subject: str, body: str) -> None:
        settings = get_settings()
        try:
            async with httpx.AsyncClient(timeout=10) as client:
                resp = await client.post(
                    _API_URL,
                    headers={"Authorization": f"Bearer {settings.email_provider_api_key}"},
                    json={
                        "from": settings.email_from,
                        "to": [to],
                        "subject": subject,
                        "text": body,
                    },
                )
            if resp.status_code >= 400:
                log.warning(
                    "email.resend_failed", to=to, status=resp.status_code, body=resp.text[:200]
                )
            else:
                log.info("email.sent", to=to, subject=subject, provider="resend")
        except httpx.HTTPError:
            log.warning("email.resend_unreachable", to=to, subject=subject)
