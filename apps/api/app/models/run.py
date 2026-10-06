"""Food run models (food-runs spec).

A run = a student ("runner") walking to a food spot posts the trip; other
students attach orders for a small fee. Coordination happens in an existing
Conversation (context_type='run'); payment is off-app (Venmo); trust comes
from two-way ratings with context_type='run' and context_id=RunOrder.id.
"""

import uuid
from datetime import datetime

from sqlalchemy import (
    Boolean,
    DateTime,
    Enum,
    Float,
    ForeignKey,
    Index,
    Integer,
    String,
    Text,
    UniqueConstraint,
)
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import TimestampedBase
from app.models.enums import FoodSpotCategory, RunOrderStatus, RunStatus
from app.models.user import User


class FoodSpot(TimestampedBase):
    """Seeded catalog of destinations (campus venues + off-campus spots)."""

    __tablename__ = "food_spots"

    name: Mapped[str] = mapped_column(String(120), unique=True, index=True)
    category: Mapped[FoodSpotCategory] = mapped_column(
        Enum(FoodSpotCategory, name="food_spot_category"),
        default=FoodSpotCategory.campus,
    )
    description: Mapped[str | None] = mapped_column(String(200))
    active: Mapped[bool] = mapped_column(Boolean, default=True)
    # Destination coordinates for the live map's target pin. Nullable so a spot
    # can exist without being geocoded; the map simply omits the pin.
    lat: Mapped[float | None] = mapped_column(Float)
    lng: Mapped[float | None] = mapped_column(Float)
    # Hero photo for the spot (feed cards + run detail header). Nullable so a
    # spot can exist without imagery; the app falls back to a monogram tile.
    image_url: Mapped[str | None] = mapped_column(String(500))


class DropoffLocation(TimestampedBase):
    """Admin-curated catalog of valid drop-off points (dorm halls, campus
    landmarks). Requesters pick one from a dropdown when joining a run, so no
    one can type a random/unsafe address — every drop-off is a known place.
    """

    __tablename__ = "dropoff_locations"

    name: Mapped[str] = mapped_column(String(120), unique=True, index=True)
    description: Mapped[str | None] = mapped_column(String(200))
    active: Mapped[bool] = mapped_column(Boolean, default=True)
    # Admin-recorded coordinates powering the runner's multi-stop navigation
    # (route optimization from the runner's live position through each drop-off).
    lat: Mapped[float | None] = mapped_column(Float)
    lng: Mapped[float | None] = mapped_column(Float)


class Run(TimestampedBase):
    __tablename__ = "runs"
    __table_args__ = (Index("ix_runs_status_leaving", "status", "leaving_at"),)

    runner_id: Mapped[uuid.UUID] = mapped_column(
        PG_UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    food_spot_id: Mapped[uuid.UUID] = mapped_column(
        PG_UUID(as_uuid=True), ForeignKey("food_spots.id", ondelete="CASCADE"), index=True
    )
    note: Mapped[str | None] = mapped_column(Text)
    leaving_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    # Runner's per-order fee; payment itself is off-app (Venmo).
    fee_cents: Mapped[int] = mapped_column(Integer, default=0)
    spots_max: Mapped[int] = mapped_column(Integer, default=3)
    prepay_required: Mapped[bool] = mapped_column(Boolean, default=False)
    status: Mapped[RunStatus] = mapped_column(
        Enum(RunStatus, name="run_status"), default=RunStatus.open
    )
    completed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    # Runner's last-known live position (Uber/Lyft-style tracking). Pushed by
    # the runner's device while the run is active; exposed only to accepted
    # requesters (see run_service.run_response). Null until the runner shares.
    runner_lat: Mapped[float | None] = mapped_column(Float)
    runner_lng: Mapped[float | None] = mapped_column(Float)
    location_updated_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))

    runner: Mapped[User] = relationship()
    food_spot: Mapped[FoodSpot] = relationship()
    orders: Mapped[list["RunOrder"]] = relationship(
        back_populates="run", cascade="all, delete-orphan"
    )


class RunOrder(TimestampedBase):
    __tablename__ = "run_orders"
    __table_args__ = (
        UniqueConstraint("run_id", "requester_id", name="uq_run_order_run_requester"),
    )

    run_id: Mapped[uuid.UUID] = mapped_column(
        PG_UUID(as_uuid=True), ForeignKey("runs.id", ondelete="CASCADE"), index=True
    )
    requester_id: Mapped[uuid.UUID] = mapped_column(
        PG_UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    order_text: Mapped[str] = mapped_column(Text)
    # Where this requester wants their food dropped — a name picked from the
    # admin DropoffLocation catalog, denormalized here so read paths stay flat.
    dropoff: Mapped[str] = mapped_column(String(120))
    # Denormalized coordinates of the picked drop-off, feeding the runner's
    # multi-stop navigation. Null when the chosen location isn't geocoded.
    dropoff_lat: Mapped[float | None] = mapped_column(Float)
    dropoff_lng: Mapped[float | None] = mapped_column(Float)
    status: Mapped[RunOrderStatus] = mapped_column(
        Enum(RunOrderStatus, name="run_order_status"), default=RunOrderStatus.requested
    )
    # Off-app payment proof: after the runner accepts, the requester pays via the
    # revealed handle and can attach a transaction screenshot + optional note.
    # The runner sees it on their order card. The app never moves money.
    payment_proof_key: Mapped[str | None] = mapped_column(String(300))
    payment_note: Mapped[str | None] = mapped_column(String(300))
    payment_submitted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))

    run: Mapped[Run] = relationship(back_populates="orders")
    requester: Mapped[User] = relationship()
