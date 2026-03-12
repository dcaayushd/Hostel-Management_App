FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    HOSTEL_HOST=0.0.0.0 \
    HOSTEL_PORT=8000 \
    HOSTEL_DB_PATH=/data/hostel.db

WORKDIR /app

COPY . /tmp/src

RUN mkdir -p /app/backend /data && \
    if [ -f /tmp/src/server.py ]; then \
      cp -R /tmp/src/. /app/backend/; \
    elif [ -f /tmp/src/backend/server.py ]; then \
      cp -R /tmp/src/backend/. /app/backend/; \
    else \
      echo "Backend sources not found in Docker build context." >&2; \
      exit 1; \
    fi && \
    rm -rf /tmp/src /app/backend/__pycache__ /app/backend/data /app/backend/tests

VOLUME ["/data"]

EXPOSE 8000

CMD ["python", "-m", "backend.server"]
