# Fixture designs — PREPARATION_ONLY / all DB execution NOT_EXECUTED

Each fixture needs its own case/operation-bound G09, DBA identity, before inventory, exact approved script SHA, snapshot/teardown identifier, fault-off action and cancellation/stop owner. None is approved by this document. No product/source object or identity definition is altered. Source SQL and frozen releases remain pinned.

## Business fixture C01

`scripts/52_C01_fixture.sql` prepares CREATE TABLE TETOOLS.STEP4_BUSINESS_FIXTURE with RUN_ID VARCHAR2(48) NOT NULL and a RUN_ID primary key. Empty object check prevents blind rerun; no DROP. Run only after source installation and separately approved FIXTURE operation. Dedicated caller must have no prior business DML.51 requires no row for the unique run ID and no diagnostic marker. It saves config, enables logging TABLE/debug OFF/single, resolves actual LOGSESSION_ID, inserts business row, calls LOG_ERROR, rolls back, asserts business0 AND diagnostic1 with exact session/category/text, restores config. A separate approved observer confirms committed persistence. Failure stops; no logger call from exception cleanup. DBA retains diagnostic until signed evidence and tears down only approved objects.

## Incident

The actual INCIDENT_ID is GENERATED ALWAYS. Oracle19c rejects explicit identity assignments; this is not a duplicate-PK proof. No unsupported override syntax, identity ALTER, sequence reset or source DDL change is proposed.31 checks actual PK/identity metadata and explicitly reports METADATA_ONLY.

Prepared real-row fixture design: derive true SID/SERIAL#/AUDSID/LOGON_USER/LOGON_TIME from current approved GV$SESSION observer; capture current_user/current_schema/proxy_user; use CREATED_ON=SYSTIMESTAMP, CONTEXT='S4_<RUN>_T03_02', STATUS='OPEN', REASON='missing_id'; omit INCIDENT_ID and RETURNING the generated ID. In a caller transaction, assert returned ID non-null, one exact persisted-in-transaction row and PK metadata; insert separately with each required nonidentity field NULL, catch ONLY ORA-01400 and assert count unchanged; ROLLBACK. This needs a separately reviewed guarded fixture script and DBA real identity capture before execution; preparation remains BLOCKED, no implied permission.

Optional typed clone design (also BLOCKED until exact DBA DDL reviewed): explicit STEP4_INCIDENT_PK_FIXTURE table with INCIDENT_ID NUMBER NOT NULL, RUN_ID VARCHAR2(48) NOT NULL and a named primary key on INCIDENT_ID; insert two same ID/run values, expect ORA-00001, then rollback. This demonstrates the clone's PK, not the source incident PK. Do not mark real duplicate-PK acceptance PASS from clone, identity rejection or metadata. A safe actual duplicate-PK method is an unresolved module/DBA decision; source identity must remain unchanged.

## C02-C06 failure fixtures

BLOCKED: no approved reversible mechanism yet exists to fail precisely between source management DMLs, fail diagnostic persistence and guarantee external observation/recovery without modifying source. Do not invent a trigger, revoke owner rights, lock a shared object or fill a tablespace. Each proposed mechanism must name exact source point, fault class, operation footprint, validity after fault, observer visibility, injection-on/off sequence, watchdog and independent restore. C02-C06 cannot become prepared/executable merely by renaming these missing dependencies.

## Concurrency / RAC

No fabricated physical identities. Use genuine current session registration IDs and externally coordinated clients. For index-only races a single captured positive (LOGSESSION_ID,LOGBATCH_ID,LOG_LINES) tuple is deliberately shared across clients in the isolated schema; lack of an FK is not permission to use production IDs. Allocate tuple once, prove no collision, record winner LOGGER_ID, don't guess MAX+1. Ten trials and three-node variant require approved coordinator and cleanup key inventory. Autonomous calls may commit rows; caller rollback does not clean them.

## Filters, maintenance and performance

Source context_filter/callstack_filter columns have no public setter/application in the pinned BODY: their mere presence is not evidence of implemented filtering. Expected filtering behavior is UNVERIFIED; do not modify columns or approve functionality to fabricate a test. Record a separate functional clarification before adding a runtime acceptance claim. Clear-scope fixtures use only disposable known test rows with explicit timestamps and inactive/active-batch classifications; see procedures.md. Performance baseline/thresholds and licensed metric visibility require DBA/module sign-off.
