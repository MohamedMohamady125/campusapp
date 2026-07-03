"""Marketplace listing models (spec §3, search per §5.3)."""

import uuid
from datetime import datetime

from sqlalchemy import (
    Computed,
    DateTime,
    Enum,
    ForeignKey,
    Index,
    Integer,
    String,
    Text,
)
from sqlalchemy.dialects.postgresql import TSVECTOR
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import TimestampedBase
from app.models.enums import ListingCategory, ListingCondition, ListingStatus, ModerationStatus
from app.models.user import User


class Listing(TimestampedBase):
    __tablename__ = "listings"
    __table_args__ = (
        Index("ix_listings_search_vector", "search_vector", postgresql_using="gin"),
        Index("ix_listings_status_created", "status", "created_at"),
        Index("ix_listings_category_price", "category", "price_cents"),
        # pg_trgm fuzzy index on title (spec §5.3); extension created in migration.
        Index(
            "ix_listings_title_trgm",
            "title",
            postgresql_using="gin",
            postgresql_ops={"title": "gin_trgm_ops"},
        ),
    )

    seller_id: Mapped[uuid.UUID] = mapped_column(
        PG_UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    title: Mapped[str] = mapped_column(String(120))
    description: Mapped[str] = mapped_column(Text)
    price_cents: Mapped[int] = mapped_column(Integer)
    category: Mapped[ListingCategory] = mapped_column(
        Enum(ListingCategory, name="listing_category")
    )
    condition: Mapped[ListingCondition] = mapped_column(
        Enum(ListingCondition, name="listing_condition")
    )
    status: Mapped[ListingStatus] = mapped_column(
        Enum(ListingStatus, name="listing_status"), default=ListingStatus.active
    )
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), index=True)
    # Promoted-listing rail (spec §13.1) — only ranked when flags.promoted_listings is on.
    boosted_until: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    # Generated tsvector column from title + description (spec §5.3).
    search_vector: Mapped[str] = mapped_column(
        TSVECTOR,
        Computed(
            "to_tsvector('english', coalesce(title, '') || ' ' || coalesce(description, ''))",
            persisted=True,
        ),
    )
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))

    seller: Mapped[User] = relationship()
    images: Mapped[list["ListingImage"]] = relationship(
        back_populates="listing", order_by="ListingImage.order", cascade="all, delete-orphan"
    )


class ListingImage(TimestampedBase):
    __tablename__ = "listing_images"

    listing_id: Mapped[uuid.UUID] = mapped_column(
        PG_UUID(as_uuid=True), ForeignKey("listings.id", ondelete="CASCADE"), index=True
    )
    s3_key: Mapped[str] = mapped_column(String(255))
    order: Mapped[int] = mapped_column(Integer, default=0)
    moderation_status: Mapped[ModerationStatus] = mapped_column(
        Enum(ModerationStatus, name="moderation_status"), default=ModerationStatus.pending
    )

    listing: Mapped[Listing] = relationship(back_populates="images")
