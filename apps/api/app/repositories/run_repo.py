"""Food run data access (food-runs spec)."""

import uuid
from datetime import datetime

from sqlalchemy import or_, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models import DropoffLocation, FoodSpot, Run, RunOrder
from app.models.enums import RunStatus

# Eager-load everything a RunResponse needs — no N+1 on the feed (spec §7.2).
_RUN_LOAD = (
    selectinload(Run.runner),
    selectinload(Run.food_spot),
    selectinload(Run.orders).selectinload(RunOrder.requester),
)


class RunRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    def add(self, obj: Run | RunOrder) -> None:
        self._session.add(obj)

    def add_spot(self, spot: FoodSpot) -> None:
        self._session.add(spot)

    async def list_spots(self) -> list[FoodSpot]:
        result = await self._session.execute(
            select(FoodSpot).where(FoodSpot.active.is_(True)).order_by(FoodSpot.name)
        )
        return list(result.scalars())

    async def get_spot(self, spot_id: uuid.UUID) -> FoodSpot | None:
        return await self._session.get(FoodSpot, spot_id)

    async def spot_name_exists(self, name: str) -> bool:
        result = await self._session.execute(select(FoodSpot.id).where(FoodSpot.name == name))
        return result.first() is not None

    def add_dropoff(self, dropoff: DropoffLocation) -> None:
        self._session.add(dropoff)

    async def list_dropoffs(self) -> list[DropoffLocation]:
        result = await self._session.execute(
            select(DropoffLocation)
            .where(DropoffLocation.active.is_(True))
            .order_by(DropoffLocation.name)
        )
        return list(result.scalars())

    async def get_dropoff(self, dropoff_id: uuid.UUID) -> DropoffLocation | None:
        return await self._session.get(DropoffLocation, dropoff_id)

    async def dropoff_name_exists(self, name: str) -> bool:
        result = await self._session.execute(
            select(DropoffLocation.id).where(DropoffLocation.name == name)
        )
        return result.first() is not None

    async def get(self, run_id: uuid.UUID, *, for_update: bool = False) -> Run | None:
        # populate_existing: services re-fetch after commit and the session has
        # expire_on_commit=False — without it the eager-loaded orders collection
        # would come back stale from the identity map.
        stmt = (
            select(Run)
            .where(Run.id == run_id)
            .options(*_RUN_LOAD)
            .execution_options(populate_existing=True)
        )
        if for_update:
            # Lock only the run row; SKIP eager-load lock via of_.
            stmt = stmt.with_for_update(of=Run)
        result = await self._session.execute(stmt)
        return result.scalars().first()

    async def feed(
        self,
        *,
        now: datetime,
        cursor: tuple[datetime, uuid.UUID] | None,
        limit: int,
    ) -> list[Run]:
        """Open runs still in the future, soonest departure first."""
        stmt = (
            select(Run)
            .where(Run.status == RunStatus.open, Run.leaving_at > now)
            .options(*_RUN_LOAD)
            .order_by(Run.leaving_at.asc(), Run.id.asc())
            .limit(limit)
        )
        if cursor is not None:
            ts, oid = cursor
            stmt = stmt.where(or_(Run.leaving_at > ts, (Run.leaving_at == ts) & (Run.id > oid)))
        result = await self._session.execute(stmt)
        return list(result.scalars())

    async def list_mine(self, *, user_id: uuid.UUID, limit: int = 50) -> list[Run]:
        """Runs I posted or joined, newest first (bounded, no cursor needed v1)."""
        joined = select(RunOrder.run_id).where(RunOrder.requester_id == user_id)
        stmt = (
            select(Run)
            .where(or_(Run.runner_id == user_id, Run.id.in_(joined)))
            .options(*_RUN_LOAD)
            .order_by(Run.created_at.desc())
            .limit(limit)
        )
        result = await self._session.execute(stmt)
        return list(result.scalars())

    async def get_order(self, order_id: uuid.UUID) -> RunOrder | None:
        result = await self._session.execute(
            select(RunOrder)
            .where(RunOrder.id == order_id)
            .options(
                selectinload(RunOrder.requester),
                selectinload(RunOrder.run).options(*_RUN_LOAD),
            )
        )
        return result.scalars().first()

    async def find_order(self, run_id: uuid.UUID, requester_id: uuid.UUID) -> RunOrder | None:
        result = await self._session.execute(
            select(RunOrder).where(RunOrder.run_id == run_id, RunOrder.requester_id == requester_id)
        )
        return result.scalars().first()

    async def expirable(self, *, now: datetime) -> list[Run]:
        """Runs the expiry job must look at (open past leaving_at, or active >90min over)."""
        result = await self._session.execute(
            select(Run)
            .where(
                Run.status.in_(
                    [RunStatus.open, RunStatus.locked, RunStatus.at_store, RunStatus.delivering]
                ),
                Run.leaving_at < now,
            )
            .options(selectinload(Run.orders))
        )
        return list(result.scalars())
