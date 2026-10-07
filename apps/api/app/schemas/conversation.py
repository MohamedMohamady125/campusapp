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


class RunChatContext(BaseModel):
    """Order + restaurant summary pinned atop a run chat (both parties)."""

    run_id: uuid.UUID
    order_id: uuid.UUID
    spot_name: str
    spot_image_url: str | None
    order_text: str
    dropoff: str
    fee_cents: int


class ConversationResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    context_type: ConversationContext
    context_id: uuid.UUID | None
    participants: list[UserPublicResponse]
    created_at: datetime
    # Populated on GET-by-id / create for run conversations only; stays None
    # on the list endpoint to keep it one query (no N+1, spec §7.2).
    run_context: RunChatContext | None = None


class ConversationPageResponse(BaseModel):
    items: list[ConversationResponse]
    next_cursor: str | None


class MessagePageResponse(BaseModel):
    items: list[MessageResponse]
    next_cursor: str | None
