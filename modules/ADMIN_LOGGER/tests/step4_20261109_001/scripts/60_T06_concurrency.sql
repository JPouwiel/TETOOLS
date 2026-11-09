-- T06: run separately on two independent SQL clients, NOT as a one-client proof.
-- DBA must collect wait/lock/redo metrics; script is only a harmless identity probe.
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SET SERVEROUTPUT ON
SELECT SYS_CONTEXT('USERENV','SID') AS sid,
       SYS_CONTEXT('USERENV','CON_ID') AS con_id,
       SYS_CONTEXT('USERENV','INSTANCE_NAME') AS instance_name
FROM dual;
-- T06-01: Client A locks guard row SELECT ... FOR UPDATE WAIT 5, holds transaction.
-- T06-02: Client B attempts same statement; capture elapsed/ORA-30006 if timeout.
-- T06-03: parallel inserts of same batch-position in separate clients; one
-- must fail uniqueness, with evidence; ROLLBACK both clients.
-- DO NOT add DBMS_LOCK.SLEEP or timing assertions without DBA-approved harness.
