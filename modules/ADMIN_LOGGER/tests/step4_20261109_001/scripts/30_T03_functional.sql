-- PREPARATION ONLY. G09 NOT_GRANTED. Never bypass 00_safety_gate.sql.
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
DEFINE STEP4_CASE_IDS = 'T03-01,T03-03'
DEFINE STEP4_OPERATION = 'TEST'
@@00_safety_gate.sql
SET SERVEROUTPUT ON SIZE UNLIMITED
SET ECHO ON
SET FEEDBACK ON
SET VERIFY OFF
@@00_post_install.sql
DECLARE
  l_batch NUMBER; l_sid NUMBER; l_n NUMBER; l_tag VARCHAR2(128):='S4_&&TEST_RUN_ID._T03_01';
BEGIN
  SELECT COUNT(*) INTO l_n FROM tetools.admin_logger_log WHERE context=l_tag;
  IF l_n<>0 THEN RAISE_APPLICATION_ERROR(-20301,'Run marker already exists'); END IF;
  SELECT tetools.admin_logger_logbatch_seq.NEXTVAL INTO l_batch FROM dual;
  tetools.admin_logger.session_details;
  SELECT s.logsession_id INTO l_sid FROM tetools.admin_logger_sessions s
   WHERE s.sid=tetools.admin_logger.get_invoking_sid AND s.serial#=tetools.admin_logger.get_invoking_serial
     AND s.audsid=tetools.admin_logger.get_audsid(s.sid,s.serial#)
     AND s.logon_time=tetools.admin_logger.get_logon_time(s.sid,s.serial#);
  INSERT INTO tetools.admin_logger_log(created_on,logsession_id,logbatch_id,log_category,log_lines,context,text)
    VALUES(SYSTIMESTAMP,l_sid,l_batch,'INFO',1,l_tag,'first');
  BEGIN
    INSERT INTO tetools.admin_logger_log(created_on,logsession_id,logbatch_id,log_category,log_lines,context,text)
      VALUES(SYSTIMESTAMP,l_sid,l_batch,'INFO',1,l_tag,'duplicate');
    RAISE_APPLICATION_ERROR(-20302,'T03-01 duplicate positive tuple accepted');
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN NULL; END;
  -- Single-position NULL batch metadata is intentionally outside the conditional unique key.
  FOR n IN 1..2 LOOP
    INSERT INTO tetools.admin_logger_log(created_on,logsession_id,log_category,context,text)
      VALUES(SYSTIMESTAMP,l_sid,'INFO',l_tag,'single');
  END LOOP;
  SELECT COUNT(*) INTO l_n FROM tetools.admin_logger_log WHERE context=l_tag;
  IF l_n<>3 THEN RAISE_APPLICATION_ERROR(-20304,'T03-01 wrong accepted count'); END IF;
  ROLLBACK;
  DBMS_OUTPUT.PUT_LINE('T03-01 assertions passed; autonomous initialization retained for DBA cleanup');
  tetools.admin_logger.session_details;
  SELECT COUNT(*) INTO l_n FROM tetools.admin_logger_guard WHERE guard_id=1;
  IF l_n<>1 THEN RAISE_APPLICATION_ERROR(-20303,'T03-03 guard seed invalid'); END IF;
  SELECT COUNT(*) INTO l_n FROM tetools.admin_logger_sessions s JOIN tetools.admin_logger_config c
    ON c.logsession_id=s.logsession_id
   WHERE s.sid=tetools.admin_logger.get_invoking_sid
     AND s.serial#=tetools.admin_logger.get_invoking_serial
     AND s.audsid=tetools.admin_logger.get_audsid(s.sid,s.serial#)
     AND s.logon_time=tetools.admin_logger.get_logon_time(s.sid,s.serial#);
  IF l_n<>1 THEN RAISE_APPLICATION_ERROR(-20305,'T03-03 session/config not one-to-one'); END IF;
  DBMS_OUTPUT.PUT_LINE('T03-03 guard and current session/config assertions passed');
EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE;
END;
/
-- Incident test is T03-02, exclusively in 31_T03_incident.sql.
