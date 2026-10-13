"""Always-on in-process maintenance loop (prod has no Celery worker service).

Runs inside the API process from the app lifespan, every tick:

1. sweeps expired runs (idempotent ``expire_runs_job`` — previously this only
   ran in prod when DEMO_RUNS_KEEPALIVE=1, a gap this loop closes),
2. sends the one-time "settle up" nudge for done runs with unconfirmed
   payment (``settle_up_reminder_job``), and
3. once per day, runs the nightly batch (listings expiry, verification-code
   and notification purges, metrics aggregation, global-mean recompute) that
   the never-deployed Celery beat was supposed to own.

Multiple gunicorn workers race safely: a Postgres advisory lock makes each
tick single-flight. Every job body is idempotent, so overlap with Celery
beat (when a worker *is* deployed) is harmless.
"""

import asyncio
from datetime import UTC, datetime, timedelta

import structlog
from sqlalchemy import func, select, text
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import async_session_factory
from app.models import DailyMetric
from app.workers.jobs import (
    aggregate_daily_metrics_job,
    expire_listings_job,
    expire_runs_job,
    marketing_emails_job,
    purge_notifications_job,
    purge_verification_codes_job,
    recompute_global_mean_job,
    settle_up_reminder_job,
)

log = structlog.get_logger()

TICK_SECONDS = 10 * 60
# Arbitrary app-unique advisory lock key — distinct from demo_keepalive's.
_LOCK_KEY = 0x_CA_FE_D0_06


async def _daily_jobs_due(session: AsyncSession) -> bool:
    """The nightly batch is due while yesterday has no daily_metrics rows.

    aggregate_daily_metrics_job always writes at least the active_peers row,
    so its output doubles as the done-marker — no extra bookkeeping table.
    """
    yesterday = datetime.now(UTC).date() - timedelta(days=1)
    row = (
        await session.execute(select(DailyMetric.id).where(DailyMetric.day == yesterday).limit(1))
    ).first()
    return row is None


async def maintenance_tick(session: AsyncSession) -> None:
    """One idempotent tick: expire sweep + settle-up reminders + daily batch."""
    got_lock = (await session.execute(select(func.pg_try_advisory_lock(_LOCK_KEY)))).scalar()
    if not got_lock:
        return
    try:
        await expire_runs_job(session)
        await settle_up_reminder_job(session)
        if await _daily_jobs_due(session):
            await expire_listings_job(session)
            await purge_verification_codes_job(session)
            await purge_notifications_job(session)
            await recompute_global_mean_job(session)
            await marketing_emails_job(session)
            # Last on purpose: it writes the done-marker rows, so a failure
            # above leaves the batch due and it retries next tick.
            await aggregate_daily_metrics_job(session)
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
