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
from app.integrations.analytics.base import EVENT_MESSAGE_SENT
from app.integrations.analytics.provider import get_analytics_provider
from app.models import Conversation, ConversationParticipant, FoodSpot, Message, Run, RunOrder, User
from app.models.enums import ConversationContext
from app.repositories.chat_repo import NotificationRepository
from app.repositories.conversation_repo import ConversationRepository
from app.repositories.user_repo import UserRepository
from app.services.notification_dispatch import upsert_deduped_notification

MESSAGE_LIMIT = 30  # anti-spam (spec §8): max messages per window
MESSAGE_WINDOW_SECONDS = 60
NOTIFICATION_TYPE_DM_MESSAGE = "dm_message"


class MessagingService:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session
        self._repo = ConversationRepository(session)
        self._users = UserRepository(session)
        self._notifications = NotificationRepository(session)

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
                "context_id is required for listing/tutoring/run conversations.",
                code="CONTEXT_ID_REQUIRED",
            )
        if context_type == ConversationContext.run:
            assert context_id is not None  # guarded above
            await self._assert_run_order_party(
                order_id=context_id, user_id=user.id, recipient_id=recipient_id
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

    async def _assert_run_order_party(
        self, *, order_id: uuid.UUID, user_id: uuid.UUID, recipient_id: uuid.UUID
    ) -> None:
        """Run chats are strictly between the runner and that order's requester
        (spec §8 authz: ownership checks on every mutating endpoint)."""
        order = await self._session.get(RunOrder, order_id)
        if order is None:
            raise NotFoundError("Order not found.", code="ORDER_NOT_FOUND")
        run = await self._session.get(Run, order.run_id)
        if run is None:  # pragma: no cover — FK guarantees the parent run
            raise NotFoundError("Run not found.", code="RUN_NOT_FOUND")
        if {user_id, recipient_id} != {run.runner_id, order.requester_id}:
            raise ForbiddenError(
                "Run chats are between the runner and the orderer only.",
                code="NOT_RUN_PARTY",
            )

    async def get_run_context(
        self, conversation: Conversation
    ) -> tuple[RunOrder, Run, FoodSpot] | None:
        """Order/run/spot behind a run conversation, for the pinned chat
        sub-header. None for non-run threads or if the order was withdrawn."""
        if conversation.context_type != ConversationContext.run or conversation.context_id is None:
            return None
        order = await self._session.get(RunOrder, conversation.context_id)
        if order is None:
            return None
        run = await self._session.get(Run, order.run_id)
        if run is None:  # pragma: no cover — FK guarantees the parent run
            return None
        spot = await self._session.get(FoodSpot, run.food_spot_id)
        if spot is None:  # pragma: no cover — FK guarantees the spot
            return None
        return order, run, spot

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
        conversation = await self._get_or_404(conversation_id)
        participant = await self._assert_participant(conversation_id, user)
        await enforce_rate_limit(
            f"msg:{user.id}", limit=MESSAGE_LIMIT, window_seconds=MESSAGE_WINDOW_SECONDS
        )
        message = Message(conversation_id=conversation_id, sender_id=user.id, body=body)
        self._repo.add(message)
        await self._session.flush()  # assign message.id for the notification payload
        participant.last_read_at = datetime.now(UTC)
        await self._notify_recipients(conversation=conversation, sender=user, message=message)
        await get_analytics_provider().track(
            self._session,
            name=EVENT_MESSAGE_SENT,
            user_id=user.id,
            properties={"conversation_id": str(conversation_id)},
        )
        await self._session.commit()
        await self._session.refresh(message)
        return message

    async def _notify_recipients(
        self, *, conversation: Conversation, sender: User, message: Message
    ) -> None:
        """dm_message notifications for the other participant(s) (Sprint 6),
        honoring per-type NotificationPreference like the chat fan-out and
        deduped per recipient on payload.conversation_id within 60 minutes."""
        recipients = [p.user_id for p in conversation.participants if p.user_id != sender.id]
        opted_out = await self._notifications.disabled_types_for(
            recipients, NOTIFICATION_TYPE_DM_MESSAGE
        )
        now = datetime.now(UTC)
        for uid in recipients:
            if uid in opted_out:
                continue
            await upsert_deduped_notification(
                self._notifications,
                user_id=uid,
                type_=NOTIFICATION_TYPE_DM_MESSAGE,
                dedup_key="conversation_id",
                dedup_value=str(conversation.id),
                payload={
                    "conversation_id": str(conversation.id),
                    "message_id": str(message.id),
                    "sender_id": str(sender.id),
                    "sender_name": sender.display_name,
                },
                now=now,
            )

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
