"""Feature flag endpoint (spec §4.1 Meta: GET /flags)."""

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_session
from app.services.flag_service import list_flags

router = APIRouter(tags=["meta"])


class FlagItem(BaseModel):
    key: str
    enabled: bool
    rollout_percent: int


@router.get("/flags", response_model=list[FlagItem])
async def get_flags(session: AsyncSession = Depends(get_session)) -> list[FlagItem]:
    return [FlagItem(**f) for f in await list_flags(session)]
