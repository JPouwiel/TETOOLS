-- DANGEROUS: NOT AUTOMATED. DO NOT EXECUTE THIS FILE.
-- Destructive cleanup requires DBA-authorized restore/teardown plan, explicit
-- object inventory, approval to DROP in disposable schema, and audit evidence.
PROMPT STOP: use DBA-approved documented teardown/restore procedure, NOT this file.
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
BEGIN RAISE_APPLICATION_ERROR(-20990,'CLEANUP BLOCKED: DBA restore authorization required'); END;
/
