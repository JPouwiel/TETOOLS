-- T05 observational owner-side privilege evidence. Separate negative user session mandatory.
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SET SERVEROUTPUT ON
SELECT object_name,authid FROM USER_PROCEDURES WHERE object_name='ADMIN_LOGGER' AND procedure_name IS NULL;
SELECT privilege,table_name,grantor FROM USER_TAB_PRIVS_RECD ORDER BY table_name,privilege;
-- T05 C01..C06 are transaction/exception scenarios in casebook, requiring
-- approved business fixture, failure injection, caller principal and proof.
-- No source-code alteration is authorized by this preparation.
