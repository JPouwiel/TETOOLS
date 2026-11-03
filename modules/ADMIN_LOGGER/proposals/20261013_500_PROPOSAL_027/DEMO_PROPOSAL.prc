CREATE OR REPLACE PROCEDURE tetools.admin_logger_demo
IS
  l_context VARCHAR2(128):='ADMIN_LOGGER_DEMO';
BEGIN
  tetools.admin_logger.toggle_logging('ON','T');
  tetools.admin_logger.toggle_batch('ON','BATCH');
  tetools.admin_logger.log_info(l_context,'First demonstration row');
  tetools.admin_logger.log_runtime(l_context,'Second demonstration row');
  tetools.admin_logger.toggle_batch('OFF');
  tetools.admin_logger.toggle_logging('OFF','T');
EXCEPTION WHEN OTHERS THEN
  -- Propagate the error. This optional demo is not part of required installation.
  RAISE;
END admin_logger_demo;
/
