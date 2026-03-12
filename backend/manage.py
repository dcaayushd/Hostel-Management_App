from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

from backend.repository import BackendError, HostelDataStore


def _default_db_path() -> str:
    return str(Path(__file__).resolve().parent / "data" / "hostel.db")


def _store(args: argparse.Namespace) -> HostelDataStore:
    return HostelDataStore(args.db_path, demo_mode=False)


def _print_json(payload: Any) -> None:
    print(json.dumps(payload, indent=2))


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Operational helpers for the Hostel Hub backend.",
    )
    parser.add_argument(
        "--db-path",
        default=_default_db_path(),
        help="SQLite database path. Defaults to backend/data/hostel.db",
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    bootstrap_admin = subparsers.add_parser(
        "bootstrap-admin",
        help="Create the first admin account in the database.",
    )
    _add_person_args(bootstrap_admin)

    create_block = subparsers.add_parser(
        "create-block",
        help="Create a hostel block.",
    )
    create_block.add_argument("--code", required=True)
    create_block.add_argument("--name", required=True)
    create_block.add_argument("--description")

    create_room = subparsers.add_parser(
        "create-room",
        help="Create a room inside an existing block.",
    )
    create_room.add_argument("--block", required=True)
    create_room.add_argument("--number", required=True)
    create_room.add_argument("--capacity", required=True, type=int)
    create_room.add_argument("--room-type", required=True)

    create_user = subparsers.add_parser(
        "create-user",
        help="Create a student, guest, staff, or admin account.",
    )
    _add_person_args(create_user)
    create_user.add_argument(
        "--role",
        required=True,
        choices=("student", "guest", "staff", "admin"),
    )
    create_user.add_argument("--room-id")
    create_user.add_argument("--job-title")
    create_user.add_argument(
        "--email-verified",
        action="store_true",
        help="Mark the account as already email-verified.",
    )

    list_users = subparsers.add_parser(
        "list-users",
        help="List users currently stored in the database.",
    )
    list_users.add_argument(
        "--role",
        choices=("student", "guest", "staff", "admin"),
    )

    subparsers.add_parser(
        "list-rooms",
        help="List rooms currently stored in the database.",
    )

    return parser


def _add_person_args(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--username", required=True)
    parser.add_argument("--first-name", required=True)
    parser.add_argument("--last-name", required=True)
    parser.add_argument("--email", required=True)
    parser.add_argument("--password", required=True)
    parser.add_argument("--phone-number", required=True)


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    try:
        if args.command == "bootstrap-admin":
            payload = _store(args).bootstrap_admin(
                username=args.username,
                first_name=args.first_name,
                last_name=args.last_name,
                email=args.email,
                password=args.password,
                phone_number=args.phone_number,
            )
        elif args.command == "create-block":
            payload = _store(args).create_block(
                code=args.code,
                name=args.name,
                description=args.description,
            )
        elif args.command == "create-room":
            payload = _store(args).create_room(
                block=args.block,
                number=args.number,
                capacity=args.capacity,
                room_type=args.room_type,
            )
        elif args.command == "create-user":
            payload = _store(args).create_user_account(
                role=args.role,
                username=args.username,
                first_name=args.first_name,
                last_name=args.last_name,
                email=args.email,
                password=args.password,
                phone_number=args.phone_number,
                room_id=args.room_id,
                job_title=args.job_title,
                email_verified=args.email_verified,
            )
        elif args.command == "list-users":
            payload = _store(args).list_users(role=args.role)
        elif args.command == "list-rooms":
            payload = _store(args).list_rooms()
        else:
            parser.error("Unknown command.")
            return 2
    except BackendError as error:
        print(error.message, file=sys.stderr)
        return 1

    _print_json(payload)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
