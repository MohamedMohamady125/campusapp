"""Liveness and readiness probes (spec §4.1 Meta)."""

from typing import Literal

import redis.asyncio as aioredis
from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.db.session import get_session

router = APIRouter(tags=["meta"])


class HealthResponse(BaseModel):
    status: Literal["ok"]


class ReadyResponse(BaseModel):
    status: Literal["ok", "degraded"]
    database: bool
    redis: bool


@router.get("/health", response_model=HealthResponse)
async def health() -> HealthResponse:
    return HealthResponse(status="ok")


@router.get("/health/ready", response_model=ReadyResponse)
async def ready(session: AsyncSession = Depends(get_session)) -> ReadyResponse:
    db_ok = False
    redis_ok = False
    try:
        await session.execute(text("SELECT 1"))
        db_ok = True
    except Exception:
        db_ok = False
    try:
        client: aioredis.Redis = aioredis.from_url(
            get_settings().redis_url, socket_connect_timeout=2
        )
        try:
            redis_ok = bool(await client.ping())
        finally:
            await client.aclose()
    except Exception:
        redis_ok = False
    return ReadyResponse(
        status="ok" if (db_ok and redis_ok) else "degraded",
        database=db_ok,
        redis=redis_ok,
    )
