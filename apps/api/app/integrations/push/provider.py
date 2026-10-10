"""Push provider selection by environment (spec §2.5)."""

from functools import lru_cache

from app.core.config import get_settings
from app.integrations.push.base import PushProvider
from app.integrations.push.stub import StubPushProvider


@lru_cache
def get_push_provider() -> PushProvider:
    settings = get_settings()
    if settings.app_env != "test" and settings.fcm_service_account_json:
        from app.integrations.push.fcm import FcmPushProvider

        return FcmPushProvider(settings.fcm_service_account_json)
    return StubPushProvider()
