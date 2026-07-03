"""Async engine + session factory (SQLAlchemy 2.0 async, asyncpg)."""

from collections.abc import AsyncIterator

from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.pool import NullPool

from app.core.config import get_settings

_settings = get_settings()

# NullPool in tests: pytest-asyncio uses a fresh event loop per test, and pooled
# asyncpg connections cannot cross loops.
engine = (
    create_async_engine(_settings.database_url, poolclass=NullPool)
    if _settings.app_env == "test"
    else create_async_engine(
        _settings.database_url,
        pool_pre_ping=True,
        pool_size=10,
        max_overflow=20,
    )
)

async_session_factory = async_sessionmaker(engine, expire_on_commit=False)


async def get_session() -> AsyncIterator[AsyncSession]:
    """FastAPI dependency yielding a request-scoped session."""
    async with async_session_factory() as session:
        yield session
