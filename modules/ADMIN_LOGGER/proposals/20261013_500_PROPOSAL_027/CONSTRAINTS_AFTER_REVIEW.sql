-- Add only after preserving and resolving preflight conflicts.
-- No automatic deletion or renumbering of historical log rows is supplied.
-- The code accepts old single-mode ID 0 while reading; new saves use SQL NULL.
-- If old single config ID 0 remains, review and normalize it before the CHECK.
ALTER TABLE tetools.admin_logger_sessions ADD CONSTRAINT admin_logger_phys_uk
  UNIQUE (sid,serial#,audsid,logon_user,logon_time);
ALTER TABLE tetools.admin_logger_config ADD CONSTRAINT admin_logger_batch_state_ck
  CHECK ((NVL(batch_mode,'S')='S' AND logbatch_id IS NULL)
      OR (NVL(batch_mode,'S')='B' AND logbatch_id IS NOT NULL AND logbatch_id>0));
CREATE UNIQUE INDEX tetools.admin_logger_active_batch_uk
  ON tetools.admin_logger_config(CASE WHEN batch_mode='B' THEN logbatch_id END);
-- All keys are NULL for single/diagnostic rows, so these rows are not constrained.
CREATE UNIQUE INDEX tetools.admin_logger_position_uk ON tetools.admin_logger_log (
  CASE WHEN logbatch_id>0 AND log_lines>0 THEN logsession_id END,
  CASE WHEN logbatch_id>0 AND log_lines>0 THEN logbatch_id END,
  CASE WHEN logbatch_id>0 AND log_lines>0 THEN log_lines END
);
