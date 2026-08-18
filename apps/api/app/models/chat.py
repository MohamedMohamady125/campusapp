"""Community chat models (spec §3)."""

import uuid
from datetime import datetime

from sqlalchemy import (
    DateTime,
    Enum,
    ForeignKey,
    Index,
    Integer,
    String,
    Text,
    UniqueConstraint,
)
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import TimestampedBase
from app.models.enums import ChatRole, ChatVisibility
from app.models.user import User


class Chat(TimestampedBase):
    __tablename__ = "chats"

    name: Mapped[str] = mapped_column(String(80))
    slug: Mapped[str] = mapped_column(String(100), unique=True, index=True)
    description: Mapped[str | None] = mapped_column(Text)
    visibility: Mapped[ChatVisibility] = mapped_column(
        Enum(ChatVisibility, name="chat_visibility"), default=ChatVisibility.open
    )
    created_by_id: Mapped[uuid.UUID] = mapped_column(
        PG_UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    member_cap: Mapped[int] = mapped_column(Integer, default=500)
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))

    created_by: Mapped[User] = relationship()
    memberships: Mapped[list["ChatMembership"]] = relationship(
        back_populates="chat", cascade="all, delete-orphan"
    )


class ChatMembership(TimestampedBase):
    __tablename__ = "chat_memberships"
    __table_args__ = (UniqueConstraint("chat_id", "user_id", name="uq_chat_membership"),)

    chat_id: Mapped[uuid.UUID] = mapped_column(
        PG_UUID(as_uuid=True), ForeignKey("chats.id", ondelete="CASCADE"), index=True
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        PG_UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    role: Mapped[ChatRole] = mapped_column(
        Enum(ChatRole, name="chat_role"), default=ChatRole.member
    )
    muted_until: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    banned_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))

    chat: Mapped[Chat] = relationship(back_populates="memberships")
    user: Mapped[User] = relationship()


class ChatMessage(TimestampedBase):
    __tablename__ = "chat_messages"
    __table_args__ = (Index("ix_chat_messages_chat_created", "chat_id", "created_at"),)

    chat_id: Mapped[uuid.UUID] = mapped_column(
        PG_UUID(as_uuid=True), ForeignKey("chats.id", ondelete="CASCADE"), index=True
    )
    sender_id: Mapped[uuid.UUID] = mapped_column(
        PG_UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    body: Mapped[str] = mapped_column(Text)
    attachment_key: Mapped[str | None] = mapped_column(String(255))
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    # Tombstoned moderation deletes: who removed it and why (shown in the feed).
    deleted_by_id: Mapped[uuid.UUID | None] = mapped_column(
        PG_UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL")
    )
    deleted_reason: Mapped[str | None] = mapped_column(String(300))

    chat: Mapped[Chat] = relationship()
    sender: Mapped[User] = relationship(foreign_keys=[sender_id])
    deleted_by: Mapped[User | None] = relationship(foreign_keys=[deleted_by_id])
