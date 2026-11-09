-- PREPARATION ONLY. G09 NOT_GRANTED. Never bypass 00_safety_gate.sql.
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
DEFINE STEP4_CASE_IDS = 'T02-01,T02-02'
DEFINE STEP4_OPERATION = 'READ'
@@00_safety_gate.sql
SET SERVEROUTPUT ON SIZE UNLIMITED
SET ECHO ON
SET FEEDBACK ON
SET VERIFY OFF
@@00_post_install.sql
DECLARE l_n NUMBER;
BEGIN
  SELECT COUNT(*) INTO l_n FROM USER_ERRORS WHERE name='ADMIN_LOGGER';
  IF l_n<>0 THEN RAISE_APPLICATION_ERROR(-20102,'Compile errors/warnings require classification; no PASS'); END IF;
  SELECT COUNT(*) INTO l_n FROM USER_INDEXES
   WHERE index_name IN ('ADMIN_LOGGER_POSITION_UK','ADMIN_LOGGER_ACTIVE_BATCH_UK')
     AND uniqueness='UNIQUE' AND status='VALID';
  IF l_n<>2 THEN RAISE_APPLICATION_ERROR(-20103,'Expected unique indexes not VALID'); END IF;
  SELECT COUNT(*) INTO l_n FROM USER_CONSTRAINTS
   WHERE constraint_name IN ('ADMIN_LOGGER_INCIDENT_PK','ADMIN_LOGGER_GUARD_PK')
     AND constraint_type='P' AND status='ENABLED' AND validated='VALIDATED';
  IF l_n<>2 THEN RAISE_APPLICATION_ERROR(-20104,'Expected PKs not enabled/validated'); END IF;
  DBMS_OUTPUT.PUT_LINE('T02-01 object assertions passed; installation spool/source exports still required');
END;
/
SELECT name,type,line,position,attribute,text FROM USER_ERRORS WHERE name='ADMIN_LOGGER' ORDER BY sequence;
SELECT name,type,referenced_owner,referenced_name,referenced_type
FROM USER_DEPENDENCIES WHERE name='ADMIN_LOGGER' ORDER BY 1,2,3,4;
SELECT object_name,object_type,status FROM USER_OBJECTS ORDER BY 1,2;
