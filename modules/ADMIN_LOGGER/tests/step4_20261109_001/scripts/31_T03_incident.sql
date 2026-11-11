-- PREPARATION ONLY. G09 NOT_GRANTED. Never bypass 00_safety_gate.sql.
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
DEFINE STEP4_CASE_IDS = 'T03-02'
DEFINE STEP4_OPERATION = 'READ'
@@00_safety_gate.sql
SET SERVEROUTPUT ON SIZE UNLIMITED
SET ECHO ON
SET FEEDBACK ON
SET VERIFY OFF
@@00_post_install.sql
-- No explicit assignment to a GENERATED ALWAYS identity; no production identity ALTER.
DECLARE l_n NUMBER;
BEGIN
  SELECT COUNT(*) INTO l_n FROM USER_CONSTRAINTS c JOIN USER_CONS_COLUMNS cc
    ON c.constraint_name=cc.constraint_name AND c.table_name=cc.table_name
   WHERE c.table_name='ADMIN_LOGGER_INCIDENT' AND c.constraint_name='ADMIN_LOGGER_INCIDENT_PK'
     AND c.constraint_type='P' AND c.status='ENABLED' AND c.validated='VALIDATED'
     AND cc.column_name='INCIDENT_ID' AND cc.position=1;
  IF l_n<>1 THEN RAISE_APPLICATION_ERROR(-20320,'Incident PK metadata mismatch'); END IF;
  SELECT COUNT(*) INTO l_n FROM USER_TAB_IDENTITY_COLS
   WHERE table_name='ADMIN_LOGGER_INCIDENT' AND column_name='INCIDENT_ID' AND generation_type='ALWAYS';
  IF l_n<>1 THEN RAISE_APPLICATION_ERROR(-20321,'Expected ALWAYS identity'); END IF;
  DBMS_OUTPUT.PUT_LINE('T03-02 METADATA_ONLY; duplicate-PK runtime case remains BLOCKED');
END;
/
-- See fixtures.md: separate typed clone design, never count clone/identity rejection as real PK PASS.
