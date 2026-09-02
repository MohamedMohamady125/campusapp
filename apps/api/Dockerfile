# CampusConnect API container (spec §2.1 — Uvicorn workers under Gunicorn).
# Build context is apps/api (see railway.json / Railway root directory).
FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

# Install the package (runtime deps only — no dev extras) from source.
COPY . .
RUN pip install --upgrade pip && pip install . && chmod +x start.sh

# Gunicorn/Uvicorn bind to $PORT, injected by the platform at runtime.
EXPOSE 8000
CMD ["./start.sh"]
