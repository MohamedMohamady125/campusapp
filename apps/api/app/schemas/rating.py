"""Rating & report contracts (spec §4.1 Ratings, Reports)."""

import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field

from app.models.enums import RatingContext, ReportStatus, ReportTargetType


class RatingCreateRequest(BaseModel):
    rated_user_id: uuid.UUID
    context_type: RatingContext
    context_id: uuid.UUID
    stars: int = Field(ge=1, le=5)
    comment: str | None = Field(default=None, max_length=2000)


class RatingResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    rater_id: uuid.UUID
    rated_user_id: uuid.UUID
    context_type: RatingContext
    context_id: uuid.UUID
    stars: int
    comment: str | None
    created_at: datetime


class RatingPageResponse(BaseModel):
    items: list[RatingResponse]
    next_cursor: str | None


class ReportCreateRequest(BaseModel):
    target_type: ReportTargetType
    target_id: uuid.UUID
    reason: str = Field(min_length=3, max_length=2000)


class ReportResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    reporter_id: uuid.UUID
    target_type: ReportTargetType
    target_id: uuid.UUID
    reason: str
    status: ReportStatus
    handled_by_id: uuid.UUID | None
    created_at: datetime


class ReportPageResponse(BaseModel):
    items: list[ReportResponse]
    next_cursor: str | None


class ReportUpdateRequest(BaseModel):
    status: ReportStatus
