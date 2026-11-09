-- C01. Separate authorized DBA-created table TETOOLS.STEP4_BUSINESS_FIXTURE required.
-- Fixture must contain RUN_ID VARCHAR2(128) NOT NULL; no constraints on test tag.
-- SQL client must be configured to TABLE logger target; this script does not alter it.
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SET SERVEROUTPUT ON
DECLARE
  l_before NUMBER;
  l_after NUMBER;
  l_log_before NUMBER;
  l_log_after NUMBER;
BEGIN
  SELECT COUNT(*) INTO l_before FROM tetools.step4_business_fixture WHERE run_id='&&TEST_RUN_ID';
  SELECT COUNT(*) INTO l_log_before FROM tetools.admin_logger_log WHERE context='STEP4_C01_&&TEST_RUN_ID';
  INSERT INTO tetools.step4_business_fixture(run_id) VALUES ('&&TEST_RUN_ID');
  tetools.admin_logger.LOG_ERROR('STEP4_C01_&&TEST_RUN_ID','autonomous diagnostic probe');
  ROLLBACK;
  SELECT COUNT(*) INTO l_after FROM tetools.step4_business_fixture WHERE run_id='&&TEST_RUN_ID';
  SELECT COUNT(*) INTO l_log_after FROM tetools.admin_logger_log WHERE context='STEP4_C01_&&TEST_RUN_ID';
  DBMS_OUTPUT.PUT_LINE('C01 business before/after='||l_before||'/'||l_after);
  DBMS_OUTPUT.PUT_LINE('C01 diagnostics before/after='||l_log_before||'/'||l_log_after);
  IF l_after<>l_before THEN RAISE_APPLICATION_ERROR(-20501,'C01 FAIL caller row persisted'); END IF;
  -- Do not automatically mark PASS: allowed autonomous diagnostics and target
  -- behavior must be confirmed against package contract and recorded separately.
END;
/
