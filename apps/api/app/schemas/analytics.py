"""Client behavioural-analytics ingest contract (spec §12).

The app batches screen views (with dwell time) and discrete actions and
ships them here; everything lands in the existing `analytics_events`
table with the client context folded into the JSONB `properties`.
"""

from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field, field_validator

# One batch per flush; the client flushes ~every 30s and on background.
MAX_EVENTS_PER_BATCH = 50
# Dwell cap: anything above a day is a clock bug, clamp it out.
MAX_DURATION_MS = 86_400_000


class ClientEventIn(BaseModel):
    """A single client-side event (screen_view or a named action)."""

    name: str = Field(min_length=1, max_length=60, pattern=r"^[a-z0-9_.]+$")
    occurred_at: datetime
    # Stable route pattern, ids normalised out (e.g. "/runs/run/:id").
    screen: str | None = Field(default=None, max_length=80)
    # For screen_view: how long the previous render of this screen was visible.
    duration_ms: int | None = Field(default=None, ge=0, le=MAX_DURATION_MS)
    properties: dict[str, str | int | float | bool | None] = Field(
        default_factory=dict, max_length=10
    )

    @field_validator("properties")
    @classmethod
    def _cap_string_values(
        cls, value: dict[str, str | int | float | bool | None]
    ) -> dict[str, str | int | float | bool | None]:
        # Keep rows small: no free-text payloads sneaking into analytics.
        return {k: (v[:200] if isinstance(v, str) else v) for k, v in value.items()}


class ClientEventBatchRequest(BaseModel):
    # One id per app launch; lets us count sessions and session length.
    session_id: str = Field(min_length=8, max_length=64)
    platform: Literal["ios", "android", "web"]
    events: list[ClientEventIn] = Field(min_length=1, max_length=MAX_EVENTS_PER_BATCH)
