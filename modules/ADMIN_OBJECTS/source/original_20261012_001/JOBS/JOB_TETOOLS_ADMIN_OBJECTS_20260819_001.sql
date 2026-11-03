

DECLARE
    l_context                 VARCHAR2 (128) := $$PLSQL_UNIT;
	l_user                    varchar2 (128) := USER();
    l_count                   PLS_INTEGER    ;
	v_status                  VARCHAR2 (12)  ;
	v_enable                  BOOLEAN        := FALSE;
	v_module                  VARCHAR2 (32)  := 'ALL';
    v_jobname                 VARCHAR2 (64)  := 'JOB_CATALOG_ADMIN_OBJECTS__'||v_module;
    v_date_format             VARCHAR2 (100) ;
	v_frequency               VARCHAR2 (100) := 'FREQ=WEEKLY; BYDAY=FRI; BYHOUR=21; BYMINUTE=0;';
BEGIN
  --
  IF l_context IS NULL THEN
    l_context := 'ANONYMOUS BLOCK';
  END IF;
  --
  SELECT COUNT(1)
  INTO l_count
  FROM user_scheduler_jobs
  WHERE job_name = v_jobname;
  --
  IF l_count = 0 THEN
    SYS.DBMS_SCHEDULER.CREATE_JOB (
        job_name            => v_jobname,
        job_type            => 'STORED_PROCEDURE',
        job_action          => 'admin_objects.catalog_admin_objects',
        number_of_arguments => 2,
        start_date          => systimestamp,
        repeat_interval     => v_frequency,
        job_class           => '"SYS"."DEFAULT_JOB_CLASS"',
        enabled             => FALSE,
        auto_drop           => FALSE,
        comments            => 'Catalogs all objects of all the ADMIN_xxx module, and stores or updates the record'
	);

    SYS.DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE (
        job_name            => v_jobname,
        argument_position   => 1,
        argument_value      => v_module
	);

    SYS.DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE (
        job_name            => v_jobname,
        argument_position   => 2,
        argument_value      => v_jobname
	);
	--
    IF v_enable THEN
      v_status := 'ENABLED';
      SYS.DBMS_SCHEDULER.enable (name => v_jobname);
    ELSE
      v_status := 'DISABLED';
    END IF;
    --
    COMMIT;
	--
    DBMS_OUTPUT.PUT_LINE('Job '||v_jobname||' created with status '||v_status||'.');
    tetools.admin_logger.log_runtime (l_context, l_user||' has created job '||v_jobname||' with status '||v_status||' and frequency: '||v_frequency||'.');
  ELSE
    --
    DBMS_OUTPUT.PUT_LINE('Job '||v_jobname||' already exists!');
    tetools.admin_logger.log_runtime (l_context, l_user||' tried to create job '||v_jobname||'; job already exists. Execution cancelled.');
  END IF;
END;
/



DECLARE
    l_context                 VARCHAR2 (128) := $$PLSQL_UNIT;
	l_user                    varchar2 (128) := USER();
    l_count                   PLS_INTEGER    ;
	v_status                  VARCHAR2 (12)  ;
	v_enable                  BOOLEAN        := TRUE;
	v_module                  VARCHAR2 (32)  := 'ADMIN_OBJECTS';
    v_jobname                 VARCHAR2 (64)  := 'JOB_CATALOG_ADMIN_OBJECTS__'||v_module;
    v_date_format             VARCHAR2 (100) ;
	v_frequency               VARCHAR2 (100) := 'FREQ=WEEKLY; BYDAY=FRI; BYHOUR=21; BYMINUTE=0;';
BEGIN
  --
  IF l_context IS NULL THEN
    l_context := 'ANONYMOUS BLOCK';
  END IF;
  --
  SELECT COUNT(1)
  INTO l_count
  FROM user_scheduler_jobs
  WHERE job_name = v_jobname;
  --
  IF l_count = 0 THEN
    SYS.DBMS_SCHEDULER.CREATE_JOB (
        job_name            => v_jobname,
        job_type            => 'STORED_PROCEDURE',
        job_action          => 'admin_objects.catalog_admin_objects',
        number_of_arguments => 2,
        start_date          => systimestamp,
        repeat_interval     => v_frequency,
        job_class           => '"SYS"."DEFAULT_JOB_CLASS"',
        enabled             => FALSE,
        auto_drop           => FALSE,
        comments            => 'Catalogs all objects of the '||v_module||' module, and stores or updates the record'
	);

    SYS.DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE (
        job_name            => v_jobname,
        argument_position   => 1,
        argument_value      => v_module
	);

    SYS.DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE (
        job_name            => v_jobname,
        argument_position   => 2,
        argument_value      => v_jobname
	);
	--
    IF v_enable THEN
      v_status := 'ENABLED';
      SYS.DBMS_SCHEDULER.enable (name => v_jobname);
    ELSE
      v_status := 'DISABLED';
    END IF;
    --
    COMMIT;
	--
    DBMS_OUTPUT.PUT_LINE('Job '||v_jobname||' created with status '||v_status||'.');
    tetools.admin_logger.log_runtime (l_context, l_user||' has created job '||v_jobname||' with status '||v_status||' and frequency: '||v_frequency||'.');
  ELSE
    --
    DBMS_OUTPUT.PUT_LINE('Job '||v_jobname||' already exists!');
    tetools.admin_logger.log_runtime (l_context, l_user||' tried to create job '||v_jobname||'; job already exists. Execution cancelled.');
  END IF;
END;
/



DECLARE
    l_context                 VARCHAR2 (128) := $$PLSQL_UNIT;
	l_user                    varchar2 (128) := USER();
    l_count                   PLS_INTEGER    ;
	v_status                  VARCHAR2 (12)  ;
	v_enable                  BOOLEAN        := FALSE;
	v_module                  VARCHAR2 (32)  := 'ADMIN_TNSNAMES';
    v_jobname                 VARCHAR2 (64)  := 'JOB_CATALOG_ADMIN_OBJECTS__'||v_module;
    v_date_format             VARCHAR2 (100) ;
	v_frequency               VARCHAR2 (100) := 'FREQ=WEEKLY; BYDAY=FRI; BYHOUR=21; BYMINUTE=0;';
BEGIN
  --
  IF l_context IS NULL THEN
    l_context := 'ANONYMOUS BLOCK';
  END IF;
  --
  SELECT COUNT(1)
  INTO l_count
  FROM user_scheduler_jobs
  WHERE job_name = v_jobname;
  --
  IF l_count = 0 THEN
    SYS.DBMS_SCHEDULER.CREATE_JOB (
        job_name            => v_jobname,
        job_type            => 'STORED_PROCEDURE',
        job_action          => 'admin_objects.catalog_admin_objects',
        number_of_arguments => 2,
        start_date          => systimestamp,
        repeat_interval     => v_frequency,
        job_class           => '"SYS"."DEFAULT_JOB_CLASS"',
        enabled             => FALSE,
        auto_drop           => FALSE,
        comments            => 'Catalogs all objects of the '||v_module||' module, and stores or updates the record'
	);

    SYS.DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE (
        job_name            => v_jobname,
        argument_position   => 1,
        argument_value      => v_module
	);

    SYS.DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE (
        job_name            => v_jobname,
        argument_position   => 2,
        argument_value      => v_jobname
	);
	--
    IF v_enable THEN
      v_status := 'ENABLED';
      SYS.DBMS_SCHEDULER.enable (name => v_jobname);
    ELSE
      v_status := 'DISABLED';
    END IF;
    --
    COMMIT;
	--
    DBMS_OUTPUT.PUT_LINE('Job '||v_jobname||' created with status '||v_status||'.');
    tetools.admin_logger.log_runtime (l_context, l_user||' has created job '||v_jobname||' with status '||v_status||' and frequency: '||v_frequency||'.');
  ELSE
    --
    DBMS_OUTPUT.PUT_LINE('Job '||v_jobname||' already exists!');
    tetools.admin_logger.log_runtime (l_context, l_user||' tried to create job '||v_jobname||'; job already exists. Execution cancelled.');
  END IF;
END;
/



DECLARE
    l_context                 VARCHAR2 (128) := $$PLSQL_UNIT;
	l_user                    varchar2 (128) := USER();
    l_count                   PLS_INTEGER    ;
	v_status                  VARCHAR2 (12)  ;
	v_enable                  BOOLEAN        := FALSE;
	v_module                  VARCHAR2 (32)  := 'ADMIN_SESSION';
    v_jobname                 VARCHAR2 (64)  := 'JOB_CATALOG_ADMIN_OBJECTS__'||v_module;
    v_date_format             VARCHAR2 (100) ;
	v_frequency               VARCHAR2 (100) := 'FREQ=WEEKLY; BYDAY=FRI; BYHOUR=21; BYMINUTE=0;';
BEGIN
  --
  IF l_context IS NULL THEN
    l_context := 'ANONYMOUS BLOCK';
  END IF;
  --
  SELECT COUNT(1)
  INTO l_count
  FROM user_scheduler_jobs
  WHERE job_name = v_jobname;
  --
  IF l_count = 0 THEN
    SYS.DBMS_SCHEDULER.CREATE_JOB (
        job_name            => v_jobname,
        job_type            => 'STORED_PROCEDURE',
        job_action          => 'admin_objects.catalog_admin_objects',
        number_of_arguments => 2,
        start_date          => systimestamp,
        repeat_interval     => v_frequency,
        job_class           => '"SYS"."DEFAULT_JOB_CLASS"',
        enabled             => FALSE,
        auto_drop           => FALSE,
        comments            => 'Catalogs all objects of the '||v_module||' module, and stores or updates the record'
	);

    SYS.DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE (
        job_name            => v_jobname,
        argument_position   => 1,
        argument_value      => v_module
	);

    SYS.DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE (
        job_name            => v_jobname,
        argument_position   => 2,
        argument_value      => v_jobname
	);
	--
    IF v_enable THEN
      v_status := 'ENABLED';
      SYS.DBMS_SCHEDULER.enable (name => v_jobname);
    ELSE
      v_status := 'DISABLED';
    END IF;
    --
    COMMIT;
	--
    DBMS_OUTPUT.PUT_LINE('Job '||v_jobname||' created with status '||v_status||'.');
    tetools.admin_logger.log_runtime (l_context, l_user||' has created job '||v_jobname||' with status '||v_status||' and frequency: '||v_frequency||'.');
  ELSE
    --
    DBMS_OUTPUT.PUT_LINE('Job '||v_jobname||' already exists!');
    tetools.admin_logger.log_runtime (l_context, l_user||' tried to create job '||v_jobname||'; job already exists. Execution cancelled.');
  END IF;
END;
/



DECLARE
    l_context                 VARCHAR2 (128) := $$PLSQL_UNIT;
	l_user                    varchar2 (128) := USER();
    l_count                   PLS_INTEGER    ;
	v_status                  VARCHAR2 (12)  ;
	v_enable                  BOOLEAN        := FALSE;
	v_module                  VARCHAR2 (32)  := 'ADMIN_MONITOR';
    v_jobname                 VARCHAR2 (64)  := 'JOB_CATALOG_ADMIN_OBJECTS__'||v_module;
    v_date_format             VARCHAR2 (100) ;
	v_frequency               VARCHAR2 (100) := 'FREQ=WEEKLY; BYDAY=FRI; BYHOUR=21; BYMINUTE=0;';
BEGIN
  --
  IF l_context IS NULL THEN
    l_context := 'ANONYMOUS BLOCK';
  END IF;
  --
  SELECT COUNT(1)
  INTO l_count
  FROM user_scheduler_jobs
  WHERE job_name = v_jobname;
  --
  IF l_count = 0 THEN
    SYS.DBMS_SCHEDULER.CREATE_JOB (
        job_name            => v_jobname,
        job_type            => 'STORED_PROCEDURE',
        job_action          => 'admin_objects.catalog_admin_objects',
        number_of_arguments => 2,
        start_date          => systimestamp,
        repeat_interval     => v_frequency,
        job_class           => '"SYS"."DEFAULT_JOB_CLASS"',
        enabled             => FALSE,
        auto_drop           => FALSE,
        comments            => 'Catalogs all objects of the '||v_module||' module, and stores or updates the record'
	);

    SYS.DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE (
        job_name            => v_jobname,
        argument_position   => 1,
        argument_value      => v_module
	);

    SYS.DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE (
        job_name            => v_jobname,
        argument_position   => 2,
        argument_value      => v_jobname
	);
	--
    IF v_enable THEN
      v_status := 'ENABLED';
      SYS.DBMS_SCHEDULER.enable (name => v_jobname);
    ELSE
      v_status := 'DISABLED';
    END IF;
    --
    COMMIT;
	--
    DBMS_OUTPUT.PUT_LINE('Job '||v_jobname||' created with status '||v_status||'.');
    tetools.admin_logger.log_runtime (l_context, l_user||' has created job '||v_jobname||' with status '||v_status||' and frequency: '||v_frequency||'.');
  ELSE
    --
    DBMS_OUTPUT.PUT_LINE('Job '||v_jobname||' already exists!');
    tetools.admin_logger.log_runtime (l_context, l_user||' tried to create job '||v_jobname||'; job already exists. Execution cancelled.');
  END IF;
END;
/



DECLARE
    l_context                 VARCHAR2 (128) := $$PLSQL_UNIT;
	l_user                    varchar2 (128) := USER();
    l_count                   PLS_INTEGER    ;
	v_status                  VARCHAR2 (12)  ;
	v_enable                  BOOLEAN        := FALSE;
	v_module                  VARCHAR2 (32)  := 'ADMIN_REFRESH';
    v_jobname                 VARCHAR2 (64)  := 'JOB_CATALOG_ADMIN_OBJECTS__'||v_module;
    v_date_format             VARCHAR2 (100) ;
	v_frequency               VARCHAR2 (100) := 'FREQ=WEEKLY; BYDAY=FRI; BYHOUR=21; BYMINUTE=0;';
BEGIN
  --
  IF l_context IS NULL THEN
    l_context := 'ANONYMOUS BLOCK';
  END IF;
  --
  SELECT COUNT(1)
  INTO l_count
  FROM user_scheduler_jobs
  WHERE job_name = v_jobname;
  --
  IF l_count = 0 THEN
    SYS.DBMS_SCHEDULER.CREATE_JOB (
        job_name            => v_jobname,
        job_type            => 'STORED_PROCEDURE',
        job_action          => 'admin_objects.catalog_admin_objects',
        number_of_arguments => 2,
        start_date          => systimestamp,
        repeat_interval     => v_frequency,
        job_class           => '"SYS"."DEFAULT_JOB_CLASS"',
        enabled             => FALSE,
        auto_drop           => FALSE,
        comments            => 'Catalogs all objects of the '||v_module||' module, and stores or updates the record'
	);

    SYS.DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE (
        job_name            => v_jobname,
        argument_position   => 1,
        argument_value      => v_module
	);

    SYS.DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE (
        job_name            => v_jobname,
        argument_position   => 2,
        argument_value      => v_jobname
	);
	--
    IF v_enable THEN
      v_status := 'ENABLED';
      SYS.DBMS_SCHEDULER.enable (name => v_jobname);
    ELSE
      v_status := 'DISABLED';
    END IF;
    --
    COMMIT;
	--
    DBMS_OUTPUT.PUT_LINE('Job '||v_jobname||' created with status '||v_status||'.');
    tetools.admin_logger.log_runtime (l_context, l_user||' has created job '||v_jobname||' with status '||v_status||' and frequency: '||v_frequency||'.');
  ELSE
    --
    DBMS_OUTPUT.PUT_LINE('Job '||v_jobname||' already exists!');
    tetools.admin_logger.log_runtime (l_context, l_user||' tried to create job '||v_jobname||'; job already exists. Execution cancelled.');
  END IF;
END;
/


