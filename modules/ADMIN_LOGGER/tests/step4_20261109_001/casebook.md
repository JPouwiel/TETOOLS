# Executable casebook — all database cases NOT_EXECUTED

**Scope:** `20261109_501_DEV`, Oracle 19c Enterprise. **No execution authorization.** For every case: record exact run ID, approved PDB/CON_ID, source SHA, script SHA, operator, UTC timestamps, expected/actual, evidence URI, PASS/FAIL, cleanup and reviewer in `results_template.csv`. A static source inspection is **not** an Oracle PASS. All environment values UNVERIFIED. If a case needs destructive injection or unavailable privileges, STOP, mark BLOCKED, seek DBA/central decision; do not patch the production package to simulate behavior.

**Modes:** SI = isolated single-instance disposable schema sufficient; RAC3 = three real RAC instances required; OFF = offline static. For every SQL script, load private approved configuration and capture `SPOOL` before running. Expected failures must be caught locally; any other ORA-/PLS-error is FAIL/STOP.

| ID | Mode | Requirement/risk | Objective PASS criterion | Executable procedure / evidence | Cleanup / stop |
|---|---|---|---|---|---|
| T01-01 | OFF | RAC-A-010/011 | 6 Git blobs match manifest; baseline TABLE unchanged; exact 2 authorized changes | `git ls-tree`, `git hash-object`; compare index text and comma | STOP on mismatch; no DB |
| T01-02 | OFF | LOG-OPEN-05 / API | SPEC and BODY Git blobs byte-identical to baseline; all public overloads/defaults enumerated | Diff original vs DEV; SPEC signatures and AUTHID | STOP on mismatch |
| T02-01 | SI | RAC-A-010/011 | fresh install 0 SQL errors, package SPEC/BODY VALID, 2 unique indexes, incident PK ENABLED | `00_preflight` then `10_install` + `20_T02_compile`; capture USER_ERRORS, USER_OBJECTS, USER_INDEXES, USER_CONSTRAINTS | DBA restore/teardown; STOP on any error |
| T02-02 | SI | LOG-OPEN-01 | compile warnings catalogued; no unexpected warning; dependencies resolvable | `ALTER SESSION SET PLSQL_WARNINGS='ENABLE:ALL'` only if DBA approved; `ALTER PACKAGE ... COMPILE` needs separate DDL GO; otherwise inspect USER_ERRORS/ALL_DEPENDENCIES | STOP if compile would change unauthorized objects |
| T03-01 | SI | RAC-A-010 | same positive (logsession_id, logbatch_id, log_lines) rejected by unique index; single-position allowed | `30_T03_functional.sql`; expected DUP_VAL_ON_INDEX, log marker `STEP4_T03` | ROLLBACK; STOP on unexpected accepted duplicate |
| T03-02 | SI | RAC-A-011 | incident PK exists, NOT NULL fields enforced; duplicate PK rejected | DBA-authorized valid incident fixture using actual session metadata; insert duplicate incident_id with explicit ID if GENERATED ALWAYS requires OVERRIDING SYSTEM VALUE (Oracle 19c syntax review before execution); capture ORA-00001 | ROLLBACK; no fake identity; BLOCKED until fixture reviewed |
| T03-03 | SI | LOG-OPEN-02 | session/config/guard row consistency after initialize, toggle and session_details | `30_T03_functional.sql` guard count; call `session_details`, query matching rows and config; validate one config per session | ROLLBACK only caller DML; autonomous rows may require authorized cleanup |
| T03-04 | SI | LOG-OPEN-03 | log to SCREEN/TABLE according to toggle settings, context filters, batch position | `toggle_logging`, `toggle_debug`, `toggle_batch`; query actual table and DBMS_OUTPUT after each | Save/restore configuration; STOP on unexpected target |
| T04-01 | SI | LOG-OPEN-05 | version/help and all LOG_* function/procedure VARCHAR2 overloads return documented behavior | `40_T04_regression.sql` plus one anonymous block per function; record return value and output | authorized session reset; STOP if critical error swallowed |
| T04-02 | SI | LOG-OPEN-05 | CLOB, BOOLEAN, DATE and FORCE variants callable with identical signatures/defaults; no overload ambiguity | generate explicit anonymous blocks for each SPEC declaration (see API inventory); compare baseline source; record outputs | session reset; no permanent fixture |
| T04-03 | SI | LOG-OPEN-02 | toggle_* and `session_details_revert('BACKUP'/'RESTORE')` behavior matches actual documented modes; clear_* respects scope | **DO NOT GUESS mode values**: inspect SPEC/BODY, approve exact mode tokens and fixture first; invoke one at a time | DBA-approved disposable session only; STOP if mode unknown |
| T05-01 | SI | RAC-A-012 | owner AUTHID DEFINER compiles with direct grants; consumer EXECUTE works, negative principal denied | `50_T05_security.sql`, DBA grant inventory; positive/negative principals | DBA revoke test-only grants; STOP on unexpected access |
| T05-02 | SI | C01 | caller business INSERT rolled back, autonomous permitted diagnostic persists | create separate DBA-approved business fixture; SAVEPOINT/INSERT; call LOG_ERROR; ROLLBACK; compare business and log/incident by unique marker | DBA fixture cleanup; STOP if caller commit occurs |
| T05-03 | SI | C02 | induced error between session/config mutations leaves no partial committed state; guard released | DBA-approved reversible fault-injection strategy; snapshot rows, inject controlled failure without package edits, assert both tables + guard after rollback | **BLOCKED** until safe injection mechanism approved |
| T05-04 | SI | C03 | incident/exception survives management rollback; diagnostic fallback bounded on its own failure | DBA-approved isolated failure fixture; verify incident ID and caller error/backtrace | **BLOCKED** until injection and cleanup approved |
| T05-05 | SI | C04 | registration vs session-wide vs fallback errors produce distinct observable classification | run three separately authorized failure scenarios, capture DBMS_OUTPUT, SQLCODE, incident rows | **BLOCKED** pending exact reversible fixtures |
| T05-06 | SI | C05 | LOG_RUNTIME best-effort incidental failure; LOG_INFO/WARNING internal handling; LOG_ERROR/DEBUG/FORCE mandatory feedback; both function/procedure | exercise matrix across fault classes; assert output, SQLCODE, return value and incident | **BLOCKED** pending fault matrix and approved injection |
| T05-07 | SI | C06 | logging + diagnostic failure terminates without recursion or uncontrolled stack; bounded duration/error | approved fault simulation, external watchdog/timeout, capture error/backtrace and resource usage | **BLOCKED** until DBA-safe injection/watchdog |
| T06-01 | SI | RAC-A-003/004 | guard `FOR UPDATE WAIT 5` contends predictably, no deadlock; lock released on rollback | two SQL clients, A locks guard, B waits; capture elapsed, ORA-30006 or success as per sequence | rollback both; STOP on deadlock or blocked cleanup |
| T06-02 | SI | RAC-A-005/006 | two writers cannot commit duplicate positive log position | parallel INSERT same tuple, one commit, other duplicate rejection; repeat 10+ times | ROLLBACK both if possible; marker cleanup |
| T06-03 | SI | RAC-A-007/009 | p50/p95 latency, redo/waits and throughput captured against approved baseline; no unapproved regression | repeat 30+ controlled runs, DBA-approved metric views and workload; threshold from owner **UNVERIFIED** | stop at resource cap; no PASS without baseline |
| T07-01 | RAC3 | RAC-A-001/002 | all 3 distinct INST_ID, same authorized PDB/CON_ID, services map correct | `70_T07_rac.sql` on each node; DBA `GV$INSTANCE/GV$SESSION` | disconnect; STOP if fewer than 3 nodes |
| T07-02 | RAC3 | RAC-A-001/012 | remote active session is never incorrectly purged; privilege-denied visibility fails safe | open live sessions on nodes 1–3, run authorized cleanup on other node; verify per-node liveness and row survival | **BLOCKED** until purge-scope/safety approval |
| T07-03 | RAC3 | RAC-A-002/008 | reconnect/failover retains correct identity provenance; no cross-instance collision | three service clients, controlled disconnect/reconnect/failover with DBA; compare SID/SERIAL#/AUDSID/INST_ID/CON_ID | **BLOCKED** until DBA approved failover plan |
| T07-04 | RAC3 | RAC-A-006/011 | global logposition uniqueness and incident consistency under cross-node writers | parallel three-node same key insert; verify one commit and two rejections; incident constraints valid | cleanup by DBA; STOP on inconsistent outcomes |
| T08-01 | SI | LOG-OPEN-04 | all evidence linked, environment/approval/DBA identity and source pinned; no missing test records | `80_T08_evidence.sql`; results_template.csv, per-case spools, approvals | no PASS until reviewer signs |
| T08-02 | SI | LOG-OPEN-04 | approved snapshot/restore or disposable teardown proven and reconciled | DBA executes independent restore rehearsal and signs evidence | **BLOCKED** pending DBA; no implicit DDL rollback |
| T08-03 | RAC3 | RAC-A-001..012 | 8 categories + C01–C06 reviewed; RAC three-node PASS; all P1 resolved/accepted | independent reviewer, DBA and TETOOLS__REGIE accept evidence | no RAC_READY without actual tests and release decision |

## Detailed C01–C06 contract

**C01 caller rollback:** baseline row count B; insert one uniquely tagged business row, call LOG_ERROR with same tag; `ROLLBACK`; expected business count B, diagnostic row persisted only if permitted autonomous transaction is documented; record exact logsession_id and tag. Failure if caller DML committed.

**C02 atomic management:** capture session/config snapshots; inject error at exact approved point between their DML operations, ensure no partial committed row, guard lock released; if no safe injection exists mark BLOCKED, not PASS.

**C03 durable diagnostics:** after management rollback verify independently persisted incident/exception and backtrace; induce diagnostic failure only through approved fixture; ensure bounded fallback. Evidence: transaction snapshots and incident IDs.

**C04 classification:** three scenarios (incidental log insert, session state invalidation, fallback failure); capture SQLCODE, user-visible message, exception trace, classification and severity; compare to central F03 rules. Unavailable fixtures -> BLOCKED.

**C05 LOG_* contract:** all LOG_RUNTIME/INFO/WARNING/ERROR/DEBUG and FORCE procedure/function variants, across normal, incidental and session-wide failure, assert returned value, exception propagation, DBMS_OUTPUT and persisted diagnostics. No untested overload can be marked PASS.

**C06 recursion bound:** force logger+diagnostic failure under DBA-approved watchdog, verify one bounded failure, no unbounded recursion, no resource exhaustion; do not deliberately crash shared RAC instances.

## Pass/fail, cleanup and evidence

PASS only on actual matched observations and signed expected outcomes. FAIL on unexpected ORA-/PLS-error, unintended commit, duplicate accepted, remote live session purged, missing error feedback, or data escape. BLOCKED if environment/fixture/privilege unavailable. NOT_EXECUTED for all cases until separate Oracle GO. A `WHENEVER SQLERROR EXIT` does not catch every SQL*Plus command or `SHOW ERRORS` problem: T02 uses explicit USER_ERRORS assertions. SQL*Plus `@@` resolution and spool locations must be verified by operator. All destructive scripts are deliberately non-operational until DBA authorization.

**Risk:** current package may fail several F03 contracts; these are acceptance tests, not claims of conformity. Changes to production code or test methodology beyond approved scope require separate decision.
