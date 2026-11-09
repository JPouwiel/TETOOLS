-- T04-02 API overload matrix; ONLY after separate execution GO.
-- Based on 20261015_500 SPEC, which is byte-identical in 20261109_501_DEV.
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SET SERVEROUTPUT ON
DECLARE
  l_clob CLOB := TO_CLOB('STEP4_CLOB');
  l_bool BOOLEAN := TRUE;
  l_date DATE := DATE '2026-11-09';
  l_ret PLS_INTEGER;
BEGIN
  -- Five ordinary logging categories: VARCHAR2/CLOB/BOOLEAN/DATE procedure overloads.
  tetools.admin_logger.LOG_RUNTIME('STEP4_T04','varchar2');
  tetools.admin_logger.LOG_RUNTIME('STEP4_T04',l_clob);
  tetools.admin_logger.LOG_RUNTIME('STEP4_T04',l_bool);
  tetools.admin_logger.LOG_RUNTIME('STEP4_T04',l_date);
  tetools.admin_logger.LOG_INFO('STEP4_T04','varchar2');
  tetools.admin_logger.LOG_INFO('STEP4_T04',l_clob);
  tetools.admin_logger.LOG_INFO('STEP4_T04',l_bool);
  tetools.admin_logger.LOG_INFO('STEP4_T04',l_date);
  tetools.admin_logger.LOG_WARNING('STEP4_T04','varchar2');
  tetools.admin_logger.LOG_WARNING('STEP4_T04',l_clob);
  tetools.admin_logger.LOG_WARNING('STEP4_T04',l_bool);
  tetools.admin_logger.LOG_WARNING('STEP4_T04',l_date);
  tetools.admin_logger.LOG_ERROR('STEP4_T04','varchar2');
  tetools.admin_logger.LOG_ERROR('STEP4_T04',l_clob);
  tetools.admin_logger.LOG_ERROR('STEP4_T04',l_bool);
  tetools.admin_logger.LOG_ERROR('STEP4_T04',l_date);
  tetools.admin_logger.LOG_DEBUG('STEP4_T04','varchar2');
  tetools.admin_logger.LOG_DEBUG('STEP4_T04',l_clob);
  tetools.admin_logger.LOG_DEBUG('STEP4_T04',l_bool);
  tetools.admin_logger.LOG_DEBUG('STEP4_T04',l_date);
  -- Four FORCE categories; DEBUG_FORCE does not appear in pinned SPEC.
  tetools.admin_logger.LOG_RUNTIME_FORCE('STEP4_T04','varchar2');
  tetools.admin_logger.LOG_RUNTIME_FORCE('STEP4_T04',l_clob);
  tetools.admin_logger.LOG_RUNTIME_FORCE('STEP4_T04',l_bool);
  tetools.admin_logger.LOG_RUNTIME_FORCE('STEP4_T04',l_date);
  tetools.admin_logger.LOG_INFO_FORCE('STEP4_T04','varchar2');
  tetools.admin_logger.LOG_INFO_FORCE('STEP4_T04',l_clob);
  tetools.admin_logger.LOG_INFO_FORCE('STEP4_T04',l_bool);
  tetools.admin_logger.LOG_INFO_FORCE('STEP4_T04',l_date);
  tetools.admin_logger.LOG_WARNING_FORCE('STEP4_T04','varchar2');
  tetools.admin_logger.LOG_WARNING_FORCE('STEP4_T04',l_clob);
  tetools.admin_logger.LOG_WARNING_FORCE('STEP4_T04',l_bool);
  tetools.admin_logger.LOG_WARNING_FORCE('STEP4_T04',l_date);
  tetools.admin_logger.LOG_ERROR_FORCE('STEP4_T04','varchar2');
  tetools.admin_logger.LOG_ERROR_FORCE('STEP4_T04',l_clob);
  tetools.admin_logger.LOG_ERROR_FORCE('STEP4_T04',l_bool);
  tetools.admin_logger.LOG_ERROR_FORCE('STEP4_T04',l_date);
  -- Nine function overloads (five ordinary, four FORCE), VARCHAR2 only.
  l_ret:=tetools.admin_logger.LOG_RUNTIME('STEP4_T04','function');
  l_ret:=tetools.admin_logger.LOG_INFO('STEP4_T04','function');
  l_ret:=tetools.admin_logger.LOG_WARNING('STEP4_T04','function');
  l_ret:=tetools.admin_logger.LOG_ERROR('STEP4_T04','function');
  l_ret:=tetools.admin_logger.LOG_DEBUG('STEP4_T04','function');
  l_ret:=tetools.admin_logger.LOG_RUNTIME_FORCE('STEP4_T04','function');
  l_ret:=tetools.admin_logger.LOG_INFO_FORCE('STEP4_T04','function');
  l_ret:=tetools.admin_logger.LOG_WARNING_FORCE('STEP4_T04','function');
  l_ret:=tetools.admin_logger.LOG_ERROR_FORCE('STEP4_T04','function');
  DBMS_OUTPUT.PUT_LINE('T04-02 calls completed; actual outputs/targets still require case-by-case verification.');
END;
/
