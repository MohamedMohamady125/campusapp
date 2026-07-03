# ADR-0001: Stack — Flutter + FastAPI + PostgreSQL

Status: Accepted (locked by build spec §2)
Date: 2026-07-03

## Decision

| Layer | Choice |
|---|---|
| Frontend | Flutter 3.x (Dart 3.x), Material 3, iOS + Android + Web |
| App state | Riverpod v2 (code-gen) |
| Networking | dio (+ typed client generated from OpenAPI) |
| Models | freezed + json_serializable |
| Routing | go_router |
| Local persistence | flutter_secure_storage (tokens) + Hive (cache) |
| Backend | FastAPI (Python 3.12), Uvicorn, async-first |
| API structure | router → service → repository |
| Validation | Pydantic v2 |
| ORM | SQLAlchemy 2.0 async (asyncpg) |
| Migrations | Alembic |
| Database | PostgreSQL 15 |
| Auth | JWT access + rotating refresh, argon2id |
| Object storage | S3-compatible (MinIO locally) via boto3, signed-URL direct upload |
| Realtime | Polling v1; FastAPI WebSockets behind `flags.realtime` |
| Cache/queues | Redis + Celery |
| CI/CD | GitHub Actions (ci-api, ci-mobile, deploy) |
| Observability | structlog + Sentry (stubbed) |
| Containerization | docker-compose (postgres, redis, minio, mailhog) |

## Contract
`contracts/openapi.json` exported from FastAPI is the single source of truth;
the Flutter client is generated from it. CI fails if stale.

## External services
Every third-party dependency (email, moderation, storage, payments, analytics)
is behind a Python ABC in `apps/api/app/integrations/<name>/` with a real
adapter and a stub adapter selected by env (§2.5).

## Consequences
- One contract, two generated ends; type-safe API evolution.
- Zero paid credentials needed for dev/CI (stubs).
- Horizontal scaling: stateless API, Redis-backed rate limits/cache, Celery workers.
