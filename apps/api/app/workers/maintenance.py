"""Always-on in-process maintenance loop (prod has no Celery worker service).

Runs inside the API process from the app lifespan, every tick:

1. sweeps expired runs (idempotent ``expire_runs_job`` — previously this only
   ran in prod when DEMO_RUNS_KEEPALIVE=1, a gap this loop closes), and
2. sends the one-time "settle up" nudge for done runs with unconfirmed
   payment (``settle_up_reminder_job``).

Multiple gunicorn workers race safely: a Postgres advisory lock makes each
tick single-flight. Every job body is idempotent, so overlap with Celery
beat (when a worker *is* deployed) is harmless.
"""

import asyncio

import structlog
from sqlalchemy import func, select, text
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import async_session_factory
from app.workers.jobs import expire_runs_job, settle_up_reminder_job

log = structlog.get_logger()

TICK_SECONDS = 10 * 60
# Arbitrary app-unique advisory lock key — distinct from demo_keepalive's.
_LOCK_KEY = 0x_CA_FE_D0_06


async def maintenance_tick(session: AsyncSession) -> None:
    """One idempotent tick: expire sweep + settle-up reminders."""
    got_lock = (await session.execute(select(func.pg_try_advisory_lock(_LOCK_KEY)))).scalar()
    if not got_lock:
        return
    try:
        await expire_runs_job(session)
        await settle_up_reminder_job(session)
    finally:
        await session.execute(text("SELECT pg_advisory_unlock(:k)"), {"k": _LOCK_KEY})


async def maintenance_loop() -> None:
    """Forever loop started unconditionally from the app lifespan."""
    while True:
        try:
            async with async_session_factory() as session:
                await maintenance_tick(session)
        except asyncio.CancelledError:
            raise
        except Exception:
            log.exception("jobs.maintenance.tick_failed")
        await asyncio.sleep(TICK_SECONDS)
