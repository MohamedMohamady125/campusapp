"""Moderation provider selection (spec §2.5). Real adapter (Rekognition et al.)
plugs in here when MODERATION_API_KEY is present; stub otherwise."""

from functools import lru_cache

from app.integrations.moderation.base import ModerationProvider
from app.integrations.moderation.stub import StubModerationProvider


@lru_cache
def get_moderation_provider() -> ModerationProvider:
    return StubModerationProvider()
