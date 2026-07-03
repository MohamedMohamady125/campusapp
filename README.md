# CampusConnect

A trust-first campus platform: **marketplace + peer tutoring + community chats**,
all behind one verified .edu student identity and a shared reputation system.

Monorepo: **Flutter** app (`apps/mobile`) · **FastAPI** backend (`apps/api`) · **PostgreSQL**.

## Quickstart (≤ 5 commands)

```bash
git clone <repo> campusconnect && cd campusconnect
make dev          # venv + docker infra (postgres/redis/minio/mailhog) + migrations + API on :8000
make seed         # realistic demo data (courses, users, listings, chats)
cd apps/mobile && flutter run    # launch the app (device/emulator/chrome)
```

API docs: http://localhost:8000/docs (Swagger, dev-only) · http://localhost:8000/redoc (ReDoc, all envs) ·
Mailhog: http://localhost:8025 · MinIO console: http://localhost:9001

## Deploy

Tagging `v*` runs `.github/workflows/deploy.yml`: migrate → deploy API → web/mobile
artifacts → smoke (`/health/ready`, `/flags`, auth boundary) → rollback on failure.
All cloud steps are secret-guarded, so it dry-runs green without credentials.
Ops, env vars, and rollback: `docs/RUNBOOK.md`.

## Development

| Command | What it does |
|---|---|
| `make dev` | Full local stack + API with reload |
| `make ci` | Everything CI runs: lint, type-check, tests, contract check (both lanes) |
| `make ci-api` | ruff + mypy (strict) + pytest + OpenAPI freshness |
| `make ci-mobile` | dart format + flutter analyze + flutter test |
| `make export-openapi` | Re-export `contracts/openapi.json` after API schema changes |
| `make migrate` / `make seed` | Alembic migrations / demo data |

## Architecture

- **Contract-first:** `contracts/openapi.json` is exported from FastAPI and the
  Flutter client is generated from it. Never hand-write API models on the Flutter side.
- **Backend layering:** router → service → repository. No DB access in routers.
- **External services** (email, moderation, storage, payments, analytics) sit behind
  interfaces with stub adapters, so the whole app runs with zero paid credentials.
- Decisions live in `docs/adr/`. Ops in `docs/RUNBOOK.md`. Build journal in `docs/RUN_LOG.md`.
