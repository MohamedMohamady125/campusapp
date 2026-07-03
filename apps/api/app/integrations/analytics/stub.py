"""DB analytics adapter (spec §12 stub): writes to the analytics_events table."""

import uuid
from typing import Any

import structlog
from sqlalchemy.ext.asyncio import AsyncSession

from app.integrations.analytics.base import AnalyticsProvider
from app.models import AnalyticsEvent

log = structlog.get_logger()


class DbAnalyticsProvider(AnalyticsProvider):
    async def track(
        self,
        session: AsyncSession,
        *,
        name: str,
        user_id: uuid.UUID | None,
        properties: dict[str, Any] | None = None,
    ) -> None:
        try:
            session.add(AnalyticsEvent(name=name, user_id=user_id, properties=properties or {}))
        except Exception:  # analytics must never break the request path
            log.warning("analytics.track_failed", event=name)
