from __future__ import annotations

from concurrent.futures import ThreadPoolExecutor
from contextlib import redirect_stderr, redirect_stdout
from datetime import datetime, timedelta
import io
import json
import tempfile
import threading
import time
import unittest
import urllib.error
import urllib.request
from pathlib import Path

from backend.manage import main as manage_main
from backend.repository import HostelDataStore
from backend.server import create_server


class FakeAuthChallengeMailer:
    def __init__(self) -> None:
        self.messages: list[dict[str, str]] = []

    def send_auth_challenge(
        self,
        *,
        email: str,
        purpose: str,
        code: str,
        expires_at: str,
    ) -> None:
        self.messages.append(
            {
                "email": email,
                "purpose": purpose,
                "code": code,
                "expiresAt": expires_at,
            }
        )


class HostelDataStoreTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory()
        self.db_path = Path(self.temp_dir.name) / "hostel_test.db"
        self.store = HostelDataStore(self.db_path, demo_mode=True)

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def test_register_student_assigns_selected_room(self) -> None:
        registered_user = self.store.register_student(
            username="newstudent",
            first_name="New",
            last_name="Student",
            email="new.student@hostelhub.edu",
            password="Student@123",
            phone_number="9801111111",
            room_id="room_a102",
        )

        rooms = self.store.list_rooms()
        assigned_room = next(room for room in rooms if room["id"] == "room_a102")
        fees = self.store.get_fee_summary(registered_user["id"])

        self.assertEqual(registered_user["roomId"], "room_a102")
        self.assertIn(registered_user["id"], assigned_room["residentIds"])
        self.assertGreater(fees["total"], 0)

    def test_approving_room_request_moves_student(self) -> None:
        self.store.update_room_change_request_status(
            request_id="request_1",
            status="approved",
        )

        students = self.store.list_students()
        rooms = self.store.list_rooms()
        moved_student = next(
            student for student in students if student["id"] == "student_1"
        )
        old_room = next(room for room in rooms if room["id"] == "room_b413")
        new_room = next(room for room in rooms if room["id"] == "room_a102")

        self.assertEqual(moved_student["roomId"], "room_a102")
        self.assertNotIn("student_1", old_room["residentIds"])
        self.assertIn("student_1", new_room["residentIds"])

    def test_assigning_resident_room_moves_student_and_resolves_request(self) -> None:
        moved_student = self.store.assign_resident_room(
            user_id="student_1",
            room_id="room_a102",
        )

        rooms = self.store.list_rooms()
        requests = self.store.list_room_change_requests()
        old_room = next(room for room in rooms if room["id"] == "room_b413")
        new_room = next(room for room in rooms if room["id"] == "room_a102")
        request = next(item for item in requests if item["id"] == "request_1")

        self.assertEqual(moved_student["roomId"], "room_a102")
        self.assertNotIn("student_1", old_room["residentIds"])
        self.assertIn("student_1", new_room["residentIds"])
        self.assertEqual(request["status"], "approved")

    def test_seed_data_contains_over_100_students(self) -> None:
        students = self.store.list_students()

        self.assertGreaterEqual(len(students), 100)
        self.assertTrue(
            all(student["email"].endswith("@hostelhub.edu") for student in students)
        )

    def test_email_verification_marks_account_verified(self) -> None:
        created = self.store.register_student(
            username="verifyme",
            first_name="Verify",
            last_name="Me",
            email="verify.me@hostelhub.edu",
            password="Student@123",
            phone_number="9801111112",
            room_id="room_a102",
        )

        challenge = self.store.request_email_verification(email=created["email"])
        verified = self.store.verify_email(
            email=created["email"],
            code=challenge["code"],
        )

        self.assertEqual(challenge["deliveryMethod"], "local")
        self.assertTrue(verified["emailVerified"])

    def test_email_verification_uses_mailer_when_configured(self) -> None:
        mailer = FakeAuthChallengeMailer()
        store = HostelDataStore(
            self.db_path,
            demo_mode=True,
            auth_challenge_mailer=mailer,
        )
        created = store.register_guest(
            username="mailguest",
            first_name="Mail",
            last_name="Guest",
            email="mail.guest@gmail.com",
            password="Guest@123",
            phone_number="9801111122",
        )

        challenge = store.request_email_verification(email=created["email"])

        self.assertEqual(challenge["deliveryMethod"], "email")
        self.assertEqual(len(mailer.messages), 1)
        self.assertEqual(mailer.messages[0]["purpose"], "verify-email")

    def test_register_guest_creates_guest_without_room_assignment(self) -> None:
        created = self.store.register_guest(
            username="guestarrival",
            first_name="Guest",
            last_name="Arrival",
            email="guest.arrival@hostelhub.edu",
            password="Guest@123",
            phone_number="9801111113",
        )

        guests = self.store.list_guests()
        staff = self.store.list_staff()

        self.assertEqual(created["role"], "guest")
        self.assertIsNone(created["roomId"])
        self.assertTrue(any(item["id"] == created["id"] for item in guests))
        self.assertFalse(any(item["id"] == created["id"] for item in staff))

    def test_password_reset_updates_login_credentials(self) -> None:
        challenge = self.store.request_password_reset(
            email="aayush.dc@hostelhub.edu"
        )

        self.store.reset_password(
            email="aayush.dc@hostelhub.edu",
            code=challenge["code"],
            new_password="Student@456",
        )

        logged_in = self.store.login(
            identifier="aayush.dc@hostelhub.edu",
            password="Student@456",
        )

        self.assertEqual(logged_in["id"], "student_1")

    def test_passwords_are_hashed_at_rest(self) -> None:
        created = self.store.register_guest(
            username="hashguest",
            first_name="Hash",
            last_name="Guest",
            email="hash.guest@hostelhub.edu",
            password="Guest@123",
            phone_number="9801111155",
        )

        with self.store._connect() as conn:
            stored_password = conn.execute(
                "SELECT password FROM users WHERE id = ?",
                (created["id"],),
            ).fetchone()["password"]

        self.assertNotEqual(stored_password, "Guest@123")
        self.assertTrue(stored_password.startswith("pbkdf2_sha256$"))

    def test_login_returns_signed_auth_token(self) -> None:
        logged_in = self.store.login(
            identifier="admin@hostelhub.edu",
            password="Admin@123",
        )
        authenticated = self.store.verify_auth_token(logged_in["authToken"])

        self.assertEqual(authenticated["id"], "admin_1")
        self.assertEqual(authenticated["role"], "admin")

    def test_existing_plaintext_passwords_are_migrated_on_initialize(self) -> None:
        with self.store._connect() as conn:
            conn.execute(
                "UPDATE users SET password = ? WHERE id = 'student_1'",
                ("Student@123",),
            )

        migrated_store = HostelDataStore(self.db_path, demo_mode=True)
        logged_in = migrated_store.login(
            identifier="aayush.dc@hostelhub.edu",
            password="Student@123",
        )

        with migrated_store._connect() as conn:
            stored_password = conn.execute(
                "SELECT password FROM users WHERE id = 'student_1'"
            ).fetchone()["password"]

        self.assertEqual(logged_in["id"], "student_1")
        self.assertTrue(stored_password.startswith("pbkdf2_sha256$"))

    def test_backend_handles_parallel_student_reads(self) -> None:
        identifiers = [
            student["email"] for student in self.store.list_students()[:30]
        ]

        with ThreadPoolExecutor(max_workers=12) as executor:
            results = list(
                executor.map(
                    lambda identifier: self.store.login(
                        identifier=identifier,
                        password="Student@123",
                    ),
                    identifiers,
                )
            )

        self.assertEqual(len(results), len(identifiers))
        self.assertTrue(all(result["role"] == "student" for result in results))

    def test_create_block_and_room_extend_inventory(self) -> None:
        block = self.store.create_block(
            code="F",
            name="City View",
            description="New compact resident wing.",
        )
        room = self.store.create_room(
            block="F",
            number="301",
            capacity=2,
            room_type="Double Sharing",
        )

        blocks = self.store.list_blocks()
        rooms = self.store.list_rooms()

        self.assertEqual(block["code"], "F")
        self.assertEqual(room["block"], "F")
        self.assertTrue(any(item["code"] == "F" for item in blocks))
        self.assertTrue(any(item["id"] == room["id"] for item in rooms))

    def test_updating_fee_settings_recalculates_student_fees(self) -> None:
        updated = self.store.update_fee_settings(
            maintenance_charge=1500,
            parking_charge=450,
            water_charge=600,
            single_occupancy_charge=7000,
            double_sharing_charge=5600,
            triple_sharing_charge=4700,
            custom_charges=[{"label": "Wi-Fi", "amount": 300}],
        )

        fees = self.store.get_fee_summary("student_1")

        self.assertEqual(updated["doubleSharingCharge"], 5600)
        self.assertEqual(fees["roomCharge"], 5600)
        self.assertEqual(fees["total"], 8950)
        self.assertIn(
            "Electricity",
            [item["label"] for item in fees["additionalCharges"]],
        )

    def test_updating_fee_settings_rolls_to_current_month_only(self) -> None:
        previous_month = "February 2026"
        with self.store._connect() as conn:
            conn.execute(
                """
                UPDATE fee_summaries
                SET billing_month = ?, paid_amount = 9100
                WHERE user_id = 'student_2'
                """,
                (previous_month,),
            )
            conn.execute("DELETE FROM payment_records WHERE user_id = 'student_2'")
            conn.execute(
                """
                INSERT INTO payment_records (
                    id, user_id, amount, payment_method, status,
                    receipt_id, billing_month, paid_at
                )
                VALUES (?, ?, ?, ?, 'paid', ?, ?, ?)
                """,
                (
                    "payment_previous_cycle",
                    "student_2",
                    9100,
                    "card",
                    self.store._receipt_id(),
                    previous_month,
                    self.store._utc_now(days_ago=30),
                ),
            )

        self.store.update_fee_settings(
            maintenance_charge=1500,
            parking_charge=450,
            water_charge=600,
            single_occupancy_charge=7000,
            double_sharing_charge=5600,
            triple_sharing_charge=4700,
            custom_charges=[{"label": "Wi-Fi", "amount": 300}],
        )

        summary = self.store.get_fee_summary("student_2")
        history = self.store.get_payment_history("student_2")

        self.assertEqual(summary["billingMonth"], self.store._billing_month_label())
        self.assertEqual(summary["paidAmount"], 0)
        self.assertEqual(history[0]["billingMonth"], previous_month)
        self.assertEqual(history[0]["amount"], 9100)

    def test_paying_fee_creates_receipt_and_clears_balance(self) -> None:
        payment = self.store.pay_fee(
            user_id="student_1",
            payment_method="card",
        )
        summary = self.store.get_fee_summary("student_1")
        history = self.store.get_payment_history("student_1")

        self.assertTrue(payment["receiptId"].startswith("RCT-"))
        self.assertEqual(summary["balance"], 0)
        self.assertTrue(summary["isPaid"])
        self.assertEqual(history[0]["receiptId"], payment["receiptId"])

    def test_creating_notice_publishes_board_update(self) -> None:
        notice = self.store.create_notice(
            title="Water tank cleaning",
            message="Water supply will pause from 11 AM to 1 PM on Friday.",
            category="Announcement",
            is_pinned=True,
        )
        notices = self.store.list_notices()

        self.assertTrue(notice["isPinned"])
        self.assertEqual(notices[0]["title"], "Water tank cleaning")
        self.assertEqual(notices[0]["category"], "Announcement")

    def test_assigning_issue_links_staff_and_moves_status_forward(self) -> None:
        issue = self.store.assign_issue(
            issue_id="issue_1",
            staff_id="staff_2",
        )

        self.assertEqual(issue["assignedStaffId"], "staff_2")
        self.assertEqual(issue["status"], "inProgress")

    def test_assigning_issue_notifies_the_new_assignee(self) -> None:
        self.store.assign_issue(
            issue_id="issue_1",
            staff_id="staff_2",
        )

        notifications = self.store.list_notifications("staff_2")

        self.assertTrue(
            any(
                item["title"] == "Issue assigned"
                and item["type"] == "complaint"
                for item in notifications
            )
        )

    def test_creating_gate_pass_stores_a_pending_request(self) -> None:
        departure_at = "2026-03-10T10:00:00+00:00"
        expected_return_at = "2026-03-10T18:00:00+00:00"
        gate_pass = self.store.create_gate_pass(
            student_id="student_2",
            destination="Kalanki",
            reason="Family function",
            emergency_contact="9801234567",
            departure_at=departure_at,
            expected_return_at=expected_return_at,
        )
        passes = self.store.list_gate_passes()

        self.assertEqual(gate_pass["status"], "pending")
        self.assertTrue(any(item["id"] == gate_pass["id"] for item in passes))

    def test_marking_gate_pass_return_closes_the_trip(self) -> None:
        gate_pass = self.store.mark_gate_pass_return("gatepass_1")

        self.assertIn(gate_pass["status"], {"returned", "late"})
        self.assertIsNotNone(gate_pass["returnedAt"])

    def test_marking_gate_pass_return_handles_local_datetime_records(self) -> None:
        now = datetime.now()
        gate_pass = self.store.create_gate_pass(
            student_id="student_2",
            destination="Baneshwor",
            reason="Family visit",
            emergency_contact="9801234567",
            departure_at=(now - timedelta(hours=4)).isoformat(timespec="seconds"),
            expected_return_at=(
                now - timedelta(hours=1)
            ).isoformat(timespec="seconds"),
        )

        self.store.review_gate_pass(
            gate_pass_id=gate_pass["id"],
            status="approved",
        )
        self.store.mark_gate_pass_departure(gate_pass["id"])
        updated = self.store.mark_gate_pass_return(gate_pass["id"])

        self.assertIn(updated["status"], {"returned", "late"})
        self.assertIsNotNone(updated["returnedAt"])

    def test_marking_meal_attendance_updates_mess_bill(self) -> None:
        attendance = self.store.mark_meal_attendance(
            user_id="student_1",
            day="friday",
            meal_type="dinner",
            attended=True,
        )
        bill = self.store.get_mess_bill("student_1")

        self.assertTrue(attendance["dinner"])
        self.assertGreaterEqual(bill["dinnerCount"], 1)
        self.assertGreater(bill["dinnerRate"], 0)

    def test_updating_mess_menu_changes_the_requested_day(self) -> None:
        updated = self.store.update_mess_menu_day(
            day="monday",
            breakfast="Oats and fruit",
            lunch="Rice bowl",
            dinner="Soup and toast",
        )
        menu = self.store.list_mess_menu()

        self.assertEqual(updated["breakfast"], "Oats and fruit")
        self.assertEqual(menu[0]["day"], "monday")
        self.assertEqual(menu[0]["dinner"], "Soup and toast")

    def test_admin_catalog_updates_operational_lists(self) -> None:
        updated = self.store.update_admin_catalog(
            issue_categories=["Bathroom", "Internet"],
            notice_categories=["Announcement", "Emergency"],
            laundry_machines=["Machine A", "Machine D"],
            parcel_carriers=["DHL", "Blue Dart"],
            alert_presets=[
                {
                    "title": "Emergency alert",
                    "category": "Emergency",
                    "message": "Immediate response required.",
                }
            ],
            service_shortcuts=[
                {
                    "title": "Emergency",
                    "subtitle": "Alerts",
                    "route": "/notifications",
                    "iconKey": "notifications",
                    "roles": ["admin", "staff"],
                    "accentHex": "#D92D20",
                }
            ],
        )

        self.assertIn("Internet", updated["issueCategories"])
        self.assertIn("Emergency", updated["noticeCategories"])
        self.assertEqual(updated["laundryMachines"][-1], "Machine D")

    def test_clean_workspace_keeps_blank_mess_menu_days_available(self) -> None:
        self.store.prepare_clean_workspace(admin_id="admin_1")

        menu = self.store.list_mess_menu()

        self.assertEqual(len(menu), 7)
        self.assertTrue(all(item["breakfast"] == "" for item in menu))

    def test_creating_parcel_adds_a_pending_front_desk_record(self) -> None:
        parcel = self.store.create_parcel(
            user_id="student_3",
            carrier="FedEx",
            tracking_code="FDX-4488",
            note="Electronics package",
        )
        parcels = self.store.list_parcels()

        self.assertEqual(parcel["status"], "awaitingPickup")
        self.assertEqual(parcels[0]["id"], parcel["id"])

    def test_checking_out_visitor_updates_the_entry(self) -> None:
        visitor = self.store.check_out_visitor("visitor_1")
        entries = self.store.list_visitor_entries()

        self.assertIsNotNone(visitor["checkedOutAt"])
        updated = next(item for item in entries if item["id"] == "visitor_1")
        self.assertIsNotNone(updated["checkedOutAt"])

    def test_notifications_can_be_marked_read(self) -> None:
        notifications = self.store.list_notifications("student_1")
        unread = next(item for item in notifications if item["readAt"] is None)

        updated = self.store.mark_notification_read(unread["id"])
        self.store.mark_all_notifications_read("student_1")
        refreshed = self.store.list_notifications("student_1")

        self.assertIsNotNone(updated["readAt"])
        self.assertTrue(all(item["readAt"] is not None for item in refreshed))

    def test_sending_chat_message_creates_chat_notification(self) -> None:
        self.store.send_chat_message(
            sender_id="student_1",
            recipient_id="staff_1",
            message="Need help with my room.",
        )

        notifications = self.store.list_notifications("staff_1")
        message_notification = next(
            item for item in notifications if item["title"] == "New message"
        )

        self.assertEqual(message_notification["type"], "chat")

    def test_creating_laundry_booking_adds_schedule_entry(self) -> None:
        booking = self.store.create_laundry_booking(
            user_id="student_3",
            scheduled_at="2026-03-11T08:00:00+00:00",
            slot_label="08:00 - 09:00",
            machine_label="Machine C",
            notes="Uniform wash",
        )
        bookings = self.store.list_laundry_bookings()

        self.assertEqual(booking["status"], "scheduled")
        self.assertTrue(any(item["id"] == booking["id"] for item in bookings))

    def test_clean_mode_bootstraps_first_admin(self) -> None:
        clean_db = Path(self.temp_dir.name) / "clean_hostel.db"
        clean_store = HostelDataStore(clean_db, demo_mode=False)

        status = clean_store.setup_status()
        created = clean_store.bootstrap_admin(
            username="owner",
            first_name="Owner",
            last_name="Admin",
            email="owner@hostelhub.edu",
            password="Admin@123",
            phone_number="9807777777",
        )

        self.assertTrue(status["requiresBootstrap"])
        self.assertEqual(created["role"], "admin")
        self.assertFalse(clean_store.setup_status()["requiresBootstrap"])


class HostelApiServerTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory()
        self.db_path = Path(self.temp_dir.name) / "hostel_api.db"
        self.server = create_server(
            host="127.0.0.1",
            port=0,
            db_path=self.db_path,
            demo_mode=True,
        )
        self.thread = threading.Thread(
            target=self.server.serve_forever,
            daemon=True,
        )
        self.thread.start()
        time.sleep(0.05)

    def tearDown(self) -> None:
        self.server.shutdown()
        self.server.server_close()
        self.thread.join(timeout=2)
        self.temp_dir.cleanup()

    def test_health_endpoint_returns_ok(self) -> None:
        status, payload = self._request("GET", "/health")
        self.assertEqual(status, 200)
        self.assertEqual(payload["status"], "ok")
        self.assertIn("storage", payload)

    def test_login_endpoint_returns_seeded_student(self) -> None:
        status, payload = self._request(
            "POST",
            "/auth/login",
            {
                "identifier": "aayush.dc@hostelhub.edu",
                "password": "Student@123",
            },
        )
        self.assertEqual(status, 200)
        self.assertEqual(payload["role"], "student")
        self.assertEqual(payload["roomId"], "room_b413")
        self.assertIsInstance(payload["authToken"], str)

    def test_user_endpoint_returns_admin_by_id(self) -> None:
        status, payload = self._request("GET", "/users/admin_1")

        self.assertEqual(status, 200)
        self.assertEqual(payload["id"], "admin_1")
        self.assertEqual(payload["role"], "admin")

    def test_password_reset_endpoint_updates_credentials(self) -> None:
        request_status, request_payload = self._request(
            "POST",
            "/auth/password-reset/request",
            {"email": "aayush.dc@hostelhub.edu"},
        )
        self.assertEqual(request_status, 200)

        confirm_status, confirm_payload = self._request(
            "POST",
            "/auth/password-reset/confirm",
            {
                "email": "aayush.dc@hostelhub.edu",
                "code": request_payload["code"],
                "newPassword": "Student@456",
            },
        )
        self.assertEqual(confirm_status, 200)
        self.assertEqual(confirm_payload["id"], "student_1")

    def test_verify_email_endpoints_mark_account_verified(self) -> None:
        register_status, register_payload = self._request(
            "POST",
            "/auth/register",
            {
                "username": "verifyflow",
                "firstName": "Verify",
                "lastName": "Flow",
                "email": "verify.flow@hostelhub.edu",
                "password": "Student@123",
                "phoneNumber": "9801111113",
                "roomId": "room_a102",
            },
        )
        self.assertEqual(register_status, 201)

        request_status, request_payload = self._request(
            "POST",
            "/auth/verify-email/request",
            {"email": register_payload["email"]},
        )
        self.assertEqual(request_status, 200)
        self.assertEqual(request_payload["deliveryMethod"], "local")

        confirm_status, confirm_payload = self._request(
            "POST",
            "/auth/verify-email/confirm",
            {
                "email": register_payload["email"],
                "code": request_payload["code"],
            },
        )
        self.assertEqual(confirm_status, 200)
        self.assertTrue(confirm_payload["emailVerified"])

    def test_chat_endpoint_stores_messages(self) -> None:
        status, payload = self._request(
            "POST",
            "/chat",
            {
                "senderId": "student_1",
                "recipientId": "staff_1",
                "message": "Please confirm tonight's late entry window.",
            },
        )
        self.assertEqual(status, 201)

        list_status, thread = self._request("GET", "/chat/student_1")
        self.assertEqual(list_status, 200)
        self.assertTrue(any(item["id"] == payload["id"] for item in thread))

    def test_fee_settings_endpoint_updates_values(self) -> None:
        admin_headers = self._admin_auth_headers()
        status, payload = self._request(
            "PATCH",
            "/fee-settings",
            {
                "maintenanceCharge": 1500,
                "parkingCharge": 450,
                "waterCharge": 600,
                "singleOccupancyCharge": 7000,
                "doubleSharingCharge": 5600,
                "tripleSharingCharge": 4700,
                "customCharges": [{"label": "Wi-Fi", "amount": 300}],
            },
            headers=admin_headers,
        )
        self.assertEqual(status, 200)
        self.assertEqual(payload["doubleSharingCharge"], 5600)
        self.assertIn(
            "Electricity",
            [item["label"] for item in payload["customCharges"]],
        )

    def test_payment_endpoint_creates_receipt(self) -> None:
        status, payload = self._request(
            "POST",
            "/payments",
            {
                "userId": "student_1",
                "paymentMethod": "eSewa",
            },
        )
        self.assertEqual(status, 201)
        self.assertTrue(payload["receiptId"].startswith("RCT-"))

    def test_notice_endpoint_creates_board_item(self) -> None:
        status, payload = self._request(
            "POST",
            "/notices",
            {
                "title": "Movie night",
                "message": "Common room screening starts at 7:30 PM.",
                "category": "Event",
                "isPinned": False,
            },
        )
        self.assertEqual(status, 201)
        self.assertEqual(payload["category"], "Event")

    def test_public_catalog_endpoint_is_available_without_auth(self) -> None:
        status, payload = self._request("GET", "/catalog")

        self.assertEqual(status, 200)
        self.assertIn("issueCategories", payload)
        self.assertIn("noticeCategories", payload)

    def test_admin_catalog_endpoint_requires_admin_token(self) -> None:
        unauthenticated_status, unauthenticated_payload = self._request(
            "GET",
            "/admin/catalog",
        )
        student_headers = self._login_headers(
            identifier="aayush.dc@hostelhub.edu",
            password="Student@123",
        )
        student_status, student_payload = self._request(
            "GET",
            "/admin/catalog",
            headers=student_headers,
        )
        admin_status, admin_payload = self._request(
            "GET",
            "/admin/catalog",
            headers=self._admin_auth_headers(),
        )

        self.assertEqual(unauthenticated_status, 401)
        self.assertEqual(
            unauthenticated_payload["message"],
            "Authorization header is required.",
        )
        self.assertEqual(student_status, 403)
        self.assertEqual(student_payload["message"], "Admin access is required.")
        self.assertEqual(admin_status, 200)
        self.assertIn("issueCategories", admin_payload)

    def test_gate_pass_review_endpoint_updates_status(self) -> None:
        status, payload = self._request(
            "PATCH",
            "/gate-passes/gatepass_2/review",
            {"status": "approved"},
        )
        self.assertEqual(status, 200)
        self.assertEqual(payload["status"], "approved")

    def test_issue_assignment_endpoint_sets_staff_member(self) -> None:
        status, payload = self._request(
            "PATCH",
            "/issues/issue_1/assign",
            {"staffId": "staff_1"},
            headers=self._admin_auth_headers(),
        )
        self.assertEqual(status, 200)
        self.assertEqual(payload["assignedStaffId"], "staff_1")

    def test_issue_assignment_endpoint_allows_warden_access(self) -> None:
        status, payload = self._request(
            "PATCH",
            "/issues/issue_2/assign",
            {"staffId": "staff_2"},
            headers=self._warden_auth_headers(),
        )

        self.assertEqual(status, 200)
        self.assertEqual(payload["assignedStaffId"], "staff_2")

    def test_issue_assignment_endpoint_rejects_regular_staff(self) -> None:
        status, payload = self._request(
            "PATCH",
            "/issues/issue_2/assign",
            {"staffId": "staff_1"},
            headers=self._support_staff_auth_headers(),
        )

        self.assertEqual(status, 403)
        self.assertEqual(
            payload["message"],
            "Admin or warden access is required.",
        )

    def test_issue_list_endpoint_returns_only_assigned_staff_issues(self) -> None:
        status, payload = self._request(
            "GET",
            "/issues",
            headers=self._support_staff_auth_headers(),
        )

        self.assertEqual(status, 200)
        self.assertEqual(payload, [])

        assign_status, _ = self._request(
            "PATCH",
            "/issues/issue_2/assign",
            {"staffId": "staff_2"},
            headers=self._admin_auth_headers(),
        )
        self.assertEqual(assign_status, 200)

        updated_status, updated_payload = self._request(
            "GET",
            "/issues",
            headers=self._support_staff_auth_headers(),
        )
        self.assertEqual(updated_status, 200)
        self.assertEqual(len(updated_payload), 1)
        self.assertEqual(updated_payload[0]["id"], "issue_2")

    def test_issue_status_endpoint_requires_assigned_staff_or_manager(self) -> None:
        status, payload = self._request(
            "PATCH",
            "/issues/issue_1",
            {"status": "resolved"},
            headers=self._support_staff_auth_headers(),
        )

        self.assertEqual(status, 403)
        self.assertEqual(
            payload["message"],
            "Only the assigned staff member, admin, or warden can update this issue.",
        )

    def test_issue_status_endpoint_allows_assigned_staff(self) -> None:
        status, payload = self._request(
            "PATCH",
            "/issues/issue_1",
            {"status": "resolved"},
            headers=self._warden_auth_headers(),
        )

        self.assertEqual(status, 200)
        self.assertEqual(payload["status"], "resolved")

    def test_room_assignment_endpoint_updates_resident_room(self) -> None:
        status, payload = self._request(
            "PATCH",
            "/students/student_1/room",
            {"roomId": "room_a102"},
        )
        self.assertEqual(status, 200)
        self.assertEqual(payload["roomId"], "room_a102")

    def test_gate_pass_create_endpoint_submits_leave_request(self) -> None:
        status, payload = self._request(
            "POST",
            "/gate-passes",
            {
                "studentId": "student_3",
                "destination": "Baneshwor",
                "reason": "Medical follow-up",
                "emergencyContact": "9822224444",
                "departureAt": "2026-03-10T11:00:00+00:00",
                "expectedReturnAt": "2026-03-10T17:00:00+00:00",
            },
        )
        self.assertEqual(status, 201)
        self.assertEqual(payload["status"], "pending")

    def test_mess_feedback_endpoint_creates_rating_entry(self) -> None:
        status, payload = self._request(
            "POST",
            "/mess/feedback",
            {
                "userId": "student_1",
                "rating": 5,
                "comment": "Lunch was fresh and served on time.",
            },
        )
        self.assertEqual(status, 201)
        self.assertEqual(payload["rating"], 5)
        self.assertEqual(payload["userId"], "student_1")

    def test_mess_menu_endpoint_updates_a_day(self) -> None:
        status, payload = self._request(
            "PATCH",
            "/mess/menu/tuesday",
            {
                "breakfast": "Cornflakes and milk",
                "lunch": "Dal rice",
                "dinner": "Roti and curry",
            },
        )
        self.assertEqual(status, 200)
        self.assertEqual(payload["day"], "tuesday")
        self.assertEqual(payload["breakfast"], "Cornflakes and milk")

    def test_parcel_endpoint_creates_front_desk_item(self) -> None:
        status, payload = self._request(
            "POST",
            "/parcels",
            {
                "userId": "student_1",
                "carrier": "BlueDart",
                "trackingCode": "BD-7701",
                "note": "Bank card delivery",
            },
        )
        self.assertEqual(status, 201)
        self.assertEqual(payload["status"], "awaitingPickup")

    def test_visitor_checkout_endpoint_closes_entry(self) -> None:
        status, payload = self._request(
            "PATCH",
            "/visitors/visitor_1/checkout",
            {},
        )
        self.assertEqual(status, 200)
        self.assertIsNotNone(payload["checkedOutAt"])

    def test_notifications_endpoints_list_and_mark_updates(self) -> None:
        status, payload = self._request("GET", "/notifications/student_1")
        self.assertEqual(status, 200)
        unread = next(item for item in payload if item["readAt"] is None)

        mark_status, mark_payload = self._request(
            "PATCH",
            f"/notifications/{unread['id']}/read",
            {},
        )
        self.assertEqual(mark_status, 200)
        self.assertIsNotNone(mark_payload["readAt"])

        clear_status, clear_payload = self._request(
            "PATCH",
            "/notifications/student_1/read-all",
            {},
        )
        self.assertEqual(clear_status, 200)
        self.assertEqual(clear_payload["status"], "ok")

    def test_laundry_booking_endpoint_creates_slot(self) -> None:
        status, payload = self._request(
            "POST",
            "/laundry-bookings",
            {
                "userId": "student_1",
                "scheduledAt": "2026-03-11T07:00:00+00:00",
                "slotLabel": "07:00 - 08:00",
                "machineLabel": "Machine C",
                "notes": "Bedsheets",
            },
        )
        self.assertEqual(status, 201)
        self.assertEqual(payload["status"], "scheduled")

    def _request(
        self,
        method: str,
        path: str,
        payload: dict[str, object] | None = None,
        headers: dict[str, str] | None = None,
    ) -> tuple[int, object]:
        base_url = f"http://127.0.0.1:{self.server.server_address[1]}"
        body = None if payload is None else json.dumps(payload).encode("utf-8")
        request_headers = {"Content-Type": "application/json"}
        if headers is not None:
            request_headers.update(headers)
        request = urllib.request.Request(
            f"{base_url}{path}",
            data=body,
            headers=request_headers,
            method=method,
        )
        try:
            with urllib.request.urlopen(request, timeout=5) as response:
                raw_payload = response.read().decode("utf-8")
                parsed_payload = {} if not raw_payload else json.loads(raw_payload)
                return response.status, parsed_payload
        except urllib.error.HTTPError as error:
            raw_payload = error.read().decode("utf-8")
            parsed_payload = {} if not raw_payload else json.loads(raw_payload)
            return error.code, parsed_payload

    def _login_headers(self, *, identifier: str, password: str) -> dict[str, str]:
        status, payload = self._request(
            "POST",
            "/auth/login",
            {
                "identifier": identifier,
                "password": password,
            },
        )
        self.assertEqual(status, 200)
        return {"Authorization": f"Bearer {payload['authToken']}"}

    def _admin_auth_headers(self) -> dict[str, str]:
        return self._login_headers(
            identifier="admin@hostelhub.edu",
            password="Admin@123",
        )

    def _warden_auth_headers(self) -> dict[str, str]:
        return self._login_headers(
            identifier="mangal.karki@hostelhub.edu",
            password="Warden@123",
        )

    def _support_staff_auth_headers(self) -> dict[str, str]:
        return self._login_headers(
            identifier="rohit.shah@hostelhub.edu",
            password="Support@123",
        )


class BackendManageCliTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory()
        self.db_path = Path(self.temp_dir.name) / "hostel_cli.db"

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def test_create_user_command_writes_student_to_database(self) -> None:
        self._run_manage(
            "create-block",
            "--code",
            "A",
            "--name",
            "Academic Block",
        )
        self._run_manage(
            "create-room",
            "--block",
            "A",
            "--number",
            "101",
            "--capacity",
            "2",
            "--room-type",
            "Double Sharing",
        )
        _, output, _ = self._run_manage(
            "create-user",
            "--role",
            "student",
            "--username",
            "realstudent",
            "--first-name",
            "Real",
            "--last-name",
            "Student",
            "--email",
            "real.student@hostelhub.edu",
            "--password",
            "Student@123",
            "--phone-number",
            "9801234567",
            "--room-id",
            "room_a101",
            "--email-verified",
        )

        payload = json.loads(output)
        store = HostelDataStore(self.db_path, demo_mode=False)
        logged_in = store.login(
            identifier="real.student@hostelhub.edu",
            password="Student@123",
        )

        self.assertEqual(payload["role"], "student")
        self.assertEqual(payload["roomId"], "room_a101")
        self.assertTrue(payload["emailVerified"])
        self.assertEqual(logged_in["id"], payload["id"])

    def _run_manage(self, *args: str) -> tuple[int, str, str]:
        stdout = io.StringIO()
        stderr = io.StringIO()
        with redirect_stdout(stdout), redirect_stderr(stderr):
            exit_code = manage_main(
                [
                    "--db-path",
                    str(self.db_path),
                    *args,
                ]
            )
        self.assertEqual(exit_code, 0, stderr.getvalue())
        return exit_code, stdout.getvalue(), stderr.getvalue()


if __name__ == "__main__":
    unittest.main()
