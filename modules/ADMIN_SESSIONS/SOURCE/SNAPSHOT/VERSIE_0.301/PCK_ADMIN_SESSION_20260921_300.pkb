CREATE OR REPLACE PACKAGE BODY admin_session
AS
  -- 202609121_300
  --
  --C- /* ================================================================================================================================================================= */
  --C- CONSTANTS
  --C- /* ================================================================================================================================================================= */
  --C-
  gc_line_feed CONSTANT varchar2(1) := chr(10);
  gc_pref_install_schema constant admin_sessions_prefs.pref_name%type := 'INSTALL_SCHEMA';
  gc_pref_expire_after_days constant admin_sessions_prefs.pref_name%type := 'EXPIRE_AFTER_DAYS';
  gc_pref_grace_after_days constant admin_sessions_prefs.pref_name%type := 'GRACE_AFTER_DAYS';
  gc_pref_admin_session_version constant admin_sessions_prefs.pref_name%type := 'ADMIN_SESSION_VERSION';
  --
  --
  --
  --V- /* ================================================================================================================================================================= */
  --V- VARIABLES
  --V- /* ================================================================================================================================================================= */
  --V-  TABLE-COLUMN                      VARIABLE-NAME
  --V-  ------------------------------    ----------------------------
  --V-  ID                             >> p_trm_id
  --V-  LOG_DATE                       >>
  --V-  INVOKING_USERNAME              >>
  --V-  INVOKING_USER_DETAILS          >>
  --V-  TARGET_USERNAME                >> v_trg_username
  --V-  TARGET_USER_DETAILS            >> v_trg_usr_details
  --V-  INVOKING_USER_ROLES            >>
  --V-  INVOKING_USER_ISADMIN          >> p/v_isusr_adm
  --V-  TARGET_USER_ROLES              >>
  --V-  CONFMTN_REQUIRED               >> p/v_cfm_req
  --V-  CONFMTN_REQUIRED_DATE          >> v_cfm_req_date
  --V-  CONFMTN_GIVEN                  >> p/v_cfm_gvn
  --V-  CONFMTN_GIVEN_DATE             >> v_cfm_gvn_date
  --V-  CONFMTN_GIVEN_BY_USER          >> v_cfm_gvn_by_usr
  --V-  SESSION_MARKED_FOR_TERMNTN     >>
  --V-  SESSION_TERMNTND               >>
  --V-  TERMNTN_REQUEST_ACCEPTED       >> p/v_trm_req_acc
  --V-  TERMNTN_REQUEST_STATUS         >> v_trm_status
  --V-  TARGET_USER_SQLSTMNT           >>
  --V-  TARGET_USER_SQLSTMNTL          >>
  --V-  TARGET_USER_SQLPLANHASH        >>
  --V-  TARGET_USER_SQLID              >>
  --V-  TARGET_USER_SQLID_CHILD#       >>
  --V-  TERMNTN_REQUEST_DENIED_REASON  >> p/v_trm_req_denied_rsn
  --V-  TERMNTN_REQUEST_DENIED_BY      >> p/v_trm_req_denied_by
  --V-  TERMNTN_REQUEST_DENIED_DATE    >>
  --V-
  --V-
  --V-  VARIABLE-NAME                    CONTAINS                       USED-BY
  --V-  ------------------------------   ----------------------------   ------------------------------------------------------------------
  --V-  v_trm_reqr
  --V-  v_trm_result                     FEEDBACK ON CONFIRMATION       terminate_confirm
  --V-  p/v_audsid                       SID || ',' || SERIAL#          get_audsid, get_spid, get_logon_time, get_details,terminate_confirm
  --V-  p/v_username                     USERNAME                       get_details
  --V-  p/v_trm_req_denied_by            USERNAME                       get_details
  --V-  p/v_trm_reqrd
  --V-  p/v_cfm_req                      CONFIRMATION REQUIRED          get_roles
  --V-  p_sid
  --V-  p_serial
  --V-  p_cnl_given                      CANCELATION REQUEST            terminate_cancel
  --V-  p_cnl_reason                     CANCELATION REASON             terminate_cancel
  --V-  p_trgt_sid                                                      terminate_logger
  --V-  p_trgt_serial                                                   terminate_logger
  --V-  p_crg
  --
  --E- /* ================================================================================================================================================================= */
  --E- EXCEPTIONS
  --E- /* ================================================================================================================================================================= */
  --E-
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
  --
  -- /* ================================================================================================================================================================= */
  --  FUNCTIONS
  -- /* ================================================================================================================================================================= */
  --
  -- /* FUNCTION > is_number ----------------------------------------------- BOOL ----- */
  --
  FUNCTION is_number(p_str IN VARCHAR2)
    RETURN boolean
  AS
    l_num number;
  BEGIN
    l_num := to_number(p_str);
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END is_number;
  --
  -- /* FUNCTION > get_invoking_sid ---------------------------------------------------- INVOKING_SID ----- */
  --
  FUNCTION get_invoking_sid RETURN NUMBER
  AS
   v_return NUMBER;
  BEGIN
    SELECT SYS_CONTEXT('userenv','sid') INTO v_return FROM dual;
  --
    RETURN v_return;
  END get_invoking_sid;
  --
  -- /* FUNCTION > get_invoking_serial ---------------------------------------------------- INVOKING_SERIAL# ----- */
  --
  FUNCTION get_invoking_serial RETURN NUMBER
  AS
   v_return NUMBER;
  BEGIN
    SELECT dbms_debug_jdwp.current_session_serial INTO v_return FROM dual;
  --
    RETURN v_return;
  END get_invoking_serial;
  --
  -- /* FUNCTION > get_audsid ---------------------------------------------------- TARGET SID/SERIAL# ----- */
  --
  FUNCTION get_audsid ( p_sid IN NUMBER, p_serial IN NUMBER ) RETURN VARCHAR2
  AS
    v_return VARCHAR2(50);
    v_count  NUMBER(3);
  BEGIN
      SELECT audsid INTO v_return
      FROM v$session
     WHERE sid = p_sid
       AND serial# = p_serial;
  --
    RETURN v_return;
  END get_audsid;
  --
  -- /* FUNCTION > get_spid ---------------------------------------------------- SPID ----- */
  --
  FUNCTION get_spid ( p_sid IN NUMBER, p_serial IN NUMBER ) RETURN VARCHAR2
  AS
   v_return VARCHAR2(24 BYTE);
  BEGIN
    SELECT spid INTO v_return FROM gV$SESSION ses, gV$PROCESS prc WHERE (ses.sid = p_sid AND ses.serial# = p_serial) AND ses.paddr = prc.ADDR(+);
    RETURN v_return;
  END get_spid;
  --
  -- /* FUNCTION > get_logon_time ---------------------------------------------------- LOGON_TIME ----- */
  --
  FUNCTION get_logon_time ( p_sid IN NUMBER, p_serial IN NUMBER ) RETURN DATE
  AS
   v_return DATE;
  BEGIN
    SELECT logon_time INTO v_return FROM gV$SESSION ses WHERE sid = p_sid AND serial# = p_serial;
    RETURN v_return;
  END get_logon_time;
  --
  -- /* FUNCTION > get_pref ---------------------------------------------------- PREF_VALUE ----- */
  --
  FUNCTION get_pref(
    p_pref_name in admin_sessions_prefs.pref_name%type)
    RETURN VARCHAR2
  IS
    l_scope VARCHAR2(30) := 'get_pref';
    l_pref_value admin_sessions_prefs.pref_value%type;
    l_pref_name  admin_sessions_prefs.pref_name%type := UPPER(p_pref_name);
  BEGIN
    SELECT pref_value
      INTO l_pref_value
      FROM (
        SELECT pref_value
          FROM tetools.admin_sessions_prefs
      WHERE pref_name = l_pref_name);
      RETURN l_pref_value;

  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
    WHEN others THEN
      raise;
  END get_pref;
  --
  -- /* FUNCTION > list_session ---------------------------------------------------- CURRENT SESSIONS ----- */
  --
  -- /* SQL_MARCO CANNOT EXIST IN THE SAME PACKAGE AS THE FUNCTION/PROCEDURE THAT CALLS IT */
  -- /* AS IT NEEDS TO BE AVAILABLE WHEN ITS PARSED AT COMPILATION                         */
  --FUNCTION list_session( p_user_id IN VARCHAR2 ) RETURN CLOB SQL_MACRO
  --AS
  --BEGIN
  -- RETURN q'[
  --           SELECT DECODE(ses.username, NULL, SUBSTR(prc.PROGRAM, -5, 4), ses.username) username,
  --                      DECODE(ses.audsid,SYS_CONTEXT('USERENV','SESSIONID'),'*', NULL) s,
  --                      TO_CHAR(ses.logon_time, 'YYYY-MM-DD HH24:MI:SS') logon_time,
  --                      DECODE(ses.audsid, 0, 'Not eligible for termination!', DECODE(ses.username, NULL, 'Not eligible for termination!', 'TETOOLS.ADMIN_SESSION.terminate_session('||ses.sid||', '||ses.serial#||');')) statement,
  --                      audsid, 
  --                      ses.sid, 
  --                      ses.serial#
  --                 FROM v$session ses, v$process prc, dba_users dba
  --                WHERE ses.paddr = prc.addr(+)
  --                  AND ses.user# = dba.user_id
  --                  AND dba.oracle_maintained = 'N'
  --                  AND ses.user# LIKE list_session.p_user_id
  --            ]'; 
  --END;
  --
  -- /* ================================================================================================================================================================= */
  --  PROCEDURES
  -- /* ================================================================================================================================================================= */
  --
  --
  -- /* PROCEDURE > help --------------------------------------------------------------------------------------- USAGE EXAMPLES ----- */
  --
  PROCEDURE help( p_verbose IN VARCHAR2 DEFAULT 'N')
  AS
    v_rowtext  VARCHAR2(32767);
    v_filter_y VARCHAR2(40) := '^[[:space:]]{2}[\-]{2}[H][SV][\-]';
    v_filter_n VARCHAR2(40) := '^[[:space:]]{2}[\-]{2}[H][S][\-]';
    v_verbose  VARCHAR2(40) := v_filter_n;
  	CURSOR c_help(p_verbose IN VARCHAR2) IS
  	  SELECT line, text
  	    FROM dba_source
  	   WHERE name='ADMIN_SESSION'
  	     AND type ='PACKAGE'
  	     AND owner='TETOOLS'
  	     AND REGEXP_LIKE(text, p_verbose)
  	     ORDER BY 1 ASC;
  BEGIN
  /* This procedure extracts the lines of the source of the package specification starting with the leading string for the HELP excerpt. */
  /* Based on the parameter whether the HELP section needs to be verbose or not, the specific string will be used for filtering. */
  IF p_verbose = 'Y' THEN v_verbose := v_filter_y; END IF;
  	FOR r_row IN c_help(v_verbose)
    LOOP
      v_rowtext:=REPLACE(r_row.text,CHR(10),NULL);
      DBMS_OUTPUT.PUT_LINE(REPLACE(v_rowtext,',',', '));
    END LOOP;
  END;
  --
  -- /* PROCEDURE > banner -------------------------------------------------------------------------- PACKAGE DETAILS / HISTORY ----- */
  --
  PROCEDURE banner
  AS
    v_rowtext VARCHAR2(32767);
  	CURSOR c_banner IS
  	  SELECT line, text
  	    FROM dba_source
  	   WHERE name='ADMIN_SESSION'
  	     AND type ='PACKAGE'
  	     AND owner='TETOOLS'
  	     AND REGEXP_LIKE(text, '^[[:space:]]{2}[\-]{2}[B][\-]')
  	     ORDER BY 1 ASC;
  BEGIN
  /* This procedure extracts the lines of the source of the package specification starting with the leading string for the BANNER excerpt. */
  	FOR r_row IN c_banner
    LOOP
      v_rowtext:=REPLACE(r_row.text,CHR(10),NULL);
      DBMS_OUTPUT.PUT_LINE(REPLACE(v_rowtext,',',', '));
    END LOOP;
  END;
  --
  -- /* PROCEDURE > who_called --------------------------------------------------------------------------------- UTL_CALL_STACK ----- */
  --
  PROCEDURE who_called ( p_trm_result          OUT        VARCHAR2 )
  AS
      v_caller utl_call_stack.unit_qualified_name;
      v_name   VARCHAR2(128);
  BEGIN
  /* This procedure retrieves the calling component. */
  /* This information is used for troubleshooting and debugging and has no purpose for standard operational use. */
      -- step backwards though the call stack
      --      1 = current module = who_called function
      --      2 = the module that calls who_called
      --      3 = the caller!
      v_caller := utl_call_stack.subprogram(2);

      p_trm_result := utl_call_stack.concatenate_subprogram(v_caller);

  END who_called;
  --
  -- /* PROCEDURE > list_session --------------------------------------------------------------------------------- CURRENT SESSIONS ----- */
  --
  PROCEDURE list_session ( p_username in varchar2, p_cursor out sys_refcursor )
  AS
    v_username VARCHAR2(128);
  BEGIN
    --
    IF p_username = 'ALL' THEN
      v_username := '%';
    ELSIF p_username = 'SELF' THEN
      v_username := SYS_CONTEXT('USERENV', 'SESSION_USER');
    ELSE
      v_username := '%'||p_username||'%';
    END IF;
    --
    open p_cursor for
     SELECT DECODE(ses.username, NULL, SUBSTR(prc.PROGRAM, -5, 4), ses.username) username,
          DECODE(ses.audsid,SYS_CONTEXT('USERENV','SESSIONID'),'*', NULL) s,
          TO_CHAR(ses.logon_time, 'YYYY-MM-DD HH24:MI:SS') logon_time,
          DECODE(ses.audsid, 0, 'Not eligible for termination!', DECODE(ses.username, NULL, 'Not eligible for termination!', ' EXEC TETOOLS.ADMIN_SESSION.terminate_session('||ses.sid||', '||ses.serial#||');')) statement,
          audsid, 
          ses.sid, 
          ses.serial#
     FROM gv$session ses, gv$process prc, dba_users dba
    WHERE ses.paddr = prc.addr(+)
      AND ses.user# = dba.user_id
      AND dba.oracle_maintained = 'N'
      AND ses.username LIKE v_username;
  END;
  --
  -- /* PROCEDURE > list_sessions --------------------------------------------------------------------------------- CURRENT SESSIONS ----- */
  --
  PROCEDURE list_sessions( p_username IN VARCHAR2 DEFAULT 'SELF' )
  AS
    cur_int sys_refcursor;
  BEGIN
    list_session ( 
      p_username,
      cur_int
    );
    DBMS_SQL.return_result(cur_int);
  END;
  --
  -- /* PROCEDURE > grace --------------------------------------------------------------------------------- SET TRM GRACE PERIOD ----- */
  --
  PROCEDURE grace(
    p_grace_after_days IN NUMBER DEFAULT NULL)
  IS
    $IF $$NO_OP IS NULL OR NOT $$NO_OP $THEN
      l_grace_after_days number := nvl(p_grace_after_days,get_pref(admin_session.gc_pref_grace_after_days));
    $END
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    $IF $$NO_OP $THEN
      NULL;
    $ELSE
     UPDATE admin_sessions_log
        SET termntn_request_status = 'G'
      WHERE termntn_request_status IN ('X','E','O','C')
        AND log_date < SYSTIMESTAMP - NUMTODSINTERVAL(l_grace_after_days, 'day');
    $END
    COMMIT;
  END grace;
  --
  -- /* PROCEDURE > expire --------------------------------------------------------------------------------- SET TRM EXPIRED PERIOD ----- */
  --
  PROCEDURE expire(
    p_expire_after_days IN NUMBER DEFAULT NULL)
  IS
    $IF $$NO_OP IS NULL OR NOT $$NO_OP $THEN
      l_expire_after_days number := nvl(p_expire_after_days,get_pref(admin_session.gc_pref_expire_after_days));
    $END
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    $IF $$NO_OP $THEN
      NULL;
    $ELSE
     UPDATE admin_sessions_log
        SET termntn_request_status = 'T'
      WHERE termntn_request_status IN ('G')
        AND log_date < SYSTIMESTAMP - NUMTODSINTERVAL(l_expire_after_days, 'day');
    $END
    COMMIT;
  END expire;
  --
  -- /* PROCEDURE > GET_TRM_STATUS ----------------------------------------------------------------- GET DETAILS OF QUERIED SESSION ----- */
  --
  PROCEDURE get_trm_status ( p_trm_id           IN         NUMBER DEFAULT 0,   -- /* TERMINATION REQUEST ID */
                             p_sid              IN         NUMBER DEFAULT 0,
                             p_serial           IN         NUMBER DEFAULT 0,
                             p_result_num       OUT        NUMBER
                           )
  AS
    v_this_object            VARCHAR2(128);
    failure_in_calling       EXCEPTION;
    not_correct_status       EXCEPTION;
    v_result                 VARCHAR2(2000);
    v_trm_id_qry             NUMBER(3);
    v_trg_username_qry       VARCHAR2(128);
    v_trg_sid_qry            NUMBER;
    v_trg_serial_qry         NUMBER;
    v_trg_audsid_qry         NUMBER;
    v_trm_status             CHAR(1);
    match_count              NUMBER;
    /* Below cursor is written so any request id will yield a number of hitsas match_count */
    CURSOR c_get_trm_status(p_trm_id IN NUMBER, p_sid IN NUMBER, p_serial IN NUMBER) IS
    SELECT a.match_count, a.id, b.username, b.sid, b.serial, b.audsid, b.termntn_request_status 
      FROM
           (SELECT NVL(MAX(asl.id), p_trm_id) AS id, count(*) match_count
                         FROM tetools.admin_sessions_log asl
                        WHERE ((    TO_NUMBER(JSON_VALUE(asl.target_user_details, '$.SID')) = p_sid
                                AND TO_NUMBER(JSON_VALUE(asl.target_user_details, '$.SERIAL#')) = p_serial
                               )
                                 OR asl.id =p_trm_id)
                          AND asl.termntn_request_status IN ('O','C','X','M')) a,
                          --group by audsid) a,
           (SELECT NVL(asl.id, p_trm_id) AS id, 
                  ses.username,
                  ses.sid,
                  ses.serial# AS serial,
                  ses.audsid,
                  asl.termntn_request_status 
             FROM tetools.admin_sessions_log asl,
                  v$session ses
            WHERE TO_NUMBER(JSON_VALUE(target_user_details, '$.AUDSID')) = ses.audsid
              AND TO_NUMBER(JSON_VALUE(asl.target_user_details, '$.SID')) = ses.sid
              AND TO_NUMBER(JSON_VALUE(asl.target_user_details, '$.SERIAL#')) = ses.serial#
              AND ((    TO_NUMBER(JSON_VALUE(asl.target_user_details, '$.SID')) = p_sid
                    AND TO_NUMBER(JSON_VALUE(asl.target_user_details, '$.SERIAL#')) = p_serial
                   )
                     OR asl.id =p_trm_id)) b
     WHERE a.id = b.id(+);

  BEGIN
  /* This procedure should verify whether a termination request already exists for a given session (sid/serial). */
  /* This procedure will be called from [terminate_session]. */
  	--
    tetools.admin_session.who_called(v_this_object);
    --
    --DBMS_OUTPUT.PUT_LINE(v_this_object|| ' > 3164640814');
    --
    /* VALIDATE INPUT PARAMETERS */
    --IF (p_sid = 0 OR p_serial = 0) OR p_trm_id = 0 THEN
    --	v_result := 'Procedure was called with invalid/missing parameters.';
    --  RAISE failure_in_calling;
    --END IF;
    --
    OPEN c_get_trm_status(p_trm_id, p_sid, p_serial);
    FETCH c_get_trm_status INTO match_count, v_trm_id_qry, v_trg_username_qry, v_trg_sid_qry, v_trg_serial_qry, v_trg_audsid_qry, v_trm_status;
    CLOSE c_get_trm_status;
    --
    --DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 6682882743');
    --
    IF match_count > 0 THEN
      p_result_num := v_trm_id_qry;
    ELSIF match_count = 0 THEN
      p_result_num := 0;
    ELSE
      p_result_num := 2;
    END IF;
  EXCEPTION
  WHEN failure_in_calling THEN
    DBMS_OUTPUT.PUT_LINE(v_this_object|| ' > failure_in_calling: > '|| DBMS_UTILITY.format_error_stack);
    DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 9104860624');
  WHEN not_correct_status THEN
    DBMS_OUTPUT.PUT_LINE(v_this_object|| ' > not_correct_status: > '|| DBMS_UTILITY.format_error_stack);
    DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 4136315860');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(v_this_object|| ' > OTHERS: > '|| DBMS_UTILITY.format_error_stack);
    DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 8270818264');
  END get_trm_status;
  --
  -- /* PROCEDURE > SET_TRM_STATUS ----------------------------------------------------------------- GET DETAILS OF QUERIED SESSION ----- */
  --
  PROCEDURE set_trm_status ( p_trm_id              IN         NUMBER,
                             p_trm_status          IN         VARCHAR2,
                             p_cfm_req             IN         VARCHAR2 DEFAULT 'Y',
                             p_result_num          OUT        NUMBER,
                             p_result              OUT        VARCHAR2)
  AS
    v_this_object            VARCHAR2(128);
    not_correct_status       EXCEPTION;
    v_trm_trmnd              CHAR(1)       := 'N';
    v_cfm_req                CHAR(1)       := p_cfm_req;
    v_jobsql                 VARCHAR2(200) := 'UPDATE tetools.admin_sessions_log SET termntn_request_status = :v_trm_status, session_termntnd = :v_trm_trmnd, confmtn_required = :v_cfm_req WHERE id = :v_trm_id';
  BEGIN
  /* This procedure sets the status of a termination request. */
  /* This procedure is called in the procedure "EJECT_SESSION" and in various other procedures after a validation has taken place whether the request is still valid or executed. */
  	--
    tetools.admin_session.who_called(v_this_object);
    --
  	IF p_trm_status IN ('O','X','E','R','D','M','C') THEN
  	  --DBMS_OUTPUT.PUT_LINE(v_this_object|| ' (O, X, E, R..) p_cfm_req: '|| p_cfm_req);
      --DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 0484092389 '||p_trm_status||', '||v_trm_trmnd||', '||p_cfm_req||', '||p_trm_id);
      EXECUTE IMMEDIATE v_jobsql USING p_trm_status, v_trm_trmnd, p_cfm_req, p_trm_id;
      p_result_num := 0;
    ELSIF p_trm_status = 'K' THEN
      v_trm_trmnd := 'Y';
      --DBMS_OUTPUT.PUT_LINE(v_this_object|| ' (K) p_cfm_req: '|| p_cfm_req);
      --DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 2505139488 '||p_trm_status||', '||v_trm_trmnd||', '||p_cfm_req||', '||p_trm_id);
      EXECUTE IMMEDIATE v_jobsql USING p_trm_status, v_trm_trmnd, p_cfm_req, p_trm_id;
      p_result_num := 0;
    ELSE
      RAISE not_correct_status;
    END IF;
    COMMIT;
  EXCEPTION
  WHEN not_correct_status THEN
      p_result_num := 1;
      p_result := v_this_object||': REQUEST FOR STATUS UPDATE COULD NOT BE PROCESSED. WRONG STATUS IDENTIFIED WAS GIVEN: '||p_trm_status ;
      DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 3087752308 > '|| DBMS_UTILITY.format_error_stack);   
      --p_result := p_result||chr(13)||chr(10)||DBMS_UTILITY.format_error_stack;
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 0168116940 '|| DBMS_UTILITY.format_error_stack);
  END set_trm_status;
  --
  -- /* PROCEDURE > GET_DETAILS ---------------------------------------------------------------- GET DETAILS OF QUERIED SESSION ----- */
  --
  PROCEDURE get_details ( p_sid                IN         NUMBER,
                          p_serial             IN         NUMBER,
                          p_result_num         OUT        NUMBER,
                          P_result             OUT        VARCHAR2,
                          p_audsid             OUT        NUMBER,
                          p_username           OUT        VARCHAR2,
                          p_sql_id             OUT        VARCHAR2,
                          p_sql_child_number   OUT        NUMBER,
                          p_trm_req_acc        OUT        VARCHAR2,
                          p_trm_req_denied_by  OUT        VARCHAR2,
                          p_trm_req_denied_rsn OUT        VARCHAR2,
                          p_sqltext            OUT        VARCHAR2,
                          p_cpu_msec           OUT        NUMBER,
                          p_phys_read          OUT        NUMBER,
                          p_phys_write         OUT        NUMBER)
  AS
    no_session_found         EXCEPTION;
    multiple_sessions_found  EXCEPTION;
    v_this_object            VARCHAR2(128);
    v_match_count            NUMBER;
  BEGIN
  /* This procedure retrieves the various details of a termination request. */
  /* These details are used for terminal feedback and validation of the made request. */
  	--
    tetools.admin_session.who_called(v_this_object);
    --
  	SELECT a.match_count, b.username, b.audsid, b.sql_id, b.child_number, b.sql_text, b.cpu_time, b.PHYSICAL_READ_BYTES, b.PHYSICAL_WRITE_BYTES INTO v_match_count, p_username, p_audsid, p_sql_id, p_sql_child_number, p_sqltext, p_cpu_msec, p_phys_read, p_phys_write
      FROM (SELECT NVL(MAX(ses.sid), p_sid) AS sid, count(*) match_count
              FROM v$session ses
             WHERE ses.sid = p_sid
               AND ses.serial# = p_serial) a,
           (SELECT ses.sid, DECODE(ses.username, NULL, SUBSTR(prc.PROGRAM, -5, 4), ses.username) username, audsid, sql.sql_id, sql.child_number, sql.sql_text, sql.cpu_time, sql.PHYSICAL_READ_BYTES, sql.PHYSICAL_WRITE_BYTES --INTO p_ses_qry, p_username, p_audsid, p_sql_id, p_sql_child_number, p_sqltext, p_cpu_msec, p_phys_read, p_phys_write
              FROM gv$session ses, gv$process prc, gv$sql sql
             WHERE ses.paddr = prc.addr(+)
               AND ses.SQL_ADDRESS = sql.address(+)
               AND ses.sql_hash_value = sql.hash_value(+)
               AND ses.sid = p_sid
               AND ses.serial# = p_serial) b
     WHERE a.sid = b.sid(+);
    --
    IF v_match_count = 1 THEN
      p_result_num := 0;
      p_result     := 'DETAILS FOR USER SESSION: '|| p_username ||' RETRIEVED.';
      --DBMS_OUTPUT.PUT_LINE(v_this_object|| ' > DETAILS FOR USER SESSION: '|| p_username ||' RETRIEVED.');
    ELSIF v_match_count = 0 THEN
      RAISE no_session_found;
      DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 4021918122: NO DETAILS FOUND FOR USER SESSION: ('''|| p_sid||','||P_serial||''')');
    ELSE
      RAISE multiple_sessions_found;
      DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 5491615119: NO DISTINCT DETAILS FOUND FOR USER SESSION: ('''|| p_sid||','||P_serial||''')');
    END IF;
    --
  EXCEPTION
  WHEN no_session_found THEN
    p_result_num := 1;
    p_result     := '4021918122: NO DETAILS FOUND FOR USER SESSION: ('''|| p_sid||','||P_serial||''')';
  WHEN multiple_sessions_found THEN
    p_result_num := 2;
    p_result     := '5491615119: NO DISTINCT SESSION FOUND FOR SESSION REQUEST: ('''|| p_sid||','||P_serial||''')';
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 0881191835 '|| DBMS_UTILITY.format_error_stack);
  END get_details;
  --
  -- /* PROCEDURE > COMPARE_ROLES --------------------------------------------------------- QUERY GRANTED ROLES FOR QUERIED SESSION ----- */
  --
  PROCEDURE compare_roles(p_inv_user           IN         VARCHAR2,
                          p_trg_user           IN         VARCHAR2,
                          p_isinvusr_adm       OUT        VARCHAR2,
                          p_istrgusr_adm       OUT        VARCHAR2,
                          p_inv_roles          OUT        VARCHAR2,
                          p_trg_roles          OUT        VARCHAR2,
                          p_cfm_req            OUT        VARCHAR2)
  AS
    v_this_object            VARCHAR2(128);
    v_inv_roles              VARCHAR2(2000);
    v_trg_roles              VARCHAR2(2000);
    v_isinvusr_adm           CHAR(1) := 'N';
    v_istrgusr_adm           CHAR(1) := 'N';
    v_cfm_req                CHAR(1) := 'Y';
    CURSOR c_invuser_roles(p_inv_username IN VARCHAR2)
    IS
      SELECT  granted_role
        FROM  dba_role_privs
       WHERE  grantee = UPPER(p_inv_username);
    CURSOR c_trguser_roles(p_trg_username IN VARCHAR2)
    IS
      SELECT  granted_role
        FROM  dba_role_privs
       WHERE  grantee = UPPER(p_trg_username);
  BEGIN
  /* This procedure retrieves the various roles of the invoking user in comparison with the targeted user. */
  /* This information is used to determine whether a targeted session is eligible for termination or whether a user needs aditional confirmation before a request will be executed. */
  	--
    tetools.admin_session.who_called(v_this_object);
    --
    --DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 4430938709 '|| DBMS_UTILITY.format_error_stack);
    --
    /* The following logic canbe used to compare different characteristics of the users to validate whether and when to execute the requests. */
    /* The comparison for admin roles can be alteredfor them to be retrieved from table tetools.admin_sessions_prefs.                         */
    /* In addition, this table (and procedure) can be made generic when an extra column is added to reflect the current package               */
    FOR r_row IN c_invuser_roles(p_inv_user)
    LOOP
      v_inv_roles := v_inv_roles ||' '|| r_row.granted_role ||',';
      IF r_row.granted_role LIKE '%DBA%' OR r_row.granted_role LIKE '%TET%' THEN
        IF v_isinvusr_adm = 'N' THEN
         v_isinvusr_adm := 'Y';
        END IF;
      END IF;
    END LOOP;
    FOR r_row IN c_trguser_roles(p_trg_user)
    LOOP
      v_trg_roles := v_trg_roles ||' '|| r_row.granted_role ||',';
      IF r_row.granted_role LIKE '%DBA%' OR r_row.granted_role LIKE '%TET%' THEN
        IF v_istrgusr_adm = 'N' THEN
         v_istrgusr_adm := 'Y';
        END IF;
      END IF;
    END LOOP;

    IF v_isinvusr_adm = 'Y' OR (v_isinvusr_adm = 'N' AND v_istrgusr_adm = 'N' ) THEN
      p_cfm_req := 'N';
    ELSE
      p_cfm_req := 'Y';
    END IF;
    p_isinvusr_adm := v_isinvusr_adm;
    p_istrgusr_adm := v_istrgusr_adm;
    /* housekeeping on the retrieved stinrg to remove spaces. */
    SELECT REGEXP_REPLACE(v_inv_roles, ',[ ]*$', '') INTO p_inv_roles FROM dual;
    SELECT REGEXP_REPLACE(v_trg_roles, ',[ ]*$', '') INTO p_trg_roles FROM dual;
    --
    --DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 8710080321 '|| DBMS_UTILITY.format_error_stack);
  EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('COMPARE_ROLES ERROR STACK: '|| DBMS_UTILITY.format_error_stack);
  END compare_roles;
--
-- /* PROCEDURE > EJECT_SESSION ------------------------------------------------------------- TERMINATE SESSION BY TERMSES ID ----- */
--
  PROCEDURE eject_session(p_sid IN NUMBER, p_serial IN NUMBER, p_trm_id IN NUMBER, p_result_num OUT NUMBER, p_result OUT VARCHAR2)
  AS
    -- ORA-00026: "missing or invalid session ID"
    -- ORA-00027: "cannot kill current session"
    -- ORA-00028: "your session has been killed"
    -- ORA-00029: "session is not a user session"
    -- ORA-00030: "user session ID does not exist"
    -- ORA-00031: "session marked for kill"
    v_this_object            VARCHAR2(128);
    v_case_switch            NUMBER;
    v_cfm_req                CHAR(1);
    v_result_num             NUMBER;
    v_result                 VARCHAR2(2000);
    failure_in_calling       EXCEPTION;
    not_correct_session      EXCEPTION;
    marked_for_kill          EXCEPTION;
    v_sql                    VARCHAR2(2000);
    cursor_name              PLS_INTEGER DEFAULT DBMS_SQL.OPEN_CURSOR;
    valid_exec               PLS_INTEGER;
    PRAGMA EXCEPTION_INIT    (failure_in_calling, -00026);
    PRAGMA EXCEPTION_INIT    (not_correct_session, -00027);
    PRAGMA EXCEPTION_INIT    (not_correct_session, -00028);
    PRAGMA EXCEPTION_INIT    (failure_in_calling, -00029);
    PRAGMA EXCEPTION_INIT    (not_correct_session, -00030);
    PRAGMA EXCEPTION_INIT    (marked_for_kill, -00031);
    v_termntn_request_status CHAR(1);
  BEGIN
  	--
    tetools.admin_session.who_called(v_this_object);
    --
    /* VALIDATE INPUT PARAMETERS */
    IF p_sid IS NULL OR p_serial IS NULL OR p_trm_id IS NULL THEN
    	v_result := 'Procedure was called with invalid/missing parameters.';
      RAISE failure_in_calling;
    END IF;
    --
    /* This procedure actually executes the terminate statement. */
    /* The logic should allow for a "Marked for kill" scenario although this has not been tested. */
  	SELECT termntn_request_status, confmtn_required INTO v_termntn_request_status, v_cfm_req FROM TETOOLS.admin_sessions_log WHERE id = p_trm_id;
  	--DBMS_OUTPUT.PUT_LINE(v_this_object|| ' 8913309948 > CFM_REQ:' || v_cfm_req);
  	IF v_termntn_request_status IN ('O', 'C') THEN
  	  set_trm_status(p_trm_id, 'X', v_cfm_req, v_result_num, v_result);  -- EXECUTING
  	  v_sql :=  'ALTER SYSTEM KILL SESSION ''' || p_sid || ',' || p_serial || ''' IMMEDIATE';
      EXECUTE IMMEDIATE v_sql;
      p_result_num := 0;
      p_result := 'REQUESTED SESSION HAS BEEN TERMINATED.';
    ELSE
         RAISE failure_in_calling;
    END IF;
  EXCEPTION
    WHEN marked_for_kill THEN
      p_result_num := 1;
      p_result := 'REQUESTED SESSION HAS BEEN MARKED FOR TERMINATION. SYSTEM WILL EJECT SESSION WHEN APPROPRIATE';
    WHEN failure_in_calling THEN
      p_result_num := 2;
      p_result := NVL(v_result, 'REQUESTED SESSION IS NOT A SESSION ELIGBLE FOR TERMINATION.');
      p_result := p_result||chr(13)||chr(10)||DBMS_UTILITY.format_error_stack;
    WHEN not_correct_session THEN
      p_result_num := 3;
      p_result := 'REQUEST FOR TERMINATION COULD NOT BE PROCESSED. FOLLOW PRECEEDING MESSAGES FOR CAUSE.';
      p_result := p_result||chr(13)||chr(10)||DBMS_UTILITY.format_error_stack;
  END eject_session;
--
--
--  --
--  -- /* PROCEDURE > TERMINATE_CONFIRM --------------------------------- PROVIDE CONFIRMATION TO TERMINATE SESSION BY TERMSES ID ----- */
--  --
  PROCEDURE terminate_confirm( p_trm_id         IN        NUMBER,                               -- /* TERMINATION REQUEST ID */
                               p_cfm_gvn        IN        VARCHAR2,                             -- /* SPECIFY CONFIRMATION FOR GIVEN ID Y/N */
                               p_cfm_rsn        IN        VARCHAR2 DEFAULT 'NOT GIVEN BY USER', -- /* REASON SPECIFIED FOR DENYING TERMINATION REQUEST */
                               p_trm_result     IN OUT    VARCHAR2,                             -- /* FEEDBACK ON CONFIRMATION */
                               p_trm_result_num OUT       NUMBER                                -- /* FEEDBACK NUMBER ON CONFIRMATION */
                             )
  AS
    v_this_object            VARCHAR2(128);
    failure_in_calling       EXCEPTION;
    not_correct_session      EXCEPTION;
    marked_for_kill          EXCEPTION;
    req_denied               EXCEPTION;
    need_to_be_admin         EXCEPTION;
    confirmation_failure     EXCEPTION;
    no_data_found            EXCEPTION;
    PRAGMA EXCEPTION_INIT    (no_data_found, -29307);
    v_sid                    NUMBER;
    v_serial                 NUMBER;
    v_inv_username           VARCHAR2(128) := SYS_CONTEXT('USERENV', 'SESSION_USER');
    v_trg_username           VARCHAR2(128);
    v_trg_usr_details        VARCHAR2(128);
    v_trg_spid_compare       NUMBER;
    v_inv_roles              VARCHAR2(2000);
    v_trg_roles              VARCHAR2(2000);
    v_trm_req_acc            CHAR(1);
    v_trm_status             CHAR(1);
    v_trm_trmnd              CHAR(1) := 'N';
    v_trm_result_num         NUMBER;
    v_trm_result             VARCHAR2(2000);
    v_trm_req_denied_rsn     VARCHAR2(2000) := p_cfm_rsn;
    v_audsid                 NUMBER;
    v_isinvusr_adm           CHAR(1);
    v_istrgusr_adm           CHAR(1);
    v_cfm_req                CHAR(1);
    v_cfm_match_count        NUMBER;
    v_cfm_req_date           DATE;
    v_cfm_gvn                CHAR(1);
    v_cfm_gvn_date           DATE;
    v_cfm_gvn_by_usr         VARCHAR2(128);
    v_trm_req_denied_by      VARCHAR2(128);
    v_cfm_result_num         NUMBER;
    v_cfm_result             VARCHAR2(2000);
    --
    /* Below cursor is written so any request id will yield a number of hitsas match_count */
    CURSOR c_cfm_session(p_trm_id IN NUMBER) IS
    SELECT a.match_count, b.termntn_request_status, b.target_username, b.sid, b.serial, b.audsid, b.target_user_details
      FROM (SELECT NVL(MAX(id), p_trm_id) AS id, count(*) match_count
              FROM tetools.admin_sessions_log
             WHERE id = p_trm_id
               AND termntn_request_status = 'C') a,
           (SELECT id, termntn_request_status, target_username, TO_NUMBER(JSON_VALUE(target_user_details, '$.SID')) sid,TO_NUMBER(JSON_VALUE(target_user_details, '$.SERIAL#')) serial,TO_NUMBER(JSON_VALUE(target_user_details, '$.AUDSID')) audsid, target_user_details
             FROM tetools.admin_sessions_log
            WHERE id = p_trm_id) b
     WHERE a.id = b.id(+);
    --
  BEGIN
    /* This procedure allows an admin to confirm the termination request of another user based on id. */
  	--
    tetools.admin_session.who_called(v_this_object);
    --
    /* VALIDATE INPUT PARAMETERS */
    IF p_trm_id IS NULL OR p_cfm_gvn IS NULL THEN
    	v_trm_result := 'Procedure was called with invalid/missing parameters.';
      RAISE failure_in_calling;
    END IF;
    --
    OPEN c_cfm_session(p_trm_id);
    FETCH c_cfm_session INTO v_cfm_match_count, v_trm_status, v_trg_username, v_sid, v_serial, v_audsid, v_trg_usr_details;
    CLOSE c_cfm_session;
    --
    IF v_cfm_match_count = 1  THEN
      TETOOLS.ADMIN_SESSION.compare_roles( v_inv_username, v_trg_username, v_isinvusr_adm, v_istrgusr_adm, v_inv_roles, v_trg_roles, v_cfm_req );
      /* Because ADMIN privileges are required, "CONFMTN_REQUIRED" will ALWAYS have to be 'Y'. Therefore v_cfm_req will be hardcoded to 'Y' */
      v_cfm_req := 'Y';
      --
      IF v_isinvusr_adm = 'Y' THEN
        IF p_cfm_gvn = 'Y' THEN
            eject_session(v_sid, v_serial, p_trm_id, v_cfm_result_num, v_cfm_result);
            DBMS_OUTPUT.PUT_LINE(v_this_object || ' > ' || v_trg_username || ' SESSION HAS BEEN KILLED. CFM_REQ:' || v_cfm_req);
        ELSIF p_cfm_gvn = 'N' THEN
          set_trm_status(p_trm_id,'D', v_cfm_req, v_cfm_result_num, p_trm_result);
  	      p_trm_result := 0;
  	      RAISE req_denied;
        END IF;
      ELSE
        RAISE need_to_be_admin;
      END IF;
    ELSIF v_cfm_match_count = 0 THEN
      /* No appropriate rows found => cancel. */
      DBMS_OUTPUT.PUT_LINE(v_this_object|| ' > TRM ID '|| p_trm_id ||'GIVEN DOES NOT HAVE A STATUS WHICH CAN BE CANCELED.'|| v_trm_status);
      RAISE failure_in_calling;
      /* Any status other 'C' is not selected. The logic below will never be executed. */
      --IF v_trm_status = 'K' THEN
      --  DBMS_OUTPUT.PUT_LINE(v_this_object|| ' > TRM HAS ALREADY BEEN CLOSED: '|| v_trm_status || '. CFM_REQ:' || v_cfm_req);
      --  set_trm_status(p_trm_id,'R', v_cfm_req, v_cfm_result_num, v_cfm_result);
      --  RAISE failure_in_calling;
      --ELSIF v_trm_status <> 'K' THEN
      --  DBMS_OUTPUT.PUT_LINE(v_this_object|| ' > TRM HAS AN UNEXECUTABLE STATUS: '|| v_trm_status);
      --  RAISE failure_in_calling;
      --END IF;
    END IF;
    --    
    /* The logic below uses a returned integer whether or not the termination statement was succesfully executed. */
    CASE v_cfm_result_num
      WHEN  0 THEN
        DBMS_OUTPUT.PUT_LINE('TERMINATION REQUEST FOR USER HAS BEEN CONFIRMED.');
        v_cfm_gvn        := 'Y';
        v_trm_trmnd      := 'Y';
        v_cfm_gvn_date   := sysdate;
        v_cfm_gvn_by_usr := v_inv_username;
        set_trm_status(p_trm_id, 'K', v_cfm_req, v_cfm_result_num, v_cfm_result);  -- KILLED
        UPDATE tetools.admin_sessions_log SET session_termntnd = v_trm_trmnd, confmtn_given_by_user = v_cfm_gvn_by_usr, confmtn_given = v_cfm_gvn, confmtn_given_date = v_cfm_gvn_date WHERE ID = p_trm_id;
        COMMIT;
      ELSE
        v_cfm_gvn        := 'N';
        v_cfm_req_date   := sysdate;
        CASE v_cfm_result_num
          WHEN  1 THEN
            v_trm_req_denied_by   := 'ORACLE';
            DBMS_OUTPUT.PUT_LINE('REQUEST DENIED: TERMINATION REQUEST '|| p_trm_id ||' TARGETS A SYS SESSION OR BACKGROUND PROCESS.');
            v_trm_req_denied_rsn  := 'REQUEST DENIED: TERMINATION REQUEST '|| p_trm_id ||' TARGETS A SYS SESSION OR BACKGROUND PROCESS.';
            UPDATE tetools.admin_sessions_log SET session_termntnd = v_trm_trmnd, termntn_request_denied_by = v_trm_req_denied_by, confmtn_given = v_cfm_gvn, confmtn_given_date = v_cfm_gvn_date WHERE ID = p_trm_id;
            COMMIT;
          WHEN  2 THEN
            v_trm_req_denied_by   := 'ORACLE';
            DBMS_OUTPUT.PUT_LINE('AN INVALID PARAMETER WAS GIVEN');
            v_trm_req_denied_rsn  := 'AN INVALID PARAMETER WAS GIVEN';
            UPDATE tetools.admin_sessions_log SET session_termntnd = v_trm_trmnd, termntn_request_denied_by = v_trm_req_denied_by, confmtn_given = v_cfm_gvn, confmtn_given_date = v_cfm_gvn_date WHERE ID = p_trm_id;
            COMMIT;
          WHEN  3 THEN
            v_trm_req_denied_by   := 'ADMIN_SESSION PACKAGE';
            DBMS_OUTPUT.PUT_LINE('TERMINATION REQUEST IS CLOSED, CONFIRMATION IS NOT POSSIBLE.');
            v_trm_req_denied_rsn  := 'TERMINATION REQUEST IS CLOSED, CONFIRMATION IS NOT POSSIBLE.';
            UPDATE tetools.admin_sessions_log SET session_termntnd = v_trm_trmnd, termntn_request_denied_by = v_trm_req_denied_by, confmtn_given = v_cfm_gvn, confmtn_given_date = v_cfm_gvn_date WHERE ID = p_trm_id;
            COMMIT;
          ELSE
            set_trm_status(p_trm_id,'D', v_cfm_req, v_cfm_result_num, v_cfm_result);  -- DENIED
            UPDATE tetools.admin_sessions_log SET session_termntnd = v_trm_trmnd, termntn_request_denied_by = v_trm_req_denied_by, confmtn_given = v_cfm_gvn, confmtn_given_date = v_cfm_gvn_date, termntn_request_denied_reason = v_trm_req_denied_rsn WHERE ID = p_trm_id;
            COMMIT;
            RAISE confirmation_failure;
        END CASE;
    END CASE;
  	--
  EXCEPTION
    WHEN req_denied THEN  -- start handling exception
      v_trm_result := NVL(v_trm_req_denied_rsn, v_trm_result);
  	  DBMS_OUTPUT.PUT_LINE('TERMINATION REQUEST FOR USER: '|| v_trg_username ||' WITH DETAILS: '|| v_trg_usr_details || ' HAS BEEN DENIED.');
      UPDATE tetools.admin_sessions_log ast SET termntn_request_denied_reason = v_trm_req_denied_rsn,
  	                                            termntn_request_denied_by     = v_inv_username,
  	                                            termntn_request_denied_date   = sysdate
  	                                      WHERE ast.id = p_trm_id;
  	  COMMIT;
    WHEN need_to_be_admin THEN
      v_trm_result := NVL(v_trm_req_denied_rsn, v_trm_result);
  	  DBMS_OUTPUT.PUT_LINE('TERMINATION REQUEST FOR USER: '|| v_trg_username ||' WITH DETAILS: '|| v_trg_usr_details || ' NEEDS ADDITIONAL ACTIVITIES.');
      DBMS_OUTPUT.PUT_LINE('** INVOKING USER OF TERMINATION REQUEST NEEDS TO BE AN ADMIN USER FOR THIS REQUEST/SESSION. TERMINATION REQUEST '||p_trm_id||' AWAITS CONFIRMATION.');
      set_trm_status(p_trm_id, 'C', v_cfm_req, v_cfm_result_num, v_cfm_result);  -- ERROR
      UPDATE tetools.admin_sessions_log SET confmtn_required_date = sysdate WHERE ID = p_trm_id;
  	  COMMIT;
    WHEN failure_in_calling THEN
      v_trm_result := NVL(v_trm_req_denied_rsn, v_trm_result);
  	  DBMS_OUTPUT.PUT_LINE('TERMINATION REQUEST FOR USER: '|| v_trg_username ||' WITH DETAILS: '|| v_trg_usr_details || ' HAS FAILED.');
      UPDATE tetools.admin_sessions_log ast SET termntn_request_denied_reason = 'Session noted in target_user_details is no longer present in database, termination request will be canceled.',
  	                                            termntn_request_denied_by     = 'ADMIN_SESSION PACKAGE',
  	                                            termntn_request_denied_date   = sysdate
  	                                      WHERE ast.id = p_trm_id;
  	  COMMIT;
  	WHEN no_data_found THEN
      v_trm_result := NVL(v_trm_req_denied_rsn, v_trm_result);
      DBMS_OUTPUT.PUT_LINE('NO DATA FOUND ON GIVEN SESSION DETAILS.');
      DBMS_OUTPUT.PUT_LINE('** THE RETRIEVAL ON ID: '||p_trm_id||' HAS FAILED DUE TO:');
      DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 6144993772 > '|| DBMS_UTILITY.format_error_stack);
      DBMS_OUTPUT.PUT_LINE(v_trm_result);
    WHEN OTHERS THEN
      v_trm_result := NVL(v_trm_req_denied_rsn, v_trm_result);
      DBMS_OUTPUT.PUT_LINE('EXCEPTION CATCHALL EXECUTED.');
      DBMS_OUTPUT.PUT_LINE('** THE TERMINATION OF CONFIRMATION ID: '||p_trm_id||' HAS FAILED DUE TO:');
      DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 0054154136 > '|| DBMS_UTILITY.format_error_stack);
      set_trm_status(p_trm_id, 'E', v_cfm_req, v_cfm_result_num, v_cfm_result);  -- ERROR;
      DBMS_OUTPUT.PUT_LINE(v_trm_result);
      UPDATE tetools.admin_sessions_log SET termntn_request_denied_reason = v_trm_result, termntn_request_denied_by = 'SYSTEM', termntn_request_denied_date = sysdate WHERE ID = p_trm_id;
  	  COMMIT;
  END terminate_confirm;
--  --
--  -- /* PROCEDURE > TERMINATE_STATUS ---------------------------------------------------------- QUERY STATUS OF TERMSES REQUEST ----- */
--  --
  PROCEDURE terminate_status( p_trm_id        IN        NUMBER   DEFAULT 999999999999,   -- /* TERMINATION REQUEST ID */
                              p_trm_status    IN        VARCHAR2 DEFAULT 'Z'             -- /* TERMINATION REQUEST STATUS */
                             )
  AS
    q_trm_id VARCHAR2(32767) := 'SELECT TO_CHAR(ast.log_date, ''YYYY-MM-DD HH24:MI:SS'') log_date,
                                         ast.invoking_username,
                                         ast.target_username,
                                         ast.invoking_user_isadmin,
                                         ast.target_user_isadmin,
                                         ast.confmtn_required,
                                         TO_CHAR(ast.confmtn_required_date, ''YYYY-MM-DD HH24:MI:SS'') confmtn_required_date,
                                         ast.confmtn_given,
                                         TO_CHAR(ast.confmtn_given_date, ''YYYY-MM-DD HH24:MI:SS'') confmtn_given_date,
                                         ast.confmtn_given_by_user,
                                         ast.session_marked_for_termntn,
                                         ast.session_termntnd,
                                         ast.termntn_request_accepted,
                                         CASE ast.termntn_request_status
                                           WHEN ''O'' THEN ''Request open''
                                           WHEN ''K'' THEN ''Session killed''
                                           WHEN ''C'' THEN ''Awaiting confirmation''
                                           WHEN ''R'' THEN ''Request retracted''
                                           WHEN ''D'' THEN ''Request denied''
                                           WHEN ''E'' THEN ''Termination request in Error''
                                           WHEN ''X'' THEN ''Termination request Executing''
                                         END termntn_request_status,
                                         ast.termntn_request_denied_reason,
                                         ast.termntn_request_denied_by,
                                         TO_CHAR(ast.termntn_request_denied_date, ''YYYY-MM-DD HH24:MI:SS'') termntn_request_denied_date
                                    FROM tetools.admin_sessions_log ast
                                   WHERE ast.id = :v_trm_id';
    q_trm_st VARCHAR2(32767) := 'SELECT ast.id trm_id,
                                        TO_CHAR(ast.log_date, ''YYYY-MM-DD HH24:MI:SS'') log_date,
                                        CASE ast.termntn_request_status
                                          WHEN ''O'' THEN ''Request open''
                                          WHEN ''K'' THEN ''Session killed''
                                          WHEN ''C'' THEN ''Awaiting confirmation''
                                          WHEN ''R'' THEN ''Request retracted''
                                          WHEN ''D'' THEN ''Request denied''
                                          WHEN ''E'' THEN ''Termination request in Error''
                                          WHEN ''X'' THEN ''Termination request Executing''
                                        END termntn_request_status,
                                        ast.invoking_username,
                                        ast.target_username,
                                        ast.confmtn_given,
                                        TO_CHAR(ast.confmtn_given_date, ''YYYY-MM-DD HH24:MI:SS'') confmtn_given_date,
                                        ast.confmtn_given_by_user,
                                        ast.termntn_request_accepted,
                                        ast.termntn_request_denied_reason,
                                        MAX(LENGTH(ast.termntn_request_denied_reason)) OVER () den_length_reason,
                                        ast.termntn_request_denied_by,
                                        TO_CHAR(ast.termntn_request_denied_date, ''YYYY-MM-DD HH24:MI:SS'') termntn_request_denied_date
                                   FROM tetools.admin_sessions_log ast
                                  WHERE ast.termntn_request_status = :v_trm_status';
    v_this_object            VARCHAR2(128);
    failure_in_calling       EXCEPTION;
    v_trm_status             CHAR(1);
    c_cursor_id              INTEGER DEFAULT DBMS_SQL.OPEN_CURSOR;
    c_cursor_st              INTEGER DEFAULT DBMS_SQL.OPEN_CURSOR;
    v_colval_id              VARCHAR2(4000);
    v_colval_st              VARCHAR2(4000);
    v_status_id              INTEGER;
    v_status_st              INTEGER;
    v_descTbl_id             DBMS_SQL.DESC_TAB;
    v_descTbl_st             DBMS_SQL.DESC_TAB;
    v_colCnt_id              NUMBER;
    v_colCnt_st              NUMBER;
    v_trm_result             VARCHAR2(2000);
    n                        NUMBER  := 0;
    s                        CHAR(1) := ' ';
    h                        CHAR(1) := '-';
    --
    PROCEDURE p(msg VARCHAR2) IS
      l VARCHAR2(4000) := msg;
    BEGIN
      WHILE LENGTh(l) > 0 Loop
        DBMS_OUTPUT.PUT_LINE(SUBSTR(l,1,200));
        l := SUBSTR(l,201);
      END LOOP;
    END;
    --
    PROCEDURE echo( p_string IN VARCHAR2, p_size IN NUMBER, p_pad IN VARCHAR2)
    AS
    BEGIN
      DBMS_OUTPUT.PUT_LINE( RPAD( p_string, p_size, p_pad) );
    END;
    BEGIN
    --
    tetools.admin_session.who_called(v_this_object);
    --
    /* VALIDATE INPUT PARAMETERS */
    IF p_trm_id IS NULL OR p_trm_status IS NULL THEN
    	v_trm_result := 'Procedure was called with invalid/missing parameters.';
      RAISE failure_in_calling;
    END IF;
    --
    EXECUTE IMMEDIATE  'alter session set nls_date_format=''YYYY-MM-DD HH24:MI:SS'' ';
    --
    /* The following code is default borrowed StackOverflow logic. */
    /* It pivots the columns to rows. Depending on the parameters given, it searches for a single row (id) of a status. */
    IF p_trm_status = 'Z' AND p_trm_id IS NOT NULL THEN
      DBMS_SQL.PARSE(  c_cursor_id,  q_trm_id, dbms_sql.native );
      DBMS_SQL.BIND_VARIABLE(  c_cursor_id,  ':v_trm_id', p_trm_id);
      DBMS_SQL.DESCRIBE_COLUMNS( c_cursor_id, v_colCnt_id, v_descTbl_id );
  
      FOR i IN 1 .. v_colCnt_id LOOP
          DBMS_SQL.DEFINE_COLUMN(c_cursor_id, i, v_colval_id, 4000);
      END LOOP;
  
      v_status_id := DBMS_SQL.EXECUTE(c_cursor_id);
  
      WHILE ( DBMS_SQL.FETCH_ROWS(c_cursor_id) > 0 ) LOOP
          FOR i IN 1 .. v_colCnt_id LOOP
              DBMS_SQL.COLUMN_VALUE( c_cursor_id, i, v_colval_id );
              p( RPAD( v_descTbl_id(i).col_name, 30 )
                || ': ' ||
                v_colval_id );
          END LOOP;
          --DBMS_OUTPUT.PUT_LINE( '-----------------' );
          n := n + 1;
      END LOOP;
      IF n = 0 THEN
        DBMS_OUTPUT.PUT_LINE( CHR(10)||'No data found '||CHR(10) );
      END IF;
    ELSIF p_trm_status <> 'Z' AND p_trm_status IN ('E','O','K','C','R','D') THEN
      DBMS_SQL.PARSE(  c_cursor_st,  q_trm_st, dbms_sql.native );
      DBMS_SQL.BIND_VARIABLE(  c_cursor_st,  ':v_trm_status', p_trm_status);
      DBMS_SQL.DESCRIBE_COLUMNS( c_cursor_st, v_colCnt_st, v_descTbl_st );
  
      FOR i IN 1 .. v_colCnt_st LOOP
          DBMS_SQL.DEFINE_COLUMN(c_cursor_st, i, v_colval_st, 4000);
      END LOOP;
  
      v_status_st := DBMS_SQL.EXECUTE(c_cursor_st);
  
      DBMS_OUTPUT.PUT_LINE( '/* == TRM REQUEST STATUS '|| p_trm_status || ' ================================================================ */' );
      
      WHILE ( DBMS_SQL.FETCH_ROWS(c_cursor_st) > 0 ) LOOP
        DBMS_SQL.COLUMN_VALUE( c_cursor_st, 1, v_colval_st );
        DBMS_OUTPUT.PUT_LINE( '   -- TRM ID: '|| v_colval_st || ' ------------------------------------------ ' );
          FOR i IN 1 .. v_colCnt_st LOOP
              DBMS_SQL.COLUMN_VALUE( c_cursor_st, i, v_colval_st );
              p( RPAD( v_descTbl_st(i).col_name, 30 ) || ': ' || v_colval_st );
          END LOOP;
          DBMS_OUTPUT.PUT_LINE( '--' );
          DBMS_OUTPUT.PUT_LINE( '--' );
          n := n + 1;
      END LOOP;
      DBMS_OUTPUT.PUT_LINE( '/* == END TRM STATUS ====================================================================== */' );
      IF n = 0 THEN
        DBMS_OUTPUT.PUT_LINE( CHR(10)||'No data found '||CHR(10) );
      END IF;
  
    ELSE
      RAISE failure_in_calling;
    END IF;
    --
    EXCEPTION
      WHEN failure_in_calling THEN
        v_trm_result := NVL(v_trm_result, '** THE FOLLOWING PARAMETERS ARE ACCEPTED:(''E'',''O'',''K'',''C'',''R'',''D'')');
    	  DBMS_OUTPUT.PUT_LINE(v_this_object || ' WRONG PARAMETER GIVEN: '|| p_trm_status);
        DBMS_OUTPUT.PUT_LINE(v_trm_result);
        DBMS_OUTPUT.PUT_LINE('** CONSULT TETOOLS.ADMIN_SESSION.help FOR USAGE EXAMPLES.');
  END terminate_status;
--
--  --
--  -- /* PROCEDURE > TERMINATE_CANCEL ----------------------------------------------------- CANCEL TERMSES REQUEST BY TERMSES ID ----- */
--  --
  PROCEDURE terminate_cancel( p_trm_id        IN        NUMBER,               -- /* TERMINATION REQUEST ID */
                              p_cnl_given     IN        VARCHAR2 DEFAULT 'Y', -- /* SPECIFY CANCELATION REQUEST FOR GIVEN ID Y/N */
                              p_cnl_reason    IN        VARCHAR2,             -- /* SPECIFY CANCELATION RREASON FOR GIVEN ID */
                              p_trm_result    OUT       VARCHAR2              -- /* FEEDBACK ON CANCELATION REQUEST */
                             )
  AS
    v_this_object            VARCHAR2(128);
    failure_in_calling       EXCEPTION;
    not_correct_session      EXCEPTION;
    marked_for_kill          EXCEPTION;
    cnl_denied               EXCEPTION;
    need_to_be_admin         EXCEPTION;
    confirmation_failure     EXCEPTION;
    v_inv_username_cur       VARCHAR2(128) := SYS_CONTEXT('USERENV', 'SESSION_USER');
    v_inv_username           VARCHAR2(128);
    v_trg_username           VARCHAR2(128);
    v_trg_usr_details        VARCHAR2(500);
    v_trm_status_cur         CHAR(1);
    v_trm_status_den         CHAR(1) := 'R';
    v_cfm_req                CHAR(1);
    v_trm_result             VARCHAR2(2000);
    v_inv_roles              VARCHAR2(2000);
    v_trg_roles              VARCHAR2(2000);
    v_cfm_match_count        NUMBER;
    v_audsid                 NUMBER;
    v_username               VARCHAR2(128);
    v_isinvusr_adm           CHAR(1);
    v_istrgusr_adm           CHAR(1);
    v_trm_req_acc            CHAR(1);
    v_trm_req_denied_by      VARCHAR2(128) := v_inv_username_cur;
    v_trm_req_denied_rsn     VARCHAR2(2000) := p_cnl_reason;
    v_jobsql                 VARCHAR2(2000) := 'UPDATE tetools.admin_sessions_log SET termntn_request_status = :v_trm_status_den, termntn_request_denied_reason = :v_trm_req_denied_rsn, termntn_request_denied_by = :v_trm_req_denied_by, termntn_request_denied_date = sysdate WHERE id = :v_trm_id';

    --
  	CURSOR c_cnl_request(p_trm_id IN NUMBER) IS
    SELECT a.match_count, b.TERMNTN_REQUEST_STATUS, b.CONFMTN_REQUIRED, b.INVOKING_USERNAME, b.TARGET_USERNAME, b.TARGET_USER_DETAILS
      FROM (SELECT NVL(MAX(id), p_trm_id) AS id, count(*) match_count
              FROM tetools.admin_sessions_log
             WHERE id = p_trm_id
               AND termntn_request_status IN ('O','C')) a,
  	       (SELECT id, TERMNTN_REQUEST_STATUS, CONFMTN_REQUIRED, INVOKING_USERNAME, TARGET_USERNAME, TARGET_USER_DETAILS
  	          FROM tetools.admin_sessions_log
  	         WHERE id = p_trm_id) b
     WHERE a.id = b.id(+);
  BEGIN
  	/* This procedure allows a user to cancel a request. This helps in housekeeping of the requests in total, and prevents erroneous execution of requests */
  	TETOOLS.ADMIN_SESSION.who_called(v_this_object);
  	TETOOLS.ADMIN_SESSION.compare_roles( v_inv_username_cur, v_trg_username, v_isinvusr_adm, v_istrgusr_adm, v_inv_roles, v_trg_roles, v_cfm_req );
  --
  /* VALIDATE INPUT PARAMETERS */
  IF p_trm_id IS NULL THEN
  	v_trm_result := 'Procedure was called with invalid/missing parameters.';
    RAISE failure_in_calling;
  ELSIF p_cnl_given IS NULL OR p_cnl_given NOT IN ('Y', 'N') THEN
  	v_trm_result := 'Procedure was called with invalid/missing parameters.';
    RAISE failure_in_calling;
  ELSIF p_cnl_reason IS NULL THEN
  	v_trm_result := 'Procedure was called with invalid/missing parameters.';
    RAISE failure_in_calling;
  END IF;
  --
    OPEN c_cnl_request(p_trm_id);
    FETCH c_cnl_request  INTO v_cfm_match_count, v_trm_status_cur, v_cfm_req, v_inv_username, v_trg_username, v_trg_usr_details;
    CLOSE c_cnl_request;
    --
    IF v_cfm_match_count = 1  THEN
      IF ( v_cfm_req = 'Y' AND v_isinvusr_adm = 'Y' ) OR v_inv_username = v_inv_username_cur THEN
       IF p_cnl_given = 'Y' THEN
         EXECUTE IMMEDIATE v_jobsql USING v_trm_status_den, v_trm_req_denied_rsn, v_trm_req_denied_by, p_trm_id;
         COMMIT;
         DBMS_OUTPUT.PUT_LINE(v_this_object || ' > TRM REQUEST FOR ' || v_trg_username || ' SESSION HAS BEEN RETRACTED. CFM_REQ:' || v_cfm_req);
  	     p_trm_result := 0;
       ELSIF p_cnl_given = 'N' THEN
         /* This part *should* not be necessary. Why execute this procedure for not using it!? */
         DBMS_OUTPUT.PUT_LINE(v_this_object || ' > TRM REQUEST FOR ' || v_trg_username || ' SESSION WAS NOT RETRACTED. CONFIRMATION NOT GIVEN');
  	     p_trm_result := 0;
  	     RAISE cnl_denied;
       END IF;
     ELSE
       RAISE need_to_be_admin;
     END IF;
    ELSIF v_cfm_match_count = 0 THEN
      DBMS_OUTPUT.PUT_LINE(v_this_object || ' > TRM REQUEST FOR ' || v_trg_username || ' SESSION COULD NOT BE FOUND WITH CORRECT STATUS. CURRENT STATUS (IF EXISTS):' || NVL(v_trm_status_cur, 'NOT FOUND!'));
      RAISE failure_in_calling;
    END IF;
  EXCEPTION
    WHEN cnl_denied THEN  -- start handling exception
      v_trm_result := NVL(v_trm_req_denied_rsn, v_trm_result);
  	  DBMS_OUTPUT.PUT_LINE('CANCELATION REQUEST FOR USER: '|| v_trg_username ||' WITH DETAILS: '|| v_trg_usr_details || ' HAS BEEN DENIED.');
      UPDATE tetools.admin_sessions_log ast SET termntn_request_denied_reason = v_trm_req_denied_rsn,
  	                                            termntn_request_denied_by     = v_inv_username_cur,
  	                                            termntn_request_denied_date   = sysdate
  	                                      WHERE ast.id = p_trm_id;
  	  COMMIT;
    WHEN need_to_be_admin THEN
      v_trm_result := NVL(v_trm_req_denied_rsn, v_trm_result);
  	  DBMS_OUTPUT.PUT_LINE('TERMINATION REQUEST FOR USER: '|| v_trg_username ||' WITH DETAILS: '|| v_trg_usr_details || ' NEEDS ADDITIONAL ACTIVITIES.');
      DBMS_OUTPUT.PUT_LINE('** INVOKING USER OF CANCELATION REQUEST NEEDS TO BE AN ADMIN USER FOR THIS REQUEST/SESSION. TERMINATION REQUEST '||p_trm_id||' REMAINS IN STATUS: '|| v_trm_status_cur);
    WHEN failure_in_calling THEN
      v_trm_result := NVL(v_trm_req_denied_rsn, v_trm_result);
  	  DBMS_OUTPUT.PUT_LINE('CANCELATION REQUEST FOR USER: '|| v_trg_username ||' WITH DETAILS: '|| v_trm_result || ' HAS FAILED. NO ELIGBLE TERMINATION REQUEST HAD BEEN FOUND.');
    WHEN OTHERS THEN
      v_trm_result := NVL(v_trm_req_denied_rsn, v_trm_result);
      DBMS_OUTPUT.PUT_LINE('EXCEPTION CATCHALL EXECUTED.');
      DBMS_OUTPUT.PUT_LINE('** THE TERMINATION OF CONFIRMATION ID: '||p_trm_id||' HAS FAILED DUE TO:');
      DBMS_OUTPUT.PUT_LINE(v_trm_result);
  END terminate_cancel;
--
--  --
--  -- /* PROCEDURE > TERMINATE_SESSION -------------------------------------------------------- TERMINATE SESSION BY SID/SERIAL# ----- */
--  --
  PROCEDURE terminate_session( p_trgt_sid      IN         NUMBER,           -- /* TARGET USER SID */
                               p_trgt_serial   IN         NUMBER            -- /* TARGET USER SERIAL# */
                             )
  AS
    v_this_object            VARCHAR2(128);
    failure_in_calling       EXCEPTION;
    not_correct_session      EXCEPTION;
    marked_for_kill          EXCEPTION;
    req_denied               EXCEPTION;
    need_to_be_admin         EXCEPTION;
    confirmation_failure     EXCEPTION;
    trm_request_exists       EXCEPTION;
    PRAGMA EXCEPTION_INIT    (failure_in_calling, -00026);
    PRAGMA EXCEPTION_INIT    (not_correct_session, -00027);
    PRAGMA EXCEPTION_INIT    (not_correct_session, -00028);
    PRAGMA EXCEPTION_INIT    (failure_in_calling, -00029);
    PRAGMA EXCEPTION_INIT    (not_correct_session, -00030);
    PRAGMA EXCEPTION_INIT    (marked_for_kill, -00031);
    v_trm_id                 tetools.admin_sessions_log.id%TYPE;
    v_sid                    NUMBER := p_trgt_sid;
    v_serial                 NUMBER := p_trgt_serial;
    v_audsid                 NUMBER;
    v_inv_username           VARCHAR2(128) := SYS_CONTEXT('USERENV', 'SESSION_USER');
    v_trg_username           VARCHAR2(128);
    v_trg_usr_details        VARCHAR2(128);
    v_trg_usr_compare        VARCHAR2(50);
    v_inv_roles              VARCHAR2(2000);
    v_trg_roles              VARCHAR2(2000);
    v_sql_id                 VARCHAR2(13);
    v_sql_child_number       NUMBER;
    v_sqltext                VARCHAR2(1000);
    v_cpu_msec               NUMBER;
    v_phys_read              NUMBER;
    v_phys_write             NUMBER;
    v_trm_status             CHAR(1);
    v_trm_trmnd              CHAR(1) := 'N';
    v_trm_req_acc            CHAR(1);
    v_trm_result_num         NUMBER;
    v_trm_result             VARCHAR2(2000);
    v_result_num             NUMBER;
    v_result                 VARCHAR2(2000);
    v_audsid1                NUMBER;
    v_audsid2                NUMBER;
    v_username               VARCHAR2(128);
    v_isinvusr_adm           CHAR(1);
    v_istrgusr_adm           CHAR(1);
    v_cfm_req                CHAR(1);
    v_cfm_req_date           DATE;
    v_cfm_gvn                CHAR(1);
    v_cfm_gvn_date           DATE;
    v_cfm_gvn_by_usr         VARCHAR2(128);
    v_trm_req_denied_by      VARCHAR2(128);
    v_trm_req_denied_rsn     VARCHAR2(2000);
    v_trm_req_denied_date    DATE;
    v_cfm_result_num         NUMBER;
    v_cfm_result             VARCHAR2(2000);
--
  BEGIN
  /* This procedure is the beginning of a termination request. */
  --
    tetools.admin_session.who_called(v_this_object);
  --
  /* VALIDATE INPUT PARAMETERS */
  IF p_trgt_sid IS NULL OR p_trgt_serial IS NULL THEN
  	v_trm_result := 'Procedure was called with invalid/missing parameters.';
    RAISE failure_in_calling;
  END IF;
  --
    TETOOLS.ADMIN_SESSION.get_trm_status( v_trm_id, p_trgt_sid, p_trgt_serial, v_trm_result_num );
    IF v_trm_result_num > 0 THEN
      RAISE trm_request_exists;
    ELSIF v_trm_result_num = 0 THEN
    --
      TETOOLS.ADMIN_SESSION.get_details( v_sid, v_serial, v_trm_result_num, v_trm_result, v_audsid1, v_trg_username, v_sql_id, v_sql_child_number, v_trm_req_acc, v_trm_req_denied_by, v_trm_req_denied_rsn, v_sqltext, v_cpu_msec, v_phys_read, v_phys_write );
      IF v_trm_result_num > 1 THEN
        RAISE failure_in_calling;
      END IF;
    	TETOOLS.ADMIN_SESSION.compare_roles( v_inv_username, v_trg_username, v_isinvusr_adm, v_istrgusr_adm, v_inv_roles, v_trg_roles, v_cfm_req );
    --
      --DBMS_OUTPUT.PUT_LINE(v_this_object|| ' 5367339529 > '|| DBMS_UTILITY.format_error_stack);
    --
      --DBMS_OUTPUT.PUT_LINE(v_this_object|| ' 7349405775 > SID: '||p_trgt_sid||', SERIAL#: '||p_trgt_serial||', SPID: '||TETOOLS.ADMIN_SESSION.get_spid(p_trgt_sid, p_trgt_serial)||', AUDSID: '||v_audsid1 );
      SELECT '(SID: '||p_trgt_sid||', SERIAL#: '||p_trgt_serial||', SPID: '||TETOOLS.ADMIN_SESSION.get_spid(p_trgt_sid, p_trgt_serial)||', AUDSID: '||v_audsid1||')' INTO v_trg_usr_details FROM dual;
      --DBMS_OUTPUT.PUT_LINE(v_this_object|| ' 6101637452 > '|| v_trg_usr_details);
      --DBMS_OUTPUT.PUT_LINE(v_this_object|| ' 5235865978 > '|| DBMS_UTILITY.format_error_stack);
    --
    /* v_audsid1 is fed from TETOOLS.ADMIN_SESSION.get_details on line 588                                                  */
    /* when v_audsid1 is used directly in IF-THEN-ELSE, an error is raised that the same variable cannot be assigned twice. */
    v_audsid2 := v_audsid1;
    IF v_audsid2 = 0 OR v_trg_username = 'SYS' THEN
      v_trm_req_acc        := 'N';
      v_trm_status         := 'D';
      v_trm_req_denied_by  := 'ADMIN_SESSION PACKAGE';
      v_trm_req_denied_rsn := 'Session is a background process.';
    ELSE
      v_trm_req_acc        := 'Y';
      v_trm_req_denied_by  := NULL;
      v_trm_req_denied_rsn := NULL;
      IF v_isinvusr_adm = 'Y' OR v_cfm_req = 'N' THEN
        v_trm_status         := 'O';
      ELSE
        v_trm_status         := 'C';
        v_cfm_req_date       := sysdate;
      END IF;
    END IF;
    --
    INSERT INTO tetools.admin_sessions_log (
           LOG_DATE,
           INVOKING_USERNAME,
           INVOKING_USER_DETAILS,
           TARGET_USERNAME,
           TARGET_USER_DETAILS,
           INVOKING_USER_ROLES,
           INVOKING_USER_ISADMIN,
           TARGET_USER_ISADMIN,
           TARGET_USER_ROLES,
           CONFMTN_REQUIRED,
           CONFMTN_REQUIRED_DATE,
           SESSION_TERMNTND,
           TERMNTN_REQUEST_ACCEPTED,
           TERMNTN_REQUEST_STATUS,
           TARGET_USER_SQLSTMNT,
           TARGET_USER_SQLID,
           TARGET_USER_SQLID_CHILD#,
           TARGET_USER_SQL_CPU_TIME,
           TARGET_USER_SQL_PHYS_READ,
           TARGET_USER_SQL_PHYS_WRITE,
           TERMNTN_REQUEST_DENIED_REASON,
           TERMNTN_REQUEST_DENIED_BY,
           TERMNTN_REQUEST_DENIED_DATE)
   VALUES (sysdate,                                                                                                                                   -- LOG_DATE
           v_inv_username,                                                                                                                            -- INVOKING_USERNAME
           JSON_OBJECT('SID' VALUE GET_INVOKING_SID,'SERIAL#' VALUE GET_INVOKING_SERIAL,'SPID' VALUE get_spid(GET_INVOKING_SID, GET_INVOKING_SERIAL)), -- INVOKING_USER_DETAILS
           v_trg_username,                                                                                                                            -- TARGET_USERNAME
           JSON_OBJECT('SID' VALUE v_sid,'SERIAL#' VALUE v_serial,'SPID' VALUE get_spid(v_sid, v_serial), 'AUDSID' VALUE v_audsid1),                  -- TARGET_USER_DETAILS
           JSON_OBJECT('INVOKING_USER_ROLES' VALUE v_inv_roles),                                                                                      -- INVOKING_USER_ROLES
           v_isinvusr_adm,                                                                                                                            -- INVOKING_USER_ISADMIN
           v_istrgusr_adm,                                                                                                                            -- TARGET_USER_ISADMIN
           JSON_OBJECT('TARGET_USER_ROLES' VALUE v_trg_roles),                                                                                        -- TARGET_USER_ROLES
           v_cfm_req,                                                                                                                                 -- CONFMTN_REQUIRED
           NVL(v_cfm_req_date, NULL),                                                                                                                 -- CONFMTN_REQUIRED_DATE
           v_trm_trmnd,                                                                                                                               -- SESSION_TERMNTND
           v_trm_req_acc,                                                                                                                             -- TERMNTN_REQUEST_ACCEPTED
           v_trm_status,                                                                                                                              -- TERMNTN_REQUEST_STATUS
           v_sqltext,                                                                                                                                 -- TARGET_USER_SQLSTMNT
           v_sql_id,                                                                                                                                  -- TARGET_USER_SQLID
           v_sql_child_number,                                                                                                                        -- TARGET_USER_SQLID_CHILD#
           v_cpu_msec,                                                                                                                                -- TARGET_USER_SQL_CPU_TIME
           v_phys_read,                                                                                                                               -- TARGET_USER_SQL_PHYS_READ
           v_phys_write,                                                                                                                              -- TARGET_USER_SQL_PHYS_WRITE
           v_trm_req_denied_rsn,                                                                                                                      -- TERMNTN_REQUEST_DENIED_REASON
           v_trm_req_denied_by,                                                                                                                       -- TERMNTN_REQUEST_DENIED_BY
           v_trm_req_denied_date)                                                                                                                     -- TERMNTN_REQUEST_DENIED_DATE
    RETURNING id INTO v_trm_id;
    COMMIT;
    --
    --DBMS_OUTPUT.PUT_LINE(v_this_object|| ' 7260605947 > '|| DBMS_UTILITY.format_error_stack);
    --
    /* Because validation in this procedure has a large part in the overall process, it is imperitive with this line of logic */
    /* the status of the individual requests is not set in any other procedure prior to insert, it will fail. */
    /* The only other location is in the procedure "EJECT_SESSION" where the status is set to 'X' prior to termination. */
  	IF v_trm_status = 'O' THEN
  	--
  	  DBMS_OUTPUT.PUT_LINE('### '|| v_this_object|| ': TERMINATION REQUEST IS ACCEPTED, STATUS = '|| v_trm_status);
  	--
  	  IF v_isinvusr_adm = 'Y' OR v_cfm_req = 'N' THEN
  	  --
  	  --DBMS_OUTPUT.PUT_LINE(v_this_object|| '  1253475064 > '|| DBMS_UTILITY.format_error_stack);
  	    --
  	    eject_session(v_sid, v_serial, v_trm_id, v_trm_result_num, v_trm_result);
  	    --
  	    --DBMS_OUTPUT.PUT_LINE(v_this_object|| ' 4489290163 > '|| DBMS_UTILITY.format_error_stack);
  	    --
  	    IF v_trm_result_num = 0 THEN
  	      set_trm_status(v_trm_id, 'K', v_cfm_req, v_result_num, v_result);  -- KILLED
  	      DBMS_OUTPUT.PUT_LINE('-- '|| v_this_object|| ': TERMINATION WAS SUCCESFUL.');
  	    ELSIF v_trm_result_num = 1 THEN
  	      set_trm_status(v_trm_id, 'M', v_cfm_req, v_result_num, v_result);  -- MARKED-FOR-KILL
  	      DBMS_OUTPUT.PUT_LINE('-- '|| v_this_object|| ': TERMINATION WAS PROCESSED, STATUS = '|| v_result);
  	    ELSIF v_trm_result_num = 2 THEN
  	      set_trm_status(v_trm_id, 'E', v_cfm_req, v_result_num, v_result);  -- ERROR
  	      DBMS_OUTPUT.PUT_LINE('-- '|| v_this_object|| ': TERMINATION WAS UNSUCCESFUL, STATUS = '|| v_result);
  	      RAISE not_correct_session;
  	    ELSIF  v_trm_result_num = 3 THEN
  	      set_trm_status(v_trm_id, 'E', v_cfm_req, v_result_num, v_result);  -- ERROR
  	      DBMS_OUTPUT.PUT_LINE('-- '|| v_this_object|| ': TERMINATION WAS UNSUCCESFUL, STATUS = '|| v_result);
  	      RAISE failure_in_calling;
  	    END IF;
  	  ELSIF (v_isinvusr_adm = 'N' AND v_cfm_req = 'Y') THEN
  	    set_trm_status(v_trm_id, 'C', v_cfm_req, v_result_num, v_result);  -- NEED-CONFIRMATION
  	      DBMS_OUTPUT.PUT_LINE('-- '|| v_this_object|| ': TERMINATION REQUEST NEEDS CONFIMRATION, STATUS = '|| v_result);
  	    RAISE need_to_be_admin;
      END IF;
    ELSIF v_trm_status = 'D' THEN
      RAISE req_denied;
    ELSIF v_trm_status = 'C' THEN
      RAISE need_to_be_admin;
  	END IF;             -- IF v_trm_status = 'O'
  ELSE
    RAISE failure_in_calling;
  END IF;     -- IF wanna_cfm_trm = 'Y'
  --
  EXCEPTION
    WHEN trm_request_exists THEN
      v_trm_result := NVL(v_trm_req_denied_rsn, v_trm_result);
  	  DBMS_OUTPUT.PUT_LINE('TERMINATION REQUEST FOR USER: '|| v_trg_username ||' WITH DETAILS: '|| v_trg_usr_details || ' ALREADY EXISTS.');
      DBMS_OUTPUT.PUT_LINE('** REQUEST DENIED: PLEASE CONFIRM '||v_trm_result_num||' VIA TETOOLS.ADMIN_SESSION.terminate_confirm('||v_trm_result_num||', '||'''Y'')');
    WHEN req_denied THEN  -- start handling exception
      v_trm_result := NVL(v_trm_req_denied_rsn, v_trm_result);
  	  DBMS_OUTPUT.PUT_LINE('TERMINATION REQUEST FOR USER: '|| v_trg_username ||' WITH DETAILS: '|| v_trg_usr_details || ' HAS BEEN DENIED.');
      DBMS_OUTPUT.PUT_LINE('** REQUEST DENIED: TERMINATION REQUEST '||v_trm_id||' TARGETS A SYS SESSION OR BACKGROUND PROCESS.');
      set_trm_status(v_trm_id, 'D', v_cfm_req, v_result_num, v_result);  -- ERROR
      UPDATE tetools.admin_sessions_log SET termntn_request_denied_reason = v_trm_result, termntn_request_denied_by = 'SYSTEM', termntn_request_denied_date = sysdate WHERE ID = v_trm_id;
  	  COMMIT;
    WHEN need_to_be_admin THEN
      v_trm_result := NVL(v_trm_req_denied_rsn, v_trm_result);
  	  DBMS_OUTPUT.PUT_LINE('TERMINATION REQUEST FOR USER: '|| v_trg_username ||' WITH DETAILS: '|| v_trg_usr_details || ' NEEDS ADDITIONAL ACTIVITIES.');
      DBMS_OUTPUT.PUT_LINE('** INVOKING USER OF TERMINATION REQUEST NEEDS TO BE AN ADMIN USER FOR THIS REQUEST/SESSION. TERMINATION REQUEST AWAITS CONFIRMATION. TRM ID: '||v_trm_id);
      set_trm_status(v_trm_id, 'C', v_cfm_req, v_result_num, v_result);  -- ERROR
      UPDATE tetools.admin_sessions_log SET confmtn_required_date = sysdate WHERE ID = v_trm_id;
  	  COMMIT;
    WHEN failure_in_calling THEN
      v_trm_result := NVL(v_trm_req_denied_rsn, v_trm_result);
  	  DBMS_OUTPUT.PUT_LINE('TERMINATION REQUEST FOR USER: '|| v_trg_username ||' WITH DETAILS: '|| v_trg_usr_details || ' HAS FAILED.');
      DBMS_OUTPUT.PUT_LINE('** TERMINATION HAS BEEN EXECUTED WITH THE FOLLOWING RESULT:'||chr(13)||chr(10)||v_trm_result);
      set_trm_status(v_trm_id, 'E', v_cfm_req, v_result_num, v_result);  -- ERROR
      UPDATE tetools.admin_sessions_log SET termntn_request_denied_reason = v_trm_result, termntn_request_denied_by = 'SYSTEM', termntn_request_denied_date = sysdate WHERE ID = v_trm_id;
  	  COMMIT;
    WHEN confirmation_failure THEN
      v_trm_result := NVL(v_trm_req_denied_rsn, v_trm_result);
      DBMS_OUTPUT.PUT_LINE('TERMINATION CONFIRMATION FOR USER: '|| v_trg_username ||' WITH DETAILS: '|| v_trg_usr_details || ' HAS FAILED.');
      DBMS_OUTPUT.PUT_LINE('** THE TERMINATION OF CONFIRMATION ID: '||v_trm_id||' HAS FAILED DUE TO:');
      DBMS_OUTPUT.PUT_LINE(v_trm_result);
      set_trm_status(v_trm_id, 'E', v_cfm_req, v_result_num, v_result);  -- ERROR
      UPDATE tetools.admin_sessions_log SET termntn_request_denied_reason = v_trm_result, termntn_request_denied_by = 'SYSTEM', termntn_request_denied_date = sysdate WHERE ID = v_trm_id;
  	  COMMIT;
    WHEN not_correct_session THEN
      v_trm_result := NVL(v_trm_req_denied_rsn, v_trm_result);
      DBMS_OUTPUT.PUT_LINE('TERMINATION CONFIRMATION FOR USER: '|| v_trg_username ||' WITH DETAILS: '|| v_trg_usr_details || ' HAS FAILED.');
      DBMS_OUTPUT.PUT_LINE('** SESSION OF CONFIRMATION ID: '||v_trm_id||' IS NOT A USER SESSION:');
      DBMS_OUTPUT.PUT_LINE(v_trm_result);
      set_trm_status(v_trm_id, 'E', v_cfm_req, v_result_num, v_result);  -- ERROR
      UPDATE tetools.admin_sessions_log SET termntn_request_denied_reason = v_trm_result, termntn_request_denied_by = 'SYSTEM', termntn_request_denied_date = sysdate WHERE ID = v_trm_id;
  	  COMMIT;
    WHEN OTHERS THEN
      v_trm_result := NVL(v_trm_req_denied_rsn, v_trm_result);
      DBMS_OUTPUT.PUT_LINE('EXCEPTION CATCHALL EXECUTED.');
      DBMS_OUTPUT.PUT_LINE('** THE TERMINATION OF CONFIRMATION ID: '||v_trm_id||' HAS FAILED DUE TO:');
      DBMS_OUTPUT.PUT_LINE(v_this_object|| ' 7985340260 > '|| DBMS_UTILITY.format_error_stack);
      DBMS_OUTPUT.PUT_LINE(v_trm_result);
      set_trm_status(v_trm_id, 'E', v_cfm_req, v_result_num, v_result);  -- ERROR;
      UPDATE tetools.admin_sessions_log SET termntn_request_denied_reason = v_trm_result, termntn_request_denied_by = 'SYSTEM', termntn_request_denied_date = sysdate WHERE ID = v_trm_id;
  	  COMMIT;
  END terminate_session;
END admin_session;
/