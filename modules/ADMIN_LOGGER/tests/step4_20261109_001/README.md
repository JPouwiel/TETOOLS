# ADMIN_LOGGER step 4 — corrected preparation, execution locked

Correction assignment: Issue #104, LOGGER-STEP4-REVIEW-20261109-001 / REGIE-LOGGER-TESTPREP-20261109-001. Existing module owner ADMIN_LOGGER-REGIE-20261104-01. Actual delegated implementer: Codex session a9edd3a9-d49a-4cb8-a102-868f3808e7bf. This implementer wrote the earlier review and **cannot provide the next independent re-review**. Historical PR106 review/evidence remain unchanged.

Second-herreview correction (10 November 2026): actual delegated executor is existing Codex thread 01a1c472-55b9-7281-882f-53425c5c8937. Earlier implementer identity above is historical; no new regie session ID is introduced. Independent PR108 FAIL is retained; RR01/RR02 source/documentation corrections require a new independent full-head review. [Remaining BLOCKED dependencies](blocked_dependencies.md) identify owners, decisions, evidence and technical prerequisites.

**TESTPACKAGE_CORRECTION_ONLY / STATIC_VERIFICATION_ONLY. G09 NOT_GRANTED. Every Oracle result NOT_EXECUTED. PR102 NOT MERGED; no release/RAC readiness.**

## Safety boundary

Every SQL entry in scripts/ runs `00_safety_gate.sql` before DML, locks, API calls, DDL, source includes or configuration substitution. That shared gate first disables substitution and raises -20909 with source-pinned NOT_GRANTED and a NULL approval reference. It does not reference ADMIN_LOGGER: first-reference initialization can commit autonomously. Stale DEFINE values, YES flags, a previous preflight, an edited private request or reconnect cannot grant execution. Missing includes encounter WHENEVER OSERROR EXIT; client behavior still requires later authorized verification. Do not strip guards or run snippets separately.

This is a safety stop for trusted, reviewed test source, not a substitute for Oracle privileges or cryptographic authorization. A principal able to edit scripts or submit arbitrary SQL can bypass client tooling; DBA isolation/privileges remain required. No execution-enabled artifact is supplied. A future GO needs a separate central environment/case/operation-specific decision and independently reviewed authorization artifact with literal identity/scope/reference pins. Changing a flag in env.template.sql never enables this revision.

`00_preflight.sql` additionally requires an entirely empty TETOOLS owner before installation. `00_post_install.sql` instead checks installed objects without demanding emptiness; it preserves the caller case/operation. All identity/principal/DB/PDB/CON_ID/instance/service values are rechecked against the actual connection and approval pins. Null/blank/UNVERIFIED/invalid numbers and missing run/client markers fail closed. Future consumers/observers need separately pinned principals; no broad owner authorization by inheritance.

## What is prepared

- [28 complete case records](cases.json), [casebook](casebook.md), [28 result rows](results_template.csv).
- [Exact manual procedures](procedures.md), [fixture designs and blocks](fixtures.md), [known dependencies/principals](privileges.md), [canonical risk trace](traceability.md), [full public declarations/defaults](api_inventory.json).
- Gated install, compile metadata, functional uniqueness/current-session assertions, 45 LOG overload behavioral checks, config/backup/restore checks, C01 two-sided transaction assertions, four-stage guard contention/release probes and identity/evidence capture.
- C02-C06 remain BLOCKED. Actual incident duplicate-PK, negative security/failover/performance/clear-scope and DBA restore remain explicitly blocked until their precise outstanding approvals and fixtures are supplied. Prepared core probes do not make an entire category PASS.

## Offline verification (no Oracle)

Run `python verify_static.py --repo <repository> --ref <exact-full-PR-head> --main <read-main-SHA> --require-material-match --out <new-static-report.json>` from this directory, then `python test_static_guards.py` and `python test_post_install.py`. The original nine source-unittest methods comprise two positive suites, six mutation rejections and one analytical prefixcheck; they are not nine negative Oracle executions. The eight new post-install methods inspect source and evaluate only a synthetic in-memory SQLite metadata model. No Oracle client/network/database connection is used. Do not connect simply to test the gate; negative SQL client tests also require authorization.

The verifier records scope, pins, unchanged source/frozen trees, include graph, case/contract/trace consistency, gate prefix and negative source-mutation tests. JSON Schema is separately reported NOT_EXECUTED when jsonschema is unavailable; the pre-existing relay ASSESSED mismatch is not repaired here. A static check does not prove PL/SQL compilation, SQL*Plus error routing or RAC behavior.

## Future order — only after new separate GO

1. DBA signs G01-G08 in environment.template.md, approval artifact pins all identities/allowed operations/cases and independent reviewer accepts it; central G09 must actually be granted first.
2. Create a fresh private evidence directory and fresh clean SQL client per fixture/transaction phase. Load a reviewed private request based on env.template.sql; passwords stay outside files/arguments.
3. Before each stage, record client version/source export hashes and actual connection. Preserve stdout/stderr externally from process start, including gate failures; capture exact nonzero exit and scan SP2/ORA/PLS against per-case allowlist. No automatic continuation.
4. 00_preflight -> 10_install -> 20; then only explicitly permitted tests. Fixture52 is **after** installation; no fixture/table can exist before the empty-owner check. 41 and42 save/restore config;51 performs all autonomous setup before the business INSERT.
5. Lock protocol61/62/63/64 requires live coordinated clients and external timing/lock observer. T07 requires three actual instances, not three connections routed to one node.
6. Check all 28 result rows, expected/actual, hashes, observer and recovery signatures. DBA recovery is independent;90 always refuses cleanup. No master script runs all tests.

SPOOL uses unique run/client/stage names and CREATE (not default REPLACE). Do not nest spools inadvertently; the operator's outer process capture records boundaries and statuses even when an inner script owns its spool. Never reuse a filename. SELECT/SHOW output alone is not acceptance.

[Central preparation](../../../../COMMUNICATION_RELAY/reviews/ADMIN_LOGGER_STEP4_ORACLE_TEST_PREPARATION_20261109.md), [LDR plan](../../docs/reports/ADMIN_LOGGER_LDR_TESTPLAN_20261109.md), [source manifest](../../src/20261109_501_DEV/REVISION_MANIFEST.md), [historical independent review](../../docs/reports/ADMIN_LOGGER_STEP4_INDEPENDENT_REVIEW_20261109.md).
