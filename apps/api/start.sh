#!/usr/bin/env sh
# Release + boot sequence (spec §11 deploy lane). Runs on every container start.
set -e

echo "==> Applying database migrations (alembic upgrade head)"
alembic upgrade head

# Seed is idempotent — it bails out the moment any user already exists, so it is
# safe to run on every boot. Disable with SEED_ON_BOOT=0.
if [ "${SEED_ON_BOOT:-1}" = "1" ]; then
  echo "==> Seeding demo data (idempotent)"
  python -m app.seed || echo "==> seed step failed; continuing to serve"
fi

# Catalog upsert is idempotent and keyed by name — keeps every GCU spot,
# residence hall and building at its accurate OSM coordinate on each deploy.
echo "==> Upserting GCU campus catalog (idempotent)"
python -m app.seed_gcu_catalog || echo "==> gcu catalog step failed; continuing to serve"

echo "==> Starting API on 0.0.0.0:${PORT:-8000} (${WEB_CONCURRENCY:-2} workers)"
exec gunicorn app.main:app \
  -k uvicorn.workers.UvicornWorker \
  -b "0.0.0.0:${PORT:-8000}" \
  -w "${WEB_CONCURRENCY:-2}" \
  --access-logfile - \
  --error-logfile -
