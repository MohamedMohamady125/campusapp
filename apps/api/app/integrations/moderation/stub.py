"""Stub moderation: deterministic approve, logs every review (spec §2.5)."""

import structlog

from app.integrations.moderation.base import ModerationProvider, ModerationVerdict

log = structlog.get_logger()


class StubModerationProvider(ModerationProvider):
    async def review_image(self, *, key: str) -> ModerationVerdict:
        log.info("moderation.stub_review", key=key, verdict="approved")
        # Deterministic hook for tests: keys containing "reject" are rejected.
        if "reject" in key:
            return ModerationVerdict.rejected
        return ModerationVerdict.approved
