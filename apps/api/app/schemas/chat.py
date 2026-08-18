"""Community chat + notification contracts (spec §4.1 Chats, Notifications)."""

import uuid
from datetime import datetime
from typing import Any

from pydantic import BaseModel, ConfigDict, Field

from app.models.enums import ChatRole, ChatVisibility


class ChatCreateRequest(BaseModel):
    name: str = Field(min_length=3, max_length=80)
    description: str | None = Field(default=None, max_length=2000)
    visibility: ChatVisibility = ChatVisibility.open
    member_cap: int = Field(default=500, ge=2, le=5000)


class ChatResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    name: str
    slug: str
    description: str | None
    visibility: ChatVisibility
    member_cap: int
    member_count: int
    created_by_id: uuid.UUID
    created_at: datetime


class ChatPageResponse(BaseModel):
    items: list[ChatResponse]
    next_cursor: str | None


class ChatMembershipResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    chat_id: uuid.UUID
    user_id: uuid.UUID
    role: ChatRole
    muted_until: datetime | None
    banned_at: datetime | None


class ChatMessageCreateRequest(BaseModel):
    body: str = Field(min_length=1, max_length=4000)


class ChatMessageResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    chat_id: uuid.UUID
    sender_id: uuid.UUID
    body: str  # blanked to "" server-side when the message is deleted
    created_at: datetime
    # Tombstone fields (Sprint 6): deleted messages stay in the feed.
    deleted_at: datetime | None = None
    deleted_reason: str | None = None
    deleted_by_name: str | None = None


class ChatMessagePageResponse(BaseModel):
    items: list[ChatMessageResponse]
    next_cursor: str | None


class ChatMessageDeleteRequest(BaseModel):
    reason: str = Field(min_length=3, max_length=300)


class MuteRequest(BaseModel):
    minutes: int = Field(default=60, ge=1, le=10080)  # up to 7 days
    reason: str = Field(min_length=3, max_length=300)


class BanRequest(BaseModel):
    reason: str | None = Field(default=None, min_length=3, max_length=300)


class NotificationResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    type: str
    payload: dict[str, Any]
    read_at: datetime | None
    created_at: datetime


class NotificationPageResponse(BaseModel):
    items: list[NotificationResponse]
    next_cursor: str | None
    unread_count: int  # bell badge (spec §14 M7)


class NotificationsReadRequest(BaseModel):
    ids: list[uuid.UUID] | None = None  # None = mark all read


class NotificationPreferenceItem(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    type: str = Field(max_length=60)
    enabled: bool


class NotificationPreferencesUpdateRequest(BaseModel):
    preferences: list[NotificationPreferenceItem] = Field(min_length=1, max_length=20)
