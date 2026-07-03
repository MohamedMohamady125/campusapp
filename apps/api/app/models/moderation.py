"""Rating, report, and audit-log models (spec §3)."""

import uuid
from datetime import datetime
from typing import Any

from sqlalchemy import (
    DateTime,
    Enum,
    ForeignKey,
    Index,
    SmallInteger,
    String,
    Text,
    UniqueConstraint,
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import TimestampedBase
from app.models.enums import RatingContext, ReportStatus, ReportTargetType
from app.models.user import User


class Rating(TimestampedBase):
    """One rating per (rater, context) — no double-rating a transaction (spec §3)."""

    __tablename__ = "ratings"
    __table_args__ = (
        UniqueConstraint("rater_id", "context_type", "context_id", name="uq_rating_per_context"),
        Index("ix_ratings_rated_user", "rated_user_id"),
    )

    rater_id: Mapped[uuid.UUID] = mapped_column(
        PG_UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    rated_user_id: Mapped[uuid.UUID] = mapped_column(
        PG_UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE")
    )
    context_type: Mapped[RatingContext] = mapped_column(Enum(RatingContext, name="rating_context"))
    context_id: Mapped[uuid.UUID] = mapped_column(PG_UUID(as_uuid=True))
    stars: Mapped[int] = mapped_column(SmallInteger)
    comment: Mapped[str | None] = mapped_column(Text)
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))

    rater: Mapped[User] = relationship(foreign_keys=[rater_id])
    rated_user: Mapped[User] = relationship(foreign_keys=[rated_user_id])


class Report(TimestampedBase):
    __tablename__ = "reports"
    __table_args__ = (Index("ix_reports_status_created", "status", "created_at"),)

    reporter_id: Mapped[uuid.UUID] = mapped_column(
        PG_UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    target_type: Mapped[ReportTargetType] = mapped_column(
        Enum(ReportTargetType, name="report_target_type")
    )
    target_id: Mapped[uuid.UUID] = mapped_column(PG_UUID(as_uuid=True))
    reason: Mapped[str] = mapped_column(Text)
    status: Mapped[ReportStatus] = mapped_column(
        Enum(ReportStatus, name="report_status"), default=ReportStatus.open
    )
    handled_by_id: Mapped[uuid.UUID | None] = mapped_column(
        PG_UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL")
    )

    reporter: Mapped[User] = relationship(foreign_keys=[reporter_id])
    handled_by: Mapped[User | None] = relationship(foreign_keys=[handled_by_id])


class AuditLog(TimestampedBase):
    """Written on every moderation/admin action and auth-sensitive event (spec §3, §8)."""

    __tablename__ = "audit_logs"
    __table_args__ = (Index("ix_audit_logs_target", "target_type", "target_id"),)

    actor_id: Mapped[uuid.UUID | None] = mapped_column(
        PG_UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), index=True
    )
    action: Mapped[str] = mapped_column(String(80))
    target_type: Mapped[str] = mapped_column(String(40))
    target_id: Mapped[uuid.UUID | None] = mapped_column(PG_UUID(as_uuid=True))
    metadata_: Mapped[dict[str, Any]] = mapped_column("metadata", JSONB, default=dict)

    actor: Mapped[User | None] = relationship()
