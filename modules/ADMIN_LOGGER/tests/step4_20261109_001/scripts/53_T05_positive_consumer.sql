-- Positive consumer only; owner/DBA cannot substitute for a consumer.
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
DEFINE STEP4_CASE_IDS = 'T05-01'
DEFINE STEP4_OPERATION = 'SECURITY'
@@00_safety_gate.sql
SET SERVEROUTPUT ON SIZE UNLIMITED
SPOOL &&TEST_RUN_ID._&&TEST_CLIENT_ID._T05_01_positive.log CREATE
DECLARE l_return PLS_INTEGER;
BEGIN
  IF USER IN ('TETOOLS','SYS','SYSTEM') THEN RAISE_APPLICATION_ERROR(-20530,'Separate EXECUTE-only consumer required'); END IF;
  l_return:=tetools.admin_logger.LOG_INFO_FORCE('S4_&&TEST_RUN_ID._T05_POS','POSITIVE_CONSUMER');
  IF l_return IS NULL OR l_return<>1 THEN RAISE_APPLICATION_ERROR(-20531,'Positive consumer return mismatch'); END IF;
  DBMS_OUTPUT.PUT_LINE('POSITIVE_API_COMPLETED; observer verifies row, principal and effective least privileges');
END;
/
SPOOL OFF
