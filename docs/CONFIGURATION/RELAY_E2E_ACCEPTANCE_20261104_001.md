# TETOOLS COMMUNICATION_RELAY — End-to-end acceptance protocol
**ID:** RELAY-E2E-20261104-001 | **Revision:** 001 | **State:** PROPOSED / NOT_EXECUTED | **Platform:** Oracle Database 19c Enterprise (no database execution required)

## 1. Purpose and limits
Verify that a new module REGIE, central TETOOLS__REGIE, Work, and local Codex can read the same approved GitHub baseline, publish traceable records, receive and process a suite-impact signal, close and resume sessions, and identify blocked/unavailable paths. A successful configuration test is not evidence of successful end-to-end operation. ChatGPT conversations do not synchronize automatically. Never write test credentials, tokens, or private chat content to Git.

## 2. Roles and locations
- **OWNER:** User; authorizes test actions, merges and final acceptance.
- **CENTRAL:** TETOOLS__REGIE ChatGPT session; checks governance, triage and acceptance.
- **MODULE:** Fresh ADMIN_LOGGER__REGIE ChatGPT session; originates signal (test only).
- **WORK:** New Work session; reads assignment, writes test artifact if available.
- **CODEX:** New Codex session; local checkout with origin JPouwiel/TETOOLS.
- **REVIEWER:** OWNER or separately authorized reviewer; validates evidence on GitHub main.
- **LOCATION:** GitHub JPouwiel/TETOOLS, COMMUNICATION_RELAY/, and docs/CONFIGURATION/; local checkout; ChatGPT project and Library where available.

## 3. Preconditions and safety
1. OWNER confirms the test window, selected module, permissions and whether test PRs may merge. **Current authorization:** PRs and merges permitted for this test protocol; operational test data should be approved at execution.
2. CENTRAL reads START_HERE_TETOOLS_REGIE.md, RELAY_CONTRACT.md, CURRENT_STATUS.md, MODULE_REGISTRY.md, SESSION_REGISTRY.json, CHANGE_REGISTER.json and relevant module registers on main. Record baseline commit SHA.
3. CODEX checks `git status --porcelain`, branch, remote, local/remote divergence and `AGENTS.md`. No uncommitted unrelated changes may be overwritten.
4. Test IDs must be unique; use prefix `E2E-20261104-<run-id>` and clearly label records TEST_ONLY. No frozen releases, production data or source code changes.
5. Every write uses a new branch, PR, approved merge, and independent readback on main. PR approval/merge must comply with actual branch protections. Never bypass required reviews.
6. Use explicit timeouts: each PR/write stage is BLOCKED after 30 minutes without access or required approval; human response stages are BLOCKED after one working day. Record actual elapsed times, not assumed times.
7. Before test, save a list of test record IDs and artifact paths; never delete historic register entries. Rollback by append-only superseding/closing entries, not history rewrite.

## 4. Execution cases
Each case is completed only with status PASS, FAIL, BLOCKED or NOT_EXECUTED, evidence URL + commit SHA, actor, date/time and reviewer. Mark N/A only if approved by OWNER with reason; mandatory cases cannot be N/A.

### KT-01 — Baseline and access
**Who:** CENTRAL + CODEX. **Where:** GitHub main, ChatGPT, local Git.
**Action:** Read start protocol, contract, registers and AGENTS.md; compare local HEAD with fetched origin/main; record access modes separately (GitHub connector, local Git read/write). Confirm source identities and permissions without exposing secrets.
**Expected:** Same current baseline; mandatory files accessible; discrepancies logged. **Evidence:** SHA, file paths, command results. **Failure:** missing contract, inconsistent baseline or unreported permission failure.

### KT-02 — Module session registration
**Who:** MODULE, reviewed by REVIEWER. **Where:** fresh ADMIN_LOGGER__REGIE chat + GitHub.
**Action:** Create unique session ID per contract; register TEST_ONLY ACTIVE entry through branch/PR/merge; read back on main. Use actual thread ID if available, otherwise marked local UUID.
**Expected:** Complete schema fields, unique ID, provenance and verified merge. **Evidence:** PR, merge SHA, main registry entry. **Failure:** assumed registration or missing mandatory fields.

### KT-03 — Suite-impact signal
**Who:** MODULE. **Where:** module chat + GitHub CHANGE_REGISTER.json.
**Action:** Publish a harmless hypothetical signal about RAC instance/session correlation; explicitly mark HYPOTHESIS and TEST_ONLY, source session, affected modules UNKNOWN, status PROPOSED; link module record. Do not present as real defect.
**Expected:** Unique SUITE_IMPACT_SIGNAL with required fields, preserved module link and verified main readback. **Evidence:** PR, SHA, record ID.

### KT-04 — Cross-session central triage
**Who:** CENTRAL in a separate new chat. **Where:** GitHub main + TETOOLS__REGIE.
**Action:** Independently discover the signal without copying its content in the prompt; record assessment INVESTIGATE or MODULE_ONLY as a new traceable disposition, do not erase original record; report originating module and evidence.
**Expected:** Signal is discoverable, attributed and disposition recorded with link. **Evidence:** PR, SHA, original and disposition IDs. **Failure:** only discovers signal after manual paste of its contents.

### KT-05 — Work handover
**Who:** CENTRAL assigns; WORK executes. **Where:** ChatGPT Work + GitHub.
**Action:** Publish a bounded, non-code documentation task referencing the signal ID. Work reads main baseline, creates a TEST_ONLY handover note via PR if access permits, and records limitations.
**Expected:** Independent Work read, traceable artifact, review and verified publication. **Evidence:** Work session reference, PR, SHA. **Failure:** claimed background completion without verifiable artifact.

### KT-06 — Codex implementation path
**Who:** CODEX + REVIEWER. **Where:** local TETOOLS checkout + GitHub.
**Action:** Fetch origin; create separate test branch; add only a non-executable TEST_ONLY markdown verification note; run `git diff --check`, check Git status and file diff; push, PR, review, merge and fetch/readback. Do not touch Oracle code or releases.
**Expected:** Correct branch isolation, clean diff, successful checks and verified main artifact. **Evidence:** commands, PR, SHA, final diff. **Failure:** unapproved changes or missing readback.

### KT-07 — Concurrent changes
**Who:** Two authorized test sessions + REVIEWER. **Where:** GitHub relay register.
**Action:** Create two branches from same base and propose independent test entries in the same register. Merge first; update/rebase second without losing first; validate JSON and uniqueness before second merge. If conflicts arise, resolve visibly through review.
**Expected:** Both records survive with distinct IDs and valid schema; no lost update. **Evidence:** two PRs, merge SHAs, validation output, main readback.

### KT-08 — Closure and resume
**Who:** MODULE and CENTRAL; fresh third session checks. **Where:** ChatGPT + GitHub.
**Action:** MODULE closes test session with CLOSED only after deliverables, dependencies and closed_at; CENTRAL records disposition/handover. A fresh session reads main and reconstructs status without chat transcript.
**Expected:** Provenance, closed lifecycle, open dependencies and next actions recoverable. **Evidence:** PRs, SHAs, reconstructed status. **Failure:** missing provenance or presumed automatic chat synchronization.

### KT-09 — Document copies and consistency
**Who:** OWNER + CENTRAL. **Where:** GitHub docs, local checkout, ChatGPT Library.
**Action:** Save one harmless versioned test document in GitHub; fetch locally; place a copy in Library if connector/access permits. Record SHA-256 for identical bytes and distinguish copies from source of truth. Modify only the GitHub test document in a later revision; verify local/Library copies do NOT silently update and document refresh procedure.
**Expected:** GitHub authoritative version identified; hashes and version labels recorded; unavailable Library write marked BLOCKED, not PASS. **Evidence:** Git commit, local hash, Library item identifier or explicit limitation.

### KT-10 — Failure-path and permissions
**Who:** CENTRAL + CODEX, reviewed by OWNER. **Where:** isolated test branch, local checkout.
**Action:** Simulate lack of GitHub write access by using a read-only instruction/test scenario (do not revoke live credentials). Attempt no unauthorized write; record NOT_REGISTERED/BLOCKED and a pending payload. Check that no success is claimed. Verify conflict and missing-source handling without modifying production settings.
**Expected:** Safe failure reporting and recoverable pending action. **Evidence:** transcript reference, pending record, no unauthorized commit.

### KT-11 — Final acceptance
**Who:** OWNER approves; CENTRAL prepares report. **Where:** TETOOLS__REGIE + GitHub.
**Action:** Verify all KT-01..KT-10 evidence independently against main; verify no open critical FAIL/BLOCKED; record final decision APPROVED or REJECTED/DEFERRED via PR; preserve evidence index and open points.
**Expected:** Explicit OWNER approval, linked test evidence, verified merge and no claims beyond tested scope.

## 5. Acceptance gate
**FULLY_ACCEPTED** only when KT-01..KT-10 PASS, all mandatory evidence is linked and read back on main, OWNER approves KT-11, no unresolved critical defects or unauthorized changes exist, and the decision itself is published and verified. **CONDITIONALLY_ACCEPTED** requires explicit OWNER-approved exclusions and may not be described as fully implemented. Otherwise **NOT_ACCEPTED** or **DEFERRED**.

## 6. Per-case execution record
```
case_id:
run_id:
actor:
location:
start_time:
end_time:
status: NOT_EXECUTED | PASS | FAIL | BLOCKED
observed_result:
evidence_urls:
commit_sha:
reviewed_by:
deviation_or_open_point:
```
Do not treat a UI checkbox as audit evidence. The interactive HTML checklist is a local execution aid; durable evidence and formal decisions reside in GitHub.

## 7. Scope of approval
This document authorizes no Oracle DDL/DML, production configuration change, secret handling or alteration of frozen module releases. Test implementation must remain confined to new test-only documentation/relay records and follow branch protections. Any change to the relay schema or governance contract requires separate explicit approval.

## 8. References
- [Start protocol](../../COMMUNICATION_RELAY/START_HERE_TETOOLS_REGIE.md)
- [Relay contract](../../COMMUNICATION_RELAY/RELAY_CONTRACT.md)
- [Current status](../../COMMUNICATION_RELAY/CURRENT_STATUS.md)
- [Codex instructions](../../AGENTS.md)
