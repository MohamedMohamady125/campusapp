"""Food run endpoints (food-runs spec)."""

import base64
import uuid
from datetime import UTC, datetime

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.deps import get_current_user
from app.core.pagination import DEFAULT_PAGE_SIZE, clamp_limit
from app.db.session import get_session
from app.models import User
from app.repositories.run_repo import RunRepository
from app.schemas.run import (
    FoodSpotResponse,
    RunCreateRequest,
    RunOrderCreateRequest,
    RunPageResponse,
    RunResponse,
    RunStatusUpdateRequest,
)
from app.services.run_service import RunService, run_response

router = APIRouter(prefix="/runs", tags=["runs"])


def _service(session: AsyncSession = Depends(get_session)) -> RunService:
    return RunService(session)


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


@router.get("", response_model=RunPageResponse)
async def run_feed(
    cursor: str | None = None,
    limit: int = Query(default=DEFAULT_PAGE_SIZE, ge=1, le=50),
    dining_dollars: bool = Query(
        default=False,
        description="Only runs where the runner pays with dining dollars.",
    ),
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> RunPageResponse:
    limit = clamp_limit(limit)
    runs = await RunRepository(session).feed(
        now=datetime.now(UTC),
        cursor=_decode_feed_cursor(cursor) if cursor else None,
        limit=limit + 1,
        dining_dollars=dining_dollars,
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
    return run_response(run, viewer_id=user.id)


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
    run = await svc.request_spot(run_id=run_id, user=user, order_text=body.order_text)
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


@router.post("/{run_id}/status", response_model=RunResponse)
async def update_status(
    run_id: uuid.UUID,
    body: RunStatusUpdateRequest,
    user: User = Depends(get_current_user),
    svc: RunService = Depends(_service),
) -> RunResponse:
    run = await svc.update_status(run_id=run_id, actor=user, status=body.status)
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
