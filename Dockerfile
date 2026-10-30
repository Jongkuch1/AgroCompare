# syntax=docker/dockerfile:1
# AgroCompare backend (Flask API), built from the repository root.

# ---------- Stage 1: build dependencies ----------
# Pinned base image (not "latest") so builds are repeatable
FROM python:3.11-slim AS builder

WORKDIR /build

# Copy only requirements first so this layer is cached
# until requirements.txt changes
COPY backend/requirements.txt .
RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

# ---------- Stage 2: small runtime image ----------
FROM python:3.11-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH"

# Create an unprivileged user: the app must not run as root
RUN useradd --create-home --uid 1001 appuser

WORKDIR /app

# Bring in the installed packages, then the application code
COPY --from=builder /opt/venv /opt/venv
COPY --chown=appuser:appuser backend/ /app/

USER appuser

EXPOSE 5000

# Mark the container unhealthy if the API stops answering
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/api/health', timeout=3)"

# Listen on 0.0.0.0 so the port is reachable from outside the container
CMD ["flask", "--app", "app", "run", "--host", "0.0.0.0", "--port", "5000"]
