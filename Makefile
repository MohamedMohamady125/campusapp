.PHONY: dev infra-up infra-down api install-api lint-api type-api test-api ci-api \
        export-openapi check-openapi analyze-mobile test-mobile ci-mobile ci seed migrate

PY := apps/api/.venv/bin/python
PIP := apps/api/.venv/bin/pip

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
	cd apps/api && .venv/bin/uvicorn app.main:app --reload --port 8000

api: install-api
	cd apps/api && .venv/bin/uvicorn app.main:app --reload --port 8000

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

# ── Mobile quality lane ─────────────────────────────────────────────
analyze-mobile:
	cd apps/mobile && dart format --set-exit-if-changed lib test && flutter analyze

test-mobile:
	cd apps/mobile && flutter test

ci-mobile: analyze-mobile test-mobile

# ── Everything ───────────────────────────────────────────────────────
ci: ci-api ci-mobile
