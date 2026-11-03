CREATE OR REPLACE PACKAGE BODY tetools.admin_objects
IS 
  -- VER BODY VERSION 20261012_001
  --
  -- /* ================================================================================================================================================================= */
  --  EXCEPTIONS
  -- /* ================================================================================================================================================================= */
  --
  generic_error            EXCEPTION;  PRAGMA EXCEPTION_INIT (generic_error           , -20001);
  failure_in_calling       EXCEPTION;  PRAGMA EXCEPTION_INIT (failure_in_calling      , -20002);
  invalid_parameter        EXCEPTION;  PRAGMA EXCEPTION_INIT (invalid_parameter       , -20003);  --'AN INVALID PARAMETER WAS GIVEN. VERIFY ITS USE'
  not_correct_session      EXCEPTION;  PRAGMA EXCEPTION_INIT (not_correct_session     , -20004);  --'REQUEST FOR TERMINATION COULD NOT BE PROCESSED. FOLLOW PRECEEDING MESSAGES FOR CAUSE.'
  marked_for_kill          EXCEPTION;  PRAGMA EXCEPTION_INIT (marked_for_kill         , -20005);  --'REQUESTED SESSION HAS BEEN MARKED FOR TERMINATION. SYSTEM WILL EJECT SESSION WHEN APPROPRIATE'
  get_help                 EXCEPTION;  PRAGMA EXCEPTION_INIT (get_help                , -20006);
  trm_cfmnd                EXCEPTION;  PRAGMA EXCEPTION_INIT (trm_cfmnd               , -20007);  --'TERMINATION REQUEST FOR USER HAS BEEN CONFIRMED.'
  req_denied               EXCEPTION;  PRAGMA EXCEPTION_INIT (req_denied              , -20008);  --'REQUEST DENIED: TERMINATION REQUEST <v_trm_id> TARGETS A SYS SESSION OR BACKGROUND PROCESS.'
  need_to_be_admin         EXCEPTION;  PRAGMA EXCEPTION_INIT (need_to_be_admin        , -20009);  --'INVOKING USER OF TERMINATION REQUEST NEEDS TO BE AN ADMIN USER FOR THIS REQUEST/SESSION. TERMINATION REQUEST <v_trm_id> AWAITS CONFIRMATION.'
  trm_closed               EXCEPTION;  PRAGMA EXCEPTION_INIT (trm_closed              , -20010);  --'TERMINATION REQUEST IS CLOSED, CONFIRMATION IS NOT POSSIBLE.'
  segment_numeral          EXCEPTION;  PRAGMA EXCEPTION_INIT (segment_numeral         , -20011);  --
  version_lt_min           EXCEPTION;  PRAGMA EXCEPTION_INIT (version_lt_min          , -20012);  --
  version_gt_max           EXCEPTION;  PRAGMA EXCEPTION_INIT (version_gt_max          , -20013);  --
  version_validation       EXCEPTION;  PRAGMA EXCEPTION_INIT (version_validation      , -20014);  --
  too_many_sessions        EXCEPTION;  PRAGMA EXCEPTION_INIT (too_many_sessions       , -20015);  --
  invalid_numsessions      EXCEPTION;  PRAGMA EXCEPTION_INIT (invalid_numsessions     , -20016);  --
  corrupt_logger_target    EXCEPTION;  PRAGMA EXCEPTION_INIT (corrupt_logger_target   , -20017);  --
  not_correct_phase        EXCEPTION;  PRAGMA EXCEPTION_INIT (not_correct_phase       , -20018); --'THE PHASE GIVEN IS NOT COMMONLY USED IN GD.'
  no_valid_domain          EXCEPTION;  PRAGMA EXCEPTION_INIT (no_valid_domain         , -20019); --'DOMAIN NAME VALIDATION FAILED, MOST LIKELY A DOMAIN NOT COMMONLY USED IN GD.'
  hostname_validation      EXCEPTION;  PRAGMA EXCEPTION_INIT (hostname_validation     , -20020); --'VALIDATION OF THE HOSTNAME FAILED, MOST LIKELY A TYPO.'
  fqdn_validation          EXCEPTION;  PRAGMA EXCEPTION_INIT (fqdn_validation         , -20021); --'VALIDATION OF THE FQDN FAILED FOR THE GIVEN HOSTNAME, CHECK AGAIN.'
  ip_invalid               EXCEPTION;  PRAGMA EXCEPTION_INIT (ip_invalid              , -20022); --'VALIDATION OF THE GIVEN IP ADDRESS FAILED, EITHER FORMAT IS WRONG OR A BROADCAST ADDRESS WAS GIVEN.'
  shortname_validation     EXCEPTION;  PRAGMA EXCEPTION_INIT (shortname_validation    , -20023); --'VALIDATION OF THE DB SERVER SHORTNAME FAILED, MOST LIKELY A SUBDOMAIN.'
  not_correct_phase        EXCEPTION;  PRAGMA EXCEPTION_INIT (not_correct_phase       , -20024); --'GIVEN PHASE IS NOT USED WITHIN GD.'
  no_valid_domain          EXCEPTION;  PRAGMA EXCEPTION_INIT (no_valid_domain         , -20025); --'DOMAIN VALIDATION FAILED.'
  idx_internal_check       EXCEPTION;  PRAGMA EXCEPTION_INIT (idx_internal_check      , -20026); --'INDEX FOR VARRAY FAILED INTERNALLY, TECHNICAL ISSUE MOST LIKELY.'
  ip_format_invalid        EXCEPTION;  PRAGMA EXCEPTION_INIT (ip_format_invalid       , -20027); --'IP ADDRESS FORMAT IS INVALID'
  port_validation          EXCEPTION;  PRAGMA EXCEPTION_INIT (port_validation         , -20028); --'PORT VALIDATION FAILED'
  crud_read                EXCEPTION;  PRAGMA EXCEPTION_INIT (crud_read               , -20029); --'REQUESTED CRUD OPERATION (READ) NOT APPLICABLE FOR THIS PACKAGE.'
  crud_unknown             EXCEPTION;  PRAGMA EXCEPTION_INIT (crud_unknown            , -20030); --'REQUESTED CRUD OPERATION IN TNSNAMES BASE TABLE IS INVALID.'
  no_contributor           EXCEPTION;  PRAGMA EXCEPTION_INIT (no_contributor          , -20031); --'INVOKING USER HAS NO PRIVILEGES TO CONTRIBUTE TO TNSNAMES. CONTACT TET.'
  maintenance_mode_enabled EXCEPTION;  PRAGMA EXCEPTION_INIT (maintenance_mode_enabled, -20032); --'INVOKING USER HAS NO PRIVILEGES TO ADMINISTER TO TNSNAMES WHILE MAINTENANCE MODE IS ENABLED. CONTACT TET.'
  no_update_found          EXCEPTION;  PRAGMA EXCEPTION_INIT (no_update_found         , -20033); --'NO DISCERNABLE UPDATE VALUES FOUND TO PROCESS AS TNS REGISTRATION. TRY AGAIN.'
  operation_halted         EXCEPTION;  PRAGMA EXCEPTION_INIT (operation_halted        , -20034); --'SOMEHOW, SOMEWHERE, SOMETHINGs NOT GOOD. TRY AGAIN. CALL TET.'
  wrong_crud               EXCEPTION;  PRAGMA EXCEPTION_INIT (wrong_crud              , -20035); --'CANt UPDATE WHEN IT ALREADY EXISTS, OR SIMILAR. TRY AGAIN.'
  mismatch_type_numhosts   EXCEPTION;  PRAGMA EXCEPTION_INIT (mismatch_type_numhosts  , -20036); --'A SPECIFIC NUMBER OF ADDRESSES CAN/MUST BE USED WITH THE TYPE OF REGISTRATION. SIMPLE: 1, ADVANCED: 1 to 3.'
  invalid_numhosts         EXCEPTION;  PRAGMA EXCEPTION_INIT (invalid_numhosts        , -20037); --'A SPECIFIC RANGE OF NUMBER OF ADDRESSES CAN BE USED TO REGISTER A NET SERVICE NAME: [1 - 3].'
  validation_error         EXCEPTION;  PRAGMA EXCEPTION_INIT (validation_error        , -20038); --'A VALIDATION ERROR HAS OCCURED VALIDATING THE PROTO TNS ENTRY. SEE FEEDBACK FOR OFFENDING ATTRIBUTE.'
  invalid_parameter        EXCEPTION;  PRAGMA EXCEPTION_INIT (invalid_parameter       , -20039); --'AN INVALID PARAMETER WAS GIVEN. VERIFY ITS USE'
  no_parent_attr_name      EXCEPTION;  PRAGMA EXCEPTION_INIT (no_parent_attr_name     , -20040); --'A PARSE ERROR HAS OCCURED TRYING TO VALIDATE THE GIVEN ATTRIBUTE NAME. THIS ATTRIBUTE HAS BEEN MISSPELLED OR NOT IN SUPPORT.'
  crud_retrieve            EXCEPTION;  PRAGMA EXCEPTION_INIT (crud_retrieve           , -20041);
  crud_unknown             EXCEPTION;  PRAGMA EXCEPTION_INIT (crud_unknown            , -20042);
  idx_internal_check       EXCEPTION;  PRAGMA EXCEPTION_INIT (idx_internal_check      , -20043);
  already_cataloged        EXCEPTION;  PRAGMA EXCEPTION_INIT (already_cataloged       , -20044);
  --
  -- /* ================================================================================================================================================================= */
  --  TYPES
  -- /* ================================================================================================================================================================= */
  --
  --
  --
  -- /* ================================================================================================================================================================= */
  --  FUNCTIONS
  -- /* ================================================================================================================================================================= */
  --
  -- /* FUNCTION > version_compare_func ------------------------------------------------------ VERSION_COMPARE_FUNC ----- */
  FUNCTION version_compare_func ( p_current_version IN VARCHAR2, p_base_version IN VARCHAR2 ) RETURN VARCHAR2
    IS
    v_current_version         VARCHAR2(32) := p_current_version;
    v_base_ver                VARCHAR2(32) := p_base_version;
    v_result                  VARCHAR2(32);
  BEGIN
    --
    version_compare(v_current_version, v_base_ver, v_result);
    --
    RETURN (v_result);
  END version_compare_func;
  --
  -- /* FUNCTION > version_validate_func ---------------------------------------------------- VERSION_VALIDATE_FUNC ----- */
  FUNCTION version_validate_func ( p_current_version IN VARCHAR2, p_min_version IN VARCHAR2, p_max_version IN VARCHAR2 ) RETURN VARCHAR2
  IS
    v_current_version         VARCHAR2(32) := p_current_version;
    v_min_ver                 VARCHAR2(32) := p_min_version;
    v_max_ver                 VARCHAR2(32) := p_max_version;
    v_result                  VARCHAR2(32);
  BEGIN
    --
    version_validate(v_current_version, v_min_ver, v_max_ver, v_result);
    --
    RETURN (v_result);
  END version_validate_func;
  --
  -- /* FUNCTION > version_numberfy_func ---------------------------------------------------- VERSION_NUMBERFY_FUNC ----- */
  FUNCTION version_numberfy_func ( p_current_version IN VARCHAR2 ) RETURN VARCHAR2
  IS
    l_context                 VARCHAR2(128) := $$PLSQL_UNIT;
    v_this_object             VARCHAR2(128);
    v_caller                  VARCHAR2(128);
    v_current_version         VARCHAR2(32)  := p_current_version;
    v_result                  VARCHAR2(32);
    is_numeral                CHAR(1)       := 'N';
    v_rowtext                 VARCHAR2(32767);
    v_batch                   BOOLEAN       := TRUE;
    logbatch_id               PLS_INTEGER;
    l_depth                   PLS_INTEGER;
    l_lvl_object              PLS_INTEGER;
    l_lvl_caller              PLS_INTEGER;
    --
  BEGIN
    --
    tetools.admin_logger.session_details;
    --
    l_depth := UTL_CALL_STACK.dynamic_depth;
    --
    IF l_depth = 1 THEN
      l_lvl_object := l_depth;
      l_lvl_caller := l_depth;
    ELSIF l_depth > 1 THEN
      l_lvl_object := l_depth -1;
      l_lvl_caller := l_depth;
    END IF;
    --
    v_caller      := UTL_CALL_STACK.concatenate_subprogram(UTL_CALL_STACK.subprogram(l_lvl_object));
    v_this_object := UTL_CALL_STACK.concatenate_subprogram(UTL_CALL_STACK.subprogram(l_lvl_caller));
    --
    version_numberfy(v_current_version, v_result);
    --
    IF v_result = 'FAIL' THEN
      RAISE segment_numeral;
    ELSE
      RETURN (v_result);
    END IF;
    --
    EXCEPTION
    WHEN segment_numeral THEN
      tetools.admin_logger.log_error_force (l_context, v_current_version||' is not a number.');
      v_result := 'FAIL';
  	RETURN (v_result);
  END version_numberfy_func;
  --
  --
  -- /* ================================================================================================================================================================= */
  --  PROCEDURES
  -- /* ================================================================================================================================================================= */
  --
  -- /* PROCEDURE > help --------------------------------------------------------------------------------------- USAGE EXAMPLES ----- */
  --
  PROCEDURE help( verbose IN VARCHAR2 DEFAULT 'N')
  AS
    l_context                VARCHAR2(128) := $$PLSQL_UNIT;
    v_this_object            VARCHAR2(128);
    v_caller                 VARCHAR2(128);
    v_rowtext                VARCHAR2(32767);
    v_filter_y               VARCHAR2(40) := '^[[:space:]]{2}[\-]{2}[H][SV][\-]';
    v_filter_n               VARCHAR2(40) := '^[[:space:]]{2}[\-]{2}[H][S][\-]';
    v_filter_help            VARCHAR2(64) := v_filter_y || '[[:space:]]';
    v_verbose                VARCHAR2(64) := v_filter_n;
	v_token                  VARCHAR2(5)  := admin_logger.gen_token;
    v_result                 CLOB;
	v_full_clob              CLOB;
	logbatch_id              PLS_INTEGER;
	l_depth                  PLS_INTEGER;
	l_lvl_object             PLS_INTEGER;
	l_lvl_caller             PLS_INTEGER;
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
	--
	tetools.admin_logger.session_details;
	tetools.admin_logger.session_details_revert('BACKUP', v_token);
    --
	l_depth := UTL_CALL_STACK.dynamic_depth;
	--
	IF l_depth = 1 THEN
	  l_lvl_object := l_depth;
	  l_lvl_caller := l_depth;
	ELSIF l_depth = 2 THEN
	  l_lvl_object := l_depth -1;
	  l_lvl_caller := l_depth;
	ELSIF l_depth > 1 THEN
	  l_lvl_object := 2;
	  l_lvl_caller := l_depth -1;
	END IF;
	--
    who_called(l_lvl_object, v_this_object);
	who_called(l_lvl_caller, v_caller);
    --
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
	DBMS_LOB.append(v_full_clob, v_caller||':: '||CHR(10));
	--
  	FOR r_row IN c_help(l_context, v_verbose)
    LOOP
	  DBMS_LOB.append(v_full_clob, REPLACE(r_row.text,',',', '));
    END LOOP;
	--
	tetools.admin_logger.toggle_debug(modus => c_on, set_debug_target => c_to_screen);
	tetools.admin_logger.log_runtime (l_context, v_full_clob);
	--
	tetools.admin_logger.session_details_revert('RESTORE', v_token);
	--
	DBMS_LOB.CLOSE(lob_loc => v_full_clob);
    DBMS_LOB.FREETEMPORARY(lob_loc => v_full_clob);
	--
	DBMS_APPLICATION_INFO.SET_MODULE(null,null);
    --
    EXCEPTION
      WHEN failure_in_calling                                                                                                THEN
        v_result := v_result||chr(13)||chr(10)||DBMS_UTILITY.format_error_stack;
  	    tetools.admin_logger.log_error_force(l_context, v_this_object||': '||v_result);
  	WHEN get_help                                                                                                            THEN
  	  help('HELP SHC');
    WHEN OTHERS                                                                                                              THEN
      tetools.admin_logger.log_error_force(l_context, v_this_object||': '||DBMS_UTILITY.format_error_stack);
      RAISE;
	--
  END help;
  --
  -- /* PROCEDURE > banner -------------------------------------------------------------------------- PACKAGE DETAILS / HISTORY ----- */
  --
  PROCEDURE banner
  AS
    l_context                VARCHAR2(128) := $$PLSQL_UNIT;
    v_this_object            VARCHAR2(128);
    v_caller                 VARCHAR2(128);
    v_rowtext                VARCHAR2(32767);
	v_token                  VARCHAR2(5)  := admin_logger.gen_token;
    v_result                 CLOB;
	v_full_clob              CLOB;
	l_depth                  PLS_INTEGER;
	l_lvl_object             PLS_INTEGER;
	l_lvl_caller             PLS_INTEGER;
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
	--
	tetools.admin_logger.session_details;
	tetools.admin_logger.session_details_revert('BACKUP', v_token);
    --
	l_depth := UTL_CALL_STACK.dynamic_depth;
	--
	IF l_depth = 1 THEN
	  l_lvl_object := l_depth;
	  l_lvl_caller := l_depth;
	ELSIF l_depth = 2 THEN
	  l_lvl_object := l_depth -1;
	  l_lvl_caller := l_depth;
	ELSIF l_depth > 1 THEN
	  l_lvl_object := 2;
	  l_lvl_caller := l_depth -1;
	END IF;
	--
    who_called(l_lvl_object, v_this_object);
	who_called(l_lvl_caller, v_caller);
    --
    DBMS_APPLICATION_INFO.SET_MODULE(module_name => l_context||'.banner', action_name => 'Display the BANNER for package '||l_context||'.');
    --
	DBMS_LOB.CREATETEMPORARY(v_full_clob,TRUE);
	DBMS_LOB.OPEN(v_full_clob, DBMS_LOB.LOB_READWRITE);
	DBMS_LOB.append(v_full_clob, v_caller||':: '||CHR(10));
	--
  	FOR r_row IN c_banner(l_context)
    LOOP
	  DBMS_LOB.append(v_full_clob, REPLACE(r_row.text,',',', '));
    END LOOP;
	--
	tetools.admin_logger.toggle_debug(modus => c_on, set_debug_target => c_to_screen);
	tetools.admin_logger.log_runtime (l_context, v_full_clob);
	--
	DBMS_LOB.CLOSE(lob_loc => v_full_clob);
    DBMS_LOB.FREETEMPORARY(lob_loc => v_full_clob);
	--
	tetools.admin_logger.session_details_revert('RESTORE', v_token);
	--
	DBMS_APPLICATION_INFO.SET_MODULE(null,null); 
  END banner;
  --
  -- /* PROCEDURE > version ------------------------------------------------------------------------- PACKAGE DETAILS / HISTORY ----- */
  --
  PROCEDURE version
  AS
    l_context                VARCHAR2(128) := $$PLSQL_UNIT;
    v_this_object            VARCHAR2(128);
    v_caller                 VARCHAR2(128);
    v_rowtext                VARCHAR2(32767);
	v_full_clob              CLOB;
	l_depth                  PLS_INTEGER;
	l_lvl_object             PLS_INTEGER;
	l_lvl_caller             PLS_INTEGER;
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
	--
	tetools.admin_logger.session_details;
	tetools.admin_logger.session_details_revert('BACKUP');
    --
	l_depth := UTL_CALL_STACK.dynamic_depth;
	--
	IF l_depth = 1 THEN
	  l_lvl_object := l_depth;
	  l_lvl_caller := l_depth;
	ELSIF l_depth = 2 THEN
	  l_lvl_object := l_depth -1;
	  l_lvl_caller := l_depth;
	ELSIF l_depth > 1 THEN
	  l_lvl_object := 2;
	  l_lvl_caller := l_depth -1;
	END IF;
	--
    who_called(l_lvl_object, v_this_object);
	who_called(l_lvl_caller, v_caller);
    --
    DBMS_APPLICATION_INFO.SET_MODULE(module_name => l_context||'.banner', action_name => 'Display version numbers for package '||l_context||'.');
    --
	DBMS_LOB.CREATETEMPORARY(v_full_clob,TRUE);
	DBMS_LOB.OPEN(v_full_clob, DBMS_LOB.LOB_READWRITE);
	DBMS_LOB.append(v_full_clob, v_caller||':: '||CHR(10));
	--
  	FOR r_row IN c_versions(l_context)
    LOOP
	  DBMS_LOB.append(v_full_clob, REPLACE(r_row.text,'-- VER',' '));
    END LOOP;
	--
	tetools.admin_logger.toggle_debug(modus => c_on, set_debug_target => c_to_screen);
	tetools.admin_logger.log_runtime (l_context, v_full_clob);
	--
	DBMS_LOB.CLOSE(lob_loc => v_full_clob);
    DBMS_LOB.FREETEMPORARY(lob_loc => v_full_clob);
	--
	tetools.admin_logger.session_details_revert('RESTORE');
	--
	DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL); 
  END version;
  --
  -- /* PROCEDURE > who_called --------------------------------------------------------------------------------- UTL_CALL_STACK ----- */
  --
  PROCEDURE who_called ( p_level IN NUMBER, p_trm_result OUT VARCHAR2 )
  AS
    l_context                VARCHAR2(128) := $$PLSQL_UNIT;
    v_caller                 utl_call_stack.unit_qualified_name;
    v_name                   VARCHAR2(128);
  BEGIN
    /* This procedure retrieves the calling component. */
    /* This information is used for troubleshooting and debugging and has no purpose for standard operational use. */
    -- step backwards though the call stack
    --      1 = current module = who_called function
    --      2 = the module that calls who_called
    --      3 = the caller!
    --v_caller := utl_call_stack.subprogram(2);
    v_caller     := utl_call_stack.subprogram(p_level);
    v_name       := utl_call_stack.concatenate_subprogram(v_caller);
    SELECT REGEXP_SUBSTR(v_name, '[^.]+',1,2) INTO p_trm_result FROM DUAL;
  END who_called;
  --
  -- /* PROCEDURE > version_compare --------------------------------------------------------------------------- VERSION_COMPARE ----- */
  --
  PROCEDURE version_compare ( p_to_compare_version IN VARCHAR2, p_base_version IN VARCHAR2 DEFAULT NULL, p_return OUT VARCHAR2 )
  AS
    l_context                 VARCHAR2(128) := $$PLSQL_UNIT;
    v_this_object             VARCHAR2(128);
    v_caller                  VARCHAR2(128);
    v_current_version         VARCHAR2(32)  := p_to_compare_version;
    iterator                  NUMBER;
    v_base_ver                VARCHAR2(32)  := p_base_version;
    num_segs                  NUMBER;
    is_numeral                CHAR(1)       := 'N';
    seg_current_var           VARCHAR2(32);
    seg_current_num           NUMBER;
    seg_base_num              NUMBER;
    prev_segment              VARCHAR2(6);
    v_rowtext                 VARCHAR2(32767);
	v_token                   VARCHAR2(5)   := admin_logger.gen_token;
    v_batch                   BOOLEAN       := TRUE;
    v_result                 CLOB;
    logbatch_id               PLS_INTEGER;
    l_depth                   PLS_INTEGER;
    l_lvl_object              PLS_INTEGER;
    l_lvl_caller              PLS_INTEGER;
    --
    tab   type_tbl_ADMIN_OBJECTS_CONFIG; 
    TYPE  type_tbl IS TABLE OF VARCHAR2(255);
    v_tab type_tbl := type_tbl('EQ', 'LT', 'GT');
    --
    FUNCTION is_number(p_segment VARCHAR2) RETURN CHAR AS
      v_return  CHAR(1);
    BEGIN
    SELECT CASE
                 WHEN REGEXP_LIKE(p_segment, '^([0-9]*)$') THEN 'Y'
                                                           ELSE 'N'
               END INTO v_return
          FROM DUAL;
    --
    RETURN v_return;
    END is_number;
    --
    --
    FUNCTION num_period_version RETURN NUMBER AS
     v_return                  NUMBER;
    BEGIN
      SELECT MIN(REGEXP_COUNT(v_current_version, '[.]'))+1 INTO v_return
        FROM dual;
      --
      RETURN v_return;
    END num_period_version;
    --
  BEGIN
    --
    /* VALIDATE INPUT PARAMETERS */
    IF UPPER(p_to_compare_version) = c_to_screen THEN
      RAISE get_help;
    END IF;
	--
    tetools.admin_logger.session_details;
    --
    l_depth := UTL_CALL_STACK.dynamic_depth;
    --
    IF l_depth = 1 THEN
      l_lvl_object := l_depth;
      l_lvl_caller := l_depth;
    ELSIF l_depth > 1 THEN
      l_lvl_object := l_depth -1;
      l_lvl_caller := l_depth;
    END IF;
    --
    v_caller      := UTL_CALL_STACK.concatenate_subprogram(UTL_CALL_STACK.subprogram(l_lvl_caller));
    v_this_object := UTL_CALL_STACK.concatenate_subprogram(UTL_CALL_STACK.subprogram(l_lvl_object));
    --
    --tetools.admin_logger.toggle_logging(modus => 'ON', send_log_to_in => 'T');
    DBMS_APPLICATION_INFO.SET_MODULE(module_name => l_context, action_name => 'Calculate status of version given in context of given range.');
    --
    SELECT jt.*
        BULK COLLECT INTO tab
      FROM ADMIN_OBJECTS_CONFIG aoc,
           json_table(conf_value, '$'
             COLUMNS (nested path '$.STATUSES[*]'
               columns (
                 STATUS_TYPE   VARCHAR2(10) path '$.Name'
               )
           )
         ) AS "JT"
     where aoc.conf_name = 'AVAILABLE_VERSION_STATUSES';
    --
    num_segs   := num_period_version;
    --
    FOR i IN 1.. num_segs LOOP
    --
      iterator          := i;
      seg_current_var   := NVL(LTRIM(REGEXP_SUBSTR(REPLACE(v_current_version,   '.', ';'),'[^;]+', 1, iterator), '0 '),0);
      seg_base_num      := TO_NUMBER(NVL(LTRIM(REGEXP_SUBSTR(REPLACE(v_base_ver, '.', ';'),'[^;]+', 1, iterator), '0 '),0));
      is_numeral        := is_number(seg_current_var);
  	  seg_current_num   := TO_NUMBER(seg_current_var);
      --
      IF is_numeral = 'N' THEN
  	  RAISE segment_numeral;
      END IF;
      --
      IF iterator = 1                                           THEN
        IF    seg_current_num < seg_base_num                                           THEN
          prev_segment := 'LT';
          EXIT;
        ELSIF seg_current_num = seg_base_num                                           THEN
  	      prev_segment := 'EQ';
        ELSIF seg_current_num > seg_base_num                                           THEN
          prev_segment := 'GT';
          EXIT;
        END IF;
        --
      ELSIF iterator > 1                                        THEN
        IF    prev_segment = 'EQ'                                                      THEN
          IF    seg_current_num < seg_base_num                                                           THEN
            prev_segment := 'LT';
  		    EXIT;
  		  ELSIF seg_current_num = seg_base_num                                                           THEN
            prev_segment := 'EQ';
  		  ELSIF seg_current_num > seg_base_num                                                           THEN
            prev_segment := 'GT';
  		    EXIT;
  		  END IF;
        END IF;
        --
      END IF;
      --
    END LOOP;
    --
    IF    prev_segment = 'EQ' THEN
      p_return := 'EQUAL';
    ELSIF prev_segment = 'LT' THEN
      p_return := 'OLDER';
    ELSIF prev_segment = 'GT' THEN
      p_return := 'NEWER';
    END IF;
    --
    DBMS_APPLICATION_INFO.SET_MODULE(null,null); 
    --
    EXCEPTION
      WHEN failure_in_calling                                                                                                  THEN
        v_result := v_result||chr(13)||chr(10)||DBMS_UTILITY.format_error_stack;
  	    tetools.admin_logger.log_error_force(l_context, v_this_object||': '||v_result);
  	  WHEN get_help                                                                                                            THEN
  	    help('HELP VCP');
      WHEN segment_numeral                                                                                                     THEN
        tetools.admin_logger.log_error_force (l_context, v_caller||':: SEGMENT'||seg_current_var||' is not a number.) (CUR: '||TO_CHAR(seg_current_num)||'; BASE: '||TO_CHAR(v_base_ver)||')');
        p_return := 'FAIL';
      WHEN OTHERS                                                                                                              THEN
        RAISE;
  END version_compare;
  --
  -- /* PROCEDURE > version_validate ------------------------------------------------------------------------- VERSION_VALIDATE ----- */
  --
  PROCEDURE version_validate ( p_current_version IN VARCHAR2, p_min_version IN VARCHAR2, p_max_version IN VARCHAR2, p_return OUT VARCHAR2 )
  AS
    l_context                 VARCHAR2(128) := $$PLSQL_UNIT;
    v_this_object             VARCHAR2(128);
    v_caller                  VARCHAR2(128);
    v_current_version         VARCHAR2(32)  := p_current_version;
    iterator                  NUMBER;
    v_min_ver                 VARCHAR2(32)  := p_min_version;
    v_max_ver                 VARCHAR2(32)  := p_max_version;
    num_segs                  NUMBER;
    is_numeral                CHAR(1)       := 'N';
    seg_current_var           VARCHAR2(32);
    seg_current_num           NUMBER;
    seg_minimal_num           NUMBER;
    seg_maximal_num           NUMBER;
    prev_segment              VARCHAR2(6);
    v_rowtext                 VARCHAR2(32767);
    v_batch                   BOOLEAN       := TRUE;
    v_result                 CLOB;
    logbatch_id               PLS_INTEGER;
    l_depth                   PLS_INTEGER;
    l_lvl_object              PLS_INTEGER;
    l_lvl_caller              PLS_INTEGER;
    --
    tab   type_tbl_ADMIN_OBJECTS_CONFIG; 
    TYPE  type_tbl IS TABLE OF VARCHAR2(255);
    v_tab type_tbl := type_tbl('EQ_MIN', 'BT', 'EQ_MAX');
    --
    FUNCTION is_number(p_segment VARCHAR2) RETURN CHAR AS
      v_return  CHAR(1);
    BEGIN
    SELECT CASE
                 WHEN REGEXP_LIKE(p_segment, '^([0-9]*)$') THEN 'Y'
                                                           ELSE 'N'
               END INTO v_return
          FROM DUAL;
    --
    RETURN v_return;
    END is_number;
    --
    --
    FUNCTION num_period_verion RETURN NUMBER AS
     v_return                  NUMBER;
    BEGIN
      SELECT MIN(REGEXP_COUNT(v_current_version, '[.]'))+1 INTO v_return
        FROM dual;
      --
      RETURN v_return;
    END num_period_verion;
    --
  BEGIN
    --
    tetools.admin_logger.session_details;
    --
    l_depth := UTL_CALL_STACK.dynamic_depth;
    --
    IF l_depth = 1 THEN
      l_lvl_object := l_depth;
      l_lvl_caller := l_depth;
    ELSIF l_depth > 1 THEN
      l_lvl_object := l_depth -1;
      l_lvl_caller := l_depth;
    END IF;
    --
    v_caller      := UTL_CALL_STACK.concatenate_subprogram(UTL_CALL_STACK.subprogram(l_lvl_caller));
    v_this_object := UTL_CALL_STACK.concatenate_subprogram(UTL_CALL_STACK.subprogram(l_lvl_object));
    --
    DBMS_APPLICATION_INFO.SET_MODULE(module_name => l_context, action_name => 'Calculate status of version given in context of given range.');
    --
    SELECT jt.*
        BULK COLLECT INTO tab
      FROM ADMIN_OBJECTS_CONFIG aoc,
           json_table(conf_value, '$'
             COLUMNS (nested path '$.STATUSES[*]'
               columns (
                 STATUS_TYPE   VARCHAR2(10) path '$.Name'
               )
           )
         ) AS "JT"
     where aoc.conf_name = 'AVAILABLE_VERSION_STATUSES';
    --
    num_segs   := num_period_verion;
    --
    FOR i IN 1.. num_segs LOOP
    --
      iterator          := i;
      seg_current_var   := NVL(LTRIM(REGEXP_SUBSTR(REPLACE(v_current_version,   '.', ';'),'[^;]+', 1, iterator), '0 '),0);
      seg_minimal_num   := TO_NUMBER(NVL(LTRIM(REGEXP_SUBSTR(REPLACE(v_min_ver, '.', ';'),'[^;]+', 1, iterator), '0 '),0));
      seg_maximal_num   := TO_NUMBER(NVL(LTRIM(REGEXP_SUBSTR(REPLACE(v_max_ver, '.', ';'),'[^;]+', 1, iterator), '0 '),0));
      is_numeral        := is_number(seg_current_var);
  	  seg_current_num   := TO_NUMBER(seg_current_var);
      --
      IF is_numeral = 'N' THEN
  	  RAISE segment_numeral;
      END IF;
      --
      IF iterator = 1                                           THEN
        IF    seg_current_num < seg_minimal_num                                           THEN
          prev_segment := 'LT_MIN';
          RAISE VERSION_LT_MIN;
        ELSIF seg_current_num BETWEEN seg_minimal_num AND seg_maximal_num                 THEN
          IF    seg_current_num = seg_minimal_num                                                           THEN
            prev_segment := 'EQ_MIN';
  		  ELSIF seg_current_num > seg_minimal_num AND seg_current_num < seg_maximal_num                     THEN
            prev_segment := 'BT';
  		    EXIT;
  		  ELSIF seg_current_num = seg_maximal_num                                                           THEN
            prev_segment := 'EQ_MAX';
  		  END IF;
        ELSIF seg_current_num > seg_maximal_num                                           THEN
          prev_segment := 'GT_MAX';
          RAISE VERSION_GT_MAX;
        END IF;
        --
      ELSIF iterator > 1                                        THEN
        IF    prev_segment = 'EQ_MIN'                                                     THEN
          IF    seg_current_num < seg_minimal_num                                                           THEN
            prev_segment := 'LT_MIN';
  		    RAISE version_lt_min;
  		  ELSIF seg_current_num = seg_minimal_num                                                           THEN
            prev_segment := 'EQ_MIN';
  		  ELSIF seg_current_num > seg_minimal_num                                                           THEN
            prev_segment := 'BT';
  		    EXIT;
  		  END IF;
        --
        ELSIF prev_segment = 'EQ_MAX'                           THEN
          IF    seg_current_num = seg_maximal_num                                         THEN
            prev_segment := 'EQ_MAX';
  		  ELSIF seg_current_num < seg_maximal_num                                         THEN
            prev_segment := 'BT';
  		    EXIT;
  		  ELSIF seg_current_num > seg_maximal_num                                         THEN
            prev_segment := 'GT_MAX';
  		    RAISE VERSION_GT_MAX;
  		  END IF;
        END IF;
        --
      END IF;
      --
    END LOOP;
    --
    IF prev_segment MEMBER OF v_tab THEN
      p_return := 'ACTIVE';
    END IF;
    --
    DBMS_APPLICATION_INFO.SET_MODULE(null,null); 
    --
    EXCEPTION
    WHEN segment_numeral                                                                                                     THEN
      tetools.admin_logger.log_error_force (l_context, v_caller||':: SEGMENT'||seg_current_var||' is not a number.) (CUR: '||TO_CHAR(seg_current_num)||'; MIN: '||TO_CHAR(v_min_ver)||'; MAX: '||TO_CHAR(v_max_ver)||')');
      p_return := 'FAIL';
      --RAISE;
    WHEN version_lt_min                                                                                                      THEN
      tetools.admin_logger.log_error_force (l_context, v_caller||':: CURRENT VERSION is less than minimum required version for this object.)'||' (CUR: '||TO_CHAR(seg_current_num)||'; MIN: '||TO_CHAR(v_min_ver)||'; MAX: '||TO_CHAR(v_max_ver)||')');
  	  tetools.admin_logger.log_error_force (l_context, v_caller||':: Consider upgrading the module.)');
  	  p_return := 'FUTURE RELEASE';
      --RAISE;
    WHEN version_gt_max                                                                                                      THEN
      tetools.admin_logger.log_error_force (l_context, v_caller||':: CURRENT VERSION is greater than maximum required version for this object.)'||' (CUR: '||TO_CHAR(seg_current_num)||'; MIN: '||TO_CHAR(v_min_ver)||'; MAX: '||TO_CHAR(v_max_ver)||')');
  	  tetools.admin_logger.log_error_force (l_context, v_caller||':: Consider reloading the required objects for this version of module.)');
  	  p_return := 'INACTIVE';
      --RAISE;
    WHEN OTHERS                                                                                                              THEN
      RAISE;
  END version_validate;
  --
  -- /* PROCEDURE > version_numberfy ------------------------------------------------------------------------- VERSION_NUMBERFY ----- */
  --
  PROCEDURE version_numberfy ( p_current_version IN VARCHAR2, p_return OUT VARCHAR2 )
  AS
    l_context                 VARCHAR2(128) := $$PLSQL_UNIT;
    v_this_object             VARCHAR2(128);
    v_caller                  VARCHAR2(128);
    v_current_version         VARCHAR2(32)  := p_current_version;
    v_numberfied_version      VARCHAR2(32);
    iterator                  NUMBER;
    num_segs                  NUMBER;
    is_numeral                CHAR(1)       := 'N';
    seg_current_var           VARCHAR2(32);
    seg_current_num           NUMBER;
    seg_minimal_num           NUMBER;
    seg_maximal_num           NUMBER;
    prev_segment              VARCHAR2(6);
    v_rowtext                 VARCHAR2(32767);
    v_batch                   BOOLEAN       := TRUE;
    logbatch_id               PLS_INTEGER;
    l_depth                   PLS_INTEGER;
    l_lvl_object              PLS_INTEGER;
    l_lvl_caller              PLS_INTEGER;
    --
    tab   type_tbl_ADMIN_OBJECTS_CONFIG; 
    TYPE  type_tbl IS TABLE OF VARCHAR2(255);
    v_tab type_tbl := type_tbl('EQ_MIN', 'BT', 'EQ_MAX');
    --
    FUNCTION num_period_version(p_segment VARCHAR2)  RETURN NUMBER AS
     v_return                  NUMBER;
    BEGIN
      SELECT MIN(REGEXP_COUNT(p_segment, '[.]'))+1 INTO v_return
        FROM dual;
      --
      RETURN v_return;
    END num_period_version;
    --
    FUNCTION is_number(p_segment VARCHAR2) RETURN CHAR AS
      num_segs   NUMBER;
      v_return  CHAR(1);
    BEGIN
  	--
  	SELECT CASE
               WHEN REGEXP_LIKE(REPLACE(p_segment, '.', ''), '^([0-9]*)$') THEN 'Y'
                                                         ELSE 'N'
             END INTO v_return
        FROM DUAL;
      --
      RETURN v_return;
    END is_number;
    --
  BEGIN
    --
    tetools.admin_logger.session_details;
    --
    l_depth := UTL_CALL_STACK.dynamic_depth;
    --
    IF l_depth = 1 THEN
      l_lvl_object := l_depth;
      l_lvl_caller := l_depth;
    ELSIF l_depth > 1 THEN
      l_lvl_object := l_depth -1;
      l_lvl_caller := l_depth;
    END IF;
    --
    v_caller      := UTL_CALL_STACK.concatenate_subprogram(UTL_CALL_STACK.subprogram(l_lvl_caller));
    v_this_object := UTL_CALL_STACK.concatenate_subprogram(UTL_CALL_STACK.subprogram(l_lvl_object));
    --
    --tetools.admin_logger.toggle_logging(modus => 'ON', send_log_to_in => 'S');
    DBMS_APPLICATION_INFO.SET_MODULE(module_name => l_context, action_name => 'Transform versioning into a number.');
    --
    num_segs   := num_period_version(v_current_version);
    --
    FOR i IN 1.. num_segs LOOP
    --
      iterator          := i;
      seg_current_var   := NVL(LTRIM(REGEXP_SUBSTR(REPLACE(v_current_version,   '.', ';'),'[^;]+', 1, iterator), '0 '),0);
      is_numeral        := is_number(seg_current_var);
      --
      IF is_numeral = 'N' THEN
  	    RAISE segment_numeral;
  	  ELSE
        seg_current_num   := TO_NUMBER(seg_current_var);
      END IF;
      --
  	  IF iterator    = 1                        THEN
  	    v_numberfied_version := TO_CHAR(seg_current_var);
      ELSIF iterator = 2                        THEN
  	    v_numberfied_version := v_numberfied_version || LPAD(TO_CHAR(seg_current_var), 3, '0');
      ELSIF iterator = 3                        THEN
  	    v_numberfied_version := v_numberfied_version || '.' || LPAD(TO_CHAR(seg_current_var), 3, '0');
      ELSIF iterator > 3                        THEN
  	    v_numberfied_version := v_numberfied_version || LPAD(TO_CHAR(seg_current_var), 3, '0');
      END IF;
      --
    END LOOP;
    --
    num_segs := num_period_version(v_numberfied_version);
    --
    IF num_segs < 3 THEN
      is_numeral := is_number(REPLACE(v_numberfied_version, '.', ''));
  	  IF is_numeral = 'Y' THEN
  	    p_return := v_numberfied_version;
  	  ELSE
  	    RAISE segment_numeral;
  	  END IF;
    ELSE
      RAISE segment_numeral;
    END IF;
    --
    DBMS_APPLICATION_INFO.SET_MODULE(null,null); 
    --
    EXCEPTION
    WHEN segment_numeral                                                                                                     THEN
      tetools.admin_logger.log_error_force (l_context, v_caller||':: SEGMENT'||seg_current_var||' is not a number.) (CUR: '||TO_CHAR(seg_current_num)||')');
	  p_return := 'FAIL';
      --RAISE;
    WHEN OTHERS                                                                                                              THEN
      RAISE;
  END version_numberfy;
  --
  -- /* PROCEDURE > catalog_monitor_baselogs ------------------------------------------------------------- ADMIN_OBJECTS_LEDGER ----- */
  --
  PROCEDURE catalog_admin_objects ( p_module IN VARCHAR2 DEFAULT c_module, p_user IN VARCHAR2 DEFAULT USER )
  IS
  --
    l_context                VARCHAR2(128) := $$PLSQL_UNIT                                   ;
    v_owner                  TETOOLS.ADMIN_OBJECTS_LEDGER.object_owner%TYPE                  ;
    v_object                 TETOOLS.ADMIN_OBJECTS_LEDGER.object_name%TYPE                   ;
    v_type                   TETOOLS.ADMIN_OBJECTS_LEDGER.object_type%TYPE                   ;
    v_createtime             TETOOLS.ADMIN_OBJECTS_LEDGER.created%TYPE                       ;
    v_comment                TETOOLS.ADMIN_OBJECTS_LEDGER.object_comment%TYPE                ;
    v_object_status          TETOOLS.ADMIN_OBJECTS_LEDGER.object_status%TYPE                 ;
    v_object_present         TETOOLS.ADMIN_OBJECTS_LEDGER.object_present%TYPE                ;
    v_evaluation_status      TETOOLS.ADMIN_OBJECTS_LEDGER.evaluation_status%TYPE := 'PENDING';
    v_curr_app_version       TETOOLS.ADMIN_MONITOR_CONFIG.conf_value%TYPE                    ;
	v_force_accepted         TETOOLS.ADMIN_OBJECTS_LEDGER.force_accepted%TYPE                ;
	v_initial_load_by        TETOOLS.ADMIN_OBJECTS_LEDGER.initial_load_by%TYPE               ;
	v_evaluated_by           TETOOLS.ADMIN_OBJECTS_LEDGER.evaluated_by%TYPE                  ;
	v_md5_hash               TETOOLS.ADMIN_OBJECTS_LEDGER.md5_hash%TYPE                      ;
    v_cur_db_version         CDB_REGISTRY.version_full%TYPE                                  ;
	v_user                   VARCHAR2(128)            := p_user                              ;
    v_datafound              BOOLEAN                  := TRUE                                ;
	v_batch                  BOOLEAN                  := c_true                              ;
	v_token                  VARCHAR2(5)              := admin_logger.gen_token              ;
    v_result                 CLOB                                                            ;
	l_null                   CHAR (1)                                                        ;
    v_error                  VARCHAR2 (1)                                                    ;
    v_this_object            VARCHAR2(128)                                                   ;
    v_caller                 VARCHAR2(128)                                                   ;
	v_hash                   VARCHAR2(33)                                                    ;
	v_metadata               VARCHAR2(32765)                                                 ;
    v_dummy                  VARCHAR2(4000)                                                  ;
	sql_ori1_insert          VARCHAR2(4000)           := 'INSERT INTO TETOOLS.ADMIN_OBJECTS_LEDGER (module, object_owner, object_name, object_type, created, md5_hash, min_db_version, max_db_version, min_app_version, max_app_version, last_cataloged, runs_since_last_cataloged, object_present, object_subject, object_comment, initial_load_by, object_status, evaluation_status) VALUES (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14, :15, :16, :17, :18)';
	sql_ori2_update          VARCHAR2(4000)           := 'UPDATE TETOOLS.ADMIN_OBJECTS_LEDGER SET last_cataloged = :1, runs_since_last_cataloged = :2, object_present = :3, object_status = :4 , force_accepted = :5 WHERE object_owner = :6 AND object_name = :7';
	l_depth                  PLS_INTEGER                                                     ;
	l_lvl_object             PLS_INTEGER                                                     ;
	l_lvl_caller             PLS_INTEGER                                                     ;
	v_iterator               PLS_INTEGER              := 0                                   ;
    --
    CURSOR c_admin_catalog_objects ( p_module VARCHAR2 )
    IS
	WITH cte_obj AS (
      SELECT DISTINCT object_name
           , owner
        FROM cdb_objects
       WHERE owner       = 'TETOOLS'
         AND object_type IN ('TABLE', 'VIEW', 'TYPE', 'PACKAGE', 'PROCEDURE', 'FUNCTION', 'JOB', 'LOB', 'MATERIALIZED VIEW', 'SEQUENCE', 'TRIGGER', 'QUEUE')
         AND object_name LIKE p_module || '%'
    )
    ,    cte_tab AS (
      SELECT obj.owner
           , obj.object_name
    	   , obj.object_type
    	   , MIN(obj.CREATED)       AS "CREATED"
    	   , COUNT(obj.object_type) AS "HITS"
        FROM cdb_objects  obj
    	JOIN cte_obj      cte ON obj.owner = cte.owner AND obj.object_name = cte.object_name
       GROUP BY obj.owner, obj.object_name, obj.object_type
       ORDER BY 1,2,3
    )
    ,    cte_lob AS (
      SELECT lob.owner
           , lob.table_name
    	   , cdb.object_type
    	   , MIN(cdb.CREATED)       AS "CREATED"
           , COUNT(cdb.object_type) AS "HITS"
        FROM cte_obj     obj
    	JOIN cdb_lobs    lob ON obj.owner = lob.owner AND obj.object_name  = lob.table_name
        JOIN cdb_objects cdb ON lob.owner = cdb.owner AND lob.segment_name = cdb.object_name
       GROUP BY lob.owner, lob.table_name, cdb.object_type
       ORDER BY 1,2,3,4
    )
    ,    cte_cur AS (
      SELECT CASE
      		   WHEN (LENGTH(OBJECT_NAME) - LENGTH(replace(OBJECT_NAME,'_',NULL))) >=2 THEN SUBSTR(OBJECT_NAME,0,INSTR(OBJECT_NAME,'_',1,2)-1)
      		   ELSE  OBJECT_NAME
      	     END                                                                                                               AS "MODULE"
      	   , owner                                                                                                             AS "OBJECT_OWNER"
           , object_name                                                                                                       AS "OBJECT_NAME"
      	   , object_type                                                                                                       AS "OBJECT_TYPE"
    	   , NULL                                                                                                              AS "OBJECT_SUBJECT"
    	   , created                                                                                                           AS "CREATED"
    	   , 0                                                                                                                 AS "RUNS_SINCE_LAST_CATALOG"
    	   , 'YES'                                                                                                             AS "OBJECT_PRESENT"
		   , NULL                                                                                                              AS "MD5_HASH"
      	   , 3                                                                                                                 AS "ORIGIN"
    	   , 'NOT YET CATALOGED'                                                                                               AS "OBJECT_STATUS"
    	FROM cte_tab
      UNION ALL
      SELECT CASE
      		   WHEN (LENGTH(table_name) - LENGTH(replace(table_name,'_',NULL))) >=2 THEN SUBSTR(table_name,0,INSTR(table_name,'_',1,2)-1)
      		   ELSE  table_name
      	     END                                                                                                               AS "MODULE"
      	   , owner                                                                                                             AS "OBJECT_OWNER"
           , table_name                                                                                                        AS "OBJECT_NAME"
      	   , object_type                                                                                                       AS "OBJECT_TYPE"
    	   , NULL                                                                                                              AS "OBJECT_SUBJECT"
      	   , created                                                                                                           AS "CREATED"
    	   , 0                                                                                                                 AS "RUNS_SINCE_LAST_CATALOG"
    	   , 'YES'                                                                                                             AS "OBJECT_PRESENT"
		   , NULL                                                                                                              AS "MD5_HASH"
      	   , 3                                                                                                                 AS "ORIGIN"
    	   , 'NOT YET CATALOGED'                                                                                               AS "OBJECT_STATUS"
        FROM cte_lob
     UNION ALL
      SELECT module
            , object_owner
    	    , object_name
    	    , object_type
    	    , object_subject
    	    , created
    	    , NVL(runs_since_last_cataloged, 0)                                                                               AS "RUNS_SINCE_LAST_CATALOGED"
    	    , 'NO'                                                                                                            AS "OBJECT_PRESENT"
		    , md5_hash                                                                                                        AS "MD5_HASH"
    	    , 7                                                                                                               AS "ORIGIN"
    	    , object_status
         FROM ADMIN_OBJECTS_LEDGER
        WHERE module LIKE p_module || '%'
        ORDER BY 1,2,3
    )
    ,    cte_uni AS (
    select cur.module
         , cur.object_owner
    	 , cur.object_name
    	 , cur.object_type
    	 , aol.object_subject
         , NVL(aol.min_db_version, '12.0.01')                                                                                AS "MIN_DB_VERSION"
         , NVL(aol.max_db_version, '99.9.99')                                                                                AS "MAX_DB_VERSION"
         , NVL(aol.min_app_version, '24.0.01')                                                                               AS "MIN_APP_VERSION"
         , NVL(aol.max_app_version, '99.9.99')                                                                               AS "MAX_APP_VERSION"
    	 , NVL(aol.created, DECODE(cur.created, TO_DATE('1999-01-01 00:00:01', 'YYYY-MM-DD HH24:MI:SS'), NULL, cur.created)) AS "CREATED"
    	 , NVL(aol.runs_since_last_cataloged, 0)                                                                             AS "RUNS_SINCE_LAST_CATALOGED"
    	 , NVL(aol.object_status, cur.object_status)                                                                         AS "OBJECT_STATUS"
    	 , NVL(aol.object_present, cur.object_present)                                                                       AS "OBJECT_PRESENT"
		 , NVL(aol.md5_hash, cur.md5_hash)                                                                                   AS "MD5_HASH"
    	 , SUM(cur.ORIGIN)                                                                                                   AS "ORIGIN"
        FROM cte_cur cur
    LEFT JOIN ADMIN_OBJECTS_LEDGER aol ON cur.module = aol.module AND cur.object_owner = aol.object_owner and cur.object_name = aol.object_name AND cur.object_type = aol.object_type
       GROUP BY cur.module
         , cur.object_owner
    	 , cur.object_name
    	 , cur.object_type
    	 , aol.object_subject
         , NVL(aol.min_db_version, '12.0.01')
         , NVL(aol.max_db_version, '99.9.99')
         , NVL(aol.min_app_version, '24.0.01')
         , NVL(aol.max_app_version, '99.9.99')
    	 , NVL(aol.created, DECODE(cur.created, TO_DATE('1999-01-01 00:00:01', 'YYYY-MM-DD HH24:MI:SS'), NULL, cur.created))
    	 , NVL(aol.runs_since_last_cataloged, 0)
    	 , NVL(aol.object_present, cur.object_present)
		 , NVL(aol.md5_hash, cur.md5_hash)
    	 , NVL(aol.object_status, cur.object_status)
       ORDER BY 1,2,3,4
    )
    select uni.module
         , uni.object_owner
    	 , uni.object_name
    	 , uni.object_type
    	 , uni.object_subject
    	 , uni.MIN_DB_VERSION
    	 , uni.MAX_DB_VERSION
    	 , uni.MIN_APP_VERSION
    	 , uni.MAX_APP_VERSION
    	 , TO_CHAR(uni.created, 'YYYY-MM-DD HH24:MI:SS')                                                                     AS "CREATED"
    	 , NVL(uni.runs_since_last_cataloged, 0)                                                                             AS "RUNS_SINCE_LAST_CATALOGED"
    	 , uni.object_present
		 , uni.md5_hash
    	 , NVL(aol.object_comment, ctc.comments)                                                                             AS "OBJECT_COMMENT"
    	 , uni.ORIGIN
    	 , uni.object_status
    	 , v_curr_app_version                                                                                                AS "CUR_APP_VERSION"
         , admin_objects.version_validate_func(v_curr_app_version, uni.MIN_APP_VERSION, uni.MAX_APP_VERSION)                 AS "APP_STATUS"
    	 , v_cur_db_version                                                                                                  AS "CUR_DB_VERSION"
         , admin_objects.version_validate_func(v_cur_db_version, uni.MIN_DB_VERSION, uni.MAX_DB_VERSION)                     AS "DB_STATUS"
        FROM cte_uni uni
    LEFT JOIN ADMIN_OBJECTS_LEDGER aol ON uni.object_owner = aol.object_owner AND uni.object_name = aol.object_name AND uni.object_type = aol.object_type
    LEFT JOIN CDB_TAB_COMMENTS     ctc ON uni.object_owner = ctc.owner        AND uni.object_name = ctc.table_name  AND uni.object_type = ctc.table_type;
  --
  BEGIN
	--
    /* VALIDATE INPUT PARAMETERS */
    IF p_module IS NOT NULL    THEN
	  IF UPPER(p_module) = c_helpme  THEN
        RAISE get_help;
	  END IF;
    END IF;
    --
	tetools.admin_logger.session_details;
	tetools.admin_logger.session_details_revert('BACKUP', v_token);
	--
	l_depth := UTL_CALL_STACK.dynamic_depth;
	--
	IF l_depth = 1 THEN
	  l_lvl_caller := l_depth;
	  l_lvl_object := l_depth;
	ELSIF l_depth = 2 THEN
	  l_lvl_caller := l_depth -1;
	  l_lvl_object := l_depth;
	ELSIF l_depth > 1 THEN
	  l_lvl_caller := 2;
	  l_lvl_object := l_depth -1;
	END IF;
	--
    who_called(l_lvl_object, v_this_object);
	who_called(l_lvl_caller, v_caller);
    --
	tetools.admin_logger.toggle_logging(modus => 'ON', send_log_to_in => 'T');
	tetools.admin_logger.toggle_batch(batch => 'B', modus => 'ON');
	DBMS_APPLICATION_INFO.SET_MODULE(module_name => l_context||'.'||v_this_object, action_name => 'Catalog objects for module '||l_context||'.');
	--
    SELECT conf_value INTO v_curr_app_version FROM TETOOLS.ADMIN_MONITOR_CONFIG WHERE conf_name = 'ADMIN_MONITOR_VERSION';
    SELECT MAX(version_full) INTO v_cur_db_version FROM CDB_REGISTRY;
    --
    EXECUTE IMMEDIATE 'alter session set sort_area_size = 314572800';
    EXECUTE IMMEDIATE 'alter session set skip_unusable_indexes=true';
	--
	IF UPPER(v_this_object) = 'CATALOG_ADMIN_OBJECTS' THEN
	  v_user := v_this_object;
	END IF;
    --
    FOR r_data IN c_admin_catalog_objects (p_module)
	LOOP
	  --
	  IF r_data.object_type NOT IN ('JOB', 'MATERIALIZED VIEW', 'PROCEDURE', 'PACKAGE', 'PACKAGE BODY', 'LOB', 'LOB PARTITION', 'TABLE PARTITION') THEN
	    SELECT DBMS_METADATA.GET_DDL(r_data.object_type, r_data.object_name, r_data.object_owner) INTO v_metadata FROM DUAL;
	    SELECT STANDARD_HASH(v_metadata, 'MD5') INTO v_hash FROM DUAL;
	  END IF;
	  --
	  IF    MOD(TO_NUMBER(r_data.origin), 3) = 0 THEN
		v_object_present    := c_y;
		--
	    IF    r_data.app_status = 'ACTIVE' AND r_data.db_status = 'ACTIVE'                THEN
		  v_object_status     := 'ACTIVE';
		ELSIF r_data.APP_STATUS = 'INACTIVE' OR r_data.db_status = 'INACTIVE'             THEN
		  v_object_status := 'INACTIVE';
		ELSIF r_data.APP_STATUS = 'FUTURE RELEASE' OR r_data.db_status = 'FUTURE RELEASE' THEN
		  v_object_status := 'FUTURE RELEASE';
		ELSE
		  v_object_status := 'ERROR';
	    END IF;
		--
	    EXECUTE IMMEDIATE sql_ori1_insert USING IN r_data.module, r_data.object_owner, r_data.object_name, r_data.object_type, to_date(r_data.created, 'YYYY-MM-DD HH24:MI:SS'), v_hash, r_data.min_db_version, r_data.max_db_version, r_data.min_app_version, r_data.max_app_version, sysdate, r_data.runs_since_last_cataloged+1, v_object_present, r_data.object_subject, r_data.object_comment, v_user, v_object_status, v_evaluation_status;
		tetools.admin_logger.log_runtime (l_context, v_this_object||' :: INSERT REGISTRATION '||v_object_status||':: ORIGIN: '||r_data.origin||', TYPE: '||r_data.object_type||',  OBJECT: '||r_data.object_owner||'.'||r_data.object_name||', CREATED: '||r_data.created||', runs: '||r_data.runs_since_last_cataloged);
	  ELSIF MOD(TO_NUMBER(r_data.origin), 7) = 0 THEN
		v_object_present    := c_n;
		--
	    IF    r_data.app_status = 'ACTIVE' AND r_data.db_status = 'ACTIVE'                THEN
		  v_object_status     := 'ACTIVE';
		ELSIF r_data.APP_STATUS = 'INACTIVE' OR r_data.db_status = 'INACTIVE'             THEN
		  v_object_status := 'INACTIVE';
		ELSIF r_data.APP_STATUS = 'FUTURE RELEASE' OR r_data.db_status = 'FUTURE RELEASE' THEN
		  v_object_status := 'FUTURE RELEASE';
		ELSE
		  v_object_status := 'ERROR';
	    END IF;
		--
		EXECUTE IMMEDIATE sql_ori2_update USING IN SYSDATE, 0, v_object_present, v_object_status, v_force_accepted, r_data.object_owner, r_data.object_name;
		tetools.admin_logger.log_runtime (l_context, v_this_object||' :: UPDATE REGISTRATION '||v_object_status||':: ORIGIN: '||r_data.origin||', TYPE: '||r_data.object_type||',  OBJECT: '||r_data.object_owner||'.'||r_data.object_name||', CREATED: '||r_data.created||', runs: '||r_data.runs_since_last_cataloged);
	  ELSIF MOD(TO_NUMBER(r_data.origin), 10) = 0 THEN
		v_object_present    := c_y;
		--
	    IF    r_data.app_status = 'ACTIVE' AND r_data.db_status = 'ACTIVE'                THEN
		  v_object_status     := 'ACTIVE';
		ELSIF r_data.APP_STATUS = 'INACTIVE' OR r_data.db_status = 'INACTIVE'             THEN
		  v_object_status := 'INACTIVE';
		ELSIF r_data.APP_STATUS = 'FUTURE RELEASE' OR r_data.db_status = 'FUTURE RELEASE' THEN
		  v_object_status := 'FUTURE RELEASE';
		ELSE
		  v_object_status := 'ERROR';
	    END IF;
		--
		EXECUTE IMMEDIATE sql_ori2_update USING IN SYSDATE, 0, v_object_present, v_object_status, v_force_accepted, r_data.object_owner, r_data.object_name;
		tetools.admin_logger.log_runtime (l_context, v_this_object||' :: UPDATE REGISTRATION '||v_object_status||':: ORIGIN: '||r_data.origin||', TYPE: '||r_data.object_type||',  OBJECT: '||r_data.object_owner||'.'||r_data.object_name||', CREATED: '||r_data.created||', runs: '||r_data.runs_since_last_cataloged);
	  ELSE
	    tetools.admin_logger.log_error_force (l_context, v_this_object||'!! :: RAISE ERROR: '||v_object_status||':: ORIGIN: '||r_data.origin||', TYPE: '||r_data.object_type||',  OBJECT: '||r_data.object_owner||'.'||r_data.object_name||', CREATED: '||r_data.created||', runs: '||r_data.runs_since_last_cataloged);
	  END IF;
	  --
	  v_metadata := NULL;
	  v_hash     := NULL;
	v_iterator := v_iterator + 1;
	END LOOP;
	--
    COMMIT;
	--
	tetools.admin_logger.log_runtime (l_context, 'Number of items cataloged: '||v_iterator);
	tetools.admin_logger.session_details_revert('RESTORE', v_token);
	tetools.admin_logger.toggle_batch;
	--
	DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL); 
	--
    EXCEPTION
      WHEN failure_in_calling                                                                                                  THEN
        v_result := v_result||chr(13)||chr(10)||DBMS_UTILITY.format_error_stack;
	    tetools.admin_logger.log_error_force(l_context, v_this_object||': '||v_result);
	  WHEN get_help                                                                                                            THEN
	    help('HELP CAO');
      WHEN generic_error      THEN
	    v_dummy := SQLERRM;
        IF v_dummy IS NULL THEN
	      v_dummy := 'No additional information available.';
	    END IF;
	    --
        ROLLBACK;
        tetools.admin_logger.log_error_force (l_context, v_caller||':: '||v_dummy);
	    tetools.admin_logger.session_details_revert('RESTORE', v_token);
		COMMIT;
        RAISE;
      WHEN version_validation THEN
	    v_dummy := SQLERRM;
        IF v_dummy IS NULL THEN
	      v_dummy := 'No additional information available.';
	    END IF;
	    --
        ROLLBACK;
        tetools.admin_logger.log_warning_force (l_context, v_caller||':: '||v_dummy);
	    tetools.admin_logger.session_details_revert('RESTORE', v_token);
		COMMIT;
    --
  END catalog_admin_objects;
  --
  -- /* PROCEDURE > report_catalog ----------------------------------------------------------------------- ADMIN_OBJECTS_LEDGER ----- */
  --
  PROCEDURE report_catalog ( report_on IN VARCHAR2 )
  AS
    l_context                VARCHAR2(128) := $$PLSQL_UNIT                                   ;
    v_this_object            VARCHAR2(128)                                                   ;
    v_caller                 VARCHAR2(128)                                                   ;
    l_depth                  PLS_INTEGER                                                     ;
	l_lvl_object             PLS_INTEGER                                                     ;
	l_lvl_caller             PLS_INTEGER                                                     ;
    v_curr_app_version       TETOOLS.ADMIN_MONITOR_CONFIG.conf_value%TYPE                    ;
    v_cur_db_version         CDB_REGISTRY.version_full%TYPE                                  ;
	v_name                   VARCHAR2(128)                                                   ;
    v_object_owner           VARCHAR2(17) := RPAD('OWNER', 16, ' ')                          ;
    v_object_name            VARCHAR2(49) := RPAD('OBJECT_NAME', 48, ' ')                    ;
    v_object_type            VARCHAR2(19) := RPAD('OBJECT_TYPE', 18, ' ')                    ;
    v_object_subject         VARCHAR2(17) := RPAD('SUBJECT', 16, ' ')                        ;
    v_created                VARCHAR2(24) := RPAD('CREATED', 23, ' ')                        ;
    v_last_cataloged         VARCHAR2(24) := RPAD('LAST_CATALOGED', 23, ' ')                 ;
    v_rs_lcat                VARCHAR2(9)  := RPAD('RUNS',  8, ' ')                           ;
    v_min_db_version         VARCHAR2(13) := RPAD('MIN_DB_VER', 12, ' ')                     ;
    v_module                 VARCHAR2(15) := RPAD('MODULE', 14, ' ')                         ;
    v_max_db_version         VARCHAR2(13) := RPAD('MAX_DB_VER', 12, ' ')                     ;
    v_min_app_version        VARCHAR2(13) := RPAD('MIN_APP_VER', 12, ' ')                    ;
    v_max_app_version        VARCHAR2(13) := RPAD('MAX_APP_VER', 12, ' ')                    ;
    v_object_status          VARCHAR2(17) := RPAD('OBJ_STATUS', 16, ' ')                     ;
    v_initial_load_by        VARCHAR2(17) := RPAD('LOADED_BY', 16, ' ')                      ;
    v_object_present         VARCHAR2(4)  := RPAD('OBJ',  3, ' ')                            ;
    v_evaluation_status      VARCHAR2(15) := RPAD('EVAL_STATUS', 14, ' ')                    ;
	v_ledger_id              VARCHAR2(9)  := RPAD('LEDGER',  8, ' ')                         ;
	--
	CURSOR c_catalog_status ( p_module VARCHAR2 DEFAULT 'ADMIN' )
    IS
	SELECT module
         , object_status
         , evaluation_status
         , COUNT(*)  AS "NUM_ROWS"
      FROM admin_objects_ledger
     WHERE module LIKE p_module || '%'
       AND object_present = 'Y'
     GROUP BY module
            , object_status
    		, evaluation_status
     ORDER BY module
            , object_status
    		, evaluation_status;
	--
    CURSOR c_catalog_versions ( p_module VARCHAR2 DEFAULT 'ADMIN' )
    IS
	SELECT min_db_version
         , max_db_version
         , min_app_version
         , max_app_version
         , object_status
    --	 , maximale db/app versie afzetten tegen huidige versies
      FROM admin_objects_ledger
     WHERE object_present = 'Y'
       AND object_status IN ('CURRENT', 'ACTIVE')
     GROUP BY min_db_version
            , max_db_version
            , min_app_version
            , max_app_version
            , object_status
     ORDER BY min_db_version
            , max_db_version
            , min_app_version
            , max_app_version
            , object_status;
	--
    PROCEDURE ECHO( STRING IN VARCHAR2, PAD IN VARCHAR2)
    AS
    BEGIN
      DBMS_OUTPUT.PUT_LINE( '  !' || RPAD( STRING, 170, PAD) || '!!');
    END ECHO;
  BEGIN
	--
	l_depth := UTL_CALL_STACK.dynamic_depth;
	--
	IF l_depth = 1 THEN
	  l_lvl_caller := l_depth;
	  l_lvl_object := l_depth;
	ELSIF l_depth = 2 THEN
	  l_lvl_caller := l_depth -1;
	  l_lvl_object := l_depth;
	ELSIF l_depth > 1 THEN
	  l_lvl_caller := 2;
	  l_lvl_object := l_depth -1;
	END IF;
	--
    who_called(l_lvl_object, v_this_object);
	who_called(l_lvl_caller, v_caller);
    --
	tetools.admin_logger.toggle_logging(modus => 'ON', send_log_to_in => 'S');
	tetools.admin_logger.toggle_batch(batch => 'BATCH', modus => 'ON');
	DBMS_APPLICATION_INFO.SET_MODULE(module_name => l_context||'.catalog_admin_objects', action_name => 'List cataloged objects for module '||l_context||'.');
	--
    SELECT conf_value INTO v_curr_app_version FROM TETOOLS.ADMIN_MONITOR_CONFIG WHERE conf_name = 'ADMIN_MONITOR_VERSION';
    SELECT MAX(version_full) INTO v_cur_db_version FROM CDB_REGISTRY;
    --
    --
	IF    UPPER(report_on) = 'STATUS'        THEN
	  DBMS_OUTPUT.PUT_LINE(CHR(13));
      ECHO( '!!!!!! '||l_context||'.'||v_this_object||' > '||UPPER(report_on)||' ', '!');
      ECHO( '!', ' ');
	  ECHO( '! '||v_module||v_object_status||v_evaluation_status, ' ');
      ECHO( '! '||RPAD('-', 13, '-')||' '||RPAD('-', 15, '-')||' '||RPAD('-', 13, '-'), ' ');
      FOR r_data IN c_catalog_status ('ADMIN')
	  LOOP
	  --
	    ECHO( '! '||RPAD(r_data.module, 14, ' ')||' '||RPAD(r_data.object_status, 16, ' ')||'  '||RPAD(r_data.evaluation_status, 14, ' '), ' '); 
	  --
	  END LOOP;
      ECHO( '!', ' ');
	  ECHO( '!', '!');
	ELSIF UPPER(report_on) = 'VERSIONS'      THEN
	  DBMS_OUTPUT.PUT_LINE(CHR(13));
      ECHO( '!!!!!! '||l_context||'.'||v_this_object||' > '||UPPER(report_on)||' ', '!');
      ECHO( '!', ' ');
	  ECHO( '! '||v_min_db_version||v_max_db_version||v_min_app_version||v_max_app_version||v_object_status, ' ');
      ECHO( '! '||RPAD('-', 11, '-')||' '||RPAD('-', 11, '-')||' '||RPAD('-', 11, '-')||' '||RPAD('-', 11, '-')||' '||RPAD('-', 15, '-'), ' ');
      FOR r_data IN c_catalog_versions ('ADMIN')
	  LOOP
	  --
	    ECHO( '! '||RPAD(r_data.min_db_version, 11, ' ')||' '||RPAD(r_data.max_db_version, 11, ' ')||' '||RPAD(r_data.min_app_version, 11, ' ')||' '||RPAD(r_data.max_app_version, 11, ' ')||' '||RPAD(r_data.object_status, 16, ' '), ' '); 
	  --
	  END LOOP;
      ECHO( '!', ' ');
	  ECHO( '!', '!');
	END IF;
	--
  END report_catalog;
  --
BEGIN 
--
  admin_logger.session_details;
--
END admin_objects;
/

