"""Food run contracts (food-runs spec)."""

import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field

from app.models.enums import FoodSpotCategory, RunOrderStatus, RunStatus


class FoodSpotResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    name: str
    category: FoodSpotCategory
    description: str | None


class RunCreateRequest(BaseModel):
    food_spot_id: uuid.UUID
    delivery_spot: str = Field(min_length=2, max_length=120)
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
    venmo_handle: str | None = None


class RunOrderResponse(BaseModel):
    id: uuid.UUID
    run_id: uuid.UUID
    requester: RunUserSummary
    order_text: str
    status: RunOrderStatus
    created_at: datetime


class RunResponse(BaseModel):
    id: uuid.UUID
    runner: RunUserSummary
    food_spot: FoodSpotResponse
    delivery_spot: str
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


class RunPageResponse(BaseModel):
    items: list[RunResponse]
    next_cursor: str | None


class RunOrderCreateRequest(BaseModel):
    order_text: str = Field(min_length=1, max_length=500)


class RunStatusUpdateRequest(BaseModel):
    status: RunStatus
