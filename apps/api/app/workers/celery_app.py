"""Celery app: Redis broker, nightly beat schedule (spec §5.4)."""

from celery import Celery
from celery.schedules import crontab

from app.core.config import get_settings

celery_app = Celery(
    "campusconnect",
    broker=get_settings().redis_url,
    backend=get_settings().redis_url,
    include=["app.workers.tasks"],
)

celery_app.conf.update(
    task_acks_late=True,
    task_serializer="json",
    result_serializer="json",
    accept_content=["json"],
    beat_schedule={
        "expire-listings-nightly": {
            "task": "app.workers.tasks.expire_listings",
            "schedule": crontab(hour=3, minute=0),
        },
        "recompute-global-mean-nightly": {
            "task": "app.workers.tasks.recompute_global_mean",
            "schedule": crontab(hour=3, minute=15),
        },
        "purge-verification-codes-nightly": {
            "task": "app.workers.tasks.purge_verification_codes",
            "schedule": crontab(hour=3, minute=30),
        },
        "aggregate-daily-metrics-nightly": {
            "task": "app.workers.tasks.aggregate_daily_metrics",
            "schedule": crontab(hour=3, minute=45),
        },
    },
)
