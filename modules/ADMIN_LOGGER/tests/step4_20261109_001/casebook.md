# Casebook correction revision 1

**All Oracle execution: NOT_EXECUTED; G09 NOT_GRANTED.** Preparation status is not a runtime outcome. Full per-case requirements, privileges, fixtures, stop/negative conditions, evidence and cleanup are in [cases.json](cases.json). Exact remaining manual protocols: [procedures.md](procedures.md). No database was connected.

| ID | Mode | Requirement | Procedure | Preparation | Execution |
|---|---|---|---|---|---|
| T01-01 | OFF | RAC-A-010,RAC-A-011 | verify_static.py | STATIC_PREPARED | NOT_EXECUTED |
| T01-02 | OFF | LOG-OPEN-05 | api_inventory.json | STATIC_PREPARED | NOT_EXECUTED |
| T02-01 | SI | RAC-A-010,RAC-A-011,LOG-OPEN-03 | scripts/10_install.sql | CORRECTED_PENDING_REVIEW | NOT_EXECUTED |
| T02-02 | SI | LOG-OPEN-01,LOG-OPEN-02,RAC-A-003 | scripts/20_T02_compile.sql; procedures.md#compile-warnings | BLOCKED | NOT_EXECUTED |
| T03-01 | SI | RAC-A-010 | scripts/30_T03_functional.sql | CORRECTED_PENDING_REVIEW | NOT_EXECUTED |
| T03-02 | SI | RAC-A-011 | scripts/31_T03_incident.sql; fixtures.md#incident | BLOCKED | NOT_EXECUTED |
| T03-03 | SI | LOG-OPEN-02 | scripts/30_T03_functional.sql | CORRECTED_PENDING_REVIEW | NOT_EXECUTED |
| T03-04 | SI | LOG-OPEN-02 | scripts/42_T04_configuration.sql; procedures.md#configuration | BLOCKED | NOT_EXECUTED |
| T04-01 | SI | LOG-OPEN-05 | scripts/40_T04_regression.sql; scripts/41_T04_overloads.sql | CORRECTED_PENDING_REVIEW | NOT_EXECUTED |
| T04-02 | SI | LOG-OPEN-05 | scripts/41_T04_overloads.sql | CORRECTED_PENDING_REVIEW | NOT_EXECUTED |
| T04-03 | SI | LOG-OPEN-04,LOG-OPEN-05,RAC-A-008,RAC-A-009 | scripts/42_T04_configuration.sql; procedures.md#configuration | BLOCKED | NOT_EXECUTED |
| T05-01 | SI | RAC-A-003,RAC-A-012,LOG-OPEN-02 | scripts/50_T05_security.sql; procedures.md#security | BLOCKED | NOT_EXECUTED |
| T05-02 | SI | C01 | scripts/52_C01_fixture.sql; scripts/51_C01_caller_rollback.sql | CORRECTED_PENDING_REVIEW | NOT_EXECUTED |
| T05-03 | SI | C02,RAC-A-005 | procedures.md#c02-c06 | BLOCKED | NOT_EXECUTED |
| T05-04 | SI | C03,RAC-A-005 | procedures.md#c02-c06 | BLOCKED | NOT_EXECUTED |
| T05-05 | SI | C04 | procedures.md#c02-c06 | BLOCKED | NOT_EXECUTED |
| T05-06 | SI | C05 | procedures.md#c02-c06 | BLOCKED | NOT_EXECUTED |
| T05-07 | SI | C06 | procedures.md#c02-c06 | BLOCKED | NOT_EXECUTED |
| T06-01 | SI/RAC3 | RAC-A-004,RAC-A-005 | scripts/61_T06_guard_client_A.sql; scripts/62_T06_guard_client_B.sql; scripts/63_T06_guard_release_A.sql; scripts/64_T06_guard_reacquire_B.sql | CORRECTED_PENDING_REVIEW | NOT_EXECUTED |
| T06-02 | SI | RAC-A-004,RAC-A-010 | procedures.md#uniqueness | BLOCKED | NOT_EXECUTED |
| T06-03 | SI/RAC3 | RAC-A-004,RAC-A-006,RAC-A-007 | procedures.md#performance | BLOCKED | NOT_EXECUTED |
| T07-01 | RAC3 | RAC-A-002,RAC-A-003 | scripts/70_T07_rac.sql; procedures.md#rac | BLOCKED | NOT_EXECUTED |
| T07-02 | RAC3 | RAC-A-001,RAC-A-003,RAC-A-012 | procedures.md#remote-purge | BLOCKED | NOT_EXECUTED |
| T07-03 | RAC3 | RAC-A-002,RAC-A-008 | procedures.md#failover | BLOCKED | NOT_EXECUTED |
| T07-04 | RAC3 | RAC-A-004,RAC-A-010,RAC-A-011 | procedures.md#uniqueness | BLOCKED | NOT_EXECUTED |
| T08-01 | SI/RAC3 | LOG-OPEN-02,LOG-OPEN-05 | scripts/80_T08_evidence.sql; procedures.md#evidence | CORRECTED_PENDING_REVIEW | NOT_EXECUTED |
| T08-02 | SI/RAC3 | LOG-OPEN-02 | scripts/90_cleanup.sql; procedures.md#recovery | BLOCKED | NOT_EXECUTED |
| T08-03 | RAC3 | RAC-A-001,RAC-A-002,RAC-A-003,RAC-A-004,RAC-A-005,RAC-A-006,RAC-A-007,RAC-A-008,RAC-A-009,RAC-A-010,RAC-A-011,RAC-A-012 | procedures.md#acceptance | BLOCKED | NOT_EXECUTED |

## Contracts C01-C06

C01=T05-02: business row disappears AND permitted autonomous diagnostic survives for exact marker/session; both asserted in51. C02=T05-03 atomic management and guard release; C03=T05-04 durable diagnostic/fallback; C04=T05-05 three fault classes; C05=T05-06 API-specific feedback; C06=T05-07 bounded nonrecursive fallback. C02-C06 remain BLOCKED without approved reversible injection/observer/recovery. 41 normal overload behavior is not C05 failure acceptance.

SQL scripts are prepared source, not a claim of 19c compilation or client behavior. All SQL entries stop at the immutable shared G09 gate. A future GO requires separate source-reviewed authorization pins and independent review. No global READY/Oracle PASS is claimed.
