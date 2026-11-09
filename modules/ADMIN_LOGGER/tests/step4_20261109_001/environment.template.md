# DBA environment declaration — all values UNVERIFIED

| Field | DBA value / evidence | Status |
|---|---|---|
| Oracle version, exact 19c RU and DBA_REGISTRY_SQLPATCH | UNVERIFIED | UNVERIFIED |
| DB_UNIQUE_NAME, CDB/PDB, CON_ID, test schema TETOOLS | UNVERIFIED | UNVERIFIED |
| Three GV$INSTANCE nodes, INST_ID, host, service aliases, failover/replay mode | UNVERIFIED | UNVERIFIED |
| Client SQL*Plus/SQLcl version and connection/wallet policy | UNVERIFIED | UNVERIFIED |
| Dedicated empty disposable non-production PDB/schema and object inventory | UNVERIFIED | UNVERIFIED |
| Direct grants and denied privileges; runtime/maintenance principals | UNVERIFIED | UNVERIFIED |
| GV$/DBA observation rights and Diagnostic/Tuning Pack licensing restrictions | UNVERIFIED | UNVERIFIED |
| Snapshot/backup identifier, restore procedure, owner, tested RTO | UNVERIFIED | UNVERIFIED |
| Change window, security review, DDL authorization and stop owner | UNVERIFIED | UNVERIFIED |
| Consumers, API contract, baseline data and expected performance thresholds | UNVERIFIED | UNVERIFIED |

**Stop** if any environment identity mismatches, objects exist before clean install, PDB is production, unauthorized grant is needed, snapshot is missing, or a non-disposable schema is targeted. No fake default addresses, passwords or CON_ID values.
