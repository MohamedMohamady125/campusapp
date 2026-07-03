# CampusConnect RUNBOOK

Operational guide: deploy, rollback, environment, and routine ops.
Architecture decisions live in `docs/adr/`; security posture in `docs/owasp.md`.

## 1. Environments

| Env | `APP_ENV` | Notes |
|---|---|---|
| dev | `dev` | `make dev` — docker compose Postgres/Redis/MinIO/Mailhog, API reload on :8000 |
| test | `test` | CI + pytest; in-memory cache/rate-limit fallback, NullPool |
| prod | `prod` | JSON logs, Swagger UI disabled (`/redoc` stays up), Sentry if DSN set |

## 2. Production environment variables

All config is env-driven (`apps/api/app/core/config.py`, template in `/.env.example`).

| Variable | Required in prod | Notes |
|---|---|---|
| `APP_ENV` | yes — `prod` | gates JSON logs, Swagger off, real payment adapter eligibility |
| `DATABASE_URL` | yes | `postgresql+asyncpg://…`; use a pooled managed Postgres 15 |
| `REDIS_URL` | yes | cache + rate limits + Celery broker |
| `JWT_SECRET` | yes | ≥32 bytes; `python -c "import secrets; print(secrets.token_urlsafe(64))"` |
| `CAMPUS_EMAIL_DOMAIN` | yes | the .edu domain students must sign up with |
| `S3_*` | yes | real S3 (or compatible) creds + bucket; MinIO is dev-only |
| `EMAIL_PROVIDER_API_KEY` | yes | real email adapter used only when set; otherwise SMTP/Mailhog stub |
| `CORS_ORIGINS` | yes | comma-separated web origins |
| `MODERATION_API_KEY` | no | stub moderation when empty |
| `STRIPE_SECRET_KEY` / `STRIPE_WEBHOOK_SECRET` | **NO — leave empty** | guardrail §16: monetization ships dark. Real adapter activates only when `APP_ENV=prod` **and** key present **and** flags enabled — requires human review. |
| `SENTRY_DSN` | recommended | crash reporting; no-op when empty |

Never commit real values. Secrets live in the platform's secret store / GitHub Actions secrets.

## 3. Deploy

`deploy.yml` runs on version tags (`v*`) or manual dispatch:
**migrate → deploy API → deploy web + mobile artifacts → smoke → rollback-on-failure.**

Every cloud step is guarded by its secret, so the pipeline dry-runs green with no
credentials. To go live, set GitHub Actions secrets:

- `PROD_DATABASE_URL` — used only by the migration job
- `RENDER_DEPLOY_HOOK` — deploy-hook URL for the API container (Render/Railway)
- `PROD_API_URL` — public base URL for smoke checks
- `VERCEL_DEPLOY_HOOK` — Flutter-web deploy (TODO(blocked): pub.dev — app not bootstrapped)
- `RENDER_ROLLBACK_HOOK` — optional automatic rollback hook

Smoke gate = `/api/v1/health/ready` 200 + `/api/v1/flags` readable + unauthenticated
`/api/v1/listings` returns 401. Any failure triggers the rollback job.

### Manual deploy (no CI)

```bash
cd apps/api
DATABASE_URL=$PROD_DATABASE_URL .venv/bin/alembic upgrade head
# then redeploy the container; entrypoint:
gunicorn app.main:app -k uvicorn.workers.UvicornWorker -w 2 -b 0.0.0.0:8000
# worker + beat:
celery -A app.workers.celery_app worker -l info
celery -A app.workers.celery_app beat -l info
```

## 4. Rollback

1. **API container**: redeploy the previous image/release from the platform dashboard
   (or POST the rollback hook). Releases are immutable images keyed by git SHA.
2. **Database**: migrations are **forward-only** in prod. Prefer a hotfix migration over
   `alembic downgrade`; downgrade only if the bad migration was additive and unused.
3. **Feature flags**: anything shipped behind a flag (realtime, promoted_listings,
   tutor_premium) is rolled back instantly by flipping the flag row to `enabled=false`
   — no deploy needed. Flag reads are cached ~30s.
4. Verify with the smoke gate above; watch Sentry + logs for 5 minutes.

## 5. Routine ops

- **Migrations**: `make migrate` (dev). New migration: edit models → `alembic revision
  --autogenerate -m "…"` → review → `alembic upgrade head`. CI fails on model drift.
- **Seed demo data**: `make seed` (dev only).
- **Feature flags**: rows in the `flags` table (`key`, `enabled`, `rollout_percent`).
  Percentage rollouts bucket deterministically per (flag, user). All flags default dark.
- **Nightly jobs** (Celery beat): listing expiry sweep; daily metrics aggregation 03:45 UTC
  (idempotent — safe to re-run for a day: `aggregate_daily_metrics_job(session, day=…)`).
- **Backups**: use the managed-Postgres provider's PITR/daily snapshots; test restore
  quarterly. MinIO/S3 bucket versioning for images.
- **Load smoke**: `make k6-smoke` against a running stack (p95 < 250ms, error rate < 1%).
- **Dependency audit**: `make audit-api` (pip-audit); also runs in CI.

## 6. Incident quick reference

| Symptom | First moves |
|---|---|
| 5xx spike | Sentry issue → recent deploy? roll back (§4). Check `/health/ready` (DB+Redis probes). |
| DB connection exhaustion | check pool on the platform; Alembic long locks; restart API last. |
| Redis down | cache and rate-limit fail open/closed respectively; API stays up — restore Redis, no restart needed. |
| Abuse/spam wave | tighten rate limits (env), ban via admin moderation endpoints, audit log has trails. |
| Bad flag rollout | set `enabled=false` on the flag row; propagates ≤30s. |

## 7. What a human must plug in before real launch

Real S3 + email provider keys, moderation API key, Stripe keys (**only** with §16 review),
Sentry DSN, FCM/APNs certs (push — post-v1), DNS + TLS for API and web, app-store
credentials, and the production `.edu` domain in `CAMPUS_EMAIL_DOMAIN`.
