"""Messaging business logic (spec §14 M5): participant-gated threads, read state.

AuthZ: a user can only read *their* conversations (spec §8) — every entry point
asserts participation and raises 403 NOT_PARTICIPANT otherwise.
"""

import uuid
from datetime import UTC, datetime

from sqlalchemy import update
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import BusinessRuleError, ForbiddenError, NotFoundError
from app.core.rate_limit import enforce_rate_limit
from app.models import Conversation, ConversationParticipant, Message, User
from app.models.enums import ConversationContext
from app.repositories.conversation_repo import ConversationRepository
from app.repositories.user_repo import UserRepository

MESSAGE_LIMIT = 30  # anti-spam (spec §8): max messages per window
MESSAGE_WINDOW_SECONDS = 60


class MessagingService:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session
        self._repo = ConversationRepository(session)
        self._users = UserRepository(session)

    async def get_or_create_conversation(
        self,
        *,
        user: User,
        recipient_id: uuid.UUID,
        context_type: ConversationContext,
        context_id: uuid.UUID | None,
    ) -> Conversation:
        if recipient_id == user.id:
            raise BusinessRuleError("Cannot message yourself.", code="SELF_CONVERSATION")
        recipient = await self._users.get_by_id(recipient_id)
        if recipient is None:
            raise NotFoundError("Recipient not found.", code="USER_NOT_FOUND")
        if context_type != ConversationContext.direct and context_id is None:
            raise BusinessRuleError(
                "context_id is required for listing/tutoring conversations.",
                code="CONTEXT_ID_REQUIRED",
            )

        existing = await self._repo.find_between(
            context_type=context_type,
            context_id=context_id,
            user_a=user.id,
            user_b=recipient_id,
        )
        if existing is not None:
            return existing

        conversation = Conversation(context_type=context_type, context_id=context_id)
        self._repo.add(conversation)
        await self._session.flush()
        for uid in (user.id, recipient_id):
            self._repo.add(ConversationParticipant(conversation_id=conversation.id, user_id=uid))
        await self._session.commit()
        return await self._get_or_404(conversation.id)

    async def _get_or_404(self, conversation_id: uuid.UUID) -> Conversation:
        conversation = await self._repo.get(conversation_id)
        if conversation is None:
            raise NotFoundError("Conversation not found.", code="CONVERSATION_NOT_FOUND")
        return conversation

    async def _assert_participant(
        self, conversation_id: uuid.UUID, user: User
    ) -> ConversationParticipant:
        participant = await self._repo.get_participant(conversation_id, user.id)
        if participant is None:
            raise ForbiddenError("You are not part of this conversation.", code="NOT_PARTICIPANT")
        return participant

    async def get_conversation(self, *, conversation_id: uuid.UUID, user: User) -> Conversation:
        conversation = await self._get_or_404(conversation_id)
        await self._assert_participant(conversation_id, user)
        return conversation

    async def list_messages(
        self,
        *,
        conversation_id: uuid.UUID,
        user: User,
        cursor: tuple[datetime, uuid.UUID] | None,
        limit: int,
    ) -> list[Message]:
        await self._get_or_404(conversation_id)
        await self._assert_participant(conversation_id, user)
        return await self._repo.list_messages(
            conversation_id=conversation_id, cursor=cursor, limit=limit
        )

    async def send_message(self, *, conversation_id: uuid.UUID, user: User, body: str) -> Message:
        await self._get_or_404(conversation_id)
        participant = await self._assert_participant(conversation_id, user)
        await enforce_rate_limit(
            f"msg:{user.id}", limit=MESSAGE_LIMIT, window_seconds=MESSAGE_WINDOW_SECONDS
        )
        message = Message(conversation_id=conversation_id, sender_id=user.id, body=body)
        self._repo.add(message)
        participant.last_read_at = datetime.now(UTC)
        await self._session.commit()
        await self._session.refresh(message)
        return message

    async def mark_read(self, *, conversation_id: uuid.UUID, user: User) -> None:
        await self._get_or_404(conversation_id)
        participant = await self._assert_participant(conversation_id, user)
        now = datetime.now(UTC)
        participant.last_read_at = now
        await self._session.execute(
            update(Message)
            .where(
                Message.conversation_id == conversation_id,
                Message.sender_id != user.id,
                Message.read_at.is_(None),
            )
            .values(read_at=now)
        )
        await self._session.commit()
