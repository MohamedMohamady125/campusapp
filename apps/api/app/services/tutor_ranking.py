"""Tutor ranking (spec §5.1) as a pure, unit-testable function.

score = 0.60 * reputation_norm + 0.30 * recency_norm + 0.10 * responsiveness_norm

All *_norm values are normalized [0,1] over the candidate pool. New tutors get
the pool-median responsiveness (neutral prior) — never floored to last purely
for lack of data. Tie-break: rating_count desc, then last_active_at desc.
"""

import statistics
import uuid
from dataclasses import dataclass
from datetime import UTC, datetime

from app.core.scoring import WEIGHT_RECENCY, WEIGHT_REPUTATION, WEIGHT_RESPONSIVENESS

_SEASON_ORDER = {"spring": 0, "summer": 1, "fall": 2}


def term_ordinal(term: str) -> int:
    """'2025-fall' → sortable ordinal (later terms are larger)."""
    year_s, _, season = term.partition("-")
    return int(year_s) * 3 + _SEASON_ORDER.get(season.lower(), 0)


@dataclass(frozen=True)
class TutorCandidate:
    tutor_id: uuid.UUID
    reputation: float  # Bayesian §5.2 cached score
    term: str  # e.g. "2025-fall"
    median_reply_seconds: float | None  # None = no reply data (new tutor)
    rating_count: int
    last_active_at: datetime | None


@dataclass(frozen=True)
class RankedTutor:
    tutor_id: uuid.UUID
    score: float
    reputation_norm: float
    recency_norm: float
    responsiveness_norm: float


def _minmax(values: list[float]) -> list[float]:
    lo, hi = min(values), max(values)
    if hi == lo:
        return [1.0] * len(values)  # all-equal pool: nobody penalized
    return [(v - lo) / (hi - lo) for v in values]


def rank_tutors(candidates: list[TutorCandidate]) -> list[RankedTutor]:
    if not candidates:
        return []

    reputation_norms = _minmax([c.reputation for c in candidates])
    recency_norms = _minmax([float(term_ordinal(c.term)) for c in candidates])

    # Responsiveness: lower median reply time is better → invert after minmax.
    # New tutors (no data) get the pool median — the neutral prior (spec §5.1).
    known = [c.median_reply_seconds for c in candidates if c.median_reply_seconds is not None]
    pool_median = statistics.median(known) if known else 0.0
    reply_seconds = [
        c.median_reply_seconds if c.median_reply_seconds is not None else pool_median
        for c in candidates
    ]
    if len(set(reply_seconds)) <= 1:
        responsiveness_norms = [1.0] * len(candidates)  # all-equal pool: nobody penalized
    else:
        responsiveness_norms = [1.0 - v for v in _minmax(reply_seconds)]

    ranked = [
        RankedTutor(
            tutor_id=c.tutor_id,
            score=(WEIGHT_REPUTATION * rep + WEIGHT_RECENCY * rec + WEIGHT_RESPONSIVENESS * resp),
            reputation_norm=rep,
            recency_norm=rec,
            responsiveness_norm=resp,
        )
        for c, rep, rec, resp in zip(
            candidates, reputation_norms, recency_norms, responsiveness_norms, strict=True
        )
    ]
    by_id = {c.tutor_id: c for c in candidates}
    _epoch = datetime.min.replace(tzinfo=UTC)
    # score desc, tie-break rating_count desc then last_active_at desc (spec §5.1).
    ranked.sort(
        key=lambda r: (
            r.score,
            by_id[r.tutor_id].rating_count,
            (by_id[r.tutor_id].last_active_at or _epoch),
        ),
        reverse=True,
    )
    return ranked
