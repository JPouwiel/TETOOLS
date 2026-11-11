-- PREPARATION ONLY. G09 NOT_GRANTED. Never bypass 00_safety_gate.sql.
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
DEFINE STEP4_CASE_IDS = 'T05-02'
DEFINE STEP4_OPERATION = 'TEST'
@@00_safety_gate.sql
SET SERVEROUTPUT ON SIZE UNLIMITED
SET ECHO ON
SET FEEDBACK ON
SET VERIFY OFF
@@00_post_install.sql
SPOOL &&TEST_RUN_ID._&&TEST_CLIENT_ID._C01.log CREATE
DECLARE
  l_tag VARCHAR2(128):='S4_&&TEST_RUN_ID._C01'; l_n NUMBER; l_sid NUMBER;
  l_saved BOOLEAN:=FALSE;
BEGIN
  SELECT COUNT(*) INTO l_n FROM tetools.step4_business_fixture WHERE run_id='&&TEST_RUN_ID';
  IF l_n<>0 THEN RAISE_APPLICATION_ERROR(-20510,'C01 business run ID collision'); END IF;
  SELECT COUNT(*) INTO l_n FROM tetools.admin_logger_log WHERE context=l_tag;
  IF l_n<>0 THEN RAISE_APPLICATION_ERROR(-20511,'C01 diagnostic marker collision'); END IF;
  -- Complete all autonomous setup BEFORE the business INSERT.
  tetools.admin_logger.session_details_revert('BACKUP','S4C01'); l_saved:=TRUE;
  tetools.admin_logger.toggle_logging('ON','T'); tetools.admin_logger.toggle_debug('OFF','T');
  tetools.admin_logger.toggle_batch('OFF','SINGLE');
  SELECT s.logsession_id INTO l_sid FROM tetools.admin_logger_sessions s
   WHERE s.sid=tetools.admin_logger.get_invoking_sid AND s.serial#=tetools.admin_logger.get_invoking_serial
     AND s.audsid=tetools.admin_logger.get_audsid(s.sid,s.serial#)
     AND s.logon_time=tetools.admin_logger.get_logon_time(s.sid,s.serial#);
  INSERT INTO tetools.step4_business_fixture(run_id) VALUES('&&TEST_RUN_ID');
  tetools.admin_logger.LOG_ERROR(l_tag,'C01_AUTONOMOUS_DIAGNOSTIC');
  ROLLBACK;
  SELECT COUNT(*) INTO l_n FROM tetools.step4_business_fixture WHERE run_id='&&TEST_RUN_ID';
  IF l_n<>0 THEN RAISE_APPLICATION_ERROR(-20512,'C01 FAIL caller business row committed'); END IF;
  SELECT COUNT(*) INTO l_n FROM tetools.admin_logger_log
   WHERE context=l_tag AND logsession_id=l_sid AND log_category='ERROR'
     AND DBMS_LOB.COMPARE(text,TO_CLOB('C01_AUTONOMOUS_DIAGNOSTIC'))=0;
  IF l_n<>1 THEN RAISE_APPLICATION_ERROR(-20513,'C01 FAIL missing/duplicate persisted autonomous diagnostic'); END IF;
  tetools.admin_logger.session_details_revert('RESTORE','S4C01'); l_saved:=FALSE;
  DBMS_OUTPUT.PUT_LINE('C01 assertions passed; session='||l_sid||' marker='||l_tag);
  -- Independent observer must confirm same persisted diagnostic; retain evidence before DBA teardown.
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  IF l_saved THEN
    BEGIN tetools.admin_logger.session_details_revert('RESTORE','S4C01');
    EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('STOP: C01 configuration restore failed'); END;
  END IF;
  RAISE;
END;
/
SPOOL OFF
