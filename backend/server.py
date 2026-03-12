from __future__ import annotations

import argparse
import json
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import Any
from urllib.parse import urlparse

from backend.repository import BackendError, HostelDataStore


class HostelApiServer(ThreadingHTTPServer):
    daemon_threads = True
    allow_reuse_address = True


class HostelRequestHandler(BaseHTTPRequestHandler):
    repository: HostelDataStore

    def do_OPTIONS(self) -> None:  # noqa: N802
        self._send_json(204, None)

    def do_GET(self) -> None:  # noqa: N802
        self._dispatch("GET")

    def do_POST(self) -> None:  # noqa: N802
        self._dispatch("POST")

    def do_PATCH(self) -> None:  # noqa: N802
        self._dispatch("PATCH")

    def do_DELETE(self) -> None:  # noqa: N802
        self._dispatch("DELETE")

    def log_message(self, format: str, *args: Any) -> None:  # noqa: A003
        return

    def _dispatch(self, method: str) -> None:
        path = urlparse(self.path).path
        try:
            if method == "GET":
                payload, status = self._handle_get(path)
            elif method == "POST":
                payload, status = self._handle_post(path)
            elif method == "PATCH":
                payload, status = self._handle_patch(path)
            elif method == "DELETE":
                payload, status = self._handle_delete(path)
            else:
                raise BackendError("Method not allowed.", 405)
            self._send_json(status, payload)
        except BackendError as error:
            self._send_json(
                error.status_code,
                {"message": error.message},
            )
        except json.JSONDecodeError:
            self._send_json(400, {"message": "Request body must be valid JSON."})
        except Exception:
            self._send_json(
                500,
                {"message": "Unexpected backend error."},
            )

    def _handle_get(self, path: str) -> tuple[Any, int]:
        segments = self._segments(path)
        if path == "/health":
            return self.repository.health(), 200
        if path == "/setup/status":
            return self.repository.setup_status(), 200
        if path == "/catalog":
            return self.repository.get_admin_catalog(), 200
        if path == "/blocks":
            return self.repository.list_blocks(), 200
        if path == "/students":
            return self.repository.list_students(), 200
        if path == "/guests":
            return self.repository.list_guests(), 200
        if path == "/staff":
            return self.repository.list_staff(), 200
        if len(segments) == 2 and segments[0] == "users":
            return self.repository.get_user(segments[1]), 200
        if len(segments) == 2 and segments[0] == "chat":
            return self.repository.list_chat_messages(segments[1]), 200
        if path == "/rooms":
            return self.repository.list_rooms(), 200
        if path == "/issues":
            user = self._authenticated_user()
            return (
                self.repository.list_issues(
                    user_id=user["id"],
                    role=user["role"],
                    job_title=user.get("jobTitle"),
                ),
                200,
            )
        if path == "/gate-passes":
            return self.repository.list_gate_passes(), 200
        if path == "/parcels":
            return self.repository.list_parcels(), 200
        if path == "/visitors":
            return self.repository.list_visitor_entries(), 200
        if path == "/laundry-bookings":
            return self.repository.list_laundry_bookings(), 200
        if path == "/admin/catalog":
            self._require_admin_user()
            return self.repository.get_admin_catalog(), 200
        if path == "/mess/menu":
            return self.repository.list_mess_menu(), 200
        if path == "/mess/attendance":
            return self.repository.list_meal_attendance(), 200
        if path == "/mess/feedback":
            return self.repository.list_mess_feedback(), 200
        if path == "/notices":
            return self.repository.list_notices(), 200
        if path == "/room-change-requests":
            return self.repository.list_room_change_requests(), 200
        if path == "/fee-settings":
            self._require_admin_user()
            return self.repository.get_fee_settings(), 200
        if len(segments) == 2 and segments[0] == "notifications":
            return self.repository.list_notifications(segments[1]), 200
        if len(segments) == 3 and segments[0] == "mess" and segments[1] == "bill":
            return self.repository.get_mess_bill(segments[2]), 200
        if len(segments) == 2 and segments[0] == "fees":
            return self.repository.get_fee_summary(segments[1]), 200
        if len(segments) == 2 and segments[0] == "payments":
            return self.repository.get_payment_history(segments[1]), 200
        raise BackendError("Endpoint not found.", 404)

    def _handle_post(self, path: str) -> tuple[Any, int]:
        payload = self._read_json()
        if path == "/blocks":
            return (
                self.repository.create_block(
                    code=self._required(payload, "code"),
                    name=self._required(payload, "name"),
                    description=payload.get("description"),
                ),
                201,
            )
        if path == "/auth/login":
            identifier = payload.get("identifier") or payload.get("email")
            return (
                self.repository.login(
                    identifier=self._required(
                        {"identifier": identifier},
                        "identifier",
                    ),
                    password=self._required(payload, "password"),
                ),
                200,
            )
        if path == "/auth/bootstrap-admin":
            return (
                self.repository.bootstrap_admin(
                    username=self._required(payload, "username"),
                    first_name=self._required(payload, "firstName"),
                    last_name=self._required(payload, "lastName"),
                    email=self._required(payload, "email"),
                    password=self._required(payload, "password"),
                    phone_number=self._required(payload, "phoneNumber"),
                ),
                201,
            )
        if path == "/auth/register":
            return (
                self.repository.register_student(
                    username=self._required(payload, "username"),
                    first_name=self._required(payload, "firstName"),
                    last_name=self._required(payload, "lastName"),
                    email=self._required(payload, "email"),
                    password=self._required(payload, "password"),
                    phone_number=self._required(payload, "phoneNumber"),
                    room_id=self._required(payload, "roomId"),
                ),
                201,
            )
        if path == "/auth/register-guest":
            return (
                self.repository.register_guest(
                    username=self._required(payload, "username"),
                    first_name=self._required(payload, "firstName"),
                    last_name=self._required(payload, "lastName"),
                    email=self._required(payload, "email"),
                    password=self._required(payload, "password"),
                    phone_number=self._required(payload, "phoneNumber"),
                ),
                201,
            )
        if path == "/auth/verify-email/request":
            return (
                self.repository.request_email_verification(
                    email=self._required(payload, "email"),
                ),
                200,
            )
        if path == "/auth/verify-email/confirm":
            return (
                self.repository.verify_email(
                    email=self._required(payload, "email"),
                    code=self._required(payload, "code"),
                ),
                200,
            )
        if path == "/auth/password-reset/request":
            return (
                self.repository.request_password_reset(
                    email=self._required(payload, "email"),
                ),
                200,
            )
        if path == "/auth/password-reset/confirm":
            return (
                self.repository.reset_password(
                    email=self._required(payload, "email"),
                    code=self._required(payload, "code"),
                    new_password=self._required(payload, "newPassword"),
                ),
                200,
            )
        if path == "/issues":
            user = self._authenticated_user()
            student_id = self._required(payload, "studentId")
            if user["role"] != "student" or user["id"] != student_id:
                raise BackendError(
                    "Students can only create issues for their own account.",
                    403,
                )
            return (
                self.repository.create_issue(
                    student_id=student_id,
                    category=self._required(payload, "category"),
                    comment=self._required(payload, "comment"),
                ),
                201,
            )
        if path == "/chat":
            return (
                self.repository.send_chat_message(
                    sender_id=self._required(payload, "senderId"),
                    recipient_id=self._required(payload, "recipientId"),
                    message=self._required(payload, "message"),
                ),
                201,
            )
        if path == "/gate-passes":
            return (
                self.repository.create_gate_pass(
                    student_id=self._required(payload, "studentId"),
                    destination=self._required(payload, "destination"),
                    reason=self._required(payload, "reason"),
                    emergency_contact=self._required(payload, "emergencyContact"),
                    departure_at=self._required(payload, "departureAt"),
                    expected_return_at=self._required(payload, "expectedReturnAt"),
                ),
                201,
            )
        if path == "/parcels":
            return (
                self.repository.create_parcel(
                    user_id=self._required(payload, "userId"),
                    carrier=self._required(payload, "carrier"),
                    tracking_code=self._required(payload, "trackingCode"),
                    note=self._required(payload, "note"),
                ),
                201,
            )
        if path == "/visitors":
            return (
                self.repository.create_visitor_entry(
                    student_id=self._required(payload, "studentId"),
                    visitor_name=self._required(payload, "visitorName"),
                    relation=self._required(payload, "relation"),
                    note=self._required(payload, "note"),
                ),
                201,
            )
        if path == "/laundry-bookings":
            return (
                self.repository.create_laundry_booking(
                    user_id=self._required(payload, "userId"),
                    scheduled_at=self._required(payload, "scheduledAt"),
                    slot_label=self._required(payload, "slotLabel"),
                    machine_label=self._required(payload, "machineLabel"),
                    notes=self._required(payload, "notes"),
                ),
                201,
            )
        if path == "/mess/attendance":
            return (
                self.repository.mark_meal_attendance(
                    user_id=self._required(payload, "userId"),
                    day=self._required(payload, "day"),
                    meal_type=self._required(payload, "mealType"),
                    attended=bool(self._required(payload, "attended")),
                ),
                200,
            )
        if path == "/mess/feedback":
            return (
                self.repository.create_mess_feedback(
                    user_id=self._required(payload, "userId"),
                    rating=int(self._required(payload, "rating")),
                    comment=self._required(payload, "comment"),
                ),
                201,
            )
        if path == "/notices":
            return (
                self.repository.create_notice(
                    title=self._required(payload, "title"),
                    message=self._required(payload, "message"),
                    category=self._required(payload, "category"),
                    is_pinned=bool(payload.get("isPinned", False)),
                ),
                201,
            )
        if path == "/staff":
            return (
                self.repository.create_staff(
                    username=self._required(payload, "username"),
                    first_name=self._required(payload, "firstName"),
                    last_name=self._required(payload, "lastName"),
                    email=self._required(payload, "email"),
                    password=self._required(payload, "password"),
                    phone_number=self._required(payload, "phoneNumber"),
                    job_title=self._required(payload, "jobTitle"),
                ),
                201,
            )
        if path == "/rooms":
            return (
                self.repository.create_room(
                    block=self._required(payload, "block"),
                    number=self._required(payload, "number"),
                    capacity=int(self._required(payload, "capacity")),
                    room_type=self._required(payload, "roomType"),
                ),
                201,
            )
        if path == "/room-change-requests":
            return (
                self.repository.create_room_change_request(
                    student_id=self._required(payload, "studentId"),
                    desired_room_id=self._required(payload, "desiredRoomId"),
                    reason=self._required(payload, "reason"),
                ),
                201,
            )
        if path == "/payments":
            return (
                self.repository.pay_fee(
                    user_id=self._required(payload, "userId"),
                    payment_method=self._required(payload, "paymentMethod"),
                ),
                201,
            )
        if len(self._segments(path)) == 3 and self._segments(path)[0] == "fees":
            segments = self._segments(path)
            if segments[2] == "reminder":
                return (
                    self.repository.send_fee_reminder(segments[1]),
                    200,
                )
        raise BackendError("Endpoint not found.", 404)

    def _handle_patch(self, path: str) -> tuple[Any, int]:
        payload = self._read_json()
        segments = self._segments(path)
        if path == "/fee-settings":
            self._require_admin_user()
            return (
                self.repository.update_fee_settings(
                    maintenance_charge=int(
                        self._required(payload, "maintenanceCharge")
                    ),
                    parking_charge=int(self._required(payload, "parkingCharge")),
                    water_charge=int(self._required(payload, "waterCharge")),
                    single_occupancy_charge=int(
                        self._required(payload, "singleOccupancyCharge")
                    ),
                    double_sharing_charge=int(
                        self._required(payload, "doubleSharingCharge")
                    ),
                    triple_sharing_charge=int(
                        self._required(payload, "tripleSharingCharge")
                    ),
                    custom_charges=payload.get("customCharges", []),
                ),
                200,
            )
        if path == "/admin/catalog":
            self._require_admin_user()
            return (
                self.repository.update_admin_catalog(
                    issue_categories=payload.get("issueCategories", []),
                    notice_categories=payload.get("noticeCategories", []),
                    laundry_machines=payload.get("laundryMachines", []),
                    parcel_carriers=payload.get("parcelCarriers", []),
                    alert_presets=payload.get("alertPresets", []),
                    service_shortcuts=payload.get("serviceShortcuts", []),
                ),
                200,
            )
        if len(segments) == 3 and segments[0] == "students":
            if segments[2] == "room":
                return (
                    self.repository.assign_resident_room(
                        user_id=segments[1],
                        room_id=self._required(payload, "roomId"),
                    ),
                    200,
                )
        if len(segments) == 2 and segments[0] == "issues":
            self._require_issue_worker(segments[1])
            return (
                self.repository.update_issue_status(
                    issue_id=segments[1],
                    status=self._required(payload, "status"),
                ),
                200,
            )
        if len(segments) == 3 and segments[0] == "issues":
            if segments[2] == "assign":
                self._require_admin_or_warden_user()
                return (
                    self.repository.assign_issue(
                        issue_id=segments[1],
                        staff_id=self._required(payload, "staffId"),
                    ),
                    200,
                )
        if len(segments) == 3 and segments[0] == "gate-passes":
            if segments[2] == "review":
                return (
                    self.repository.review_gate_pass(
                        gate_pass_id=segments[1],
                        status=self._required(payload, "status"),
                    ),
                    200,
                )
            if segments[2] == "checkout":
                return (
                    self.repository.mark_gate_pass_departure(segments[1]),
                    200,
                )
            if segments[2] == "return":
                return (
                    self.repository.mark_gate_pass_return(segments[1]),
                    200,
                )
        if len(segments) == 3 and segments[0] == "parcels":
            if segments[2] == "collect":
                return (
                    self.repository.mark_parcel_collected(segments[1]),
                    200,
                )
        if len(segments) == 3 and segments[0] == "visitors":
            if segments[2] == "checkout":
                return (
                    self.repository.check_out_visitor(segments[1]),
                    200,
                )
        if len(segments) == 2 and segments[0] == "laundry-bookings":
            return (
                self.repository.update_laundry_booking_status(
                    booking_id=segments[1],
                    status=self._required(payload, "status"),
                ),
                200,
            )
        if len(segments) == 3 and segments[0] == "mess" and segments[1] == "menu":
            return (
                self.repository.update_mess_menu_day(
                    day=segments[2],
                    breakfast=self._required(payload, "breakfast"),
                    lunch=self._required(payload, "lunch"),
                    dinner=self._required(payload, "dinner"),
                ),
                200,
            )
        if len(segments) == 2 and segments[0] == "room-change-requests":
            return (
                self.repository.update_room_change_request_status(
                    request_id=segments[1],
                    status=self._required(payload, "status"),
                ),
                200,
            )
        if len(segments) == 3 and segments[0] == "notifications":
            if segments[2] == "read":
                return (
                    self.repository.mark_notification_read(segments[1]),
                    200,
                )
        if len(segments) == 3 and segments[0] == "notifications":
            if segments[2] == "read-all":
                self.repository.mark_all_notifications_read(segments[1])
                return {"status": "ok"}, 200
        if path == "/chat/read":
            self.repository.mark_chat_thread_read(
                user_id=self._required(payload, "userId"),
                partner_id=self._required(payload, "partnerId"),
            )
            return {"status": "ok"}, 200
        if path == "/admin/prepare-clean-workspace":
            self.repository.prepare_clean_workspace(
                admin_id=self._required(payload, "adminId"),
            )
            return {"status": "ok"}, 200
        raise BackendError("Endpoint not found.", 404)

    def _handle_delete(self, path: str) -> tuple[Any, int]:
        segments = self._segments(path)
        if len(segments) == 2 and segments[0] == "staff":
            self.repository.delete_staff(segments[1])
            return {"status": "deleted"}, 200
        raise BackendError("Endpoint not found.", 404)

    def _read_json(self) -> dict[str, Any]:
        content_length = int(self.headers.get("Content-Length", "0"))
        if content_length == 0:
            return {}
        raw_body = self.rfile.read(content_length).decode("utf-8")
        if not raw_body:
            return {}
        return json.loads(raw_body)

    def _required(self, payload: dict[str, Any], field: str) -> Any:
        value = payload.get(field)
        if value is None:
            raise BackendError(f"{field} is required.")
        if isinstance(value, str) and not value.strip():
            raise BackendError(f"{field} is required.")
        return value

    def _segments(self, path: str) -> list[str]:
        return [segment for segment in path.split("/") if segment]

    def _authenticated_user(self) -> dict[str, Any]:
        header = self.headers.get("Authorization", "").strip()
        if not header:
            raise BackendError("Authorization header is required.", 401)
        scheme, _, token = header.partition(" ")
        if scheme.lower() != "bearer" or not token.strip():
            raise BackendError("Authorization header must use Bearer token.", 401)
        return self.repository.verify_auth_token(token.strip())

    def _require_admin_user(self) -> dict[str, Any]:
        user = self._authenticated_user()
        if user["role"] != "admin":
            raise BackendError("Admin access is required.", 403)
        return user

    def _is_admin_or_warden(self, user: dict[str, Any]) -> bool:
        if user["role"] == "admin":
            return True
        if user["role"] != "staff":
            return False
        return "warden" in (user.get("jobTitle") or "").strip().lower()

    def _require_admin_or_warden_user(self) -> dict[str, Any]:
        user = self._authenticated_user()
        if not self._is_admin_or_warden(user):
            raise BackendError("Admin or warden access is required.", 403)
        return user

    def _require_issue_worker(self, issue_id: str) -> tuple[dict[str, Any], dict[str, Any]]:
        user = self._authenticated_user()
        issue = self.repository.get_issue(issue_id)
        if self._is_admin_or_warden(user):
            return user, issue
        if user["role"] == "staff" and issue.get("assignedStaffId") == user["id"]:
            return user, issue
        raise BackendError(
            "Only the assigned staff member, admin, or warden can update this issue.",
            403,
        )

    def _send_json(self, status_code: int, payload: Any) -> None:
        body = b"" if payload is None else json.dumps(payload).encode("utf-8")
        self.send_response(status_code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header(
            "Access-Control-Allow-Methods",
            "GET, POST, PATCH, DELETE, OPTIONS",
        )
        self.send_header(
            "Access-Control-Allow-Headers",
            "Content-Type, Authorization",
        )
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        if body:
            self.wfile.write(body)


def create_server(
    *,
    host: str = "127.0.0.1",
    port: int = 8000,
    db_path: str | Path | None = None,
    demo_mode: bool = False,
) -> HostelApiServer:
    storage_path = db_path or Path(__file__).resolve().parent / "data" / "hostel.db"
    repository = HostelDataStore(storage_path, demo_mode=demo_mode)
    handler = type(
        "BoundHostelRequestHandler",
        (HostelRequestHandler,),
        {"repository": repository},
    )
    return HostelApiServer((host, port), handler)


def _env_flag(name: str, *, default: bool = False) -> bool:
    value = os.environ.get(name)
    if value is None:
        return default
    return value.strip().lower() in {"1", "true", "yes", "on"}


def main() -> None:
    default_db_path = str(Path(__file__).resolve().parent / "data" / "hostel.db")
    default_host = (
        os.environ.get("HOSTEL_HOST")
        or os.environ.get("HOST")
        or "127.0.0.1"
    )
    default_port = int(
        os.environ.get("HOSTEL_PORT")
        or os.environ.get("PORT")
        or "8000"
    )
    parser = argparse.ArgumentParser(description="Hostel management Python backend")
    parser.add_argument("--host", default=default_host)
    parser.add_argument("--port", default=default_port, type=int)
    parser.add_argument(
        "--demo-data",
        action="store_true",
        default=_env_flag("HOSTEL_DEMO_DATA"),
        help="Seed development demo data into a new database.",
    )
    parser.add_argument(
        "--db-path",
        default=os.environ.get("HOSTEL_DB_PATH") or default_db_path,
    )
    args = parser.parse_args()

    server = create_server(
        host=args.host,
        port=args.port,
        db_path=args.db_path,
        demo_mode=args.demo_data,
    )
    address = server.server_address
    print(f"Python backend listening on http://{address[0]}:{address[1]}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
