"""Food run contracts (food-runs spec)."""

import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field

from app.models.enums import FoodSpotCategory, RunOrderStatus, RunStatus
from app.schemas.user import PaymentMethod


class FoodSpotResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    name: str
    category: FoodSpotCategory
    description: str | None
    # Destination coordinates for the live map (null if the spot isn't geocoded).
    lat: float | None = None
    lng: float | None = None
    # Hero photo for feed cards / run detail (null → monogram fallback).
    image_url: str | None = None


class FoodSpotCreateRequest(BaseModel):
    """Admin-only: add a campus/off-campus destination to the catalog."""

    name: str = Field(min_length=2, max_length=120)
    category: FoodSpotCategory = FoodSpotCategory.campus
    description: str | None = Field(default=None, max_length=200)
    lat: float | None = Field(default=None, ge=-90, le=90)
    lng: float | None = Field(default=None, ge=-180, le=180)
    image_url: str | None = Field(default=None, max_length=500)


class DropoffLocationResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    name: str
    description: str | None
    # Coordinates for the runner's multi-stop navigation (null if not geocoded).
    lat: float | None = None
    lng: float | None = None


class DropoffLocationCreateRequest(BaseModel):
    """Admin-only: add a valid drop-off point (dorm hall, landmark)."""

    name: str = Field(min_length=2, max_length=120)
    description: str | None = Field(default=None, max_length=200)
    lat: float | None = Field(default=None, ge=-90, le=90)
    lng: float | None = Field(default=None, ge=-180, le=180)


class RunLocation(BaseModel):
    """The runner's last-known live position, plus when it was reported."""

    lat: float
    lng: float
    updated_at: datetime


class RunCreateRequest(BaseModel):
    food_spot_id: uuid.UUID
    note: str | None = Field(default=None, max_length=500)
    leaving_at: datetime
    fee_cents: int = Field(default=0, ge=0, le=2000)
    spots_max: int = Field(default=3, ge=1, le=10)
    prepay_required: bool = False
    # Pay-on-handoff methods for non-prepay runs: any mix of "cash" and the
    # runner's saved PaymentMethodType values (validated in the service).
    payment_prefs: list[str] = Field(default_factory=list, max_length=6)


class RunUserSummary(BaseModel):
    """Trust card shown on every run/order: identity + portable reputation."""

    id: uuid.UUID
    display_name: str
    reputation_score: float
    rating_count: int
    # Payment rails, revealed only to accepted requesters + the runner
    # (empty for passers-by). See run_service.run_response.
    payment_methods: list[PaymentMethod] = []


class RunOrderResponse(BaseModel):
    id: uuid.UUID
    run_id: uuid.UUID
    requester: RunUserSummary
    order_text: str
    # Where this requester wants their food — name of the picked drop-off.
    dropoff: str
    # Drop-off coordinates for the runner's navigation (null if not geocoded).
    dropoff_lat: float | None = None
    dropoff_lng: float | None = None
    status: RunOrderStatus
    created_at: datetime
    # Off-app payment proof (spec: app never moves money). After the runner
    # accepts, the requester pays via the revealed handle and can attach a
    # transaction screenshot + note. Null until submitted; the runner sees it
    # on the order card, the requester sees it on their own order.
    payment_proof_url: str | None = None
    payment_note: str | None = None
    payment_submitted_at: datetime | None = None
    # No-show counter: set when the runner taps "I'm here" at this drop-off.
    # Both apps render a live 5-minute countdown from this stamp; the server
    # refuses no-show until NO_SHOW_WAIT has elapsed past it.
    arrived_at: datetime | None = None
    # Server-authoritative "the viewer already rated this order" flag (ratings
    # are unique per rater+order). The client greys out its Rate CTA on this —
    # it must never guess from local state (QA M-05: Rate stayed active).
    rated_by_me: bool = False


class RunResponse(BaseModel):
    id: uuid.UUID
    runner: RunUserSummary
    # Server-authoritative "the viewer IS this run's runner" flag. The client
    # must never derive this by comparing ids (a not-yet-loaded profile made
    # runners see requester CTAs like "Attach my order").
    is_mine: bool = False
    food_spot: FoodSpotResponse
    note: str | None
    leaving_at: datetime
    fee_cents: int
    spots_max: int
    prepay_required: bool
    # How the runner wants to be paid on handoff (non-prepay runs): any mix
    # of "cash" and PaymentMethodType values; empty on prepay runs.
    payment_prefs: list[str] = []
    status: RunStatus
    accepted_count: int
    pending_count: int
    created_at: datetime
    # Only for the runner: every order. Requesters/visitors get [] here.
    orders: list[RunOrderResponse] = []
    # Only for a requester: their own order on this run.
    my_order: RunOrderResponse | None = None
    # Runner's live position — revealed only to the runner + accepted requesters
    # while the run is active. Null for everyone else (privacy gate).
    runner_location: RunLocation | None = None


class RunPageResponse(BaseModel):
    items: list[RunResponse]
    next_cursor: str | None


class RunOrderCreateRequest(BaseModel):
    order_text: str = Field(min_length=1, max_length=500)
    # Requester picks a drop-off from the admin-curated catalog (no free text) —
    # the service resolves this to the location's name stored on the order.
    dropoff_location_id: uuid.UUID


class PaymentProofUploadUrlRequest(BaseModel):
    """Requester asks for a signed URL to upload the transaction screenshot."""

    content_type: str


class PaymentProofUploadUrlResponse(BaseModel):
    upload_url: str
    fields: dict[str, str]
    key: str


class PaymentProofSubmitRequest(BaseModel):
    """Requester confirms they paid: the uploaded screenshot key + optional note."""

    proof_key: str = Field(min_length=1, max_length=300)
    note: str | None = Field(default=None, max_length=300)


class RunStatusUpdateRequest(BaseModel):
    status: RunStatus


class RunLocationUpdateRequest(BaseModel):
    """One GPS ping from the runner's device."""

    lat: float = Field(ge=-90, le=90)
    lng: float = Field(ge=-180, le=180)
