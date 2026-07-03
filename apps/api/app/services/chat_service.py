"""Community chat business logic (spec §14 M7): membership, caps, moderation.

Moderation rules (spec §8 AuthZ): only chat mods/owners moderate, and only
chats they mod. Every moderation action writes an AuditLog row (spec §3).
Notifications fan out per-recipient preferences (default: enabled).
"""

import re
import uuid
from datetime import UTC, datetime, timedelta

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import (
    BusinessRuleError,
    ConflictError,
    ForbiddenError,
    NotFoundError,
)
from app.core.rate_limit import enforce_rate_limit
from app.models import AuditLog, Chat, ChatMembership, ChatMessage, Notification, User
from app.models.enums import ChatRole, ChatVisibility
from app.repositories.chat_repo import ChatRepository, NotificationRepository
from app.schemas.chat import ChatCreateRequest

CHAT_MESSAGE_LIMIT = 30  # anti-spam (spec §8)
CHAT_MESSAGE_WINDOW_SECONDS = 60
NOTIFICATION_TYPE_CHAT_MESSAGE = "chat_message"

_MOD_ROLES = (ChatRole.mod, ChatRole.owner)


def slugify(name: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")
    return slug or "chat"


class ChatService:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session
        self._repo = ChatRepository(session)
        self._notifications = NotificationRepository(session)

    # -- lifecycle ------------------------------------------------------------

    async def create_chat(self, *, creator: User, body: ChatCreateRequest) -> Chat:
        base = slugify(body.name)
        slug, n = base, 2
        while await self._repo.slug_exists(slug):
            slug = f"{base}-{n}"
            n += 1
        chat = Chat(
            name=body.name,
            slug=slug,
            description=body.description,
            visibility=body.visibility,
            member_cap=body.member_cap,
            created_by_id=creator.id,
        )
        self._repo.add(chat)
        await self._session.flush()
        self._repo.add(ChatMembership(chat_id=chat.id, user_id=creator.id, role=ChatRole.owner))
        await self._session.commit()
        return chat

    async def _get_or_404(self, chat_id: uuid.UUID) -> Chat:
        chat = await self._repo.get(chat_id)
        if chat is None:
            raise NotFoundError("Chat not found.", code="CHAT_NOT_FOUND")
        return chat

    async def join(self, *, chat_id: uuid.UUID, user: User) -> ChatMembership:
        chat = await self._get_or_404(chat_id)
        existing = await self._repo.get_membership(chat_id, user.id)
        if existing is not None:
            if existing.banned_at is not None:
                raise ForbiddenError("You are banned from this chat.", code="BANNED")
            raise ConflictError("Already a member.", code="ALREADY_MEMBER")
        if chat.visibility == ChatVisibility.private:
            raise ForbiddenError("This chat is private.", code="PRIVATE_CHAT")
        if chat.visibility == ChatVisibility.request:
            # v1: request-to-join queue not built yet; keep the gate explicit.
            raise BusinessRuleError(
                "This chat requires approval to join.", code="JOIN_REQUIRES_APPROVAL"
            )
        counts = await self._repo.member_counts([chat.id])
        if counts.get(chat.id, 0) >= chat.member_cap:
            raise BusinessRuleError("Chat is at member capacity.", code="CHAT_FULL")
        membership = ChatMembership(chat_id=chat.id, user_id=user.id)
        self._repo.add(membership)
        await self._session.commit()
        return membership

    async def leave(self, *, chat_id: uuid.UUID, user: User) -> None:
        await self._get_or_404(chat_id)
        membership = await self._repo.get_membership(chat_id, user.id)
        if membership is None:
            raise NotFoundError("Not a member.", code="NOT_MEMBER")
        if membership.role == ChatRole.owner:
            raise BusinessRuleError(
                "Owners cannot leave their own chat.", code="OWNER_CANNOT_LEAVE"
            )
        await self._repo.delete_membership(membership)
        await self._session.commit()

    # -- messaging ------------------------------------------------------------

    async def _assert_active_member(self, chat_id: uuid.UUID, user: User) -> ChatMembership:
        membership = await self._repo.get_membership(chat_id, user.id)
        if membership is None or membership.banned_at is not None:
            raise ForbiddenError("You are not a member of this chat.", code="NOT_MEMBER")
        return membership

    async def post_message(self, *, chat_id: uuid.UUID, user: User, body: str) -> ChatMessage:
        await self._get_or_404(chat_id)
        membership = await self._assert_active_member(chat_id, user)
        now = datetime.now(UTC)
        if membership.muted_until is not None and membership.muted_until > now:
            raise ForbiddenError("You are muted in this chat.", code="MUTED")
        await enforce_rate_limit(
            f"chatmsg:{user.id}",
            limit=CHAT_MESSAGE_LIMIT,
            window_seconds=CHAT_MESSAGE_WINDOW_SECONDS,
        )
        message = ChatMessage(chat_id=chat_id, sender_id=user.id, body=body)
        self._repo.add(message)
        await self._session.flush()
        await self._fan_out_notifications(chat_id=chat_id, message=message)
        await self._session.commit()
        await self._session.refresh(message)
        return message

    async def _fan_out_notifications(self, *, chat_id: uuid.UUID, message: ChatMessage) -> None:
        """Per-event notifications honoring preferences (spec §14 M7)."""
        member_ids = await self._repo.member_ids(chat_id)
        recipients = [uid for uid in member_ids if uid != message.sender_id]
        opted_out = await self._notifications.disabled_types_for(
            recipients, NOTIFICATION_TYPE_CHAT_MESSAGE
        )
        for uid in recipients:
            if uid in opted_out:
                continue
            self._notifications.add(
                Notification(
                    user_id=uid,
                    type=NOTIFICATION_TYPE_CHAT_MESSAGE,
                    payload={
                        "chat_id": str(chat_id),
                        "message_id": str(message.id),
                        "sender_id": str(message.sender_id),
                    },
                )
            )

    async def list_messages(
        self,
        *,
        chat_id: uuid.UUID,
        user: User,
        cursor: tuple[datetime, uuid.UUID] | None,
        limit: int,
    ) -> list[ChatMessage]:
        await self._get_or_404(chat_id)
        await self._assert_active_member(chat_id, user)
        return await self._repo.list_messages(chat_id=chat_id, cursor=cursor, limit=limit)

    # -- moderation -----------------------------------------------------------

    async def _assert_moderator(self, chat_id: uuid.UUID, actor: User) -> ChatMembership:
        membership = await self._repo.get_membership(chat_id, actor.id)
        if (
            membership is None
            or membership.banned_at is not None
            or membership.role not in _MOD_ROLES
        ):
            raise ForbiddenError("Moderator role required.", code="NOT_CHAT_MOD")
        return membership

    def _audit(
        self, actor: User, action: str, target_type: str, target_id: uuid.UUID, **meta: str
    ) -> None:
        self._session.add(
            AuditLog(
                actor_id=actor.id,
                action=action,
                target_type=target_type,
                target_id=target_id,
                metadata_=dict(meta),
            )
        )

    async def delete_message(
        self, *, chat_id: uuid.UUID, message_id: uuid.UUID, actor: User
    ) -> None:
        await self._get_or_404(chat_id)
        await self._assert_moderator(chat_id, actor)
        message = await self._repo.get_message(message_id)
        if message is None or message.chat_id != chat_id or message.deleted_at is not None:
            raise NotFoundError("Message not found.", code="MESSAGE_NOT_FOUND")
        message.deleted_at = datetime.now(UTC)
        self._audit(actor, "chat_message.delete", "chat_message", message.id, chat_id=str(chat_id))
        await self._session.commit()

    async def _moderatable_member(
        self, chat_id: uuid.UUID, target_user_id: uuid.UUID
    ) -> ChatMembership:
        target = await self._repo.get_membership(chat_id, target_user_id)
        if target is None:
            raise NotFoundError("Member not found.", code="MEMBER_NOT_FOUND")
        if target.role == ChatRole.owner:
            raise ForbiddenError("The owner cannot be moderated.", code="CANNOT_MODERATE_OWNER")
        return target

    async def mute_member(
        self, *, chat_id: uuid.UUID, target_user_id: uuid.UUID, actor: User, minutes: int
    ) -> ChatMembership:
        await self._get_or_404(chat_id)
        await self._assert_moderator(chat_id, actor)
        target = await self._moderatable_member(chat_id, target_user_id)
        target.muted_until = datetime.now(UTC) + timedelta(minutes=minutes)
        self._audit(
            actor,
            "chat_member.mute",
            "user",
            target_user_id,
            chat_id=str(chat_id),
            minutes=str(minutes),
        )
        await self._session.commit()
        return target

    async def ban_member(
        self, *, chat_id: uuid.UUID, target_user_id: uuid.UUID, actor: User
    ) -> ChatMembership:
        await self._get_or_404(chat_id)
        await self._assert_moderator(chat_id, actor)
        target = await self._moderatable_member(chat_id, target_user_id)
        target.banned_at = datetime.now(UTC)
        self._audit(actor, "chat_member.ban", "user", target_user_id, chat_id=str(chat_id))
        await self._session.commit()
        return target
