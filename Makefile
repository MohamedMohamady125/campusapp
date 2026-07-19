.PHONY: dev infra-up infra-down api install-api lint-api type-api test-api ci-api \
        export-openapi check-openapi analyze-mobile test-mobile ci-mobile ci seed migrate \
        k6-smoke audit-api

PY := apps/api/.venv/bin/python
PIP := apps/api/.venv/bin/pip

# pub.dev is unreachable from some networks; the official community mirror works.
# Override with `make PUB_HOSTED_URL=https://pub.dev …` when unrestricted.
export PUB_HOSTED_URL ?= https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL ?= https://storage.flutter-io.cn

# ── Setup ────────────────────────────────────────────────────────────
apps/api/.venv:
	python3.12 -m venv apps/api/.venv
	$(PIP) install -q --upgrade pip
	$(PIP) install -q -e "apps/api[dev]"

install-api: apps/api/.venv

# ── Local dev ────────────────────────────────────────────────────────
infra-up:
	docker compose -f infra/docker-compose.yml up -d --wait

infra-down:
	docker compose -f infra/docker-compose.yml down

dev: install-api infra-up migrate
	cd apps/api && .venv/bin/uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

api: install-api
	cd apps/api && .venv/bin/uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

migrate: install-api
	cd apps/api && .venv/bin/alembic upgrade head

seed: install-api
	cd apps/api && .venv/bin/python -m app.seed

# ── API quality lane ────────────────────────────────────────────────
lint-api: install-api
	cd apps/api && .venv/bin/ruff check app tests scripts && .venv/bin/ruff format --check app tests scripts

type-api: install-api
	cd apps/api && .venv/bin/mypy app

test-api: install-api
	cd apps/api && .venv/bin/pytest -q --cov=app --cov-report=term-missing

export-openapi: install-api
	cd apps/api && .venv/bin/python scripts/export_openapi.py

check-openapi: install-api
	cd apps/api && .venv/bin/python scripts/export_openapi.py && \
	git diff --exit-code ../../contracts/openapi.json || \
	(echo "contracts/openapi.json is stale — run 'make export-openapi' and commit." && exit 1)

ci-api: lint-api type-api test-api check-openapi

# ── Hardening (M8) ──────────────────────────────────────────────────
k6-smoke:
	k6 run infra/k6/smoke.js -e BASE_URL=$${BASE_URL:-http://localhost:8000}

audit-api: install-api
	cd apps/api && .venv/bin/python -m pip_audit --skip-editable || \
	(.venv/bin/pip install -q pip-audit && .venv/bin/python -m pip_audit --skip-editable)

# ── Mobile quality lane ─────────────────────────────────────────────
analyze-mobile:
	cd apps/mobile && dart format --set-exit-if-changed lib test && flutter analyze

test-mobile:
	cd apps/mobile && flutter test

ci-mobile: analyze-mobile test-mobile

# ── Everything ───────────────────────────────────────────────────────
ci: ci-api ci-mobile
