from __future__ import annotations

import base64
from contextlib import contextmanager
from email.message import EmailMessage
import hashlib
import hmac
import json
import os
import re
import secrets
import smtplib
import sqlite3
import ssl
import sys
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any, Protocol


ISSUE_STATUSES = {"open", "inProgress", "resolved"}
ROOM_REQUEST_STATUSES = {"pending", "approved", "rejected"}
USER_ROLES = {"student", "guest", "staff", "admin"}
PAYMENT_METHODS = {"eSewa", "card", "bankTransfer", "cash"}
PAYMENT_STATUSES = {"paid"}
PARCEL_STATUSES = {"awaitingPickup", "collected"}
LAUNDRY_BOOKING_STATUSES = {"scheduled", "completed", "cancelled"}
GATE_PASS_STATUSES = {
    "pending",
    "approved",
    "rejected",
    "checkedOut",
    "returned",
    "late",
}
NOTIFICATION_TYPES = {
    "fee",
    "notice",
    "chat",
    "complaint",
    "roomChange",
    "parcel",
    "gatePass",
}
AUTH_CHALLENGE_PURPOSES = {"verify-email", "password-reset"}
MESS_DAYS = (
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
    "sunday",
)
MEAL_TYPES = {"breakfast", "lunch", "dinner"}
MESS_BREAKFAST_RATE = 90
MESS_LUNCH_RATE = 140
MESS_DINNER_RATE = 130
DEFAULT_FEE_SETTINGS = {
    "maintenanceCharge": 1200,
    "parkingCharge": 350,
    "waterCharge": 550,
    "singleOccupancyCharge": 6200,
    "doubleSharingCharge": 5000,
    "tripleSharingCharge": 4300,
    "customCharges": [
        {"label": "Electricity", "amount": 500},
        {"label": "Wi-Fi", "amount": 300},
    ],
}
DEFAULT_ADMIN_CATALOG = {
    "issueCategories": [
        "Bathroom",
        "Bedroom",
        "Electricity",
        "Furniture",
        "Mess Food",
        "Water",
    ],
    "noticeCategories": [
        "Announcement",
        "Event",
        "Rule",
    ],
    "laundryMachines": [
        "Machine A",
        "Machine B",
        "Machine C",
    ],
    "parcelCarriers": [
        "DHL",
        "FedEx",
        "Nepal Post",
    ],
    "alertPresets": [
        {
            "title": "Urgent maintenance",
            "category": "Announcement",
            "message": "A facility maintenance update needs immediate attention.",
        },
        {
            "title": "Mess update",
            "category": "Event",
            "message": "There is an important change in today's mess service.",
        },
    ],
    "serviceShortcuts": [],
}
PASSWORD_HASH_ALGORITHM = "pbkdf2_sha256"
DEFAULT_PASSWORD_HASH_ITERATIONS = 120000
DEFAULT_AUTH_TOKEN_TTL_MINUTES = 60 * 24 * 30


@dataclass(slots=True)
class BackendError(Exception):
    message: str
    status_code: int = 400

    def __str__(self) -> str:
        return self.message


class AuthChallengeMailer(Protocol):
    def send_auth_challenge(
        self,
        *,
        email: str,
        purpose: str,
        code: str,
        expires_at: str,
    ) -> None: ...


@dataclass(slots=True)
class SmtpMailerConfig:
    host: str
    port: int
    from_email: str
    username: str | None
    password: str | None
    use_ssl: bool
    use_starttls: bool


class SmtpAuthChallengeMailer:
    def __init__(self, config: SmtpMailerConfig):
        self._config = config

    @classmethod
    def from_env(cls) -> SmtpAuthChallengeMailer | None:
        host = _optional_env("HOSTEL_SMTP_HOST")
        if host is None:
            return None
        port_raw = _optional_env("HOSTEL_SMTP_PORT") or "465"
        try:
            port = int(port_raw)
        except ValueError:
            print(
                "Invalid HOSTEL_SMTP_PORT value. Falling back to local auth codes.",
                file=sys.stderr,
            )
            return None
        username = _optional_env("HOSTEL_SMTP_USERNAME")
        password = _optional_env("HOSTEL_SMTP_PASSWORD")
        from_email = _optional_env("HOSTEL_SMTP_FROM_EMAIL") or username
        if from_email is None:
            print(
                "HOSTEL_SMTP_FROM_EMAIL or HOSTEL_SMTP_USERNAME is required for SMTP delivery.",
                file=sys.stderr,
            )
            return None
        use_ssl = _env_flag("HOSTEL_SMTP_USE_SSL", default=port == 465)
        use_starttls = _env_flag(
            "HOSTEL_SMTP_USE_STARTTLS",
            default=not use_ssl,
        )
        if use_ssl:
            use_starttls = False
        return cls(
            SmtpMailerConfig(
                host=host,
                port=port,
                from_email=from_email,
                username=username,
                password=password,
                use_ssl=use_ssl,
                use_starttls=use_starttls,
            )
        )

    def send_auth_challenge(
        self,
        *,
        email: str,
        purpose: str,
        code: str,
        expires_at: str,
    ) -> None:
        subject, body = self._compose_message(
            email=email,
            purpose=purpose,
            code=code,
            expires_at=expires_at,
        )
        message = EmailMessage()
        message["From"] = self._config.from_email
        message["To"] = email
        message["Subject"] = subject
        message.set_content(body)

        if self._config.use_ssl:
            with smtplib.SMTP_SSL(
                self._config.host,
                self._config.port,
                timeout=15,
                context=ssl.create_default_context(),
            ) as client:
                self._login_if_needed(client)
                client.send_message(message)
            return

        with smtplib.SMTP(
            self._config.host,
            self._config.port,
            timeout=15,
        ) as client:
            client.ehlo()
            if self._config.use_starttls:
                client.starttls(context=ssl.create_default_context())
                client.ehlo()
            self._login_if_needed(client)
            client.send_message(message)

    def _login_if_needed(self, client: smtplib.SMTP) -> None:
        if self._config.username and self._config.password:
            client.login(self._config.username, self._config.password)

    def _compose_message(
        self,
        *,
        email: str,
        purpose: str,
        code: str,
        expires_at: str,
    ) -> tuple[str, str]:
        if purpose == "verify-email":
            return (
                "Hostel Hub email verification code",
                (
                    f"Hello,\n\n"
                    f"Use this Hostel Hub verification code for {email}: {code}\n"
                    f"This code expires at {expires_at}.\n\n"
                    f"If you did not request this, you can ignore this email.\n"
                ),
            )
        return (
            "Hostel Hub password reset code",
            (
                f"Hello,\n\n"
                f"Use this Hostel Hub password reset code for {email}: {code}\n"
                f"This code expires at {expires_at}.\n\n"
                f"If you did not request this, you can ignore this email.\n"
            ),
        )


def _optional_env(name: str) -> str | None:
    value = os.getenv(name)
    if value is None:
        return None
    trimmed = value.strip()
    return trimmed or None


def _env_flag(name: str, *, default: bool) -> bool:
    value = _optional_env(name)
    if value is None:
        return default
    return value.lower() in {"1", "true", "yes", "on"}


def _password_hash_iterations() -> int:
    value = _optional_env("HOSTEL_PASSWORD_HASH_ITERATIONS")
    if value is None:
        return DEFAULT_PASSWORD_HASH_ITERATIONS
    try:
        iterations = int(value)
    except ValueError:
        print(
            "Invalid HOSTEL_PASSWORD_HASH_ITERATIONS value. Falling back to 120000.",
            file=sys.stderr,
        )
        return DEFAULT_PASSWORD_HASH_ITERATIONS
    if iterations < 100_000:
        print(
            "HOSTEL_PASSWORD_HASH_ITERATIONS is too low. Falling back to 120000.",
            file=sys.stderr,
        )
        return DEFAULT_PASSWORD_HASH_ITERATIONS
    return iterations


def _auth_token_ttl_minutes() -> int:
    value = _optional_env("HOSTEL_AUTH_TOKEN_TTL_MINUTES")
    if value is None:
        return DEFAULT_AUTH_TOKEN_TTL_MINUTES
    try:
        ttl_minutes = int(value)
    except ValueError:
        print(
            "Invalid HOSTEL_AUTH_TOKEN_TTL_MINUTES value. Falling back to 43200.",
            file=sys.stderr,
        )
        return DEFAULT_AUTH_TOKEN_TTL_MINUTES
    if ttl_minutes < 5:
        print(
            "HOSTEL_AUTH_TOKEN_TTL_MINUTES is too low. Falling back to 43200.",
            file=sys.stderr,
        )
        return DEFAULT_AUTH_TOKEN_TTL_MINUTES
    return ttl_minutes


def _urlsafe_b64encode(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode("ascii")


def _urlsafe_b64decode(value: str) -> bytes:
    padding = "=" * (-len(value) % 4)
    return base64.urlsafe_b64decode(f"{value}{padding}".encode("ascii"))


class HostelDataStore:
    def __init__(
        self,
        db_path: str | Path,
        *,
        demo_mode: bool = False,
        auth_challenge_mailer: AuthChallengeMailer | None = None,
    ):
        self.db_path = Path(db_path)
        self.demo_mode = demo_mode
        self._auth_challenge_mailer = (
            auth_challenge_mailer or SmtpAuthChallengeMailer.from_env()
        )
        self._auth_token_ttl_minutes = _auth_token_ttl_minutes()
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        self._auth_token_secret = self._load_or_create_auth_token_secret()
        self._initialize()

    def health(self) -> dict[str, Any]:
        with self._connect() as conn:
            blocks = conn.execute("SELECT COUNT(*) FROM blocks").fetchone()[0]
            rooms = conn.execute("SELECT COUNT(*) FROM rooms").fetchone()[0]
            users = conn.execute("SELECT COUNT(*) FROM users").fetchone()[0]
            issues = conn.execute("SELECT COUNT(*) FROM issues").fetchone()[0]
        return {
            "status": "ok",
            "storage": str(self.db_path),
            "demoMode": self.demo_mode,
            "emailDelivery": "smtp"
            if self._auth_challenge_mailer is not None
            else "local",
            "blocks": blocks,
            "rooms": rooms,
            "users": users,
            "issues": issues,
        }

    def setup_status(self) -> dict[str, Any]:
        with self._connect() as conn:
            admin_count = conn.execute(
                "SELECT COUNT(*) FROM users WHERE role = 'admin'"
            ).fetchone()[0]
        return {
            "requiresBootstrap": admin_count == 0,
            "demoMode": self.demo_mode,
        }

    def login(self, *, identifier: str, password: str) -> dict[str, Any]:
        normalized_identifier = identifier.strip().lower()
        is_phone_login = self._is_phone_number(normalized_identifier)
        with self._connect() as conn:
            row = conn.execute(
                """
                SELECT *
                FROM users
                WHERE (
                    lower(email) = ?
                    OR (? = 1 AND phone_number = ?)
                )
                """,
                (
                    normalized_identifier,
                    1 if is_phone_login else 0,
                    identifier.strip(),
                ),
            ).fetchone()
            if row is None:
                raise BackendError("Invalid email or password.", 401)
            normalized_password = password.strip()
            if not self._verify_password(normalized_password, row["password"]):
                raise BackendError("Invalid email or password.", 401)
            if not self._is_password_hashed(row["password"]):
                conn.execute(
                    "UPDATE users SET password = ? WHERE id = ?",
                    (
                        self._hash_password(normalized_password),
                        row["id"],
                    ),
                )
                row = conn.execute(
                    "SELECT * FROM users WHERE id = ?",
                    (row["id"],),
                ).fetchone()
            return self._user_from_row(
                row,
                auth_token=self._generate_auth_token(
                    user_id=row["id"],
                    user_role=row["role"],
                ),
            )

    def bootstrap_admin(
        self,
        *,
        username: str,
        first_name: str,
        last_name: str,
        email: str,
        password: str,
        phone_number: str,
    ) -> dict[str, Any]:
        normalized_username = username.strip()
        normalized_email = email.strip().lower()
        normalized_phone = phone_number.strip()
        self._validate_email(normalized_email)
        self._validate_password(password)
        if not self._is_phone_number(normalized_phone):
            raise BackendError("Enter a valid 10 digit phone number.")

        with self._connect() as conn:
            has_admin = conn.execute(
                "SELECT 1 FROM users WHERE role = 'admin' LIMIT 1"
            ).fetchone()
            if has_admin is not None:
                raise BackendError("An admin account is already configured.")

            self._ensure_unique_credentials(
                conn,
                email=normalized_email,
                username=normalized_username,
                phone_number=normalized_phone,
            )
            conn.execute(
                """
                INSERT INTO users (
                    id, username, first_name, last_name, email, password,
                    phone_number, role, room_id, job_title,
                    email_verified, email_verified_at
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, 'admin', NULL, ?, 1, ?)
                """,
                (
                    "admin_1",
                    normalized_username,
                    first_name.strip(),
                    last_name.strip(),
                    normalized_email,
                    self._hash_password(password.strip()),
                    normalized_phone,
                    "Hostel Admin",
                    self._utc_now(),
                ),
            )
            row = conn.execute(
                "SELECT * FROM users WHERE id = 'admin_1'"
            ).fetchone()
            self.demo_mode = False
            return self._user_from_row(
                row,
                auth_token=self._generate_auth_token(
                    user_id=row["id"],
                    user_role=row["role"],
                ),
            )

    def register_student(
        self,
        *,
        username: str,
        first_name: str,
        last_name: str,
        email: str,
        password: str,
        phone_number: str,
        room_id: str,
    ) -> dict[str, Any]:
        normalized_username = username.strip()
        normalized_email = email.strip().lower()
        normalized_phone = phone_number.strip()
        self._validate_email(normalized_email)
        self._validate_password(password)
        if not self._is_phone_number(normalized_phone):
            raise BackendError("Enter a valid 10 digit phone number.")

        with self._connect() as conn:
            self._ensure_unique_credentials(
                conn,
                email=normalized_email,
                username=normalized_username,
                phone_number=normalized_phone,
            )
            room = self._require_room(conn, room_id)
            if not self._room_has_availability(conn, room_id):
                raise BackendError("Selected room is already full.")

            user_id = self._new_id("student")
            conn.execute(
                """
                INSERT INTO users (
                    id, username, first_name, last_name, email, password,
                    phone_number, role, room_id, job_title,
                    email_verified, email_verified_at
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, 'student', ?, NULL, 0, NULL)
                """,
                (
                    user_id,
                    normalized_username,
                    first_name.strip(),
                    last_name.strip(),
                    normalized_email,
                    self._hash_password(password.strip()),
                    normalized_phone,
                    room_id,
                ),
            )
            self._write_fee_summary(
                conn,
                user_id=user_id,
                fee_summary=self._default_fee_for_room(conn, room),
            )
            created_user = conn.execute(
                "SELECT * FROM users WHERE id = ?",
                (user_id,),
            ).fetchone()
            return self._user_from_row(
                created_user,
                auth_token=self._generate_auth_token(
                    user_id=created_user["id"],
                    user_role=created_user["role"],
                ),
            )

    def register_guest(
        self,
        *,
        username: str,
        first_name: str,
        last_name: str,
        email: str,
        password: str,
        phone_number: str,
    ) -> dict[str, Any]:
        normalized_username = username.strip()
        normalized_email = email.strip().lower()
        normalized_phone = phone_number.strip()
        self._validate_email(normalized_email)
        self._validate_password(password)
        if not self._is_phone_number(normalized_phone):
            raise BackendError("Enter a valid 10 digit phone number.")

        with self._connect() as conn:
            self._ensure_unique_credentials(
                conn,
                email=normalized_email,
                username=normalized_username,
                phone_number=normalized_phone,
            )
            user_id = self._new_id("guest")
            conn.execute(
                """
                INSERT INTO users (
                    id, username, first_name, last_name, email, password,
                    phone_number, role, room_id, job_title,
                    email_verified, email_verified_at
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, 'guest', NULL, NULL, 0, NULL)
                """,
                (
                    user_id,
                    normalized_username,
                    first_name.strip(),
                    last_name.strip(),
                    normalized_email,
                    self._hash_password(password.strip()),
                    normalized_phone,
                ),
            )
            created_user = conn.execute(
                "SELECT * FROM users WHERE id = ?",
                (user_id,),
            ).fetchone()
            return self._user_from_row(
                created_user,
                auth_token=self._generate_auth_token(
                    user_id=created_user["id"],
                    user_role=created_user["role"],
                ),
            )

    def request_email_verification(self, *, email: str) -> dict[str, Any]:
        normalized_email = email.strip().lower()
        with self._connect() as conn:
            user = self._require_user_by_email(conn, normalized_email)
            if user["emailVerified"]:
                raise BackendError("Email is already verified.")
            return self._create_auth_challenge(
                conn,
                email=normalized_email,
                purpose="verify-email",
            )

    def verify_email(self, *, email: str, code: str) -> dict[str, Any]:
        normalized_email = email.strip().lower()
        with self._connect() as conn:
            row = self._consume_auth_challenge(
                conn,
                email=normalized_email,
                purpose="verify-email",
                code=code.strip(),
            )
            conn.execute(
                """
                UPDATE users
                SET email_verified = 1, email_verified_at = ?
                WHERE id = ?
                """,
                (self._utc_now(), row["id"]),
            )
            updated = conn.execute(
                "SELECT * FROM users WHERE id = ?",
                (row["id"],),
            ).fetchone()
            return self._user_from_row(
                updated,
                auth_token=self._generate_auth_token(
                    user_id=updated["id"],
                    user_role=updated["role"],
                ),
            )

    def request_password_reset(self, *, email: str) -> dict[str, Any]:
        normalized_email = email.strip().lower()
        with self._connect() as conn:
            self._require_user_by_email(conn, normalized_email)
            return self._create_auth_challenge(
                conn,
                email=normalized_email,
                purpose="password-reset",
            )

    def reset_password(
        self,
        *,
        email: str,
        code: str,
        new_password: str,
    ) -> dict[str, Any]:
        normalized_email = email.strip().lower()
        self._validate_password(new_password)
        with self._connect() as conn:
            row = self._consume_auth_challenge(
                conn,
                email=normalized_email,
                purpose="password-reset",
                code=code.strip(),
            )
            conn.execute(
                "UPDATE users SET password = ? WHERE id = ?",
                (
                    self._hash_password(new_password.strip()),
                    row["id"],
                ),
            )
            updated = conn.execute(
                "SELECT * FROM users WHERE id = ?",
                (row["id"],),
            ).fetchone()
            return self._user_from_row(
                updated,
                auth_token=self._generate_auth_token(
                    user_id=updated["id"],
                    user_role=updated["role"],
                ),
            )

    def get_user(self, user_id: str) -> dict[str, Any]:
        with self._connect() as conn:
            return self._require_user(conn, user_id)

    def list_students(self) -> list[dict[str, Any]]:
        with self._connect() as conn:
            rows = conn.execute(
                """
                SELECT *
                FROM users
                WHERE role = 'student'
                ORDER BY first_name, last_name
                """
            ).fetchall()
            return [self._user_from_row(row) for row in rows]

    def list_guests(self) -> list[dict[str, Any]]:
        with self._connect() as conn:
            rows = conn.execute(
                """
                SELECT *
                FROM users
                WHERE role = 'guest'
                ORDER BY first_name, last_name
                """
            ).fetchall()
            return [self._user_from_row(row) for row in rows]

    def list_staff(self) -> list[dict[str, Any]]:
        with self._connect() as conn:
            rows = conn.execute(
                """
                SELECT *
                FROM users
                WHERE role IN ('staff', 'admin')
                ORDER BY CASE role WHEN 'admin' THEN 0 ELSE 1 END, first_name, last_name
                """
            ).fetchall()
            return [self._user_from_row(row) for row in rows]

    def list_users(self, *, role: str | None = None) -> list[dict[str, Any]]:
        normalized_role = self._clean_optional(role)
        if normalized_role is not None:
            normalized_role = normalized_role.strip().lower()
            if normalized_role not in USER_ROLES:
                raise BackendError("Invalid user role.")
        with self._connect() as conn:
            if normalized_role is None:
                rows = conn.execute(
                    """
                    SELECT *
                    FROM users
                    ORDER BY CASE role
                        WHEN 'admin' THEN 0
                        WHEN 'staff' THEN 1
                        WHEN 'student' THEN 2
                        ELSE 3
                    END,
                    first_name,
                    last_name
                    """
                ).fetchall()
            else:
                rows = conn.execute(
                    """
                    SELECT *
                    FROM users
                    WHERE role = ?
                    ORDER BY first_name, last_name
                    """,
                    (normalized_role,),
                ).fetchall()
            return [self._user_from_row(row) for row in rows]

    def create_user_account(
        self,
        *,
        role: str,
        username: str,
        first_name: str,
        last_name: str,
        email: str,
        password: str,
        phone_number: str,
        room_id: str | None = None,
        job_title: str | None = None,
        email_verified: bool = False,
    ) -> dict[str, Any]:
        normalized_role = role.strip().lower()
        if normalized_role == "student":
            if self._clean_optional(room_id) is None:
                raise BackendError("roomId is required for student accounts.")
            created = self.register_student(
                username=username,
                first_name=first_name,
                last_name=last_name,
                email=email,
                password=password,
                phone_number=phone_number,
                room_id=room_id.strip(),
            )
        elif normalized_role == "guest":
            created = self.register_guest(
                username=username,
                first_name=first_name,
                last_name=last_name,
                email=email,
                password=password,
                phone_number=phone_number,
            )
        elif normalized_role == "staff":
            resolved_job_title = self._clean_optional(job_title)
            if resolved_job_title is None:
                raise BackendError("jobTitle is required for staff accounts.")
            created = self.create_staff(
                username=username,
                first_name=first_name,
                last_name=last_name,
                email=email,
                password=password,
                phone_number=phone_number,
                job_title=resolved_job_title,
            )
        elif normalized_role == "admin":
            created = self.bootstrap_admin(
                username=username,
                first_name=first_name,
                last_name=last_name,
                email=email,
                password=password,
                phone_number=phone_number,
            )
        else:
            raise BackendError("Invalid user role.")

        if email_verified and not created["emailVerified"]:
            with self._connect() as conn:
                conn.execute(
                    """
                    UPDATE users
                    SET email_verified = 1,
                        email_verified_at = COALESCE(email_verified_at, ?)
                    WHERE id = ?
                    """,
                    (self._utc_now(), created["id"]),
                )
                row = conn.execute(
                    "SELECT * FROM users WHERE id = ?",
                    (created["id"],),
                ).fetchone()
                return self._user_from_row(row)
        return created

    def list_chat_messages(self, user_id: str) -> list[dict[str, Any]]:
        with self._connect() as conn:
            user = self._require_user(conn, user_id)
            if user["role"] in {"student", "guest"}:
                rows = conn.execute(
                    """
                    SELECT *
                    FROM chat_messages
                    WHERE sender_id = ? OR recipient_id = ?
                    ORDER BY sent_at ASC
                    """,
                    (user_id, user_id),
                ).fetchall()
            else:
                rows = conn.execute(
                    """
                    SELECT message.*
                    FROM chat_messages message
                    JOIN users sender ON sender.id = message.sender_id
                    JOIN users recipient ON recipient.id = message.recipient_id
                    WHERE sender.role IN (?, ?)
                       OR recipient.role IN (?, ?)
                    ORDER BY message.sent_at ASC
                    """,
                    ("student", "guest", "student", "guest"),
                ).fetchall()
            return [self._chat_message_from_row(row) for row in rows]

    def send_chat_message(
        self,
        *,
        sender_id: str,
        recipient_id: str,
        message: str,
    ) -> dict[str, Any]:
        normalized_message = message.strip()
        if not normalized_message:
            raise BackendError("message is required.")
        with self._connect() as conn:
            sender = self._require_user(conn, sender_id)
            recipient = self._require_user(conn, recipient_id)
            message_id = self._new_id("chat")
            sent_at = self._utc_now()
            conn.execute(
                """
                INSERT INTO chat_messages (
                    id, sender_id, recipient_id, message, sent_at, read_at
                )
                VALUES (?, ?, ?, ?, ?, NULL)
                """,
                (
                    message_id,
                    sender["id"],
                    recipient["id"],
                    normalized_message,
                    sent_at,
                ),
            )
            self._notify_user(
                conn,
                user_id=recipient["id"],
                title="New message",
                message=(
                    f"{sender['firstName']} {sender['lastName']}: "
                    f"{normalized_message}"
                ),
                type="chat",
            )
            row = conn.execute(
                "SELECT * FROM chat_messages WHERE id = ?",
                (message_id,),
            ).fetchone()
            return self._chat_message_from_row(row)

    def mark_chat_thread_read(self, *, user_id: str, partner_id: str) -> None:
        with self._connect() as conn:
            self._require_user(conn, user_id)
            self._require_user(conn, partner_id)
            conn.execute(
                """
                UPDATE chat_messages
                SET read_at = ?
                WHERE recipient_id = ?
                  AND sender_id = ?
                  AND read_at IS NULL
                """,
                (self._utc_now(), user_id, partner_id),
            )

    def list_notifications(self, user_id: str) -> list[dict[str, Any]]:
        with self._connect() as conn:
            self._require_user(conn, user_id)
            rows = conn.execute(
                """
                SELECT *
                FROM notifications
                WHERE user_id = ?
                ORDER BY created_at DESC
                """,
                (user_id,),
            ).fetchall()
            return [self._notification_from_row(row) for row in rows]

    def mark_notification_read(self, notification_id: str) -> dict[str, Any]:
        with self._connect() as conn:
            row = conn.execute(
                "SELECT * FROM notifications WHERE id = ?",
                (notification_id,),
            ).fetchone()
            if row is None:
                raise BackendError("Notification not found.", 404)

            read_at = self._utc_now()
            conn.execute(
                "UPDATE notifications SET read_at = ? WHERE id = ?",
                (read_at, notification_id),
            )
            updated = conn.execute(
                "SELECT * FROM notifications WHERE id = ?",
                (notification_id,),
            ).fetchone()
            return self._notification_from_row(updated)

    def mark_all_notifications_read(self, user_id: str) -> None:
        with self._connect() as conn:
            self._require_user(conn, user_id)
            conn.execute(
                """
                UPDATE notifications
                SET read_at = ?
                WHERE user_id = ? AND read_at IS NULL
                """,
                (self._utc_now(), user_id),
            )

    def list_blocks(self) -> list[dict[str, Any]]:
        with self._connect() as conn:
            rows = conn.execute(
                """
                SELECT *
                FROM blocks
                ORDER BY code
                """
            ).fetchall()
            return [self._block_from_row(row) for row in rows]

    def create_block(
        self,
        *,
        code: str,
        name: str,
        description: str | None = None,
    ) -> dict[str, Any]:
        normalized_code = code.strip().upper()
        if not normalized_code:
            raise BackendError("Block code is required.")

        with self._connect() as conn:
            existing = conn.execute(
                "SELECT 1 FROM blocks WHERE code = ?",
                (normalized_code,),
            ).fetchone()
            if existing is not None:
                raise BackendError("That block already exists.")

            conn.execute(
                """
                INSERT INTO blocks (code, name, description)
                VALUES (?, ?, ?)
                """,
                (
                    normalized_code,
                    name.strip() or f"Block {normalized_code}",
                    self._clean_optional(description),
                ),
            )
            row = conn.execute(
                "SELECT * FROM blocks WHERE code = ?",
                (normalized_code,),
            ).fetchone()
            return self._block_from_row(row)

    def list_rooms(self) -> list[dict[str, Any]]:
        with self._connect() as conn:
            rows = conn.execute(
                """
                SELECT *
                FROM rooms
                ORDER BY block, number
                """
            ).fetchall()
            return [self._room_from_row(conn, row) for row in rows]

    def create_room(
        self,
        *,
        block: str,
        number: str,
        capacity: int,
        room_type: str,
    ) -> dict[str, Any]:
        normalized_block = block.strip().upper()
        normalized_number = number.strip().upper()

        if not normalized_number:
            raise BackendError("Room number is required.")
        if capacity < 1:
            raise BackendError("Room capacity must be at least 1.")

        with self._connect() as conn:
            self._require_block(conn, normalized_block)
            duplicate = conn.execute(
                """
                SELECT 1
                FROM rooms
                WHERE block = ? AND number = ?
                """,
                (normalized_block, normalized_number),
            ).fetchone()
            if duplicate is not None:
                raise BackendError(
                    "That room already exists in the selected block."
                )

            room_id = self._new_room_id(normalized_block, normalized_number)
            conn.execute(
                """
                INSERT INTO rooms (id, block, number, capacity, room_type)
                VALUES (?, ?, ?, ?, ?)
                """,
                (
                    room_id,
                    normalized_block,
                    normalized_number,
                    capacity,
                    room_type.strip(),
                ),
            )
            row = conn.execute(
                "SELECT * FROM rooms WHERE id = ?",
                (room_id,),
            ).fetchone()
            return self._room_from_row(conn, row)

    def assign_resident_room(
        self,
        *,
        user_id: str,
        room_id: str,
    ) -> dict[str, Any]:
        with self._connect() as conn:
            student = self._require_user(conn, user_id)
            if student["role"] != "student":
                raise BackendError(
                    "Only student residents can be assigned to rooms."
                )

            current_room_id = student["roomId"]
            desired_room = self._require_room(conn, room_id)
            room_changed = current_room_id != room_id
            if room_changed and not self._room_has_availability(conn, room_id):
                raise BackendError("Selected room is already full.")

            conn.execute(
                "UPDATE users SET room_id = ? WHERE id = ?",
                (room_id, user_id),
            )
            self._write_fee_summary(
                conn,
                user_id=user_id,
                fee_summary=self._default_fee_for_room(conn, desired_room),
            )

            if room_changed:
                pending_request = conn.execute(
                    """
                    SELECT id, desired_room_id
                    FROM room_change_requests
                    WHERE student_id = ? AND status = 'pending'
                    """,
                    (user_id,),
                ).fetchone()
                if pending_request is not None:
                    conn.execute(
                        """
                        UPDATE room_change_requests
                        SET status = ?, resolved_at = ?
                        WHERE id = ?
                        """,
                        (
                            "approved"
                            if pending_request["desired_room_id"] == room_id
                            else "rejected",
                            self._utc_now(),
                            pending_request["id"],
                        ),
                    )

            updated = conn.execute(
                "SELECT * FROM users WHERE id = ?",
                (user_id,),
            ).fetchone()
            self._notify_user(
                conn,
                user_id=user_id,
                title="Room assignment updated"
                if room_changed
                else "Room assignment set",
                message=f"Your room assignment is now {desired_room['block']}-{desired_room['number']}.",
                type="roomChange",
            )
            return self._user_from_row(updated)

    def list_issues(
        self,
        *,
        user_id: str | None = None,
        role: str | None = None,
        job_title: str | None = None,
    ) -> list[dict[str, Any]]:
        query = """
            SELECT *
            FROM issues
        """
        parameters: tuple[Any, ...] = ()

        if role is not None:
            normalized_role = role.strip()
            if normalized_role not in USER_ROLES:
                raise BackendError("Invalid user role supplied for issue access.", 400)
            normalized_job_title = (job_title or "").strip().lower()
            if normalized_role == "student":
                query += " WHERE student_id = ?"
                parameters = (user_id,)
            elif normalized_role == "staff" and "warden" not in normalized_job_title:
                query += " WHERE assigned_staff_id = ?"
                parameters = (user_id,)
            elif normalized_role not in {"admin", "staff"}:
                query += " WHERE 1 = 0"

        query += " ORDER BY created_at DESC"

        with self._connect() as conn:
            rows = conn.execute(query, parameters).fetchall()
            return [self._issue_from_row(row) for row in rows]

    def get_issue(self, issue_id: str) -> dict[str, Any]:
        with self._connect() as conn:
            row = conn.execute(
                "SELECT * FROM issues WHERE id = ?",
                (issue_id,),
            ).fetchone()
            if row is None:
                raise BackendError("Issue not found.", 404)
            return self._issue_from_row(row)

    def list_gate_passes(self) -> list[dict[str, Any]]:
        with self._connect() as conn:
            rows = conn.execute(
                """
                SELECT *
                FROM gate_passes
                ORDER BY created_at DESC
                """
            ).fetchall()
            return [self._gate_pass_from_row(row) for row in rows]

    def create_gate_pass(
        self,
        *,
        student_id: str,
        destination: str,
        reason: str,
        emergency_contact: str,
        departure_at: str,
        expected_return_at: str,
    ) -> dict[str, Any]:
        departure_dt = datetime.fromisoformat(departure_at)
        expected_return_dt = datetime.fromisoformat(expected_return_at)
        if expected_return_dt <= departure_dt:
            raise BackendError("Return time must be after departure time.")

        with self._connect() as conn:
            student = self._require_user(conn, student_id)
            if student["role"] != "student":
                raise BackendError(
                    "Gate passes can only be requested for student accounts."
                )

            gate_pass_id = self._new_id("gatepass")
            created_at = self._utc_now()
            pass_code = self._pass_code(departure_dt)
            conn.execute(
                """
                INSERT INTO gate_passes (
                    id, student_id, destination, reason, emergency_contact,
                    pass_code, status, departure_at, expected_return_at,
                    created_at, reviewed_at, checked_out_at, returned_at
                )
                VALUES (?, ?, ?, ?, ?, ?, 'pending', ?, ?, ?, NULL, NULL, NULL)
                """,
                (
                    gate_pass_id,
                    student_id,
                    destination.strip(),
                    reason.strip(),
                    emergency_contact.strip(),
                    pass_code,
                    departure_at,
                    expected_return_at,
                    created_at,
                ),
            )
            row = conn.execute(
                "SELECT * FROM gate_passes WHERE id = ?",
                (gate_pass_id,),
            ).fetchone()
            self._notify_user(
                conn,
                user_id=student_id,
                title="Gate pass submitted",
                message=f"Your leave request for {destination.strip()} is pending.",
                type="gatePass",
                created_at=created_at,
            )
            return self._gate_pass_from_row(row)

    def review_gate_pass(
        self,
        *,
        gate_pass_id: str,
        status: str,
    ) -> dict[str, Any]:
        if status not in {"approved", "rejected"}:
            raise BackendError("Gate pass review must be approved or rejected.")

        with self._connect() as conn:
            current = conn.execute(
                "SELECT * FROM gate_passes WHERE id = ?",
                (gate_pass_id,),
            ).fetchone()
            if current is None:
                raise BackendError("Gate pass not found.", 404)
            if current["status"] != "pending":
                raise BackendError("Only pending gate passes can be reviewed.")

            reviewed_at = self._utc_now()
            conn.execute(
                """
                UPDATE gate_passes
                SET status = ?, reviewed_at = ?
                WHERE id = ?
                """,
                (status, reviewed_at, gate_pass_id),
            )
            updated = conn.execute(
                "SELECT * FROM gate_passes WHERE id = ?",
                (gate_pass_id,),
            ).fetchone()
            self._notify_user(
                conn,
                user_id=updated["student_id"],
                title="Gate pass updated",
                message=(
                    f"Your gate pass for {updated['destination']} "
                    f"was {status.lower()}."
                ),
                type="gatePass",
            )
            return self._gate_pass_from_row(updated)

    def mark_gate_pass_departure(self, gate_pass_id: str) -> dict[str, Any]:
        with self._connect() as conn:
            current = conn.execute(
                "SELECT * FROM gate_passes WHERE id = ?",
                (gate_pass_id,),
            ).fetchone()
            if current is None:
                raise BackendError("Gate pass not found.", 404)
            if current["status"] != "approved":
                raise BackendError(
                    "Only approved gate passes can be checked out."
                )

            checked_out_at = self._utc_now()
            conn.execute(
                """
                UPDATE gate_passes
                SET status = 'checkedOut', checked_out_at = ?
                WHERE id = ?
                """,
                (checked_out_at, gate_pass_id),
            )
            updated = conn.execute(
                "SELECT * FROM gate_passes WHERE id = ?",
                (gate_pass_id,),
            ).fetchone()
            self._notify_user(
                conn,
                user_id=updated["student_id"],
                title="Exit recorded",
                message=f"Gate exit recorded for {updated['destination']}.",
                type="gatePass",
            )
            return self._gate_pass_from_row(updated)

    def mark_gate_pass_return(self, gate_pass_id: str) -> dict[str, Any]:
        with self._connect() as conn:
            current = conn.execute(
                "SELECT * FROM gate_passes WHERE id = ?",
                (gate_pass_id,),
            ).fetchone()
            if current is None:
                raise BackendError("Gate pass not found.", 404)
            if current["status"] not in {"checkedOut", "late"}:
                raise BackendError(
                    "Only checked out gate passes can be closed."
                )

            expected_return_at = self._parse_iso_datetime(
                current["expected_return_at"]
            )
            returned_at = self._now_for_datetime(expected_return_at)
            resolved_status = (
                "late" if returned_at > expected_return_at else "returned"
            )
            conn.execute(
                """
                UPDATE gate_passes
                SET status = ?, returned_at = ?
                WHERE id = ?
                """,
                (resolved_status, returned_at.isoformat(), gate_pass_id),
            )
            updated = conn.execute(
                "SELECT * FROM gate_passes WHERE id = ?",
                (gate_pass_id,),
            ).fetchone()
            self._notify_user(
                conn,
                user_id=updated["student_id"],
                title="Gate pass closed",
                message=(
                    "You returned after the expected time."
                    if resolved_status == "late"
                    else "Your gate pass was closed successfully."
                ),
                type="gatePass",
            )
            return self._gate_pass_from_row(updated)

    def list_parcels(self) -> list[dict[str, Any]]:
        with self._connect() as conn:
            rows = conn.execute(
                """
                SELECT *
                FROM parcels
                ORDER BY CASE status WHEN 'awaitingPickup' THEN 0 ELSE 1 END,
                         created_at DESC
                """
            ).fetchall()
            return [self._parcel_from_row(row) for row in rows]

    def create_parcel(
        self,
        *,
        user_id: str,
        carrier: str,
        tracking_code: str,
        note: str,
    ) -> dict[str, Any]:
        with self._connect() as conn:
            user = self._require_user(conn, user_id)
            if user["role"] != "student":
                raise BackendError(
                    "Parcels can only be recorded for student accounts."
                )

            parcel_id = self._new_id("parcel")
            created_at = self._utc_now()
            conn.execute(
                """
                INSERT INTO parcels (
                    id, user_id, carrier, tracking_code, note,
                    status, created_at, notified_at, collected_at
                )
                VALUES (?, ?, ?, ?, ?, 'awaitingPickup', ?, ?, NULL)
                """,
                (
                    parcel_id,
                    user_id,
                    carrier.strip(),
                    tracking_code.strip(),
                    note.strip(),
                    created_at,
                    created_at,
                ),
            )
            row = conn.execute(
                "SELECT * FROM parcels WHERE id = ?",
                (parcel_id,),
            ).fetchone()
            self._notify_user(
                conn,
                user_id=user_id,
                title="Parcel arrived",
                message=f"{carrier.strip()} delivery is ready at the desk.",
                type="parcel",
                created_at=created_at,
            )
            return self._parcel_from_row(row)

    def mark_parcel_collected(self, parcel_id: str) -> dict[str, Any]:
        with self._connect() as conn:
            current = conn.execute(
                "SELECT * FROM parcels WHERE id = ?",
                (parcel_id,),
            ).fetchone()
            if current is None:
                raise BackendError("Parcel not found.", 404)

            if current["status"] == "collected":
                return self._parcel_from_row(current)

            collected_at = self._utc_now()
            conn.execute(
                """
                UPDATE parcels
                SET status = 'collected', collected_at = ?
                WHERE id = ?
                """,
                (collected_at, parcel_id),
            )
            updated = conn.execute(
                "SELECT * FROM parcels WHERE id = ?",
                (parcel_id,),
            ).fetchone()
            self._notify_user(
                conn,
                user_id=updated["user_id"],
                title="Parcel collected",
                message=(
                    f"Your {updated['carrier']} parcel was marked as collected."
                ),
                type="parcel",
            )
            return self._parcel_from_row(updated)

    def list_visitor_entries(self) -> list[dict[str, Any]]:
        with self._connect() as conn:
            rows = conn.execute(
                """
                SELECT *
                FROM visitor_entries
                ORDER BY CASE WHEN checked_out_at IS NULL THEN 0 ELSE 1 END,
                         checked_in_at DESC
                """
            ).fetchall()
            return [self._visitor_entry_from_row(row) for row in rows]

    def create_visitor_entry(
        self,
        *,
        student_id: str,
        visitor_name: str,
        relation: str,
        note: str,
    ) -> dict[str, Any]:
        with self._connect() as conn:
            student = self._require_user(conn, student_id)
            if student["role"] != "student":
                raise BackendError(
                    "Visitors can only be logged for student accounts."
                )

            visitor_id = self._new_id("visitor")
            checked_in_at = self._utc_now()
            conn.execute(
                """
                INSERT INTO visitor_entries (
                    id, student_id, visitor_name, relation,
                    note, checked_in_at, checked_out_at
                )
                VALUES (?, ?, ?, ?, ?, ?, NULL)
                """,
                (
                    visitor_id,
                    student_id,
                    visitor_name.strip(),
                    relation.strip(),
                    note.strip(),
                    checked_in_at,
                ),
            )
            row = conn.execute(
                "SELECT * FROM visitor_entries WHERE id = ?",
                (visitor_id,),
            ).fetchone()
            return self._visitor_entry_from_row(row)

    def check_out_visitor(self, visitor_id: str) -> dict[str, Any]:
        with self._connect() as conn:
            current = conn.execute(
                "SELECT * FROM visitor_entries WHERE id = ?",
                (visitor_id,),
            ).fetchone()
            if current is None:
                raise BackendError("Visitor entry not found.", 404)

            if current["checked_out_at"] is not None:
                return self._visitor_entry_from_row(current)

            checked_out_at = self._utc_now()
            conn.execute(
                """
                UPDATE visitor_entries
                SET checked_out_at = ?
                WHERE id = ?
                """,
                (checked_out_at, visitor_id),
            )
            updated = conn.execute(
                "SELECT * FROM visitor_entries WHERE id = ?",
                (visitor_id,),
            ).fetchone()
            return self._visitor_entry_from_row(updated)

    def list_laundry_bookings(self) -> list[dict[str, Any]]:
        with self._connect() as conn:
            rows = conn.execute(
                """
                SELECT *
                FROM laundry_bookings
                ORDER BY scheduled_at ASC, machine_label ASC
                """
            ).fetchall()
            return [self._laundry_booking_from_row(row) for row in rows]

    def get_admin_catalog(self) -> dict[str, Any]:
        with self._connect() as conn:
            row = self._get_admin_catalog_row(conn)
            return self._admin_catalog_from_row(row)

    def update_admin_catalog(
        self,
        *,
        issue_categories: list[str],
        notice_categories: list[str],
        laundry_machines: list[str],
        parcel_carriers: list[str],
        alert_presets: list[dict[str, Any]],
        service_shortcuts: list[dict[str, Any]],
    ) -> dict[str, Any]:
        normalized_issue_categories = self._normalize_string_list(
            issue_categories,
            default_values=DEFAULT_ADMIN_CATALOG["issueCategories"],
        )
        normalized_notice_categories = self._normalize_string_list(
            notice_categories,
            default_values=DEFAULT_ADMIN_CATALOG["noticeCategories"],
        )
        normalized_laundry_machines = self._normalize_string_list(
            laundry_machines,
            default_values=DEFAULT_ADMIN_CATALOG["laundryMachines"],
        )
        normalized_parcel_carriers = self._normalize_string_list(
            parcel_carriers,
            default_values=DEFAULT_ADMIN_CATALOG["parcelCarriers"],
        )
        normalized_alert_presets = self._normalize_alert_presets(
            alert_presets,
            normalized_notice_categories,
        )
        normalized_service_shortcuts = self._normalize_service_shortcuts(
            service_shortcuts
        )

        with self._connect() as conn:
            conn.execute(
                """
                UPDATE admin_catalog
                SET issue_categories_json = ?,
                    notice_categories_json = ?,
                    laundry_machines_json = ?,
                    parcel_carriers_json = ?,
                    alert_presets_json = ?,
                    service_shortcuts_json = ?
                WHERE id = 1
                """,
                (
                    json.dumps(normalized_issue_categories),
                    json.dumps(normalized_notice_categories),
                    json.dumps(normalized_laundry_machines),
                    json.dumps(normalized_parcel_carriers),
                    json.dumps(normalized_alert_presets),
                    json.dumps(normalized_service_shortcuts),
                ),
            )
            row = self._get_admin_catalog_row(conn)
            return self._admin_catalog_from_row(row)

    def create_laundry_booking(
        self,
        *,
        user_id: str,
        scheduled_at: str,
        slot_label: str,
        machine_label: str,
        notes: str,
    ) -> dict[str, Any]:
        scheduled_dt = datetime.fromisoformat(scheduled_at)
        normalized_machine_label = machine_label.strip()
        with self._connect() as conn:
            user = self._require_user(conn, user_id)
            if user["role"] != "student":
                raise BackendError(
                    "Laundry bookings are available only for student accounts."
                )
            admin_catalog = self._admin_catalog_from_row(
                self._get_admin_catalog_row(conn)
            )
            if normalized_machine_label not in admin_catalog["laundryMachines"]:
                raise BackendError("Select a valid laundry machine.")
            conflict = conn.execute(
                """
                SELECT id
                FROM laundry_bookings
                WHERE machine_label = ?
                  AND slot_label = ?
                  AND date(scheduled_at) = date(?)
                  AND status = 'scheduled'
                """,
                (
                    normalized_machine_label,
                    slot_label.strip(),
                    scheduled_at,
                ),
            ).fetchone()
            if conflict is not None:
                raise BackendError(
                    "That machine is already booked for the selected slot."
                )

            booking_id = self._new_id("laundry")
            created_at = self._utc_now()
            conn.execute(
                """
                INSERT INTO laundry_bookings (
                    id, user_id, machine_label, slot_label, scheduled_at,
                    notes, status, created_at, completed_at
                )
                VALUES (?, ?, ?, ?, ?, ?, 'scheduled', ?, NULL)
                """,
                (
                    booking_id,
                    user_id,
                    normalized_machine_label,
                    slot_label.strip(),
                    scheduled_dt.isoformat(),
                    notes.strip(),
                    created_at,
                ),
            )
            row = conn.execute(
                "SELECT * FROM laundry_bookings WHERE id = ?",
                (booking_id,),
            ).fetchone()
            return self._laundry_booking_from_row(row)

    def update_laundry_booking_status(
        self,
        *,
        booking_id: str,
        status: str,
    ) -> dict[str, Any]:
        if status not in LAUNDRY_BOOKING_STATUSES:
            raise BackendError("Invalid laundry booking status.")

        with self._connect() as conn:
            current = conn.execute(
                "SELECT * FROM laundry_bookings WHERE id = ?",
                (booking_id,),
            ).fetchone()
            if current is None:
                raise BackendError("Laundry booking not found.", 404)

            completed_at = None if status == "scheduled" else self._utc_now()
            conn.execute(
                """
                UPDATE laundry_bookings
                SET status = ?, completed_at = ?
                WHERE id = ?
                """,
                (status, completed_at, booking_id),
            )
            updated = conn.execute(
                "SELECT * FROM laundry_bookings WHERE id = ?",
                (booking_id,),
            ).fetchone()
            return self._laundry_booking_from_row(updated)

    def list_mess_menu(self) -> list[dict[str, Any]]:
        with self._connect() as conn:
            rows = conn.execute(
                """
                SELECT *
                FROM mess_menu
                ORDER BY CASE day
                    WHEN 'monday' THEN 0
                    WHEN 'tuesday' THEN 1
                    WHEN 'wednesday' THEN 2
                    WHEN 'thursday' THEN 3
                    WHEN 'friday' THEN 4
                    WHEN 'saturday' THEN 5
                    WHEN 'sunday' THEN 6
                END
                """
            ).fetchall()
            return [self._mess_menu_from_row(row) for row in rows]

    def update_mess_menu_day(
        self,
        *,
        day: str,
        breakfast: str,
        lunch: str,
        dinner: str,
    ) -> dict[str, Any]:
        normalized_day = day.strip().lower()
        if normalized_day not in MESS_DAYS:
            raise BackendError("Invalid mess menu day.")

        with self._connect() as conn:
            existing = conn.execute(
                """
                SELECT *
                FROM mess_menu
                WHERE day = ?
                """,
                (normalized_day,),
            ).fetchone()
            if existing is None:
                conn.execute(
                    """
                    INSERT INTO mess_menu (day, breakfast, lunch, dinner)
                    VALUES (?, ?, ?, ?)
                    """,
                    (
                        normalized_day,
                        breakfast.strip(),
                        lunch.strip(),
                        dinner.strip(),
                    ),
                )
            else:
                conn.execute(
                    """
                    UPDATE mess_menu
                    SET breakfast = ?, lunch = ?, dinner = ?
                    WHERE day = ?
                    """,
                    (
                        breakfast.strip(),
                        lunch.strip(),
                        dinner.strip(),
                        normalized_day,
                    ),
                )
            row = conn.execute(
                """
                SELECT *
                FROM mess_menu
                WHERE day = ?
                """,
                (normalized_day,),
            ).fetchone()
            return self._mess_menu_from_row(row)

    def list_meal_attendance(self) -> list[dict[str, Any]]:
        with self._connect() as conn:
            rows = conn.execute(
                """
                SELECT *
                FROM meal_attendance
                ORDER BY date DESC, user_id ASC
                """
            ).fetchall()
            return [self._meal_attendance_from_row(row) for row in rows]

    def mark_meal_attendance(
        self,
        *,
        user_id: str,
        day: str,
        meal_type: str,
        attended: bool,
    ) -> dict[str, Any]:
        normalized_day = day.strip().lower()
        normalized_meal = meal_type.strip()
        if normalized_day not in MESS_DAYS:
            raise BackendError("Invalid attendance day.")
        if normalized_meal not in MEAL_TYPES:
            raise BackendError("Invalid meal type.")

        with self._connect() as conn:
            user = self._require_user(conn, user_id)
            if user["role"] != "student":
                raise BackendError("Only students can update meal attendance.")

            current = conn.execute(
                """
                SELECT *
                FROM meal_attendance
                WHERE user_id = ? AND day = ?
                """,
                (user_id, normalized_day),
            ).fetchone()
            record_date = self._mess_date_for_day(normalized_day)

            if current is None:
                attendance_id = self._new_id("attendance")
                values = {
                    "breakfast": 0,
                    "lunch": 0,
                    "dinner": 0,
                }
                values[normalized_meal] = int(attended)
                conn.execute(
                    """
                    INSERT INTO meal_attendance (
                        id, user_id, day, date, breakfast, lunch, dinner
                    )
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                    """,
                    (
                        attendance_id,
                        user_id,
                        normalized_day,
                        record_date,
                        values["breakfast"],
                        values["lunch"],
                        values["dinner"],
                    ),
                )
                row = conn.execute(
                    """
                    SELECT *
                    FROM meal_attendance
                    WHERE id = ?
                    """,
                    (attendance_id,),
                ).fetchone()
                return self._meal_attendance_from_row(row)

            conn.execute(
                f"""
                UPDATE meal_attendance
                SET {normalized_meal} = ?, date = ?
                WHERE id = ?
                """,
                (int(attended), record_date, current["id"]),
            )
            updated = conn.execute(
                """
                SELECT *
                FROM meal_attendance
                WHERE id = ?
                """,
                (current["id"],),
            ).fetchone()
            return self._meal_attendance_from_row(updated)

    def list_mess_feedback(self) -> list[dict[str, Any]]:
        with self._connect() as conn:
            rows = conn.execute(
                """
                SELECT *
                FROM mess_feedback
                ORDER BY submitted_at DESC
                """
            ).fetchall()
            return [self._mess_feedback_from_row(row) for row in rows]

    def create_mess_feedback(
        self,
        *,
        user_id: str,
        rating: int,
        comment: str,
    ) -> dict[str, Any]:
        if rating < 1 or rating > 5:
            raise BackendError("Ratings must be between 1 and 5.")

        with self._connect() as conn:
            user = self._require_user(conn, user_id)
            if user["role"] != "student":
                raise BackendError("Only students can submit mess feedback.")

            feedback_id = self._new_id("feedback")
            submitted_at = self._utc_now()
            conn.execute(
                """
                INSERT INTO mess_feedback (
                    id, user_id, rating, comment, submitted_at
                )
                VALUES (?, ?, ?, ?, ?)
                """,
                (
                    feedback_id,
                    user_id,
                    rating,
                    comment.strip(),
                    submitted_at,
                ),
            )
            row = conn.execute(
                """
                SELECT *
                FROM mess_feedback
                WHERE id = ?
                """,
                (feedback_id,),
            ).fetchone()
            return self._mess_feedback_from_row(row)

    def get_mess_bill(self, user_id: str) -> dict[str, Any]:
        with self._connect() as conn:
            self._require_user(conn, user_id)
            rows = conn.execute(
                """
                SELECT *
                FROM meal_attendance
                WHERE user_id = ?
                """,
                (user_id,),
            ).fetchall()
            return self._mess_bill_from_rows(rows)

    def list_notices(self) -> list[dict[str, Any]]:
        with self._connect() as conn:
            rows = conn.execute(
                """
                SELECT *
                FROM notices
                ORDER BY is_pinned DESC, posted_at DESC
                """
            ).fetchall()
            return [self._notice_from_row(row) for row in rows]

    def create_notice(
        self,
        *,
        title: str,
        message: str,
        category: str,
        is_pinned: bool = False,
    ) -> dict[str, Any]:
        normalized_category = category.strip()
        if not normalized_category:
            raise BackendError("Notice category is required.")

        with self._connect() as conn:
            admin_catalog = self._admin_catalog_from_row(
                self._get_admin_catalog_row(conn)
            )
            if normalized_category not in admin_catalog["noticeCategories"]:
                raise BackendError("Select a valid notice category.")
            notice_id = self._new_id("notice")
            posted_at = self._utc_now()
            conn.execute(
                """
                INSERT INTO notices (
                    id, title, message, category, is_pinned, posted_at
                )
                VALUES (?, ?, ?, ?, ?, ?)
                """,
                (
                    notice_id,
                    title.strip(),
                    message.strip(),
                    normalized_category,
                    int(is_pinned),
                    posted_at,
                ),
            )
            row = conn.execute(
                "SELECT * FROM notices WHERE id = ?",
                (notice_id,),
            ).fetchone()
            user_ids = [
                item["id"]
                for item in conn.execute("SELECT id FROM users ORDER BY id").fetchall()
            ]
            self._notify_many(
                conn,
                user_ids=user_ids,
                title=title.strip(),
                message=message.strip(),
                type="notice",
                created_at=posted_at,
            )
            return self._notice_from_row(row)

    def create_issue(
        self,
        *,
        student_id: str,
        category: str,
        comment: str,
    ) -> dict[str, Any]:
        normalized_comment = comment.strip()
        if not normalized_comment:
            raise BackendError("comment is required.")
        with self._connect() as conn:
            student = self._require_user(conn, student_id)
            if student["role"] != "student":
                raise BackendError("Only students can create issues.")
            normalized_category = category.strip()
            admin_catalog = self._admin_catalog_from_row(
                self._get_admin_catalog_row(conn)
            )
            if normalized_category not in admin_catalog["issueCategories"]:
                raise BackendError("Select a valid issue category.")

            issue_id = self._new_id("issue")
            created_at = self._utc_now()
            conn.execute(
                """
                INSERT INTO issues (
                    id, student_id, category, comment, status, created_at,
                    assigned_staff_id
                )
                VALUES (?, ?, ?, ?, 'open', ?, NULL)
                """,
                (
                    issue_id,
                    student_id,
                    normalized_category,
                    normalized_comment,
                    created_at,
                ),
            )
            row = conn.execute(
                "SELECT * FROM issues WHERE id = ?",
                (issue_id,),
            ).fetchone()
            self._notify_user(
                conn,
                user_id=student_id,
                title="Complaint submitted",
                message=(
                    f"Your {normalized_category.lower()} issue is now in review."
                ),
                type="complaint",
                created_at=created_at,
            )
            return self._issue_from_row(row)

    def update_issue_status(
        self,
        *,
        issue_id: str,
        status: str,
    ) -> dict[str, Any]:
        if status not in ISSUE_STATUSES:
            raise BackendError("Invalid issue status.")

        with self._connect() as conn:
            current = conn.execute(
                "SELECT * FROM issues WHERE id = ?",
                (issue_id,),
            ).fetchone()
            if current is None:
                raise BackendError("Issue not found.", 404)

            conn.execute(
                "UPDATE issues SET status = ? WHERE id = ?",
                (status, issue_id),
            )
            updated = conn.execute(
                "SELECT * FROM issues WHERE id = ?",
                (issue_id,),
            ).fetchone()
            self._notify_user(
                conn,
                user_id=updated["student_id"],
                title="Complaint updated",
                message=f"Issue status changed to {status}.",
                type="complaint",
            )
            return self._issue_from_row(updated)

    def assign_issue(
        self,
        *,
        issue_id: str,
        staff_id: str,
    ) -> dict[str, Any]:
        with self._connect() as conn:
            issue = conn.execute(
                "SELECT * FROM issues WHERE id = ?",
                (issue_id,),
            ).fetchone()
            if issue is None:
                raise BackendError("Issue not found.", 404)
            student = self._require_user(conn, issue["student_id"])
            staff = self._require_user(conn, staff_id)
            if staff["role"] not in {"staff", "admin"}:
                raise BackendError("Select a valid staff member.")
            status = issue["status"]
            next_status = "inProgress" if status == "open" else status
            conn.execute(
                """
                UPDATE issues
                SET assigned_staff_id = ?, status = ?
                WHERE id = ?
                """,
                (staff_id, next_status, issue_id),
            )
            updated = conn.execute(
                "SELECT * FROM issues WHERE id = ?",
                (issue_id,),
            ).fetchone()
            self._notify_user(
                conn,
                user_id=updated["student_id"],
                title="Complaint assigned",
                message=f"Your complaint is assigned to {staff['firstName']} {staff['lastName']}.",
                type="complaint",
            )
            self._notify_user(
                conn,
                user_id=staff_id,
                title="Issue assigned",
                message=(
                    f"You have been assigned the {updated['category'].lower()} issue "
                    f"reported by {student['firstName']} {student['lastName']}."
                ),
                type="complaint",
            )
            return self._issue_from_row(updated)

    def create_staff(
        self,
        *,
        username: str,
        first_name: str,
        last_name: str,
        email: str,
        password: str,
        phone_number: str,
        job_title: str,
    ) -> dict[str, Any]:
        normalized_username = username.strip()
        normalized_email = email.strip().lower()
        normalized_phone = phone_number.strip()
        self._validate_email(normalized_email)
        self._validate_password(password)
        if not self._is_phone_number(normalized_phone):
            raise BackendError("Enter a valid 10 digit phone number.")

        with self._connect() as conn:
            self._ensure_unique_credentials(
                conn,
                email=normalized_email,
                username=normalized_username,
                phone_number=normalized_phone,
            )
            user_id = self._new_id("staff")
            conn.execute(
                """
                INSERT INTO users (
                    id, username, first_name, last_name, email, password,
                    phone_number, role, room_id, job_title,
                    email_verified, email_verified_at
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, 'staff', NULL, ?, 1, ?)
                """,
                (
                    user_id,
                    normalized_username,
                    first_name.strip(),
                    last_name.strip(),
                    normalized_email,
                    self._hash_password(password.strip()),
                    normalized_phone,
                    job_title.strip(),
                    self._utc_now(),
                ),
            )
            row = conn.execute(
                "SELECT * FROM users WHERE id = ?",
                (user_id,),
            ).fetchone()
            return self._user_from_row(row)

    def delete_staff(self, staff_id: str) -> None:
        with self._connect() as conn:
            row = conn.execute(
                "SELECT * FROM users WHERE id = ?",
                (staff_id,),
            ).fetchone()
            if row is None or row["role"] not in {"staff", "admin"}:
                raise BackendError("Staff member not found.", 404)
            if row["role"] == "admin":
                raise BackendError("Admins cannot be deleted.")

            conn.execute("DELETE FROM users WHERE id = ?", (staff_id,))

    def prepare_clean_workspace(self, *, admin_id: str) -> None:
        with self._connect() as conn:
            admin = self._require_user(conn, admin_id)
            if admin["role"] != "admin":
                raise BackendError(
                    "Only admin accounts can prepare a clean workspace.",
                    403,
                )

            conn.execute("DELETE FROM notifications")
            conn.execute("DELETE FROM chat_messages")
            conn.execute("DELETE FROM auth_challenges")
            conn.execute("DELETE FROM payment_records")
            conn.execute("DELETE FROM fee_summaries")
            conn.execute("DELETE FROM room_change_requests")
            conn.execute("DELETE FROM mess_feedback")
            conn.execute("DELETE FROM meal_attendance")
            conn.execute("DELETE FROM laundry_bookings")
            conn.execute("DELETE FROM visitor_entries")
            conn.execute("DELETE FROM parcels")
            conn.execute("DELETE FROM gate_passes")
            conn.execute("DELETE FROM issues")
            conn.execute("DELETE FROM notices")
            conn.execute("DELETE FROM mess_menu")
            conn.execute("DELETE FROM users WHERE id != ?", (admin_id,))
            conn.execute("DELETE FROM rooms")
            conn.execute("DELETE FROM blocks")
            conn.execute(
                """
                UPDATE users
                SET room_id = NULL,
                    job_title = COALESCE(job_title, 'Hostel Admin'),
                    email_verified = 1,
                    email_verified_at = COALESCE(email_verified_at, ?)
                WHERE id = ?
                """,
                (self._utc_now(), admin_id),
            )
            conn.execute(
                """
                UPDATE fee_settings
                SET maintenance_charge = ?,
                    parking_charge = ?,
                    water_charge = ?,
                    single_occupancy_charge = ?,
                    double_sharing_charge = ?,
                    triple_sharing_charge = ?,
                    custom_charges_json = ?
                WHERE id = 1
                """,
                (
                    DEFAULT_FEE_SETTINGS["maintenanceCharge"],
                    DEFAULT_FEE_SETTINGS["parkingCharge"],
                    DEFAULT_FEE_SETTINGS["waterCharge"],
                    DEFAULT_FEE_SETTINGS["singleOccupancyCharge"],
                    DEFAULT_FEE_SETTINGS["doubleSharingCharge"],
                    DEFAULT_FEE_SETTINGS["tripleSharingCharge"],
                    json.dumps(DEFAULT_FEE_SETTINGS["customCharges"]),
                ),
            )
            conn.execute(
                """
                UPDATE admin_catalog
                SET issue_categories_json = ?,
                    notice_categories_json = ?,
                    laundry_machines_json = ?,
                    parcel_carriers_json = ?,
                    alert_presets_json = ?,
                    service_shortcuts_json = ?
                WHERE id = 1
                """,
                (
                    json.dumps(DEFAULT_ADMIN_CATALOG["issueCategories"]),
                    json.dumps(DEFAULT_ADMIN_CATALOG["noticeCategories"]),
                    json.dumps(DEFAULT_ADMIN_CATALOG["laundryMachines"]),
                    json.dumps(DEFAULT_ADMIN_CATALOG["parcelCarriers"]),
                    json.dumps(DEFAULT_ADMIN_CATALOG["alertPresets"]),
                    json.dumps(DEFAULT_ADMIN_CATALOG["serviceShortcuts"]),
                ),
            )
            self._ensure_mess_menu_rows(conn)
            self.demo_mode = False

    def list_room_change_requests(self) -> list[dict[str, Any]]:
        with self._connect() as conn:
            rows = conn.execute(
                """
                SELECT *
                FROM room_change_requests
                ORDER BY created_at DESC
                """
            ).fetchall()
            return [self._room_request_from_row(row) for row in rows]

    def create_room_change_request(
        self,
        *,
        student_id: str,
        desired_room_id: str,
        reason: str,
    ) -> dict[str, Any]:
        with self._connect() as conn:
            student = self._require_user(conn, student_id)
            current_room_id = student["roomId"]
            if student["role"] != "student" or current_room_id is None:
                raise BackendError(
                    "Only assigned students can create room requests."
                )
            if current_room_id == desired_room_id:
                raise BackendError(
                    "Choose a room different from your current room."
                )

            self._require_room(conn, desired_room_id)
            if not self._room_has_availability(conn, desired_room_id):
                raise BackendError("Desired room is not available.")

            pending_request = conn.execute(
                """
                SELECT id
                FROM room_change_requests
                WHERE student_id = ? AND status = 'pending'
                """,
                (student_id,),
            ).fetchone()
            if pending_request is not None:
                raise BackendError(
                    "You already have a pending room change request."
                )

            request_id = self._new_id("request")
            created_at = self._utc_now()
            conn.execute(
                """
                INSERT INTO room_change_requests (
                    id, student_id, current_room_id, desired_room_id,
                    reason, status, created_at, resolved_at
                )
                VALUES (?, ?, ?, ?, ?, 'pending', ?, NULL)
                """,
                (
                    request_id,
                    student_id,
                    current_room_id,
                    desired_room_id,
                    reason.strip(),
                    created_at,
                ),
            )
            row = conn.execute(
                "SELECT * FROM room_change_requests WHERE id = ?",
                (request_id,),
            ).fetchone()
            return self._room_request_from_row(row)

    def update_room_change_request_status(
        self,
        *,
        request_id: str,
        status: str,
    ) -> dict[str, Any]:
        if status not in ROOM_REQUEST_STATUSES:
            raise BackendError("Invalid room request status.")

        with self._connect() as conn:
            current = conn.execute(
                "SELECT * FROM room_change_requests WHERE id = ?",
                (request_id,),
            ).fetchone()
            if current is None:
                raise BackendError("Request not found.", 404)

            if current["status"] != "pending":
                if current["status"] == status:
                    return self._room_request_from_row(current)
                raise BackendError("Only pending requests can be updated.")

            if status == "approved":
                student = self._require_user(conn, current["student_id"])
                if student["roomId"] is None:
                    raise BackendError("Student is not assigned to a room.")
                desired_room = self._require_room(conn, current["desired_room_id"])
                if not self._room_has_availability(
                    conn,
                    current["desired_room_id"],
                ):
                    raise BackendError("Desired room is no longer available.")

                conn.execute(
                    "UPDATE users SET room_id = ? WHERE id = ?",
                    (current["desired_room_id"], current["student_id"]),
                )
                self._write_fee_summary(
                    conn,
                    user_id=current["student_id"],
                    fee_summary=self._default_fee_for_room(conn, desired_room),
                )

            resolved_at = self._utc_now()
            conn.execute(
                """
                UPDATE room_change_requests
                SET status = ?, resolved_at = ?
                WHERE id = ?
                """,
                (status, resolved_at, request_id),
            )
            updated = conn.execute(
                "SELECT * FROM room_change_requests WHERE id = ?",
                (request_id,),
            ).fetchone()
            self._notify_user(
                conn,
                user_id=updated["student_id"],
                title=f"Room request {status.lower()}",
                message=f"Your room change request was {status.lower()}.",
                type="roomChange",
            )
            return self._room_request_from_row(updated)

    def get_fee_summary(self, user_id: str) -> dict[str, Any]:
        with self._connect() as conn:
            user = self._require_user(conn, user_id)
            return self._ensure_current_fee_summary(
                conn,
                user_id=user_id,
                user=user,
            )

    def get_payment_history(self, user_id: str) -> list[dict[str, Any]]:
        with self._connect() as conn:
            self._require_user(conn, user_id)
            rows = conn.execute(
                """
                SELECT *
                FROM payment_records
                WHERE user_id = ?
                ORDER BY paid_at DESC
                """,
                (user_id,),
            ).fetchall()
            return [self._payment_from_row(row) for row in rows]

    def pay_fee(self, *, user_id: str, payment_method: str) -> dict[str, Any]:
        if payment_method not in PAYMENT_METHODS:
            raise BackendError("Unsupported payment method.")

        with self._connect() as conn:
            user = self._require_user(conn, user_id)
            if user["role"] != "student":
                raise BackendError("Only students can complete hostel payments.")

            summary = self._ensure_current_fee_summary(
                conn,
                user_id=user_id,
                user=user,
            )
            if summary["balance"] <= 0:
                raise BackendError("No pending fee balance found.")

            payment_id = self._new_id("payment")
            paid_at = self._utc_now()
            receipt_id = self._receipt_id()
            conn.execute(
                """
                INSERT INTO payment_records (
                    id, user_id, amount, payment_method, status,
                    receipt_id, billing_month, paid_at
                )
                VALUES (?, ?, ?, ?, 'paid', ?, ?, ?)
                """,
                (
                    payment_id,
                    user_id,
                    summary["balance"],
                    payment_method,
                    receipt_id,
                    summary["billingMonth"],
                    paid_at,
                ),
            )
            self._write_fee_summary(
                conn,
                user_id=user_id,
                fee_summary={
                    **summary,
                    "paidAmount": summary["total"],
                },
            )
            payment_row = conn.execute(
                """
                SELECT *
                FROM payment_records
                WHERE id = ?
                """,
                (payment_id,),
            ).fetchone()
            return self._payment_from_row(payment_row)

    def send_fee_reminder(self, user_id: str) -> dict[str, Any]:
        with self._connect() as conn:
            user = self._require_user(conn, user_id)
            if user["role"] != "student":
                raise BackendError(
                    "Fee reminders are available only for student accounts."
                )
            summary = self._ensure_current_fee_summary(
                conn,
                user_id=user_id,
                user=user,
            )
            if summary["isPaid"]:
                raise BackendError("This resident has no pending hostel fees.")
            self._write_fee_summary(
                conn,
                user_id=user_id,
                fee_summary={
                    **summary,
                    "lastReminderAt": self._utc_now(),
                },
            )
            updated_row = conn.execute(
                """
                SELECT *
                FROM fee_summaries
                WHERE user_id = ?
                """,
                (user_id,),
            ).fetchone()
            updated_summary = self._fee_summary_from_row(updated_row)
            self._notify_user(
                conn,
                user_id=user_id,
                title="Fee reminder",
                message=(
                    f"Hostel fees for {updated_summary['billingMonth']} are still pending."
                ),
                type="fee",
            )
            return updated_summary

    def _ensure_current_fee_summary(
        self,
        conn: sqlite3.Connection,
        *,
        user_id: str,
        user: sqlite3.Row | None = None,
    ) -> dict[str, Any]:
        resolved_user = user or self._require_user(conn, user_id)
        room_id = resolved_user["roomId"]
        if room_id is None:
            fee_summary = self._default_fee_without_room(conn)
        else:
            fee_summary = self._default_fee_for_room(
                conn,
                self._require_room(conn, room_id),
            )
        self._write_fee_summary(conn, user_id=user_id, fee_summary=fee_summary)
        summary_row = conn.execute(
            """
            SELECT *
            FROM fee_summaries
            WHERE user_id = ?
            """,
            (user_id,),
        ).fetchone()
        if summary_row is None:
            raise BackendError("Fee summary not found.", 404)
        return self._fee_summary_from_row(summary_row)

    def get_fee_settings(self) -> dict[str, Any]:
        with self._connect() as conn:
            row = self._get_fee_settings_row(conn)
            return self._fee_settings_from_row(row)

    def update_fee_settings(
        self,
        *,
        maintenance_charge: int,
        parking_charge: int,
        water_charge: int,
        single_occupancy_charge: int,
        double_sharing_charge: int,
        triple_sharing_charge: int,
        custom_charges: list[dict[str, Any]],
    ) -> dict[str, Any]:
        values = (
            maintenance_charge,
            parking_charge,
            water_charge,
            single_occupancy_charge,
            double_sharing_charge,
            triple_sharing_charge,
        )
        if any(value < 0 for value in values):
            raise BackendError("Fee values must be zero or greater.")
        normalized_custom_charges = self._ensure_default_fee_charge_items(
            self._normalize_fee_charge_items(custom_charges)
        )

        with self._connect() as conn:
            conn.execute(
                """
                UPDATE fee_settings
                SET maintenance_charge = ?,
                    parking_charge = ?,
                    water_charge = ?,
                    single_occupancy_charge = ?,
                    double_sharing_charge = ?,
                    triple_sharing_charge = ?,
                    custom_charges_json = ?
                WHERE id = 1
                """,
                (*values, json.dumps(normalized_custom_charges)),
            )
            self._rebuild_student_fee_summaries(conn)
            row = self._get_fee_settings_row(conn)
            return self._fee_settings_from_row(row)

    def _initialize(self) -> None:
        with self._connect() as conn:
            conn.executescript(
                """
                PRAGMA foreign_keys = ON;

                CREATE TABLE IF NOT EXISTS blocks (
                    code TEXT PRIMARY KEY,
                    name TEXT NOT NULL,
                    description TEXT
                );

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

                CREATE TABLE IF NOT EXISTS parcels (
                    id TEXT PRIMARY KEY,
                    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                    carrier TEXT NOT NULL,
                    tracking_code TEXT NOT NULL,
                    note TEXT NOT NULL,
                    status TEXT NOT NULL,
                    created_at TEXT NOT NULL,
                    notified_at TEXT,
                    collected_at TEXT
                );

                CREATE TABLE IF NOT EXISTS visitor_entries (
                    id TEXT PRIMARY KEY,
                    student_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                    visitor_name TEXT NOT NULL,
                    relation TEXT NOT NULL,
                    note TEXT NOT NULL,
                    checked_in_at TEXT NOT NULL,
                    checked_out_at TEXT
                );

                CREATE TABLE IF NOT EXISTS laundry_bookings (
                    id TEXT PRIMARY KEY,
                    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                    machine_label TEXT NOT NULL,
                    slot_label TEXT NOT NULL,
                    scheduled_at TEXT NOT NULL,
                    notes TEXT NOT NULL,
                    status TEXT NOT NULL,
                    created_at TEXT NOT NULL,
                    completed_at TEXT
                );

                CREATE TABLE IF NOT EXISTS mess_menu (
                    day TEXT PRIMARY KEY,
                    breakfast TEXT NOT NULL,
                    lunch TEXT NOT NULL,
                    dinner TEXT NOT NULL
                );

                CREATE TABLE IF NOT EXISTS meal_attendance (
                    id TEXT PRIMARY KEY,
                    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                    day TEXT NOT NULL,
                    date TEXT NOT NULL,
                    breakfast INTEGER NOT NULL DEFAULT 0,
                    lunch INTEGER NOT NULL DEFAULT 0,
                    dinner INTEGER NOT NULL DEFAULT 0,
                    UNIQUE(user_id, day)
                );

                CREATE TABLE IF NOT EXISTS mess_feedback (
                    id TEXT PRIMARY KEY,
                    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                    rating INTEGER NOT NULL,
                    comment TEXT NOT NULL,
                    submitted_at TEXT NOT NULL
                );

                CREATE TABLE IF NOT EXISTS notices (
                    id TEXT PRIMARY KEY,
                    title TEXT NOT NULL,
                    message TEXT NOT NULL,
                    category TEXT NOT NULL,
                    is_pinned INTEGER NOT NULL DEFAULT 0,
                    posted_at TEXT NOT NULL
                );

                CREATE TABLE IF NOT EXISTS room_change_requests (
                    id TEXT PRIMARY KEY,
                    student_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                    current_room_id TEXT NOT NULL REFERENCES rooms(id),
                    desired_room_id TEXT NOT NULL REFERENCES rooms(id),
                    reason TEXT NOT NULL,
                    status TEXT NOT NULL,
                    created_at TEXT NOT NULL,
                    resolved_at TEXT
                );

                CREATE TABLE IF NOT EXISTS fee_settings (
                    id INTEGER PRIMARY KEY CHECK (id = 1),
                    maintenance_charge INTEGER NOT NULL,
                    parking_charge INTEGER NOT NULL,
                    water_charge INTEGER NOT NULL,
                    single_occupancy_charge INTEGER NOT NULL,
                    double_sharing_charge INTEGER NOT NULL,
                    triple_sharing_charge INTEGER NOT NULL,
                    custom_charges_json TEXT NOT NULL DEFAULT '[]'
                );

                CREATE TABLE IF NOT EXISTS fee_summaries (
                    user_id TEXT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
                    maintenance_charge INTEGER NOT NULL,
                    parking_charge INTEGER NOT NULL,
                    water_charge INTEGER NOT NULL,
                    room_charge INTEGER NOT NULL,
                    extra_charges_json TEXT NOT NULL DEFAULT '[]',
                    billing_month TEXT,
                    due_date TEXT,
                    paid_amount INTEGER NOT NULL DEFAULT 0,
                    last_reminder_at TEXT
                );

                CREATE TABLE IF NOT EXISTS admin_catalog (
                    id INTEGER PRIMARY KEY CHECK (id = 1),
                    issue_categories_json TEXT NOT NULL,
                    notice_categories_json TEXT NOT NULL,
                    laundry_machines_json TEXT NOT NULL,
                    parcel_carriers_json TEXT NOT NULL,
                    alert_presets_json TEXT NOT NULL,
                    service_shortcuts_json TEXT NOT NULL
                );

                CREATE TABLE IF NOT EXISTS payment_records (
                    id TEXT PRIMARY KEY,
                    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                    amount INTEGER NOT NULL,
                    payment_method TEXT NOT NULL,
                    status TEXT NOT NULL,
                    receipt_id TEXT NOT NULL UNIQUE,
                    billing_month TEXT NOT NULL,
                    paid_at TEXT NOT NULL
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

                CREATE TABLE IF NOT EXISTS chat_messages (
                    id TEXT PRIMARY KEY,
                    sender_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                    recipient_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                    message TEXT NOT NULL,
                    sent_at TEXT NOT NULL,
                    read_at TEXT
                );

                CREATE TABLE IF NOT EXISTS auth_challenges (
                    id TEXT PRIMARY KEY,
                    email TEXT NOT NULL,
                    purpose TEXT NOT NULL,
                    code TEXT NOT NULL,
                    created_at TEXT NOT NULL,
                    expires_at TEXT NOT NULL,
                    consumed_at TEXT
                );
                """
            )
            conn.execute(
                "CREATE INDEX IF NOT EXISTS idx_users_role ON users(role)"
            )
            conn.execute(
                "CREATE INDEX IF NOT EXISTS idx_users_room_id ON users(room_id)"
            )
            conn.execute(
                "CREATE INDEX IF NOT EXISTS idx_users_phone_number ON users(phone_number)"
            )
            conn.execute(
                "CREATE INDEX IF NOT EXISTS idx_notifications_user_created ON notifications(user_id, created_at DESC)"
            )
            conn.execute(
                "CREATE INDEX IF NOT EXISTS idx_chat_messages_participants ON chat_messages(sender_id, recipient_id, sent_at)"
            )
            conn.execute(
                "CREATE INDEX IF NOT EXISTS idx_auth_challenges_lookup ON auth_challenges(email, purpose, consumed_at, expires_at)"
            )
            self._ensure_column(
                conn,
                table="issues",
                column="assigned_staff_id",
                definition="TEXT REFERENCES users(id) ON DELETE SET NULL",
            )
            self._ensure_column(
                conn,
                table="fee_summaries",
                column="billing_month",
                definition="TEXT",
            )
            self._ensure_column(
                conn,
                table="fee_summaries",
                column="due_date",
                definition="TEXT",
            )
            self._ensure_column(
                conn,
                table="fee_summaries",
                column="paid_amount",
                definition="INTEGER NOT NULL DEFAULT 0",
            )
            self._ensure_column(
                conn,
                table="fee_summaries",
                column="last_reminder_at",
                definition="TEXT",
            )
            self._ensure_column(
                conn,
                table="fee_settings",
                column="custom_charges_json",
                definition="TEXT NOT NULL DEFAULT '[]'",
            )
            self._ensure_column(
                conn,
                table="fee_summaries",
                column="extra_charges_json",
                definition="TEXT NOT NULL DEFAULT '[]'",
            )
            self._ensure_column(
                conn,
                table="users",
                column="email_verified",
                definition="INTEGER NOT NULL DEFAULT 0",
            )
            self._ensure_column(
                conn,
                table="users",
                column="email_verified_at",
                definition="TEXT",
            )
            self._migrate_password_storage(conn)

            fee_settings_count = conn.execute(
                "SELECT COUNT(*) FROM fee_settings"
            ).fetchone()[0]
            if fee_settings_count == 0:
                conn.execute(
                    """
                    INSERT INTO fee_settings (
                        id, maintenance_charge, parking_charge, water_charge,
                        single_occupancy_charge, double_sharing_charge,
                        triple_sharing_charge, custom_charges_json
                    )
                    VALUES (1, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    (
                        DEFAULT_FEE_SETTINGS["maintenanceCharge"],
                        DEFAULT_FEE_SETTINGS["parkingCharge"],
                        DEFAULT_FEE_SETTINGS["waterCharge"],
                        DEFAULT_FEE_SETTINGS["singleOccupancyCharge"],
                        DEFAULT_FEE_SETTINGS["doubleSharingCharge"],
                        DEFAULT_FEE_SETTINGS["tripleSharingCharge"],
                        json.dumps(DEFAULT_FEE_SETTINGS["customCharges"]),
                    ),
                )
            else:
                conn.execute(
                    """
                    UPDATE fee_settings
                    SET custom_charges_json = COALESCE(NULLIF(custom_charges_json, ''), '[]')
                    WHERE id = 1
                    """
                )

            admin_catalog_count = conn.execute(
                "SELECT COUNT(*) FROM admin_catalog"
            ).fetchone()[0]
            if admin_catalog_count == 0:
                conn.execute(
                    """
                    INSERT INTO admin_catalog (
                        id,
                        issue_categories_json,
                        notice_categories_json,
                        laundry_machines_json,
                        parcel_carriers_json,
                        alert_presets_json,
                        service_shortcuts_json
                    )
                    VALUES (1, ?, ?, ?, ?, ?, ?)
                    """,
                    (
                        json.dumps(DEFAULT_ADMIN_CATALOG["issueCategories"]),
                        json.dumps(DEFAULT_ADMIN_CATALOG["noticeCategories"]),
                        json.dumps(DEFAULT_ADMIN_CATALOG["laundryMachines"]),
                        json.dumps(DEFAULT_ADMIN_CATALOG["parcelCarriers"]),
                        json.dumps(DEFAULT_ADMIN_CATALOG["alertPresets"]),
                        json.dumps(DEFAULT_ADMIN_CATALOG["serviceShortcuts"]),
                    ),
                )

            self._ensure_mess_menu_rows(conn)

            room_count = conn.execute("SELECT COUNT(*) FROM rooms").fetchone()[0]
            if room_count == 0 and self.demo_mode:
                self._seed(conn)

            block_count = conn.execute("SELECT COUNT(*) FROM blocks").fetchone()[0]
            if block_count == 0:
                self._sync_blocks_from_rooms(conn)

            if self.demo_mode:
                self._ensure_demo_scale(conn)
                self._backfill_fee_summary_metadata(conn)

                notices_count = conn.execute(
                    "SELECT COUNT(*) FROM notices"
                ).fetchone()[0]
                if notices_count == 0:
                    self._seed_notices(conn)

                gate_pass_count = conn.execute(
                    "SELECT COUNT(*) FROM gate_passes"
                ).fetchone()[0]
                if gate_pass_count == 0:
                    self._seed_gate_passes(conn)

                parcel_count = conn.execute(
                    "SELECT COUNT(*) FROM parcels"
                ).fetchone()[0]
                if parcel_count == 0:
                    self._seed_parcels(conn)

                visitor_count = conn.execute(
                    "SELECT COUNT(*) FROM visitor_entries"
                ).fetchone()[0]
                if visitor_count == 0:
                    self._seed_visitors(conn)

                laundry_count = conn.execute(
                    "SELECT COUNT(*) FROM laundry_bookings"
                ).fetchone()[0]
                if laundry_count == 0:
                    self._seed_laundry_bookings(conn)

                self._seed_mess_menu(conn)

                mess_attendance_count = conn.execute(
                    "SELECT COUNT(*) FROM meal_attendance"
                ).fetchone()[0]
                if mess_attendance_count == 0:
                    self._seed_mess_activity(conn)

                mess_feedback_count = conn.execute(
                    "SELECT COUNT(*) FROM mess_feedback"
                ).fetchone()[0]
                if mess_feedback_count == 0:
                    self._seed_mess_feedback(conn)

                fee_summary_count = conn.execute(
                    "SELECT COUNT(*) FROM fee_summaries"
                ).fetchone()[0]
                if fee_summary_count == 0:
                    self._rebuild_student_fee_summaries(conn)

                notification_count = conn.execute(
                    "SELECT COUNT(*) FROM notifications"
                ).fetchone()[0]
                if notification_count == 0:
                    self._seed_notifications(conn)

                chat_count = conn.execute(
                    "SELECT COUNT(*) FROM chat_messages"
                ).fetchone()[0]
                if chat_count == 0:
                    self._seed_chat_messages(conn)

    def _seed(self, conn: sqlite3.Connection) -> None:
        conn.executemany(
            """
            INSERT INTO blocks (code, name, description)
            VALUES (?, ?, ?)
            """,
            [
                (
                    "A",
                    "Academic Block",
                    "Quieter rooms close to classrooms and the library.",
                ),
                (
                    "B",
                    "Garden Block",
                    "Larger resident wing near the courtyard.",
                ),
                (
                    "C",
                    "City View",
                    "Balanced mid-rise wing for senior residents.",
                ),
                (
                    "D",
                    "Riverfront",
                    "Three-bed rooms with longer study hours.",
                ),
                (
                    "E",
                    "Summit Block",
                    "Newest section for overflow capacity.",
                ),
            ],
        )

        conn.executemany(
            """
            INSERT INTO rooms (id, block, number, capacity, room_type)
            VALUES (?, ?, ?, ?, ?)
            """,
            [
                ("room_a101", "A", "101", 2, "Double Sharing"),
                ("room_a102", "A", "102", 2, "Double Sharing"),
                ("room_a201", "A", "201", 3, "Triple Sharing"),
                ("room_b413", "B", "413", 2, "Double Sharing"),
                ("room_b415", "B", "415", 2, "Double Sharing"),
                ("room_b420", "B", "420", 1, "Single Occupancy"),
                *self._generated_seed_room_rows(),
            ],
        )

        conn.executemany(
            """
            INSERT INTO users (
                id, username, first_name, last_name, email, password,
                phone_number, role, room_id, job_title,
                email_verified, email_verified_at
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            [
                (
                    "admin_1",
                    "admin",
                    "Hostel",
                    "Admin",
                    "admin@hostelhub.edu",
                    self._hash_password("Admin@123"),
                    "9800000000",
                    "admin",
                    None,
                    "Operations Lead",
                    1,
                    self._utc_now(days_ago=60),
                ),
                (
                    "staff_1",
                    "warden",
                    "Mangal",
                    "Karki",
                    "mangal.karki@hostelhub.edu",
                    self._hash_password("Warden@123"),
                    "9804532792",
                    "staff",
                    None,
                    "Hostel Warden",
                    1,
                    self._utc_now(days_ago=58),
                ),
                (
                    "staff_2",
                    "support",
                    "Rohit",
                    "Shah",
                    "rohit.shah@hostelhub.edu",
                    self._hash_password("Support@123"),
                    "9804555555",
                    "staff",
                    None,
                    "Maintenance Supervisor",
                    1,
                    self._utc_now(days_ago=58),
                ),
                (
                    "student_1",
                    "aayush",
                    "Aayush",
                    "DC",
                    "aayush.dc@hostelhub.edu",
                    self._hash_password("Student@123"),
                    "9876543210",
                    "student",
                    "room_b413",
                    None,
                    1,
                    self._utc_now(days_ago=55),
                ),
                (
                    "student_2",
                    "shyam",
                    "Shyam",
                    "Thapa",
                    "shyam.thapa@hostelhub.edu",
                    self._hash_password("Student@123"),
                    "9811111111",
                    "student",
                    "room_a101",
                    None,
                    1,
                    self._utc_now(days_ago=54),
                ),
                (
                    "student_3",
                    "aarjila",
                    "Aarjila",
                    "Jirel",
                    "aarjila.jirel@hostelhub.edu",
                    self._hash_password("Student@123"),
                    "9822222222",
                    "student",
                    "room_b415",
                    None,
                    1,
                    self._utc_now(days_ago=54),
                ),
                (
                    "guest_1",
                    "guestdemo",
                    "Guest",
                    "Resident",
                    "guest.demo@hostelhub.edu",
                    self._hash_password("Guest@123"),
                    "9803333333",
                    "guest",
                    None,
                    None,
                    1,
                    self._utc_now(days_ago=20),
                ),
                *self._generated_seed_student_rows(),
            ],
        )

        conn.executemany(
            """
            INSERT INTO issues (
                id, student_id, category, comment, status, created_at,
                assigned_staff_id
            )
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            [
                (
                    "issue_1",
                    "student_1",
                    "Bathroom",
                    "Tap leakage near the washbasin.",
                    "open",
                    self._utc_now(days_ago=2),
                    "staff_1",
                ),
                (
                    "issue_2",
                    "student_2",
                    "Electricity",
                    "Tube light keeps flickering after 10 PM.",
                    "resolved",
                    self._utc_now(days_ago=5),
                    None,
                ),
            ],
        )

        self._seed_notices(conn)

        conn.execute(
            """
            INSERT INTO room_change_requests (
                id, student_id, current_room_id, desired_room_id,
                reason, status, created_at, resolved_at
            )
            VALUES (?, ?, ?, ?, ?, 'pending', ?, NULL)
            """,
            (
                "request_1",
                "student_1",
                "room_b413",
                "room_a102",
                "Need a quieter room closer to the study hall.",
                self._utc_now(days_ago=1),
            ),
        )

        self._rebuild_student_fee_summaries(conn)
        self._seed_payment_activity(conn)

    def _ensure_demo_scale(self, conn: sqlite3.Connection) -> None:
        conn.executemany(
            """
            INSERT OR IGNORE INTO blocks (code, name, description)
            VALUES (?, ?, ?)
            """,
            [
                (
                    "C",
                    "City View",
                    "Balanced mid-rise wing for senior residents.",
                ),
                (
                    "D",
                    "Riverfront",
                    "Three-bed rooms with longer study hours.",
                ),
                (
                    "E",
                    "Summit Block",
                    "Newest section for overflow capacity.",
                ),
            ],
        )
        conn.executemany(
            """
            INSERT OR IGNORE INTO rooms (id, block, number, capacity, room_type)
            VALUES (?, ?, ?, ?, ?)
            """,
            self._generated_seed_room_rows(),
        )
        conn.executemany(
            """
            INSERT OR IGNORE INTO users (
                id, username, first_name, last_name, email, password,
                phone_number, role, room_id, job_title,
                email_verified, email_verified_at
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            [
                (
                    "guest_1",
                    "guestdemo",
                    "Guest",
                    "Resident",
                    "guest.demo@hostelhub.edu",
                    self._hash_password("Guest@123"),
                    "9803333333",
                    "guest",
                    None,
                    None,
                    1,
                    self._utc_now(days_ago=20),
                ),
                *self._generated_seed_student_rows(),
            ],
        )
        conn.executemany(
            """
            UPDATE users
            SET email = ?, email_verified = 1, email_verified_at = COALESCE(email_verified_at, ?)
            WHERE id = ?
            """,
            [
                ("admin@hostelhub.edu", self._utc_now(days_ago=60), "admin_1"),
                (
                    "mangal.karki@hostelhub.edu",
                    self._utc_now(days_ago=58),
                    "staff_1",
                ),
                (
                    "rohit.shah@hostelhub.edu",
                    self._utc_now(days_ago=58),
                    "staff_2",
                ),
                (
                    "aayush.dc@hostelhub.edu",
                    self._utc_now(days_ago=55),
                    "student_1",
                ),
                (
                    "shyam.thapa@hostelhub.edu",
                    self._utc_now(days_ago=54),
                    "student_2",
                ),
                (
                    "aarjila.jirel@hostelhub.edu",
                    self._utc_now(days_ago=54),
                    "student_3",
                ),
                (
                    "guest.demo@hostelhub.edu",
                    self._utc_now(days_ago=20),
                    "guest_1",
                ),
            ],
        )
        students = conn.execute(
            """
            SELECT id, room_id
            FROM users
            WHERE role = 'student' AND room_id IS NOT NULL
            """
        ).fetchall()
        for student in students:
            exists = conn.execute(
                "SELECT 1 FROM fee_summaries WHERE user_id = ?",
                (student["id"],),
            ).fetchone()
            if exists is not None:
                continue
            room = self._require_room(conn, student["room_id"])
            self._write_fee_summary(
                conn,
                user_id=student["id"],
                fee_summary=self._default_fee_for_room(conn, room),
            )

    @contextmanager
    def _connect(self) -> sqlite3.Connection:
        conn = sqlite3.connect(
            self.db_path,
            timeout=5,
            check_same_thread=False,
        )
        conn.row_factory = sqlite3.Row
        conn.execute("PRAGMA foreign_keys = ON")
        conn.execute("PRAGMA journal_mode = WAL")
        conn.execute("PRAGMA synchronous = NORMAL")
        conn.execute("PRAGMA busy_timeout = 5000")
        try:
            yield conn
            conn.commit()
        except sqlite3.OperationalError as error:
            conn.rollback()
            if "locked" in str(error).lower():
                raise BackendError(
                    "Database is locked. Please retry in a moment.",
                    503,
                ) from error
            raise
        except Exception:
            conn.rollback()
            raise
        finally:
            conn.close()

    def _load_or_create_auth_token_secret(self) -> str:
        configured_secret = _optional_env("HOSTEL_AUTH_TOKEN_SECRET")
        if configured_secret is not None:
            return configured_secret

        secret_path = self.db_path.with_name(f".{self.db_path.stem}_auth_secret")
        if secret_path.exists():
            try:
                existing_secret = secret_path.read_text(encoding="utf-8").strip()
            except OSError:
                existing_secret = ""
            if existing_secret:
                return existing_secret

        generated_secret = secrets.token_urlsafe(48)
        try:
            secret_path.write_text(generated_secret, encoding="utf-8")
            os.chmod(secret_path, 0o600)
        except OSError:
            pass
        return generated_secret

    def verify_auth_token(self, token: str) -> dict[str, Any]:
        raw_token = token.strip()
        if not raw_token:
            raise BackendError("Authentication token is required.", 401)

        parts = raw_token.split(".")
        if len(parts) != 3:
            raise BackendError("Authentication token is invalid.", 401)

        encoded_header, encoded_payload, signature = parts
        signed_value = f"{encoded_header}.{encoded_payload}"
        expected_signature = _urlsafe_b64encode(
            hmac.new(
                self._auth_token_secret.encode("utf-8"),
                signed_value.encode("utf-8"),
                hashlib.sha256,
            ).digest()
        )
        if not hmac.compare_digest(expected_signature, signature):
            raise BackendError("Authentication token is invalid.", 401)

        try:
            payload = json.loads(_urlsafe_b64decode(encoded_payload).decode("utf-8"))
        except (ValueError, json.JSONDecodeError) as error:
            raise BackendError("Authentication token is invalid.", 401) from error

        user_id = payload.get("sub")
        user_role = payload.get("user_role")
        expires_at = payload.get("exp")
        if not isinstance(user_id, str) or not isinstance(user_role, str):
            raise BackendError("Authentication token is invalid.", 401)
        if not isinstance(expires_at, int):
            raise BackendError("Authentication token is invalid.", 401)
        if expires_at <= int(datetime.now(tz=timezone.utc).timestamp()):
            raise BackendError("Authentication token has expired.", 401)

        with self._connect() as conn:
            user = self._require_user(conn, user_id)
        if user["role"] != user_role:
            raise BackendError("Authentication token is no longer valid.", 401)
        return user

    def _sync_blocks_from_rooms(self, conn: sqlite3.Connection) -> None:
        rows = conn.execute(
            """
            SELECT DISTINCT block
            FROM rooms
            ORDER BY block
            """
        ).fetchall()
        conn.executemany(
            """
            INSERT OR IGNORE INTO blocks (code, name, description)
            VALUES (?, ?, NULL)
            """,
            [(row["block"], f"Block {row['block']}") for row in rows],
        )

    def _seed_notices(self, conn: sqlite3.Connection) -> None:
        conn.executemany(
            """
            INSERT OR IGNORE INTO notices (
                id, title, message, category, is_pinned, posted_at
            )
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            [
                (
                    "notice_1",
                    "Study hall closes at 10 PM",
                    "The study hall will close one hour early on Wednesday for maintenance.",
                    "Announcement",
                    1,
                    self._utc_now(),
                ),
                (
                    "notice_2",
                    "Saturday movie night",
                    "Join the common room screening at 7:30 PM. Seats are first come, first served.",
                    "Event",
                    0,
                    self._utc_now(days_ago=1),
                ),
                (
                    "notice_3",
                    "Quiet hours after 10 PM",
                    "Keep corridor noise low and avoid speaker use after 10 PM in all blocks.",
                    "Rule",
                    0,
                    self._utc_now(days_ago=2),
                ),
            ],
        )

    def _seed_notifications(self, conn: sqlite3.Connection) -> None:
        conn.executemany(
            """
            INSERT OR IGNORE INTO notifications (
                id, user_id, title, message, type, created_at, read_at
            )
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            [
                (
                    "notification_1",
                    "student_1",
                    "Fee reminder",
                    f"Hostel fees for {self._billing_month_label()} are still pending.",
                    "fee",
                    self._utc_now(days_ago=1),
                    None,
                ),
                (
                    "notification_2",
                    "student_1",
                    "Parcel arrived",
                    "DHL delivery is ready at the desk.",
                    "parcel",
                    self._utc_now(days_ago=2),
                    self._utc_now(days_ago=1),
                ),
                (
                    "notification_3",
                    "student_2",
                    "Saturday movie night",
                    "Join the common room screening at 7:30 PM. Seats are first come, first served.",
                    "notice",
                    self._utc_now(days_ago=1),
                    None,
                ),
                (
                    "notification_4",
                    "admin_1",
                    "Complaint updated",
                    "A bathroom complaint is still open in Block B.",
                    "complaint",
                    self._utc_now(),
                    None,
                ),
            ],
        )

    def _seed_chat_messages(self, conn: sqlite3.Connection) -> None:
        conn.executemany(
            """
            INSERT OR IGNORE INTO chat_messages (
                id, sender_id, recipient_id, message, sent_at, read_at
            )
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            [
                (
                    "chat_1",
                    "student_1",
                    "staff_1",
                    "I need approval for an early morning gate pass tomorrow.",
                    self._utc_now(days_ago=0),
                    self._utc_now(days_ago=0),
                ),
                (
                    "chat_2",
                    "staff_1",
                    "student_1",
                    "Submit the request before 9 PM and I will review it.",
                    self._utc_now(days_ago=0),
                    None,
                ),
                (
                    "chat_3",
                    "student_2",
                    "admin_1",
                    "Can the notice board include upcoming maintenance windows?",
                    self._utc_now(days_ago=1),
                    self._utc_now(days_ago=1),
                ),
                (
                    "chat_4",
                    "guest_1",
                    "staff_1",
                    "Please confirm the guest check-in time for tomorrow.",
                    self._utc_now(days_ago=0),
                    None,
                ),
            ],
        )

    def _seed_gate_passes(self, conn: sqlite3.Connection) -> None:
        now = datetime.now(timezone.utc)
        conn.executemany(
            """
            INSERT OR IGNORE INTO gate_passes (
                id, student_id, destination, reason, emergency_contact,
                pass_code, status, departure_at, expected_return_at,
                created_at, reviewed_at, checked_out_at, returned_at
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            [
                (
                    "gatepass_1",
                    "student_1",
                    "Pulchowk",
                    "Family dinner",
                    "9801112200",
                    self._pass_code(now - timedelta(hours=5)),
                    "checkedOut",
                    (now - timedelta(hours=6)).isoformat(),
                    (now - timedelta(hours=2)).isoformat(),
                    (now - timedelta(hours=8)).isoformat(),
                    (now - timedelta(hours=7)).isoformat(),
                    (now - timedelta(hours=6)).isoformat(),
                    None,
                ),
                (
                    "gatepass_2",
                    "student_2",
                    "Library research center",
                    "Project submission",
                    "9811113333",
                    self._pass_code(now + timedelta(days=1)),
                    "pending",
                    (now + timedelta(days=1, hours=2)).isoformat(),
                    (now + timedelta(days=1, hours=8)).isoformat(),
                    (now - timedelta(hours=3)).isoformat(),
                    None,
                    None,
                    None,
                ),
                (
                    "gatepass_3",
                    "student_3",
                    "Jawalakhel",
                    "Medical appointment",
                    "9822224444",
                    self._pass_code(now - timedelta(days=1)),
                    "returned",
                    (now - timedelta(days=1, hours=7)).isoformat(),
                    (now - timedelta(days=1, hours=2)).isoformat(),
                    (now - timedelta(days=1, hours=9)).isoformat(),
                    (now - timedelta(days=1, hours=8)).isoformat(),
                    (now - timedelta(days=1, hours=7)).isoformat(),
                    (now - timedelta(days=1, hours=3)).isoformat(),
                ),
            ],
        )

    def _seed_parcels(self, conn: sqlite3.Connection) -> None:
        conn.executemany(
            """
            INSERT OR IGNORE INTO parcels (
                id, user_id, carrier, tracking_code, note,
                status, created_at, notified_at, collected_at
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            [
                (
                    "parcel_1",
                    "student_1",
                    "DHL",
                    "DHL-2026-340",
                    "Books from home",
                    "awaitingPickup",
                    self._utc_now(days_ago=1),
                    self._utc_now(days_ago=1),
                    None,
                ),
                (
                    "parcel_2",
                    "student_2",
                    "Nepal Post",
                    "NP-9921",
                    "Documents envelope",
                    "collected",
                    self._utc_now(days_ago=4),
                    self._utc_now(days_ago=4),
                    self._utc_now(days_ago=3),
                ),
            ],
        )

    def _seed_visitors(self, conn: sqlite3.Connection) -> None:
        conn.executemany(
            """
            INSERT OR IGNORE INTO visitor_entries (
                id, student_id, visitor_name, relation,
                note, checked_in_at, checked_out_at
            )
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            [
                (
                    "visitor_1",
                    "student_1",
                    "Suresh DC",
                    "Brother",
                    "Weekend visit",
                    self._utc_now(),
                    None,
                ),
                (
                    "visitor_2",
                    "student_3",
                    "Mina Thapa",
                    "Mother",
                    "Picked up documents",
                    self._utc_now(days_ago=2),
                    self._utc_now(days_ago=2),
                ),
            ],
        )

    def _seed_laundry_bookings(self, conn: sqlite3.Connection) -> None:
        now = datetime.now(timezone.utc)
        conn.executemany(
            """
            INSERT OR IGNORE INTO laundry_bookings (
                id, user_id, machine_label, slot_label, scheduled_at,
                notes, status, created_at, completed_at
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            [
                (
                    "laundry_1",
                    "student_1",
                    "Machine A",
                    "07:00 - 08:00",
                    datetime(now.year, now.month, now.day, 7, tzinfo=timezone.utc).isoformat(),
                    "Bedsheets",
                    "scheduled",
                    self._utc_now(days_ago=0),
                    None,
                ),
                (
                    "laundry_2",
                    "student_2",
                    "Machine B",
                    "18:00 - 19:00",
                    datetime(now.year, now.month, now.day, 18, tzinfo=timezone.utc).isoformat(),
                    "Weekend clothes",
                    "completed",
                    self._utc_now(days_ago=1),
                    self._utc_now(days_ago=1),
                ),
            ],
        )

    def _seed_mess_menu(self, conn: sqlite3.Connection) -> None:
        conn.executemany(
            """
            INSERT OR REPLACE INTO mess_menu (day, breakfast, lunch, dinner)
            VALUES (?, ?, ?, ?)
            """,
            [
                ("monday", "Poha & tea", "Rice, dal, mixed veg", "Roti, paneer curry"),
                ("tuesday", "Paratha & curd", "Jeera rice, rajma, salad", "Roti, egg curry"),
                ("wednesday", "Bread omelette", "Pulao, chana masala", "Roti, chicken stew"),
                ("thursday", "Idli & sambar", "Rice, dal fry, aloo jeera", "Roti, veg kofta"),
                ("friday", "Aloo puri", "Fried rice, chilli paneer", "Roti, dal makhani"),
                ("saturday", "Upma & banana", "Rice, fish curry, greens", "Roti, mixed veg"),
                ("sunday", "Pancakes & fruit", "Veg biryani, raita", "Roti, korma"),
            ],
        )

    def _seed_mess_activity(self, conn: sqlite3.Connection) -> None:
        today_index = datetime.now(timezone.utc).weekday()
        today_day = MESS_DAYS[today_index]
        previous_day = MESS_DAYS[(today_index - 1) % len(MESS_DAYS)]
        conn.executemany(
            """
            INSERT OR IGNORE INTO meal_attendance (
                id, user_id, day, date, breakfast, lunch, dinner
            )
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            [
                (
                    "attendance_1",
                    "student_1",
                    today_day,
                    self._mess_date_for_day(today_day),
                    1,
                    1,
                    0,
                ),
                (
                    "attendance_2",
                    "student_1",
                    previous_day,
                    self._mess_date_for_day(previous_day),
                    1,
                    0,
                    1,
                ),
                (
                    "attendance_3",
                    "student_2",
                    today_day,
                    self._mess_date_for_day(today_day),
                    1,
                    1,
                    1,
                ),
                (
                    "attendance_4",
                    "student_3",
                    today_day,
                    self._mess_date_for_day(today_day),
                    0,
                    1,
                    1,
                ),
            ],
        )

    def _seed_mess_feedback(self, conn: sqlite3.Connection) -> None:
        conn.executemany(
            """
            INSERT OR IGNORE INTO mess_feedback (
                id, user_id, rating, comment, submitted_at
            )
            VALUES (?, ?, ?, ?, ?)
            """,
            [
                (
                    "feedback_1",
                    "student_1",
                    4,
                    "Breakfast quality has improved. Please keep fruit on weekdays.",
                    self._utc_now(days_ago=1),
                ),
                (
                    "feedback_2",
                    "student_2",
                    5,
                    "Sunday lunch menu was excellent and service was quick.",
                    self._utc_now(days_ago=3),
                ),
            ],
        )

    def _ensure_unique_credentials(
        self,
        conn: sqlite3.Connection,
        *,
        email: str,
        username: str,
        phone_number: str,
    ) -> None:
        self._validate_email(email)
        if not self._is_phone_number(phone_number):
            raise BackendError("Enter a valid 10 digit phone number.")
        existing_email = conn.execute(
            "SELECT 1 FROM users WHERE lower(email) = ?",
            (email.lower(),),
        ).fetchone()
        if existing_email is not None:
            raise BackendError("That email address is already in use.")

        existing_username = conn.execute(
            "SELECT 1 FROM users WHERE lower(username) = ?",
            (username.lower(),),
        ).fetchone()
        if existing_username is not None:
            raise BackendError("That username is already in use.")

        existing_phone = conn.execute(
            "SELECT 1 FROM users WHERE phone_number = ?",
            (phone_number.strip(),),
        ).fetchone()
        if existing_phone is not None:
            raise BackendError("That phone number is already in use.")

    def _require_user_by_email(
        self,
        conn: sqlite3.Connection,
        email: str,
    ) -> dict[str, Any]:
        row = conn.execute(
            "SELECT * FROM users WHERE lower(email) = ?",
            (email.strip().lower(),),
        ).fetchone()
        if row is None:
            raise BackendError("Account not found for this email.", 404)
        return self._user_from_row(row)

    def _create_auth_challenge(
        self,
        conn: sqlite3.Connection,
        *,
        email: str,
        purpose: str,
    ) -> dict[str, Any]:
        if purpose not in AUTH_CHALLENGE_PURPOSES:
            raise BackendError("Invalid auth challenge purpose.", 500)
        code = f"{secrets.randbelow(900000) + 100000:06d}"
        created_at = self._utc_now()
        expires_at = (
            datetime.now(tz=timezone.utc) + timedelta(minutes=15)
        ).isoformat()
        conn.execute(
            """
            UPDATE auth_challenges
            SET consumed_at = ?
            WHERE lower(email) = ? AND purpose = ? AND consumed_at IS NULL
            """,
            (created_at, email.strip().lower(), purpose),
        )
        conn.execute(
            """
            INSERT INTO auth_challenges (
                id, email, purpose, code, created_at, expires_at, consumed_at
            )
            VALUES (?, ?, ?, ?, ?, ?, NULL)
            """,
            (
                self._new_id("challenge"),
                email.strip().lower(),
                purpose,
                code,
                created_at,
                expires_at,
            ),
        )
        delivery = self._deliver_auth_challenge(
            email=email.strip().lower(),
            purpose=purpose,
            code=code,
            expires_at=expires_at,
        )
        return {
            "email": email.strip().lower(),
            "code": code,
            "expiresAt": expires_at,
            "deliveryMethod": delivery["method"],
            "deliveryError": delivery.get("error"),
        }

    def _deliver_auth_challenge(
        self,
        *,
        email: str,
        purpose: str,
        code: str,
        expires_at: str,
    ) -> dict[str, str]:
        if self._auth_challenge_mailer is None:
            return {
                "method": "local",
                "error": "SMTP is not configured on this backend.",
            }
        try:
            self._auth_challenge_mailer.send_auth_challenge(
                email=email,
                purpose=purpose,
                code=code,
                expires_at=expires_at,
            )
        except Exception as error:
            error_message = str(error).strip() or error.__class__.__name__
            print(
                f"Unable to send auth challenge email to {email}: {error_message}",
                file=sys.stderr,
            )
            return {
                "method": "local",
                "error": error_message,
            }
        return {"method": "email"}

    def _consume_auth_challenge(
        self,
        conn: sqlite3.Connection,
        *,
        email: str,
        purpose: str,
        code: str,
    ) -> dict[str, Any]:
        row = conn.execute(
            """
            SELECT *
            FROM auth_challenges
            WHERE lower(email) = ?
              AND purpose = ?
              AND consumed_at IS NULL
            ORDER BY created_at DESC
            LIMIT 1
            """,
            (email.strip().lower(), purpose),
        ).fetchone()
        if row is None:
            raise BackendError("Request a fresh verification code.")
        if datetime.fromisoformat(row["expires_at"]) < datetime.now(
            tz=timezone.utc
        ):
            conn.execute(
                "UPDATE auth_challenges SET consumed_at = ? WHERE id = ?",
                (self._utc_now(), row["id"]),
            )
            raise BackendError("The verification code has expired.")
        if row["code"] != code.strip():
            raise BackendError("The verification code is invalid.")
        conn.execute(
            "UPDATE auth_challenges SET consumed_at = ? WHERE id = ?",
            (self._utc_now(), row["id"]),
        )
        return self._require_user_by_email(conn, row["email"])

    def _require_user(
        self,
        conn: sqlite3.Connection,
        user_id: str,
    ) -> dict[str, Any]:
        row = conn.execute(
            "SELECT * FROM users WHERE id = ?",
            (user_id,),
        ).fetchone()
        if row is None:
            raise BackendError("User not found.", 404)
        return self._user_from_row(row)

    def _require_block(
        self,
        conn: sqlite3.Connection,
        block_code: str,
    ) -> dict[str, Any]:
        row = conn.execute(
            "SELECT * FROM blocks WHERE code = ?",
            (block_code,),
        ).fetchone()
        if row is None:
            raise BackendError("Block not found.", 404)
        return self._block_from_row(row)

    def _require_room(
        self,
        conn: sqlite3.Connection,
        room_id: str,
    ) -> dict[str, Any]:
        row = conn.execute(
            "SELECT * FROM rooms WHERE id = ?",
            (room_id,),
        ).fetchone()
        if row is None:
            raise BackendError("Room not found.", 404)
        return self._room_from_row(conn, row)

    def _room_has_availability(
        self,
        conn: sqlite3.Connection,
        room_id: str,
    ) -> bool:
        row = conn.execute(
            """
            SELECT r.capacity AS capacity, COUNT(u.id) AS occupancy
            FROM rooms r
            LEFT JOIN users u
              ON u.room_id = r.id AND u.role = 'student'
            WHERE r.id = ?
            GROUP BY r.id
            """,
            (room_id,),
        ).fetchone()
        if row is None:
            raise BackendError("Room not found.", 404)
        return row["occupancy"] < row["capacity"]

    def _get_fee_settings_row(self, conn: sqlite3.Connection) -> sqlite3.Row:
        row = conn.execute("SELECT * FROM fee_settings WHERE id = 1").fetchone()
        if row is None:
            raise BackendError("Fee settings are not initialized.", 500)
        return row

    def _ensure_column(
        self,
        conn: sqlite3.Connection,
        *,
        table: str,
        column: str,
        definition: str,
    ) -> None:
        existing_columns = {
            row["name"] for row in conn.execute(f"PRAGMA table_info({table})").fetchall()
        }
        if column not in existing_columns:
            conn.execute(f"ALTER TABLE {table} ADD COLUMN {column} {definition}")

    def _migrate_password_storage(self, conn: sqlite3.Connection) -> None:
        rows = conn.execute(
            """
            SELECT id, password
            FROM users
            WHERE password IS NOT NULL AND trim(password) != ''
            """
        ).fetchall()
        for row in rows:
            if self._is_password_hashed(row["password"]):
                continue
            conn.execute(
                "UPDATE users SET password = ? WHERE id = ?",
                (
                    self._hash_password(row["password"]),
                    row["id"],
                ),
            )

    def _backfill_fee_summary_metadata(self, conn: sqlite3.Connection) -> None:
        conn.execute(
            """
            UPDATE fee_summaries
            SET billing_month = ?
            WHERE billing_month IS NULL OR billing_month = ''
            """,
            (self._billing_month_label(),),
        )
        conn.execute(
            """
            UPDATE fee_summaries
            SET due_date = ?
            WHERE due_date IS NULL OR due_date = ''
            """,
            (self._default_due_date(),),
        )
        conn.execute(
            """
            UPDATE fee_summaries
            SET paid_amount = 0
            WHERE paid_amount IS NULL
            """
        )

    def _write_fee_summary(
        self,
        conn: sqlite3.Connection,
        *,
        user_id: str,
        fee_summary: dict[str, Any],
    ) -> None:
        existing_row = conn.execute(
            """
            SELECT *
            FROM fee_summaries
            WHERE user_id = ?
            """,
            (user_id,),
        ).fetchone()
        total = (
            fee_summary["maintenanceCharge"]
            + fee_summary["parkingCharge"]
            + fee_summary["waterCharge"]
            + fee_summary["roomCharge"]
            + sum(
                int(item.get("amount", 0))
                for item in fee_summary.get("additionalCharges", [])
                if isinstance(item, dict)
            )
        )
        billing_month = fee_summary.get("billingMonth", self._billing_month_label())
        same_billing_month = (
            existing_row is not None and existing_row["billing_month"] == billing_month
        )
        paid_amount = fee_summary.get(
            "paidAmount",
            0
            if existing_row is None or not same_billing_month
            else existing_row["paid_amount"],
        )
        paid_amount = max(0, min(paid_amount, total))
        due_date = fee_summary.get(
            "dueDate",
            self._default_due_date()
            if existing_row is None or not same_billing_month
            else existing_row["due_date"],
        )
        if "lastReminderAt" in fee_summary:
            last_reminder_at = fee_summary["lastReminderAt"]
        else:
            last_reminder_at = (
                None
                if existing_row is None or not same_billing_month
                else existing_row["last_reminder_at"]
            )
        conn.execute(
            """
            INSERT OR REPLACE INTO fee_summaries (
                user_id, maintenance_charge, parking_charge,
                water_charge, room_charge, extra_charges_json, billing_month,
                due_date, paid_amount, last_reminder_at
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                user_id,
                fee_summary["maintenanceCharge"],
                fee_summary["parkingCharge"],
                fee_summary["waterCharge"],
                fee_summary["roomCharge"],
                json.dumps(
                    self._normalize_fee_charge_items(
                        fee_summary.get("additionalCharges", [])
                    )
                ),
                billing_month,
                due_date,
                paid_amount,
                last_reminder_at,
            ),
        )

    def _rebuild_student_fee_summaries(self, conn: sqlite3.Connection) -> None:
        students = conn.execute(
            """
            SELECT id, room_id
            FROM users
            WHERE role = 'student' AND room_id IS NOT NULL
            """
        ).fetchall()
        for student in students:
            room = self._require_room(conn, student["room_id"])
            self._write_fee_summary(
                conn,
                user_id=student["id"],
                fee_summary=self._default_fee_for_room(conn, room),
            )

    def _clean_optional(self, value: str | None) -> str | None:
        if value is None:
            return None
        trimmed = value.strip()
        return trimmed or None

    def _user_from_row(
        self,
        row: sqlite3.Row,
        *,
        auth_token: str | None = None,
    ) -> dict[str, Any]:
        role = row["role"]
        if role not in USER_ROLES:
            raise BackendError("Invalid user role stored in backend.", 500)
        payload = {
            "id": row["id"],
            "username": row["username"],
            "firstName": row["first_name"],
            "lastName": row["last_name"],
            "email": row["email"],
            "phoneNumber": row["phone_number"],
            "role": role,
            "roomId": row["room_id"],
            "jobTitle": row["job_title"],
            "emailVerified": bool(row["email_verified"]),
            "emailVerifiedAt": row["email_verified_at"],
        }
        if auth_token is not None:
            payload["authToken"] = auth_token
        return payload

    def _block_from_row(self, row: sqlite3.Row) -> dict[str, Any]:
        return {
            "code": row["code"],
            "name": row["name"],
            "description": row["description"],
        }

    def _room_from_row(
        self,
        conn: sqlite3.Connection,
        row: sqlite3.Row,
    ) -> dict[str, Any]:
        residents = conn.execute(
            """
            SELECT id
            FROM users
            WHERE room_id = ? AND role = 'student'
            ORDER BY id
            """,
            (row["id"],),
        ).fetchall()
        resident_ids = [resident["id"] for resident in residents]
        return {
            "id": row["id"],
            "block": row["block"],
            "number": row["number"],
            "capacity": row["capacity"],
            "roomType": row["room_type"],
            "residentIds": resident_ids,
        }

    def _issue_from_row(self, row: sqlite3.Row) -> dict[str, Any]:
        status = row["status"]
        if status not in ISSUE_STATUSES:
            raise BackendError("Invalid issue status stored in backend.", 500)
        return {
            "id": row["id"],
            "studentId": row["student_id"],
            "category": row["category"],
            "comment": row["comment"],
            "status": status,
            "createdAt": row["created_at"],
            "assignedStaffId": row["assigned_staff_id"],
        }

    def _gate_pass_from_row(self, row: sqlite3.Row) -> dict[str, Any]:
        status = row["status"]
        if status not in GATE_PASS_STATUSES:
            raise BackendError("Invalid gate pass status stored in backend.", 500)
        return {
            "id": row["id"],
            "studentId": row["student_id"],
            "destination": row["destination"],
            "reason": row["reason"],
            "emergencyContact": row["emergency_contact"],
            "passCode": row["pass_code"],
            "status": status,
            "departureAt": row["departure_at"],
            "expectedReturnAt": row["expected_return_at"],
            "createdAt": row["created_at"],
            "reviewedAt": row["reviewed_at"],
            "checkedOutAt": row["checked_out_at"],
            "returnedAt": row["returned_at"],
        }

    def _parcel_from_row(self, row: sqlite3.Row) -> dict[str, Any]:
        status = row["status"]
        if status not in PARCEL_STATUSES:
            raise BackendError("Invalid parcel status stored in backend.", 500)
        return {
            "id": row["id"],
            "userId": row["user_id"],
            "carrier": row["carrier"],
            "trackingCode": row["tracking_code"],
            "note": row["note"],
            "status": status,
            "createdAt": row["created_at"],
            "notifiedAt": row["notified_at"],
            "collectedAt": row["collected_at"],
        }

    def _visitor_entry_from_row(self, row: sqlite3.Row) -> dict[str, Any]:
        return {
            "id": row["id"],
            "studentId": row["student_id"],
            "visitorName": row["visitor_name"],
            "relation": row["relation"],
            "note": row["note"],
            "checkedInAt": row["checked_in_at"],
            "checkedOutAt": row["checked_out_at"],
        }

    def _laundry_booking_from_row(self, row: sqlite3.Row) -> dict[str, Any]:
        status = row["status"]
        if status not in LAUNDRY_BOOKING_STATUSES:
            raise BackendError(
                "Invalid laundry booking status stored in backend.",
                500,
            )
        return {
            "id": row["id"],
            "userId": row["user_id"],
            "machineLabel": row["machine_label"],
            "slotLabel": row["slot_label"],
            "scheduledAt": row["scheduled_at"],
            "notes": row["notes"],
            "status": status,
            "createdAt": row["created_at"],
            "completedAt": row["completed_at"],
        }

    def _mess_menu_from_row(self, row: sqlite3.Row) -> dict[str, Any]:
        day = row["day"]
        if day not in MESS_DAYS:
            raise BackendError("Invalid mess day stored in backend.", 500)
        return {
            "day": day,
            "breakfast": row["breakfast"],
            "lunch": row["lunch"],
            "dinner": row["dinner"],
        }

    def _meal_attendance_from_row(self, row: sqlite3.Row) -> dict[str, Any]:
        day = row["day"]
        if day not in MESS_DAYS:
            raise BackendError("Invalid attendance day stored in backend.", 500)
        return {
            "id": row["id"],
            "userId": row["user_id"],
            "day": day,
            "date": row["date"],
            "breakfast": bool(row["breakfast"]),
            "lunch": bool(row["lunch"]),
            "dinner": bool(row["dinner"]),
        }

    def _mess_feedback_from_row(self, row: sqlite3.Row) -> dict[str, Any]:
        return {
            "id": row["id"],
            "userId": row["user_id"],
            "rating": row["rating"],
            "comment": row["comment"],
            "submittedAt": row["submitted_at"],
        }

    def _notice_from_row(self, row: sqlite3.Row) -> dict[str, Any]:
        return {
            "id": row["id"],
            "title": row["title"],
            "message": row["message"],
            "category": row["category"],
            "isPinned": bool(row["is_pinned"]),
            "postedAt": row["posted_at"],
        }

    def _notification_from_row(self, row: sqlite3.Row) -> dict[str, Any]:
        notification_type = row["type"]
        if notification_type not in NOTIFICATION_TYPES:
            raise BackendError("Invalid notification type stored in backend.", 500)
        return {
            "id": row["id"],
            "userId": row["user_id"],
            "title": row["title"],
            "message": row["message"],
            "type": notification_type,
            "createdAt": row["created_at"],
            "readAt": row["read_at"],
        }

    def _chat_message_from_row(self, row: sqlite3.Row) -> dict[str, Any]:
        return {
            "id": row["id"],
            "senderId": row["sender_id"],
            "recipientId": row["recipient_id"],
            "message": row["message"],
            "sentAt": row["sent_at"],
            "readAt": row["read_at"],
        }

    def _room_request_from_row(self, row: sqlite3.Row) -> dict[str, Any]:
        status = row["status"]
        if status not in ROOM_REQUEST_STATUSES:
            raise BackendError("Invalid room request status stored in backend.", 500)
        return {
            "id": row["id"],
            "studentId": row["student_id"],
            "currentRoomId": row["current_room_id"],
            "desiredRoomId": row["desired_room_id"],
            "reason": row["reason"],
            "status": status,
            "createdAt": row["created_at"],
            "resolvedAt": row["resolved_at"],
        }

    def _fee_summary_from_row(self, row: sqlite3.Row) -> dict[str, Any]:
        return self._fee_summary_with_total(
            {
                "maintenanceCharge": row["maintenance_charge"],
                "parkingCharge": row["parking_charge"],
                "waterCharge": row["water_charge"],
                "roomCharge": row["room_charge"],
                "additionalCharges": self._json_list(row["extra_charges_json"]),
                "billingMonth": row["billing_month"],
                "dueDate": row["due_date"],
                "paidAmount": row["paid_amount"],
                "lastReminderAt": row["last_reminder_at"],
            }
        )

    def _fee_summary_with_total(self, fee_summary: dict[str, Any]) -> dict[str, Any]:
        additional_charges = fee_summary.get("additionalCharges", [])
        total = (
            fee_summary["maintenanceCharge"]
            + fee_summary["parkingCharge"]
            + fee_summary["waterCharge"]
            + fee_summary["roomCharge"]
            + sum(
                int(item.get("amount", 0))
                for item in additional_charges
                if isinstance(item, dict)
            )
        )
        balance = max(total - fee_summary.get("paidAmount", 0), 0)
        return {
            **fee_summary,
            "additionalCharges": additional_charges,
            "total": total,
            "balance": balance,
            "isPaid": balance == 0,
        }

    def _payment_from_row(self, row: sqlite3.Row) -> dict[str, Any]:
        if row["payment_method"] not in PAYMENT_METHODS:
            raise BackendError("Invalid payment method stored in backend.", 500)
        if row["status"] not in PAYMENT_STATUSES:
            raise BackendError("Invalid payment status stored in backend.", 500)
        return {
            "id": row["id"],
            "userId": row["user_id"],
            "amount": row["amount"],
            "paymentMethod": row["payment_method"],
            "status": row["status"],
            "receiptId": row["receipt_id"],
            "billingMonth": row["billing_month"],
            "paidAt": row["paid_at"],
        }

    def _notify_user(
        self,
        conn: sqlite3.Connection,
        *,
        user_id: str,
        title: str,
        message: str,
        type: str,
        created_at: str | None = None,
        read_at: str | None = None,
    ) -> None:
        if type not in NOTIFICATION_TYPES:
            raise BackendError("Invalid notification type.", 500)
        self._require_user(conn, user_id)
        conn.execute(
            """
            INSERT INTO notifications (
                id, user_id, title, message, type, created_at, read_at
            )
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            (
                self._new_id("notification"),
                user_id,
                title.strip(),
                message.strip(),
                type,
                created_at or self._utc_now(),
                read_at,
            ),
        )

    def _notify_many(
        self,
        conn: sqlite3.Connection,
        *,
        user_ids: list[str],
        title: str,
        message: str,
        type: str,
        created_at: str | None = None,
    ) -> None:
        for user_id in user_ids:
            self._notify_user(
                conn,
                user_id=user_id,
                title=title,
                message=message,
                type=type,
                created_at=created_at,
            )

    def _mess_bill_from_rows(self, rows: list[sqlite3.Row]) -> dict[str, Any]:
        now = datetime.now(timezone.utc)
        breakfast_count = 0
        lunch_count = 0
        dinner_count = 0

        for row in rows:
            meal_date = datetime.fromisoformat(row["date"])
            if meal_date.year != now.year or meal_date.month != now.month:
                continue
            if row["breakfast"]:
                breakfast_count += 1
            if row["lunch"]:
                lunch_count += 1
            if row["dinner"]:
                dinner_count += 1

        return {
            "monthLabel": self._billing_month_label(now),
            "breakfastCount": breakfast_count,
            "lunchCount": lunch_count,
            "dinnerCount": dinner_count,
            "breakfastRate": MESS_BREAKFAST_RATE,
            "lunchRate": MESS_LUNCH_RATE,
            "dinnerRate": MESS_DINNER_RATE,
        }

    def _fee_settings_from_row(self, row: sqlite3.Row) -> dict[str, Any]:
        return {
            "maintenanceCharge": row["maintenance_charge"],
            "parkingCharge": row["parking_charge"],
            "waterCharge": row["water_charge"],
            "singleOccupancyCharge": row["single_occupancy_charge"],
            "doubleSharingCharge": row["double_sharing_charge"],
            "tripleSharingCharge": row["triple_sharing_charge"],
            "customCharges": self._ensure_default_fee_charge_items(
                self._json_list(row["custom_charges_json"])
            ),
        }

    def _get_admin_catalog_row(self, conn: sqlite3.Connection) -> sqlite3.Row:
        row = conn.execute(
            "SELECT * FROM admin_catalog WHERE id = 1"
        ).fetchone()
        if row is None:
            raise BackendError("Admin catalog not found.", 500)
        return row

    def _admin_catalog_from_row(self, row: sqlite3.Row) -> dict[str, Any]:
        return {
            "issueCategories": self._normalize_string_list(
                self._json_list(row["issue_categories_json"]),
                default_values=DEFAULT_ADMIN_CATALOG["issueCategories"],
            ),
            "noticeCategories": self._normalize_string_list(
                self._json_list(row["notice_categories_json"]),
                default_values=DEFAULT_ADMIN_CATALOG["noticeCategories"],
            ),
            "laundryMachines": self._normalize_string_list(
                self._json_list(row["laundry_machines_json"]),
                default_values=DEFAULT_ADMIN_CATALOG["laundryMachines"],
            ),
            "parcelCarriers": self._normalize_string_list(
                self._json_list(row["parcel_carriers_json"]),
                default_values=DEFAULT_ADMIN_CATALOG["parcelCarriers"],
            ),
            "alertPresets": self._normalize_alert_presets(
                self._json_list(row["alert_presets_json"]),
                self._normalize_string_list(
                    self._json_list(row["notice_categories_json"]),
                    default_values=DEFAULT_ADMIN_CATALOG["noticeCategories"],
                ),
            ),
            "serviceShortcuts": self._normalize_service_shortcuts(
                self._json_list(row["service_shortcuts_json"])
            ),
        }

    def _json_list(self, raw: Any) -> list[Any]:
        if raw is None:
            return []
        if isinstance(raw, list):
            return raw
        if not isinstance(raw, str):
            return []
        try:
            decoded = json.loads(raw)
        except json.JSONDecodeError:
            return []
        return decoded if isinstance(decoded, list) else []

    def _normalize_string_list(
        self,
        values: list[Any],
        *,
        default_values: list[str],
    ) -> list[str]:
        normalized: list[str] = []
        seen: set[str] = set()
        for value in values:
            if not isinstance(value, str):
                continue
            trimmed = value.strip()
            if not trimmed:
                continue
            lowered = trimmed.casefold()
            if lowered in seen:
                continue
            seen.add(lowered)
            normalized.append(trimmed)
        return normalized or list(default_values)

    def _normalize_fee_charge_items(
        self,
        values: list[Any],
    ) -> list[dict[str, Any]]:
        normalized: list[dict[str, Any]] = []
        seen: set[str] = set()
        for value in values:
            if not isinstance(value, dict):
                continue
            label = str(value.get("label", "")).strip()
            if not label:
                continue
            lowered = label.casefold()
            if lowered in seen:
                continue
            amount_raw = value.get("amount", 0)
            try:
                amount = int(amount_raw)
            except (TypeError, ValueError):
                raise BackendError("Fee category amounts must be valid numbers.")
            if amount < 0:
                raise BackendError("Fee category amounts must be zero or greater.")
            seen.add(lowered)
            normalized.append(
                {
                    "label": label,
                    "amount": amount,
                }
            )
        return normalized

    def _ensure_default_fee_charge_items(
        self,
        values: list[dict[str, Any]],
    ) -> list[dict[str, Any]]:
        normalized = list(values)
        has_electricity = any(
            str(item.get("label", "")).strip().casefold() == "electricity"
            for item in normalized
            if isinstance(item, dict)
        )
        if not has_electricity:
            normalized.insert(0, {"label": "Electricity", "amount": 500})
        return normalized

    def _normalize_alert_presets(
        self,
        values: list[Any],
        notice_categories: list[str],
    ) -> list[dict[str, str]]:
        normalized: list[dict[str, str]] = []
        fallback_category = notice_categories[0]
        seen: set[str] = set()
        valid_categories = {item.casefold(): item for item in notice_categories}
        for value in values:
            if not isinstance(value, dict):
                continue
            title = str(value.get("title", "")).strip()
            message = str(value.get("message", "")).strip()
            category = str(value.get("category", "")).strip()
            if not title or not message:
                continue
            seen_key = f"{title.casefold()}::{message.casefold()}"
            if seen_key in seen:
                continue
            seen.add(seen_key)
            normalized.append(
                {
                    "title": title,
                    "message": message,
                    "category": valid_categories.get(
                        category.casefold(),
                        fallback_category,
                    ),
                }
            )
        if normalized:
            return normalized
        return list(DEFAULT_ADMIN_CATALOG["alertPresets"])

    def _normalize_service_shortcuts(
        self,
        values: list[Any],
    ) -> list[dict[str, Any]]:
        normalized: list[dict[str, Any]] = []
        seen: set[tuple[str, str]] = set()
        for value in values:
            if not isinstance(value, dict):
                continue
            title = str(value.get("title", "")).strip()
            subtitle = str(value.get("subtitle", "")).strip()
            route = str(value.get("route", "")).strip()
            icon_key = str(value.get("iconKey", "")).strip()
            roles_raw = value.get("roles", [])
            accent_hex = value.get("accentHex")
            if not title or not subtitle or not route or not icon_key:
                continue
            roles: list[str] = []
            for item in roles_raw if isinstance(roles_raw, list) else []:
                if not isinstance(item, str):
                    continue
                role = item.strip()
                if role not in USER_ROLES or role in roles:
                    continue
                roles.append(role)
            if not roles:
                continue
            dedupe_key = (title.casefold(), route)
            if dedupe_key in seen:
                continue
            seen.add(dedupe_key)
            normalized.append(
                {
                    "title": title,
                    "subtitle": subtitle,
                    "route": route,
                    "iconKey": icon_key,
                    "roles": roles,
                    "accentHex": accent_hex if isinstance(accent_hex, str) else None,
                }
            )
        if normalized:
            return normalized
        return list(DEFAULT_ADMIN_CATALOG["serviceShortcuts"])

    def _ensure_mess_menu_rows(self, conn: sqlite3.Connection) -> None:
        conn.executemany(
            """
            INSERT OR IGNORE INTO mess_menu (day, breakfast, lunch, dinner)
            VALUES (?, '', '', '')
            """,
            [(day,) for day in MESS_DAYS],
        )

    def _default_fee_for_room(
        self,
        conn: sqlite3.Connection,
        room: dict[str, Any],
    ) -> dict[str, Any]:
        settings = self._fee_settings_from_row(self._get_fee_settings_row(conn))
        room_type = room["roomType"]
        if room_type == "Single Occupancy":
            room_charge = settings["singleOccupancyCharge"]
        elif room_type == "Triple Sharing":
            room_charge = settings["tripleSharingCharge"]
        else:
            room_charge = settings["doubleSharingCharge"]

        return {
            "maintenanceCharge": settings["maintenanceCharge"],
            "parkingCharge": settings["parkingCharge"],
            "waterCharge": settings["waterCharge"],
            "roomCharge": room_charge,
            "additionalCharges": settings["customCharges"],
            "billingMonth": self._billing_month_label(),
        }

    def _default_fee_without_room(self, conn: sqlite3.Connection) -> dict[str, Any]:
        settings = self._fee_settings_from_row(self._get_fee_settings_row(conn))
        return {
            "maintenanceCharge": settings["maintenanceCharge"],
            "parkingCharge": settings["parkingCharge"],
            "waterCharge": settings["waterCharge"],
            "roomCharge": settings["doubleSharingCharge"],
            "additionalCharges": settings["customCharges"],
            "billingMonth": self._billing_month_label(),
        }

    def _seed_payment_activity(self, conn: sqlite3.Connection) -> None:
        student_one_summary = self._fee_summary_from_row(
            conn.execute(
                "SELECT * FROM fee_summaries WHERE user_id = 'student_1'"
            ).fetchone()
        )
        student_two_summary = self._fee_summary_from_row(
            conn.execute(
                "SELECT * FROM fee_summaries WHERE user_id = 'student_2'"
            ).fetchone()
        )
        self._write_fee_summary(
            conn,
            user_id="student_1",
            fee_summary={
                **student_one_summary,
                "paidAmount": 2000,
                "lastReminderAt": self._utc_now(days_ago=2),
            },
        )
        conn.execute(
            """
            INSERT INTO payment_records (
                id, user_id, amount, payment_method, status,
                receipt_id, billing_month, paid_at
            )
            VALUES (?, ?, ?, ?, 'paid', ?, ?, ?)
            """,
            (
                "payment_1",
                "student_1",
                2000,
                "eSewa",
                self._receipt_id(),
                student_one_summary["billingMonth"],
                self._utc_now(days_ago=5),
            ),
        )
        self._write_fee_summary(
            conn,
            user_id="student_2",
            fee_summary={
                **student_two_summary,
                "paidAmount": student_two_summary["total"],
            },
        )
        conn.execute(
            """
            INSERT INTO payment_records (
                id, user_id, amount, payment_method, status,
                receipt_id, billing_month, paid_at
            )
            VALUES (?, ?, ?, ?, 'paid', ?, ?, ?)
            """,
            (
                "payment_2",
                "student_2",
                student_two_summary["total"],
                "bankTransfer",
                self._receipt_id(),
                student_two_summary["billingMonth"],
                self._utc_now(days_ago=3),
            ),
        )

    def _generated_seed_room_rows(self) -> list[tuple[str, str, str, int, str]]:
        rows: list[tuple[str, str, str, int, str]] = []
        for block in ("C", "D", "E"):
            for floor in range(1, 4):
                for room_number in range(1, 5):
                    number = f"{floor}0{room_number}"
                    rows.append(
                        (
                            f"room_{block.lower()}{number}",
                            block,
                            number,
                            3,
                            "Triple Sharing",
                        )
                    )
        return rows

    def _generated_seed_student_rows(
        self,
    ) -> list[tuple[str, str, str, str, str, str, str, str, str | None, str | None, int, str]]:
        first_names = (
            "Sujan",
            "Nishan",
            "Prakash",
            "Kiran",
            "Suman",
            "Amit",
            "Ritesh",
            "Nabin",
            "Bikash",
            "Sabin",
            "Puja",
            "Asmita",
            "Anusha",
            "Srijana",
            "Nikita",
            "Rachana",
            "Bibek",
            "Sagar",
            "Roshan",
            "Ankit",
        )
        last_names = (
            "Shrestha",
            "Tamang",
            "Basnet",
            "Khadka",
            "Gurung",
            "Acharya",
            "Bista",
            "Rai",
            "Maharjan",
            "Adhikari",
        )
        generated_rooms = [row[0] for row in self._generated_seed_room_rows()]
        rows: list[
            tuple[str, str, str, str, str, str, str, str, str | None, str | None, int, str]
        ] = []
        room_index = 0
        room_occupancy = 0
        for student_index in range(4, 109):
            first_name = first_names[(student_index - 4) % len(first_names)]
            last_name = last_names[
                ((student_index - 4) // len(first_names)) % len(last_names)
            ]
            room_id = generated_rooms[room_index]
            rows.append(
                (
                    f"student_{student_index}",
                    f"{first_name.lower()}{last_name.lower()}{student_index}",
                    first_name,
                    last_name,
                    f"{first_name.lower()}.{last_name.lower()}{student_index}@hostelhub.edu",
                    self._hash_password("Student@123"),
                    f"98{30000000 + student_index:08d}",
                    "student",
                    room_id,
                    None,
                    1,
                    self._utc_now(days_ago=50),
                )
            )
            room_occupancy += 1
            if room_occupancy == 3:
                room_index += 1
                room_occupancy = 0
        return rows

    def _hash_password(self, password: str) -> str:
        normalized_password = password.strip()
        salt = secrets.token_hex(16)
        iterations = _password_hash_iterations()
        digest = hashlib.pbkdf2_hmac(
            "sha256",
            normalized_password.encode("utf-8"),
            salt.encode("utf-8"),
            iterations,
        ).hex()
        return (
            f"{PASSWORD_HASH_ALGORITHM}$"
            f"{iterations}$"
            f"{salt}$"
            f"{digest}"
        )

    def _is_password_hashed(self, stored_password: str) -> bool:
        return stored_password.startswith(f"{PASSWORD_HASH_ALGORITHM}$")

    def _verify_password(
        self,
        candidate_password: str,
        stored_password: str,
    ) -> bool:
        normalized_password = candidate_password.strip()
        if not self._is_password_hashed(stored_password):
            return hmac.compare_digest(
                stored_password,
                normalized_password,
            )
        parts = stored_password.split("$", 3)
        if len(parts) != 4:
            return False
        algorithm, iterations_raw, salt, expected_digest = parts
        if algorithm != PASSWORD_HASH_ALGORITHM:
            return False
        try:
            iterations = int(iterations_raw)
        except ValueError:
            return False
        resolved_digest = hashlib.pbkdf2_hmac(
            "sha256",
            normalized_password.encode("utf-8"),
            salt.encode("utf-8"),
            iterations,
        ).hex()
        return hmac.compare_digest(expected_digest, resolved_digest)

    def _generate_auth_token(self, *, user_id: str, user_role: str) -> str:
        issued_at = int(datetime.now(tz=timezone.utc).timestamp())
        expires_at = issued_at + (self._auth_token_ttl_minutes * 60)
        header = {
            "alg": "HS256",
            "typ": "JWT",
        }
        payload = {
            "sub": user_id,
            "user_role": user_role,
            "iat": issued_at,
            "exp": expires_at,
        }
        encoded_header = _urlsafe_b64encode(
            json.dumps(header, separators=(",", ":")).encode("utf-8")
        )
        encoded_payload = _urlsafe_b64encode(
            json.dumps(payload, separators=(",", ":")).encode("utf-8")
        )
        signed_value = f"{encoded_header}.{encoded_payload}"
        signature = hmac.new(
            self._auth_token_secret.encode("utf-8"),
            signed_value.encode("utf-8"),
            hashlib.sha256,
        ).digest()
        return f"{signed_value}.{_urlsafe_b64encode(signature)}"

    def _validate_email(self, email: str) -> None:
        if re.fullmatch(r"[^@\s]+@[^@\s]+\.[^@\s]+", email.strip()) is None:
            raise BackendError("Enter a valid email address.")

    def _validate_password(self, password: str) -> None:
        if len(password.strip()) < 8:
            raise BackendError("Password must be at least 8 characters.")

    def _is_phone_number(self, value: str) -> bool:
        return re.fullmatch(r"\d{10}", value.strip()) is not None

    def _mess_date_for_day(self, day: str) -> str:
        if day not in MESS_DAYS:
            raise BackendError("Invalid mess day.")
        now = datetime.now(timezone.utc)
        start_of_week = now - timedelta(days=now.weekday())
        target = start_of_week + timedelta(days=MESS_DAYS.index(day))
        resolved = datetime(
            target.year,
            target.month,
            target.day,
            tzinfo=timezone.utc,
        )
        return resolved.isoformat()

    def _billing_month_label(self, timestamp: datetime | None = None) -> str:
        resolved = timestamp or datetime.now(timezone.utc)
        return resolved.strftime("%B %Y")

    def _default_due_date(self) -> str:
        now = datetime.now(timezone.utc)
        return datetime(now.year, now.month, 12, tzinfo=timezone.utc).isoformat()

    def _receipt_id(self) -> str:
        return f"RCT-{datetime.now(timezone.utc).strftime('%Y%m%d%H%M%S')}-{secrets.token_hex(2).upper()}"

    def _pass_code(self, timestamp: datetime) -> str:
        return f"GP-{timestamp.strftime('%y%m%d')}-{secrets.token_hex(2).upper()}"

    def _new_id(self, prefix: str) -> str:
        return f"{prefix}_{secrets.token_hex(4)}"

    def _new_room_id(self, block: str, number: str) -> str:
        sanitized_number = "".join(
            character.lower() for character in number if character.isalnum()
        )
        return f"room_{block.lower()}{sanitized_number}"

    def _parse_iso_datetime(self, value: str) -> datetime:
        return datetime.fromisoformat(value)

    def _now_for_datetime(self, reference: datetime) -> datetime:
        if reference.tzinfo is None:
            return datetime.now()
        return datetime.now(tz=timezone.utc)

    def _utc_now(self, *, days_ago: int = 0) -> str:
        return (
            datetime.now(tz=timezone.utc) - timedelta(days=days_ago)
        ).isoformat()
