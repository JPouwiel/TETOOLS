-- T04 API smoke: source signatures are pinned in SPEC; no package changes.
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SET SERVEROUTPUT ON
BEGIN
  tetools.admin_logger.version;
  tetools.admin_logger.help('N');
  tetools.admin_logger.LOG_INFO('STEP4_T04','info overload VARCHAR2');
  tetools.admin_logger.LOG_WARNING('STEP4_T04','warning overload VARCHAR2');
  tetools.admin_logger.LOG_RUNTIME('STEP4_T04','runtime overload VARCHAR2');
  tetools.admin_logger.LOG_ERROR('STEP4_T04','error overload VARCHAR2');
  tetools.admin_logger.LOG_DEBUG('STEP4_T04','debug overload VARCHAR2');
  DBMS_OUTPUT.PUT_LINE('T04 smoke completed; inspect target/output and contract expected behavior separately');
END;
/
-- FORCE, CLOB/BOOLEAN/DATE/function overloads, toggle_*, clear_* and
-- session_details_revert require individual controlled cases per casebook;
-- DO NOT invoke clear_* or revert blindly in shared schema.
