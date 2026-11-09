# Traceability and risk ownership — PREPARATION_ONLY

The risk-to-test mapping below is a **test-design proposal**, not a claim that the risk is fixed or that its original wording has been independently revalidated. Refer to [RAC report A](../../docs/reports/20261105__PLSQL__TETOOLS_ADMIN_LOGGER__RAC_analyse_A_20261015_500_STE_033.html) and [central LDR plan](../../docs/reports/ADMIN_LOGGER_LDR_TESTPLAN_20261109.md) for authoritative finding descriptions. Only RAC-A-010/011 are source-fixed by PR97; all Oracle outcomes NOT_EXECUTED.

| Finding | Proposed test IDs | Acceptance focus | Owner | Priority / state |
|---|---|---|---|---|
| RAC-A-001 | T07-01,T07-02,T08-03 | remote live session must not be purged | ADMIN_LOGGER + DBA | P1 OPEN |
| RAC-A-002 | T07-01,T07-03,T08-03 | INST_ID/CON_ID provenance and reconnect identity | ADMIN_LOGGER + DBA | P1 OPEN |
| RAC-A-003 | T06-01,T06-03 | guard lock and concurrent progress | ADMIN_LOGGER | original severity see report A; OPEN |
| RAC-A-004 | T06-01,T06-02 | lock timeout and session repair | ADMIN_LOGGER | OPEN |
| RAC-A-005 | T06-02,T06-03 | concurrency and log batch isolation | ADMIN_LOGGER | OPEN |
| RAC-A-006 | T06-02,T07-04 | position uniqueness under concurrency | ADMIN_LOGGER | OPEN |
| RAC-A-007 | T06-03,T08-01 | reproducible performance evidence | DBA + module | OPEN |
| RAC-A-008 | T07-03,T08-03 | failover/reconnect | DBA + module | OPEN |
| RAC-A-009 | T06-03,T08-01 | performance, service and deployment evidence | DBA | OPEN |
| RAC-A-010 | T01-01,T02-01,T03-01 | index after LOG table, unchanged semantics | ADMIN_LOGGER | SOURCE_FIXED; Oracle NOT_EXECUTED |
| RAC-A-011 | T01-01,T02-01,T03-02 | comma and incident PK | ADMIN_LOGGER | SOURCE_FIXED; Oracle NOT_EXECUTED |
| RAC-A-012 | T05-01,T07-02 | least privilege, safe remote maintenance | DBA + module | OPEN |
| LOG-OPEN-01 | T01-01,T02-02 | baseline, compile and bug evidence | ADMIN_LOGGER | OPEN |
| LOG-OPEN-02 | T03-03,T04-03,C02,C03 | session/config/restore consistency | ADMIN_LOGGER | OPEN |
| LOG-OPEN-03 | T03-04,T04-01,C04,C05 | logging targets and failure behavior | ADMIN_LOGGER | OPEN |
| LOG-OPEN-04 | T08-01,T08-02 | audit, rollback and evidence | DBA + module | OPEN |
| LOG-OPEN-05 | T01-02,T04-01,T04-02 | consumer/API compatibility | TETOOLS__REGIE + module | OPEN |
| C01 | T05-02 | business rollback vs autonomous log | ADMIN_LOGGER | NOT_EXECUTED |
| C02 | T05-03 | management atomicity, guard release | ADMIN_LOGGER + DBA | BLOCKED fixture |
| C03 | T05-04 | durable diagnostics and bounded fallback | ADMIN_LOGGER + DBA | BLOCKED fixture |
| C04 | T05-05 | distinguish error classes | ADMIN_LOGGER + DBA | BLOCKED fixture |
| C05 | T05-06 | all LOG_*/FORCE variants and feedback | ADMIN_LOGGER | BLOCKED fault matrix |
| C06 | T05-07 | no recursive failure logging | DBA + module | BLOCKED watchdog |

## Open environment gates and risk register

| Risk | Priority | Owner | Required resolution |
|---|---|---|---|
| R1 Oracle 19c RU/SQLPATCH, exact CDB/PDB/CON_ID and DB_UNIQUE_NAME unknown | P1 | DBA | signed G01 evidence |
| R2 three-node services, failover client and remote session visibility unknown | P1 | DBA + application | G01/G07, RAC3 matrix |
| R3 empty isolated disposable TETOOLS schema not confirmed | P1 | DBA | G02 inventory, no production |
| R4 direct SYS.V_$ grants and consumer negative principal not confirmed | P1 | DBA/security | G03 least privilege |
| R5 backup/snapshot and tested recovery owner absent | P1 | DBA | G06 restore signoff |
| R6 C02–C06 controlled failure injection unapproved, unsafe to improvise | P1 | TETOOLS__REGIE + DBA | approve reversible fixture design separately |
| R7 API consumers/defaults and performance baseline unknown | P2 | Module + suite regie | G08 compatibility and thresholds |
| R8 licensing and availability of GV$/wait/redo metrics unverified | P2 | DBA | G07 licensed diagnostic plan |
| R9 SQL client path, slash semantics, spool and stop behavior not database-tested | P1 | Test engineer | T02 dry-run only after separate GO |

**Suite signal:** reuse `LOGGER-RAC-20261105-001` (INVESTIGATE). Do not create duplicate signal. Suite-wide identity, session purge and maintenance grants require TETOOLS__REGIE assessment; technical work stays with ADMIN_LOGGER__REGIE.

## Readiness determination

**NOT_READY** for `READY_FOR_EXECUTION_AUTHORIZATION_REVIEW` until DBA environment G01–G08 and safe failure fixtures are approved, independent test-package review passes, and a recovery runbook is signed. G09 separate Oracle test authorization remains **NOT_GRANTED**. `RAC_READY` and `ORACLE_VALIDATED` are forbidden until actual validated tests.
