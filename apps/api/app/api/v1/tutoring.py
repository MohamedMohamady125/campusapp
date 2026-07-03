"""Tutoring endpoints (spec §4.1 Tutoring): courses autocomplete, offerings, ranked search."""

import uuid

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.cache import cache_get_json, cache_set_json
from app.core.deps import get_current_user
from app.db.session import get_session
from app.integrations.analytics.base import EVENT_TUTOR_MATCH_VIEWED
from app.integrations.analytics.provider import get_analytics_provider
from app.models import User
from app.repositories.tutoring_repo import TutoringRepository
from app.schemas.tutoring import (
    CourseResponse,
    OfferingCreateRequest,
    OfferingResponse,
    RankedTutorResponse,
    SubscriptionResponse,
    TutorSearchResponse,
)
from app.schemas.user import UserPublicResponse
from app.services.flag_service import is_enabled
from app.services.monetization_service import MonetizationService, has_tutor_premium
from app.services.tutoring_service import TutoringService

router = APIRouter(tags=["tutoring"])

TUTOR_SEARCH_CACHE_TTL_SECONDS = 30  # M8: ranked search is read-heavy; short TTL


def _service(session: AsyncSession = Depends(get_session)) -> TutoringService:
    return TutoringService(session)


@router.get("/courses", response_model=list[CourseResponse])
async def autocomplete_courses(
    q: str = Query(min_length=1, max_length=50),
    _: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> list[CourseResponse]:
    courses = await TutoringRepository(session).autocomplete_courses(q)
    return [CourseResponse.model_validate(c) for c in courses]


@router.post("/tutoring/offerings", response_model=OfferingResponse, status_code=201)
async def create_offering(
    body: OfferingCreateRequest,
    user: User = Depends(get_current_user),
    svc: TutoringService = Depends(_service),
) -> OfferingResponse:
    offering = await svc.create_offering(tutor=user, body=body)
    return OfferingResponse.model_validate(offering)


@router.delete("/tutoring/offerings/{offering_id}", status_code=204)
async def delete_offering(
    offering_id: uuid.UUID,
    user: User = Depends(get_current_user),
    svc: TutoringService = Depends(_service),
) -> None:
    await svc.delete_offering(offering_id=offering_id, user=user)


@router.get("/tutoring/tutors", response_model=TutorSearchResponse)
async def ranked_tutors(
    course: str = Query(min_length=2, max_length=20),
    user: User = Depends(get_current_user),
    svc: TutoringService = Depends(_service),
    session: AsyncSession = Depends(get_session),
) -> TutorSearchResponse:
    await get_analytics_provider().track(
        session, name=EVENT_TUTOR_MATCH_VIEWED, user_id=user.id, properties={"course": course}
    )
    await session.commit()
    cache_key = f"tutors:{course.strip().upper()}"
    cached = await cache_get_json(cache_key)
    if cached is not None:
        return TutorSearchResponse.model_validate(cached)
    matched_course, ranked = await svc.ranked_tutors(course_code=course)
    premium_on = await is_enabled(session, "tutor_premium")
    response = TutorSearchResponse(
        course=CourseResponse.model_validate(matched_course),
        items=[
            RankedTutorResponse(
                tutor=UserPublicResponse.model_validate(offering.tutor),
                offering=OfferingResponse.model_validate(offering),
                score=r.score,
                reputation_norm=r.reputation_norm,
                recency_norm=r.recency_norm,
                responsiveness_norm=r.responsiveness_norm,
                premium=(premium_on and await has_tutor_premium(session, offering.tutor_id)),
            )
            for r, offering in ranked
        ],
    )
    await cache_set_json(
        cache_key, response.model_dump(mode="json"), ttl_seconds=TUTOR_SEARCH_CACHE_TTL_SECONDS
    )
    return response


@router.post("/tutoring/premium/subscription", response_model=SubscriptionResponse, status_code=201)
async def subscribe_tutor_premium(
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> SubscriptionResponse:
    """Tutor premium rail (spec §13.2) — 403 FEATURE_DISABLED while the flag is off."""
    sub = await MonetizationService(session).subscribe_tutor_premium(user=user)
    return SubscriptionResponse.model_validate(sub)


@router.delete("/tutoring/premium/subscription", response_model=SubscriptionResponse)
async def cancel_tutor_premium(
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> SubscriptionResponse:
    sub = await MonetizationService(session).cancel_tutor_premium(user=user)
    return SubscriptionResponse.model_validate(sub)
