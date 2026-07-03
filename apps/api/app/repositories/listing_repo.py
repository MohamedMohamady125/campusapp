"""Listing data access: FTS search, filters, cursor pagination (spec §5.3)."""

import uuid
from datetime import datetime

from sqlalchemy import Select, func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models import Listing, ListingImage
from app.models.enums import ListingCategory, ListingCondition, ListingStatus


class ListingRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    def _base_query(self) -> Select[tuple[Listing]]:
        # selectinload avoids N+1 on seller + images (spec §7.2).
        return (
            select(Listing)
            .options(selectinload(Listing.seller), selectinload(Listing.images))
            .where(Listing.deleted_at.is_(None))
        )

    async def get(self, listing_id: uuid.UUID) -> Listing | None:
        result = await self._session.execute(self._base_query().where(Listing.id == listing_id))
        return result.scalar_one_or_none()

    def add(self, listing: Listing) -> None:
        self._session.add(listing)

    def add_image(self, image: ListingImage) -> None:
        self._session.add(image)

    async def get_image(self, image_id: uuid.UUID) -> ListingImage | None:
        result = await self._session.execute(
            select(ListingImage).where(ListingImage.id == image_id)
        )
        return result.scalar_one_or_none()

    async def search(
        self,
        *,
        query: str | None,
        category: ListingCategory | None,
        condition: ListingCondition | None,
        min_price_cents: int | None,
        max_price_cents: int | None,
        cursor: tuple[datetime, uuid.UUID] | None,
        limit: int,
    ) -> list[Listing]:
        """Filters are SQL WHERE clauses, never post-filtering (spec §5.3).

        With a text query: ts_rank blended with pg_trgm similarity for typo
        tolerance, then recency. Without: pure recency (created_at desc).
        """
        stmt = self._base_query().where(Listing.status == ListingStatus.active)

        if category is not None:
            stmt = stmt.where(Listing.category == category)
        if condition is not None:
            stmt = stmt.where(Listing.condition == condition)
        if min_price_cents is not None:
            stmt = stmt.where(Listing.price_cents >= min_price_cents)
        if max_price_cents is not None:
            stmt = stmt.where(Listing.price_cents <= max_price_cents)

        if query:
            ts_query = func.plainto_tsquery("english", query)
            similarity = func.similarity(Listing.title, query)
            stmt = stmt.where(
                or_(
                    Listing.search_vector.op("@@")(ts_query),
                    similarity > 0.2,
                )
            ).order_by(
                (func.ts_rank(Listing.search_vector, ts_query) + similarity).desc(),
                Listing.created_at.desc(),
                Listing.id.desc(),
            )
            # Ranked search uses simple page slicing; keyset cursor applies to
            # the recency feed where the sort is stable.
            result = await self._session.execute(stmt.limit(limit))
            return list(result.scalars().unique())

        stmt = stmt.order_by(Listing.created_at.desc(), Listing.id.desc())
        if cursor is not None:
            cursor_ts, cursor_id = cursor
            stmt = stmt.where(
                or_(
                    Listing.created_at < cursor_ts,
                    (Listing.created_at == cursor_ts) & (Listing.id < cursor_id),
                )
            )
        result = await self._session.execute(stmt.limit(limit))
        return list(result.scalars().unique())
