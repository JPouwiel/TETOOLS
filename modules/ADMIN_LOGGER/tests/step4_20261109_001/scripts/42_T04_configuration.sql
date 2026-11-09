-- PREPARATION ONLY. G09 NOT_GRANTED. Never bypass 00_safety_gate.sql.
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
DEFINE STEP4_CASE_IDS = 'T03-04,T04-03'
DEFINE STEP4_OPERATION = 'TEST'
@@00_safety_gate.sql
SET SERVEROUTPUT ON SIZE UNLIMITED
SET ECHO ON
SET FEEDBACK ON
SET VERIFY OFF
@@00_post_install.sql
SPOOL &&TEST_RUN_ID._&&TEST_CLIENT_ID._T04_03_config.log CREATE
DECLARE
  l_tag VARCHAR2(128):='S4_&&TEST_RUN_ID._T04_03'; l_n NUMBER; l_saved BOOLEAN:=FALSE;
  l_on CHAR(1); l_debug CHAR(1);
BEGIN
  SELECT COUNT(*) INTO l_n FROM tetools.admin_logger_log WHERE context=l_tag;
  IF l_n<>0 THEN RAISE_APPLICATION_ERROR(-20410,'Run marker collision'); END IF;
  l_on:=tetools.admin_logger.logging_is_on;
  l_debug:=tetools.admin_logger.debug_is_on;
  tetools.admin_logger.session_details_revert('BACKUP','S4CFG'); l_saved:=TRUE;
  tetools.admin_logger.toggle_logging('OFF','T'); tetools.admin_logger.toggle_debug('OFF','T');
  tetools.admin_logger.LOG_INFO(l_tag,'suppressed');
  SELECT COUNT(*) INTO l_n FROM tetools.admin_logger_log WHERE context=l_tag;
  IF l_n<>0 THEN RAISE_APPLICATION_ERROR(-20411,'OFF log persisted'); END IF;
  tetools.admin_logger.toggle_logging('ON','T'); tetools.admin_logger.toggle_debug('OFF','T');
  tetools.admin_logger.toggle_batch('OFF','SINGLE');
  tetools.admin_logger.LOG_INFO(l_tag,'table');
  SELECT COUNT(*) INTO l_n FROM tetools.admin_logger_log WHERE context=l_tag AND log_category='INFO';
  IF l_n<>1 THEN RAISE_APPLICATION_ERROR(-20412,'TABLE log absent'); END IF;
  tetools.admin_logger.toggle_logging('ON','S');
  tetools.admin_logger.LOG_INFO(l_tag,'STEP4_SCREEN_EXPECTED');
  SELECT COUNT(*) INTO l_n FROM tetools.admin_logger_log WHERE context=l_tag;
  IF l_n<>1 THEN RAISE_APPLICATION_ERROR(-20413,'SCREEN call wrote table'); END IF;
  tetools.admin_logger.session_details_revert('RESTORE','S4CFG'); l_saved:=FALSE;
  IF NVL(tetools.admin_logger.logging_is_on,'!')<>NVL(l_on,'!')
    OR NVL(tetools.admin_logger.debug_is_on,'!')<>NVL(l_debug,'!') THEN
    RAISE_APPLICATION_ERROR(-20414,'Restored state mismatch');
  END IF;
  DBMS_OUTPUT.PUT_LINE('T03-04/T04-03 PARTIAL: assert screen token from spool; filters/batch/clear-scope remain manual BLOCKED');
EXCEPTION WHEN OTHERS THEN
  IF l_saved THEN
    BEGIN tetools.admin_logger.session_details_revert('RESTORE','S4CFG');
    EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('STOP: config restore failed'); END;
  END IF;
  RAISE;
END;
/
SPOOL OFF
