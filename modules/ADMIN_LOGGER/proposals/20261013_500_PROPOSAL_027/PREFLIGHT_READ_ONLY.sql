-- Read-only review. Do not discard rows to make a query return zero rows.
SELECT sid,serial#,audsid,logon_user,logon_time,COUNT(*) AS registrations
  FROM tetools.admin_logger_sessions
 GROUP BY sid,serial#,audsid,logon_user,logon_time HAVING COUNT(*)>1;
SELECT s.logsession_id FROM tetools.admin_logger_sessions s
 WHERE NOT EXISTS (SELECT 1 FROM tetools.admin_logger_config c
                    WHERE c.logsession_id=s.logsession_id);
SELECT config_id,logsession_id,batch_mode,logbatch_id FROM tetools.admin_logger_config
 WHERE batch_mode='B' AND (logbatch_id IS NULL OR logbatch_id<=0);
SELECT logbatch_id,COUNT(*) AS active_writers FROM tetools.admin_logger_config
 WHERE batch_mode='B' GROUP BY logbatch_id HAVING COUNT(*)>1;
SELECT logsession_id,logbatch_id,log_lines,COUNT(*) AS duplicate_positions
  FROM tetools.admin_logger_log WHERE logbatch_id>0 AND log_lines>0
 GROUP BY logsession_id,logbatch_id,log_lines HAVING COUNT(*)>1;
SELECT config_id,logger_on,logger_target,debug_on,debug_target,batch_mode
  FROM tetools.admin_logger_config
 WHERE logger_on NOT IN ('Y','N') OR logger_on IS NULL
    OR logger_target NOT IN ('S','T') OR logger_target IS NULL
    OR debug_on NOT IN ('Y','N') OR debug_target NOT IN ('S','T')
    OR batch_mode NOT IN ('S','B');
SELECT log_category,logsession_id,logbatch_id,log_lines,logger_id
  FROM tetools.admin_logger_log
 WHERE (logbatch_id IS NOT NULL AND logbatch_id<=0)
    OR (logbatch_id>0 AND (log_lines IS NULL OR log_lines<=0));
-- These single-mode IDs need a preserved, reviewed normalization before the new CHECK.
SELECT config_id,logsession_id,batch_mode,logbatch_id FROM tetools.admin_logger_config
 WHERE NVL(batch_mode,'S')='S' AND logbatch_id IS NOT NULL;
