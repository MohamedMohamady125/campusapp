"""Stub email adapter: logs and returns deterministic success (spec §2.5)."""

import structlog

from app.integrations.email.base import EmailProvider

log = structlog.get_logger()


class StubEmailProvider(EmailProvider):
    def __init__(self) -> None:
        self.sent: list[dict[str, str]] = []  # inspectable in tests

    async def send(self, *, to: str, subject: str, body: str) -> None:
        self.sent.append({"to": to, "subject": subject, "body": body})
        log.info("email.stub_sent", to=to, subject=subject)
