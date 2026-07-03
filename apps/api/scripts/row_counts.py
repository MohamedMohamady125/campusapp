"""M1 acceptance: print row counts for every table (spec §14 M1)."""

import asyncio
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from sqlalchemy import func, select

import app.models  # noqa: F401
from app.db.base import Base
from app.db.session import async_session_factory


async def main() -> None:
    async with async_session_factory() as session:
        for table in Base.metadata.sorted_tables:
            count = (await session.execute(select(func.count()).select_from(table))).scalar_one()
            print(f"{table.name:30s} {count}")


if __name__ == "__main__":
    asyncio.run(main())
