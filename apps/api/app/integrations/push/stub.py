"""Stub push adapter: records sends for tests, logs, returns success."""

import structlog

from app.integrations.push.base import PushMessage, PushProvider

log = structlog.get_logger()


class StubPushProvider(PushProvider):
    def __init__(self) -> None:
        self.sent: list[dict[str, object]] = []  # inspectable in tests

    async def send(self, *, tokens: list[str], message: PushMessage) -> list[str]:
        self.sent.append(
            {
                "tokens": list(tokens),
                "title": message.title,
                "body": message.body,
                "data": dict(message.data),
                "collapse_key": message.collapse_key,
                "critical": message.critical,
            }
        )
        log.info("push.stub_sent", tokens=len(tokens), title=message.title)
        return []
