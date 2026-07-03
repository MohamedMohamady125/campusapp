"""Listing endpoints (spec §4.1 Listings)."""

import uuid

from fastapi import APIRouter, Depends, Query
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.deps import get_current_user
from app.core.pagination import DEFAULT_PAGE_SIZE, clamp_limit, decode_cursor, encode_cursor
from app.db.session import get_session
from app.integrations.moderation.provider import get_moderation_provider
from app.integrations.storage.provider import get_storage_provider
from app.models import User
from app.models.enums import ListingCategory, ListingCondition
from app.repositories.listing_repo import ListingRepository
from app.schemas.listing import (
    ImageUploadUrlResponse,
    ListingCreateRequest,
    ListingPageResponse,
    ListingResponse,
    ListingUpdateRequest,
)
from app.services.listing_service import ListingService

router = APIRouter(prefix="/listings", tags=["listings"])


def _service(session: AsyncSession = Depends(get_session)) -> ListingService:
    return ListingService(session, get_storage_provider(), get_moderation_provider())


@router.get("", response_model=ListingPageResponse)
async def list_listings(
    q: str | None = Query(default=None, max_length=100),
    category: ListingCategory | None = None,
    condition: ListingCondition | None = None,
    min_price: int | None = Query(default=None, ge=0),
    max_price: int | None = Query(default=None, ge=0),
    cursor: str | None = None,
    limit: int = Query(default=DEFAULT_PAGE_SIZE, ge=1, le=50),
    _: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> ListingPageResponse:
    repo = ListingRepository(session)
    limit = clamp_limit(limit)
    listings = await repo.search(
        query=q,
        category=category,
        condition=condition,
        min_price_cents=min_price,
        max_price_cents=max_price,
        cursor=decode_cursor(cursor) if cursor else None,
        limit=limit + 1,
    )
    has_more = len(listings) > limit
    listings = listings[:limit]
    next_cursor = (
        encode_cursor(listings[-1].created_at, listings[-1].id)
        if has_more and not q  # ranked search is not keyset-pageable
        else None
    )
    return ListingPageResponse(
        items=[ListingResponse.model_validate(x) for x in listings],
        next_cursor=next_cursor,
    )


@router.post("", response_model=ListingResponse, status_code=201)
async def create_listing(
    body: ListingCreateRequest,
    user: User = Depends(get_current_user),
    svc: ListingService = Depends(_service),
) -> ListingResponse:
    return ListingResponse.model_validate(await svc.create(seller=user, body=body))


@router.get("/{listing_id}", response_model=ListingResponse)
async def get_listing(
    listing_id: uuid.UUID,
    _: User = Depends(get_current_user),
    svc: ListingService = Depends(_service),
) -> ListingResponse:
    return ListingResponse.model_validate(await svc.get(listing_id))


@router.patch("/{listing_id}", response_model=ListingResponse)
async def update_listing(
    listing_id: uuid.UUID,
    body: ListingUpdateRequest,
    user: User = Depends(get_current_user),
    svc: ListingService = Depends(_service),
) -> ListingResponse:
    return ListingResponse.model_validate(
        await svc.update(listing_id=listing_id, user=user, body=body)
    )


@router.delete("/{listing_id}", status_code=204)
async def delete_listing(
    listing_id: uuid.UUID,
    user: User = Depends(get_current_user),
    svc: ListingService = Depends(_service),
) -> None:
    await svc.soft_delete(listing_id=listing_id, user=user)


@router.post("/{listing_id}/mark-sold", response_model=ListingResponse)
async def mark_sold(
    listing_id: uuid.UUID,
    user: User = Depends(get_current_user),
    svc: ListingService = Depends(_service),
) -> ListingResponse:
    return ListingResponse.model_validate(await svc.mark_sold(listing_id=listing_id, user=user))


class ImageUploadUrlRequest(BaseModel):
    content_type: str


@router.post("/{listing_id}/image-upload-url", response_model=ImageUploadUrlResponse)
async def image_upload_url(
    listing_id: uuid.UUID,
    body: ImageUploadUrlRequest,
    user: User = Depends(get_current_user),
    svc: ListingService = Depends(_service),
) -> ImageUploadUrlResponse:
    signed, image = await svc.create_image_upload(
        listing_id=listing_id, user=user, content_type=body.content_type
    )
    return ImageUploadUrlResponse(
        upload_url=signed.url, fields=signed.fields, image_id=image.id, key=signed.key
    )
