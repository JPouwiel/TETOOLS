# Canonical risk traceability â€” correction1

Canonical meaning copied without reinterpretation from [LDR trace](../../docs/reports/ADMIN_LOGGER_LDR_TRACE_20261109.md). Original OPEN_POINTS and report A remain authoritative. Tests below supplement coverage; no risk is declared closed. Existing LOGGER-RAC-20261105-001 / Issue55 retained.

| ID | Canonical risk/open point | Cases | Remaining scope |
|---|---|---|
| RAC-A-001 | Local V$SESSION purge may delete live remote sessions | T07-02,T08-03 | Oracle NOT_EXECUTED; cases.json records missing DBA/fixtures |
| RAC-A-002 | INST_ID/CON_ID provenance absent | T07-01,T07-03,T08-03 | Oracle NOT_EXECUTED; cases.json records missing DBA/fixtures |
| RAC-A-003 | Grants/container visibility unknown | T02-02,T05-01,T07-01,T07-02,T08-03 | Oracle NOT_EXECUTED; cases.json records missing DBA/fixtures |
| RAC-A-004 | Single guard serializes writers | T06-01,T06-02,T06-03,T07-04,T08-03 | Oracle NOT_EXECUTED; cases.json records missing DBA/fixtures |
| RAC-A-005 | Autonomous transactions vs caller locks | T05-03,T05-04,T06-01,T08-03 | Oracle NOT_EXECUTED; cases.json records missing DBA/fixtures |
| RAC-A-006 | Metadata reload/per-line commits | T06-03,T08-03 | Oracle NOT_EXECUTED; cases.json records missing DBA/fixtures |
| RAC-A-007 | ORDER sequence potentially serializes RAC | T06-03,T08-03 | Oracle NOT_EXECUTED; cases.json records missing DBA/fixtures |
| RAC-A-008 | Reconnect/replay/backup semantics unknown | T04-03,T07-03,T08-03 | Oracle NOT_EXECUTED; cases.json records missing DBA/fixtures |
| RAC-A-009 | Node clock and retention policy unknown | T08-03 | Oracle NOT_EXECUTED; cases.json records missing DBA/fixtures |
| RAC-A-010 | Position index before log table | T01-01,T02-01,T03-01,T06-02,T07-04,T08-03 | Oracle NOT_EXECUTED; cases.json records missing DBA/fixtures |
| RAC-A-011 | Missing comma before incident PK | T01-01,T02-01,T03-02,T07-04,T08-03 | Oracle NOT_EXECUTED; cases.json records missing DBA/fixtures |
| RAC-A-012 | Public EXECUTE also grants maintenance access | T05-01,T07-02,T08-03 | Oracle NOT_EXECUTED; cases.json records missing DBA/fixtures |
| LOG-OPEN-01 | Broader bug/dead-code/performance review | T02-02 | Additional source review / proposal027 / consumer inventory in procedures.md; BLOCKED where evidence absent |
| LOG-OPEN-02 | Oracle 19c runtime/privileges | T02-02,T03-03,T03-04,T05-01,T08-01,T08-02 | Additional source review / proposal027 / consumer inventory in procedures.md; BLOCKED where evidence absent |
| LOG-OPEN-03 | Installer 003 defect review | T02-01 | Additional source review / proposal027 / consumer inventory in procedures.md; BLOCKED where evidence absent |
| LOG-OPEN-04 | Backup/restore API comparison | T04-03 | Additional source review / proposal027 / consumer inventory in procedures.md; BLOCKED where evidence absent |
| LOG-OPEN-05 | Consumers, versions, install order | T01-02,T04-01,T04-02,T04-03,T08-01 | Additional source review / proposal027 / consumer inventory in procedures.md; BLOCKED where evidence absent |

RAC-A-009 cutoff/timezone boundary protocol is an explicit supplemental scenario under T04-03 (see procedures.md#retention). LOG-OPEN-03 includes an explicit installer003 comparison under T02-01; LOG-OPEN-04 includes source-versus-proposal027 and external BACKUP/RESTORE under T04-03, not DBA snapshot restore. C01-C06 map one-to-one to T05-02..07. G01-G08 UNVERIFIED, G09 NOT_GRANTED.
