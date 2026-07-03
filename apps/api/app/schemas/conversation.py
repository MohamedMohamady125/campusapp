"""Messaging contracts (spec §4.1 Conversations)."""

import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field

from app.models.enums import ConversationContext
from app.schemas.user import UserPublicResponse


class ConversationCreateRequest(BaseModel):
    recipient_id: uuid.UUID
    context_type: ConversationContext = ConversationContext.direct
    context_id: uuid.UUID | None = None


class MessageCreateRequest(BaseModel):
    body: str = Field(min_length=1, max_length=4000)


class MessageResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    conversation_id: uuid.UUID
    sender_id: uuid.UUID
    body: str
    read_at: datetime | None
    created_at: datetime


class ConversationResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    context_type: ConversationContext
    context_id: uuid.UUID | None
    participants: list[UserPublicResponse]
    created_at: datetime


class ConversationPageResponse(BaseModel):
    items: list[ConversationResponse]
    next_cursor: str | None


class MessagePageResponse(BaseModel):
    items: list[MessageResponse]
    next_cursor: str | None
