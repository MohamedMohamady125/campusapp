"""Chat + notification data access, keyset-cursor paginated (spec §2.4)."""

import uuid
from datetime import datetime
from typing import Any, cast

from sqlalchemy import CursorResult, Select, func, or_, select, update
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models import (
    Chat,
    ChatMembership,
    ChatMessage,
    Notification,
    NotificationPreference,
    User,
)
from app.models.enums import ChatVisibility


def _keyset(
    stmt: Select[Any], model: Any, cursor: tuple[datetime, uuid.UUID] | None
) -> Select[Any]:
    if cursor is None:
        return stmt
    ts, oid = cursor
    return stmt.where(
        or_(
            model.created_at < ts,
            (model.created_at == ts) & (model.id < oid),
        )
    )


class ChatRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def get(self, chat_id: uuid.UUID) -> Chat | None:
        result = await self._session.execute(
            select(Chat).where(Chat.id == chat_id, Chat.deleted_at.is_(None))
        )
        return result.scalar_one_or_none()

    async def slug_exists(self, slug: str) -> bool:
        result = await self._session.execute(select(Chat.id).where(Chat.slug == slug))
        return result.scalar_one_or_none() is not None

    async def directory(
        self, *, cursor: tuple[datetime, uuid.UUID] | None, limit: int
    ) -> list[Chat]:
        """Browsable directory: private chats are not listed (spec §3 visibility)."""
        stmt = (
            select(Chat)
            .where(
                Chat.deleted_at.is_(None),
                Chat.visibility.in_([ChatVisibility.open, ChatVisibility.request]),
            )
            .order_by(Chat.created_at.desc(), Chat.id.desc())
        )
        stmt = _keyset(stmt, Chat, cursor)
        return list((await self._session.execute(stmt.limit(limit))).scalars())

    async def mine(
        self, *, user_id: uuid.UUID, cursor: tuple[datetime, uuid.UUID] | None, limit: int
    ) -> list[Chat]:
        stmt = (
            select(Chat)
            .join(ChatMembership, ChatMembership.chat_id == Chat.id)
            .where(
                ChatMembership.user_id == user_id,
                ChatMembership.banned_at.is_(None),
                Chat.deleted_at.is_(None),
            )
            .order_by(Chat.created_at.desc(), Chat.id.desc())
        )
        stmt = _keyset(stmt, Chat, cursor)
        return list((await self._session.execute(stmt.limit(limit))).scalars().unique())

    async def member_counts(self, chat_ids: list[uuid.UUID]) -> dict[uuid.UUID, int]:
        if not chat_ids:
            return {}
        rows = await self._session.execute(
            select(ChatMembership.chat_id, func.count(ChatMembership.id))
            .where(
                ChatMembership.chat_id.in_(chat_ids),
                ChatMembership.banned_at.is_(None),
            )
            .group_by(ChatMembership.chat_id)
        )
        return {row[0]: int(row[1]) for row in rows}

    async def get_membership(self, chat_id: uuid.UUID, user_id: uuid.UUID) -> ChatMembership | None:
        result = await self._session.execute(
            select(ChatMembership).where(
                ChatMembership.chat_id == chat_id, ChatMembership.user_id == user_id
            )
        )
        return result.scalar_one_or_none()

    async def member_ids(self, chat_id: uuid.UUID) -> list[uuid.UUID]:
        rows = await self._session.execute(
            select(ChatMembership.user_id).where(
                ChatMembership.chat_id == chat_id, ChatMembership.banned_at.is_(None)
            )
        )
        return [r[0] for r in rows]

    async def members_with_names(self, chat_id: uuid.UUID) -> list[tuple[uuid.UUID, str]]:
        """Active (non-banned) members with display names, for @mention matching."""
        rows = await self._session.execute(
            select(ChatMembership.user_id, User.display_name)
            .join(User, User.id == ChatMembership.user_id)
            .where(ChatMembership.chat_id == chat_id, ChatMembership.banned_at.is_(None))
        )
        return [(r[0], r[1]) for r in rows]

    async def get_message(self, message_id: uuid.UUID) -> ChatMessage | None:
        return await self._session.get(ChatMessage, message_id)

    async def list_messages(
        self,
        *,
        chat_id: uuid.UUID,
        cursor: tuple[datetime, uuid.UUID] | None,
        limit: int,
    ) -> list[ChatMessage]:
        # Deleted messages are NOT filtered out: they are returned as tombstones
        # (body blanked at the API layer) so the room shows "message removed".
        stmt = (
            select(ChatMessage)
            .options(selectinload(ChatMessage.deleted_by))
            .where(ChatMessage.chat_id == chat_id)
            .order_by(ChatMessage.created_at.desc(), ChatMessage.id.desc())
        )
        stmt = _keyset(stmt, ChatMessage, cursor)
        return list((await self._session.execute(stmt.limit(limit))).scalars())

    def add(self, obj: Chat | ChatMembership | ChatMessage) -> None:
        self._session.add(obj)

    async def delete_membership(self, membership: ChatMembership) -> None:
        await self._session.delete(membership)


class NotificationRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def list_for_user(
        self,
        *,
        user_id: uuid.UUID,
        cursor: tuple[datetime, uuid.UUID] | None,
        limit: int,
    ) -> list[Notification]:
        stmt = (
            select(Notification)
            .where(Notification.user_id == user_id)
            .order_by(Notification.created_at.desc(), Notification.id.desc())
        )
        stmt = _keyset(stmt, Notification, cursor)
        return list((await self._session.execute(stmt.limit(limit))).scalars())

    async def find_recent_unread_by_payload(
        self,
        *,
        user_id: uuid.UUID,
        type_: str,
        key: str,
        value: str,
        since: datetime,
    ) -> Notification | None:
        """Most recent unread notification of a type whose payload[key] == value,
        created after `since` — the dedup target for chat/DM fan-out."""
        stmt = (
            select(Notification)
            .where(
                Notification.user_id == user_id,
                Notification.type == type_,
                Notification.read_at.is_(None),
                Notification.created_at >= since,
                Notification.payload[key].astext == value,
            )
            .order_by(Notification.created_at.desc(), Notification.id.desc())
            .limit(1)
        )
        return (await self._session.execute(stmt)).scalars().first()

    async def unread_count(self, user_id: uuid.UUID) -> int:
        result = await self._session.execute(
            select(func.count(Notification.id)).where(
                Notification.user_id == user_id, Notification.read_at.is_(None)
            )
        )
        return int(result.scalar_one())

    async def mark_read(
        self, *, user_id: uuid.UUID, ids: list[uuid.UUID] | None, now: datetime
    ) -> int:
        stmt = (
            update(Notification)
            .where(Notification.user_id == user_id, Notification.read_at.is_(None))
            .values(read_at=now)
        )
        if ids is not None:
            stmt = stmt.where(Notification.id.in_(ids))
        result = cast(CursorResult[Any], await self._session.execute(stmt))
        return int(result.rowcount or 0)

    async def preferences(self, user_id: uuid.UUID) -> list[NotificationPreference]:
        result = await self._session.execute(
            select(NotificationPreference).where(NotificationPreference.user_id == user_id)
        )
        return list(result.scalars())

    async def disabled_types_for(self, user_ids: list[uuid.UUID], type_: str) -> set[uuid.UUID]:
        """Users who opted out of this notification type (default is enabled)."""
        if not user_ids:
            return set()
        rows = await self._session.execute(
            select(NotificationPreference.user_id).where(
                NotificationPreference.user_id.in_(user_ids),
                NotificationPreference.type == type_,
                NotificationPreference.enabled.is_(False),
            )
        )
        return {r[0] for r in rows}

    def add(self, obj: Notification | NotificationPreference) -> None:
        self._session.add(obj)
