#!/usr/bin/env python3
"""Validate relay registries. Python 3 stdlib only."""
import json
import pathlib
import sys
from session_retention_review import validate_activity

ROOT = pathlib.Path(__file__).resolve().parents[1]
SESSION_STATES = {"REGISTERED", "ACTIVE", "BLOCKED", "COMPLETED", "CLOSED", "ARCHIVED"}
RETENTION = {"KEEP", "REVIEW", "ELIGIBLE_FOR_DELETION"}
CHANGE_STATES = {"PROPOSED", "APPROVED", "REJECTED", "SUPERSEDED", "CLOSED", "IMPLEMENTED"}
errors = []

def load(name):
    try:
        return json.loads((ROOT / name).read_text(encoding="utf-8"))
    except (OSError, ValueError) as exc:
        errors.append(f"{name}: {exc}")
        return {}

sessions = load("SESSION_REGISTRY.json").get("sessions", [])
changes = load("CHANGE_REGISTER.json").get("records", [])
if not isinstance(sessions, list) or not isinstance(changes, list):
    errors.append("Registries must contain arrays")
    sessions, changes = [], []
seen = set()
for item in sessions:
    sid = item.get("session_id")
    if not sid or sid in seen:
        errors.append(f"duplicate/missing session ID: {sid}")
    seen.add(sid)
    try:
        validate_activity(item)
    except ValueError as exc:
        errors.append(f"{sid}: {exc}")
    if item.get("status") not in SESSION_STATES:
        errors.append(f"{sid}: invalid status")
    if item.get("retention_status") not in RETENTION:
        errors.append(f"{sid}: invalid retention")
    if not item.get("source_reference") or not item.get("recorded_by"):
        errors.append(f"{sid}: missing source/recorder")
    if item.get("status") in {"CLOSED", "ARCHIVED"} and not item.get("closed_at"):
        errors.append(f"{sid}: missing closure timestamp")
    if item.get("retention_status") == "ELIGIBLE_FOR_DELETION" and (item.get("open_dependencies") or not item.get("deliverables")):
        errors.append(f"{sid}: deletion eligibility unsupported")
seen = set()
for item in changes:
    cid = item.get("change_id")
    if not cid or cid in seen:
        errors.append(f"duplicate/missing change ID: {cid}")
    seen.add(cid)
    if item.get("status") not in CHANGE_STATES and not (
        item.get("status") == "ASSESSED" and item.get("record_type") == "REVIEW"
    ):
        errors.append(f"{cid}: invalid change status")
    for field in ("source_reference", "origin_session", "recorded_by_session", "recorded_at"):
        if not item.get(field):
            errors.append(f"{cid}: missing {field}")
    if item.get("status") in {"APPROVED", "IMPLEMENTED"} and not (item.get("approved_by") or item.get("approval_actor")):
        errors.append(f"{cid}: missing approval provenance")
for name in ("PROJECT.md", "CURRENT_STATUS.md", "MODULE_REGISTRY.md", "RELAY_CONTRACT.md"):
    if not (ROOT / name).is_file():
        errors.append(f"missing {name}")
if errors:
    print("FAIL", *errors, sep="\n")
    sys.exit(1)
print(f"PASS: {len(sessions)} sessions; {len(changes)} changes; required files present")
