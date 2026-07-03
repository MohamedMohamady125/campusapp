"""Marketplace business logic (spec §14 M4): ownership, moderation gate, expiry."""

import uuid
from datetime import UTC, datetime, timedelta

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import BusinessRuleError, ForbiddenError, NotFoundError, ValidationAppError
from app.integrations.moderation.base import ModerationProvider, ModerationVerdict
from app.integrations.storage.base import ALLOWED_CONTENT_TYPES, SignedUpload, StorageProvider
from app.models import Listing, ListingImage, User
from app.models.enums import ListingStatus, ModerationStatus
from app.repositories.listing_repo import ListingRepository
from app.schemas.listing import ListingCreateRequest, ListingUpdateRequest

LISTING_TTL_DAYS = 90  # spec §3
MAX_IMAGES_PER_LISTING = 8


class ListingService:
    def __init__(
        self,
        session: AsyncSession,
        storage: StorageProvider,
        moderation: ModerationProvider,
    ) -> None:
        self._session = session
        self._repo = ListingRepository(session)
        self._storage = storage
        self._moderation = moderation

    async def create(self, *, seller: User, body: ListingCreateRequest) -> Listing:
        listing = Listing(
            seller_id=seller.id,
            title=body.title,
            description=body.description,
            price_cents=body.price_cents,
            category=body.category,
            condition=body.condition,
            expires_at=datetime.now(UTC) + timedelta(days=LISTING_TTL_DAYS),
        )
        self._repo.add(listing)
        await self._session.commit()
        return await self._get_or_404(listing.id)

    async def _get_or_404(self, listing_id: uuid.UUID) -> Listing:
        listing = await self._repo.get(listing_id)
        if listing is None:
            raise NotFoundError("Listing not found.", code="LISTING_NOT_FOUND")
        return listing

    async def get(self, listing_id: uuid.UUID) -> Listing:
        return await self._get_or_404(listing_id)

    def _assert_owner(self, listing: Listing, user: User) -> None:
        """Ownership check on every mutation (spec §8 AuthZ)."""
        if listing.seller_id != user.id:
            raise ForbiddenError("You can only modify your own listings.", code="NOT_OWNER")

    async def update(
        self, *, listing_id: uuid.UUID, user: User, body: ListingUpdateRequest
    ) -> Listing:
        listing = await self._get_or_404(listing_id)
        self._assert_owner(listing, user)
        for field, value in body.model_dump(exclude_unset=True).items():
            setattr(listing, field, value)
        await self._session.commit()
        return await self._get_or_404(listing_id)

    async def soft_delete(self, *, listing_id: uuid.UUID, user: User) -> None:
        listing = await self._get_or_404(listing_id)
        self._assert_owner(listing, user)
        listing.deleted_at = datetime.now(UTC)
        listing.status = ListingStatus.removed
        await self._session.commit()

    async def mark_sold(self, *, listing_id: uuid.UUID, user: User) -> Listing:
        listing = await self._get_or_404(listing_id)
        self._assert_owner(listing, user)
        if listing.status != ListingStatus.active:
            raise BusinessRuleError("Only active listings can be marked sold.", code="NOT_ACTIVE")
        listing.status = ListingStatus.sold
        await self._session.commit()
        return await self._get_or_404(listing_id)

    async def create_image_upload(
        self, *, listing_id: uuid.UUID, user: User, content_type: str
    ) -> tuple[SignedUpload, ListingImage]:
        """Signed-URL direct upload; image is moderation-gated before visible (spec §8)."""
        if content_type not in ALLOWED_CONTENT_TYPES:
            raise ValidationAppError(
                "Unsupported image type.",
                code="UNSUPPORTED_CONTENT_TYPE",
                details={"allowed": sorted(ALLOWED_CONTENT_TYPES)},
            )
        listing = await self._get_or_404(listing_id)
        self._assert_owner(listing, user)
        if len(listing.images) >= MAX_IMAGES_PER_LISTING:
            raise BusinessRuleError("Image limit reached.", code="IMAGE_LIMIT")
        ext = content_type.split("/")[-1]
        image = ListingImage(
            listing_id=listing.id,
            s3_key="",
            order=len(listing.images),
            moderation_status=ModerationStatus.pending,
        )
        self._repo.add_image(image)
        await self._session.flush()
        image.s3_key = f"listings/{listing.id}/{image.id}.{ext}"
        signed = await self._storage.create_signed_upload(
            key=image.s3_key, content_type=content_type
        )
        # v1: moderation runs at request time via the provider (stub approves).
        # Real deployments move this to a Celery task on upload-complete webhook.
        verdict = await self._moderation.review_image(key=image.s3_key)
        image.moderation_status = (
            ModerationStatus.approved
            if verdict == ModerationVerdict.approved
            else ModerationStatus.rejected
        )
        await self._session.commit()
        return signed, image
