# TETOOLS — handmatige overdracht tussen sessies
**Status:** APPROVED by project owner, 2026-11-04. **Scope:** All TETOOLS REGIE, Work and Codex sessions. **Transport:** one copy/paste by owner; no automation.

## Contract
1. **Sender** creates a GitHub Issue in `JPouwiel/TETOOLS` for each actionable cross-session request. Use a unique `RELAY-HANDOFF-YYYYMMDD-NNN` ID. This Issue is a *work item*, not a second decision register. Link the existing `CHANGE_REGISTER.json` signal or decision when applicable; do not duplicate formal decisions.
2. **Sender** fills all fields below and verifies that the Issue is accessible. Sender then provides the owner **one complete, copy-ready message** with no placeholders. The owner only copies it to the receiving session. No summary or interpretation is required.
3. **Receiver** reads the Issue, `START_HERE_TETOOLS_REGIE.md`, `RELAY_CONTRACT.md`, `CURRENT_STATUS.md`, and relevant module sources from GitHub. Receiver checks scope and authority; acknowledges in the Issue with session ID and evidence. If GitHub access fails, receiver reports BLOCKED; do not infer the request from the message alone.
4. **Receiver** executes within authorized scope. Content decisions and suite-impact dispositions remain in the canonical relay/module registers, via branch, PR, merge and readback. Link resulting PR/commit in the Issue. Do not claim completion before verification.
5. **Receiver** closes the Issue only when outcome, evidence, remaining dependencies and any required handover are recorded. Otherwise keep open and label status in the Issue body/comment (e.g. BLOCKED, WAITING_APPROVAL); do not confuse Issue closure with session closure.
6. **Approval boundary:** Owner involvement is required only for changes explicitly reserved to owner, scope expansion, sensitive permissions, production/destructive actions, or an unresolved governance conflict. Do not interpret transport as owner approval.
7. **Failure path:** If Issue creation is unavailable, sender provides a complete copy-ready message with an explicitly marked `ISSUE_NOT_CREATED` status and the full request text. Receiver may create the Issue after checking authorization. Never invent URLs or claim registration.
8. **No hooks, GitHub Actions, autonomous agents or automatic chat activation** are part of this agreement. An inactive session does not receive the message until the owner pastes it.

## Issue title
`[RELAY][<SOURCE> -> <TARGET>] <SUBJECT> | <HANDOFF_ID>`

## Issue body template
```markdown
HANDOFF_ID:
STATUS: OPEN
PROJECT: PLSQL_TETOOLS
SENDER_SESSION:
RECEIVER_SESSION_ROLE:
MODULE:
REQUEST_TYPE: REVIEW | DECISION | IMPLEMENTATION | INFORMATION
SUBJECT:
ACTION_REQUIRED:
BACKGROUND_AND_FACTS:
ASSUMPTIONS_AND_UNVERIFIED:
SOURCE_REFERENCES:
RELATED_CHANGE_IDS:
SCOPE_AND_RESTRICTIONS:
AUTHORITY_AND_APPROVAL_REQUIRED:
EXPECTED_DELIVERABLE:
ACCEPTANCE_CRITERIA:
DEPENDENCIES:
PRIORITY:
CREATED_AT:
ACKNOWLEDGED_BY:
RESULT_AND_EVIDENCE:
OPEN_POINTS:
```

## Required copy-ready message (sender supplies filled values)
```text
TETOOLS COMMUNICATION_RELAY — HANDOFF
To: <receiving session role>
From: <sender session>
Request ID: <HANDOFF_ID>
GitHub Issue: <verified URL>
Action: Read the full Issue and linked sources independently on GitHub.
Follow START_HERE_TETOOLS_REGIE.md and RELAY_CONTRACT.md.
Handle within your assigned authority; record the result and evidence in the Issue
and in the canonical registers when a formal decision/change is involved.
Report BLOCKED if source or permissions are unavailable.
No approval by the user is implied by forwarding this message.
```

## Readability and traceability
- Sender must use a **single copyable text block**; do not make the owner assemble separate references.
- One Issue per actionable request; related PRs and formal change IDs remain linked.
- Unique IDs, verifiable URLs, explicit owner, acceptance criteria, evidence and status are mandatory.
- Keep issue discussion focused; never include secrets or private transcript contents.
- GitHub Issues are a task queue, not the source of truth for module code, decisions or release status.

## Source
Approved in TETOOLS__REGIE conversation, 2026-11-04; exact chat URL unavailable (UNVERIFIED).
