CREATE OR REPLACE TRIGGER admin_sessions_log_BRU_trg
BEFORE UPDATE OF termntn_request_status
  on TETOOLS.ADMIN_SESSIONS_LOG
  FOR EACH ROW 

BEGIN

  IF(:OLD.termntn_request_status IN ('K','R','D','T')) THEN
    RAISE_APPLICATION_ERROR(-20000,'Targeted row is locked for future updates.');
  END IF;
  
END;
/