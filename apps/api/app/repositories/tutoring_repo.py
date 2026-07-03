"""Course + tutor offering data access (spec §4.1 Tutoring)."""

import uuid
from datetime import datetime

from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models import (
    Conversation,
    ConversationParticipant,
    Course,
    Message,
    TutorOffering,
)

COURSE_AUTOCOMPLETE_LIMIT = 10


class TutoringRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def autocomplete_courses(self, query: str) -> list[Course]:
        """Prefix match on code, substring on title — J2 is typed fast."""
        pattern_code = f"{query}%"
        pattern_title = f"%{query}%"
        stmt = (
            select(Course)
            .where(
                or_(
                    Course.code.ilike(pattern_code),
                    Course.title.ilike(pattern_title),
                )
            )
            .order_by(Course.code)
            .limit(COURSE_AUTOCOMPLETE_LIMIT)
        )
        return list((await self._session.execute(stmt)).scalars())

    async def get_course_by_code(self, code: str) -> Course | None:
        result = await self._session.execute(
            select(Course).where(func.lower(Course.code) == code.lower())
        )
        return result.scalar_one_or_none()

    async def get_course(self, course_id: uuid.UUID) -> Course | None:
        return await self._session.get(Course, course_id)

    async def get_offering(self, offering_id: uuid.UUID) -> TutorOffering | None:
        result = await self._session.execute(
            select(TutorOffering)
            .options(selectinload(TutorOffering.tutor), selectinload(TutorOffering.course))
            .where(TutorOffering.id == offering_id)
        )
        return result.scalar_one_or_none()

    async def get_offering_for(
        self, tutor_id: uuid.UUID, course_id: uuid.UUID
    ) -> TutorOffering | None:
        result = await self._session.execute(
            select(TutorOffering).where(
                TutorOffering.tutor_id == tutor_id, TutorOffering.course_id == course_id
            )
        )
        return result.scalar_one_or_none()

    async def active_offerings_for_course(self, course_id: uuid.UUID) -> list[TutorOffering]:
        stmt = (
            select(TutorOffering)
            .options(selectinload(TutorOffering.tutor), selectinload(TutorOffering.course))
            .where(TutorOffering.course_id == course_id, TutorOffering.active.is_(True))
        )
        return list((await self._session.execute(stmt)).scalars())

    async def reply_events_since(
        self, tutor_ids: list[uuid.UUID], since: datetime
    ) -> list[tuple[uuid.UUID, uuid.UUID, uuid.UUID, datetime]]:
        """(conversation_id, message_id, sender_id, created_at) for conversations
        involving any candidate tutor — raw material for median reply time (§5.1)."""
        conv_ids = select(ConversationParticipant.conversation_id).where(
            ConversationParticipant.user_id.in_(tutor_ids)
        )
        stmt = (
            select(Message.conversation_id, Message.id, Message.sender_id, Message.created_at)
            .join(Conversation, Conversation.id == Message.conversation_id)
            .where(
                Message.conversation_id.in_(conv_ids),
                Message.created_at >= since,
                Message.deleted_at.is_(None),
            )
            .order_by(Message.conversation_id, Message.created_at)
        )
        rows = (await self._session.execute(stmt)).all()
        return [(r[0], r[1], r[2], r[3]) for r in rows]

    def add(self, offering: TutorOffering) -> None:
        self._session.add(offering)
