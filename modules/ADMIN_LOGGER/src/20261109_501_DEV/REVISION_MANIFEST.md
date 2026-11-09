# ADMIN_LOGGER 20261109_501_DEV — ontwikkelrevisie (NIET-BEVROREN)

**Besluit:** REGIE-LOGGER-PILOT-20261109-001; PR #93. **Scope:** CODE_ONLY. **Status:** REVIEW_PENDING / NOT_INSTALLED / NOT_RELEASED. **Platform:** Oracle Database 19c Enterprise; RAC NOT_DEMONSTRATED.

## Baseline en bronhashes (Git blob SHA-1)

De originele bronset staat ongewijzigd in `../20261015_500/`. De nieuwe ontwikkelrevisie is een volledige kopie van de vijf bronbestanden met alleen de hieronder genoemde twee inhoudelijke DDL-correcties in het TABLE-script. De oorspronkelijke bestandsnamen zijn behouden om het verschil tot de baseline volledig zichtbaar te houden; de **directory** `20261109_501_DEV` identificeert de niet-bevroren revisie.

| Relatief bestand | Baseline Git blob SHA-1 | DEV Git blob SHA-1 | Statische vergelijking |
|---|---|---|---|
| PACKAGE_BODY/PACKAGE-BODY_TETOOLS_ADMIN_LOGGER__20261015_500.pkb | `febb57c5aebe3ce5d23799f60c6c38f793681d00` | `febb57c5aebe3ce5d23799f60c6c38f793681d00` | EXACT IDENTICAL |
| PACKAGE_SPEC/PACKAGE_TETOOLS_ADMIN_LOGGER__20261015_500.pks | `9331a2756b1c2196280cda3f10bf1643285f61ab` | `9331a2756b1c2196280cda3f10bf1643285f61ab` | EXACT IDENTICAL |
| PROCEDURES/20260527__ADMIN_LOGGER__001.prc | `5a5e4e3181816aa520f5067f2b8c0abd3fef63f1` | `5a5e4e3181816aa520f5067f2b8c0abd3fef63f1` | EXACT IDENTICAL |
| SEQUENCE/SEQ_20261007__ADMIN_LOGGER__001.sql | `47416ff9583c32bc14cbe49007cd277f2449682b` | `47416ff9583c32bc14cbe49007cd277f2449682b` | EXACT IDENTICAL |
| TABLE/TAB_TETOOLS_ADMIN_LOGGER__20261015_202.sql | `240b6516fcfd7e9a99ae7d47bb18433f77a8686f` | `0c112a15643c62bcf4c2d4ac37fd54e2b656a04a` | TWO AUTHORIZED CHANGES ONLY |

Hashes retrieved from GitHub blobs, not database object hashes. Identical blobs demonstrate byte-level preservation of PKS/PKB/API source, sequence and sample procedure. All five DEV files preserve CRLF line endings. Static normalized comparison **PASS**: remove the same index statement from old/new and apply only the one comma correction; the resulting SQL texts are exactly identical (198 CRLF-delimited lines). Index block occurs once in each file; three CASE expressions and slash terminator are unchanged.

## Complete content-only diff (baseline vs DEV TABLE)

```diff
@@ old TABLE lines 86-91 (remove index before log table)
-CREATE UNIQUE INDEX tetools.admin_logger_position_uk ON tetools.admin_logger_log (
-  CASE WHEN logbatch_id>0 AND log_lines>0 THEN logsession_id END,
-  CASE WHEN logbatch_id>0 AND log_lines>0 THEN logbatch_id END,
-  CASE WHEN logbatch_id>0 AND log_lines>0 THEN log_lines END
-)
-/
@@ directly after CREATE TABLE tetools.admin_logger_log and its / (old line 126)
+CREATE UNIQUE INDEX tetools.admin_logger_position_uk ON tetools.admin_logger_log (
+  CASE WHEN logbatch_id>0 AND log_lines>0 THEN logsession_id END,
+  CASE WHEN logbatch_id>0 AND log_lines>0 THEN logbatch_id END,
+  CASE WHEN logbatch_id>0 AND log_lines>0 THEN log_lines END
+)
+/
@@ old TABLE line 163
-  config_snapshot    CLOB
+  config_snapshot    CLOB,
```

The moved index has the identical name, UNIQUE flag, CASE expressions, punctuation and client terminator. No other DDL semantics or source text changed. Note: the GitHub PR displays new copied files rather than a Git rename diff; this baseline-to-DEV diff is the reviewable semantic diff.

## Review and execution gate

- Independent reviewer: **UNASSIGNED; REVIEW_NOT_EXECUTED**. Do not merge this PR before independent review PASS and central/contract merge authorization.
- Eight test categories and decision23/F03 contract cases: [LDR test plan](../../docs/reports/ADMIN_LOGGER_LDR_TESTPLAN_20261109.md); actual Oracle tests NOT_EXECUTED.
- Installation: planned clean isolated TETOOLS schema, SQL client stop-on-error, direct grants, tables/constraints before indexes, sequence, SPEC/BODY, inspect USER_ERRORS/INDEXES/CONSTRAINTS. This is **not** an executed install script and not authorization to connect.
- Recovery: pre-test snapshot or approved reverse-order object teardown in disposable schema; no blanket rerun or DROP in existing schema; Oracle DDL implicit commits. DBA, RU, PDB/CON_ID, three-node environment and backup owner UNVERIFIED.
- No release/frozen baseline changes; no Oracle-DDL/runtime/RAC execution; RAC_READY not demonstrated. Separate authorization for Oracle test phase required.

**Sources:** [formal decision](../../../../COMMUNICATION_RELAY/reviews/ADMIN_LOGGER_PILOT_DECISION_20261109.md), [LDR DDL analysis](../../docs/reports/ADMIN_LOGGER_LDR_DDL_20261109.md), [relay contract](../../../../COMMUNICATION_RELAY/RELAY_CONTRACT.md).
