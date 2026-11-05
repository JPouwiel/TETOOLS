#!/usr/bin/env python3
"""Read-only TETOOLS session retention inventory. Python 3.8+, stdlib only."""
import argparse
import datetime as dt
import json
from pathlib import Path

VALID_RETENTION = {"KEEP", "REVIEW", "ELIGIBLE_FOR_DELETION"}
VALID_STATUS = {"REGISTERED", "ACTIVE", "BLOCKED", "COMPLETED", "CLOSED", "ARCHIVED"}

def validate_activity(session):
    """Validate optional declared work; never infer presence or authority."""
    activity = session.get("current_activity")
    if activity is None:
        return
    if not isinstance(activity, dict) or set(activity) != {"task_reference", "summary", "state"}:
        raise ValueError("current_activity requires exactly task_reference, summary, state")
    for field in ("task_reference", "summary"):
        if not isinstance(activity[field], str) or not activity[field].strip():
            raise ValueError("current_activity requires non-empty " + field)
    if activity["state"] not in ("WORKING", "WAITING", "BLOCKED"):
        raise ValueError("Invalid current_activity state")
    if session.get("status") not in ("REGISTERED", "ACTIVE", "BLOCKED"):
        raise ValueError("Completed/closed/archived session must clear current_activity")
    if session.get("retention_status") == "ELIGIBLE_FOR_DELETION":
        raise ValueError("Current activity prevents deletion eligibility")
    last = session.get("last_confirmed_at")
    try:
        dt.date.fromisoformat(last[:10])
    except (ValueError, TypeError):
        raise ValueError("Current activity requires valid last_confirmed_at")
    if not session.get("recorded_by"):
        raise ValueError("Current activity requires recorded_by")

def assess(registry, as_of):
    if registry.get("project") != "PLSQL_TETOOLS" or not isinstance(registry.get("sessions"), list):
        raise ValueError("Expected PLSQL_TETOOLS SESSION_REGISTRY with sessions list")
    seen = set()
    rows = []
    for s in registry["sessions"]:
        sid = s.get("session_id")
        if not isinstance(sid, str) or not sid or sid in seen:
            raise ValueError("Missing or duplicate session_id")
        seen.add(sid)
        status, retention = s.get("status"), s.get("retention_status")
        if status not in VALID_STATUS or retention not in VALID_RETENTION:
            raise ValueError("Invalid status or retention_status for " + sid)
        dependencies = s.get("open_dependencies", [])
        deliverables = s.get("deliverables", [])
        if not isinstance(dependencies, list) or not isinstance(deliverables, list):
            raise ValueError("Expected dependency/deliverable arrays for " + sid)
        validate_activity(s)
        activity = s.get("current_activity")
        reasons = []
        if activity:
            reasons.append("Declared current activity; retain pending work review")
        if dependencies:
            reasons.append("Open dependencies: " + str(len(dependencies)))
        if status in ("ACTIVE", "REGISTERED", "BLOCKED"):
            reasons.append("Session lifecycle not completed")
        if not s.get("source_reference"):
            reasons.append("Source reference missing")
        if not deliverables:
            reasons.append("No recorded deliverables")
        if status == "COMPLETED" and not s.get("closed_at"):
            reasons.append("Work completed, chat closure not evidenced")
        last = s.get("last_confirmed_at")
        days = None
        if last:
            try:
                days = (as_of - dt.date.fromisoformat(last[:10])).days
            except (ValueError, TypeError):
                reasons.append("Invalid last_confirmed_at")
        else:
            reasons.append("No last confirmation")
        if days is not None and days > 30:
            reasons.append("Last confirmation older than 30 days (review hint only)")
        if activity:
            recommendation = "KEEP"
        elif retention == "KEEP":
            recommendation = "KEEP"
            reasons.append("Explicit retention KEEP")
        elif reasons:
            recommendation = "REVIEW"
        else:
            # A register entry alone never proves that all unique chat context is preserved.
            recommendation = "REVIEW"
            reasons.append("Independent preservation/dependency verification required")
        rows.append({"session_id": sid, "module": s.get("module") or "SUITE",
                     "role": s.get("role") or "UNKNOWN", "status": status,
                     "retention_status": retention, "last_confirmed_at": last,
                     "days_since_confirmation": days, "recommendation": recommendation,
                     "reasons": reasons, "current_activity": activity})
    return rows

def render(rows, as_of):
    lines = ["# TETOOLS — Session retention inventory", "",
             "Generated for: " + as_of.isoformat(), "",
             "**Scope:** registered sessions only. Read-only advisory; no deletion or archive action.",
             "**Activity:** last manual declaration, not live chat presence. No declared task does not mean inactivity.",
             "**Evidence:** registry metadata only; no chat transcript or independent context preservation check.",
             "**Policy:** no session is automatically eligible for deletion; age is a review hint, not proof.",
             "", "| Session | Module | Lifecycle | Retention | Advice | Declared activity | Confirmed |",
             "|---|---|---|---|---|---|---|"]
    def cell(value):
        return str(value).replace("|", "\\|").replace("\r", " ").replace("\n", " ")
    for r in rows:
        activity = r.get("current_activity")
        declared = (activity["state"] + ": " + activity["summary"] + " (" +
                    activity["task_reference"] + ")") if activity else "No declared task"
        lines.append("| `" + r["session_id"].replace("|", "\\|") + "` | " +
                     r["module"] + " | " + r["status"] + " | " +
                     r["retention_status"] + " | " + r["recommendation"] + " | " +
                     cell(declared) + " | " + cell(r["last_confirmed_at"] or "UNKNOWN") + " |")
    lines += ["", "## Reasons and next checks", ""]
    for r in rows:
        lines.append("### " + r["session_id"])
        lines.append("- " + "; ".join(r["reasons"]))
    lines += ["", "## Before any cleanup", "",
              "1. Confirm actual chat identity and whether the chat still exists.",
              "2. Check unique decisions, files, messages and dependencies outside the registry.",
              "3. Preserve required information in canonical GitHub records and verify links.",
              "4. Obtain explicit owner authorization for each proposed deletion.",
              "5. Perform chat deletion separately using supported ChatGPT controls.",
              "6. Record evidence of actual deletion; never equate ARCHIVED with deletion.", ""]
    return "\n".join(lines)

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--registry", default="COMMUNICATION_RELAY/SESSION_REGISTRY.json")
    p.add_argument("--as-of", default=dt.date.today().isoformat(), help="YYYY-MM-DD")
    p.add_argument("--output", default=None, help="Markdown report file; stdout if omitted")
    a = p.parse_args()
    date = dt.date.fromisoformat(a.as_of)
    rows = assess(json.loads(Path(a.registry).read_text(encoding="utf-8")), date)
    report = render(rows, date)
    if a.output:
        Path(a.output).write_text(report, encoding="utf-8")
    else:
        print(report)

if __name__ == "__main__":
    main()
