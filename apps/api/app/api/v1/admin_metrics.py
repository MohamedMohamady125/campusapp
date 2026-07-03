"""Admin metrics endpoint (spec §12): feeds the /admin dashboard (Flutter-web, role-gated)."""

from datetime import UTC, date, datetime, timedelta

from fastapi import APIRouter, Depends, Query
from pydantic import BaseModel, ConfigDict
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.deps import require_role
from app.db.session import get_session
from app.models import DailyMetric, Listing, Message, User
from app.models.enums import ListingStatus, UserRole

router = APIRouter(prefix="/admin", tags=["admin"])


class DailyMetricItem(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    day: date
    name: str
    value: float


class MetricsResponse(BaseModel):
    totals: dict[str, int]
    daily: list[DailyMetricItem]


@router.get("/metrics", response_model=MetricsResponse)
async def admin_metrics(
    days: int = Query(default=14, ge=1, le=90),
    _: User = require_role(UserRole.moderator, UserRole.admin),
    session: AsyncSession = Depends(get_session),
) -> MetricsResponse:
    since = datetime.now(UTC).date() - timedelta(days=days)
    daily = (
        (
            await session.execute(
                select(DailyMetric)
                .where(DailyMetric.day >= since)
                .order_by(DailyMetric.day.desc(), DailyMetric.name)
            )
        )
        .scalars()
        .all()
    )
    users_total = (await session.execute(select(func.count(User.id)))).scalar_one()
    listings_active = (
        await session.execute(
            select(func.count(Listing.id)).where(
                Listing.status == ListingStatus.active, Listing.deleted_at.is_(None)
            )
        )
    ).scalar_one()
    messages_total = (await session.execute(select(func.count(Message.id)))).scalar_one()
    return MetricsResponse(
        totals={
            "users": int(users_total),
            "active_listings": int(listings_active),
            "messages": int(messages_total),
        },
        daily=[DailyMetricItem.model_validate(m) for m in daily],
    )
