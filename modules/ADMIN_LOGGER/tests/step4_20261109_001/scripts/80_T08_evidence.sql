-- T08 read-only evidence snapshot, not test acceptance by itself.
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SET SERVEROUTPUT ON
SELECT SYS_CONTEXT('USERENV','DB_UNIQUE_NAME') db_unique_name,
       SYS_CONTEXT('USERENV','CON_NAME') pdb,
       SYS_CONTEXT('USERENV','CON_ID') con_id,
       SYS_CONTEXT('USERENV','INSTANCE_NAME') instance_name FROM dual;
SELECT object_name,object_type,status FROM USER_OBJECTS WHERE object_name LIKE 'ADMIN_LOGGER%' ORDER BY 1,2;
SELECT name,type,line,position,text FROM USER_ERRORS WHERE name='ADMIN_LOGGER' ORDER BY sequence;
-- Attach independently collected per-case expected/actual, evidence, approvals,
-- snapshot/restore proof and DBA signoff. Never infer PASS from empty output.
