"""Shared test fixtures.

Integration tests run against a real Postgres (spec §10.1): a dedicated
`campusconnect_test` database on the docker-compose server, truncated
between tests. Env is pinned *before* app imports so the app engine
points at the test database.
"""

import asyncio
import os

os.environ["APP_ENV"] = "test"
_TEST_DB_URL = (
    os.environ.get(
        "DATABASE_URL", "postgresql+asyncpg://campus:campus@localhost:5434/campusconnect"
    ).rsplit("/", 1)[0]
    + "/campusconnect_test"
)
os.environ["DATABASE_URL"] = _TEST_DB_URL

from collections.abc import AsyncIterator  # noqa: E402

import httpx  # noqa: E402
import pytest  # noqa: E402
from fastapi import FastAPI  # noqa: E402
from sqlalchemy import text  # noqa: E402
from sqlalchemy.ext.asyncio import create_async_engine  # noqa: E402

import app.models  # noqa: E402
from app.core.rate_limit import reset_rate_limits  # noqa: E402
from app.db.base import Base  # noqa: E402
from app.db.session import async_session_factory  # noqa: E402
from app.main import create_app  # noqa: E402


async def _create_schema() -> None:
    admin_url = _TEST_DB_URL.rsplit("/", 1)[0] + "/campusconnect"
    admin = create_async_engine(admin_url, isolation_level="AUTOCOMMIT")
    async with admin.connect() as conn:
        exists = await conn.execute(
            text("SELECT 1 FROM pg_database WHERE datname = 'campusconnect_test'")
        )
        if exists.scalar() is None:
            await conn.execute(text("CREATE DATABASE campusconnect_test"))
    await admin.dispose()

    engine = create_async_engine(_TEST_DB_URL)
    async with engine.begin() as conn:
        await conn.execute(text("CREATE EXTENSION IF NOT EXISTS pg_trgm"))
        await conn.run_sync(Base.metadata.drop_all)
        await conn.run_sync(Base.metadata.create_all)
    await engine.dispose()


@pytest.fixture(scope="session", autouse=True)
def _setup_database() -> None:
    asyncio.run(_create_schema())


@pytest.fixture(autouse=True)
async def _clean_tables() -> AsyncIterator[None]:
    reset_rate_limits()
    yield
    tables = ", ".join(t.name for t in Base.metadata.sorted_tables)
    async with async_session_factory() as session:
        await session.execute(text(f"TRUNCATE {tables} CASCADE"))
        await session.commit()


@pytest.fixture
def app() -> FastAPI:
    return create_app()


@pytest.fixture
async def client(app: FastAPI) -> AsyncIterator[httpx.AsyncClient]:
    transport = httpx.ASGITransport(app=app)
    async with httpx.AsyncClient(transport=transport, base_url="http://test") as c:
        yield c
