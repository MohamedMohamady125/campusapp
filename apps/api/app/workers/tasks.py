"""Celery task wrappers around async job bodies (spec §5.4)."""

import asyncio
from typing import Any

from app.db.session import async_session_factory
from app.workers.celery_app import celery_app
from app.workers.jobs import (
    aggregate_daily_metrics_job,
    expire_listings_job,
    expire_runs_job,
    purge_verification_codes_job,
    recompute_global_mean_job,
)


def _run(coro_factory: Any) -> Any:
    async def _inner() -> Any:
        async with async_session_factory() as session:
            return await coro_factory(session)

    return asyncio.run(_inner())


@celery_app.task  # type: ignore[untyped-decorator]
def expire_listings() -> int:
    return int(_run(expire_listings_job))


@celery_app.task  # type: ignore[untyped-decorator]
def expire_runs() -> dict[str, int]:
    return dict(_run(expire_runs_job))


@celery_app.task  # type: ignore[untyped-decorator]
def recompute_global_mean() -> float:
    return float(_run(recompute_global_mean_job))


@celery_app.task  # type: ignore[untyped-decorator]
def purge_verification_codes() -> int:
    return int(_run(purge_verification_codes_job))


@celery_app.task  # type: ignore[untyped-decorator]
def aggregate_daily_metrics() -> dict[str, float]:
    result = _run(aggregate_daily_metrics_job)
    return dict(result)
