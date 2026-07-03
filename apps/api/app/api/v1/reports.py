"""Report endpoints (spec §4.1 Reports) + admin moderation queue."""

import uuid

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.deps import get_current_user, require_role
from app.core.pagination import DEFAULT_PAGE_SIZE, clamp_limit, decode_cursor, encode_cursor
from app.db.session import get_session
from app.models import User
from app.models.enums import UserRole
from app.schemas.rating import (
    ReportCreateRequest,
    ReportPageResponse,
    ReportResponse,
    ReportUpdateRequest,
)
from app.services.rating_service import ReportService

router = APIRouter(tags=["reports"])


@router.post("/reports", response_model=ReportResponse, status_code=201)
async def create_report(
    body: ReportCreateRequest,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> ReportResponse:
    report = await ReportService(session).create(reporter=user, body=body)
    return ReportResponse.model_validate(report)


@router.get("/admin/reports", response_model=ReportPageResponse)
async def list_reports(
    cursor: str | None = None,
    limit: int = Query(default=DEFAULT_PAGE_SIZE, ge=1, le=50),
    _: User = require_role(UserRole.moderator, UserRole.admin),
    session: AsyncSession = Depends(get_session),
) -> ReportPageResponse:
    limit = clamp_limit(limit)
    reports = await ReportService(session).list_reports(
        cursor=decode_cursor(cursor) if cursor else None, limit=limit + 1
    )
    has_more = len(reports) > limit
    reports = reports[:limit]
    next_cursor = encode_cursor(reports[-1].created_at, reports[-1].id) if has_more else None
    return ReportPageResponse(
        items=[ReportResponse.model_validate(r) for r in reports], next_cursor=next_cursor
    )


@router.patch("/admin/reports/{report_id}", response_model=ReportResponse)
async def update_report(
    report_id: uuid.UUID,
    body: ReportUpdateRequest,
    moderator: User = require_role(UserRole.moderator, UserRole.admin),
    session: AsyncSession = Depends(get_session),
) -> ReportResponse:
    report = await ReportService(session).update_status(
        report_id=report_id, moderator=moderator, status=body.status
    )
    return ReportResponse.model_validate(report)
