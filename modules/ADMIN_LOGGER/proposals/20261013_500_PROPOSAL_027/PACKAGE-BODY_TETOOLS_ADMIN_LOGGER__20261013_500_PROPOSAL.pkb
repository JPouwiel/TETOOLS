CREATE OR REPLACE PACKAGE BODY tetools.admin_logger
IS
  -- VER BODY VERSION 20261013_500_PROPOSAL_027
  --
  -- /* ================================================================================================================================================================= */
  --  EXCEPTIONS
  -- /* ================================================================================================================================================================= */
  --
  generic_error            EXCEPTION;  PRAGMA EXCEPTION_INIT (generic_error           , -20001);
  failure_in_calling       EXCEPTION;  PRAGMA EXCEPTION_INIT (failure_in_calling      , -20002);
  invalid_parameter        EXCEPTION;  PRAGMA EXCEPTION_INIT (invalid_parameter       , -20003);  -- 'AN INVALID PARAMETER WAS GIVEN. VERIFY ITS USE'
  not_correct_session      EXCEPTION;  PRAGMA EXCEPTION_INIT (not_correct_session     , -20004);  -- 'REQUEST FOR TERMINATION COULD NOT BE PROCESSED. FOLLOW PRECEEDING MESSAGES FOR CAUSE.'
  marked_for_kill          EXCEPTION;  PRAGMA EXCEPTION_INIT (marked_for_kill         , -20005);  -- 'REQUESTED SESSION HAS BEEN MARKED FOR TERMINATION. SYSTEM WILL EJECT SESSION WHEN APPROPRIATE'
  get_help                 EXCEPTION;  PRAGMA EXCEPTION_INIT (get_help                , -20006);
  trm_cfmnd                EXCEPTION;  PRAGMA EXCEPTION_INIT (trm_cfmnd               , -20007);  -- 'TERMINATION REQUEST FOR USER HAS BEEN CONFIRMED.'
  req_denied               EXCEPTION;  PRAGMA EXCEPTION_INIT (req_denied              , -20008);  -- 'REQUEST DENIED: TERMINATION REQUEST <v_trm_id> TARGETS A SYS SESSION OR BACKGROUND PROCESS.'
  need_to_be_admin         EXCEPTION;  PRAGMA EXCEPTION_INIT (need_to_be_admin        , -20009);  -- 'INVOKING USER OF TERMINATION REQUEST NEEDS TO BE AN ADMIN USER FOR THIS REQUEST/SESSION. TERMINATION REQUEST <v_trm_id> AWAITS CONFIRMATION.'
  trm_closed               EXCEPTION;  PRAGMA EXCEPTION_INIT (trm_closed              , -20010);  -- 'TERMINATION REQUEST IS CLOSED, CONFIRMATION IS NOT POSSIBLE.'
  segment_numeral          EXCEPTION;  PRAGMA EXCEPTION_INIT (segment_numeral         , -20011);  --
  version_lt_min           EXCEPTION;  PRAGMA EXCEPTION_INIT (version_lt_min          , -20012);  --
  version_gt_max           EXCEPTION;  PRAGMA EXCEPTION_INIT (version_gt_max          , -20013);  --
  version_validation       EXCEPTION;  PRAGMA EXCEPTION_INIT (version_validation      , -20014);  --
  too_many_sessions        EXCEPTION;  PRAGMA EXCEPTION_INIT (too_many_sessions       , -20015);  --
  invalid_numsessions      EXCEPTION;  PRAGMA EXCEPTION_INIT (invalid_numsessions     , -20016);  --
  corrupt_logger_target    EXCEPTION;  PRAGMA EXCEPTION_INIT (corrupt_logger_target   , -20017);  --
  not_correct_phase        EXCEPTION;  PRAGMA EXCEPTION_INIT (not_correct_phase       , -20018);  -- 'THE PHASE GIVEN IS NOT COMMONLY USED IN GD.'
  no_valid_domain          EXCEPTION;  PRAGMA EXCEPTION_INIT (no_valid_domain         , -20019);  -- 'DOMAIN NAME VALIDATION FAILED, MOST LIKELY A DOMAIN NOT COMMONLY USED IN GD.'
  hostname_validation      EXCEPTION;  PRAGMA EXCEPTION_INIT (hostname_validation     , -20020);  -- 'VALIDATION OF THE HOSTNAME FAILED, MOST LIKELY A TYPO.'
  fqdn_validation          EXCEPTION;  PRAGMA EXCEPTION_INIT (fqdn_validation         , -20021);  -- 'VALIDATION OF THE FQDN FAILED FOR THE GIVEN HOSTNAME, CHECK AGAIN.'
  ip_invalid               EXCEPTION;  PRAGMA EXCEPTION_INIT (ip_invalid              , -20022);  -- 'VALIDATION OF THE GIVEN IP ADDRESS FAILED, EITHER FORMAT IS WRONG OR A BROADCAST ADDRESS WAS GIVEN.'
  shortname_validation     EXCEPTION;  PRAGMA EXCEPTION_INIT (shortname_validation    , -20023);  -- 'VALIDATION OF THE DB SERVER SHORTNAME FAILED, MOST LIKELY A SUBDOMAIN.'
  ip_format_invalid        EXCEPTION;  PRAGMA EXCEPTION_INIT (ip_format_invalid       , -20024);  -- 'IP ADDRESS FORMAT IS INVALID'
  port_validation          EXCEPTION;  PRAGMA EXCEPTION_INIT (port_validation         , -20025);  -- 'PORT VALIDATION FAILED'
  no_contributor           EXCEPTION;  PRAGMA EXCEPTION_INIT (no_contributor          , -20026);  -- 'INVOKING USER HAS NO PRIVILEGES TO CONTRIBUTE TO TNSNAMES. CONTACT TET.'
  maintenance_mode_enabled EXCEPTION;  PRAGMA EXCEPTION_INIT (maintenance_mode_enabled, -20027);  -- 'INVOKING USER HAS NO PRIVILEGES TO ADMINISTER TO TNSNAMES WHILE MAINTENANCE MODE IS ENABLED. CONTACT TET.'
  no_update_found          EXCEPTION;  PRAGMA EXCEPTION_INIT (no_update_found         , -20028);  -- 'NO DISCERNABLE UPDATE VALUES FOUND TO PROCESS AS TNS REGISTRATION. TRY AGAIN.'
  operation_halted         EXCEPTION;  PRAGMA EXCEPTION_INIT (operation_halted        , -20029);  -- 'SOMEHOW, SOMEWHERE, SOMETHINGs NOT GOOD. TRY AGAIN. CALL TET.'
  wrong_crud               EXCEPTION;  PRAGMA EXCEPTION_INIT (wrong_crud              , -20030);  -- 'CANt UPDATE WHEN IT ALREADY EXISTS, OR SIMILAR. TRY AGAIN.'
  mismatch_type_numhosts   EXCEPTION;  PRAGMA EXCEPTION_INIT (mismatch_type_numhosts  , -20031);  -- 'A SPECIFIC NUMBER OF ADDRESSES CAN/MUST BE USED WITH THE TYPE OF REGISTRATION. SIMPLE: 1, ADVANCED: 1 to 3.'
  invalid_numhosts         EXCEPTION;  PRAGMA EXCEPTION_INIT (invalid_numhosts        , -20032);  -- 'A SPECIFIC RANGE OF NUMBER OF ADDRESSES CAN BE USED TO REGISTER A NET SERVICE NAME: [1 - 3].'
  validation_error         EXCEPTION;  PRAGMA EXCEPTION_INIT (validation_error        , -20033);  -- 'A VALIDATION ERROR HAS OCCURED VALIDATING THE PROTO TNS ENTRY. SEE FEEDBACK FOR OFFENDING ATTRIBUTE.'
  no_parent_attr_name      EXCEPTION;  PRAGMA EXCEPTION_INIT (no_parent_attr_name     , -20034);  -- 'A PARSE ERROR HAS OCCURED TRYING TO VALIDATE THE GIVEN ATTRIBUTE NAME. THIS ATTRIBUTE HAS BEEN MISSPELLED OR NOT IN SUPPORT.'
  crud_retrieve            EXCEPTION;  PRAGMA EXCEPTION_INIT (crud_retrieve           , -20035);
  crud_read                EXCEPTION;  PRAGMA EXCEPTION_INIT (crud_read               , -20036);  -- 'REQUESTED CRUD OPERATION (READ) NOT APPLICABLE FOR THIS PACKAGE.'
  crud_unknown             EXCEPTION;  PRAGMA EXCEPTION_INIT (crud_unknown            , -20037);
  idx_internal_check       EXCEPTION;  PRAGMA EXCEPTION_INIT (idx_internal_check      , -20038);
  already_cataloged        EXCEPTION;  PRAGMA EXCEPTION_INIT (already_cataloged       , -20039);
  missing_logsession       EXCEPTION;  PRAGMA EXCEPTION_INIT (missing_logsession      , -20040);
  missing_logger_config EXCEPTION; PRAGMA EXCEPTION_INIT(missing_logger_config,-20041);
  --
  -- /* ================================================================================================================================================================= */
  --  TYPES
  -- /* ================================================================================================================================================================= */
  --
  TYPE session_rt    IS RECORD ( logsession_id     ADMIN_LOGGER_SESSIONS.LOGSESSION_ID%TYPE,
                                 sid               ADMIN_LOGGER_SESSIONS.SID%TYPE,
                                 serial#           ADMIN_LOGGER_SESSIONS.SERIAL#%TYPE,
                                 audsid            ADMIN_LOGGER_SESSIONS.AUDSID%TYPE,
                                 logon_user        ADMIN_LOGGER_SESSIONS.LOGON_USER%TYPE,
                                 logon_time        ADMIN_LOGGER_SESSIONS.LOGON_TIME%TYPE,
                                 current_user      ADMIN_LOGGER_SESSIONS.CURRENT_USER%TYPE,
                                 current_schema    ADMIN_LOGGER_SESSIONS.CURRENT_SCHEMA%TYPE,
                                 proxy_user        ADMIN_LOGGER_SESSIONS.PROXY_USER%TYPE
                               );
  --
  TYPE config_rt     IS RECORD ( config_id         ADMIN_LOGGER_CONFIG.CONFIG_ID%TYPE,
                                 logging_on        BOOLEAN                                  DEFAULT FALSE,
                                 logging_target    ADMIN_LOGGER_CONFIG.LOGGER_TARGET%TYPE   DEFAULT c_to_table,
                                 debug_on          BOOLEAN                                  DEFAULT g_debug_on,
                                 debug_target      ADMIN_LOGGER_CONFIG.DEBUG_TARGET%TYPE    DEFAULT g_override_target,
                                 batch_mode        ADMIN_LOGGER_CONFIG.BATCH_MODE%TYPE      DEFAULT c_b
                               ); 
  --
  TYPE config_bck_rt IS RECORD ( config_key        CHAR(5),
                                 config_id         ADMIN_LOGGER_CONFIG.CONFIG_ID%TYPE,
                                 logging_on        BOOLEAN,
                                 logging_target    ADMIN_LOGGER_CONFIG.LOGGER_TARGET%TYPE,
                                 debug_on          BOOLEAN,
                                 debug_target      ADMIN_LOGGER_CONFIG.DEBUG_TARGET%TYPE,
                                 batch_mode        ADMIN_LOGGER_CONFIG.BATCH_MODE%TYPE,
                                 log_batch         ADMIN_LOGGER_LOG.LOGBATCH_ID%TYPE,
                                 log_session       ADMIN_LOGGER_SESSIONS.LOGSESSION_ID%TYPE
                               ); 
  --
  TYPE logging_rt   IS RECORD  ( log_batch         ADMIN_LOGGER_LOG.LOGBATCH_ID%TYPE,
                                 log_lines         ADMIN_LOGGER_LOG.LOG_LINES%TYPE
					    	   );
  --
  TYPE incident_rt  IS RECORD  ( incident_id       ADMIN_LOGGER_INCIDENT.INCIDENT_ID%TYPE,
                                 context           ADMIN_LOGGER_INCIDENT.CONTEXT%TYPE,
								 status            ADMIN_LOGGER_INCIDENT.STATUS%TYPE,
								 sid               ADMIN_LOGGER_INCIDENT.SID%TYPE,
								 serial#           ADMIN_LOGGER_INCIDENT.SERIAL#%TYPE,
                                 audsid            ADMIN_LOGGER_INCIDENT.AUDSID%TYPE,
								 logon_user        ADMIN_LOGGER_INCIDENT.LOGON_USER%TYPE,
								 logon_time        ADMIN_LOGGER_INCIDENT.LOGON_TIME%TYPE,
                                 current_user      ADMIN_LOGGER_INCIDENT.CURRENT_USER%TYPE,
                                 current_schema    ADMIN_LOGGER_INCIDENT.CURRENT_SCHEMA%TYPE,
                                 proxy_user        ADMIN_LOGGER_INCIDENT.PROXY_USER%TYPE,
								 new_logsession_id ADMIN_LOGGER_INCIDENT.NEW_LOGSESSION_ID%TYPE,
								 callstack         ADMIN_LOGGER_INCIDENT.CALLSTACK%TYPE,
								 backtrace         ADMIN_LOGGER_INCIDENT.BACKTRACE%TYPE
					    	   );
  --
  g_session_rt          session_rt;
  g_config_rt           config_rt;
  g_config_bck_rt       config_bck_rt;
  g_logging_rt          logging_rt;
  g_incident_rt         incident_rt;
  --
  --
  -- /* ================================================================================================================================================================= */
  --  FUNCTIONS
  -- /* ================================================================================================================================================================= */
  --
  -- /* FUNCTION > gen_token --------------------------------------------------------------- VARCHAR2 ----- */
  -- 
  FUNCTION gen_token RETURN VARCHAR2 
  IS
    v_return CHAR(5);
  BEGIN
  --
    RETURN dbms_random.string('x',5);
  --
  END gen_token;
  --
  -- /* FUNCTION > bool2vc --------------------------------------------------------------------- BOOL ----- */
  -- 
  FUNCTION bool2vc (bool IN BOOLEAN) RETURN VARCHAR2 
  IS 
  BEGIN
	--
     RETURN CASE 
               WHEN bool     THEN 'TRUE' 
               WHEN NOT bool THEN 'FALSE' 
               ELSE               'NULL' 
            END; 
  END bool2vc;
  --
  -- /* FUNCTION > bool2c ---------------------------------------------------------------------- BOOL ----- */
  -- 
  FUNCTION bool2c (bool IN BOOLEAN) RETURN CHAR 
  IS 
  BEGIN
     RETURN CASE 
               WHEN bool     THEN 'Y' 
               WHEN NOT bool THEN 'N' 
           ELSE               NULL
            END; 
  END bool2c;
  -- 
  -- /* FUNCTION > char2bool ------------------------------------------------------------------- CHAR ----- */
  -- 
  FUNCTION char2bool (string IN CHAR) RETURN BOOLEAN 
  IS 
  BEGIN
  IF string = c_y THEN RETURN TRUE;
  ELSIF string = c_n OR string IS NULL THEN RETURN FALSE;
  ELSE RAISE invalid_parameter;
  END IF;
  END char2bool;
  --
  -- /* FUNCTION > get_invoking_sid ---------------------------------------------------- INVOKING_SID ----- */
  --
  FUNCTION get_invoking_sid RETURN NUMBER
  AS
   v_return NUMBER;
  BEGIN
	--
    SELECT SYS_CONTEXT('userenv','sid') INTO v_return FROM dual;
  --
    RETURN v_return;
  END get_invoking_sid;
  --
  -- /* FUNCTION > get_invoking_serial --------------------------------------------- INVOKING_SERIAL# ----- */
  --
  FUNCTION get_invoking_serial RETURN NUMBER
  AS
   v_return NUMBER;
  BEGIN
	--
    SELECT dbms_debug_jdwp.current_session_serial INTO v_return FROM dual;
  --
    RETURN v_return;
  END get_invoking_serial;
  --
  -- /* FUNCTION > get_audsid ---------------------------------------------------- TARGET SID/SERIAL# ----- */
  --
  FUNCTION get_audsid ( p_sid IN NUMBER, p_serial IN NUMBER ) RETURN NUMBER
  AS
    v_return NUMBER;
  BEGIN
	--
      SELECT audsid INTO v_return
      FROM v$session
     WHERE sid = p_sid
       AND serial# = p_serial;
  --
    RETURN v_return;
  END get_audsid;
  --
  -- /* FUNCTION > get_logon_time ---------------------------------------------------- LOGON_TIME ----- */
  --
  FUNCTION get_logon_time ( p_sid IN NUMBER, p_serial IN NUMBER ) RETURN DATE
  AS
   v_return DATE;
  BEGIN
	--
    SELECT logon_time INTO v_return FROM V$SESSION ses WHERE sid = p_sid AND serial# = p_serial;
    RETURN v_return;
  END get_logon_time;
  --
  -- /* FUNCTION > logging_is_on ------------------------------------------ ADMIN_LOGGER_SETTINGS ----- */
  --
  FUNCTION logging_is_on         ( p_settings_id IN INTEGER DEFAULT NULL
                                  ) RETURN CHAR
  IS 
    l_return           CHAR(1) DEFAULT 'N';
  BEGIN
  	session_details;
  -- The optional ID asserts the current configuration; it is not a cross-session selector.
  IF p_settings_id IS NOT NULL AND p_settings_id != g_config_rt.config_id THEN
    RAISE invalid_parameter;
  END IF;
    l_return := admin_logger.bool2c(g_config_rt.logging_on);
  	RETURN l_return;
  END logging_is_on;
  --
  -- /* FUNCTION > debug_is_on -------------------------------------------- ADMIN_LOGGER_SETTINGS ----- */
  --
  FUNCTION debug_is_on            ( p_settings_id IN INTEGER DEFAULT NULL
                                  ) RETURN CHAR
  IS 
    l_return           CHAR(1) DEFAULT 'N';
  BEGIN
  	session_details;
  -- The optional ID asserts the current configuration; it is not a cross-session selector.
  IF p_settings_id IS NOT NULL AND p_settings_id != g_config_rt.config_id THEN
    RAISE invalid_parameter;
  END IF;
    l_return := admin_logger.bool2c(g_config_rt.debug_on);
  	RETURN l_return;
  END debug_is_on;
  --
  -- /* FUNCTION > get_batchid -------------------------------------------------------------- INTEGER ----- */
  -- 
  FUNCTION get_batchid ( batch_mode IN CHAR ) RETURN INTEGER 
  IS
  BEGIN
    toggle_batch (modus => c_on, batch => batch_mode);
  	RETURN g_logging_rt.log_batch;
  END get_batchid;
  --
  --
  -- /* ================================================================================================================================================================= */
  --  PROCEDURES
  -- /* ================================================================================================================================================================= */
  --
  --
  --
  -- /* PROCEDURE > help --------------------------------------------------------------------------------------- USAGE EXAMPLES ----- */
  --
  PROCEDURE help( verbose IN VARCHAR2 DEFAULT 'N')
  AS
    l_context                VARCHAR2(128) := $$PLSQL_UNIT;
    v_this_object            VARCHAR2(32767);
    v_caller                 VARCHAR2(32767);
    v_rowtext                VARCHAR2(32767);
    v_filter_y               VARCHAR2(40) := '^[[:space:]]{2}[\-]{2}[H][SV][\-]';
    v_filter_n               VARCHAR2(40) := '^[[:space:]]{2}[\-]{2}[H][S][\-]';
    v_filter_help            VARCHAR2(64) := v_filter_y || '[[:space:]]';
    v_verbose                VARCHAR2(64) := v_filter_n;
    v_result                 CLOB;
  	v_full_clob              CLOB;
  	l_depth                  PLS_INTEGER;
  	l_lvl_object             PLS_INTEGER;
  	l_lvl_caller             PLS_INTEGER;
    l_old_module             VARCHAR2(64);
    l_old_action             VARCHAR2(64);
    l_old_client             VARCHAR2(64);
  	--
  	CURSOR c_help(p_object IN VARCHAR2, p_verbose IN VARCHAR2) IS
  	  SELECT line, text
  	    FROM dba_source
  	   WHERE name=p_object
  	     AND type ='PACKAGE'
  	     AND owner='TETOOLS'
  	     AND REGEXP_LIKE(text, p_verbose)
  	     ORDER BY 1 ASC;
  BEGIN
    DBMS_APPLICATION_INFO.READ_MODULE(l_old_module,l_old_action);
  	--
    --
  	IF verbose IS NULL OR NOT (UPPER(verbose) IN (c_y,c_n)
       OR (LENGTH(verbose)=8 AND SUBSTR(UPPER(verbose),1,5)='HELP '
           AND REGEXP_LIKE(SUBSTR(UPPER(verbose),6,3),'^[A-Z]{3}$'))) THEN
      RAISE failure_in_calling;
  	END IF;
    BEGIN
      who_called(2,v_this_object);
      who_called(LEAST(3,UTL_CALL_STACK.dynamic_depth+1),v_caller);
    EXCEPTION WHEN OTHERS THEN
      v_this_object:=l_context||'.help';
      v_caller:='[caller unavailable]';
    END;

    DBMS_APPLICATION_INFO.SET_MODULE(module_name => l_context||'.help', action_name => 'Display HELP section for package '||l_context||'.');
  	--
  	IF    UPPER(verbose) = c_y   THEN
  	  v_verbose := v_filter_y;
  	ELSIF ( SUBSTR( UPPER(verbose), 1, 4 ) = c_helpme ) AND ( LENGTH( verbose ) = 8 ) THEN
  	  v_verbose := v_filter_help || SUBSTR(UPPER(verbose), -3, 3);
  	END IF;
  	--
  	DBMS_LOB.CREATETEMPORARY(v_full_clob,TRUE);
  	DBMS_LOB.OPEN(v_full_clob, DBMS_LOB.LOB_READWRITE);
  	DBMS_LOB.append(v_full_clob, TO_CLOB(v_caller)||':: '||CHR(10));
  	--
  	FOR r_row IN c_help(l_context, v_verbose)
    LOOP
  	  DBMS_LOB.append(v_full_clob, REPLACE(r_row.text,',',', '));
    END LOOP;
  	--
    put_line(v_full_clob);
  	--
  	--
  	DBMS_LOB.CLOSE(lob_loc => v_full_clob);
    DBMS_LOB.FREETEMPORARY(lob_loc => v_full_clob);
  	--
  	DBMS_APPLICATION_INFO.SET_MODULE(l_old_module,l_old_action);
    --

  EXCEPTION WHEN OTHERS THEN
    BEGIN
      IF v_full_clob IS NOT NULL AND DBMS_LOB.ISTEMPORARY(v_full_clob)=1 THEN
        IF DBMS_LOB.ISOPEN(v_full_clob)=1 THEN DBMS_LOB.CLOSE(v_full_clob); END IF;
        DBMS_LOB.FREETEMPORARY(v_full_clob);
      END IF;
    EXCEPTION WHEN OTHERS THEN NULL; END;
    BEGIN
  	    DBMS_APPLICATION_INFO.SET_MODULE(l_old_module,l_old_action);
    EXCEPTION WHEN OTHERS THEN NULL; END;
        RAISE;
  END help;
  --
  -- /* PROCEDURE > banner -------------------------------------------------------------------------- PACKAGE DETAILS / HISTORY ----- */
  --
  PROCEDURE banner
  AS
    l_context                VARCHAR2(128) := $$PLSQL_UNIT;
    v_this_object            VARCHAR2(32767);
    v_caller                 VARCHAR2(32767);
    v_rowtext                VARCHAR2(32767);
  	v_full_clob              CLOB;
  	v_result                 CLOB;
  	l_depth                  PLS_INTEGER;
  	l_lvl_object             PLS_INTEGER;
  	l_lvl_caller             PLS_INTEGER;
    l_old_module             VARCHAR2(64);
    l_old_action             VARCHAR2(64);
    l_old_client             VARCHAR2(64);
  	--
  	CURSOR c_banner(p_object IN VARCHAR2) IS
  	  SELECT line, text
  	    FROM dba_source
  	   WHERE name=p_object
  	     AND type ='PACKAGE'
  	     AND owner='TETOOLS'
  	     AND REGEXP_LIKE(text, '^[[:space:]]{2}[\-]{2}[B][\-]')
  	     ORDER BY 1 ASC;
  BEGIN
    DBMS_APPLICATION_INFO.READ_MODULE(l_old_module,l_old_action);
  	--
    --
  	BEGIN
      who_called(2,v_this_object);
      who_called(LEAST(3,UTL_CALL_STACK.dynamic_depth+1),v_caller);
    EXCEPTION WHEN OTHERS THEN
      v_this_object:=l_context||'.banner';
      v_caller:='[caller unavailable]';
    END;

    DBMS_APPLICATION_INFO.SET_MODULE(module_name => l_context||'.banner', action_name => 'Display the BANNER for package '||l_context||'.');
    --
  	DBMS_LOB.CREATETEMPORARY(v_full_clob,TRUE);
  	DBMS_LOB.OPEN(v_full_clob, DBMS_LOB.LOB_READWRITE);
  	DBMS_LOB.append(v_full_clob, TO_CLOB(v_caller)||':: '||CHR(10));
  	--
  	FOR r_row IN c_banner(l_context)
    LOOP
  	  DBMS_LOB.append(v_full_clob, REPLACE(r_row.text,',',', '));
    END LOOP;
  	--
    put_line(v_full_clob);
  	--
  	DBMS_LOB.CLOSE(lob_loc => v_full_clob);
    DBMS_LOB.FREETEMPORARY(lob_loc => v_full_clob);
  	--
  	--
  	DBMS_APPLICATION_INFO.SET_MODULE(l_old_module,l_old_action);
    --

  EXCEPTION WHEN OTHERS THEN
    BEGIN
      IF v_full_clob IS NOT NULL AND DBMS_LOB.ISTEMPORARY(v_full_clob)=1 THEN
        IF DBMS_LOB.ISOPEN(v_full_clob)=1 THEN DBMS_LOB.CLOSE(v_full_clob); END IF;
        DBMS_LOB.FREETEMPORARY(v_full_clob);
      END IF;
    EXCEPTION WHEN OTHERS THEN NULL; END;
    BEGIN
  	    DBMS_APPLICATION_INFO.SET_MODULE(l_old_module,l_old_action);
    EXCEPTION WHEN OTHERS THEN NULL; END;
        RAISE;
  END banner;
  --
  -- /* PROCEDURE > version ------------------------------------------------------------------------- PACKAGE DETAILS / HISTORY ----- */
  --
  PROCEDURE version
  AS
    l_context                VARCHAR2(128) := $$PLSQL_UNIT;
    v_this_object            VARCHAR2(32767);
    v_caller                 VARCHAR2(32767);
    v_rowtext                VARCHAR2(32767);
  	v_full_clob              CLOB;
  	v_result                 CLOB;
  	l_depth                  PLS_INTEGER;
  	l_lvl_object             PLS_INTEGER;
  	l_lvl_caller             PLS_INTEGER;
    l_old_module             VARCHAR2(64);
    l_old_action             VARCHAR2(64);
    l_old_client             VARCHAR2(64);
  	--
  	CURSOR c_versions(p_object IN VARCHAR2) IS
  	  SELECT line, text
  	    FROM dba_source
  	   WHERE name  = p_object
  	     AND type IN ('PACKAGE', 'PACKAGE BODY')
  	     AND owner = 'TETOOLS'
  	     AND REGEXP_LIKE(text, '^[[:space:]]{2}[\-]{2}[[:space:]]VER')
  	     ORDER BY 1 ASC;
  BEGIN
    DBMS_APPLICATION_INFO.READ_MODULE(l_old_module,l_old_action);
  	--
    --
  	BEGIN
      who_called(2,v_this_object);
      who_called(LEAST(3,UTL_CALL_STACK.dynamic_depth+1),v_caller);
    EXCEPTION WHEN OTHERS THEN
      v_this_object:=l_context||'.version';
      v_caller:='[caller unavailable]';
    END;

    DBMS_APPLICATION_INFO.SET_MODULE(module_name => l_context||'.version', action_name => 'Display version numbers for package '||l_context||'.');
    --
  	DBMS_LOB.CREATETEMPORARY(v_full_clob,TRUE);
  	DBMS_LOB.OPEN(v_full_clob, DBMS_LOB.LOB_READWRITE);
  	DBMS_LOB.append(v_full_clob, TO_CLOB(v_caller)||':: '||CHR(10));
  	--
  	FOR r_row IN c_versions(l_context)
    LOOP
  	  DBMS_LOB.append(v_full_clob, REPLACE(r_row.text,'-- VER',' '));
    END LOOP;
  	--
    put_line(v_full_clob);
  	--
  	DBMS_LOB.CLOSE(lob_loc => v_full_clob);
    DBMS_LOB.FREETEMPORARY(lob_loc => v_full_clob);
  	--
  	--
  	DBMS_APPLICATION_INFO.SET_MODULE(l_old_module,l_old_action);
    --

  EXCEPTION WHEN OTHERS THEN
    BEGIN
      IF v_full_clob IS NOT NULL AND DBMS_LOB.ISTEMPORARY(v_full_clob)=1 THEN
        IF DBMS_LOB.ISOPEN(v_full_clob)=1 THEN DBMS_LOB.CLOSE(v_full_clob); END IF;
        DBMS_LOB.FREETEMPORARY(v_full_clob);
      END IF;
    EXCEPTION WHEN OTHERS THEN NULL; END;
    BEGIN
  	    DBMS_APPLICATION_INFO.SET_MODULE(l_old_module,l_old_action);
    EXCEPTION WHEN OTHERS THEN NULL; END;
        RAISE;
  END version;
  --
  -- /* PROCEDURE > save_logger_config -------------------------------------------------------------------------------- ROWTYPE ----- */
  --
  PROCEDURE save_logger_config
  AS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_count                  PLS_INTEGER;
  l_null  CHAR(1);
  v_upd_logger VARCHAR2(4000) :=
    'UPDATE tetools.admin_logger_config SET logger_on=:1, logger_target=:2, ' ||
    'debug_on=:3, debug_target=:4, batch_mode=:5, logbatch_id=:6 ' ||
    'WHERE logsession_id=:7 AND config_id=:8';
  BEGIN
  -- Only the actual DML owner takes this lock. Callers must not hold it.
  SELECT guard_id INTO l_count FROM tetools.admin_logger_guard
   WHERE guard_id = 1 FOR UPDATE WAIT 5;
  IF g_config_rt.logging_on IS NULL OR g_config_rt.debug_on IS NULL
     OR g_config_rt.logging_target IS NULL OR g_config_rt.debug_target IS NULL
     OR g_config_rt.logging_target NOT IN (c_to_screen,c_to_table)
     OR g_config_rt.debug_target NOT IN (c_to_screen,c_to_table)
     OR g_config_rt.batch_mode IS NULL OR g_config_rt.batch_mode NOT IN (c_s,c_b) THEN
    RAISE invalid_parameter;
  	END IF;
  IF g_config_rt.batch_mode = c_b THEN
    IF g_logging_rt.log_batch IS NULL OR g_logging_rt.log_batch <= 0 THEN
      RAISE invalid_parameter;
    END IF;
    EXECUTE IMMEDIATE v_upd_logger USING
      bool2c(g_config_rt.logging_on), g_config_rt.logging_target,
      bool2c(g_config_rt.debug_on), g_config_rt.debug_target,
      c_b, g_logging_rt.log_batch, g_session_rt.logsession_id, g_config_rt.config_id;
  ELSE
    EXECUTE IMMEDIATE v_upd_logger USING
      bool2c(g_config_rt.logging_on), g_config_rt.logging_target,
      bool2c(g_config_rt.debug_on), g_config_rt.debug_target,
      c_s, l_null, g_session_rt.logsession_id, g_config_rt.config_id;
  END IF;
  IF SQL%ROWCOUNT != 1 THEN RAISE invalid_numsessions; END IF;
      COMMIT;
  EXCEPTION 
  	WHEN OTHERS                                 THEN
    ROLLBACK;
    -- Do not route a saver error back through the logger or session lookup.
      RAISE;
  END save_logger_config;
  --
  -- /* PROCEDURE > session_detail_incident ------------------------------------------------------------------------- V$SESSION ----- */
  --
PROCEDURE persist_session_incident (
  p_session        IN session_rt,
  p_issue          IN VARCHAR2,
  p_incident_id    IN OUT admin_logger_incident.incident_id%TYPE,
  p_status         IN VARCHAR2,
  p_errorstack     IN CLOB,
  p_callstack      IN CLOB,
  p_backtrace      IN CLOB,
  p_repair_error   IN CLOB DEFAULT NULL,
  p_capture_rows   IN BOOLEAN DEFAULT FALSE )
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_count             PLS_INTEGER;
  v_sessions_snapshot CLOB;
  v_config_snapshot   CLOB;
  v_ins_incident VARCHAR2(4000) :=
    'INSERT INTO tetools.admin_logger_incident ' ||
    '(created_on,context,status,reason,sid,serial#,audsid,logon_user,logon_time,' ||
    'current_user,current_schema,proxy_user,callstack,backtrace,error_stack,' ||
    'old_logsession_id,sessions_snapshot,config_snapshot,repair_error) ' ||
    'VALUES (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17,:18,:19)';
  v_upd_incident VARCHAR2(4000) :=
    'UPDATE tetools.admin_logger_incident SET status=:1, ' ||
    'sessions_snapshot=COALESCE(sessions_snapshot,:2), ' ||
    'config_snapshot=COALESCE(config_snapshot,:3), ' ||
    'repair_error=COALESCE(:4,repair_error) WHERE incident_id=:5';
BEGIN
  IF p_issue IS NULL OR p_issue NOT IN ('missing_id','extra_id','no_config')
     OR p_status IS NULL OR p_status NOT IN ('SUBMITTED','OPEN') THEN
    RAISE invalid_parameter;
  END IF;
  -- The repair owner holds the guard when it requests snapshots.
  -- This autonomous reader never takes that guard or changes session/config rows.
  IF p_capture_rows THEN
    SELECT JSON_ARRAYAGG(JSON_OBJECT(s.* RETURNING CLOB)
                         ORDER BY s.logsession_id RETURNING CLOB)
      INTO v_sessions_snapshot FROM tetools.admin_logger_sessions s
     WHERE s.sid=p_session.sid AND s.serial#=p_session.serial#
       AND s.audsid=p_session.audsid AND s.logon_user=p_session.logon_user
       AND s.logon_time=p_session.logon_time;
    SELECT JSON_ARRAYAGG(JSON_OBJECT(c.* RETURNING CLOB)
                         ORDER BY c.config_id RETURNING CLOB)
      INTO v_config_snapshot FROM tetools.admin_logger_config c
      JOIN tetools.admin_logger_sessions s ON s.logsession_id=c.logsession_id
     WHERE s.sid=p_session.sid AND s.serial#=p_session.serial#
       AND s.audsid=p_session.audsid AND s.logon_user=p_session.logon_user
       AND s.logon_time=p_session.logon_time;
    IF v_sessions_snapshot IS NULL THEN v_sessions_snapshot:=TO_CLOB('[]'); END IF;
    IF v_config_snapshot IS NULL THEN v_config_snapshot:=TO_CLOB('[]'); END IF;
  END IF;
  IF p_incident_id IS NULL THEN
    EXECUTE IMMEDIATE v_ins_incident || ' RETURNING incident_id INTO :new_incident'
      USING SYSTIMESTAMP,'ADMIN_LOGGER',p_status,p_issue,p_session.sid,
        p_session.serial#,p_session.audsid,p_session.logon_user,p_session.logon_time,
        p_session.current_user,p_session.current_schema,p_session.proxy_user,
        p_callstack,p_backtrace,p_errorstack,p_session.logsession_id,
        v_sessions_snapshot,v_config_snapshot,p_repair_error
      RETURNING INTO p_incident_id;
  ELSE
    SELECT COUNT(*) INTO l_count FROM tetools.admin_logger_incident
     WHERE incident_id=p_incident_id AND sid=p_session.sid
       AND serial#=p_session.serial# AND audsid=p_session.audsid
       AND logon_user=p_session.logon_user AND logon_time=p_session.logon_time
       AND status IN ('SUBMITTED','OPEN');
    IF l_count != 1 THEN RAISE failure_in_calling; END IF;
    EXECUTE IMMEDIATE v_upd_incident USING p_status,v_sessions_snapshot,
      v_config_snapshot,p_repair_error,p_incident_id;
    IF SQL%ROWCOUNT != 1 THEN RAISE failure_in_calling; END IF;
  END IF;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  RAISE;
END persist_session_incident;
  --
  PROCEDURE session_detail_incident (
  issue IN VARCHAR2, inc_id IN INTEGER DEFAULT NULL,
  error_stack_in IN CLOB DEFAULT NULL, backtrace_in IN CLOB DEFAULT NULL )
  AS
    PRAGMA                   AUTONOMOUS_TRANSACTION; 
  l_logger_sessions admin_logger_sessions%ROWTYPE;
    l_logger_config          admin_logger_config%ROWTYPE;
  	l_incident_saved         BOOLEAN        := FALSE;
  l_session         session_rt;
    l_count                  PLS_INTEGER;
  v_incident_id     admin_logger_incident.incident_id%TYPE := inc_id;
  v_logsession_id   admin_logger_sessions.logsession_id%TYPE;
    v_callstack              CLOB           := DBMS_UTILITY.format_call_stack ;
  v_backtrace       CLOB := backtrace_in;
  v_errorstack      CLOB := error_stack_in;
  	v_sql_sessions           VARCHAR2(4000) := 'INSERT INTO TETOOLS.ADMIN_LOGGER_SESSIONS (created_on, sid, serial#, audsid, logon_user, logon_time, current_user, current_schema, proxy_user, incident_id) VALUES (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10)';
  	v_sql_config             VARCHAR2(4000) := 'INSERT INTO TETOOLS.ADMIN_LOGGER_CONFIG (created_on, logsession_id, logger_on, logger_target, debug_on, debug_target, batch_mode, logbatch_id) VALUES (:1, :2, :3, :4, :5, :6, :7, :8)';
  l_null CHAR(1);
  	v_del_sessions           VARCHAR2(4000) := 'DELETE FROM TETOOLS.ADMIN_LOGGER_SESSIONS WHERE logsession_id = :1';
  	v_del_config             VARCHAR2(4000) := 'DELETE FROM TETOOLS.ADMIN_LOGGER_CONFIG WHERE logsession_id = :1';
  BEGIN
    /* VALIDATE INPUT PARAMETERS */
  IF issue IS NULL OR issue NOT IN ('missing_id','extra_id','no_config') THEN
  	  RAISE failure_in_calling;
  	END IF;
  -- Preserve a known old ID. Do not clear the published runtime records.
  l_session.logsession_id:=g_session_rt.logsession_id;
  IF l_session.logsession_id=0 THEN l_session.logsession_id:=NULL; END IF;
  l_session.sid:=get_invoking_sid;
  l_session.serial#:=get_invoking_serial;
  l_session.audsid:=get_audsid(l_session.sid,l_session.serial#);
  l_session.logon_time:=get_logon_time(l_session.sid,l_session.serial#);
  l_session.logon_user:=SYS_CONTEXT('USERENV','SESSION_USER');
  l_session.current_user:=SYS_CONTEXT('USERENV','CURRENT_USER');
  l_session.current_schema:=SYS_CONTEXT('USERENV','CURRENT_SCHEMA');
  l_session.proxy_user:=SYS_CONTEXT('USERENV','PROXY_USER');
  IF v_errorstack IS NULL THEN v_errorstack:=DBMS_UTILITY.format_error_stack; END IF;
  IF v_backtrace IS NULL THEN v_backtrace:=DBMS_UTILITY.format_error_backtrace; END IF;
  persist_session_incident(l_session,issue,v_incident_id,'SUBMITTED',
    v_errorstack,v_callstack,v_backtrace);
  l_incident_saved:=TRUE;
  SELECT guard_id INTO l_count FROM tetools.admin_logger_guard
   WHERE guard_id=1 FOR UPDATE WAIT 5;
  -- Snapshot before destructive DML, while cooperative writers are excluded.
  persist_session_incident(l_session,issue,v_incident_id,'OPEN',
    v_errorstack,v_callstack,v_backtrace,p_capture_rows=>TRUE);
  SELECT COUNT(*) INTO l_count FROM tetools.admin_logger_sessions
   WHERE sid=l_session.sid AND serial#=l_session.serial# AND audsid=l_session.audsid
     AND logon_user=l_session.logon_user AND logon_time=l_session.logon_time;
  IF l_count=1 THEN
    SELECT * INTO l_logger_sessions FROM tetools.admin_logger_sessions
     WHERE sid=l_session.sid AND serial#=l_session.serial# AND audsid=l_session.audsid
       AND logon_user=l_session.logon_user AND logon_time=l_session.logon_time;
    SELECT COUNT(*) INTO l_count FROM tetools.admin_logger_config
     WHERE logsession_id=l_logger_sessions.logsession_id;
    IF l_count=1 THEN v_logsession_id:=l_logger_sessions.logsession_id; END IF;
  	END IF;
  IF v_logsession_id IS NULL THEN
    -- One path handles missing, duplicate, and missing-config registrations.
    FOR r_row IN (SELECT logsession_id FROM tetools.admin_logger_sessions
      WHERE sid=l_session.sid AND serial#=l_session.serial# AND audsid=l_session.audsid
        AND logon_user=l_session.logon_user AND logon_time=l_session.logon_time
  		 ORDER BY logsession_id ) LOOP
  	    EXECUTE IMMEDIATE v_del_config USING IN r_row.logsession_id;
        EXECUTE IMMEDIATE v_del_sessions USING IN r_row.logsession_id;
      END LOOP;
    EXECUTE IMMEDIATE v_sql_sessions || ' RETURNING logsession_id INTO :new_session'
      USING SYSTIMESTAMP,l_session.sid,l_session.serial#,l_session.audsid,
        l_session.logon_user,l_session.logon_time,l_session.current_user,
        l_session.current_schema,l_session.proxy_user,v_incident_id
      RETURNING INTO v_logsession_id;
    EXECUTE IMMEDIATE v_sql_config USING SYSTIMESTAMP,v_logsession_id,
      c_n,c_to_table,c_n,c_to_screen,c_s,l_null;
  	END IF;
  SELECT COUNT(*) INTO l_count FROM tetools.admin_logger_sessions
   WHERE sid=l_session.sid AND serial#=l_session.serial# AND audsid=l_session.audsid
     AND logon_user=l_session.logon_user AND logon_time=l_session.logon_time;
  	IF    l_count != 1  THEN RAISE generic_error; END IF;
  SELECT COUNT(*) INTO l_count FROM tetools.admin_logger_sessions
   WHERE logsession_id=v_logsession_id AND sid=l_session.sid
     AND serial#=l_session.serial# AND audsid=l_session.audsid
     AND logon_user=l_session.logon_user AND logon_time=l_session.logon_time;
    IF l_count != 1 THEN RAISE generic_error; END IF;
  SELECT * INTO l_logger_config FROM tetools.admin_logger_config
   WHERE logsession_id=v_logsession_id;
  IF l_logger_config.logger_target IS NULL
     OR l_logger_config.logger_target NOT IN (c_s,c_to_table)
     OR NVL(l_logger_config.debug_target,c_to_screen) NOT IN (c_s,c_to_table)
     OR NVL(l_logger_config.batch_mode,c_s) NOT IN (c_s,c_b) THEN
    RAISE generic_error;
  END IF;
  IF l_logger_config.batch_mode=c_b AND
     (l_logger_config.logbatch_id IS NULL OR l_logger_config.logbatch_id<=0) THEN
    RAISE generic_error;
  END IF;
  EXECUTE IMMEDIATE
    'UPDATE tetools.admin_logger_incident SET status=:1,new_logsession_id=:2 WHERE incident_id=:3'
    USING 'CLOSED',v_logsession_id,v_incident_id;
  IF SQL%ROWCOUNT!=1 THEN RAISE generic_error; END IF;
  -- Registration, configuration, and CLOSED mapping commit together.
  	COMMIT;
  -- The wrapper publishes only after a strict, successful reload.
  EXCEPTION WHEN OTHERS THEN
  v_backtrace:=TO_CLOB(DBMS_UTILITY.format_error_stack)||CHR(10)||DBMS_UTILITY.format_error_backtrace;
       ROLLBACK;
  IF l_incident_saved THEN
    BEGIN
      persist_session_incident(l_session,issue,v_incident_id,'OPEN',
        v_errorstack,v_callstack,backtrace_in,p_repair_error=>v_backtrace);
    EXCEPTION WHEN OTHERS THEN NULL; END;
  END IF;
       RAISE;
  END session_detail_incident;
  --
  -- /* PROCEDURE > load_session_details ---------------------------------------------------------------------------- V$SESSION ----- */
  --
  PROCEDURE load_session_details ( allow_null BOOLEAN DEFAULT FALSE )
  AS
    l_logger_config          admin_logger_config%ROWTYPE;
    l_logger_sessions        admin_logger_sessions%ROWTYPE;
  l_session         session_rt;
  l_config          config_rt;
  l_logging         logging_rt;
    l_count                  PLS_INTEGER;
  BEGIN
  l_session.sid:=get_invoking_sid;
  l_session.serial#:=get_invoking_serial;
  l_session.audsid:=get_audsid(l_session.sid,l_session.serial#);
  l_session.logon_time:=get_logon_time(l_session.sid,l_session.serial#);
  l_session.logon_user:=SYS_CONTEXT('USERENV','SESSION_USER');
  l_session.current_user:=SYS_CONTEXT('USERENV','CURRENT_USER');
  l_session.current_schema:=SYS_CONTEXT('USERENV','CURRENT_SCHEMA');
  l_session.proxy_user:=SYS_CONTEXT('USERENV','PROXY_USER');
  SELECT COUNT(*) INTO l_count FROM tetools.admin_logger_sessions
   WHERE sid=l_session.sid AND serial#=l_session.serial# AND audsid=l_session.audsid
     AND logon_user=l_session.logon_user AND logon_time=l_session.logon_time;
  IF l_count=0 THEN
    IF allow_null IS NULL OR NOT allow_null THEN RAISE missing_logsession; END IF;
    l_session.logsession_id:=0;
    l_config.config_id:=0;
    l_config.logging_on:=FALSE;
    l_config.logging_target:=c_to_table;
    l_config.debug_on:=FALSE;
    l_config.debug_target:=c_to_screen;
    l_config.batch_mode:=c_s;
    l_logging.log_batch:=0;
    l_logging.log_lines:=0;
  ELSIF l_count=1 THEN
    BEGIN
      SELECT * INTO l_logger_sessions FROM tetools.admin_logger_sessions
       WHERE sid=l_session.sid AND serial#=l_session.serial# AND audsid=l_session.audsid
         AND logon_user=l_session.logon_user AND logon_time=l_session.logon_time;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN RAISE missing_logsession;
      WHEN TOO_MANY_ROWS THEN RAISE too_many_sessions;
    END;
    BEGIN
      SELECT * INTO l_logger_config FROM tetools.admin_logger_config
       WHERE logsession_id=l_logger_sessions.logsession_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN RAISE missing_logger_config;
    END;
    l_session.logsession_id:=l_logger_sessions.logsession_id;
    l_config.config_id:=l_logger_config.config_id;
    l_config.logging_on:=char2bool(l_logger_config.logger_on);
    l_config.logging_target:=l_logger_config.logger_target;
    l_config.debug_on:=char2bool(l_logger_config.debug_on);
    l_config.debug_target:=NVL(l_logger_config.debug_target,c_to_screen);
    l_config.batch_mode:=NVL(l_logger_config.batch_mode,c_s);
    IF l_config.logging_target IS NULL OR l_config.logging_target NOT IN (c_s,c_to_table)
       OR l_config.debug_target IS NULL OR l_config.debug_target NOT IN (c_s,c_to_table)
       OR l_config.batch_mode IS NULL OR l_config.batch_mode NOT IN (c_s,c_b) THEN
      RAISE invalid_parameter;
  	END IF;
    IF l_config.batch_mode=c_b THEN
      l_logging.log_batch:=l_logger_config.logbatch_id;
      IF l_logging.log_batch IS NULL OR l_logging.log_batch<=0 THEN
        RAISE invalid_parameter;
  	  END IF;
      IF g_session_rt.logsession_id IS NULL
         OR g_session_rt.logsession_id!=l_session.logsession_id
         OR g_logging_rt.log_batch IS NULL OR g_logging_rt.log_batch!=l_logging.log_batch
         OR g_logging_rt.log_lines IS NULL OR g_logging_rt.log_lines<=0 THEN
        EXECUTE IMMEDIATE q'[SELECT NVL(MAX(log_lines),0)+1
          FROM tetools.admin_logger_log WHERE logsession_id=:sid AND logbatch_id=:bid]'
          INTO l_logging.log_lines USING l_session.logsession_id,l_logging.log_batch;
      ELSE l_logging.log_lines:=g_logging_rt.log_lines;
  		END IF;
  	  ELSE
      l_logging.log_batch:=0;
      l_logging.log_lines:=0;
  	  END IF;
  ELSE RAISE too_many_sessions;
  	END IF;
  -- Publish all validated records together. A failed lookup changes none of them.
  IF g_config_bck_rt.config_key IS NOT NULL AND
     (g_config_bck_rt.log_session IS NULL OR g_config_bck_rt.log_session!=l_session.logsession_id) THEN
    -- A backup from the old registration cannot be restored into the new one.
    g_config_bck_rt.config_key:=NULL;
  END IF;
  g_session_rt:=l_session;
  g_config_rt:=l_config;
  g_logging_rt:=l_logging;
  EXCEPTION 
    WHEN missing_logsession                 THEN
      RAISE; 
    WHEN too_many_sessions                  THEN 
      RAISE; 
  WHEN missing_logger_config THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE;
  END load_session_details;
  --
  -- /* PROCEDURE > session_details ---------------------------------------------------------------------- LOAD_SESSION_DETAILS ----- */
  --
  PROCEDURE session_details
  AS
  v_issue VARCHAR2(10);
  v_errorstack CLOB;
  v_backtrace CLOB;
  BEGIN
  IF g_session_recovery_busy THEN
    RAISE_APPLICATION_ERROR(-20042,'Session recovery re-entry is not permitted');
  	END IF;
  	load_session_details(FALSE);
  EXCEPTION 
  WHEN missing_logsession OR too_many_sessions OR missing_logger_config THEN
    v_errorstack:=DBMS_UTILITY.format_error_stack;
    v_backtrace:=DBMS_UTILITY.format_error_backtrace;
    v_issue:=CASE SQLCODE WHEN -20040 THEN 'missing_id'
                         WHEN -20015 THEN 'extra_id'
                         WHEN -20041 THEN 'no_config' END;
    g_session_recovery_busy:=TRUE;
    BEGIN
      session_detail_incident(v_issue,error_stack_in=>v_errorstack,backtrace_in=>v_backtrace);
      load_session_details(FALSE);
      g_session_recovery_busy:=FALSE;
    EXCEPTION WHEN OTHERS THEN
      g_session_recovery_busy:=FALSE;
      RAISE;
    END;
    WHEN OTHERS                  THEN 
    -- Unexpected lookup failures are not destructive-repair requests.
    RAISE;
  END session_details;
  --
  -- /* PROCEDURE > session_details_revert -------------------------------------------------------------------------- V$SESSION ----- */
  --
  PROCEDURE session_details_revert(modus IN VARCHAR2, config_key IN VARCHAR2 DEFAULT NULL)
  AS
  l_config_before config_rt;
  l_logging_before logging_rt;
  l_saved BOOLEAN:=FALSE;
  BEGIN
  IF modus IS NULL OR UPPER(modus) NOT IN ('BACKUP','RESTORE')
     OR config_key IS NULL OR LENGTH(config_key)!=5 THEN
    RAISE failure_in_calling;
  	END IF;
  session_details;
  IF UPPER(modus)='BACKUP' THEN
    IF g_config_bck_rt.config_key IS NOT NULL THEN RAISE failure_in_calling; END IF;
  	  g_config_bck_rt.config_key     := config_key                            ;
    g_config_bck_rt.log_session:=g_session_rt.logsession_id;
    g_config_bck_rt.config_id:=g_config_rt.config_id;
    g_config_bck_rt.logging_on:=g_config_rt.logging_on;
    g_config_bck_rt.logging_target:=g_config_rt.logging_target;
    g_config_bck_rt.debug_on:=g_config_rt.debug_on;
    g_config_bck_rt.debug_target:=g_config_rt.debug_target;
    g_config_bck_rt.batch_mode:=g_config_rt.batch_mode;
    g_config_bck_rt.log_batch:=g_logging_rt.log_batch;
  ELSE
    IF g_config_bck_rt.config_key IS NULL OR g_config_bck_rt.config_key!=config_key
       OR g_config_bck_rt.log_session!=g_session_rt.logsession_id
       OR g_config_bck_rt.config_id!=g_config_rt.config_id THEN
      RAISE failure_in_calling;
    END IF;
    l_config_before:=g_config_rt;
    l_logging_before:=g_logging_rt;
  	  g_config_rt.logging_on         := g_config_bck_rt.logging_on     ;
      g_config_rt.logging_target     := g_config_bck_rt.logging_target ;
      g_config_rt.debug_on           := g_config_bck_rt.debug_on       ;
      g_config_rt.debug_target       := g_config_bck_rt.debug_target   ;
  	  g_config_rt.batch_mode         := g_config_bck_rt.batch_mode     ;
    IF g_config_rt.batch_mode=c_b THEN
      g_logging_rt.log_batch         := g_config_bck_rt.log_batch      ;
      EXECUTE IMMEDIATE q'[SELECT NVL(MAX(log_lines),0)+1 FROM tetools.admin_logger_log
        WHERE logsession_id=:sid AND logbatch_id=:bid]'
        INTO g_logging_rt.log_lines USING g_session_rt.logsession_id,g_logging_rt.log_batch;
    ELSE
      g_logging_rt.log_batch:=0;
      g_logging_rt.log_lines:=0;
    END IF;
    save_logger_config;
    l_saved:=TRUE;
    -- Discard the backup only after a successful save.
  	  g_config_bck_rt.config_key     := NULL ;
  	END IF;
  EXCEPTION WHEN OTHERS THEN
  IF NOT l_saved AND l_config_before.config_id IS NOT NULL THEN
    g_config_rt:=l_config_before;
    g_logging_rt:=l_logging_before;
  END IF;
  	  RAISE;
  END session_details_revert;
  --
  -- /* PROCEDURE > show_config ------------------------------------------------------------------------- ADMIN_LOGGER_SETTINGS ----- */
  --
  PROCEDURE show_config ( modus IN VARCHAR DEFAULT NULL )
  AS
    l_logging_target         VARCHAR2(24);
    l_debug_target           VARCHAR2(24);

  BEGIN
  	--
    session_details;
    --
    /* VALIDATE INPUT PARAMETERS */
    IF modus IS NOT NULL    THEN
  	  IF NOT UPPER(modus) = c_helpme  THEN
        RAISE failure_in_calling;
  	  ELSE
  	    RAISE get_help;
  	  END IF;
    END IF;
  	--
  	SELECT DECODE(g_config_rt.logging_target, 'S', 'SCREEN', 'T', 'LOGGING TABLE') INTO l_logging_target FROM DUAL;
  	SELECT DECODE(g_config_rt.debug_target,   'S', 'SCREEN', 'T', 'LOGGING TABLE') INTO l_debug_target   FROM DUAL;
  	--
  	DBMS_OUTPUT.ENABLE (1000000);
  	DBMS_OUTPUT.PUT_LINE('CURRENT LOGGING SETTINGS FOR '||g_session_rt.logon_user);
  	DBMS_OUTPUT.PUT_LINE('CONFIG_KEY     VALUE');
  	DBMS_OUTPUT.PUT_LINE('-------------- -------------------------'                                  );
  	DBMS_OUTPUT.PUT_LINE('logsession_id  '||TO_CHAR(g_session_rt.logsession_id)                      );
  	DBMS_OUTPUT.PUT_LINE('sid            '||TO_CHAR(g_session_rt.sid)                                );
  	DBMS_OUTPUT.PUT_LINE('serial#        '||TO_CHAR(g_session_rt.serial#)                            );
  	DBMS_OUTPUT.PUT_LINE('audsid         '||TO_CHAR(g_session_rt.audsid)                             );
  	DBMS_OUTPUT.PUT_LINE('logon_user     '||g_session_rt.logon_user                                  );
  	DBMS_OUTPUT.PUT_LINE('batch_mode     '||g_config_rt.batch_mode                                   );
    DBMS_OUTPUT.PUT_LINE('LogBatch ID    '||g_logging_rt.log_batch                                   );
  	DBMS_OUTPUT.PUT_LINE('current_user   '||g_session_rt.current_user                                );
  	DBMS_OUTPUT.PUT_LINE('current_schema '||g_session_rt.current_schema                              );
  	DBMS_OUTPUT.PUT_LINE('proxy_user     '||g_session_rt.proxy_user                                  );
  	DBMS_OUTPUT.PUT_LINE('logon_time     '||TO_CHAR(g_session_rt.logon_time, 'YYYY-MM-DD HH24:MI:SS'));
  	DBMS_OUTPUT.PUT_LINE('logging        '||BOOL2VC(g_config_rt.logging_on)                          );
    DBMS_OUTPUT.PUT_LINE('logging_target '||l_logging_target                                         );
  	DBMS_OUTPUT.PUT_LINE('debug          '||BOOL2VC(g_config_rt.debug_on)                            );
    DBMS_OUTPUT.PUT_LINE('debug_target   '||l_debug_target                                           );
  --
  EXCEPTION
    WHEN get_help THEN help('HELP SHC');
    WHEN OTHERS THEN RAISE;
  END show_config;
  --
  -- /* PROCEDURE > who_called --------------------------------------------------------------------------------- UTL_CALL_STACK ----- */
  --
  PROCEDURE who_called ( p_level IN NUMBER, p_trm_result OUT VARCHAR2 )
  AS
    v_caller utl_call_stack.unit_qualified_name;
  BEGIN
    /* This procedure retrieves the calling component. */
    /* This information is used for troubleshooting and debugging and has no purpose for standard operational use. */
  IF p_level IS NULL OR p_level!=TRUNC(p_level) OR p_level<1
     OR p_level>UTL_CALL_STACK.dynamic_depth THEN
    RAISE invalid_parameter;
  END IF;
  	v_caller     := utl_call_stack.subprogram(p_level);
    p_trm_result := utl_call_stack.concatenate_subprogram(v_caller);
  END who_called;
  --
  -- /* PROCEDURE > toggle_logging ----------------------------------------------------------------------- ADMIN_LOGGER_CONFIG ----- */
  --
  PROCEDURE toggle_logging  ( modus                   IN VARCHAR2 DEFAULT c_on, 
                              send_log_to_in          IN VARCHAR2 DEFAULT g_logging_target)
  IS
    PRAGMA                   AUTONOMOUS_TRANSACTION; 
    l_old_module             VARCHAR2(64);
    l_old_action             VARCHAR2(64);
    l_old_client             VARCHAR2(64);
  l_config_before config_rt;
  l_saved BOOLEAN:=FALSE;
  BEGIN
    DBMS_APPLICATION_INFO.READ_MODULE(l_old_module, l_old_action);
  DBMS_APPLICATION_INFO.READ_CLIENT_INFO(l_old_client);
  IF UPPER(modus)=c_helpme THEN
    help('HELP TLO');
  ELSE
    /* VALIDATE INPUT PARAMETERS */
    IF modus IS NULL OR UPPER(modus) NOT IN (c_on,c_off)
       OR send_log_to_in IS NULL OR UPPER(send_log_to_in) NOT IN (c_s,c_to_table) THEN
  	  RAISE failure_in_calling;
  	END IF;
    session_details;
    l_config_before:=g_config_rt;
    DBMS_APPLICATION_INFO.SET_MODULE('ADMIN_LOGGER.toggle_logging','Change session configuration');
    g_config_rt.logging_on:=UPPER(modus)=c_on;
    g_config_rt.logging_target:=UPPER(send_log_to_in);
    save_logger_config;
    l_saved:=TRUE;
    END IF;
    DBMS_APPLICATION_INFO.SET_CLIENT_INFO(l_old_client);
    DBMS_APPLICATION_INFO.SET_MODULE(l_old_module,l_old_action);
  COMMIT;
  EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  IF NOT l_saved AND l_config_before.config_id IS NOT NULL THEN
    g_config_rt:=l_config_before;
  END IF;
  BEGIN
      DBMS_APPLICATION_INFO.SET_CLIENT_INFO(l_old_client);
      DBMS_APPLICATION_INFO.SET_MODULE(l_old_module,l_old_action);
  EXCEPTION WHEN OTHERS THEN NULL; END;
      RAISE;
  END toggle_logging;
  --
  -- /* PROCEDURE > toggle_debug ------------------------------------------------------------- ADMIN_LOGGER_CONFIG ----- */
  --
  PROCEDURE toggle_debug        ( modus                   IN VARCHAR2 DEFAULT c_off,
                                  set_debug_target        IN CHAR     DEFAULT g_debug_target )
  IS
    PRAGMA                   AUTONOMOUS_TRANSACTION;
    l_old_module             VARCHAR2(64);
    l_old_action             VARCHAR2(64);
    l_old_client             VARCHAR2(64);
  l_config_before config_rt;
  l_saved BOOLEAN:=FALSE;
  BEGIN
    DBMS_APPLICATION_INFO.READ_MODULE(l_old_module, l_old_action);
  DBMS_APPLICATION_INFO.READ_CLIENT_INFO(l_old_client);
  IF UPPER(modus)=c_helpme THEN
    help('HELP TLD');
  ELSE
    /* VALIDATE INPUT PARAMETERS */
    IF modus IS NULL OR UPPER(modus) NOT IN (c_on,c_off)
       OR set_debug_target IS NULL OR UPPER(set_debug_target) NOT IN (c_s,c_to_table) THEN
  	  RAISE failure_in_calling;
  	END IF;
    session_details;
    l_config_before:=g_config_rt;
    DBMS_APPLICATION_INFO.SET_MODULE('ADMIN_LOGGER.toggle_debug','Change session configuration');
    g_config_rt.debug_on:=UPPER(modus)=c_on;
    g_config_rt.debug_target:=UPPER(set_debug_target);
    save_logger_config;
    l_saved:=TRUE;
    END IF;
    DBMS_APPLICATION_INFO.SET_CLIENT_INFO(l_old_client);
    DBMS_APPLICATION_INFO.SET_MODULE(l_old_module,l_old_action);
  COMMIT;
  EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  IF NOT l_saved AND l_config_before.config_id IS NOT NULL THEN
    g_config_rt:=l_config_before;
  END IF;
  BEGIN
      DBMS_APPLICATION_INFO.SET_CLIENT_INFO(l_old_client);
      DBMS_APPLICATION_INFO.SET_MODULE(l_old_module,l_old_action);
  EXCEPTION WHEN OTHERS THEN NULL; END;
      RAISE;
  END toggle_debug;
  --
  -- /* PROCEDURE > toggle_batch ------------------------------------------------------------- ADMIN_LOGGER_CONFIG ----- */
  --
  PROCEDURE toggle_batch     ( modus IN VARCHAR2 DEFAULT c_off, batch IN VARCHAR2 DEFAULT c_single )
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  	p_batch                  VARCHAR2(4);
    l_old_module             VARCHAR2(64);
    l_old_action             VARCHAR2(64);
    l_old_client             VARCHAR2(64);
  l_config_before config_rt;
  l_logging_before logging_rt;
  l_saved BOOLEAN:=FALSE;
  BEGIN
    DBMS_APPLICATION_INFO.READ_MODULE(l_old_module, l_old_action);
    DBMS_APPLICATION_INFO.READ_CLIENT_INFO(l_old_client);
  IF UPPER(modus)=c_helpme OR UPPER(batch)=c_helpme THEN
    help('HELP TBI');
  ELSE
    /* VALIDATE INPUT PARAMETERS */
    IF modus IS NULL OR UPPER(modus) NOT IN (c_on,c_off)
       OR batch IS NULL OR UPPER(batch) NOT IN (c_s,c_single,c_b,c_batch) THEN
  	  RAISE failure_in_calling;
  	END IF;
    session_details;
    l_config_before:=g_config_rt;
    l_logging_before:=g_logging_rt;
    p_batch:=CASE WHEN UPPER(batch) IN (c_b,c_batch) THEN c_b ELSE c_s END;
    DBMS_APPLICATION_INFO.SET_MODULE('ADMIN_LOGGER.toggle_batch','Change batch mode');
    IF UPPER(modus)=c_off OR p_batch=c_s THEN
  	  g_config_rt.batch_mode  := c_s;
  	  g_logging_rt.log_batch  := 0;
  	  g_logging_rt.log_lines  := 0;
    ELSE
      IF g_config_rt.batch_mode!=c_b OR g_logging_rt.log_batch IS NULL
         OR g_logging_rt.log_batch<=0 THEN
  		  SELECT tetools.admin_logger_logbatch_seq.NEXTVAL INTO g_logging_rt.log_batch FROM dual;
  		  g_logging_rt.log_lines  := 1;
  	  END IF;
      g_config_rt.batch_mode:=c_b;
  	END IF;
  	save_logger_config;
    l_saved:=TRUE;
  END IF;
      DBMS_APPLICATION_INFO.SET_CLIENT_INFO(l_old_client);
      DBMS_APPLICATION_INFO.SET_MODULE(l_old_module,l_old_action);
  COMMIT;
  EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  IF NOT l_saved AND l_config_before.config_id IS NOT NULL THEN
    g_config_rt:=l_config_before;
    g_logging_rt:=l_logging_before;
  END IF;
  BEGIN
      DBMS_APPLICATION_INFO.SET_CLIENT_INFO(l_old_client);
      DBMS_APPLICATION_INFO.SET_MODULE(l_old_module,l_old_action);
  EXCEPTION WHEN OTHERS THEN NULL; END;
      RAISE;
  END toggle_batch;
  --
  -- /* PROCEDURE > exception_logging -------------------------------------------------- ADMIN_LOGGER_LOGGING_CLOB ----- */
  --
   PROCEDURE exception_logging ( context         IN VARCHAR2,
                                 data            IN CLOB,
  								 callstack       IN CLOB,
  							     category        IN VARCHAR2 ) 
   IS 
    PRAGMA AUTONOMOUS_TRANSACTION;
  l_null CHAR(1);
  	v_sql_logger             VARCHAR2(4000) := 'INSERT INTO TETOOLS.ADMIN_LOGGER_LOG (created_on, logsession_id, logbatch_id, log_category, log_lines, context, text, callstack) VALUES (:1, :2, :3, :4, :5, :6, :7, :8)';
   BEGIN
  -- Use only cached valid identity. Never look up or repair a session here.
  IF g_session_rt.logsession_id IS NULL OR g_session_rt.logsession_id<=0 THEN
    RAISE missing_logsession;
  	END IF;
  EXECUTE IMMEDIATE v_sql_logger USING SYSTIMESTAMP,g_session_rt.logsession_id,
    l_null,category,l_null,context,data,callstack;
    COMMIT;
  EXCEPTION WHEN OTHERS THEN
  	  ROLLBACK;
      RAISE;
  END exception_logging; 
  --
  -- /* PROCEDURE > internal_logging --------------------------------------------------- ADMIN_LOGGER_LOGGING_CHAR ----- */
  --
  PROCEDURE internal_logging ( context_in      IN VARCHAR2,
                               data_in         IN VARCHAR2,
  							   logcategory     IN VARCHAR2,
  						       override_target IN CHAR    DEFAULT g_override_target,
  						       override_in     IN BOOLEAN DEFAULT g_debug_on )
  IS 
    PRAGMA AUTONOMOUS_TRANSACTION; 
  l_log_it BOOLEAN:=FALSE;
  l_override_target CHAR(1);
  l_batch admin_logger_log.logbatch_id%TYPE;
  l_line admin_logger_log.log_lines%TYPE;
    l_old_module             VARCHAR2(64);
    l_old_action             VARCHAR2(64);
    l_old_client             VARCHAR2(64);
  v_this_object VARCHAR2(32767);
  v_caller VARCHAR2(32767);
  	v_result                 CLOB;
  	v_backtrace              CLOB;
  v_callstack CLOB;
  	v_sql_logger             VARCHAR2(4000) := 'INSERT INTO TETOOLS.ADMIN_LOGGER_LOG (created_on, logsession_id, logbatch_id, log_category, log_lines, context, text, callstack) VALUES (:1, :2, :3, :4, :5, :6, :7, :8)';
  BEGIN
    DBMS_APPLICATION_INFO.READ_MODULE(l_old_module, l_old_action);
  DBMS_APPLICATION_INFO.READ_CLIENT_INFO(l_old_client);
    session_details;
  -- Permission and destination use the same validated state.
  IF override_in IS NULL THEN RAISE invalid_parameter; END IF;
  IF override_in THEN
    l_log_it:=TRUE;
    l_override_target:=override_target;
  ELSIF logcategory='DEBUG' THEN
    l_log_it:=g_config_rt.debug_on;
              l_override_target    := g_config_rt.debug_target;
  		    ELSE
    l_log_it:=g_config_rt.logging_on OR g_config_rt.debug_on;
    l_override_target:=CASE WHEN g_config_rt.debug_on THEN g_config_rt.debug_target
                            ELSE g_config_rt.logging_target END;
  		    END IF;
  IF l_log_it THEN
    BEGIN
      who_called(2,v_this_object);
      who_called(LEAST(3,UTL_CALL_STACK.dynamic_depth+1),v_caller);
    EXCEPTION WHEN OTHERS THEN
      -- Optional name lookup must not stop the actual log write.
      v_this_object:='ADMIN_LOGGER.internal_logging';
      v_caller:='[caller unavailable]';
    END;
    DBMS_APPLICATION_INFO.SET_MODULE('ADMIN_LOGGER.internal_logging','Write log row');
    DBMS_APPLICATION_INFO.SET_CLIENT_INFO('Called by '||SUBSTR(v_caller,1,54));
    v_callstack:=DBMS_UTILITY.format_call_stack;
  	  IF    l_override_target = c_to_screen  THEN
  	    put_line (data_in); 
  	  ELSIF l_override_target = c_to_table   THEN
      IF g_config_rt.batch_mode=c_b THEN
        l_batch:=g_logging_rt.log_batch;
        l_line:=g_logging_rt.log_lines;
        IF l_batch IS NULL OR l_batch<=0 OR l_line IS NULL OR l_line<=0 THEN
          RAISE invalid_parameter;
        END IF;
      END IF;
      EXECUTE IMMEDIATE v_sql_logger USING SYSTIMESTAMP,g_session_rt.logsession_id,
        l_batch,logcategory,l_line,context_in,data_in,v_callstack;
  		COMMIT;
  	    IF    g_config_rt.batch_mode = c_b THEN
  	      g_logging_rt.log_lines  := g_logging_rt.log_lines + 1;
        END IF;
    ELSE RAISE corrupt_logger_target;
  	  END IF;
    END IF;
  COMMIT;
    DBMS_APPLICATION_INFO.SET_CLIENT_INFO(l_old_client);
    DBMS_APPLICATION_INFO.SET_MODULE(l_old_module,l_old_action);
  EXCEPTION WHEN OTHERS THEN
  v_result:=DBMS_UTILITY.format_error_stack;
  v_backtrace:=DBMS_UTILITY.format_error_backtrace;
  v_callstack:=DBMS_UTILITY.format_call_stack;
  ROLLBACK;
  BEGIN
    exception_logging(context_in,
      TO_CLOB(v_this_object)||' called by '||v_caller||': '||v_result||CHR(10)||'BACKTRACE:'||CHR(10)||v_backtrace,
      v_callstack,'ERROR');
  EXCEPTION WHEN OTHERS THEN NULL; END;
  BEGIN
      DBMS_APPLICATION_INFO.SET_CLIENT_INFO(l_old_client);
      DBMS_APPLICATION_INFO.SET_MODULE(l_old_module,l_old_action);
  EXCEPTION WHEN OTHERS THEN NULL; END;
      RAISE;
  END internal_logging; 
  --
  -- /* PROCEDURE > internal_logging --------------------------------------------------- ADMIN_LOGGER_LOGGING_CLOB ----- */
  --
   PROCEDURE internal_logging ( context_in      IN VARCHAR2,
                                data_in         IN CLOB,
  							    logcategory     IN VARCHAR2,
  							    override_target IN CHAR    DEFAULT g_override_target,
  							    override_in     IN BOOLEAN DEFAULT g_debug_on ) 
   IS 
    PRAGMA AUTONOMOUS_TRANSACTION;
  l_log_it BOOLEAN:=FALSE;
  l_override_target CHAR(1);
  l_batch admin_logger_log.logbatch_id%TYPE;
  l_line admin_logger_log.log_lines%TYPE;
    l_old_module             VARCHAR2(64);
    l_old_action             VARCHAR2(64);
    l_old_client             VARCHAR2(64);
  v_this_object VARCHAR2(32767);
  v_caller VARCHAR2(32767);
  	v_result                 CLOB;
  	v_backtrace              CLOB;
  v_callstack CLOB;
  	v_sql_logger             VARCHAR2(4000) := 'INSERT INTO TETOOLS.ADMIN_LOGGER_LOG (created_on, logsession_id, logbatch_id, log_category, log_lines, context, text, callstack) VALUES (:1, :2, :3, :4, :5, :6, :7, :8)';
   BEGIN
    DBMS_APPLICATION_INFO.READ_MODULE(l_old_module, l_old_action);
  DBMS_APPLICATION_INFO.READ_CLIENT_INFO(l_old_client);
    session_details;
  -- Permission and destination use the same validated state.
  IF override_in IS NULL THEN RAISE invalid_parameter; END IF;
  IF override_in THEN
    l_log_it:=TRUE;
    l_override_target:=override_target;
  ELSIF logcategory='DEBUG' THEN
    l_log_it:=g_config_rt.debug_on;
              l_override_target    := g_config_rt.debug_target;
  	        ELSE
    l_log_it:=g_config_rt.logging_on OR g_config_rt.debug_on;
    l_override_target:=CASE WHEN g_config_rt.debug_on THEN g_config_rt.debug_target
                            ELSE g_config_rt.logging_target END;
  	        END IF;
  IF l_log_it THEN
    BEGIN
      who_called(2,v_this_object);
      who_called(LEAST(3,UTL_CALL_STACK.dynamic_depth+1),v_caller);
    EXCEPTION WHEN OTHERS THEN
      -- Optional name lookup must not stop the actual log write.
      v_this_object:='ADMIN_LOGGER.internal_logging';
      v_caller:='[caller unavailable]';
    END;
    DBMS_APPLICATION_INFO.SET_MODULE('ADMIN_LOGGER.internal_logging','Write log row');
    DBMS_APPLICATION_INFO.SET_CLIENT_INFO('Called by '||SUBSTR(v_caller,1,54));
    v_callstack:=DBMS_UTILITY.format_call_stack;
  	  IF    l_override_target = c_to_screen  THEN
  	    put_line (data_in); 
  	  ELSIF l_override_target = c_to_table   THEN
      IF g_config_rt.batch_mode=c_b THEN
        l_batch:=g_logging_rt.log_batch;
        l_line:=g_logging_rt.log_lines;
        IF l_batch IS NULL OR l_batch<=0 OR l_line IS NULL OR l_line<=0 THEN
          RAISE invalid_parameter;
        END IF;
      END IF;
      EXECUTE IMMEDIATE v_sql_logger USING SYSTIMESTAMP,g_session_rt.logsession_id,
        l_batch,logcategory,l_line,context_in,data_in,v_callstack;
  		COMMIT;
  	    IF    g_config_rt.batch_mode = c_b THEN
  	      g_logging_rt.log_lines  := g_logging_rt.log_lines + 1;
        END IF;
    ELSE RAISE corrupt_logger_target;
  	  END IF;
    END IF;
  COMMIT;
    DBMS_APPLICATION_INFO.SET_CLIENT_INFO(l_old_client);
    DBMS_APPLICATION_INFO.SET_MODULE(l_old_module,l_old_action);
  EXCEPTION WHEN OTHERS THEN
  v_result:=DBMS_UTILITY.format_error_stack;
  v_backtrace:=DBMS_UTILITY.format_error_backtrace;
  v_callstack:=DBMS_UTILITY.format_call_stack;
  ROLLBACK;
  BEGIN
    exception_logging(context_in,
      TO_CLOB(v_this_object)||' called by '||v_caller||': '||v_result||CHR(10)||'BACKTRACE:'||CHR(10)||v_backtrace,
      v_callstack,'ERROR');
  EXCEPTION WHEN OTHERS THEN NULL; END;
  BEGIN
      DBMS_APPLICATION_INFO.SET_CLIENT_INFO(l_old_client);
      DBMS_APPLICATION_INFO.SET_MODULE(l_old_module,l_old_action);
  EXCEPTION WHEN OTHERS THEN NULL; END;
      RAISE;
  END internal_logging;
  --
  --
  --
  FUNCTION LOG_RUNTIME (context_in IN VARCHAR2, data_in IN VARCHAR2) RETURN PLS_INTEGER
  IS
  BEGIN
    LOG_RUNTIME (context_in, data_in); 
    RETURN 1; 
  END LOG_RUNTIME;
--
  PROCEDURE LOG_RUNTIME (context_in IN VARCHAR2, data_in IN VARCHAR2) 
  IS
  BEGIN
  internal_logging(context_in,data_in,'RUNTIME',c_to_table,
    override_in=>c_false);
  END LOG_RUNTIME;
--
  PROCEDURE LOG_RUNTIME (context_in IN VARCHAR2, data_in IN CLOB)
  IS
  BEGIN
  internal_logging(context_in,data_in,'RUNTIME',c_to_table,
    override_in=>c_false);
  END LOG_RUNTIME; 
--
  PROCEDURE LOG_RUNTIME (context_in IN VARCHAR2, data_in IN BOOLEAN)
  IS
  BEGIN
  internal_logging(context_in,bool2vc(data_in),'RUNTIME',c_to_table,
    override_in=>c_false);
  END LOG_RUNTIME; 
--
  PROCEDURE LOG_RUNTIME (context_in IN VARCHAR2, data_in IN DATE, format_in IN VARCHAR2 DEFAULT c_date_mask )
  IS
  BEGIN
  internal_logging(context_in,TO_CHAR(data_in,format_in),'RUNTIME',c_to_table,
    override_in=>c_false);
  END LOG_RUNTIME; 
--
--
--
FUNCTION LOG_INFO (context_in IN VARCHAR2, data_in IN VARCHAR2) RETURN PLS_INTEGER
IS
BEGIN
  LOG_INFO (context_in, data_in); 
  RETURN 1; 
END LOG_INFO;
--
  PROCEDURE LOG_INFO (context_in IN VARCHAR2, data_in IN VARCHAR2) 
  IS
  BEGIN
  internal_logging(context_in,data_in,'INFO',c_to_table,
    override_in=>c_false);
  END LOG_INFO;
--
  PROCEDURE LOG_INFO (context_in IN VARCHAR2, data_in IN CLOB)
  IS
  BEGIN
  internal_logging(context_in,data_in,'INFO',c_to_table,
    override_in=>c_false);
  END LOG_INFO; 
--
  PROCEDURE LOG_INFO (context_in IN VARCHAR2, data_in IN BOOLEAN)
  IS
  BEGIN
  internal_logging(context_in,bool2vc(data_in),'INFO',c_to_table,
    override_in=>c_false);
  END LOG_INFO; 
--
  PROCEDURE LOG_INFO (context_in IN VARCHAR2, data_in IN DATE, format_in IN VARCHAR2 DEFAULT c_date_mask )
  IS
  BEGIN
  internal_logging(context_in,TO_CHAR(data_in,format_in),'INFO',c_to_table,
    override_in=>c_false);
  END LOG_INFO; 
--
--
--
FUNCTION LOG_WARNING (context_in IN VARCHAR2, data_in IN VARCHAR2) RETURN PLS_INTEGER
IS
BEGIN
  LOG_WARNING (context_in, data_in); 
  RETURN 1; 
END LOG_WARNING;
--
  PROCEDURE LOG_WARNING (context_in IN VARCHAR2, data_in IN VARCHAR2) 
  IS
  BEGIN
  internal_logging(context_in,data_in,'WARNING',c_to_table,
    override_in=>c_false);
  END LOG_WARNING;
--
  PROCEDURE LOG_WARNING (context_in IN VARCHAR2, data_in IN CLOB)
  IS
  BEGIN
  internal_logging(context_in,data_in,'WARNING',c_to_table,
    override_in=>c_false);
  END LOG_WARNING; 
--
  PROCEDURE LOG_WARNING (context_in IN VARCHAR2, data_in IN BOOLEAN)
  IS
  BEGIN
  internal_logging(context_in,bool2vc(data_in),'WARNING',c_to_table,
    override_in=>c_false);
  END LOG_WARNING; 
--
  PROCEDURE LOG_WARNING (context_in IN VARCHAR2, data_in IN DATE, format_in IN VARCHAR2 DEFAULT c_date_mask )
  IS
  BEGIN
  internal_logging(context_in,TO_CHAR(data_in,format_in),'WARNING',c_to_table,
    override_in=>c_false);
  END LOG_WARNING; 
--
--
--
FUNCTION  LOG_ERROR (context_in IN VARCHAR2, data_in IN VARCHAR2) RETURN PLS_INTEGER
IS
BEGIN
  LOG_ERROR (context_in, data_in); 
  RETURN 1; 
END LOG_ERROR;
--
  PROCEDURE LOG_ERROR (context_in IN VARCHAR2, data_in IN VARCHAR2) 
  IS
  BEGIN
  internal_logging(context_in,data_in,'ERROR',c_to_table,
    override_in=>c_false);
  END LOG_ERROR;
--
  PROCEDURE LOG_ERROR (context_in IN VARCHAR2, data_in IN CLOB)
  IS
  BEGIN
  internal_logging(context_in,data_in,'ERROR',c_to_table,
    override_in=>c_false);
  END LOG_ERROR; 
--
  PROCEDURE LOG_ERROR (context_in IN VARCHAR2, data_in IN BOOLEAN)
  IS
  BEGIN
  internal_logging(context_in,bool2vc(data_in),'ERROR',c_to_table,
    override_in=>c_false);
  END LOG_ERROR; 
--
  PROCEDURE LOG_ERROR (context_in IN VARCHAR2, data_in IN DATE, format_in IN VARCHAR2 DEFAULT c_date_mask )
  IS
  BEGIN
  internal_logging(context_in,TO_CHAR(data_in,format_in),'ERROR',c_to_table,
    override_in=>c_false);
  END LOG_ERROR;
--
--
--
FUNCTION  LOG_DEBUG (context_in IN VARCHAR2, data_in IN VARCHAR2) RETURN PLS_INTEGER
IS
BEGIN
  LOG_DEBUG (context_in, data_in); 
  RETURN 1; 
END LOG_DEBUG;
--
  PROCEDURE LOG_DEBUG (context_in IN VARCHAR2, data_in IN VARCHAR2) 
  IS
  BEGIN
  internal_logging(context_in,data_in,'DEBUG',c_to_table,
    override_in=>c_false);
  END LOG_DEBUG;
--
  PROCEDURE LOG_DEBUG (context_in IN VARCHAR2, data_in IN CLOB)
  IS
  BEGIN
  internal_logging(context_in,data_in,'DEBUG',c_to_table,
    override_in=>c_false);
  END LOG_DEBUG; 
--
  PROCEDURE LOG_DEBUG (context_in IN VARCHAR2, data_in IN BOOLEAN)
  IS
  BEGIN
  internal_logging(context_in,bool2vc(data_in),'DEBUG',c_to_table,
    override_in=>c_false);
  END LOG_DEBUG; 
--
  PROCEDURE LOG_DEBUG (context_in IN VARCHAR2, data_in IN DATE, format_in IN VARCHAR2 DEFAULT c_date_mask )
  IS
  BEGIN
  internal_logging(context_in,TO_CHAR(data_in,format_in),'DEBUG',c_to_table,
    override_in=>c_false);
  END LOG_DEBUG; 
--
--
--
FUNCTION LOG_RUNTIME_FORCE (context_in IN VARCHAR2, data_in IN VARCHAR2) RETURN PLS_INTEGER
IS
BEGIN
  LOG_RUNTIME_FORCE (context_in, data_in); 
  RETURN 1; 
END LOG_RUNTIME_FORCE;
--
  PROCEDURE LOG_RUNTIME_FORCE (context_in IN VARCHAR2, data_in IN VARCHAR2)
  IS
  BEGIN
  internal_logging(context_in,data_in,'RUNTIME',c_to_table,
    override_in=>c_true);
  END LOG_RUNTIME_FORCE;
--
  PROCEDURE LOG_RUNTIME_FORCE (context_in IN VARCHAR2, data_in IN CLOB)
  IS 
  BEGIN
  internal_logging(context_in,data_in,'RUNTIME',c_to_table,
    override_in=>c_true);
  END LOG_RUNTIME_FORCE;
--
  PROCEDURE LOG_RUNTIME_FORCE (context_in IN VARCHAR2, data_in IN BOOLEAN)
  IS 
  BEGIN
  internal_logging(context_in,bool2vc(data_in),'RUNTIME',c_to_table,
    override_in=>c_true);
  END LOG_RUNTIME_FORCE; 
--
  PROCEDURE LOG_RUNTIME_FORCE (context_in IN VARCHAR2, data_in IN DATE, format_in IN VARCHAR2 DEFAULT c_date_mask)
  IS 
  BEGIN
  internal_logging(context_in,TO_CHAR(data_in,format_in),'RUNTIME',c_to_table,
    override_in=>c_true);
  END LOG_RUNTIME_FORCE;
--
--
--
FUNCTION  LOG_INFO_FORCE (context_in IN VARCHAR2, data_in IN VARCHAR2 ) RETURN PLS_INTEGER
IS
BEGIN
  LOG_INFO_FORCE (context_in, data_in); 
  RETURN 1; 
END LOG_INFO_FORCE;
--
  PROCEDURE LOG_INFO_FORCE (context_in IN VARCHAR2, data_in IN VARCHAR2) 
  IS
  BEGIN
  internal_logging(context_in,data_in,'INFO',c_to_table,
    override_in=>c_true);
  END LOG_INFO_FORCE;
--
  PROCEDURE LOG_INFO_FORCE (context_in IN VARCHAR2, data_in IN CLOB)
  IS 
  BEGIN
  internal_logging(context_in,data_in,'INFO',c_to_table,
    override_in=>c_true);
  END LOG_INFO_FORCE;
--
  PROCEDURE LOG_INFO_FORCE (context_in IN VARCHAR2, data_in IN BOOLEAN)
  IS 
  BEGIN
  internal_logging(context_in,bool2vc(data_in),'INFO',c_to_table,
    override_in=>c_true);
  END LOG_INFO_FORCE; 
--
  PROCEDURE LOG_INFO_FORCE (context_in IN VARCHAR2, data_in IN DATE, format_in IN VARCHAR2 DEFAULT c_date_mask)
  IS 
  BEGIN
  internal_logging(context_in,TO_CHAR(data_in,format_in),'INFO',c_to_table,
    override_in=>c_true);
  END LOG_INFO_FORCE;
--
--
--
FUNCTION  LOG_WARNING_FORCE (context_in IN VARCHAR2, data_in IN VARCHAR2) RETURN PLS_INTEGER
IS
BEGIN
  LOG_WARNING_FORCE (context_in, data_in); 
  RETURN 1; 
END LOG_WARNING_FORCE;
--
  PROCEDURE LOG_WARNING_FORCE (context_in IN VARCHAR2, data_in IN VARCHAR2)
  IS
  BEGIN
  internal_logging(context_in,data_in,'WARNING',c_to_table,
    override_in=>c_true);
  END LOG_WARNING_FORCE;
--
  PROCEDURE LOG_WARNING_FORCE (context_in IN VARCHAR2, data_in IN CLOB)
  IS 
  BEGIN
  internal_logging(context_in,data_in,'WARNING',c_to_table,
    override_in=>c_true);
  END LOG_WARNING_FORCE;
--
  PROCEDURE LOG_WARNING_FORCE (context_in IN VARCHAR2, data_in IN BOOLEAN)
  IS 
  BEGIN
  internal_logging(context_in,bool2vc(data_in),'WARNING',c_to_table,
    override_in=>c_true);
  END LOG_WARNING_FORCE; 
--
  PROCEDURE LOG_WARNING_FORCE (context_in IN VARCHAR2, data_in IN DATE, format_in IN VARCHAR2 DEFAULT c_date_mask)
  IS 
  BEGIN
  internal_logging(context_in,TO_CHAR(data_in,format_in),'WARNING',c_to_table,
    override_in=>c_true);
  END LOG_WARNING_FORCE;
--
--
--
FUNCTION  LOG_ERROR_FORCE (context_in IN VARCHAR2, data_in IN VARCHAR2) RETURN PLS_INTEGER 
IS
BEGIN
  LOG_ERROR_FORCE (context_in, data_in); 
  RETURN 1; 
END LOG_ERROR_FORCE;
--
  PROCEDURE LOG_ERROR_FORCE (context_in IN VARCHAR2, data_in IN VARCHAR2) 
  IS
  BEGIN
  internal_logging(context_in,data_in,'ERROR',c_to_table,
    override_in=>c_true);
  END LOG_ERROR_FORCE;
--
  PROCEDURE LOG_ERROR_FORCE (context_in IN VARCHAR2, data_in IN CLOB)
  IS 
  BEGIN
  internal_logging(context_in,data_in,'ERROR',c_to_table,
    override_in=>c_true);
  END LOG_ERROR_FORCE;
--
  PROCEDURE LOG_ERROR_FORCE (context_in IN VARCHAR2, data_in IN BOOLEAN)
  IS 
  BEGIN
  internal_logging(context_in,bool2vc(data_in),'ERROR',c_to_table,
    override_in=>c_true);
  END LOG_ERROR_FORCE; 
--
  PROCEDURE LOG_ERROR_FORCE (context_in IN VARCHAR2, data_in IN DATE, format_in IN VARCHAR2 DEFAULT c_date_mask)
  IS 
  BEGIN
  internal_logging(context_in,TO_CHAR(data_in,format_in),'ERROR',c_to_table,
    override_in=>c_true);
  END LOG_ERROR_FORCE;
  --
  -- /* PROCEDURES > clear_session_entries ------------------------------------------------ ADMIN_LOGGER_SESSIONS ----- */
  --
  PROCEDURE clear_session_entries ( before_in IN VARCHAR2 DEFAULT NULL ) 
  IS
    PRAGMA                   AUTONOMOUS_TRANSACTION; 
    v_check_date DATE;
    v_before_in DATE:=TRUNC(SYSDATE);
    l_count PLS_INTEGER;
    l_old_module             VARCHAR2(64);
    l_old_action             VARCHAR2(64);
    sess_del_sql             CLOB := 'DELETE FROM tetools.admin_logger_sessions WHERE logsession_id = :1';
    conf_del_sql             CLOB := 'DELETE FROM tetools.admin_logger_config WHERE logsession_id = :1';
    CURSOR c_old_sessions(p_logondate IN DATE) IS
  	WITH cte_sessions AS (
      SELECT SID
           , SERIAL#
           , AUDSID
           , LOGON_USER AS "USERNAME"
           , LOGON_TIME
        FROM ADMIN_LOGGER_SESSIONS
    minus
    SELECT SID
         , SERIAL#
         , AUDSID
         , USERNAME
         , LOGON_TIME
      FROM V$SESSION
    )
    ,    cte_als AS (
    SELECT als.LOGSESSION_ID
      FROM ADMIN_LOGGER_SESSIONS als
      JOIN CTE_sessions          ses ON als.SID = ses.SID AND als.SERIAL# = ses.SERIAL# AND als.AUDSID = ses.AUDSID AND als.LOGON_TIME = ses.LOGON_TIME
     WHERE TRUNC( als.LOGON_TIME) < p_logondate - 3
    )
    SELECT LOGSESSION_ID FROM cte_als ORDER BY 1;
  --

  BEGIN
    DBMS_APPLICATION_INFO.READ_MODULE(l_old_module,l_old_action);
    IF UPPER(before_in)=c_helpme THEN
      help('HELP CSE');
    ELSE
      IF before_in IS NOT NULL THEN
        IF LENGTH(before_in)=10 THEN v_check_date:=TO_DATE(before_in,'FXYYYY-MM-DD');
        ELSIF LENGTH(before_in)=19 THEN v_check_date:=TO_DATE(before_in,'FXYYYY-MM-DD HH24:MI:SS');
        ELSE RAISE failure_in_calling;
  	END IF;
        v_before_in:=TRUNC(v_check_date);
  	  END IF;
      DBMS_APPLICATION_INFO.SET_MODULE('ADMIN_LOGGER.clear_session_entries','Purge by day boundary');
      SELECT guard_id INTO l_count FROM tetools.admin_logger_guard
       WHERE guard_id=1 FOR UPDATE WAIT 5;
      FOR r_row IN c_old_sessions(v_before_in) LOOP
  	  EXECUTE IMMEDIATE conf_del_sql USING r_row.logsession_id;
  	  EXECUTE IMMEDIATE sess_del_sql USING r_row.logsession_id;
    END LOOP;
    COMMIT;
    END IF;
    DBMS_APPLICATION_INFO.SET_MODULE(l_old_module,l_old_action);
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    BEGIN
      DBMS_APPLICATION_INFO.SET_MODULE(l_old_module,l_old_action);
    EXCEPTION WHEN OTHERS THEN NULL; END;
      RAISE;
  END clear_session_entries; 
  --
  -- /* PROCEDURES > clear_log_entries ----------------------------------------------------- ADMIN_LOGGER_LOGGING ----- */
  --
  PROCEDURE clear_log_entries ( before_in IN VARCHAR2 DEFAULT NULL ) 
  IS
    PRAGMA                   AUTONOMOUS_TRANSACTION; 
  	v_check_date             DATE;
  v_before_in DATE:=TRUNC(SYSDATE);
  l_count PLS_INTEGER;
    l_old_module             VARCHAR2(64);
    l_old_action             VARCHAR2(64);
  all_del_sql CLOB:=q'[DELETE FROM tetools.admin_logger_log l WHERE l.created_on<=:1
    AND NOT EXISTS (SELECT 1 FROM tetools.admin_logger_config c
      WHERE c.batch_mode='B' AND c.logsession_id=l.logsession_id
        AND c.logbatch_id=l.logbatch_id)]';

  BEGIN
  DBMS_APPLICATION_INFO.READ_MODULE(l_old_module,l_old_action);
  IF UPPER(before_in)=c_helpme THEN
    help('HELP CLS');
  ELSE
    IF before_in IS NOT NULL THEN
      IF LENGTH(before_in)=10 THEN v_check_date:=TO_DATE(before_in,'FXYYYY-MM-DD');
      ELSIF LENGTH(before_in)=19 THEN v_check_date:=TO_DATE(before_in,'FXYYYY-MM-DD HH24:MI:SS');
      ELSE RAISE failure_in_calling;
  	END IF;
      v_before_in:=TRUNC(v_check_date);
  	  END IF;
    DBMS_APPLICATION_INFO.SET_MODULE('ADMIN_LOGGER.clear_log_entries','Purge by day boundary');
    SELECT guard_id INTO l_count FROM tetools.admin_logger_guard
     WHERE guard_id=1 FOR UPDATE WAIT 5;
    EXECUTE IMMEDIATE all_del_sql USING v_before_in;
    COMMIT;
  	  END IF;
    DBMS_APPLICATION_INFO.SET_MODULE(l_old_module,l_old_action);
  EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  BEGIN
      DBMS_APPLICATION_INFO.SET_MODULE(l_old_module,l_old_action);
  EXCEPTION WHEN OTHERS THEN NULL; END;
      RAISE;
  END clear_log_entries; 
  --
  -- /* PROCEDURES > put_lines ---------------------------------------------------------------------- DBMS_OUTPUT ----- */
  --
   PROCEDURE put_line (data_in IN VARCHAR2) 
   IS 
   BEGIN 
      DBMS_OUTPUT.put_line (data_in); 
   END put_line; 
  --
   PROCEDURE put_line (data_in IN DATE,format_in IN VARCHAR2 DEFAULT c_date_mask ) 
   IS 
   BEGIN 
      DBMS_OUTPUT.put_line (TO_CHAR (data_in, format_in)); 
   END put_line; 
  --
   PROCEDURE put_line (data_in IN BOOLEAN) 
   IS 
   BEGIN 
      DBMS_OUTPUT.put_line (bool2vc (data_in)); 
   END put_line; 
  --
   PROCEDURE put_line (title_in IN VARCHAR2, data_in IN BOOLEAN) 
   IS 
   BEGIN 
      DBMS_OUTPUT.put_line ( title_in || ' - ' || bool2vc (data_in)); 
   END put_line; 
  --
  PROCEDURE put_line ( clob_in IN CLOB ) 
  IS 
  	PROCEDURE print_clob ( p_clob_in IN CLOB) is
    l_offset NUMBER:=1;
    l_total_length NUMBER;
    l_line_end NUMBER;
    l_len NUMBER;
      l_line         VARCHAR2(32767);
    BEGIN
  	  IF p_clob_in IS NULL THEN RETURN; END IF;
    l_total_length:=DBMS_LOB.GETLENGTH(p_clob_in);
    WHILE l_offset<=l_total_length LOOP
      l_line_end:=DBMS_LOB.INSTR(p_clob_in,CHR(10),l_offset);
      IF l_line_end=0 THEN l_line_end:=l_total_length+1; END IF;
      l_len:=l_line_end-l_offset;
      IF l_len=0 THEN DBMS_OUTPUT.PUT_LINE(NULL);
      ELSE
        WHILE l_len>0 LOOP
          -- Wrap long logical lines at up to 4000 UCS2 code points.
          -- Advance in CLOB units, including both units of a surrogate pair.
          l_line:=DBMS_LOB.SUBSTR(p_clob_in,LEAST(4000,l_len),l_offset);
          IF l_line IS NULL THEN RAISE VALUE_ERROR; END IF;
  		DBMS_OUTPUT.PUT_LINE(l_line);
          l_offset:=l_offset+LENGTH2(l_line);
          l_len:=l_line_end-l_offset;
  	  END LOOP;
      END IF;
      l_offset:=l_line_end+1;
    END LOOP;
  END print_clob;
  BEGIN
  -- After package initialization, this procedure has no logger-state side effects.
  	print_clob(clob_in);
  END put_line; 
  --
  -- /* PROCEDURE > initialize --------------------------------------------------------------- ADMIN_LOGGER_SETTINGS ----- */
  --
  PROCEDURE initialize 
  IS 
    PRAGMA                   AUTONOMOUS_TRANSACTION; 
    l_count                  PLS_INTEGER;
  v_logsession_id admin_logger_sessions.logsession_id%TYPE;
  	l_null                   CHAR(1);
    v_sql_config             VARCHAR2(4000);
    v_sql_sessions           VARCHAR2(4000);
  BEGIN
  SELECT guard_id INTO l_count FROM tetools.admin_logger_guard
   WHERE guard_id=1 FOR UPDATE WAIT 5;
  	load_session_details(TRUE);
  	v_sql_sessions := 'INSERT INTO TETOOLS.ADMIN_LOGGER_SESSIONS (created_on, sid, serial#, audsid, logon_user, logon_time, current_user, current_schema, proxy_user) VALUES (:1, :2, :3, :4, :5, :6, :7, :8, :9)';
  	v_sql_config   := 'INSERT INTO TETOOLS.ADMIN_LOGGER_CONFIG (created_on, logsession_id, logger_on, logger_target, debug_on, debug_target, batch_mode, logbatch_id) VALUES (:1, :2, :3, :4, :5, :6, :7, :8)';
  IF g_session_rt.logsession_id=0 THEN
    EXECUTE IMMEDIATE v_sql_sessions || ' RETURNING logsession_id INTO :new_session'
      USING SYSTIMESTAMP,g_session_rt.sid,g_session_rt.serial#,g_session_rt.audsid,
        g_session_rt.logon_user,g_session_rt.logon_time,g_session_rt.current_user,
        g_session_rt.current_schema,g_session_rt.proxy_user
      RETURNING INTO v_logsession_id;
    EXECUTE IMMEDIATE v_sql_config USING SYSTIMESTAMP,v_logsession_id,
      c_n,c_to_table,c_n,c_to_screen,c_s,l_null;
      END IF;
      COMMIT;
  load_session_details(FALSE);
  COMMIT;
  EXCEPTION
  WHEN missing_logsession OR too_many_sessions OR missing_logger_config THEN
    -- Release the initialization guard before the independent repair owner runs.
    ROLLBACK;
    session_details;
    COMMIT;
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
   END initialize; 
BEGIN 
   initialize;
END admin_logger;
/
