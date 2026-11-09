-- PREPARATION ONLY. G09 NOT_GRANTED. Never bypass 00_safety_gate.sql.
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
DEFINE STEP4_CASE_IDS = 'T06-01'
DEFINE STEP4_OPERATION = 'LOCK'
@@00_safety_gate.sql
SET SERVEROUTPUT ON SIZE UNLIMITED
SET ECHO ON
SET FEEDBACK ON
SET VERIFY OFF
SPOOL &&TEST_RUN_ID._&&TEST_CLIENT_ID._T06_01_A.log CREATE
SELECT SYSTIMESTAMP acquired_at, guard_id FROM tetools.admin_logger_guard
 WHERE guard_id=1 FOR UPDATE WAIT 5;
PROMPT A_HOLD: do not disconnect, COMMIT or invoke logger; start B after this marker.
-- No implicit exit: operator keeps this SQL*Plus client open. Release ONLY with 63.
SPOOL OFF
