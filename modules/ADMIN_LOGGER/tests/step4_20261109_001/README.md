# ADMIN_LOGGER Step 4 — Oracle 19c executable test preparation

**Decision:** REGIE-LOGGER-TESTPREP-20261109-001. **Authorization:** PREPARATION_ONLY. **All database cases: NOT_EXECUTED.** **Target:** Oracle 19c Enterprise; three-node RAC tests require three actual instances. **Revision:** `20261109_501_DEV` (merged PR #97, commit `81eadafaf575accadddd18e173d4f733359ea4b7`). This directory contains **test tooling**, not changes to production code.

## Safety gates and usage

No SQL here was executed by the preparer. Never connect these scripts to production. Scripts intentionally require `EXECUTION_APPROVED=YES`, `DBA_ENV_APPROVED=YES`, an authorized isolated schema **named TETOOLS** (source SQL hardcodes this owner), a disposable empty PDB/schema, and a DBA-approved snapshot/teardown plan. No test authorization is inferred from preparing or reviewing this repository. `sqlplus` / SQLcl version, wallet/connect string, RU, CON_ID, direct grants, service aliases, backup, restore owner, licensed diagnostics: **UNVERIFIED**. Do not put passwords in files or command arguments.

Before running anything in a future separately authorized session:
1. DBA fills `environment.template.md` and signs G01–G09; security reviews `privileges.md`.
2. Operator makes a protected private `env_approved.sql` (not committed), using `env.template.sql`; checks actual target PDB, schema, database identity and grants.
3. Verify pinned Git blobs using `manifest.md`; compare all six with main; record actual SHA-256 of exported files if the transport changes bytes.
4. Obtain explicit test-phase GO with test IDs, authorized DDL, environment, maintenance window, rollback owner and stop conditions.
5. On disposable environment only, invoke `@scripts/00_preflight.sql` with `env_approved.sql` loaded, then `@scripts/10_install.sql` (destructive DDL permission separately confirmed). Run only explicitly approved cases `T02..T08`. **No master script automatically runs all tests.**
6. Collect spools and `results_template.csv` in approved evidence store, redact identifiers, then DBA signs off recovery.

## File and execution order

| Order | File | Mode | Dependency |
|---|---|---|---|
| 0 | manifest.md / environment.template.md / privileges.md | Offline | main source hashes and DBA G01–G09 |
| 1 | env.template.sql -> private env_approved.sql | Configuration | Never commit secrets |
| 2 | scripts/00_preflight.sql | Read-only | approved variables, verified target PDB, empty object inventory |
| 3 | scripts/10_install.sql | DDL, high-risk | explicit authorization, snapshot, preflight PASS |
| 4 | scripts/20_T02_compile.sql | Read-only | installed package and source objects |
| 5 | scripts/30_T03_functional.sql | DML + API | installation PASS; isolated disposable schema |
| 6 | scripts/40_T04_regression.sql | API + DML | baseline signature catalogue; settings |
| 7 | scripts/50_T05_security.sql | Read-only + DML | separate positive/negative principals, DBA |
| 8 | scripts/60_T06_concurrency.sql | Multi-session | two+ independent SQL clients; DBA lock monitoring |
| 9 | scripts/70_T07_rac.sql | Three sessions/nodes | three RAC instances and approved service map |
| 10 | scripts/80_T08_evidence.sql | Read-only | all executed case spools, recovery sign-off |
| 11 | scripts/90_cleanup.sql | DESTRUCTIVE | DBA confirmation and isolated schema, restore plan |

`casebook.md` defines each test case and all six contracts C01–C06, with expected results, proof, stop/cleanup, single-instance/RAC applicability. SQL scripts contain runnable core probes and precise manual multi-session orchestration. Some fault-injection cases need DBA-approved reversible fixtures; these are **NOT_READY** until exact fixtures are approved; do not modify package code for injection.

## Acceptance gates

T01 static review may be marked STATIC_PASS after independent recheck. T02–T08 and C01–C06 remain NOT_EXECUTED. A prepared script is not evidence of compilation or behavior. Full `READY_FOR_EXECUTION_AUTHORIZATION_REVIEW` requires G01–G08 satisfied, independent review, no unsafe unresolved fault-injection methods, pinned runbook and recovery owner; otherwise NOT_READY. Separate G09 execution GO is mandatory even if preparation READY. For RAC_READY, actual T07 must PASS on all three nodes. See `casebook.md`, `traceability.md` and `results_template.csv`.

**References:** [central preparation](../../../../COMMUNICATION_RELAY/reviews/ADMIN_LOGGER_STEP4_ORACLE_TEST_PREPARATION_20261109.md), [original LDR plan](../../docs/reports/ADMIN_LOGGER_LDR_TESTPLAN_20261109.md), [source manifest](../../src/20261109_501_DEV/REVISION_MANIFEST.md), [Oracle 19c SQL*Plus WHENEVER SQLERROR](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqpug/using-sqlplus.html), [Oracle 19c implicit DDL commits](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/COMMIT.html). Relative paths are from module root and should be checked before invocation.
