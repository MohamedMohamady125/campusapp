"""Ratings + Bayesian reputation (spec §5.2) and reports (spec §14 M5).

The cached reputation_score is recomputed *inside the rating transaction* so
profiles and seller cards never show a stale score after a new rating lands.
"""

import uuid
from datetime import datetime

from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.errors import BusinessRuleError, ConflictError, NotFoundError
from app.core.scoring import display_reputation
from app.integrations.analytics.base import EVENT_RATING_SUBMITTED
from app.integrations.analytics.provider import get_analytics_provider
from app.models import AuditLog, Listing, Rating, Report, RunOrder, User
from app.models.enums import RatingContext, ReportStatus, RunStatus
from app.repositories.user_repo import UserRepository
from app.schemas.rating import RatingCreateRequest, ReportCreateRequest


class RatingService:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session
        self._users = UserRepository(session)

    async def create(self, *, rater: User, body: RatingCreateRequest) -> Rating:
        if body.rated_user_id == rater.id:
            raise BusinessRuleError("You cannot rate yourself.", code="SELF_RATING")
        rated = await self._users.get_by_id(body.rated_user_id)
        if rated is None:
            raise NotFoundError("User not found.", code="USER_NOT_FOUND")
        await self._validate_context(body, rater_id=rater.id)

        duplicate = (
            await self._session.execute(
                select(Rating.id).where(
                    Rating.rater_id == rater.id,
                    Rating.context_type == body.context_type,
                    Rating.context_id == body.context_id,
                    Rating.deleted_at.is_(None),
                )
            )
        ).scalar_one_or_none()
        if duplicate is not None:
            raise ConflictError("You already rated this transaction.", code="ALREADY_RATED")

        rating = Rating(
            rater_id=rater.id,
            rated_user_id=rated.id,
            context_type=body.context_type,
            context_id=body.context_id,
            stars=body.stars,
            comment=body.comment,
        )
        self._session.add(rating)
        await self._session.flush()

        # Recompute cached score in the same transaction as the insert.
        rated_sum, rated_n = (
            await self._session.execute(
                select(func.coalesce(func.sum(Rating.stars), 0), func.count(Rating.id)).where(
                    Rating.rated_user_id == rated.id, Rating.deleted_at.is_(None)
                )
            )
        ).one()
        # User-visible score is the plain average (see scoring.display_reputation).
        rated.reputation_score = display_reputation(
            ratings_sum=float(rated_sum), ratings_count=int(rated_n)
        )
        rated.rating_count = int(rated_n)
        await get_analytics_provider().track(
            self._session,
            name=EVENT_RATING_SUBMITTED,
            user_id=rater.id,
            properties={"rated_user_id": str(rated.id), "stars": body.stars},
        )
        await self._session.commit()
        await self._session.refresh(rating)
        return rating

    async def _validate_context(self, body: RatingCreateRequest, *, rater_id: uuid.UUID) -> None:
        """The context must reference a real transaction object."""
        if body.context_type == RatingContext.listing:
            exists = (
                await self._session.execute(
                    select(Listing.id).where(
                        Listing.id == body.context_id, Listing.deleted_at.is_(None)
                    )
                )
            ).scalar_one_or_none()
            if exists is None:
                raise NotFoundError("Listing not found.", code="LISTING_NOT_FOUND")
        elif body.context_type == RatingContext.run:
            # Food-runs spec: context_id = RunOrder.id; both directions of a
            # completed order (runner ↔ requester) may rate exactly once each.
            order = (
                (
                    await self._session.execute(
                        select(RunOrder)
                        .where(RunOrder.id == body.context_id)
                        .options(selectinload(RunOrder.run))
                    )
                )
                .scalars()
                .first()
            )
            if order is None:
                raise NotFoundError("Run order not found.", code="ORDER_NOT_FOUND")
            if order.run.status != RunStatus.done:
                raise BusinessRuleError(
                    "You can rate only after the run is done.", code="RUN_NOT_COMPLETED"
                )
            parties = {order.run.runner_id, order.requester_id}
            if rater_id not in parties or body.rated_user_id not in parties:
                raise BusinessRuleError(
                    "Only the runner and requester on this order can rate each other.",
                    code="INVALID_RATING_PARTY",
                )
        # tutoring context references a tutor offering — validated in M6 when
        # offerings gain endpoints; existence of the rated tutor is checked above.

    async def list_for_user(
        self,
        *,
        user_id: uuid.UUID,
        cursor: tuple[datetime, uuid.UUID] | None,
        limit: int,
    ) -> list[Rating]:
        stmt = (
            select(Rating)
            .where(Rating.rated_user_id == user_id, Rating.deleted_at.is_(None))
            .order_by(Rating.created_at.desc(), Rating.id.desc())
        )
        if cursor is not None:
            ts, rid = cursor
            stmt = stmt.where(
                or_(
                    Rating.created_at < ts,
                    (Rating.created_at == ts) & (Rating.id < rid),
                )
            )
        result = await self._session.execute(stmt.limit(limit))
        return list(result.scalars())


class ReportService:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def create(self, *, reporter: User, body: ReportCreateRequest) -> Report:
        report = Report(
            reporter_id=reporter.id,
            target_type=body.target_type,
            target_id=body.target_id,
            reason=body.reason,
        )
        self._session.add(report)
        await self._session.commit()
        await self._session.refresh(report)
        return report

    async def list_reports(
        self,
        *,
        cursor: tuple[datetime, uuid.UUID] | None,
        limit: int,
    ) -> list[Report]:
        stmt = select(Report).order_by(Report.created_at.desc(), Report.id.desc())
        if cursor is not None:
            ts, rid = cursor
            stmt = stmt.where(
                or_(
                    Report.created_at < ts,
                    (Report.created_at == ts) & (Report.id < rid),
                )
            )
        result = await self._session.execute(stmt.limit(limit))
        return list(result.scalars())

    async def update_status(
        self, *, report_id: uuid.UUID, moderator: User, status: ReportStatus
    ) -> Report:
        """Moderation action — always audit-logged (spec §3, §8)."""
        report = await self._session.get(Report, report_id)
        if report is None:
            raise NotFoundError("Report not found.", code="REPORT_NOT_FOUND")
        report.status = status
        report.handled_by_id = moderator.id
        self._session.add(
            AuditLog(
                actor_id=moderator.id,
                action=f"report.{status}",
                target_type="report",
                target_id=report.id,
                metadata_={"report_target_type": str(report.target_type)},
            )
        )
        await self._session.commit()
        await self._session.refresh(report)
        return report
