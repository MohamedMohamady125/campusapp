"""Demo-run keep-alive (pre-launch only, DEMO_RUNS_KEEPALIVE=1).

Until real students post runs, the feed must never look dead. This loop runs
inside the API process (prod has no Celery worker service) and every tick:

1. sweeps expired runs (reusing the idempotent ``expire_runs_job``), and
2. tops the feed back up to ``TARGET_OPEN_RUNS`` open future runs, posted by
   seeded demo users against real catalog spots.

Entirely disabled unless the env flag is set — flip it off the day real
users arrive. Multiple gunicorn workers race safely: a Postgres advisory
lock makes each tick single-flight.
"""

import asyncio
from datetime import UTC, datetime, timedelta

import structlog
from sqlalchemy import func, select, text
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import async_session_factory
from app.models import FoodSpot, Run, User
from app.models.enums import RunStatus
from app.workers.jobs import expire_runs_job

log = structlog.get_logger()

TARGET_OPEN_RUNS = 3
TICK_SECONDS = 10 * 60
# Arbitrary app-unique advisory lock key (single-flight across workers).
_LOCK_KEY = 0x_CA_FE_D0_05
# Seeded demo users who "post" the keep-alive runs (see app/seed.py).
_DEMO_RUNNER_EMAILS = ("ben1@campus.edu", "chloe2@campus.edu", "dan3@campus.edu")
# (fee_cents, spots_max, minutes until leaving, note)
_RUN_SHAPES = (
    (200, 4, 45, "Leaving from the library — order up!"),
    (150, 3, 30, "Quick run between classes."),
    (0, 5, 60, "Free run — just keeping it friendly."),
)


async def demo_keepalive_tick(session: AsyncSession) -> int:
    """One idempotent tick: expire sweep + top up open runs. Returns created count."""
    got_lock = (
        await session.execute(select(func.pg_try_advisory_lock(_LOCK_KEY)))
    ).scalar()
    if not got_lock:
        return 0
    try:
        await expire_runs_job(session)

        now = datetime.now(UTC)
        open_count = (
            await session.execute(
                select(func.count())
                .select_from(Run)
                .where(Run.status == RunStatus.open, Run.leaving_at > now)
            )
        ).scalar() or 0
        if open_count >= TARGET_OPEN_RUNS:
            return 0

        runners = list(
            (
                await session.execute(
                    select(User).where(User.email.in_(_DEMO_RUNNER_EMAILS))
                )
            ).scalars()
        )
        spots = list(
            (
                await session.execute(
                    select(FoodSpot)
                    .where(FoodSpot.active.is_(True))
                    .order_by(FoodSpot.name)
                )
            ).scalars()
        )
        if not runners or not spots:
            log.info("jobs.demo_keepalive.no_seed_data")
            return 0

        # A demo runner with a live run shouldn't post a second one.
        busy_ids = set(
            (
                await session.execute(
                    select(Run.runner_id).where(
                        Run.status.in_(
                            (
                                RunStatus.open,
                                RunStatus.locked,
                                RunStatus.at_store,
                                RunStatus.delivering,
                            )
                        )
                    )
                )
            ).scalars()
        )
        # Rotate the spot by day so the feed photos vary between mornings.
        offset = now.timetuple().tm_yday
        created = 0
        for i, runner in enumerate(r for r in runners if r.id not in busy_ids):
            if open_count + created >= TARGET_OPEN_RUNS:
                break
            fee, spots_max, minutes, note = _RUN_SHAPES[i % len(_RUN_SHAPES)]
            session.add(
                Run(
                    runner_id=runner.id,
                    food_spot_id=spots[(offset + i) % len(spots)].id,
                    note=note,
                    leaving_at=now + timedelta(minutes=minutes),
                    fee_cents=fee,
                    spots_max=spots_max,
                )
            )
            created += 1
        await session.commit()
        if created:
            log.info("jobs.demo_keepalive", created=created, open_before=open_count)
        return created
    finally:
        await session.execute(text("SELECT pg_advisory_unlock(:k)"), {"k": _LOCK_KEY})


async def demo_keepalive_loop() -> None:
    """Forever loop started from the app lifespan when DEMO_RUNS_KEEPALIVE=1."""
    while True:
        try:
            async with async_session_factory() as session:
                await demo_keepalive_tick(session)
        except asyncio.CancelledError:
            raise
        except Exception:
            log.exception("jobs.demo_keepalive.tick_failed")
        await asyncio.sleep(TICK_SECONDS)
