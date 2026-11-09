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
SPOOL &&TEST_RUN_ID._&&TEST_CLIENT_ID._T06_01_B_timeout.log CREATE
DECLARE
  e_wait_timeout EXCEPTION; PRAGMA EXCEPTION_INIT(e_wait_timeout,-30006);
  l_start TIMESTAMP WITH TIME ZONE:=SYSTIMESTAMP; l_elapsed INTERVAL DAY TO SECOND;
  c_upper_seconds CONSTANT NUMBER := NULL; -- DBA-approved timing bound in future reviewed artifact only.
  l_n NUMBER;
BEGIN
  IF c_upper_seconds IS NULL OR c_upper_seconds<5 THEN
    RAISE_APPLICATION_ERROR(-20603,'BLOCKED: DBA-approved upper timing bound not supplied');
  END IF;
  BEGIN
    SELECT guard_id INTO l_n FROM tetools.admin_logger_guard WHERE guard_id=1 FOR UPDATE WAIT 5;
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20601,'FAIL: lock unexpectedly acquired while A must hold');
  EXCEPTION WHEN e_wait_timeout THEN
    l_elapsed:=SYSTIMESTAMP-l_start;
    ROLLBACK;
    -- Lower bound proves WAIT behavior; upper bound/resource watchdog set by DBA, see procedures.md.
    IF l_elapsed < NUMTODSINTERVAL(4,'SECOND') OR l_elapsed>NUMTODSINTERVAL(c_upper_seconds,'SECOND') THEN
      RAISE_APPLICATION_ERROR(-20602,'Timeout outside approved timing window');
    END IF;
    DBMS_OUTPUT.PUT_LINE('EXPECTED_TIMEOUT elapsed='||TO_CHAR(l_elapsed));
  END;
EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE;
END;
/
SPOOL OFF
-- This is TIMEOUT_PHASE only; T06-01 cannot PASS until 63/64 release/reacquire evidence.
