"""Conversation endpoints (spec §4.1 Conversations)."""

import uuid

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.deps import get_current_user
from app.core.pagination import DEFAULT_PAGE_SIZE, clamp_limit, decode_cursor, encode_cursor
from app.db.session import get_session
from app.models import Conversation, User
from app.repositories.conversation_repo import ConversationRepository
from app.schemas.conversation import (
    ConversationCreateRequest,
    ConversationPageResponse,
    ConversationResponse,
    MessageCreateRequest,
    MessagePageResponse,
    MessageResponse,
)
from app.schemas.user import UserPublicResponse
from app.services.messaging_service import MessagingService

router = APIRouter(prefix="/conversations", tags=["conversations"])


def _service(session: AsyncSession = Depends(get_session)) -> MessagingService:
    return MessagingService(session)


def _to_response(conversation: Conversation) -> ConversationResponse:
    # participants relationship holds ConversationParticipant rows; the API
    # exposes the user profiles behind them.
    return ConversationResponse(
        id=conversation.id,
        context_type=conversation.context_type,
        context_id=conversation.context_id,
        participants=[UserPublicResponse.model_validate(p.user) for p in conversation.participants],
        created_at=conversation.created_at,
    )


@router.get("", response_model=ConversationPageResponse)
async def list_conversations(
    cursor: str | None = None,
    limit: int = Query(default=DEFAULT_PAGE_SIZE, ge=1, le=50),
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> ConversationPageResponse:
    repo = ConversationRepository(session)
    limit = clamp_limit(limit)
    conversations = await repo.list_for_user(
        user_id=user.id,
        cursor=decode_cursor(cursor) if cursor else None,
        limit=limit + 1,
    )
    has_more = len(conversations) > limit
    conversations = conversations[:limit]
    next_cursor = (
        encode_cursor(conversations[-1].created_at, conversations[-1].id) if has_more else None
    )
    return ConversationPageResponse(
        items=[_to_response(c) for c in conversations], next_cursor=next_cursor
    )


@router.post("", response_model=ConversationResponse, status_code=201)
async def create_conversation(
    body: ConversationCreateRequest,
    user: User = Depends(get_current_user),
    svc: MessagingService = Depends(_service),
) -> ConversationResponse:
    conversation = await svc.get_or_create_conversation(
        user=user,
        recipient_id=body.recipient_id,
        context_type=body.context_type,
        context_id=body.context_id,
    )
    return _to_response(conversation)


@router.get("/{conversation_id}/messages", response_model=MessagePageResponse)
async def list_messages(
    conversation_id: uuid.UUID,
    cursor: str | None = None,
    limit: int = Query(default=DEFAULT_PAGE_SIZE, ge=1, le=50),
    user: User = Depends(get_current_user),
    svc: MessagingService = Depends(_service),
) -> MessagePageResponse:
    limit = clamp_limit(limit)
    messages = await svc.list_messages(
        conversation_id=conversation_id,
        user=user,
        cursor=decode_cursor(cursor) if cursor else None,
        limit=limit + 1,
    )
    has_more = len(messages) > limit
    messages = messages[:limit]
    next_cursor = encode_cursor(messages[-1].created_at, messages[-1].id) if has_more else None
    return MessagePageResponse(
        items=[MessageResponse.model_validate(m) for m in messages],
        next_cursor=next_cursor,
    )


@router.post("/{conversation_id}/messages", response_model=MessageResponse, status_code=201)
async def send_message(
    conversation_id: uuid.UUID,
    body: MessageCreateRequest,
    user: User = Depends(get_current_user),
    svc: MessagingService = Depends(_service),
) -> MessageResponse:
    message = await svc.send_message(conversation_id=conversation_id, user=user, body=body.body)
    return MessageResponse.model_validate(message)


@router.post("/{conversation_id}/read", status_code=204)
async def mark_read(
    conversation_id: uuid.UUID,
    user: User = Depends(get_current_user),
    svc: MessagingService = Depends(_service),
) -> None:
    await svc.mark_read(conversation_id=conversation_id, user=user)
