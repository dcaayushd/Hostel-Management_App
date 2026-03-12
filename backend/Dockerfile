FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    HOSTEL_HOST=0.0.0.0 \
    HOSTEL_PORT=8000 \
    HOSTEL_DB_PATH=/data/hostel.db

WORKDIR /app

RUN mkdir -p /app/backend /data

COPY backend/__init__.py /app/backend/__init__.py
COPY backend/manage.py /app/backend/manage.py
COPY backend/repository.py /app/backend/repository.py
COPY backend/schema.sql /app/backend/schema.sql
COPY backend/server.py /app/backend/server.py

VOLUME ["/data"]

EXPOSE 8000

CMD ["python", "-m", "backend.server"]
