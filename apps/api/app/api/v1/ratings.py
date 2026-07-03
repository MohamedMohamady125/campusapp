"""Rating endpoints (spec §4.1 Ratings): POST /ratings, GET /users/{id}/ratings."""

import uuid

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.deps import get_current_user
from app.core.pagination import DEFAULT_PAGE_SIZE, clamp_limit, decode_cursor, encode_cursor
from app.db.session import get_session
from app.models import User
from app.schemas.rating import RatingCreateRequest, RatingPageResponse, RatingResponse
from app.services.rating_service import RatingService

router = APIRouter(tags=["ratings"])


@router.post("/ratings", response_model=RatingResponse, status_code=201)
async def create_rating(
    body: RatingCreateRequest,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> RatingResponse:
    rating = await RatingService(session).create(rater=user, body=body)
    return RatingResponse.model_validate(rating)


@router.get("/users/{user_id}/ratings", response_model=RatingPageResponse)
async def list_user_ratings(
    user_id: uuid.UUID,
    cursor: str | None = None,
    limit: int = Query(default=DEFAULT_PAGE_SIZE, ge=1, le=50),
    _: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> RatingPageResponse:
    limit = clamp_limit(limit)
    ratings = await RatingService(session).list_for_user(
        user_id=user_id,
        cursor=decode_cursor(cursor) if cursor else None,
        limit=limit + 1,
    )
    has_more = len(ratings) > limit
    ratings = ratings[:limit]
    next_cursor = encode_cursor(ratings[-1].created_at, ratings[-1].id) if has_more else None
    return RatingPageResponse(
        items=[RatingResponse.model_validate(r) for r in ratings], next_cursor=next_cursor
    )
