-- PREPARATION ONLY. G09 NOT_GRANTED. Never bypass 00_safety_gate.sql.
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
DEFINE STEP4_CASE_IDS = 'T05-01'
DEFINE STEP4_OPERATION = 'READ'
@@00_safety_gate.sql
SET SERVEROUTPUT ON SIZE UNLIMITED
SET ECHO ON
SET FEEDBACK ON
SET VERIFY OFF
@@00_post_install.sql
DECLARE l_n NUMBER;
BEGIN
  SELECT COUNT(*) INTO l_n FROM USER_PROCEDURES
   WHERE object_name='ADMIN_LOGGER' AND procedure_name IS NULL AND authid='DEFINER';
  IF l_n<>1 THEN RAISE_APPLICATION_ERROR(-20500,'Expected AUTHID DEFINER package'); END IF;
END;
/
SELECT owner,table_name,privilege,grantor FROM USER_TAB_PRIVS_RECD ORDER BY owner,table_name,privilege;
SELECT name,type,referenced_owner,referenced_name,referenced_type FROM USER_DEPENDENCIES
WHERE name='ADMIN_LOGGER' ORDER BY 1,2,3,4;
-- Separate principals and DBA ALL_/DBA_ owner-filtered queries: privileges.md/procedures.md.
-- Owner-side evidence alone never passes consumer/maintenance authorization.
