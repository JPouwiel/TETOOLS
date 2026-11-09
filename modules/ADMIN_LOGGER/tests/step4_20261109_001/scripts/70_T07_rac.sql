-- T07: same script must be run through three DBA-confirmed distinct RAC services.
-- It does NOT perform failover and cannot establish RAC readiness alone.
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SET SERVEROUTPUT ON
SELECT SYS_CONTEXT('USERENV','DB_UNIQUE_NAME') AS db_unique_name,
       SYS_CONTEXT('USERENV','CON_NAME') AS pdb_name,
       SYS_CONTEXT('USERENV','CON_ID') AS con_id,
       SYS_CONTEXT('USERENV','INSTANCE_NAME') AS instance_name,
       SYS_CONTEXT('USERENV','SID') AS sid
FROM dual;
-- DBA-observer (separate account with explicit grants):
-- SELECT inst_id,instance_name,status FROM gv$instance ORDER BY inst_id;
-- SELECT inst_id,con_id,sid,serial#,audsid,username,service_name
-- FROM gv$session WHERE username='TETOOLS';
-- T07-01..04: run casebook three-node cross-instance matrix;
-- reconnect/failover requires approved service/client test harness and DBA.
