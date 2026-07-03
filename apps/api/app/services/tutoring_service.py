"""Tutoring business logic (spec §14 M6): offerings + ranked search §5.1."""

import statistics
import uuid
from datetime import UTC, datetime, timedelta

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import ConflictError, ForbiddenError, NotFoundError
from app.models import Course, TutorOffering, User
from app.repositories.tutoring_repo import TutoringRepository
from app.schemas.tutoring import OfferingCreateRequest
from app.services.tutor_ranking import RankedTutor, TutorCandidate, rank_tutors

RESPONSIVENESS_WINDOW_DAYS = 30  # spec §5.1: median reply time over last 30 days


class TutoringService:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session
        self._repo = TutoringRepository(session)

    async def create_offering(self, *, tutor: User, body: OfferingCreateRequest) -> TutorOffering:
        course = await self._repo.get_course(body.course_id)
        if course is None:
            raise NotFoundError("Course not found.", code="COURSE_NOT_FOUND")
        existing = await self._repo.get_offering_for(tutor.id, course.id)
        if existing is not None:
            raise ConflictError(
                "You already offer tutoring for this course.", code="ALREADY_OFFERING"
            )
        offering = TutorOffering(
            tutor_id=tutor.id,
            course_id=course.id,
            term_taken=body.term_taken,
            grade_received=body.grade_received,
            blurb=body.blurb,
        )
        self._repo.add(offering)
        await self._session.commit()
        result = await self._repo.get_offering(offering.id)
        assert result is not None
        return result

    async def delete_offering(self, *, offering_id: uuid.UUID, user: User) -> None:
        offering = await self._repo.get_offering(offering_id)
        if offering is None:
            raise NotFoundError("Offering not found.", code="OFFERING_NOT_FOUND")
        if offering.tutor_id != user.id:
            raise ForbiddenError("You can only remove your own offerings.", code="NOT_OWNER")
        offering.active = False
        await self._session.commit()

    async def ranked_tutors(
        self, *, course_code: str
    ) -> tuple[Course, list[tuple[RankedTutor, TutorOffering]]]:
        course = await self._repo.get_course_by_code(course_code)
        if course is None:
            raise NotFoundError("Course not found.", code="COURSE_NOT_FOUND")
        offerings = await self._repo.active_offerings_for_course(course.id)
        if not offerings:
            return course, []

        tutor_ids = [o.tutor_id for o in offerings]
        medians = await self._median_reply_seconds(tutor_ids)
        candidates = [
            TutorCandidate(
                tutor_id=o.tutor_id,
                reputation=float(o.tutor.reputation_score),
                term=o.term_taken,
                median_reply_seconds=medians.get(o.tutor_id),
                rating_count=o.tutor.rating_count,
                last_active_at=o.tutor.last_active_at,
            )
            for o in offerings
        ]
        ranked = rank_tutors(candidates)
        by_tutor = {o.tutor_id: o for o in offerings}
        return course, [(r, by_tutor[r.tutor_id]) for r in ranked]

    async def _median_reply_seconds(self, tutor_ids: list[uuid.UUID]) -> dict[uuid.UUID, float]:
        """Median reply latency per tutor over the last 30 days (spec §5.1).

        A 'reply' is a tutor message directly following someone else's message
        in the same conversation.
        """
        since = datetime.now(UTC) - timedelta(days=RESPONSIVENESS_WINDOW_DAYS)
        events = await self._repo.reply_events_since(tutor_ids, since)
        tutor_set = set(tutor_ids)
        gaps: dict[uuid.UUID, list[float]] = {}
        prev_conv: uuid.UUID | None = None
        prev_sender: uuid.UUID | None = None
        prev_at: datetime | None = None
        for conv_id, _msg_id, sender_id, created_at in events:
            if conv_id != prev_conv:
                prev_sender, prev_at = None, None
            if (
                prev_sender is not None
                and prev_at is not None
                and sender_id in tutor_set
                and prev_sender != sender_id
            ):
                gaps.setdefault(sender_id, []).append((created_at - prev_at).total_seconds())
            prev_conv, prev_sender, prev_at = conv_id, sender_id, created_at
        return {tid: statistics.median(vals) for tid, vals in gaps.items()}
