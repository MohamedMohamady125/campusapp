"""Email send log — powers the email program's anti-spam guarantees.

One row per program email actually dispatched. Queried to enforce:
- at most ONE marketing email per user per 7 days (CAN-SPAM hygiene + the
  "ceiling 1 marketing email/week" product rule),
- once-ever sends (first-order nudge) and cool-downs (win-back, wrapped),
- a global daily marketing budget so a batch can never blow the provider's
  daily quota that transactional email depends on.
"""

import uuid

from sqlalchemy import ForeignKey, Index, String
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import TimestampedBase


class EmailLog(TimestampedBase):
    __tablename__ = "email_log"
    __table_args__ = (Index("ix_email_log_user_kind_created", "user_id", "kind", "created_at"),)

    user_id: Mapped[uuid.UUID] = mapped_column(
        PG_UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    kind: Mapped[str] = mapped_column(String(40))
