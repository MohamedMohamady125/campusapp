"""Scoring constants & formulas in one config module (spec §5.1, §5.2).

Weights and priors are named here — never inlined at call sites.
"""

# §5.2 Bayesian reputation: (C*m + sum_of_stars) / (C + n)
REPUTATION_PRIOR_C = 8  # prior strength C
GLOBAL_MEAN_SEED = 4.0  # m when the platform has no ratings yet

# §5.1 tutor ranking weights (consumed in M6)
WEIGHT_REPUTATION = 0.60
WEIGHT_RECENCY = 0.30
WEIGHT_RESPONSIVENESS = 0.10


def bayesian_reputation(*, ratings_sum: float, ratings_count: int, global_mean: float) -> float:
    """Spec §5.2: two 5★ ratings must not outrank two hundred 4.8★ ratings.

    Used for *ranking* (tutor match §5.1) only — the user-visible score is
    display_reputation below, so a straight-5★ student actually shows 5.0.
    """
    return (REPUTATION_PRIOR_C * global_mean + ratings_sum) / (REPUTATION_PRIOR_C + ratings_count)


def display_reputation(*, ratings_sum: float, ratings_count: int) -> float:
    """User-facing cached score: the plain average of received stars.

    Product decision (overrides §5.2 for display): students expect a 5★-rated
    account to read 5.0, not a prior-weighted ~4.2. With zero ratings the UI
    shows "—", so the neutral seed only matters as a DB default.
    """
    if ratings_count <= 0:
        return GLOBAL_MEAN_SEED
    return ratings_sum / ratings_count
