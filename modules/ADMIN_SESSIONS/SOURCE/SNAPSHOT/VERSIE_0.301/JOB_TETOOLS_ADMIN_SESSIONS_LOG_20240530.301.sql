DECLARE
  l_count PLS_INTEGER;
  l_job_name user_scheduler_jobs.job_name%TYPE := 'ADMIN_SESSIONS_EXPIRE_JOB';
BEGIN
  
  SELECT COUNT(1)
  INTO l_count
  FROM user_scheduler_jobs
  WHERE job_name = l_job_name;
  
  IF l_count = 0 THEN
    DBMS_SCHEDULER.CREATE_JOB(
       job_name => l_job_name,
       job_type => 'PLSQL_BLOCK',
       job_action => 'begin ADMIN_SESSIONS.expire; end; ',
       start_date => systimestamp,
       repeat_interval => 'FREQ=DAILY; BYHOUR=1',
       enabled => TRUE,
       comments => 'Epires ADMIN_SESSIONS termination requests using default values defined in ADMIN_SESSIONS_PREFS.');
  END IF;
END;
/


DECLARE
  l_count PLS_INTEGER;
  l_job_name user_scheduler_jobs.job_name%TYPE := 'ADMIN_SESSIONS_GRACE_JOB';
BEGIN
  
  SELECT COUNT(1)
  INTO l_count
  FROM user_scheduler_jobs
  WHERE job_name = l_job_name;
  
  IF l_count = 0 THEN
    DBMS_SCHEDULER.CREATE_JOB(
       job_name => l_job_name,
       job_type => 'PLSQL_BLOCK',
       job_action => 'begin ADMIN_SESSIONS.grace; end; ',
       start_date => systimestamp,
       repeat_interval => 'FREQ=DAILY; BYHOUR=1',
       enabled => TRUE,
       comments => 'Sets ADMIN_SESSIONS termination requests in grace period using default values defined in ADMIN_SESSIONS_PREFS.');
  END IF;
END;
/
