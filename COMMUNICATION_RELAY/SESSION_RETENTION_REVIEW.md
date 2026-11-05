# Session retention review — Option A (approved 2026-11-04)

**Purpose:** reduce session proliferation by producing a reproducible, read-only inventory and evidence-based cleanup review. This is operational functionality, not merely a proposed schema.

## Run

From the repository root, with Python 3.8 or newer:

```sh
python3 COMMUNICATION_RELAY/tools/session_retention_review.py --as-of 2026-11-04 --output session-retention-review.md
```

No Oracle connection, third-party dependency, GitHub token, or ChatGPT account access is required to run against a local checkout. Output is a Markdown table and individual reasons/checks. The command does **not** modify the registry or perform any cleanup.

## Rules (initial conservative implementation)

- Inventory includes **only sessions registered** in `SESSION_REGISTRY.json`; it cannot discover unregistered chats.
- `KEEP` remains KEEP. Other entries receive REVIEW pending independent preservation and dependency checks.
- Open dependencies, missing source/deliverables, non-completed lifecycle and stale confirmation are shown as review reasons.
- 30 days since last confirmation is a **review hint only**, never an inactivity or deletion determination.
- A COMPLETED work record does not establish that the ChatGPT conversation has ended.
- No `ELIGIBLE_FOR_DELETION` is generated automatically. A register value of that name is not evidence of a completed deletion.
- Actual chat existence, unique context, open external dependencies and preservation cannot be verified solely from registry JSON.
- Any future eligibility decision requires evidence and owner authorization; deletion must be performed separately using supported ChatGPT controls, followed by verification.

## Acceptance checks

1. Script accepts the current schema_version 1 registry without modifying it.
2. It lists each unique session and its lifecycle, retention status and reasons.
3. Duplicate IDs and invalid status values fail loudly.
4. No automatic deletion candidate or destructive action is emitted.
5. Report is reproducible for a specified `--as-of` date.
6. Absence of recent confirmation never implies the chat is inactive or safe to delete.

## Follow-up limitations

- Add a verified chat identity mapping only if a supported source is available; never fabricate chat IDs.
- Add explicit evidence fields / verification workflow before considering a stronger eligibility classification.
- The actual ChatGPT deletion and verification process remains a separate manual action.
- `current_activity` schema and task lifecycle are still under Issue #23 and **not** implemented here.

**Sources:** `RELAY_CONTRACT.md`, `SESSION_REGISTRY.json`, Issue #23, and the owner approval of Option A in TETOOLS__REGIE on 2026-11-04 (exact chat URL unavailable).

## Uitbreiding current_activity (2026-11-05)

Issue #23 voegt optionele activiteit toe volgens RELAY_CONTRACT.md en CURRENT_ACTIVITY.md.
De tabel toont de laatst verklaarde taak, taakstatus, verwijzing en bestaande bevestigingsdatum.
Geen verklaarde taak betekent geen uitspraak over chatinactiviteit. Een taak geeft conservatief
KEEP, ook bij retention REVIEW. ELIGIBLE_FOR_DELETION samen met een taak faalt validatie.
Leeftijd wist niets; de bestaande context-/afhankelijkheidscontrole blijft verplicht.
De eerdere passage dat current_activity niet is geimplementeerd beschrijft de baseline van 2026-11-04;
deze uitbreiding vervangt die actuele beperking, niet het historische testverslag.
