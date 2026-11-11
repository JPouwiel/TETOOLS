-- PREPARATION ONLY. G09 NOT_GRANTED. Never bypass 00_safety_gate.sql.
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
DEFINE STEP4_CASE_IDS = 'T08-01'
DEFINE STEP4_OPERATION = 'READ'
@@00_safety_gate.sql
SET SERVEROUTPUT ON SIZE UNLIMITED
SET ECHO ON
SET FEEDBACK ON
SET VERIFY OFF
SPOOL &&TEST_RUN_ID._&&TEST_CLIENT_ID._T08_01_evidence.log CREATE
SELECT SYSTIMESTAMP captured_at, SYS_CONTEXT('USERENV','DB_UNIQUE_NAME') db_unique_name,
 SYS_CONTEXT('USERENV','CON_NAME') pdb, SYS_CONTEXT('USERENV','CON_ID') con_id,
 SYS_CONTEXT('USERENV','INSTANCE_NAME') instance_name FROM dual;
SELECT object_name,object_type,status FROM USER_OBJECTS ORDER BY 1,2;
SELECT name,type,line,position,attribute,text FROM USER_ERRORS WHERE name='ADMIN_LOGGER' ORDER BY sequence;
SELECT type,line,text FROM USER_SOURCE WHERE name='ADMIN_LOGGER' ORDER BY type,line;
SELECT constraint_name,constraint_type,status,validated FROM USER_CONSTRAINTS ORDER BY 1;
SELECT index_name,uniqueness,status FROM USER_INDEXES ORDER BY 1;
SPOOL OFF
-- Bundle completeness/offline hashes, approved environment, all case results and restore signature required.
