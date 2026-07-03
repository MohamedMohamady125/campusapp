"""Tutoring contracts (spec §4.1 Tutoring)."""

import uuid
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

from app.schemas.user import UserPublicResponse

Grade = Literal["A+", "A", "A-", "B+", "B", "B-"]


class CourseResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    code: str
    title: str
    department: str


class OfferingCreateRequest(BaseModel):
    course_id: uuid.UUID
    term_taken: str = Field(pattern=r"^\d{4}-(spring|summer|fall)$")
    grade_received: Grade
    blurb: str | None = Field(default=None, max_length=1000)


class OfferingResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    tutor_id: uuid.UUID
    course: CourseResponse
    term_taken: str
    grade_received: str
    blurb: str | None
    active: bool
    created_at: datetime


class RankedTutorResponse(BaseModel):
    tutor: UserPublicResponse
    offering: OfferingResponse
    score: float
    reputation_norm: float
    recency_norm: float
    responsiveness_norm: float


class TutorSearchResponse(BaseModel):
    course: CourseResponse
    items: list[RankedTutorResponse]
