-- PREPARATION ONLY. G09 NOT_GRANTED. Never bypass 00_safety_gate.sql.
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
DEFINE STEP4_CASE_IDS = 'T04-01,T04-02'
DEFINE STEP4_OPERATION = 'TEST'
@@00_safety_gate.sql
SET SERVEROUTPUT ON SIZE UNLIMITED
SET ECHO ON
SET FEEDBACK ON
SET VERIFY OFF
@@00_post_install.sql
SPOOL &&TEST_RUN_ID._&&TEST_CLIENT_ID._T04_02_overloads.log CREATE
DECLARE
  l_clob CLOB:=TO_CLOB('STEP4_CLOB'); l_bool BOOLEAN:=TRUE;
  l_date DATE:=DATE '2026-11-09'; l_ret PLS_INTEGER;
  l_tag VARCHAR2(128):='S4_&&TEST_RUN_ID._T04_02_'; l_n NUMBER; l_saved BOOLEAN:=FALSE;
  PROCEDURE check_row(p_suffix VARCHAR2,p_category VARCHAR2,p_text VARCHAR2) IS
    l_count NUMBER; l_match NUMBER;
  BEGIN
    SELECT COUNT(*),NVL(SUM(CASE WHEN log_category=p_category
        AND DBMS_LOB.COMPARE(text,TO_CLOB(p_text))=0 AND logbatch_id IS NULL AND log_lines IS NULL
        THEN 1 ELSE 0 END),0)
      INTO l_count,l_match FROM tetools.admin_logger_log WHERE context=l_tag||p_suffix;
    IF l_count<>1 OR l_match<>1 THEN RAISE_APPLICATION_ERROR(-20401,'Overload output mismatch: '||p_suffix); END IF;
  END;
BEGIN
  SELECT COUNT(*) INTO l_n FROM tetools.admin_logger_log WHERE context LIKE l_tag||'%';
  IF l_n<>0 THEN RAISE_APPLICATION_ERROR(-20402,'Run marker collision'); END IF;
  tetools.admin_logger.session_details_revert('BACKUP','S4API'); l_saved:=TRUE;
  tetools.admin_logger.toggle_logging('ON','T');
  tetools.admin_logger.toggle_debug('ON','T');
  tetools.admin_logger.toggle_batch('OFF','SINGLE');
  tetools.admin_logger.LOG_RUNTIME(l_tag||'LOG_RUNTIME_VC','STEP4_VC');
  check_row('LOG_RUNTIME_VC','RUNTIME','STEP4_VC');
  tetools.admin_logger.LOG_RUNTIME(l_tag||'LOG_RUNTIME_CL',l_clob);
  check_row('LOG_RUNTIME_CL','RUNTIME','STEP4_CLOB');
  tetools.admin_logger.LOG_RUNTIME(l_tag||'LOG_RUNTIME_BO',l_bool);
  check_row('LOG_RUNTIME_BO','RUNTIME','TRUE');
  tetools.admin_logger.LOG_RUNTIME(l_tag||'LOG_RUNTIME_DT',l_date);
  check_row('LOG_RUNTIME_DT','RUNTIME','2026-11-09 00:00:00');
  tetools.admin_logger.LOG_INFO(l_tag||'LOG_INFO_VC','STEP4_VC');
  check_row('LOG_INFO_VC','INFO','STEP4_VC');
  tetools.admin_logger.LOG_INFO(l_tag||'LOG_INFO_CL',l_clob);
  check_row('LOG_INFO_CL','INFO','STEP4_CLOB');
  tetools.admin_logger.LOG_INFO(l_tag||'LOG_INFO_BO',l_bool);
  check_row('LOG_INFO_BO','INFO','TRUE');
  tetools.admin_logger.LOG_INFO(l_tag||'LOG_INFO_DT',l_date);
  check_row('LOG_INFO_DT','INFO','2026-11-09 00:00:00');
  tetools.admin_logger.LOG_WARNING(l_tag||'LOG_WARNING_VC','STEP4_VC');
  check_row('LOG_WARNING_VC','WARNING','STEP4_VC');
  tetools.admin_logger.LOG_WARNING(l_tag||'LOG_WARNING_CL',l_clob);
  check_row('LOG_WARNING_CL','WARNING','STEP4_CLOB');
  tetools.admin_logger.LOG_WARNING(l_tag||'LOG_WARNING_BO',l_bool);
  check_row('LOG_WARNING_BO','WARNING','TRUE');
  tetools.admin_logger.LOG_WARNING(l_tag||'LOG_WARNING_DT',l_date);
  check_row('LOG_WARNING_DT','WARNING','2026-11-09 00:00:00');
  tetools.admin_logger.LOG_ERROR(l_tag||'LOG_ERROR_VC','STEP4_VC');
  check_row('LOG_ERROR_VC','ERROR','STEP4_VC');
  tetools.admin_logger.LOG_ERROR(l_tag||'LOG_ERROR_CL',l_clob);
  check_row('LOG_ERROR_CL','ERROR','STEP4_CLOB');
  tetools.admin_logger.LOG_ERROR(l_tag||'LOG_ERROR_BO',l_bool);
  check_row('LOG_ERROR_BO','ERROR','TRUE');
  tetools.admin_logger.LOG_ERROR(l_tag||'LOG_ERROR_DT',l_date);
  check_row('LOG_ERROR_DT','ERROR','2026-11-09 00:00:00');
  tetools.admin_logger.LOG_DEBUG(l_tag||'LOG_DEBUG_VC','STEP4_VC');
  check_row('LOG_DEBUG_VC','DEBUG','STEP4_VC');
  tetools.admin_logger.LOG_DEBUG(l_tag||'LOG_DEBUG_CL',l_clob);
  check_row('LOG_DEBUG_CL','DEBUG','STEP4_CLOB');
  tetools.admin_logger.LOG_DEBUG(l_tag||'LOG_DEBUG_BO',l_bool);
  check_row('LOG_DEBUG_BO','DEBUG','TRUE');
  tetools.admin_logger.LOG_DEBUG(l_tag||'LOG_DEBUG_DT',l_date);
  check_row('LOG_DEBUG_DT','DEBUG','2026-11-09 00:00:00');
  tetools.admin_logger.LOG_RUNTIME_FORCE(l_tag||'LOG_RUNTIME_FORCE_VC','STEP4_VC');
  check_row('LOG_RUNTIME_FORCE_VC','RUNTIME','STEP4_VC');
  tetools.admin_logger.LOG_RUNTIME_FORCE(l_tag||'LOG_RUNTIME_FORCE_CL',l_clob);
  check_row('LOG_RUNTIME_FORCE_CL','RUNTIME','STEP4_CLOB');
  tetools.admin_logger.LOG_RUNTIME_FORCE(l_tag||'LOG_RUNTIME_FORCE_BO',l_bool);
  check_row('LOG_RUNTIME_FORCE_BO','RUNTIME','TRUE');
  tetools.admin_logger.LOG_RUNTIME_FORCE(l_tag||'LOG_RUNTIME_FORCE_DT',l_date);
  check_row('LOG_RUNTIME_FORCE_DT','RUNTIME','2026-11-09 00:00:00');
  tetools.admin_logger.LOG_INFO_FORCE(l_tag||'LOG_INFO_FORCE_VC','STEP4_VC');
  check_row('LOG_INFO_FORCE_VC','INFO','STEP4_VC');
  tetools.admin_logger.LOG_INFO_FORCE(l_tag||'LOG_INFO_FORCE_CL',l_clob);
  check_row('LOG_INFO_FORCE_CL','INFO','STEP4_CLOB');
  tetools.admin_logger.LOG_INFO_FORCE(l_tag||'LOG_INFO_FORCE_BO',l_bool);
  check_row('LOG_INFO_FORCE_BO','INFO','TRUE');
  tetools.admin_logger.LOG_INFO_FORCE(l_tag||'LOG_INFO_FORCE_DT',l_date);
  check_row('LOG_INFO_FORCE_DT','INFO','2026-11-09 00:00:00');
  tetools.admin_logger.LOG_WARNING_FORCE(l_tag||'LOG_WARNING_FORCE_VC','STEP4_VC');
  check_row('LOG_WARNING_FORCE_VC','WARNING','STEP4_VC');
  tetools.admin_logger.LOG_WARNING_FORCE(l_tag||'LOG_WARNING_FORCE_CL',l_clob);
  check_row('LOG_WARNING_FORCE_CL','WARNING','STEP4_CLOB');
  tetools.admin_logger.LOG_WARNING_FORCE(l_tag||'LOG_WARNING_FORCE_BO',l_bool);
  check_row('LOG_WARNING_FORCE_BO','WARNING','TRUE');
  tetools.admin_logger.LOG_WARNING_FORCE(l_tag||'LOG_WARNING_FORCE_DT',l_date);
  check_row('LOG_WARNING_FORCE_DT','WARNING','2026-11-09 00:00:00');
  tetools.admin_logger.LOG_ERROR_FORCE(l_tag||'LOG_ERROR_FORCE_VC','STEP4_VC');
  check_row('LOG_ERROR_FORCE_VC','ERROR','STEP4_VC');
  tetools.admin_logger.LOG_ERROR_FORCE(l_tag||'LOG_ERROR_FORCE_CL',l_clob);
  check_row('LOG_ERROR_FORCE_CL','ERROR','STEP4_CLOB');
  tetools.admin_logger.LOG_ERROR_FORCE(l_tag||'LOG_ERROR_FORCE_BO',l_bool);
  check_row('LOG_ERROR_FORCE_BO','ERROR','TRUE');
  tetools.admin_logger.LOG_ERROR_FORCE(l_tag||'LOG_ERROR_FORCE_DT',l_date);
  check_row('LOG_ERROR_FORCE_DT','ERROR','2026-11-09 00:00:00');
  l_ret:=tetools.admin_logger.LOG_RUNTIME(l_tag||'LOG_RUNTIME_FN','STEP4_FN');
  IF l_ret IS NULL OR l_ret<>1 THEN RAISE_APPLICATION_ERROR(-20403,'Return mismatch LOG_RUNTIME'); END IF;
  check_row('LOG_RUNTIME_FN','RUNTIME','STEP4_FN');
  l_ret:=tetools.admin_logger.LOG_INFO(l_tag||'LOG_INFO_FN','STEP4_FN');
  IF l_ret IS NULL OR l_ret<>1 THEN RAISE_APPLICATION_ERROR(-20403,'Return mismatch LOG_INFO'); END IF;
  check_row('LOG_INFO_FN','INFO','STEP4_FN');
  l_ret:=tetools.admin_logger.LOG_WARNING(l_tag||'LOG_WARNING_FN','STEP4_FN');
  IF l_ret IS NULL OR l_ret<>1 THEN RAISE_APPLICATION_ERROR(-20403,'Return mismatch LOG_WARNING'); END IF;
  check_row('LOG_WARNING_FN','WARNING','STEP4_FN');
  l_ret:=tetools.admin_logger.LOG_ERROR(l_tag||'LOG_ERROR_FN','STEP4_FN');
  IF l_ret IS NULL OR l_ret<>1 THEN RAISE_APPLICATION_ERROR(-20403,'Return mismatch LOG_ERROR'); END IF;
  check_row('LOG_ERROR_FN','ERROR','STEP4_FN');
  l_ret:=tetools.admin_logger.LOG_DEBUG(l_tag||'LOG_DEBUG_FN','STEP4_FN');
  IF l_ret IS NULL OR l_ret<>1 THEN RAISE_APPLICATION_ERROR(-20403,'Return mismatch LOG_DEBUG'); END IF;
  check_row('LOG_DEBUG_FN','DEBUG','STEP4_FN');
  l_ret:=tetools.admin_logger.LOG_RUNTIME_FORCE(l_tag||'LOG_RUNTIME_FORCE_FN','STEP4_FN');
  IF l_ret IS NULL OR l_ret<>1 THEN RAISE_APPLICATION_ERROR(-20403,'Return mismatch LOG_RUNTIME_FORCE'); END IF;
  check_row('LOG_RUNTIME_FORCE_FN','RUNTIME','STEP4_FN');
  l_ret:=tetools.admin_logger.LOG_INFO_FORCE(l_tag||'LOG_INFO_FORCE_FN','STEP4_FN');
  IF l_ret IS NULL OR l_ret<>1 THEN RAISE_APPLICATION_ERROR(-20403,'Return mismatch LOG_INFO_FORCE'); END IF;
  check_row('LOG_INFO_FORCE_FN','INFO','STEP4_FN');
  l_ret:=tetools.admin_logger.LOG_WARNING_FORCE(l_tag||'LOG_WARNING_FORCE_FN','STEP4_FN');
  IF l_ret IS NULL OR l_ret<>1 THEN RAISE_APPLICATION_ERROR(-20403,'Return mismatch LOG_WARNING_FORCE'); END IF;
  check_row('LOG_WARNING_FORCE_FN','WARNING','STEP4_FN');
  l_ret:=tetools.admin_logger.LOG_ERROR_FORCE(l_tag||'LOG_ERROR_FORCE_FN','STEP4_FN');
  IF l_ret IS NULL OR l_ret<>1 THEN RAISE_APPLICATION_ERROR(-20403,'Return mismatch LOG_ERROR_FORCE'); END IF;
  check_row('LOG_ERROR_FORCE_FN','ERROR','STEP4_FN');
  tetools.admin_logger.session_details_revert('RESTORE','S4API'); l_saved:=FALSE;
  DBMS_OUTPUT.PUT_LINE('T04-02 45 LOG overload output/return/default-date assertions passed; C05 failure contract NOT_TESTED');
EXCEPTION WHEN OTHERS THEN
  IF l_saved THEN
    BEGIN tetools.admin_logger.session_details_revert('RESTORE','S4API');
    EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('STOP: config restore failed; DBA reconciliation required'); END;
  END IF;
  RAISE;
END;
/
SPOOL OFF
