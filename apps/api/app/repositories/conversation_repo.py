"""Conversation/message data access with keyset cursor pagination (spec §2.4)."""

import uuid
from datetime import datetime

from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models import Conversation, ConversationParticipant, Message
from app.models.enums import ConversationContext


class ConversationRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def get(self, conversation_id: uuid.UUID) -> Conversation | None:
        result = await self._session.execute(
            select(Conversation)
            .options(
                selectinload(Conversation.participants).selectinload(ConversationParticipant.user)
            )
            .where(Conversation.id == conversation_id, Conversation.deleted_at.is_(None))
        )
        return result.scalar_one_or_none()

    async def find_between(
        self,
        *,
        context_type: ConversationContext,
        context_id: uuid.UUID | None,
        user_a: uuid.UUID,
        user_b: uuid.UUID,
    ) -> Conversation | None:
        """Reuse the existing thread for the same context + pair (spec §4.1:
        conversations are auto-created from a listing/tutor CTA, not duplicated)."""
        cp = ConversationParticipant
        stmt = (
            select(Conversation.id)
            .join(cp, cp.conversation_id == Conversation.id)
            .where(
                Conversation.context_type == context_type,
                Conversation.deleted_at.is_(None),
                cp.user_id.in_([user_a, user_b]),
            )
        )
        if context_id is None:
            stmt = stmt.where(Conversation.context_id.is_(None))
        else:
            stmt = stmt.where(Conversation.context_id == context_id)
        stmt = stmt.group_by(Conversation.id).having(func.count(cp.user_id.distinct()) == 2)
        conv_id = (await self._session.execute(stmt.limit(1))).scalar_one_or_none()
        return await self.get(conv_id) if conv_id else None

    async def list_for_user(
        self,
        *,
        user_id: uuid.UUID,
        cursor: tuple[datetime, uuid.UUID] | None,
        limit: int,
    ) -> list[Conversation]:
        cp = ConversationParticipant
        stmt = (
            select(Conversation)
            .options(
                selectinload(Conversation.participants).selectinload(ConversationParticipant.user)
            )
            .join(cp, cp.conversation_id == Conversation.id)
            .where(cp.user_id == user_id, Conversation.deleted_at.is_(None))
            .order_by(Conversation.created_at.desc(), Conversation.id.desc())
        )
        if cursor is not None:
            ts, cid = cursor
            stmt = stmt.where(
                or_(
                    Conversation.created_at < ts,
                    (Conversation.created_at == ts) & (Conversation.id < cid),
                )
            )
        result = await self._session.execute(stmt.limit(limit))
        return list(result.scalars().unique())

    async def get_participant(
        self, conversation_id: uuid.UUID, user_id: uuid.UUID
    ) -> ConversationParticipant | None:
        result = await self._session.execute(
            select(ConversationParticipant).where(
                ConversationParticipant.conversation_id == conversation_id,
                ConversationParticipant.user_id == user_id,
            )
        )
        return result.scalar_one_or_none()

    async def list_messages(
        self,
        *,
        conversation_id: uuid.UUID,
        cursor: tuple[datetime, uuid.UUID] | None,
        limit: int,
    ) -> list[Message]:
        stmt = (
            select(Message)
            .where(Message.conversation_id == conversation_id, Message.deleted_at.is_(None))
            .order_by(Message.created_at.desc(), Message.id.desc())
        )
        if cursor is not None:
            ts, mid = cursor
            stmt = stmt.where(
                or_(
                    Message.created_at < ts,
                    (Message.created_at == ts) & (Message.id < mid),
                )
            )
        result = await self._session.execute(stmt.limit(limit))
        return list(result.scalars())

    def add(self, obj: Conversation | ConversationParticipant | Message) -> None:
        self._session.add(obj)
