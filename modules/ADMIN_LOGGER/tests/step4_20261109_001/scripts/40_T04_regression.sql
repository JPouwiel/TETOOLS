-- PREPARATION ONLY. G09 NOT_GRANTED. Never bypass 00_safety_gate.sql.
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
DEFINE STEP4_CASE_IDS = 'T04-01'
DEFINE STEP4_OPERATION = 'TEST'
@@00_safety_gate.sql
SET SERVEROUTPUT ON SIZE UNLIMITED
SET ECHO ON
SET FEEDBACK ON
SET VERIFY OFF
@@00_post_install.sql
SPOOL &&TEST_RUN_ID._&&TEST_CLIENT_ID._T04_01_smoke.log CREATE
BEGIN
  tetools.admin_logger.version;
  tetools.admin_logger.help('N');
  DBMS_OUTPUT.PUT_LINE('T04-01 HELP_VERSION_CAPTURED; reviewer compares expected package/version/help tokens');
END;
/
SPOOL OFF
-- VARCHAR2 procedure/function behavior is asserted in 41. Smoke alone is not T04-01 PASS.
