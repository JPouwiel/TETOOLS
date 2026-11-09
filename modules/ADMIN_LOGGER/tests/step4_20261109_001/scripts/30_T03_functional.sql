-- T03-01/02/03 disposable schema only. DML rollback does not undo autonomous logger work.
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SET SERVEROUTPUT ON
DECLARE l_sid NUMBER; l_batch NUMBER:=987654321; l_cnt NUMBER;
BEGIN
  -- FK to session is not declared for ADMIN_LOGGER_LOG; use a unique isolated marker.
  SELECT COUNT(*) INTO l_cnt FROM tetools.admin_logger_log WHERE logbatch_id=l_batch;
  IF l_cnt<>0 THEN RAISE_APPLICATION_ERROR(-20301,'T03 data collision'); END IF;
  INSERT INTO tetools.admin_logger_log(created_on,logsession_id,logbatch_id,log_category,log_lines,context,text)
  VALUES (SYSTIMESTAMP,987654321,l_batch,'INFO',1,'STEP4_T03','unique-position');
  BEGIN
    INSERT INTO tetools.admin_logger_log(created_on,logsession_id,logbatch_id,log_category,log_lines,context,text)
    VALUES (SYSTIMESTAMP,987654321,l_batch,'INFO',1,'STEP4_T03','duplicate');
    RAISE_APPLICATION_ERROR(-20302,'FAIL: duplicate position accepted');
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN DBMS_OUTPUT.PUT_LINE('T03-01 PASS duplicate rejected'); END;
  SELECT COUNT(*) INTO l_cnt FROM tetools.admin_logger_guard WHERE guard_id=1;
  IF l_cnt<>1 THEN RAISE_APPLICATION_ERROR(-20303,'guard seed invalid'); END IF;
  DBMS_OUTPUT.PUT_LINE('T03-02 PASS guard row=1');
  ROLLBACK;
END;
/
-- T03-03 incident PK negative test: requires valid NOT NULL incident fixture.
-- See casebook; no fabricated incident session identity is inserted here.
