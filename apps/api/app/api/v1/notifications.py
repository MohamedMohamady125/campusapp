"""Notification endpoints (spec §4.1 Notifications): feed, read, preferences."""

from datetime import UTC, datetime

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.deps import get_current_user
from app.core.pagination import DEFAULT_PAGE_SIZE, clamp_limit, decode_cursor, encode_cursor
from app.db.session import get_session
from app.models import NotificationPreference, User
from app.repositories.chat_repo import NotificationRepository
from app.schemas.chat import (
    NotificationPageResponse,
    NotificationPreferenceItem,
    NotificationPreferencesUpdateRequest,
    NotificationResponse,
    NotificationsReadRequest,
)

router = APIRouter(prefix="/notifications", tags=["notifications"])


@router.get("", response_model=NotificationPageResponse)
async def list_notifications(
    cursor: str | None = None,
    limit: int = Query(default=DEFAULT_PAGE_SIZE, ge=1, le=50),
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> NotificationPageResponse:
    repo = NotificationRepository(session)
    limit = clamp_limit(limit)
    notifications = await repo.list_for_user(
        user_id=user.id, cursor=decode_cursor(cursor) if cursor else None, limit=limit + 1
    )
    has_more = len(notifications) > limit
    notifications = notifications[:limit]
    next_cursor = (
        encode_cursor(notifications[-1].created_at, notifications[-1].id) if has_more else None
    )
    return NotificationPageResponse(
        items=[NotificationResponse.model_validate(n) for n in notifications],
        next_cursor=next_cursor,
        unread_count=await repo.unread_count(user.id),
    )


@router.post("/read", status_code=204)
async def mark_notifications_read(
    body: NotificationsReadRequest,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> None:
    await NotificationRepository(session).mark_read(
        user_id=user.id, ids=body.ids, now=datetime.now(UTC)
    )
    await session.commit()


@router.patch("/preferences", response_model=list[NotificationPreferenceItem])
async def update_preferences(
    body: NotificationPreferencesUpdateRequest,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> list[NotificationPreferenceItem]:
    repo = NotificationRepository(session)
    existing = {p.type: p for p in await repo.preferences(user.id)}
    for item in body.preferences:
        if item.type in existing:
            existing[item.type].enabled = item.enabled
        else:
            repo.add(NotificationPreference(user_id=user.id, type=item.type, enabled=item.enabled))
    await session.commit()
    return [NotificationPreferenceItem.model_validate(p) for p in await repo.preferences(user.id)]
