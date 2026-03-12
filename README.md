# Hostel Management App

Flutter hostel operations app with a production-oriented frontend structure, provider-based state management, and a Python backend option for real API-driven flows.

## What is implemented

- Login, logout, and student registration
- Role-aware dashboard for student, staff, and admin accounts
- Student issue creation with admin/staff issue resolution
- Staff directory with admin-only staff creation and deletion
- Room availability tracking with live occupancy data
- Student fee breakdown screen
- Student room change requests with admin/staff approval workflow

## Demo accounts

- Student: `student@hostel.local` / `Student@123`
- Admin: `admin@hostel.local` / `Admin@123`
- Staff: `warden@hostel.local` / `Warden@123`

## Project structure

```text
backend/            Python API server, SQLite storage, backend tests
lib/
  app/              app bootstrap, routing, theme
  core/models/      typed domain models
  core/services/    repository contract + mock backend + HTTP repository
  core/state/       provider state and app orchestration
  core/utils/       validators, feedback, formatting helpers
  core/widgets/     shared reusable UI blocks
  features/         auth, home, admin, and student screens
```

## How the backend is wired

All screens call the `HostelRepository` contract through `AppState`, so UI code is no longer hardcoded to placeholder values.

The app now supports two backend modes:

1. Python API mode
   This is now the default for local app runs. The app targets `http://127.0.0.1:8000` on iOS/macOS and `http://10.0.2.2:8000` on Android emulators unless overridden.
2. Mock mode
   Use `--dart-define=HOSTEL_FORCE_MOCK_BACKEND=true` when you want the in-app mock repository instead.

Run the Python backend:

```bash
python3 -m backend.server --host 127.0.0.1 --port 8000
```

Run Flutter against the Python backend:

```bash
flutter run --dart-define=HOSTEL_API_BASE_URL=http://127.0.0.1:8000
```

If you want verification and reset codes to be delivered to a real inbox, configure SMTP before starting the backend:

```bash
export HOSTEL_SMTP_HOST=smtp.gmail.com
export HOSTEL_SMTP_PORT=465
export HOSTEL_SMTP_USERNAME=your-account@gmail.com
export HOSTEL_SMTP_PASSWORD=your-app-password
export HOSTEL_SMTP_FROM_EMAIL=your-account@gmail.com
python3 -m backend.server --host 127.0.0.1 --port 8000
```

Backend details are also documented in [backend/README.md](/Users/dcaayushd/Development/Flutter_Dev/Flutter Projects/Hostel-Management_App/backend/README.md).

## Suggested next production steps

1. Add token-based auth and session persistence to the Python API.
2. Add local persistence for session restore and cached dashboard data.
3. Introduce end-to-end tests that boot the Python backend and hit the Flutter HTTP repository.
4. Add API error mapping and offline handling for network failure states.

## Verification

Run:

```bash
flutter analyze
flutter test
python3 -m unittest discover -s backend/tests
```
