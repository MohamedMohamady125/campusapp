"""Community chat endpoints (spec §4.1 Chats)."""

import uuid

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.deps import get_current_user
from app.core.pagination import DEFAULT_PAGE_SIZE, clamp_limit, decode_cursor, encode_cursor
from app.db.session import get_session
from app.models import Chat, User
from app.repositories.chat_repo import ChatRepository
from app.schemas.chat import (
    ChatCreateRequest,
    ChatMembershipResponse,
    ChatMessageCreateRequest,
    ChatMessagePageResponse,
    ChatMessageResponse,
    ChatPageResponse,
    ChatResponse,
    MuteRequest,
)
from app.services.chat_service import ChatService

router = APIRouter(prefix="/chats", tags=["chats"])


def _service(session: AsyncSession = Depends(get_session)) -> ChatService:
    return ChatService(session)


async def _page(chats: list[Chat], repo: ChatRepository, *, limit: int) -> ChatPageResponse:
    has_more = len(chats) > limit
    chats = chats[:limit]
    counts = await repo.member_counts([c.id for c in chats])
    items = [
        ChatResponse(
            id=c.id,
            name=c.name,
            slug=c.slug,
            description=c.description,
            visibility=c.visibility,
            member_cap=c.member_cap,
            member_count=counts.get(c.id, 0),
            created_by_id=c.created_by_id,
            created_at=c.created_at,
        )
        for c in chats
    ]
    next_cursor = encode_cursor(chats[-1].created_at, chats[-1].id) if has_more else None
    return ChatPageResponse(items=items, next_cursor=next_cursor)


@router.get("", response_model=ChatPageResponse)
async def my_chats(
    cursor: str | None = None,
    limit: int = Query(default=DEFAULT_PAGE_SIZE, ge=1, le=50),
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> ChatPageResponse:
    repo = ChatRepository(session)
    limit = clamp_limit(limit)
    chats = await repo.mine(
        user_id=user.id, cursor=decode_cursor(cursor) if cursor else None, limit=limit + 1
    )
    return await _page(chats, repo, limit=limit)


@router.get("/directory", response_model=ChatPageResponse)
async def chat_directory(
    cursor: str | None = None,
    limit: int = Query(default=DEFAULT_PAGE_SIZE, ge=1, le=50),
    _: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> ChatPageResponse:
    repo = ChatRepository(session)
    limit = clamp_limit(limit)
    chats = await repo.directory(cursor=decode_cursor(cursor) if cursor else None, limit=limit + 1)
    return await _page(chats, repo, limit=limit)


@router.post("", response_model=ChatResponse, status_code=201)
async def create_chat(
    body: ChatCreateRequest,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> ChatResponse:
    chat = await ChatService(session).create_chat(creator=user, body=body)
    return ChatResponse(
        id=chat.id,
        name=chat.name,
        slug=chat.slug,
        description=chat.description,
        visibility=chat.visibility,
        member_cap=chat.member_cap,
        member_count=1,
        created_by_id=chat.created_by_id,
        created_at=chat.created_at,
    )


@router.post("/{chat_id}/join", response_model=ChatMembershipResponse, status_code=201)
async def join_chat(
    chat_id: uuid.UUID,
    user: User = Depends(get_current_user),
    svc: ChatService = Depends(_service),
) -> ChatMembershipResponse:
    membership = await svc.join(chat_id=chat_id, user=user)
    return ChatMembershipResponse.model_validate(membership)


@router.post("/{chat_id}/leave", status_code=204)
async def leave_chat(
    chat_id: uuid.UUID,
    user: User = Depends(get_current_user),
    svc: ChatService = Depends(_service),
) -> None:
    await svc.leave(chat_id=chat_id, user=user)


@router.get("/{chat_id}/messages", response_model=ChatMessagePageResponse)
async def list_chat_messages(
    chat_id: uuid.UUID,
    cursor: str | None = None,
    limit: int = Query(default=DEFAULT_PAGE_SIZE, ge=1, le=50),
    user: User = Depends(get_current_user),
    svc: ChatService = Depends(_service),
) -> ChatMessagePageResponse:
    limit = clamp_limit(limit)
    messages = await svc.list_messages(
        chat_id=chat_id,
        user=user,
        cursor=decode_cursor(cursor) if cursor else None,
        limit=limit + 1,
    )
    has_more = len(messages) > limit
    messages = messages[:limit]
    next_cursor = encode_cursor(messages[-1].created_at, messages[-1].id) if has_more else None
    return ChatMessagePageResponse(
        items=[ChatMessageResponse.model_validate(m) for m in messages],
        next_cursor=next_cursor,
    )


@router.post("/{chat_id}/messages", response_model=ChatMessageResponse, status_code=201)
async def post_chat_message(
    chat_id: uuid.UUID,
    body: ChatMessageCreateRequest,
    user: User = Depends(get_current_user),
    svc: ChatService = Depends(_service),
) -> ChatMessageResponse:
    message = await svc.post_message(chat_id=chat_id, user=user, body=body.body)
    return ChatMessageResponse.model_validate(message)


@router.post("/{chat_id}/messages/{message_id}/delete", status_code=204)
async def delete_chat_message(
    chat_id: uuid.UUID,
    message_id: uuid.UUID,
    user: User = Depends(get_current_user),
    svc: ChatService = Depends(_service),
) -> None:
    await svc.delete_message(chat_id=chat_id, message_id=message_id, actor=user)


@router.post("/{chat_id}/members/{user_id}/mute", response_model=ChatMembershipResponse)
async def mute_member(
    chat_id: uuid.UUID,
    user_id: uuid.UUID,
    body: MuteRequest,
    user: User = Depends(get_current_user),
    svc: ChatService = Depends(_service),
) -> ChatMembershipResponse:
    membership = await svc.mute_member(
        chat_id=chat_id, target_user_id=user_id, actor=user, minutes=body.minutes
    )
    return ChatMembershipResponse.model_validate(membership)


@router.post("/{chat_id}/members/{user_id}/ban", response_model=ChatMembershipResponse)
async def ban_member(
    chat_id: uuid.UUID,
    user_id: uuid.UUID,
    user: User = Depends(get_current_user),
    svc: ChatService = Depends(_service),
) -> ChatMembershipResponse:
    membership = await svc.ban_member(chat_id=chat_id, target_user_id=user_id, actor=user)
    return ChatMembershipResponse.model_validate(membership)
