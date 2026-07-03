"""Analytics provider selection (spec §2.5).

DB adapter in every env for v1; a hosted-provider adapter can replace it
in prod without touching call sites.
"""

from functools import lru_cache

from app.integrations.analytics.base import AnalyticsProvider
from app.integrations.analytics.stub import DbAnalyticsProvider


@lru_cache
def get_analytics_provider() -> AnalyticsProvider:
    return DbAnalyticsProvider()
