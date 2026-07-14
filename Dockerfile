# ---- Stage 1: base image ----
FROM python:3.12-slim

WORKDIR /app

# Install curl untuk healthcheck
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

# Copy & install dependencies dulu (agar layer di-cache saat rebuild)
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code aplikasi
COPY app/ .

EXPOSE 5000

ENV APP_VERSION=1.0.0 \
    APP_ENV=production

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# Jalankan dengan gunicorn (production-ready WSGI server)
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:app"]
