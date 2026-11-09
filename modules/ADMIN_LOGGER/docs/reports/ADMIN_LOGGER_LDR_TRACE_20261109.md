# ADMIN_LOGGER — LDR-01 traceermatrix (2026-11-09)

Status ANALYSIS_ONLY; Oracle NOT_EXECUTED; RAC NOT_DEMONSTRATED. All 17 findings remain OPEN. Source keys: BODY=PACKAGE_BODY/PACKAGE-BODY_TETOOLS_ADMIN_LOGGER__20261015_500.pkb; SPEC=PACKAGE_SPEC/PACKAGE_TETOOLS_ADMIN_LOGGER__20261015_500.pks; TABLE=TABLE/TAB_TETOOLS_ADMIN_LOGGER__20261015_202.sql; SEQUENCE=SEQUENCE/SEQ_20261007__ADMIN_LOGGER__001.sql, all relative to ../../src/20261015_500/. Locations verified against canonical baseline and RAC report A. Acceptance criteria PROPOSED, not tested.

| ID | Priority | Exact source lines | Risk/open point | Owner | Proposed acceptance |
|---|---|---|---|---|---|
| RAC-A-001 | P1 | BODY 1716-1778; 714-723; 886-890 | Local V$SESSION purge may delete live remote sessions | Regie/DBA | 3-node remote session retained |
| RAC-A-002 | P1 | BODY 56-65,175-201,803-832; TABLE 18-34,141-165 | INST_ID/CON_ID provenance absent | Regie/DBA/central | Identity collision and migration tests |
| RAC-A-003 | P1 | SPEC 1-3; BODY 163-198,362-369,446-453 | Grants/container visibility unknown | DBA | Real RU and direct grants verified |
| RAC-A-004 | P2 | BODY 514-549,680-688,1763-1769,1803-1806,1893-1919 | Single guard serializes writers | Regie | 3-node contention and wait metrics |
| RAC-A-005 | P2 | BODY 514-548,553-628,761-779,1111-1128,1243-1262 | Autonomous transactions vs caller locks | Regie | No deadlock/partial commit in injected failure |
| RAC-A-006 | P2 | BODY 784-895,1287-1346,1391-1446 | Metadata reload/per-line commits | Regie | p95 and throughput benchmark |
| RAC-A-007 | P2 | SEQUENCE 1-5; BODY 1205-1223 | ORDER sequence potentially serializes RAC | Regie/DBA | Measure uniqueness and ORDER cost |
| RAC-A-008 | P1 | BODY 75-93,722-723,886-890,948-1011,1333-1338 | Reconnect/replay/backup semantics unknown | Regie/app | Per-driver failover and state test |
| RAC-A-009 | P2 | BODY 1720-1746,1755-1760,1782-1806 | Node clock and retention policy unknown | Regie/DBA | Timezone and cutoff boundary tests |
| RAC-A-010 | P1 | TABLE 83-91,108-126 | Position index before log table | Regie | Fresh install index exists and enforces uniqueness |
| RAC-A-011 | P1 | TABLE 141-167,163-165 | Missing comma before incident PK | Regie | Incident DDL compiles and PK/check enabled |
| RAC-A-012 | P1 | SPEC 1-3,430-448; BODY 1716-1819 | Public EXECUTE also grants maintenance access | Regie/DBA | Least privilege and authorization negative tests |
| LOG-OPEN-01 | OPEN | SPEC 376-491; BODY 1-1928 | Broader bug/dead-code/performance review | Regie | Full functional baseline and prioritized review |
| LOG-OPEN-02 | OPEN | SPEC 1-3; BODY 163-198; TABLE 18-199 | Oracle 19c runtime/privileges | DBA/Regie | RU, compile and runtime evidence |
| LOG-OPEN-03 | OPEN | TABLE 83-91,141-167; report 030 | Installer 003 defect review | Regie | Clean install with approved installer |
| LOG-OPEN-04 | OPEN | SPEC 432; BODY 946-1011; proposal 027 | Backup/restore API comparison | Regie | Preserve session_details_revert external behavior |
| LOG-OPEN-05 | OPEN | SPEC 376-491; suite registry | Consumers, versions, install order | Regie/central | Approved compatibility manifest |

Primary detail: [RAC report A](20261105__PLSQL__TETOOLS_ADMIN_LOGGER__RAC_analyse_A_20261015_500_STE_033.html); [open points](../../OPEN_POINTS.md). Existing suite signal LOGGER-RAC-20261105-001; no duplicate.
