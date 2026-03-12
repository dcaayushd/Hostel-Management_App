# Python Backend

This backend is the real data source for the app:

- `sqlite3` stores persistent data in `backend/data/hostel.db`
- `http.server` exposes the JSON API used by Flutter
- SMTP can send real email verification and password-reset codes
- Passwords are stored as PBKDF2-SHA256 hashes, not plain text

## What is already real

- Rooms, users, notices, issues, fees, chat, parcels, gate passes, laundry, and mess data are stored in SQLite.
- The database file is created automatically on first run.
- Existing plaintext passwords from older local databases are upgraded automatically to hashed passwords on startup.
- Email verification and password reset use real SMTP when configured.

SQLite is fine for local development, demos, and single-instance deployment. If you later expect heavier concurrent production traffic, move the same schema to PostgreSQL.

## Project layout

- `lib/` is the Flutter client
- `backend/` is the Python backend service

That is already the correct monorepo structure. The important production step is deploying the backend as its own process/service.

## Step 1: Start the backend database and API

Run the backend:

```bash
python3 -m backend.server --host 127.0.0.1 --port 8000 --db-path backend/data/hostel.db
```

If you want demo seed data in a fresh database:

```bash
python3 -m backend.server --host 127.0.0.1 --port 8000 --db-path backend/data/hostel.db --demo-data
```

Check health:

```bash
curl http://127.0.0.1:8000/health
```

The backend also accepts deploy-friendly environment variables:

```bash
export HOSTEL_HOST=0.0.0.0
export HOSTEL_PORT=8000
export HOSTEL_DB_PATH=backend/data/hostel.db
python3 -m backend.server
```

It also respects standard platform `PORT` values used by managed hosts.

## Step 2: Create the first admin

For a clean database, bootstrap the admin once:

```bash
python3 -m backend.manage --db-path backend/data/hostel.db bootstrap-admin \
  --username admin \
  --first-name Hostel \
  --last-name Admin \
  --email admin@yourhostel.com \
  --password 'Admin@123' \
  --phone-number 9800000000
```

You can also bootstrap the first admin from the Flutter app, but the CLI is easier for direct database setup.

## Step 3: Create blocks and rooms

Create a block:

```bash
python3 -m backend.manage --db-path backend/data/hostel.db create-block \
  --code A \
  --name "Academic Block" \
  --description "Main student residence wing"
```

Create a room inside that block:

```bash
python3 -m backend.manage --db-path backend/data/hostel.db create-room \
  --block A \
  --number 101 \
  --capacity 2 \
  --room-type "Double Sharing"
```

List rooms:

```bash
python3 -m backend.manage --db-path backend/data/hostel.db list-rooms
```

## Step 4: Add real users directly to the database

Create a student:

```bash
python3 -m backend.manage --db-path backend/data/hostel.db create-user \
  --role student \
  --username aayush \
  --first-name Aayush \
  --last-name DC \
  --email aayush@example.com \
  --password 'Student@123' \
  --phone-number 9876543210 \
  --room-id room_a101 \
  --email-verified
```

Create a staff account:

```bash
python3 -m backend.manage --db-path backend/data/hostel.db create-user \
  --role staff \
  --username warden \
  --first-name Mangal \
  --last-name Karki \
  --email warden@yourhostel.com \
  --password 'Warden@123' \
  --phone-number 9804532792 \
  --job-title "Hostel Warden" \
  --email-verified
```

Create a guest account:

```bash
python3 -m backend.manage --db-path backend/data/hostel.db create-user \
  --role guest \
  --username guest01 \
  --first-name Guest \
  --last-name User \
  --email guest01@example.com \
  --password 'Guest@123' \
  --phone-number 9801234567
```

List users:

```bash
python3 -m backend.manage --db-path backend/data/hostel.db list-users
python3 -m backend.manage --db-path backend/data/hostel.db list-users --role student
```

## Step 5: Configure real email delivery

For Gmail SMTP, use an App Password, not your normal Gmail password.

```bash
export HOSTEL_SMTP_HOST=smtp.gmail.com
export HOSTEL_SMTP_PORT=465
export HOSTEL_SMTP_USERNAME=your-account@gmail.com
export HOSTEL_SMTP_PASSWORD=your-16-char-app-password
export HOSTEL_SMTP_FROM_EMAIL=your-account@gmail.com
python3 -m backend.server --host 127.0.0.1 --port 8000 --db-path backend/data/hostel.db
```

When SMTP is configured correctly:

- verification codes are emailed to the user
- password reset codes are emailed to the user

If SMTP is missing or fails, the backend falls back to local demo codes so development can continue.

## Step 6: Connect Flutter to the backend

For simulator/emulator:

```bash
flutter run --dart-define=HOSTEL_API_BASE_URL=http://127.0.0.1:8000
```

For a physical phone on the same Wi-Fi:

1. Find your Mac's LAN IP, for example `192.168.1.23`.
2. Start the backend so it listens on all interfaces:

```bash
python3 -m backend.server --host 0.0.0.0 --port 8000 --db-path backend/data/hostel.db
```

3. Run Flutter with your Mac IP:

```bash
flutter run --dart-define=HOSTEL_API_BASE_URL=http://192.168.1.23:8000
```

If you want to force the app to use mock data instead of the backend:

```bash
flutter run --dart-define=HOSTEL_FORCE_MOCK_BACKEND=true
```

## Operational notes

- Database file: `backend/data/hostel.db`
- Inspect DB manually if needed:

```bash
sqlite3 backend/data/hostel.db
```

- Back up DB:

```bash
cp backend/data/hostel.db backend/data/hostel-backup.db
```

- Docker image for deployment:

```bash
docker build -f backend/Dockerfile -t hostel-backend backend
```

## Remaining production upgrades

The backend is now suitable for a real local/single-instance deployment, but for heavier production you should still add:

1. Token-based auth/session management instead of trusting only client-side state.
2. Role-based authorization checks on every mutating endpoint.
3. Reverse proxy + TLS in front of the Python server.
4. Automated backups and secrets management.
5. PostgreSQL if you need higher write concurrency or multi-instance deployment.
