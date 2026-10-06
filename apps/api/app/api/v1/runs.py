"""Food run endpoints (food-runs spec)."""

import base64
import uuid
from datetime import UTC, datetime

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.deps import get_current_user, require_role
from app.core.pagination import DEFAULT_PAGE_SIZE, clamp_limit
from app.db.session import get_session
from app.integrations.storage.provider import get_storage_provider
from app.models import User
from app.models.enums import UserRole
from app.repositories.run_repo import RunRepository
from app.schemas.run import (
    DropoffLocationCreateRequest,
    DropoffLocationResponse,
    FoodSpotCreateRequest,
    FoodSpotResponse,
    PaymentProofSubmitRequest,
    PaymentProofUploadUrlRequest,
    PaymentProofUploadUrlResponse,
    RunCreateRequest,
    RunLocationUpdateRequest,
    RunOrderCreateRequest,
    RunPageResponse,
    RunResponse,
    RunStatusUpdateRequest,
)
from app.services.run_service import RunService, run_response

router = APIRouter(prefix="/runs", tags=["runs"])


def _service(session: AsyncSession = Depends(get_session)) -> RunService:
    return RunService(session, get_storage_provider())


def _encode_feed_cursor(ts: datetime, oid: uuid.UUID) -> str:
    """Feed pages ascend on (leaving_at, id) — soonest departure first — so the
    shared created_at-desc cursor helpers don't apply; same base64 shape though."""
    raw = f"{ts.isoformat()}|{oid}"
    return base64.urlsafe_b64encode(raw.encode()).decode()


def _decode_feed_cursor(cursor: str) -> tuple[datetime, uuid.UUID] | None:
    try:
        raw = base64.urlsafe_b64decode(cursor.encode()).decode()
        ts_str, oid_str = raw.split("|", 1)
        return datetime.fromisoformat(ts_str), uuid.UUID(oid_str)
    except (ValueError, UnicodeDecodeError):
        return None


@router.get("/spots", response_model=list[FoodSpotResponse])
async def list_spots(
    _: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> list[FoodSpotResponse]:
    spots = await RunRepository(session).list_spots()
    return [FoodSpotResponse.model_validate(s) for s in spots]


@router.post("/spots", response_model=FoodSpotResponse, status_code=201)
async def create_spot(
    body: FoodSpotCreateRequest,
    _: User = require_role(UserRole.admin),
    svc: RunService = Depends(_service),
) -> FoodSpotResponse:
    """Admin-only: add a campus/off-campus food spot to the catalog."""
    spot = await svc.create_spot(body=body)
    return FoodSpotResponse.model_validate(spot)


@router.get("/dropoffs", response_model=list[DropoffLocationResponse])
async def list_dropoffs(
    _: User = Depends(get_current_user),
    svc: RunService = Depends(_service),
) -> list[DropoffLocationResponse]:
    """Valid drop-off points requesters choose from when joining a run."""
    locations = await svc.list_dropoffs()
    return [DropoffLocationResponse.model_validate(loc) for loc in locations]


@router.post("/dropoffs", response_model=DropoffLocationResponse, status_code=201)
async def create_dropoff(
    body: DropoffLocationCreateRequest,
    _: User = require_role(UserRole.admin),
    svc: RunService = Depends(_service),
) -> DropoffLocationResponse:
    """Admin-only: add a valid drop-off point (dorm hall, landmark)."""
    location = await svc.create_dropoff(body=body)
    return DropoffLocationResponse.model_validate(location)


@router.get("", response_model=RunPageResponse)
async def run_feed(
    cursor: str | None = None,
    limit: int = Query(default=DEFAULT_PAGE_SIZE, ge=1, le=50),
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> RunPageResponse:
    limit = clamp_limit(limit)
    runs = await RunRepository(session).feed(
        now=datetime.now(UTC),
        cursor=_decode_feed_cursor(cursor) if cursor else None,
        limit=limit + 1,
    )
    has_more = len(runs) > limit
    runs = runs[:limit]
    next_cursor = (
        _encode_feed_cursor(runs[-1].leaving_at, runs[-1].id) if has_more and runs else None
    )
    return RunPageResponse(
        items=[run_response(r, viewer_id=user.id) for r in runs],
        next_cursor=next_cursor,
    )


@router.get("/mine", response_model=RunPageResponse)
async def my_runs(
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> RunPageResponse:
    runs = await RunRepository(session).list_mine(user_id=user.id)
    return RunPageResponse(
        items=[run_response(r, viewer_id=user.id) for r in runs],
        next_cursor=None,
    )


@router.get("/{run_id}", response_model=RunResponse)
async def get_run(
    run_id: uuid.UUID,
    user: User = Depends(get_current_user),
    svc: RunService = Depends(_service),
) -> RunResponse:
    run = await svc.get_run(run_id)
    # Detail is where Rate CTAs live — mark orders the viewer already rated
    # so the client can grey them out (QA M-05). List endpoints skip this
    # extra query; they never render a Rate button.
    rated = await svc.rated_order_ids(run=run, rater_id=user.id)
    return run_response(run, viewer_id=user.id, rated_order_ids=rated)


@router.post("", response_model=RunResponse, status_code=201)
async def create_run(
    body: RunCreateRequest,
    user: User = Depends(get_current_user),
    svc: RunService = Depends(_service),
) -> RunResponse:
    run = await svc.create_run(runner=user, body=body)
    return run_response(run, viewer_id=user.id)


@router.post("/{run_id}/orders", response_model=RunResponse, status_code=201)
async def request_spot(
    run_id: uuid.UUID,
    body: RunOrderCreateRequest,
    user: User = Depends(get_current_user),
    svc: RunService = Depends(_service),
) -> RunResponse:
    run = await svc.request_spot(
        run_id=run_id,
        user=user,
        order_text=body.order_text,
        dropoff_location_id=body.dropoff_location_id,
    )
    return run_response(run, viewer_id=user.id)


@router.delete("/{run_id}/orders/{order_id}", status_code=204)
async def withdraw_order(
    run_id: uuid.UUID,
    order_id: uuid.UUID,
    user: User = Depends(get_current_user),
    svc: RunService = Depends(_service),
) -> None:
    await svc.withdraw_order(run_id=run_id, order_id=order_id, user=user)


@router.post("/{run_id}/orders/{order_id}/accept", response_model=RunResponse)
async def accept_order(
    run_id: uuid.UUID,
    order_id: uuid.UUID,
    user: User = Depends(get_current_user),
    svc: RunService = Depends(_service),
) -> RunResponse:
    run = await svc.accept_order(run_id=run_id, order_id=order_id, actor=user)
    return run_response(run, viewer_id=user.id)


@router.post("/{run_id}/orders/{order_id}/decline", response_model=RunResponse)
async def decline_order(
    run_id: uuid.UUID,
    order_id: uuid.UUID,
    user: User = Depends(get_current_user),
    svc: RunService = Depends(_service),
) -> RunResponse:
    run = await svc.decline_order(run_id=run_id, order_id=order_id, actor=user)
    return run_response(run, viewer_id=user.id)


@router.post(
    "/{run_id}/orders/{order_id}/payment-proof-upload-url",
    response_model=PaymentProofUploadUrlResponse,
)
async def payment_proof_upload_url(
    run_id: uuid.UUID,
    order_id: uuid.UUID,
    body: PaymentProofUploadUrlRequest,
    user: User = Depends(get_current_user),
    svc: RunService = Depends(_service),
) -> PaymentProofUploadUrlResponse:
    """Requester gets a signed URL to upload their transaction screenshot."""
    signed = await svc.create_payment_proof_upload(
        run_id=run_id, order_id=order_id, user=user, content_type=body.content_type
    )
    return PaymentProofUploadUrlResponse(
        upload_url=signed.url, fields=signed.fields, key=signed.key
    )


@router.post("/{run_id}/orders/{order_id}/payment-proof", response_model=RunResponse)
async def submit_payment_proof(
    run_id: uuid.UUID,
    order_id: uuid.UUID,
    body: PaymentProofSubmitRequest,
    user: User = Depends(get_current_user),
    svc: RunService = Depends(_service),
) -> RunResponse:
    """Requester confirms off-app payment; proof surfaces on the runner's card."""
    run = await svc.submit_payment_proof(
        run_id=run_id, order_id=order_id, user=user, proof_key=body.proof_key, note=body.note
    )
    return run_response(run, viewer_id=user.id)


@router.post("/{run_id}/status", response_model=RunResponse)
async def update_status(
    run_id: uuid.UUID,
    body: RunStatusUpdateRequest,
    user: User = Depends(get_current_user),
    svc: RunService = Depends(_service),
) -> RunResponse:
    run = await svc.update_status(run_id=run_id, actor=user, status=body.status)
    return run_response(run, viewer_id=user.id)


@router.post("/{run_id}/location", response_model=RunResponse)
async def update_location(
    run_id: uuid.UUID,
    body: RunLocationUpdateRequest,
    user: User = Depends(get_current_user),
    svc: RunService = Depends(_service),
) -> RunResponse:
    run = await svc.update_location(run_id=run_id, actor=user, lat=body.lat, lng=body.lng)
    return run_response(run, viewer_id=user.id)


@router.post("/{run_id}/cancel", response_model=RunResponse)
async def cancel_run(
    run_id: uuid.UUID,
    user: User = Depends(get_current_user),
    svc: RunService = Depends(_service),
) -> RunResponse:
    run = await svc.cancel_run(run_id=run_id, actor=user)
    return run_response(run, viewer_id=user.id)


@router.post("/{run_id}/orders/{order_id}/delivered", response_model=RunResponse)
async def mark_delivered(
    run_id: uuid.UUID,
    order_id: uuid.UUID,
    user: User = Depends(get_current_user),
    svc: RunService = Depends(_service),
) -> RunResponse:
    run = await svc.mark_delivered(run_id=run_id, order_id=order_id, actor=user)
    return run_response(run, viewer_id=user.id)


@router.post("/{run_id}/orders/{order_id}/received", response_model=RunResponse)
async def confirm_received(
    run_id: uuid.UUID,
    order_id: uuid.UUID,
    user: User = Depends(get_current_user),
    svc: RunService = Depends(_service),
) -> RunResponse:
    run = await svc.confirm_received(run_id=run_id, order_id=order_id, user=user)
    return run_response(run, viewer_id=user.id)


@router.post("/{run_id}/orders/{order_id}/no-show", response_model=RunResponse)
async def mark_no_show(
    run_id: uuid.UUID,
    order_id: uuid.UUID,
    user: User = Depends(get_current_user),
    svc: RunService = Depends(_service),
) -> RunResponse:
    run = await svc.mark_no_show(run_id=run_id, order_id=order_id, actor=user)
    return run_response(run, viewer_id=user.id)
