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
    # Runner will buy on their own dining dollars (surplus meal-plan balance);
    # requesters still reimburse via Venmo. Dining dollars are non-transferable.
    pays_with_dining_dollars: bool = False


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
    # Where this requester wants their food — their hall / dorm / spot.
    dropoff: str
    status: RunOrderStatus
    created_at: datetime


class RunResponse(BaseModel):
    id: uuid.UUID
    runner: RunUserSummary
    food_spot: FoodSpotResponse
    note: str | None
    leaving_at: datetime
    fee_cents: int
    spots_max: int
    prepay_required: bool
    pays_with_dining_dollars: bool
    status: RunStatus
    conversation_id: uuid.UUID | None
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
    # Requester's own drop-off — which hall / dorm / spot to bring it to.
    dropoff: str = Field(min_length=2, max_length=120)


class RunStatusUpdateRequest(BaseModel):
    status: RunStatus


class RunLocationUpdateRequest(BaseModel):
    """One GPS ping from the runner's device."""

    lat: float = Field(ge=-90, le=90)
    lng: float = Field(ge=-180, le=180)
