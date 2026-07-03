"""Analytics interface (spec §12): typed events behind an interface."""

import uuid
from abc import ABC, abstractmethod
from typing import Any

from sqlalchemy.ext.asyncio import AsyncSession

EVENT_SIGNUP_COMPLETED = "signup_completed"
EVENT_LISTING_CREATED = "listing_created"
EVENT_MESSAGE_SENT = "message_sent"
EVENT_CHAT_JOINED = "chat_joined"
EVENT_RATING_SUBMITTED = "rating_submitted"
EVENT_TUTOR_MATCH_VIEWED = "tutor_match_viewed"


class AnalyticsProvider(ABC):
    @abstractmethod
    async def track(
        self,
        session: AsyncSession,
        *,
        name: str,
        user_id: uuid.UUID | None,
        properties: dict[str, Any] | None = None,
    ) -> None:
        """Record an event. Joins the caller's transaction; must never raise."""
