"""Image moderation interface (spec §2.5, §8: every image gated before public)."""

import enum
from abc import ABC, abstractmethod


class ModerationVerdict(enum.StrEnum):
    approved = "approved"
    rejected = "rejected"


class ModerationProvider(ABC):
    @abstractmethod
    async def review_image(self, *, key: str) -> ModerationVerdict:
        """Review an uploaded object by storage key."""
