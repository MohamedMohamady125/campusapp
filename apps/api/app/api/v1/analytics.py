"""Behavioural analytics: client event ingest + admin insights (spec §12).

Ingest is deliberately dumb and fast — validate, fold client context into
JSONB, bulk-insert, 204. All the thinking happens at read time in
/admin/behavior, which answers: which screens do students live on, how
long do they stay, and what actions do they actually take?
"""

from datetime import UTC, date, datetime, timedelta

from fastapi import APIRouter, Depends, Query, Response
from pydantic import BaseModel
from sqlalchemy import Date, Numeric, cast, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.deps import get_current_user, require_role
from app.db.session import get_session
from app.models import AnalyticsEvent, User
from app.models.enums import UserRole
from app.schemas.analytics import ClientEventBatchRequest

router = APIRouter(tags=["analytics"])

# Keep raw names the client can't spoof into server-event namespaces.
_CLIENT_NAME_PREFIX = "app."


@router.post("/analytics/events", status_code=204)
async def ingest_events(
    payload: ClientEventBatchRequest,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> Response:
    rows = []
    for event in payload.events:
        name = event.name if event.name.startswith(_CLIENT_NAME_PREFIX) else f"app.{event.name}"
        properties: dict[str, object] = {
            **event.properties,
            "session_id": payload.session_id,
            "platform": payload.platform,
            "occurred_at": event.occurred_at.isoformat(),
        }
        if event.screen is not None:
            properties["screen"] = event.screen
        if event.duration_ms is not None:
            properties["duration_ms"] = event.duration_ms
        rows.append(AnalyticsEvent(name=name[:60], user_id=user.id, properties=properties))
    session.add_all(rows)
    await session.commit()
    return Response(status_code=204)


class ScreenStat(BaseModel):
    screen: str
    views: int
    unique_users: int
    avg_seconds: float
    total_minutes: float


class EventStat(BaseModel):
    name: str
    count: int
    unique_users: int


class BehaviorDay(BaseModel):
    day: date
    active_users: int
    sessions: int
    events: int


class BehaviorResponse(BaseModel):
    days: int
    screens: list[ScreenStat]
    top_events: list[EventStat]
    daily: list[BehaviorDay]


@router.get("/admin/behavior", response_model=BehaviorResponse)
async def admin_behavior(
    days: int = Query(default=14, ge=1, le=90),
    _: User = require_role(UserRole.moderator, UserRole.admin),
    session: AsyncSession = Depends(get_session),
) -> BehaviorResponse:
    since = datetime.now(UTC) - timedelta(days=days)
    screen_col = AnalyticsEvent.properties["screen"].astext
    duration_col = func.coalesce(cast(AnalyticsEvent.properties["duration_ms"].astext, Numeric), 0)

    screen_rows = (
        await session.execute(
            select(
                screen_col.label("screen"),
                func.count().label("views"),
                func.count(func.distinct(AnalyticsEvent.user_id)).label("unique_users"),
                func.avg(duration_col).label("avg_ms"),
                func.sum(duration_col).label("total_ms"),
            )
            .where(
                AnalyticsEvent.name == "app.screen_view",
                AnalyticsEvent.created_at >= since,
                screen_col.is_not(None),
            )
            .group_by(screen_col)
            .order_by(func.count().desc())
            .limit(40)
        )
    ).all()

    event_rows = (
        await session.execute(
            select(
                AnalyticsEvent.name,
                func.count().label("total"),
                func.count(func.distinct(AnalyticsEvent.user_id)).label("unique_users"),
            )
            .where(
                AnalyticsEvent.created_at >= since,
                AnalyticsEvent.name != "app.screen_view",
            )
            .group_by(AnalyticsEvent.name)
            .order_by(func.count().desc())
            .limit(30)
        )
    ).all()

    day_col = cast(AnalyticsEvent.created_at, Date)
    daily_rows = (
        await session.execute(
            select(
                day_col.label("day"),
                func.count(func.distinct(AnalyticsEvent.user_id)).label("active_users"),
                func.count(func.distinct(AnalyticsEvent.properties["session_id"].astext)).label(
                    "sessions"
                ),
                func.count().label("events"),
            )
            .where(AnalyticsEvent.created_at >= since)
            .group_by(day_col)
            .order_by(day_col.desc())
        )
    ).all()

    return BehaviorResponse(
        days=days,
        screens=[
            ScreenStat(
                screen=r.screen,
                views=int(r.views),
                unique_users=int(r.unique_users),
                avg_seconds=round(float(r.avg_ms or 0) / 1000, 1),
                total_minutes=round(float(r.total_ms or 0) / 60_000, 1),
            )
            for r in screen_rows
        ],
        top_events=[
            EventStat(name=r.name, count=int(r.total), unique_users=int(r.unique_users))
            for r in event_rows
        ],
        daily=[
            BehaviorDay(
                day=r.day,
                active_users=int(r.active_users),
                sessions=int(r.sessions),
                events=int(r.events),
            )
            for r in daily_rows
        ],
    )
