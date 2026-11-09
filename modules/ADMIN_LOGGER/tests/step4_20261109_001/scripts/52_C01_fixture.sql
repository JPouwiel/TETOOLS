-- PREPARATION ONLY. G09 NOT_GRANTED. Never bypass 00_safety_gate.sql.
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
DEFINE STEP4_CASE_IDS = 'T05-02'
DEFINE STEP4_OPERATION = 'FIXTURE'
@@00_safety_gate.sql
SET SERVEROUTPUT ON SIZE UNLIMITED
SET ECHO ON
SET FEEDBACK ON
SET VERIFY OFF
-- Separate fixture-DDL approval required; run after installation, before business transaction.
-- Must not exist; no DROP/replace/rerun. DDL commits implicitly.
DECLARE l_n NUMBER;
BEGIN
  SELECT COUNT(*) INTO l_n FROM USER_OBJECTS WHERE object_name='STEP4_BUSINESS_FIXTURE';
  IF l_n<>0 THEN RAISE_APPLICATION_ERROR(-20520,'Fixture already exists; stop for DBA inventory'); END IF;
END;
/
CREATE TABLE tetools.step4_business_fixture (
  run_id VARCHAR2(48) NOT NULL,
  CONSTRAINT step4_business_fixture_pk PRIMARY KEY(run_id)
);
