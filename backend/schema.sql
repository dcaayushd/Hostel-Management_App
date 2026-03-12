PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS rooms (
    id TEXT PRIMARY KEY,
    block TEXT NOT NULL,
    number TEXT NOT NULL,
    capacity INTEGER NOT NULL,
    room_type TEXT NOT NULL,
    UNIQUE(block, number)
);

CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    username TEXT NOT NULL UNIQUE,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    role TEXT NOT NULL,
    room_id TEXT REFERENCES rooms(id) ON DELETE SET NULL,
    job_title TEXT,
    email_verified INTEGER NOT NULL DEFAULT 0,
    email_verified_at TEXT
);

CREATE TABLE IF NOT EXISTS issues (
    id TEXT PRIMARY KEY,
    student_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category TEXT NOT NULL,
    comment TEXT NOT NULL,
    status TEXT NOT NULL,
    created_at TEXT NOT NULL,
    assigned_staff_id TEXT REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS gate_passes (
    id TEXT PRIMARY KEY,
    student_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    destination TEXT NOT NULL,
    reason TEXT NOT NULL,
    emergency_contact TEXT NOT NULL,
    pass_code TEXT NOT NULL,
    status TEXT NOT NULL,
    departure_at TEXT NOT NULL,
    expected_return_at TEXT NOT NULL,
    created_at TEXT NOT NULL,
    reviewed_at TEXT,
    checked_out_at TEXT,
    returned_at TEXT
);

CREATE TABLE IF NOT EXISTS notices (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    category TEXT NOT NULL,
    is_pinned INTEGER NOT NULL DEFAULT 0,
    posted_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS notifications (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL,
    created_at TEXT NOT NULL,
    read_at TEXT
);
