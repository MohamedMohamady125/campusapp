"""Course and tutoring models (spec §3)."""

import uuid

from sqlalchemy import Boolean, Enum, ForeignKey, Index, String, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import TimestampedBase
from app.models.user import User


class Course(TimestampedBase):
    __tablename__ = "courses"

    code: Mapped[str] = mapped_column(String(20), unique=True, index=True)
    title: Mapped[str] = mapped_column(String(200))
    department: Mapped[str] = mapped_column(String(120), index=True)


class TutorOffering(TimestampedBase):
    __tablename__ = "tutor_offerings"
    __table_args__ = (
        UniqueConstraint("tutor_id", "course_id", name="uq_tutor_offering_tutor_course"),
        Index("ix_tutor_offerings_course_active", "course_id", "active"),
    )

    tutor_id: Mapped[uuid.UUID] = mapped_column(
        PG_UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    course_id: Mapped[uuid.UUID] = mapped_column(
        PG_UUID(as_uuid=True), ForeignKey("courses.id", ondelete="CASCADE"), index=True
    )
    # e.g. "2025-fall"; recency component of ranking (spec §5.1).
    term_taken: Mapped[str] = mapped_column(String(20))
    grade_received: Mapped[str] = mapped_column(
        Enum("A+", "A", "A-", "B+", "B", "B-", name="grade_received")
    )
    blurb: Mapped[str | None] = mapped_column(Text)
    active: Mapped[bool] = mapped_column(Boolean, default=True)

    tutor: Mapped[User] = relationship()
    course: Mapped[Course] = relationship()
