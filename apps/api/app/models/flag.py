"""Feature flags (spec §2.4, §3): half-built features ship dark."""

from sqlalchemy import Boolean, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import TimestampedBase


class Flag(TimestampedBase):
    __tablename__ = "flags"

    key: Mapped[str] = mapped_column(String(60), unique=True, index=True)
    enabled: Mapped[bool] = mapped_column(Boolean, default=False)
    rollout_percent: Mapped[int] = mapped_column(Integer, default=100)
