"""Analytics instrumentation (spec §12): raw events + nightly aggregates."""

import uuid
from datetime import date
from typing import Any

from sqlalchemy import Date, ForeignKey, Index, Numeric, String, UniqueConstraint
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import TimestampedBase


class AnalyticsEvent(TimestampedBase):
    """Typed server events (spec §12); the stub analytics adapter writes here."""

    __tablename__ = "analytics_events"
    __table_args__ = (Index("ix_analytics_events_name_created", "name", "created_at"),)

    name: Mapped[str] = mapped_column(String(60))
    user_id: Mapped[uuid.UUID | None] = mapped_column(
        PG_UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL")
    )
    properties: Mapped[dict[str, Any]] = mapped_column(JSONB, default=dict)


class DailyMetric(TimestampedBase):
    """Nightly aggregation target (spec §12) for cheap dashboarding."""

    __tablename__ = "daily_metrics"
    __table_args__ = (UniqueConstraint("day", "name", name="uq_daily_metric_day_name"),)

    day: Mapped[date] = mapped_column(Date, index=True)
    name: Mapped[str] = mapped_column(String(60))
    value: Mapped[float] = mapped_column(Numeric(14, 2))
