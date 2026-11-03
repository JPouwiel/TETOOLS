
DECLARE
  fatal_error              EXCEPTION;        PRAGMA EXCEPTION_INIT (fatal_error             , -20001);
  generic_error            EXCEPTION;        PRAGMA EXCEPTION_INIT (generic_error           , -20002);
  idx_internal_check       EXCEPTION;        PRAGMA EXCEPTION_INIT (idx_internal_check      , -20003);
  param_file_dest_exists   INTEGER        := 0;
  user_exists              INTEGER        := 0;
  tblspce_dat_exists       INTEGER        := 0;
  tblspce_idx_exists       INTEGER        := 0;
  tblspce_tmp_exists       INTEGER        := 0;
  role_rbac_exists         INTEGER        := 0;
  iterator                 INTEGER        := 1;
  tblspce_dat              VARCHAR2(32)   := 'TETOOLS_DAT_01';
  tblspce_idx              VARCHAR2(32)   := 'TETOOLS_IDX_01';
  tblspce_tmp              VARCHAR2(32)   := 'CHANGE_TO_TBLSPC';
  use_tblspce_tmp_cnt      INTEGER        ;
  use_tblspce_tmp          VARCHAR2(32)   ;
  user_name                VARCHAR2(24)   := 'TETOOLS';
  user_passwd              VARCHAR2(128)  := NULL /* REDACTED FOR GIT: supply an approved secret at installation time */;
  rbac_role                VARCHAR2(32)   := 'TETOOLS_ADMIN_LOGGER_EXEC_R';
  chk_role_exists          VARCHAR2(4000) := 'SELECT COUNT(ROLE) FROM DBA_ROLES WHERE ROLE = :1';
  chk_usr_exists           VARCHAR2(4000) := 'SELECT COUNT(USERNAME) AS "PRESENT" FROM DBA_USERS WHERE USERNAME = :1';
  chk_tablspce_usr         VARCHAR2(4000) := 'SELECT COUNT(TABLESPACE_NAME) AS "PRESENT" FROM DBA_TABLESPACES WHERE TABLESPACE_NAME = :1';
  chk_tablspce_tmp         VARCHAR2(4000) := 'SELECT TEMPORARY_TABLESPACE, COUNT(*) FROM DBA_USERS GROUP BY TEMPORARY_TABLESPACE ORDER BY 2 DESC FETCH FIRST 1 ROW ONLY';
  cr8_role_rbac            VARCHAR2(4000) := 'CREATE ROLE TETOOLS_ADMIN_LOGGER_EXEC_R';
  cr8_tblspce_dat          VARCHAR2(4000) := 'CREATE TABLESPACE :1 DATAFILE SIZE 400MB AUTOEXTEND ON MAXSIZE UNLIMITED';
  cr8_tblspce_idx          VARCHAR2(4000) := 'CREATE TABLESPACE :1 DATAFILE SIZE 400MB AUTOEXTEND ON MAXSIZE UNLIMITED';
  cr8_user                 VARCHAR2(4000) := 'CREATE USER :1 IDENTIFIED BY :2 DEFAULT_TABLESPACE :3 TEMPORARY TABLESPACE :4 PROFILE DEFAULT';
  alter_user               VARCHAR2(4000) := 'ALTER USER :1 QUOTA UNLIMITED ON :2';
  param_file_dest          VARCHAR2(4000) := 'SELECT COUNT(value) AS "RESENT" FROM v$parameter WHERE name =''db_create_file_dest''';
  p_continue               CHAR(1)        ;
  v_rowname                VARCHAR2(64)   ;
  v_tabstop                VARCHAR2(50)   := ''||CHR(9)||'';
  --
  CURSOR c_grants IS
    WITH cte_grants AS (
    SELECT 'aq_admin_role'             AS NAME, 'grant AQ_ADMINISTRATOR_ROLE to tetools'                         AS STATEMENT FROM DUAL UNION ALL
    SELECT 'connect'                   AS NAME, 'grant CONNECT to tetools'                                       AS STATEMENT FROM DUAL UNION ALL
    SELECT 'audit_admin'               AS NAME, 'grant AUDIT_ADMIN to tetools'                                   AS STATEMENT FROM DUAL UNION ALL
    SELECT 'any_table'                 AS NAME, 'grant ANY_TABLE to tetools'                                     AS STATEMENT FROM DUAL UNION ALL
    SELECT 'dictionary'                AS NAME, 'grant DICTIONARY to tetools'                                    AS STATEMENT FROM DUAL UNION ALL
    SELECT 'sqlt_user_role'            AS NAME, 'grant SQLT_USER_ROLE to tetools'                                AS STATEMENT FROM DUAL UNION ALL
    SELECT 'admin_logger_exec_r'       AS NAME, 'grant TETOOLS_ADMIN_LOGGER_EXEC_R to tetools WITH ADMIN OPTION' AS STATEMENT FROM DUAL UNION ALL
    SELECT 'create_job'                AS NAME, 'grant CREATE JOB to tetools'                                    AS STATEMENT FROM DUAL UNION ALL
    SELECT 'adm_any_tuning_set'        AS NAME, 'grant ADMINISTER ANY SQL TUNING SET to tetools'                 AS STATEMENT FROM DUAL UNION ALL
    SELECT 'create_type'               AS NAME, 'grant CREATE TYPE to tetools'                                   AS STATEMENT FROM DUAL UNION ALL
    SELECT 'create_procedure'          AS NAME, 'grant CREATE PROCEDURE to tetools'                              AS STATEMENT FROM DUAL UNION ALL
    SELECT 'advisor'                   AS NAME, 'grant ADVISOR to tetools'                                       AS STATEMENT FROM DUAL UNION ALL
    SELECT 'create_mview'              AS NAME, 'grant CREATE MATERIALIZED VIEW to tetools'                      AS STATEMENT FROM DUAL UNION ALL
    SELECT 'create_view'               AS NAME, 'grant CREATE VIEW to tetools'                                   AS STATEMENT FROM DUAL UNION ALL
    SELECT 'alter_system'              AS NAME, 'grant ALTER SYSTEM to tetools WITH ADMIN OPTION'                AS STATEMENT FROM DUAL UNION ALL
    SELECT 'create_table'              AS NAME, 'grant CREATE TABLE to tetools'                                  AS STATEMENT FROM DUAL UNION ALL
    SELECT 'adm_sql_mng_object'        AS NAME, 'grant ADMINISTER SQL MANAGEMENT OBJECT to tetools'              AS STATEMENT FROM DUAL UNION ALL
    SELECT 'create_trigger'            AS NAME, 'grant CREATE TRIGGER to tetools'                                AS STATEMENT FROM DUAL UNION ALL
    SELECT 'select_any_sequence'       AS NAME, 'grant SELECT ANY SEQUENCE to tetools'                           AS STATEMENT FROM DUAL UNION ALL
    SELECT 'create_any_sequence'       AS NAME, 'grant CREATE ANY SEQUENCE to tetools'                           AS STATEMENT FROM DUAL UNION ALL
    SELECT 'tablespace'                AS NAME, 'grant UNLIMITED TABLESPACE to tetools'                          AS STATEMENT FROM DUAL UNION ALL
    SELECT 'v_session'                 AS NAME, 'grant SELECT on SYS.V_$SESSION to tetools'                      AS STATEMENT FROM DUAL UNION ALL
    SELECT 'gv_bufpool_stats'          AS NAME, 'grant SELECT on SYS.GV_$BUFFER_POOL_STATISTICS to tetools'      AS STATEMENT FROM DUAL UNION ALL
    SELECT 'gv_log'                    AS NAME, 'grant SELECT on SYS.GV_$LOG to tetools'                         AS STATEMENT FROM DUAL UNION ALL
    SELECT 'gv_process'                AS NAME, 'grant SELECT on SYS.GV_$PROCESS to tetools'                     AS STATEMENT FROM DUAL UNION ALL
    SELECT 'gv_session'                AS NAME, 'grant SELECT on SYS.GV_$SESSION to tetools'                     AS STATEMENT FROM DUAL UNION ALL
    SELECT 'gv_sysstat'                AS NAME, 'grant SELECT on SYS.GV_$SYSSTAT to tetools'                     AS STATEMENT FROM DUAL UNION ALL
    SELECT 'gv_logfile'                AS NAME, 'grant SELECT on SYS.GV_$LOGFILE to tetools'                     AS STATEMENT FROM DUAL UNION ALL
    SELECT 'gv_parameter'              AS NAME, 'grant SELECT on SYS.GV_$PARAMETER to tetools'                   AS STATEMENT FROM DUAL UNION ALL
    SELECT 'gv_rowcache'               AS NAME, 'grant SELECT on SYS.GV_$ROWCACHE to tetools'                    AS STATEMENT FROM DUAL UNION ALL
    SELECT 'gv_libr-cache'             AS NAME, 'grant SELECT on SYS.GV_$LIBRARYCACHE to tetools'                AS STATEMENT FROM DUAL UNION ALL
    SELECT 'gv_database'               AS NAME, 'grant SELECT on SYS.GV_$DATABASE to tetools'                    AS STATEMENT FROM DUAL UNION ALL
    SELECT 'gv_instance'               AS NAME, 'grant SELECT on SYS.GV_$INSTANCE to tetools'                    AS STATEMENT FROM DUAL UNION ALL
    SELECT 'gv_sql'                    AS NAME, 'grant SELECT on SYS.GV_$SQL to tetools'                         AS STATEMENT FROM DUAL UNION ALL
    SELECT 'gv_bck_datafile'           AS NAME, 'grant SELECT on SYS.GV_$BACKUP_DATAFILE to tetools'             AS STATEMENT FROM DUAL UNION ALL
    SELECT 'gv_diag_info'              AS NAME, 'grant SELECT on SYS.GV_$DIAG_INFO to tetools'                   AS STATEMENT FROM DUAL UNION ALL
    SELECT 'gv_pdbs'                   AS NAME, 'grant SELECT on SYS.GV_$PDBS to tetools'                        AS STATEMENT FROM DUAL UNION ALL
    SELECT 'gv_containers'             AS NAME, 'grant SELECT on SYS.GV_$CONTAINERS to tetools'                  AS STATEMENT FROM DUAL UNION ALL
    SELECT 'dba_tables'                AS NAME, 'grant SELECT on SYS.DBA_TABLES to tetools'                      AS STATEMENT FROM DUAL UNION ALL
    SELECT 'cdb_tables'                AS NAME, 'grant SELECT on SYS.CDB_TABLES to tetools'                      AS STATEMENT FROM DUAL UNION ALL
    SELECT 'cdb_objects'               AS NAME, 'grant SELECT on SYS.CDB_OBJECTS to tetools'                     AS STATEMENT FROM DUAL UNION ALL
    SELECT 'cdb_indexes'               AS NAME, 'grant SELECT on SYS.CDB_INDEXES to tetools'                     AS STATEMENT FROM DUAL UNION ALL
    SELECT 'cdb_lobs'                  AS NAME, 'grant SELECT on SYS.CDB_LOBS to tetools'                        AS STATEMENT FROM DUAL UNION ALL
    SELECT 'dba_role_privs'            AS NAME, 'grant SELECT on SYS.DBA_ROLE_PRIVS to tetools'                  AS STATEMENT FROM DUAL UNION ALL
    SELECT 'cdb_role_privs'            AS NAME, 'grant SELECT on SYS.CDB_ROLE_PRIVS to tetools'                  AS STATEMENT FROM DUAL UNION ALL
    SELECT 'cdb_tab_comments'          AS NAME, 'grant SELECT on SYS.CDB_TAB_COMMENTS to tetools'                AS STATEMENT FROM DUAL UNION ALL
    SELECT 'dba_users'                 AS NAME, 'grant SELECT on SYS.DBA_USERS to tetools'                       AS STATEMENT FROM DUAL UNION ALL
    SELECT 'cdb_users'                 AS NAME, 'grant SELECT on SYS.CDB_USERS to tetools'                       AS STATEMENT FROM DUAL UNION ALL
    SELECT 'cdb_audit_trail'           AS NAME, 'grant SELECT on SYS.CDB_AUDIT_TRAIL to tetools'                 AS STATEMENT FROM DUAL UNION ALL
    SELECT 'dba_source'                AS NAME, 'grant SELECT on SYS.DBA_SOURCE to tetools'                      AS STATEMENT FROM DUAL UNION ALL
    SELECT 'cdb_source'                AS NAME, 'grant SELECT on SYS.CDB_SOURCE to tetools'                      AS STATEMENT FROM DUAL UNION ALL
    SELECT 'cdb_segments'              AS NAME, 'grant SELECT on SYS.CDB_SEGMENTS to tetools'                    AS STATEMENT FROM DUAL UNION ALL
    SELECT 'cdb_free_space'            AS NAME, 'grant SELECT on SYS.CDB_FREE_SPACE to tetools'                  AS STATEMENT FROM DUAL UNION ALL
    SELECT 'cdb_data_files'            AS NAME, 'grant SELECT on SYS.CDB_DATA_FILES to tetools'                  AS STATEMENT FROM DUAL UNION ALL
    SELECT 'cdb_registry'              AS NAME, 'grant SELECT on SYS.CDB_REGISTRY to tetools'                    AS STATEMENT FROM DUAL UNION ALL
    SELECT 'cdb_sql_profiles'          AS NAME, 'grant SELECT on SYS.CDB_SQL_PROFILES to tetools'                AS STATEMENT FROM DUAL UNION ALL
    SELECT 'cdb_hist_sqltext'          AS NAME, 'grant SELECT on SYS.CDB_HIST_SQLTEXT to tetools'                AS STATEMENT FROM DUAL UNION ALL
    SELECT 'cdb_hist_sql_plan'         AS NAME, 'grant SELECT on SYS.CDB_HIST_SQL_PLAN to tetools'               AS STATEMENT FROM DUAL UNION ALL
    SELECT 'cdb_sched_jobs'            AS NAME, 'grant SELECT on SYS.CDB_SCHEDULER_JOBS to tetools'              AS STATEMENT FROM DUAL UNION ALL
    SELECT 'cdb_sched_jr_det'          AS NAME, 'grant SELECT on SYS.CDB_SCHEDULER_JOB_RUN_DETAILS to tetools'   AS STATEMENT FROM DUAL UNION ALL
    SELECT 'cdb_autotask_op'           AS NAME, 'grant SELECT on SYS.CDB_AUTOTASK_OPERATION to tetools'          AS STATEMENT FROM DUAL UNION ALL
    SELECT 'exec_utl_raw'              AS NAME, 'grant EXECUTE on SYS.UTL_RAW to tetools'                        AS STATEMENT FROM DUAL UNION ALL
    SELECT 'exec_dbms_lob'             AS NAME, 'grant EXECUTE on SYS.DBMS_LOB to tetools'                       AS STATEMENT FROM DUAL UNION ALL
    SELECT 'exec_dbms_random'          AS NAME, 'grant EXECUTE on SYS.DBMS_RANDOM to tetools'                    AS STATEMENT FROM DUAL UNION ALL
    SELECT 'exec_dbms_aq_bqview'       AS NAME, 'grant EXECUTE on SYS.DBMS_AQ_BQVIEW to tetools'                 AS STATEMENT FROM DUAL)
    SELECT NAME, STATEMENT FROM cte_grants;
  --  
  TYPE rec_privilege_validation
  IS
  RECORD ( name              VARCHAR2(64),
           owner             VARCHAR2(32),
           object            VARCHAR2(32),
           obj_type          VARCHAR2(64),
           privilege         VARCHAR2(64),
           priv_type         VARCHAR2(4),
           priv_option       CHAR(1),
           executed          CHAR(1),
           feedback          CHAR(1),
           severity          INTEGER
  );
  --
  TYPE var_excval
  IS
  VARRAY(80) OF rec_privilege_validation;
  --
  y   var_excval :=    var_excval
        ( rec_privilege_validation('idx_internal_check',  'SYSTEM',  'SYSTEM', 'TYPE',                          'INTERNAL_CHECK',  'TAB',  'N', 'N', 'X', 9)
		, rec_privilege_validation('tablespace',          'SYSTEM',  'SYSTEM', 'TABLESPACE',                    'UNLIMITED QUOTA', 'SYS',  'N', 'N', 'X', 8)  -- index 1
        , rec_privilege_validation('create_any_sequence', 'SYSTEM',  'OBJECT', 'SEQUENCE',                      'CREATE ANY',      'SYS',  'N', 'N', 'X', 8)  -- index 2
        , rec_privilege_validation('select_any_sequence', 'SYSTEM',  'OBJECT', 'SEQUENCE',                      'SELECT ANY',      'SYS',  'N', 'N', 'X', 8)  -- index 3
        , rec_privilege_validation('create_trigger',      'TETOOLS', 'OBJECT', 'TRIGGER',                       'CREATE',          'TAB',  'N', 'N', 'X', 8)  -- index 4
        , rec_privilege_validation('adm_sql_mng_object',  'SYSTEM',  'SYSTEM', 'SQL MANAGEMENT',                'ADMINISTER',      'SYS',  'N', 'N', 'X', 2)  -- index 5
        , rec_privilege_validation('create_table',        'TETOOLS', 'OBJECT', 'TABLE',                         'CREATE',          'TAB',  'N', 'N', 'X', 8)  -- index 6
        , rec_privilege_validation('alter_system',        'SYSTEM',  'SYSTEM', 'SYSTEM',                        'ALTER SYSTEM',    'SYS',  'Y', 'N', 'X', 5)  -- index 7
        , rec_privilege_validation('create_view',         'TETOOLS', 'OBJECT', 'VIEW',                          'CREATE',          'TAB',  'N', 'N', 'X', 8)  -- index 8
        , rec_privilege_validation('create_mview',        'TETOOLS', 'OBJECT', 'MVIEW',                         'CREATE',          'TAB',  'N', 'N', 'X', 8)  -- index 9
        , rec_privilege_validation('advisor',             'SYSTEM',  'SYSTEM', 'SYSTEM',                        'ADVISOR',         'SYS',  'N', 'N', 'X', 3)  -- index 10
		, rec_privilege_validation('create_procedure',    'SYSTEM',  'OBJECT', 'PROCEDURE',                     'CREATE',          'SYS',  'N', 'N', 'X', 8)  -- index 11
		, rec_privilege_validation('create_type',         'SYSTEM',  'OBJECT', 'TYPE',                          'CREATE',          'SYS',  'N', 'N', 'X', 8)  -- index 12
		, rec_privilege_validation('adm_any_tuning_set',  'SYSTEM',  'SYSTEM', 'TUNING SET',                    'ADMINISTER',      'SYS',  'N', 'N', 'X', 2)  -- index 13
		, rec_privilege_validation('create_job',          'TETOOLS', 'OBJECT', 'JOB',                           'CREATE',          'SYS',  'N', 'N', 'X', 8)  -- index 14
		, rec_privilege_validation('admin_logger_exec_r', 'SYSTEM',  'ROLE',   'ROLE',                          'ROLE',            'ROLE', 'N', 'N', 'X', 8)  -- index 15
		, rec_privilege_validation('sqlt_user_role',      'SYSTEM',  'ROLE',   'PLAN',                          'EXPLAIN',         'ROLE', 'N', 'N', 'X', 3)  -- index 16
		, rec_privilege_validation('dictionary',          'SYSTEM',  'SYSTEM', 'DICTIONARY',                    'SELECT',          'ROLE', 'N', 'N', 'X', 8)  -- index 17
		, rec_privilege_validation('any_table',           'SYSTEM',  'SYSTEM', 'TABLES',                        'SELECT',          'ROLE', 'N', 'N', 'X', 8)  -- index 18
		, rec_privilege_validation('audit_admin',         'SYSTEM',  'SYSTEM', 'AUDIT',                         'AUDIT',           'ROLE', 'N', 'N', 'X', 3)  -- index 19
		, rec_privilege_validation('connect',             'SYSTEM',  'SYSTEM', 'CONNECT',                       'CONNECT',         'ROLE', 'N', 'N', 'X', 8)  -- index 20
		, rec_privilege_validation('aq_admin_role',       'SYSTEM',  'SYSTEM', 'QUEUEING',                      'ADMINISTER',      'ROLE', 'N', 'N', 'X', 3)  -- index 21
		, rec_privilege_validation('exec_utl_raw',        'SYSTEM',  'OBJECT', 'UTL_RAW',                       'EXECUTE',         'TAB',  'N', 'N', 'X', 8)  -- index 22
		, rec_privilege_validation('exec_dbms_lob',       'SYSTEM',  'OBJECT', 'DBMS_LOB',                      'EXECUTE',         'TAB',  'N', 'N', 'X', 8)  -- index 23
		, rec_privilege_validation('exec_dbms_random',    'SYSTEM',  'OBJECT', 'DBMS_RANDOM',                   'EXECUTE',         'TAB',  'N', 'N', 'X', 8)  -- index 24
		, rec_privilege_validation('exec_dbms_aq_bqview', 'SYSTEM',  'OBJECT', 'DBMS_AQ_BQVIEW',                'EXECUTE',         'TAB',  'N', 'N', 'X', 3)  -- index 25
		, rec_privilege_validation('cdb_autotask_op',     'SYSTEM',  'OBJECT', 'CDB_AUTOTASK_OPERATION',        'SELECT',          'TAB',  'Y', 'N', 'X', 2)  -- index 26
		, rec_privilege_validation('cdb_sched_jr_det',    'SYSTEM',  'OBJECT', 'CDB_SCHEDULER_JOB_RUN_DETAILS', 'SELECT',          'TAB',  'Y', 'N', 'X', 8)  -- index 27
		, rec_privilege_validation('cdb_sched_jobs',      'SYSTEM',  'OBJECT', 'CDB_SCHEDULER_JOBS',            'SELECT',          'TAB',  'Y', 'N', 'X', 8)  -- index 28
		, rec_privilege_validation('cdb_hist_sql_plan',   'SYSTEM',  'OBJECT', 'CDB_HIST_SQL_PLAN',             'SELECT',          'TAB',  'Y', 'N', 'X', 2)  -- index 29
		, rec_privilege_validation('cdb_hist_sqltext',    'SYSTEM',  'OBJECT', 'CDB_HIST_SQLTEXT',              'SELECT',          'TAB',  'Y', 'N', 'X', 2)  -- index 30
		, rec_privilege_validation('cdb_sql_profiles',    'SYSTEM',  'OBJECT', 'CDB_SQL_PROFILES',              'SELECT',          'TAB',  'Y', 'N', 'X', 2)  -- index 31
		, rec_privilege_validation('cdb_registry',        'SYSTEM',  'OBJECT', 'CDB_REGISTRY',                  'SELECT',          'TAB',  'Y', 'N', 'X', 8)  -- index 32
		, rec_privilege_validation('cdb_data_files',      'SYSTEM',  'OBJECT', 'CDB_DATA_FILES',                'SELECT',          'TAB',  'Y', 'N', 'X', 8)  -- index 33
		, rec_privilege_validation('cdb_free_space',      'SYSTEM',  'OBJECT', 'CDB_FREE_SPACE',                'SELECT',          'TAB',  'Y', 'N', 'X', 8)  -- index 34
		, rec_privilege_validation('cdb_segments',        'SYSTEM',  'OBJECT', 'CDB_SEGMENTS',                  'SELECT',          'TAB',  'Y', 'N', 'X', 8)  -- index 35
		, rec_privilege_validation('cdb_source',          'SYSTEM',  'OBJECT', 'CDB_SOURCE',                    'SELECT',          'TAB',  'Y', 'N', 'X', 8)  -- index 36
		, rec_privilege_validation('dba_source',          'SYSTEM',  'OBJECT', 'DBA_SOURCE',                    'SELECT',          'TAB',  'Y', 'N', 'X', 8)  -- index 37
		, rec_privilege_validation('cdb_audit_trail',     'SYSTEM',  'OBJECT', 'CDB_AUDIT_TRAIL',               'SELECT',          'TAB',  'Y', 'N', 'X', 2)  -- index 38
		, rec_privilege_validation('cdb_users',           'SYSTEM',  'OBJECT', 'CDB_USERS',                     'SELECT',          'TAB',  'Y', 'N', 'X', 8)  -- index 39
		, rec_privilege_validation('dba_users',           'SYSTEM',  'OBJECT', 'DBA_USERS',                     'SELECT',          'TAB',  'Y', 'N', 'X', 8)  -- index 40
		, rec_privilege_validation('cdb_tab_comments',    'SYSTEM',  'OBJECT', 'CDB_TAB_COMMENTS',              'SELECT',          'TAB',  'Y', 'N', 'X', 8)  -- index 41
		, rec_privilege_validation('cdb_role_privs',      'SYSTEM',  'OBJECT', 'CDB_ROLE_PRIVS',                'SELECT',          'TAB',  'Y', 'N', 'X', 8)  -- index 42
		, rec_privilege_validation('dba_role_privs',      'SYSTEM',  'OBJECT', 'DBA_ROLE_PRIVS',                'SELECT',          'TAB',  'Y', 'N', 'X', 8)  -- index 43
		, rec_privilege_validation('cdb_lobs',            'SYSTEM',  'OBJECT', 'CDB_LOBS',                      'SELECT',          'TAB',  'Y', 'N', 'X', 8)  -- index 44
		, rec_privilege_validation('cdb_indexes',         'SYSTEM',  'OBJECT', 'CDB_INDEXES',                   'SELECT',          'TAB',  'Y', 'N', 'X', 8)  -- index 45
		, rec_privilege_validation('cdb_objects',         'SYSTEM',  'OBJECT', 'CDB_OBJECTS',                   'SELECT',          'TAB',  'Y', 'N', 'X', 8)  -- index 46
		, rec_privilege_validation('cdb_tables',          'SYSTEM',  'OBJECT', 'CDB_TABLES',                    'SELECT',          'TAB',  'Y', 'N', 'X', 8)  -- index 47
		, rec_privilege_validation('dba_tables',          'SYSTEM',  'OBJECT', 'DBA_TABLES',                    'SELECT',          'TAB',  'Y', 'N', 'X', 8)  -- index 48
		, rec_privilege_validation('gv_containers',       'SYSTEM',  'OBJECT', 'GV_$CONTAINERS',                'SELECT',          'TAB',  'Y', 'N', 'X', 8)  -- index 49
		, rec_privilege_validation('gv_pdbs',             'SYSTEM',  'OBJECT', 'GV_$PDBS',                      'SELECT',          'TAB',  'Y', 'N', 'X', 8)  -- index 50
		, rec_privilege_validation('gv_diag_info',        'SYSTEM',  'OBJECT', 'GV_$DIAG_INFO',                 'SELECT',          'TAB',  'Y', 'N', 'X', 2)  -- index 51
		, rec_privilege_validation('gv_bck_datafile',     'SYSTEM',  'OBJECT', 'GV_$BACKUP_DATAFILE',           'SELECT',          'TAB',  'Y', 'N', 'X', 2)  -- index 52
		, rec_privilege_validation('gv_sql',              'SYSTEM',  'OBJECT', 'GV_$SQL',                       'SELECT',          'TAB',  'Y', 'N', 'X', 2)  -- index 53
		, rec_privilege_validation('gv_instance',         'SYSTEM',  'OBJECT', 'GV_$INSTANCE',                  'SELECT',          'TAB',  'Y', 'N', 'X', 2)  -- index 54
		, rec_privilege_validation('gv_database',         'SYSTEM',  'OBJECT', 'GV_$DATABASE',                  'SELECT',          'TAB',  'Y', 'N', 'X', 2)  -- index 55
		, rec_privilege_validation('gv_libr-cache',       'SYSTEM',  'OBJECT', 'GV_$LIBRARYCACHE',              'SELECT',          'TAB',  'Y', 'N', 'X', 2)  -- index 56
		, rec_privilege_validation('gv_rowcache',         'SYSTEM',  'OBJECT', 'GV_$ROWCACHE',                  'SELECT',          'TAB',  'Y', 'N', 'X', 2)  -- index 57
		, rec_privilege_validation('gv_parameter',        'SYSTEM',  'OBJECT', 'GV_$PARAMETER',                 'SELECT',          'TAB',  'Y', 'N', 'X', 8)  -- index 58
		, rec_privilege_validation('gv_logfile',          'SYSTEM',  'OBJECT', 'GV_$LOGFILE',                   'SELECT',          'TAB',  'Y', 'N', 'X', 2)  -- index 59
		, rec_privilege_validation('gv_sysstat',          'SYSTEM',  'OBJECT', 'GV_$SYSSTAT',                   'SELECT',          'TAB',  'Y', 'N', 'X', 2)  -- index 60
		, rec_privilege_validation('gv_session',          'SYSTEM',  'OBJECT', 'GV_$SESSION',                   'SELECT',          'TAB',  'Y', 'N', 'X', 8)  -- index 61
		, rec_privilege_validation('gv_process',          'SYSTEM',  'OBJECT', 'GV_$PROCESS',                   'SELECT',          'TAB',  'Y', 'N', 'X', 8)  -- index 62
		, rec_privilege_validation('gv_log',              'SYSTEM',  'OBJECT', 'GV_$LOG',                       'SELECT',          'TAB',  'Y', 'N', 'X', 2)  -- index 63
		, rec_privilege_validation('gv_bufpool_stats',    'SYSTEM',  'OBJECT', 'GV_$BUFFER_POOL_STATISTICS',    'SELECT',          'TAB',  'Y', 'N', 'X', 2)  -- index 64
		, rec_privilege_validation('v_session',           'SYSTEM',  'OBJECT', 'V_$SESSION',                    'SELECT',          'TAB',  'Y', 'N', 'X', 8)  -- index 65
        , rec_privilege_validation('continue',            'SYSTEM',  'SYSTEM', 'OBJECT',                        'EXECUTE',         'ROLE', 'Y', 'X', 'X', 9)  -- index 66
  );
  --
  PROCEDURE put_line (data_in IN VARCHAR2) IS 
  BEGIN 
     DBMS_OUTPUT.put_line (data_in); 
  END put_line;
  --
  -- /* function idx allows a lookup for the index value in the varray based on a value                               COMMENT */
  FUNCTION idx(p_idx VARCHAR2) RETURN PLS_INTEGER AS
  BEGIN
    FOR i IN 1..y.LAST
      LOOP
        IF (y(i).name = p_idx) THEN RETURN i;
        END IF;
      END LOOP;
    RETURN 0;
  END idx;
  --
  PROCEDURE checkmark(p_idx IN INTEGER, p_executed IN CHAR DEFAULT 'Y', p_feedback  IN CHAR DEFAULT 'Y') AS
  BEGIN
    IF y(p_idx).name = 'idx_internal_check'                                                THEN
      RAISE idx_internal_check;
    END IF;
    --
    --IF (y(p_idx).feedback = 'Y' OR y(p_idx).feedback = 'X')                                                     THEN
    --   y(idx('continue')).executed := 'Y';
    --   y(p_idx).executed           := 'Y';
    --   y(p_idx).feedback           :=  p_val;
    --   --
    --   IF y(idx('continue')).feedback = 'Y' AND p_val = 'N' AND y(p_idx).severity > 3                           THEN
    --     y(idx('continue')).feedback  := 'N';
    --   END IF;
    --END IF;
	--
	IF    ( y(p_idx).executed = 'N' OR y(p_idx).executed = 'X' ) AND p_executed = 'Y' THEN
	  y(p_idx).executed := p_executed;
	  y(p_idx).feedback := p_feedback;
	ELSIF ( y(p_idx).executed = 'N' OR y(p_idx).executed = 'X' ) AND p_executed = 'N' THEN
	  IF    p_feedback = 'E' THEN
	    y(p_idx).executed := p_executed;
	    y(p_idx).feedback := p_feedback;
	  END IF;
	ELSIF y(p_idx).executed = 'Y' THEN
	  put_line(y(p_idx).name||' has already been checked and processed.'||CHR(10)||'Feedback: '||y(p_idx).feedback||' has not been set in this instance.');
	END IF;
	--
	IF    ( y(idx('continue')).feedback = 'Y' OR y(idx('continue')).feedback = 'X' ) AND p_feedback = 'Y' THEN
	  y(idx('continue')).executed := 'Y';
	  y(idx('continue')).feedback := 'Y';
	ELSIF ( y(idx('continue')).feedback = 'Y' OR y(idx('continue')).feedback = 'X' ) AND ( p_feedback != 'Y' AND y(p_idx).severity > 3 ) THEN
	  y(idx('continue')).executed := 'Y';
	  y(idx('continue')).feedback := 'N';
	END IF;
	--
  END checkmark;
  --
  PROCEDURE raise_sev(p_idx IN INTEGER, p_sev IN CHAR, p_exec IN CHAR, p_feed IN CHAR) AS
  BEGIN
    IF y(p_idx).name = 'idx_internal_check'                                                                     THEN
      RAISE idx_internal_check;
    END IF;
    --
    y(p_idx).severity           :=  p_sev;
    checkmark(p_idx, p_exec, p_feed);
    --
  END raise_sev;
  --
  -- /* function result returns the results of the checkmarks                               COMMENT */
  PROCEDURE result_checkmarks (p_idx IN INTEGER DEFAULT NULL) IS
  BEGIN
    IF p_idx IS NOT NULL THEN
	  IF NOT ( y(p_idx).name = 'continue' OR y(p_idx).name = 'idx_internal_check' ) THEN
	    put_line(v_tabstop||'Grant ' || RPAD(y(p_idx).name, 20, ' ') || ' on ' || RPAD(y(p_idx).owner, 14, ' ') || ' of object_type ' || RPAD(y(p_idx).obj_type, 14, ' ') || ' was ' || RPAD(CASE y(p_idx).executed WHEN 'N' THEN 'NOT ' WHEN 'X' THEN 'NOT KNOWN TO BE ' ELSE NULL END || 'EXECUTED' || CASE y(p_idx).priv_option WHEN 'Y' THEN ' WITH ADMIN/GRANT OPTION' ELSE NULL END, 36, ' ') ||'; FEEDBACK status is: ' || CASE y(p_idx).feedback WHEN 'E' THEN 'Error' WHEN 'Y' THEN 'Success' ELSE 'Unknown' END);
	  END IF;
	ELSE
      FOR i IN 1..y.LAST
        LOOP
		  IF NOT ( y(i).name = 'continue' OR y(i).name = 'idx_internal_check' ) THEN
            IF ( y(i).feedback != 'Y' OR y(i).executed != 'Y' ) THEN
	  	      put_line(v_tabstop||'Grant ' || RPAD(y(i).name, 20, ' ') || ' was ' || RPAD(CASE y(i).executed WHEN 'N' THEN 'NOT ' WHEN 'X' THEN 'NOT ' WHEN 'Y' THEN 'INDEED ' ELSE NULL END || 'EXECUTED' || CASE y(i).priv_option WHEN 'Y' THEN ' WITH ADMIN/GRANT OPTION' ELSE NULL END, 36, ' ') ||'; FEEDBACK status is: ' || CASE y(i).feedback WHEN 'E' THEN 'Error' WHEN 'Y' THEN 'Success' ELSE 'Unknown' END);
            END IF;
		  END IF;
        END LOOP;
	END IF;
  END result_checkmarks;
  --
BEGIN
  --
  put_line('###### INSTALLATION STARTED @ '||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS')||RPAD(' ', 158, '#'));
  put_line('#### CREATION OF USER '||user_name);
  put_line('##'||CHR(10)||'## STARTING CHECKS');
  --
  -- CHECK IF PARAMETER db_create_file_dest IS SET
  EXECUTE IMMEDIATE param_file_dest INTO param_file_dest_exists; put_line(v_tabstop||'Parameter db_create_file_dest is '||CASE param_file_dest_exists WHEN 0 THEN 'NOT ' ELSE NULL END||'set on this database.');
  IF param_file_dest_exists = 0 THEN
    put_line(v_tabstop||'This script is incompatible with this system, the tablespaces need be created by hand.');
    put_line(v_tabstop||'Exiting installation.');
	RAISE fatal_error;
  END IF;
  --
  -- CHECK IF USER TETOOLS EXISTS
  EXECUTE IMMEDIATE chk_usr_exists INTO user_exists USING IN user_name; put_line(v_tabstop||'Found '||user_exists||' occurence(s) of user: '||user_name);
  --
  -- CHECK IF RBAC ROLE EXISTS
  EXECUTE IMMEDIATE chk_role_exists INTO role_rbac_exists USING IN rbac_role; put_line(v_tabstop||'Found '||role_rbac_exists||' occurence(s) of role: '||rbac_role);
  --
  -- CHECK WHAT THE MOST USED TEMPORARY TABLESPACE CONFIGURED IS, AND USED THAT IF NOT SET IN DECLARATION
  IF tblspce_tmp = 'CHANGE_TO_TBLSPC' THEN
    EXECUTE IMMEDIATE chk_tablspce_tmp INTO use_tblspce_tmp, use_tblspce_tmp_cnt;
    tblspce_tmp_exists := 1;
  ELSIF tblspce_tmp != 'CHANGE_TO_TBLSPC' THEN
    use_tblspce_tmp    := tblspce_tmp;
    tblspce_tmp_exists := 1;
  END IF;
  put_line(v_tabstop||'TEMPORARY tablespace set to: '||use_tblspce_tmp);
  --
  -- CHECK WHETHER THE USER TABLESPACES ALREADY EXISTS
  EXECUTE IMMEDIATE chk_tablspce_usr INTO tblspce_dat_exists USING IN tblspce_dat; put_line(v_tabstop||'Found '||tblspce_dat_exists||' occurence(s) of '||tblspce_dat||' tablespace.');
  EXECUTE IMMEDIATE chk_tablspce_usr INTO tblspce_idx_exists USING IN tblspce_idx; put_line(v_tabstop||'Found '||tblspce_idx_exists||' occurence(s) of '||tblspce_idx||' tablespace.');
  --
  put_line('##'||CHR(10)||'## INSTALLING COMPONENTENTS'||CHR(10)||'#');
  IF user_exists = 0 OR role_rbac_exists = 0 OR tblspce_dat_exists = 0 OR tblspce_idx = 0 THEN put_line('# THE FOLLOWING COMPONENTENTS WILL BE CREATED'||CHR(10));   END IF;
  IF user_exists = 0                                                                      THEN put_line(v_tabstop||'User '||user_name||' will be created.');         END IF;
  IF role_rbac_exists = 0                                                                 THEN put_line(v_tabstop||'Role '||rbac_role||' will be created.');         END IF;
  IF tblspce_dat_exists = 0                                                               THEN put_line(v_tabstop||'Tablespace '||tblspce_dat||' will be created.'); END IF;
  IF tblspce_idx_exists = 0                                                               THEN put_line(v_tabstop||'Tablespace '||tblspce_idx||' will be created.'); END IF;
  IF user_exists = 0 OR role_rbac_exists = 0 OR tblspce_dat_exists = 0 OR tblspce_idx = 0 THEN put_line('#'||CHR(10));                                               END IF;
  --
  -- LET's START BUILDING THE user
  BEGIN
    -- START WITH THE TABLESPACES
	IF tblspce_dat_exists = 0 OR tblspce_idx_exists = 0 THEN put_line('# START BUILDING THE TABLESPACES'); END IF;
    IF tblspce_dat_exists = 0 THEN --EXECUTE IMMEDIATE cr8_tblspce_dat USING IN tblspce_dat; put_line('Tablespace: '||tblspce_dat||' created.'); END IF;
	  put_line(v_tabstop||'Tablespace: '||tblspce_dat||' created.');
	END IF;
	IF tblspce_idx_exists = 0 THEN --EXECUTE IMMEDIATE cr8_tblspce_idx USING IN tblspce_idx; put_line('Tablespace: '||tblspce_idx||' created.'); END IF;
	  put_line(v_tabstop||'Tablespace: '||tblspce_idx||' created.');
	END IF;
	-- CREATE THE RBAC ROLE IF NECESSARY
	IF role_rbac_exists = 0 THEN put_line(CHR(10)||'# START CREATING THE RBAC ROLE'); END IF;
	IF role_rbac_exists = 0 THEN --EXECUTE IMMEDIATE cr8_role_rbac; put_line('role '||rbac_role||' created.'); END IF;
	  put_line(v_tabstop||'role '||rbac_role||' created.');
	END IF;
	-- CREATE THE USER IF NECESSARY
	IF user_exists = 0 THEN put_line(CHR(10)||'# START CREATING THE USER'); END IF;
    IF user_exists = 0        THEN
	  --EXECUTE IMMEDIATE cr8_user        USING IN user_name, user_passwd, tblspce_dat, use_tblspce_tmp; put_line('User '||user_name||' created.');
	  --EXECUTE IMMEDIATE alter_user      USING IN user_name, tblspce_dat; put_line('User '||user_name||' altered quota on tablespace '||tblspce_dat||'.');
	  --EXECUTE IMMEDIATE alter_user      USING IN user_name, tblspce_idx; put_line('User '||user_name||' altered quota on tablespace '||tblspce_idx||'.');
	  put_line(v_tabstop||'User '||user_name||' created.');
	  put_line(v_tabstop||'User '||user_name||' altered quota on tablespace '||tblspce_dat||'.');
	  put_line(v_tabstop||'User '||user_name||' altered quota on tablespace '||tblspce_idx||'.');
	END IF;
	--
    put_line('##'||CHR(10)||'## GRANTING PRIVILEGES'||CHR(10)||'##');
	put_line('# A total of '||y.count||' privileges will be given to '||user_name);
	put_line('# IF ANY GRANTS WILL FAIL, THERE ARE SHOWN BELOW AT EXECUTION TIME:'||CHR(10)||'#');
    --
    -- GRANT PRIVILEGES TO user
	FOR r_row IN c_grants
    LOOP
	  BEGIN
	    --DBMS_OUTPUT.PUT_LINE('R_ROW: '||iterator||'. Name: '||r_row.name);
		v_rowname := r_row.name;
		IF v_rowname = 'connect' THEN
		  put_line(v_tabstop||'The following error is deliberate, remove from code!');
		  RAISE generic_error;
		END IF;
		--
		IF v_rowname != 'continue' THEN
		  checkmark(idx(v_rowname));
		  --checkmark(idx('continue'), 'N', 'Y');
		  iterator := iterator + 1;
		END IF;
      EXCEPTION
       WHEN NO_DATA_FOUND THEN
            /* HAndle an error that gets raised when a query returns nothing */
            --put_line(v_tabstop||'ERROR: NO_DATA_FOUND for: '||r_row.name);
			result_checkmarks(idx(v_rowname));
		    checkmark(idx(v_rowname), 'N', 'E');
		    --checkmark(idx('continue'), 'Y', 'N');
            CONTINUE;
          WHEN TOO_MANY_ROWS THEN
            /* HAndle the situation when too much data is returned such as with a select-into */
            put_line(v_tabstop||'ERROR: TOO_MANY_ROWS '||v_rowname);
		    checkmark(idx(v_rowname), 'N', 'E');
		    --checkmark(idx('continue'), 'Y', 'N');
            CONTINUE;
          WHEN generic_error THEN
            --put_line(v_tabstop||'ERROR: GENERIC ERROR '||r_row.name);
			result_checkmarks(idx(v_rowname));
		    checkmark(idx(v_rowname), 'N', 'E');
		    --checkmark(idx('continue'), 'Y', 'N');
      		CONTINUE;
          WHEN OTHERS THEN
            put_line(v_tabstop||'ERROR: OTHERS '||v_rowname);
		    checkmark(idx(v_rowname), 'N', 'E');
		    --checkmark(idx('continue'), 'Y', 'N');
      		CONTINUE;
      END;
	END LOOP;
	--
	put_line(CHR(10)||'# BELOW A TOTAL OVERVIEW IS GIVEN WHERE GRANTS WERE NOT EXECUTED OR ENCOUNTERED AN ERROR: '||CHR(10)||'#');
	result_checkmarks;
	--
	p_continue := y(idx('continue')).feedback;
	put_line(CHR(10)||'# Installation successful?: '||CASE y(idx('continue')).feedback WHEN 'Y' THEN 'YES !' ELSE 'NO! Check for errors.' END||CHR(10));
	--
  EXCEPTION
    WHEN generic_error THEN
      checkmark(idx(v_rowname), 'N', 'E');
	  ROLLBACK;
	  RAISE;
    WHEN idx_internal_check                                                                                                  THEN
      put_line('idx_internal_check   : '||CHR(10)||DBMS_UTILITY.format_error_stack);
  END;
  --
  put_line('##'||CHR(10)||'## SCRIPT ENDED NORMALLY');
  put_line('## INSTALLATION ENDED @ '||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS')||RPAD(' ', 158, '#'));
EXCEPTION
  WHEN fatal_error THEN
    ROLLBACK;
    put_line('##'||CHR(10)||'## SCRIPT ENDED DUE TO FATAL ERROR!');
    put_line('## INSTALLATION ENDED @ '||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS')||RPAD(' ', 158, '#'));
	RAISE;
  WHEN OTHERS THEN
    --checkmark(idx(v_rowname), 'N', 'E');
    ROLLBACK;
    put_line('##'||CHR(10)||'## SCRIPT ENDED DUE TO UNKNOWN ERROR!');
    put_line('## INSTALLATION ENDED @ '||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS')||RPAD(' ', 158, '#'));
	RAISE;
END;
/

-- @# https://vinish.dev/ora-06532-subscript-outside-of-limit




