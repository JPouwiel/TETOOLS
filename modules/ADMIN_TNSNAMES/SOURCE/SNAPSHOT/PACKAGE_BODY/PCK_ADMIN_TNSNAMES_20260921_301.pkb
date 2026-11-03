CREATE OR REPLACE PACKAGE BODY admin_tnsnames
AS
  --  20260921_301
  --  !!!!! SELECT DB_LINK, DBMS_TNS.RESOLVE_TNSNAME(HOST) FROM DBA_DB_LINKS; !!!!
  --
  --C- /* ================================================================================================================================================================= */
  --C- CONSTANTS
  --C- /* ================================================================================================================================================================= */
  --C-
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
  no_parent_attr_name      EXCEPTION;  PRAGMA EXCEPTION_INIT (no_parent_attr_name,    , -20040); --'A PARSE ERROR HAS OCCURED TRYING TO VALIDATE THE GIVEN ATTRIBUTE NAME. THIS ATTRIBUTE HAS BEEN MISSPELLED OR NOT IN SUPPORT.'
  crud_retrieve            EXCEPTION;  PRAGMA EXCEPTION_INIT (crud_retrieve           , -20041);
  crud_unknown             EXCEPTION;  PRAGMA EXCEPTION_INIT (crud_unknown            , -20042);
  idx_internal_check       EXCEPTION;  PRAGMA EXCEPTION_INIT (idx_internal_check      , -20043);
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
  --T- /* ================================================================================================================================================================= */
  --T- TODO / OUTSTANDING ACTIONS
  --T- /* ================================================================================================================================================================= */
  --T-
  --T-  * DONE!!   -report_error procedure for erroneous CUD actions-
  --T-  * add_attributes for inserting additional attributes in reference and attributes tables 
  --T-  * revert_tns procedure for rolling backup succesful updates
  --T-  * delete_registration procedure
  --T-  * generate tnsnames.ora file (per date, in conjunction with admin_tnsnames_svn)
  --
  -- /* ================================================================================================================================================================= */
  --  TYPES
  -- /* ================================================================================================================================================================= */
  --
  -- /* TYPE > rec_execution_validation --------------------------------------------------------------------------------------- RECORD ----- HEADER */
  --
  TYPE rec_execution_validation
  IS
  RECORD ( function_name     VARCHAR2(128),
           function_value    VARCHAR2(128),
           function_feedback VARCHAR2(12),
           function_severity INTEGER(3),
           function_executed CHAR(1)
         );
  --
  -- /* TYPE > var_excval ----------------------------------------------------------------------------------------------------- VARRAY ----- HEADER */
  --
  TYPE var_excval
  IS
  VARRAY(20) OF rec_execution_validation;
  --
  -- /* ================================================================================================================================================================= */
  --  FUNCTIONS
  -- /* ================================================================================================================================================================= */
  --
  -- /* FUNCTION > num_period_dname --------------------------------------------------------------------------------------------- BOOL ----- HEADER */
  --
  FUNCTION num_period_dname RETURN NUMBER AS
   v_return                  NUMBER;
  BEGIN
    SELECT MIN(REGEXP_COUNT(pref_value, '[.]'))+1 INTO v_return
      FROM admin_tnsnames_prefs
     WHERE pref_name LIKE '%DOMAIN';
    --
    RETURN v_return;
  END num_period_dname;
  --
  -- /* FUNCTION > get_pref ----------------------------------------------------------------------------------------------- PREF_VALUE ----- HEADER */
  --
  FUNCTION get_pref(
    p_pref_name in admin_sessions_prefs.pref_name%type)
    RETURN VARCHAR2
  IS
    l_scope                  VARCHAR2(30)                             := 'get_pref';
    l_pref_value             admin_sessions_prefs.pref_value%type;
    l_pref_name              admin_sessions_prefs.pref_name%type      := UPPER(p_pref_name);
  BEGIN
    SELECT pref_value INTO l_pref_value
      FROM ( SELECT pref_value 
               FROM tetools.admin_sessions_prefs
              WHERE pref_name = l_pref_name);
      RETURN l_pref_value;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RAISE;
  END get_pref;
  --
  -- /* FUNCTION > removehttp ------------------------------------------------------------------------------------------ SANITIZE HTTP ----- HEADER */
  --
  FUNCTION removehttp(p_hostname IN VARCHAR2) RETURN VARCHAR2 AS
    v_hostname                 VARCHAR2(128);
  BEGIN
  	SELECT NVL(REGEXP_SUBSTR(REGEXP_REPLACE(p_hostname, '^http[s]?://(www[1]?\.)?|^www[1]?\.', '', 1), '(.+?)(/|$)'), 'X') INTO v_hostname FROM DUAL;
  	RETURN v_hostname;
  END removehttp;
  --
  -- /* FUNCTION > shortnamer ----------------------------------------------------------------------------------------- SHORTNAME HOST ----- HEADER */
  --
  FUNCTION shortnamer(p_hostname IN VARCHAR2) RETURN VARCHAR2 AS
    v_hostname                 VARCHAR2(128);
  BEGIN
  	SELECT NVL(REGEXP_SUBSTR(UPPER(REGEXP_SUBSTR(removehttp(p_hostname),'^([a-zA-Z]{2})([a-zA-Z0-9.-]*|[a-zA-Z0-9-]*|[a-zA-Z0-9]*|[a-zA-Z0-9]*)$')), '[^."]+', 1, 1), 'X')  INTO v_hostname FROM DUAL;
  	RETURN v_hostname;
  END shortnamer;
  --
  -- /* ================================================================================================================================================================= */
  --  PROCEDURES
  -- /* ================================================================================================================================================================= */
  --
  --
  -- /* PROCEDURE > help ---------------------------------------------------------------------------------------------- USAGE EXAMPLES ----- HEADER */
  --
  PROCEDURE help( p_verbose IN VARCHAR2 DEFAULT 'N')
  AS
    v_this_object            VARCHAR2(128);
    v_rowtext                VARCHAR2(32767);
    v_filter_y               VARCHAR2(40)                             := '^[[:space:]]{2}[\-]{2}[H][SV][\-]';
    v_filter_n               VARCHAR2(40)                             := '^[[:space:]]{2}[\-]{2}[H][S][\-]';
    v_verbose                VARCHAR2(40)                             := v_filter_n;
    --
  	CURSOR c_help(p_verbose IN VARCHAR2) IS
  	  SELECT line, text
  	    FROM dba_source
  	   WHERE name='ADMIN_TNSNAMES'
  	     AND type ='PACKAGE'
  	     AND owner='TETOOLS'
  	     AND REGEXP_LIKE(text, p_verbose)
  	     ORDER BY 1 ASC;
  BEGIN
  	--
    tetools.admin_tnsnames.who_called(v_this_object);
    --
    -- /* This procedure extracts the lines of the source of the package specification starting with                    COMMENT */
    -- /* the leading string for the HELP excerpt.                                                                      COMMENT */
    -- /* Based on the parameter whether the HELP section needs to be verbose or not, the specific                      COMMENT */
    -- /* string will be used for filtering.                                                                            COMMENT */
    IF p_verbose = 'Y' THEN v_verbose := v_filter_y; END IF;
    FOR r_row IN c_help(v_verbose)
      LOOP
        v_rowtext := REPLACE(r_row.text,CHR(10),NULL);
        DBMS_OUTPUT.PUT_LINE(REPLACE(v_rowtext,',',', '));
      END LOOP;
  END help;
  --
  -- /* PROCEDURE > banner --------------------------------------------------------------------------------- PACKAGE DETAILS / HISTORY ----- HEADER */
  --
  PROCEDURE banner
  AS
    v_this_object            VARCHAR2(128);
    v_rowtext                VARCHAR2(32767);
  	CURSOR c_banner IS
  	  SELECT line, text
  	    FROM dba_source
  	   WHERE name='ADMIN_TNSNAMES'
  	     AND type ='PACKAGE'
  	     AND owner='TETOOLS'
  	     AND REGEXP_LIKE(text, '^[[:space:]]{2}[\-]{2}[B][\-]')
  	     ORDER BY 1 ASC;
  BEGIN
  	--
    tetools.admin_tnsnames.who_called(v_this_object);
    --
    -- /* This procedure extracts the lines of the source of the package specification 
    -- /* starting with the leading string for the BANNER excerpt. */
  	FOR r_row IN c_banner
      LOOP
        v_rowtext:=REPLACE(r_row.text,CHR(10),NULL);
        DBMS_OUTPUT.PUT_LINE(REPLACE(v_rowtext,',',', '));
      END LOOP;
  END banner;
  --
  -- /* PROCEDURE > generate_template ------------------------------------------------------------------------ ENTRY TEMPLATE CREATION ----- HEADER */
  --
  PROCEDURE generate_template ( p_type IN VARCHAR2, p_num_hosts IN INTEGER default 1 )
  AS
  --
    v_role_invusr            VARCHAR2(2000);
    v_isinvusr_adm           CHAR(1);
    v_isinvusr_con           CHAR(1);
    v_cont                   CHAR(1)                            := 'Y';
    v_status                 VARCHAR2(11);
    --mismatch_type_numhosts   EXCEPTION;
    --invalid_numhosts         EXCEPTION;
    --generic_error            EXCEPTION;
    --no_contributor           EXCEPTION;
    --PRAGMA EXCEPTION_INIT    (no_contributor          , -20016);
    --PRAGMA EXCEPTION_INIT    (mismatch_type_numhosts  , -20021);
    --PRAGMA EXCEPTION_INIT    (invalid_numhosts        , -20022);
    --PRAGMA EXCEPTION_INIT    (generic_error           , -20010);
	--
    PROCEDURE ECHO( STRING IN VARCHAR2, PAD IN VARCHAR2)
    AS
    BEGIN
      DBMS_OUTPUT.PUT_LINE( '  !' || RPAD( STRING, 170, PAD) || '!!');
    END ECHO;
  BEGIN
  	--
  	IF p_type != 'SIMPLE' AND p_type != 'ADVANCED'                                                                                                 THEN
      RAISE generic_error;
    END IF;
    --
  	IF p_num_hosts > 3 OR p_num_hosts < 1                                                                                                         THEN
  	  RAISE invalid_numhosts;
  	END IF;
  	--
  	IF p_type = 'SIMPLE' AND p_num_hosts > 1                                                                                                      THEN
  	  RAISE mismatch_type_numhosts;
  	END IF;
  	--
    tetools.admin_tnsnames.compare_roles(v_role_invusr, v_isinvusr_adm, v_isinvusr_con);
    --
    tetools.admin_tnsnames.tnsnames_status(v_status,v_role_invusr,v_cont);
    --
    IF v_isinvusr_con = 'N' AND v_isinvusr_adm = 'N'                                                                                              THEN
      RAISE no_contributor;
    END IF;
  	--
    DBMS_OUTPUT.PUT_LINE(chr(13)||chr(10));
    --
    ECHO( '!', '!');
    ECHO( '!', ' ');
    ECHO( '!          .#@@@%**%@+', ' ');
    ECHO( '!       :%@@=.  =.   .=    TET - TNSNAMES ADMINISTRATION PACKAGE 0.301', ' ');
    ECHO( '!     :@@%: .=#%@@@=  .', ' ');
    ECHO( '!    #@@= =@@@@%@@%=.', ' ');
    ECHO( '!  .@@@::@@@=  =:          CURRENT DATE / TIME :  ' || to_char( sysdate, 'dd-MON-yy hh:mi:ss AM') || '', ' ');
    ECHO( '!  *@@%.@@# :.:::.:= -', ' ');
    ECHO( '!  @@@#=@@: +:-*#**:#:', ' ');
    ECHO( '!  *@@@=%@', ' ');
    ECHO( '!   =@@@@@@@@#:', ' ');
    ECHO( '!', ' ');
    ECHO( '!', '-');
    ECHO( '!- GENERATE REGISTRATION TEMPLATE RESULT -', '-');
    ECHO( '!', ' ');
    ECHO( '!   INVOKING USER                  : ' || USER(), ' ');
    ECHO( '!   INVOKING USER ACCESS           :'  || v_role_invusr, ' ');
    ECHO( '!', ' ');
    ECHO( '!- REQUESTED TEMPLATE STYLE - '||p_type||' -', '-');
    IF p_type = 'SIMPLE'                                                                                                                          THEN
      ECHO( '!   Below is an example of a _SIMPLE_ TNS Entry.', ' ');
    ELSIF p_type = 'ADVANCED'                                                                                                                     THEN
      ECHO( '!   Below is an example of an _ADVANCED_ TNS Entry.', ' ');
    END IF;
      ECHO( '!   The data you will provide will/should result in a similar entry.', ' ');
      ECHO( '!', ' ');
      ECHO( '!', ' ');
      ECHO( '!   # <Description which automatically will contain the date of addition and your username, add any information you deem necessary>.', ' ');
      ECHO( '!   <your ALIAS name, e.g.: "pbobdb"> =', ' ');
      ECHO( '!     (DESCRIPTION_LIST =', ' ');
      ECHO( '!       (DESCRIPTION =', ' ');
    IF p_type = 'ADVANCED'                                                                                                                        THEN
      ECHO( '!       (TRANSPORT_CONNECT_TIMEOUT = <This parameter MUST be supplied by the DBA!>)', ' ');
      ECHO( '!       (CONNECT_TIMEOUT =           <This parameter MUST be supplied by the DBA!>)', ' ');
      ECHO( '!       (RETRY_DELAY =               <This parameter MUST be supplied by the DBA!>)', ' ');
      ECHO( '!       (RETRY_COUNT =               <This parameter MUST be supplied by the DBA!>)', ' ');
      ECHO( '!       (FAILOVER =                  <This parameter MUST be supplied by the DBA!>)', ' ');
      ECHO( '!       (LOAD_BALANCE =              <This parameter MUST be supplied by the DBA!>)', ' ');
    END IF;
      ECHO( '!         (ADDRESS_LIST =', ' ');
    FOR i IN 1 .. p_num_hosts LOOP
      ECHO( '!           (ADDRESS = ', ' ');
      ECHO( '!             (PROTOCOL = <usually TCP>)', ' ');
      ECHO( '!             (HOST = <Either a simple or fqdn, or IP address, e.g.: "192.0.2.10'||TO_CHAR(i)||'" or "host-demo'||TO_CHAR(i+6)||'.example.invalid">)', ' ');
      ECHO( '!             (PORT = <usually default (1521) or 1526>)', ' ');
      ECHO( '!           )', ' ');
    END LOOP;
      ECHO( '!         )', ' ');
      ECHO( '!         (CONNECT_DATA =', ' ');
      ECHO( '!           (SERVER = <usually DEDICATED or SHARED>', ' ');
      ECHO( '!           (SERVICE_NAME = <the service name pointing to the instance, e.g.: "pbobi_1">)', ' ');
      ECHO( '!         )', ' ');
      ECHO( '!       )', ' ');
      ECHO( '!     )', ' ');
      ECHO( '!', ' ');
      ECHO( '!', ' ');
      ECHO( '!- REQUESTED TEMPLATE STYLE - Type: '||p_type||' -- Number of hosts: '||p_num_hosts||' -', '-');
      ECHO( '!', ' ');
      ECHO( '!', ' ');
      ECHO( '!  DECLARE', ' ');
      ECHO( '!    l_clob      CLOB;', ' ');
      ECHO( '!  BEGIN', ' ');
      ECHO( '!  	SELECT tns_attr||'' = ''||tns_attr_value INTO l_clob', ' ');
      ECHO( '!  	  FROM ( SELECT ''ENTRY_DESCRIPTION''                tns_attr, ''# <your_escription>''                                        tns_attr_value FROM DUAL UNION', ' ');
      ECHO( '!             SELECT ''NET_SERVICE_NAME''                 tns_attr, ''<your ALIAS name, e.g.: "pbobdb"> =''                        tns_attr_value FROM DUAL UNION', ' ');
      ECHO( '!             SELECT ''DESCIPTION_LIST''                  tns_attr, ''  (DESCRIPTION_LIST =''                                      tns_attr_value FROM DUAL UNION', ' ');
      ECHO( '!             SELECT ''DESCIPTION''                       tns_attr, ''    (DESCRIPTION =''                                         tns_attr_value FROM DUAL UNION', ' ');
      ECHO( '!             SELECT ''TRANSPORT_CONNECT_TIMEOUT''        tns_attr, ''    (TRANSPORT_CONNECT_TIMEOUT = <INTEGER> [ms, sec, min])'' tns_attr_value FROM DUAL UNION', ' ');
      ECHO( '!             SELECT ''CONNECT_TIMEOUT''                  tns_attr, ''    (CONNECT_TIMEOUT = <INTEGER> [ms, sec, min])''           tns_attr_value FROM DUAL UNION', ' ');
      ECHO( '!             SELECT ''RETRY_DELAY''                      tns_attr, ''    (RETRY_DELAY = <INTEGER> [ms, sec, min])''               tns_attr_value FROM DUAL UNION', ' ');
      ECHO( '!             SELECT ''RETRY_COUNT''                      tns_attr, ''    (RETRY_COUNT = <INTEGER>)''                              tns_attr_value FROM DUAL UNION', ' ');
      ECHO( '!             SELECT ''FAILOVER''                         tns_attr, ''    (FAILOVER = <ON/OFF>)''                                  tns_attr_value FROM DUAL UNION', ' ');
      ECHO( '!             SELECT ''LOAD_BALANCE''                     tns_attr, ''    (LOAD_BALANCE = <ON/OFF>)''                              tns_attr_value FROM DUAL UNION', ' ');
      ECHO( '!             SELECT ''ADDRESS_LIST''                     tns_attr, ''      (ADDRESS_LIST =''                                      tns_attr_value FROM DUAL UNION', ' ');
    FOR i IN 1 .. p_num_hosts LOOP
      ECHO( '!             SELECT ''ADDRESS''                          tns_attr, ''        (ADDRESS =''                                         tns_attr_value FROM DUAL UNION', ' ');
      ECHO( '!             SELECT ''PROTOCOL''                         tns_attr, ''          (PROTOCOL = <required_protocol>''                  tns_attr_value FROM DUAL UNION', ' ');
      ECHO( '!             SELECT ''HOST''                             tns_attr, ''          (HOST = <your_host>''                              tns_attr_value FROM DUAL UNION', ' ');
      ECHO( '!             SELECT ''PORT''                             tns_attr, ''          (PORT = <required_port>''                          tns_attr_value FROM DUAL UNION', ' ');
      ECHO( '!             SELECT ''ADDRESS_LIST_CLOSING_BRACKET''     tns_attr, ''        )''                                                  tns_attr_value FROM DUAL UNION', ' ');
    END LOOP;
      ECHO( '!             SELECT ''ADDRESS_CLOSING_BRACKET''          tns_attr, ''      )''                                                    tns_attr_value FROM DUAL UNION', ' ');
      ECHO( '!             SELECT ''CONNECT_DATA''                     tns_attr, ''      (CONNECT_DATA =''                                      tns_attr_value FROM DUAL UNION', ' ');
      ECHO( '!             SELECT ''SERVICE_NAME''                     tns_attr, ''        (SERVICE_NAME = <your_service_name>''                tns_attr_value FROM DUAL UNION', ' ');
      ECHO( '!             SELECT ''SERVER''                           tns_attr, ''        (SERVER = <shared_or_dedicated>''                    tns_attr_value FROM DUAL UNION', ' ');
      ECHO( '!             SELECT ''CONNECT_DATA_CLOSING_BRACKET''     tns_attr, ''      )''                                                    tns_attr_value FROM DUAL UNION', ' ');
      ECHO( '!             SELECT ''(DESCRIPTION_CLOSING_BRACKET''     tns_attr, ''    )''                                                      tns_attr_value FROM DUAL UNION', ' ');
      ECHO( '!             SELECT ''DESCRIPTION_LIST_CLOSING_BRACKET'' tns_attr, ''  )''                                                        tns_attr_value FROM DUAL UNION', ' ');
      ECHO( '!             SELECT ''DATE_VALID_FROM''                  tns_attr, sysdate                                                        tns_attr_value FROM DUAL UNION', ' ');
      ECHO( '!             SELECT ''DATE_VALID_END''                   tns_attr, ''9999-12-31''                                                 tns_attr_value FROM DUAL UNION', ' ');
      ECHO( '!             SELECT ''PHASE''                            tns_attr, ''<DEV_or_TST_or_ACC_or_PRD>''                                 tns_attr_value FROM DUAL UNION', ' ');
      ECHO( '!             SELECT ''TARGET_ENV''                       tns_attr, ''<DTA_or_DEV_or_TST_or_ACC_or_PRD>''                          tns_attr_value FROM DUAL) qry;', ' ');
      ECHO( '!    --', ' ');
      ECHO( '!    tetools.admin_tnsnames.register_tns(l_clob);', ' ');
      ECHO( '!  END;', ' ');
      ECHO( '!  /', ' ');
      ECHO( '!', ' ');
      ECHO( '!', '!');
    --
    EXCEPTION
    WHEN no_contributor           THEN
      v_role_invusr := ' NO CONTRIBUTOR';
      v_cont        := 'N';
      tetools.admin_tnsnames.report_status(v_status, v_role_invusr, v_cont, NULL);
      RAISE;
    WHEN mismatch_type_numhosts THEN
      notify('8296852254', 'Generate Template: mismatch template type and num hosts: '||p_type||' vs '||p_num_hosts, DBMS_UTILITY.format_error_stack);
    WHEN invalid_numhosts       THEN
      notify('0483992689', 'Generate Template: invalid number of hosts: '||p_num_hosts, DBMS_UTILITY.format_error_stack);
    WHEN generic_error          THEN
      notify('1950213000', 'Generate Template: generic error, please review parameters> Type:'||p_type||', Number of hosts: '||p_num_hosts, DBMS_UTILITY.format_error_stack);
    WHEN OTHERS                 THEN
      notify('9186677024', 'Generate Template: This shouldnt happen> Type:'||p_type||', Number of hosts: '||p_num_hosts||', User roles: '||v_role_invusr, DBMS_UTILITY.format_error_stack);
  END generate_template;
  --
  -- /* PROCEDURE > tnsnames_status ------------------------------------------------------------------------------------- QUERY STATUS ----- HEADER */
  --
  PROCEDURE tnsnames_status ( p_status OUT VARCHAR2, p_role OUT VARCHAR2, p_cont OUT VARCHAR2 )
  AS
    v_this_object            VARCHAR2(128);
    v_maintenance_mode       VARCHAR2(8);
    v_tnsnames_status        VARCHAR2(8)                        := 'ENABLED';
    v_role_invusr            VARCHAR2(2000);
    v_isinvusr_adm           CHAR(1);
    v_isinvusr_con           CHAR(1);
    v_cont                   CHAR(1)                            := 'Y';
    --no_contributor           EXCEPTION;
    --maintenance_mode_enabled EXCEPTION;
    --generic_error            EXCEPTION;
    --PRAGMA EXCEPTION_INIT    (no_contributor          , -20016);
    --PRAGMA EXCEPTION_INIT    (maintenance_mode_enabled, -20017);
    --PRAGMA EXCEPTION_INIT    (generic_error           , -20010);
  BEGIN
  	--
    tetools.admin_tnsnames.who_called(v_this_object);
    --
    SELECT pref_value INTO v_maintenance_mode FROM admin_tnsnames_prefs WHERE pref_name = 'MAINTENANCE_MODE';
    IF v_maintenance_mode ='DISABLED'                                                                                                             THEN
      v_tnsnames_status := 'ENABLED'; p_status := v_tnsnames_status;
    ELSIF v_maintenance_mode ='ENABLED'                                                                                                           THEN
      v_tnsnames_status := 'DISABLED'; p_status := v_tnsnames_status;
    ELSE
      RAISE generic_error;
    END IF;
    --
    tetools.admin_tnsnames.compare_roles(v_role_invusr, v_isinvusr_adm, v_isinvusr_con);
    p_role            := v_role_invusr;
    --
    IF v_isinvusr_adm = 'N'                                                                                                                       THEN
     IF v_isinvusr_con = 'N'                                                                                                                      THEN
       RAISE no_contributor;
     ELSE
       IF v_maintenance_mode = 'ENABLED'                                                                                                          THEN
         v_cont := 'N';
         RAISE maintenance_mode_enabled;
       END IF;
     END IF;
    ELSE
      IF v_maintenance_mode = 'ENABLED'                                                                                                          THEN
        RAISE maintenance_mode_enabled;
      END IF;
    END IF;
    --
    p_cont            := v_cont;
    --
    EXCEPTION
    WHEN no_contributor           THEN
      v_role_invusr := ' NO CONTRIBUTOR';
      v_cont        := 'N';
      tetools.admin_tnsnames.report_status(v_tnsnames_status, v_role_invusr, v_cont, NULL);
      RAISE;
    WHEN maintenance_mode_enabled THEN
      tetools.admin_tnsnames.report_status(v_tnsnames_status, v_role_invusr, v_cont, NULL);
      IF v_cont = 'N'             THEN
        RAISE;
      END IF;
    WHEN generic_error            THEN
      notify('0089443894', v_this_object, DBMS_UTILITY.format_error_stack);
    WHEN OTHERS                   THEN
      notify('9889359543', v_this_object, DBMS_UTILITY.format_error_stack);
  END tnsnames_status;
  --
  -- /* PROCEDURE > report_status ------------------------------------------------------------------------------------ PRINTOUT STATUS ----- HEADER */
  --
  PROCEDURE report_status ( p_status IN VARCHAR2, p_role IN VARCHAR2, p_cont IN VARCHAR2, p_feedback IN VARCHAR2 )
  AS
  --
    --no_contributor           EXCEPTION;
    --maintenance_mode_enabled EXCEPTION;
    --generic_error            EXCEPTION;
    --PRAGMA EXCEPTION_INIT    (no_contributor          , -20016);
    --PRAGMA EXCEPTION_INIT    (maintenance_mode_enabled, -20017);
    --PRAGMA EXCEPTION_INIT    (generic_error           , -20010);
	--
    PROCEDURE ECHO( STRING IN VARCHAR2, PAD IN VARCHAR2)
    AS
    BEGIN
      DBMS_OUTPUT.PUT_LINE( '  !' || RPAD( STRING, 112, PAD) || '!!');
    END ECHO;
  BEGIN
  	--
    DBMS_OUTPUT.PUT_LINE(chr(13)||chr(10));
    --
    ECHO( '!', '!');
    ECHO( '!', ' ');
    ECHO( '!          .#@@@%**%@+', ' ');
    ECHO( '!       :%@@=.  =.   .=    TET - TNSNAMES ADMINISTRATION PACKAGE 0.301', ' ');
    ECHO( '!     :@@%: .=#%@@@=  .', ' ');
    ECHO( '!    #@@= =@@@@%@@%=.', ' ');
    ECHO( '!  .@@@::@@@=  =:          CURRENT DATE / TIME :  ' || to_char( sysdate, 'dd-MON-yy hh:mi:ss AM') || '', ' ');
    ECHO( '!  *@@%.@@# :.:::.:= -', ' ');
    ECHO( '!  @@@#=@@: +:-*#**:#:', ' ');
    ECHO( '!  *@@@=%@', ' ');
    ECHO( '!   =@@@@@@@@#:', ' ');
    ECHO( '!', ' ');
    ECHO( '!', '-');
    ECHO( '!- STATUS LOOKUP RESULT -', '-');
    ECHO( '!', ' ');
    ECHO( '!   TNSNAMES ADMINISTRATION STATUS : ' || p_status, ' ');
    ECHO( '!   INVOKING USER                  : ' || USER(), ' ');
    ECHO( '!   INVOKING USER ACCESS           :'  || p_role, ' ');
    ECHO( '!', ' ');
    IF p_status = 'DISABLED' AND p_cont = 'N'                                                                                                     THEN
      ECHO( '!   It seems you do not have the TNSNAMES ADMINISTRATION role to continue during MAINTENANCE MODE.', ' ');
      ECHO( '!   Please contact TET for further information.', ' ');
      ECHO( '!', ' ');
      ECHO( '!', '!');
      RAISE maintenance_mode_enabled;
    ELSIF p_status = 'DISABLED' AND p_cont = 'Y'                                                                                                  THEN
      ECHO( '!   It seems you do have the TNSNAMES ADMINISTRATION role to continu during MAINTENANCE MODE.', ' ');
      ECHO( '!   Please be advised that no mutations can be applied or files generated during maintenance.', ' ');
      ECHO( '!', ' ');
      ECHO( '!', '!');
    ELSIF p_status = 'ENABLED' AND p_cont = 'N' AND p_feedback IS NULL                                                                            THEN
      ECHO( '!   It seems you do not have the TNSNAMES CONTRIBUTOR role to continue.', ' ');
      ECHO( '!   Please contact TET for further information.', ' ');
      ECHO( '!', ' ');
      ECHO( '!', '!');
      RAISE no_contributor;
    ELSIF p_status = 'ENABLED' AND p_cont = 'N' AND p_feedback IS NOT NULL                                                                         THEN
      ECHO( '!   The following feedback has been given:'||p_feedback, ' ');
      ECHO( '!   Please review and submit again or contact TET for further information.', ' ');
      ECHO( '!', ' ');
      ECHO( '!', '!');      
    ELSE
      RAISE generic_error;
    END IF;
    --
    EXCEPTION
    WHEN no_contributor THEN
      notify('2620091665', 'NO CONTRIBUTOR: '||p_status, DBMS_UTILITY.format_error_stack);
    WHEN maintenance_mode_enabled THEN
      notify('2620091665', 'Maintenance Status: '||p_status, DBMS_UTILITY.format_error_stack);
    WHEN generic_error        THEN
      notify('1950213000', 'Maintenance Status: '||p_status, DBMS_UTILITY.format_error_stack);
    WHEN OTHERS               THEN
      notify('9186677024', 'Maintenance Status: '||p_status, DBMS_UTILITY.format_error_stack);
  END report_status;
  --
  -- /* PROCEDURE > report_existing ---------------------------------------------------------------------------------- PRINTOUT REPORT ----- HEADER */
  --
  PROCEDURE report_existing ( p_tns_alias IN VARCHAR2, p_does_exist IN CHAR, p_phase IN VARCHAR2, p_host_name IN VARCHAR2 DEFAULT NULL, p_service_name IN VARCHAR2 DEFAULT NULL )
  AS
  --
    PROCEDURE ECHO( STRING IN VARCHAR2, PAD IN VARCHAR2)
    AS
    BEGIN
      DBMS_OUTPUT.PUT_LINE( '  !' || RPAD( STRING, 112, PAD) || '!!');
    END ECHO;
  BEGIN
  	--
    DBMS_OUTPUT.PUT_LINE(chr(13)||chr(10));
    --
    ECHO( '!', '!');
    ECHO( '!', ' ');
    ECHO( '!          .#@@@%**%@+', ' ');
    ECHO( '!       :%@@=.  =.   .=    TET - TNSNAMES ADMINISTRATION PACKAGE 0.301', ' ');
    ECHO( '!     :@@%: .=#%@@@=  .', ' ');
    ECHO( '!    #@@= =@@@@%@@%=.', ' ');
    ECHO( '!  .@@@::@@@=  =:          TNS Query              : ' || p_tns_alias || ' (' || to_char( sysdate, 'dd-MON-yy hh:mi:ss AM') || ')', ' ');
    ECHO( '!  *@@%.@@# :.:::.:= -     USER                   : ' || USER(), ' ');
    IF p_does_exist = 'Y' THEN
      ECHO( '!  @@@#=@@: +:-*#**:#:     STATUS                 : EXISTS', ' ');
      ECHO( '!  *@@@=%@', ' ');
      ECHO( '!   =@@@@@@@@#:', ' ');
      ECHO( '!', ' ');
      ECHO( '!', '-');
      ECHO( '!- LOOKUP RESULT -', '-');
      ECHO( '!', ' ');
      ECHO( '!   PHASE                     : ' || p_phase, ' ');
      ECHO( '!   HOST NAME                 : ' || p_host_name, ' ');
      ECHO( '!   SERVICE NAME              : ' || p_service_name, ' ');
      ECHO( '!', ' ');
      ECHO( '!- HINT / FEEDBACK -', '-');
      ECHO( '!', ' ');
      ECHO( '!   Did you mean to update an existing TNS registration?', ' ');
      ECHO( '!     If so, please use: tetools.admin_tnsnames.update_alias() to accomplish this.', ' ');
      ECHO( '!', ' ');
      ECHO( '!   Did you mean to add an TNS_ALIAS or HOST_NAME to an existing registration?', ' ');
      ECHO( '!     If so, please use: tetools.admin_tnsnames.add_additional_alias() to accomplish this.', ' ');
      ECHO( '!   See tetools.admin_tnsnames.help on how to use these.', ' ');
    ELSE
      ECHO( '!  @@@#=@@: +:-*#**:#:     STATUS                 : DOES NOT EXIST', ' ');
      ECHO( '!  *@@@=%@                 PHASE                  : ' || p_phase, ' ');
      ECHO( '!   =@@@@@@@@#:', ' ');
      ECHO( '!', ' ');
    END IF;
    ECHO( '!', ' ');
    ECHO( '!', '!');
    --
  END report_existing;
  --
  -- /* PROCEDURE > report_registration ------------------------------------------------------------------------------ PRINTOUT REPORT ----- HEADER */
  --
  PROCEDURE report_registration ( json_string IN CLOB, p_tns_id IN INTEGER )
  AS  
    inter                 CLOB;
    data                  JSON_OBJECT_T;
    cud                   CHAR(1);
    tns_id                INTEGER;
    tns_alias             VARCHAR2(32);
    host_name             VARCHAR2(128);
    target_phase          CHAR(1);
    forced                CHAR(1);
    port                  INTEGER;
    date_valid_end        DATE;
    entry_description     VARCHAR2(128);
    date_valid_from       DATE;
    connect_timeout       NUMBER;
    retry_delay           NUMBER;
    retry_count           NUMBER;
    failover              VARCHAR2(5);
    load_balance          VARCHAR2(5);
    service_name          VARCHAR2(48);
    target_envs           VARCHAR2(8);
    ip_validation         CHAR(1);
    phase_validation      CHAR(1);
    fqdn_validation       CHAR(1);
    dname_validation      CHAR(1);
    shortname             VARCHAR2(48);
    domainname            VARCHAR2(48);
    feedback              VARCHAR2(128);
    numeral_validation    CHAR(1);
    numport_validation    CHAR(1);
    thousands_validation  CHAR(1);
    port_validation       CHAR(1);
    range_validation      CHAR(1);
    description           VARCHAR2(256);
    cont                  CHAR(1);
    v_extra_json          VARCHAR2(4000);
    v_var1                VARCHAR2(128)    := 'var1_val';
    v_var2                VARCHAR2(128)    := 'var2_val';
    v_var3                VARCHAR2(128)    := 'var3_val';
    v_var4                VARCHAR2(128)    := 'var4_val';
    v_var5                VARCHAR2(128)    := 'var5_val';
    v_var6                VARCHAR2(128)    := 'var6_val';
    v_var7                VARCHAR2(128)    := 'var7_val';
    v_var8                VARCHAR2(128)    := 'var8_val';
    v_var9                VARCHAR2(128)    := 'var9_val';
    --
    PROCEDURE ECHO( STRING IN VARCHAR2, PAD IN VARCHAR2)
    AS
    BEGIN
      DBMS_OUTPUT.PUT_LINE( '  !' || RPAD( STRING, 112, PAD) || '!!');
    END ECHO;
  BEGIN
    --SELECT JSON_OBJECT('v_var1' VALUE v_var1,'v_var2' VALUE v_var2,'v_var3' VALUE v_var3, 'v_var4' VALUE v_var4,'v_var5' VALUE v_var5,'v_var6' VALUE v_var6,'v_var7' VALUE v_var7,'v_var8' VALUE v_var8) INTO v_extra_json FROM dual;
  	SELECT TREAT(json_string as json) INTO INTER FROM dual;
  	data                  := new JSON_OBJECT_T(inter);
  	--
  	cud                   := data.get_string('crud');
  	tns_id                := data.get_string('tns_id');
  	tns_alias             := data.get_string('tns_alias');
    target_phase          := data.get_string('target_phase');
    target_envs           := data.get_string('target_envs');
  	host_name             := data.get_string('host_name');
    service_name          := data.get_string('service_name');
    port                  := data.get_string('port');
    date_valid_end        := data.get_string('date_valid_end');
    entry_description     := data.get_string('entry_description');
    date_valid_from       := data.get_string('date_valid_from');
    connect_timeout       := data.get_string('connect_timeout');
    retry_delay           := data.get_string('retry_delay');
    retry_count           := data.get_string('retry_count');
    failover              := data.get_string('failover');
    load_balance          := data.get_string('load_balance');
    forced                := data.get_string('forced');
    dname_validation      := data.get_string('dname_validation');
    domainname            := data.get_string('domainname');
    fqdn_validation       := data.get_string('fqdn_validation');
    ip_validation         := data.get_string('ip_validation');
    numeral_validation    := data.get_string('numeral_validation');
    numport_validation    := data.get_string('numport_validation');
    phase_validation      := data.get_string('phase_validation');
    port_validation       := data.get_string('port_validation');
    range_validation      := data.get_string('range_validation');
    shortname             := data.get_string('shortname');
    thousands_validation  := data.get_string('thousands_validation');
    feedback              := data.get_string('feedback');
    cont                  := data.get_string('continue');
    --
      DBMS_OUTPUT.PUT_LINE(chr(13)||chr(10));
    --
      IF cont != 'Y' THEN
        ECHO( '!! HEALTH WARNING : Faulty parameters given. Review your command', '!');
      ELSE
        ECHO( '!', '!');
      END IF;
      ECHO( '!', ' ');
      ECHO( '!          .#@@@%**%@+', ' ');
      ECHO( '!       :%@@=.  =.   .=    TET - TNSNAMES ADMINISTRATION PACKAGE 0.301', ' ');
      ECHO( '!     :@@%: .=#%@@@=  .', ' ');
      ECHO( '!    #@@= =@@@@%@@%=.', ' ');
      ECHO( '!  .@@@::@@@=  =:          TNS Registration       : ' || tns_alias || ' (' || to_char( sysdate, 'dd-MON-yy hh:mi:ss AM') || ')', ' ');
      ECHO( '!  *@@%.@@# :.:::.:= -     USER                   : ' || USER(), ' ');
      IF cont = 'N' THEN
        ECHO( '!  @@@#=@@: +:-*#**:#:     STATUS                 : FAILED', ' ');
      ELSE
        ECHO( '!  @@@#=@@: +:-*#**:#:', ' ');
      END IF;
      IF forced = 'Y' THEN
        ECHO( '!  *@@@=%@                 FORCED                 : YES', ' ');
      ELSE
        ECHO( '!  *@@@=%@', ' ');
      END IF;
      ECHO( '!   =@@@@@@@@#:', ' ');
      ECHO( '!', ' ');
      ECHO( '!', '-');
      IF forced = 'Y' THEN
        ECHO( '!- RESULTING ADDITION / ALTERATION - '||cud||'   ==  FORCED!!  -', '-');
      ELSE
        ECHO( '!- RESULTING ADDITION / ALTERATION - '||cud||' ', '-');
      END IF;
      ECHO( '!', ' ');
      ECHO( '!   PHASE                     : ' || target_phase, ' ');
      ECHO( '!   TARGET ENVIRONMENTS       : ' || target_envs, ' ');
      IF cud = 'C' THEN
        ECHO( '!   CREATED TNS_ID            : ' || p_tns_id, ' ');
      ELSIF cud = 'U' THEN
        ECHO( '!   UPDATED TNS_ID            : ' || p_tns_id, ' ');
      END IF;
      ECHO( '!   ----------------------------------------------------', ' ');
      IF entry_description IS NOT NULL THEN
        ECHO( '!', ' ');
        ECHO( '!   # [' || tns_alias||' - '|| to_char( sysdate, 'YYYY-MM-DD') || '] :: ' || entry_description, ' ');
      END IF;
      ECHO( '!   ' || tns_alias||' = ', ' ');
      ECHO( '!     (DESCRIPTION =', ' ');
      IF forced = 'Y' THEN
        ECHO( '!            (TRANSPORT_CONNECT_TIMEOUT : ' || connect_timeout||')', ' ');
        ECHO( '!            (CONNECT_TIMEOUT = ' || connect_timeout||')', ' ');
        ECHO( '!            (RETRY_DELAY = ' || JSON_VALUE(v_extra_json, '$.v_var3')||')', ' ');
        ECHO( '!            (RETRY_COUNT = ' || JSON_VALUE(v_extra_json, '$.v_var4')||')', ' ');
        ECHO( '!            (FAILOVER = ' || JSON_VALUE(v_extra_json, '$.v_var5')||')', ' ');
        ECHO( '!            (LOAD_BALANCE = ' || JSON_VALUE(v_extra_json, '$.v_var6')||')', ' ');
      END IF;
      ECHO( '!     (ADDRESS = TCP)', ' ');
      ECHO( '!       (HOST = ' || host_name||')', ' ');
      ECHO( '!       (PORT = ' || port||')', ' ');
      ECHO( '!       )', ' ');
      ECHO( '!       (CONNECT_DATA = ', ' ');
      ECHO( '!         (SERVER = DEDICATED)', ' ');
      ECHO( '!         (SERVICE_NAME = ' || service_name||')', ' ');
      ECHO( '!       )', ' ');
      ECHO( '!     )', ' ');
      ECHO( '!', ' ');
      IF cont = 'N' THEN
        ECHO( '!', '-');
        ECHO( '!- GIVEN and VERIFIED PARAMETERS ', '-');
      ECHO( '!', ' ');
        ECHO( '!   HOST_NAME           : ' || v_var3, ' ');
        ECHO( '!   v_is_ifqdn          : ' || fqdn_validation, ' ');
        ECHO( '!   v_force             : ' || forced, ' ');
        ECHO( '!   v_is_numeral        : ' || numeral_validation, ' ');
        ECHO( '!   v_is_valid_ip       : ' || ip_validation, ' ');
        ECHO( '!   v_is_valid_phase    : ' || phase_validation, ' ');
      ECHO( '!', ' ');
      END IF;
      ECHO( '!', '!');
      --
      IF cont = 'Y' THEN
        DBMS_OUTPUT.PUT_LINE('                                                        Don''t forget to execute TETOOLS.ADMIN_TNSNAMES.GENERATE_TNS !');
      END IF;
      DBMS_OUTPUT.PUT_LINE(chr(13)||chr(10));
  END report_registration;
  --
  -- /* PROCEDURE > who_called ---------------------------------------------------------------------------------------- UTL_CALL_STACK ----- HEADER */
  --
  PROCEDURE who_called ( p_trm_result OUT VARCHAR2, p_level IN INTEGER DEFAULT 2 )
  AS
      v_caller               utl_call_stack.unit_qualified_name;
      v_name                 VARCHAR2(128);
  BEGIN
  /* This procedure retrieves the calling component.                                                                    COMMENT */
  /* This information is used for troubleshooting and debugging and has no purpose for standard operational use.        COMMENT */
      -- step backwards though the call stack
      --      1 = current module = who_called function
      --      2 = the module that calls who_called
      --      3 = the caller!
      v_caller     := utl_call_stack.subprogram(p_level);
      p_trm_result := utl_call_stack.concatenate_subprogram(v_caller);
  END who_called;
  --
  -- /* PROCEDURE > notify ------------------------------------------------------------------------------------ UTL_CALL_STACK WRAPPER ----- HEADER */
  --
  PROCEDURE notify (p_message_num IN NUMBER, p_caller IN VARCHAR2, p_message_string IN VARCHAR2)
  AS
      v_this_object          VARCHAR2(128);
      v_caller               VARCHAR2(512)                            := p_caller;
      v_message_num          NUMBER                                   := p_message_num;
      v_message_string       VARCHAR2(4000)                           := p_message_string;
  BEGIN
  	DBMS_OUTPUT.PUT_LINE( v_message_num || ' > '|| v_caller || ' ' ||v_message_string );
  END;
  --
  -- /* PROCEDURE > crud ---------------------------------------------------------------------------------------------- RECORD STORING ----- HEADER */
  --
  PROCEDURE crud ( json_string IN CLOB, p_tns_id OUT INTEGER )
  AS
      v_this_object             VARCHAR2(128);
      inter                     CLOB;
      data                      JSON_OBJECT_T;
      v_sql_cmd                 VARCHAR2(4000);
      crud                      CHAR(1);
      tns_id                    INTEGER;
      v_tns_id_OUT              INTEGER;
      tns_alias                 VARCHAR2(32);
      target_phase              CHAR(1);
      target_envs               VARCHAR2(8);
      host_name                 VARCHAR2(128);
      service_name              VARCHAR2(48);
      port                      NUMBER;
      date_valid_from           VARCHAR2(10);
      entry_description         VARCHAR2(256);
      date_valid_end            VARCHAR2(10);
      i_connect_timeout         NUMBER;
      s_connect_timeout         VARCHAR2(7)          := 'NULL';
      i_retry_delay             NUMBER;
      s_retry_delay             VARCHAR2(7)          := 'NULL';
      i_retry_count             NUMBER;
      s_retry_count             VARCHAR2(7)          := 'NULL';
      failover                  VARCHAR2(7)          := 'NULL';
      load_balance              VARCHAR2(7)          := 'NULL';
      cont                      CHAR(1);
      --crud_retrieve             EXCEPTION;
      --crud_unknown              EXCEPTION;
      --generic_error             EXCEPTION;
      --idx_internal_check        EXCEPTION;
      --PRAGMA EXCEPTION_INIT     (crud_retrieve ,       -20014);
      --PRAGMA EXCEPTION_INIT     (crud_unknown ,        -20015);
      --PRAGMA EXCEPTION_INIT     (generic_error       , -20010);
      --PRAGMA EXCEPTION_INIT     (idx_internal_check  , -20011);
      -- /* Create an varray that allows to set flags for failed checks.                                                  COMMENT */
      -- /* In this way all checks can complete without the need to raise application errors.                             COMMENT */
      -- /* The varray holds all OUT parameters as elements but is only used for the elements ending in "*_validation".   COMMENT */
      -- /* The field "function_value" is superflous, as the OUT parameters themselves are set.                           COMMENT */
      -- /* rec_execution_validation(function_name, function_value, function_severity, function_flag)                     COMMENT */
      --
      y   var_excval :=    var_excval
              (   rec_execution_validation('idx_internal_check', 'X', 'X', 9, 'N')  -- index 1
              ,   rec_execution_validation('numeral_validation', 'X', 'X', 2, 'N')  -- index 2
              ,   rec_execution_validation('ip_validation',      'X', 'X', 1, 'N')  -- index 3
              ,   rec_execution_validation('phase_validation',   'X', 'X', 4, 'N')  -- index 4
              ,   rec_execution_validation('fqdn_validation',    'X', 'X', 4, 'N')  -- index 5
              ,   rec_execution_validation('dname_validation',   'X', 'X', 3, 'N')  -- index 6
              ,   rec_execution_validation('hostname_isfqdn',    'X', 'X', 1, 'N')  -- index 7
              ,   rec_execution_validation('hostname_eval',      'X', 'X', 1, 'N')  -- index 8
              ,   rec_execution_validation('shortname',          'X', 'X', 4, 'N')  -- index 9
              ,   rec_execution_validation('domainname',         'X', 'X', 1, 'N')  -- index 10
              ,   rec_execution_validation('continue',           'Y', 'X', 9, 'N')  -- index 11
              );
      -- /* function idx allows a lookup for the index value in the varray based on a value                               COMMENT */
      FUNCTION idx(p_idx VARCHAR2) RETURN PLS_INTEGER AS
        BEGIN
          FOR i IN 1..y.LAST
            LOOP
              IF (y(i).function_name = p_idx) THEN RETURN i;
              END IF;
            END LOOP;
          RETURN 0;
        END idx;
      --
      PROCEDURE checkmark(p_idx IN INTEGER, p_val IN CHAR) AS
      BEGIN
      	IF y(p_idx).function_name = 'idx_internal_check'                                                                       THEN
      	  RAISE idx_internal_check;
      	END IF;
        IF (y(p_idx).function_value = 'Y' OR y(p_idx).function_value = 'X') OR v_this_object = 'ADMIN_TNSNAMES.EVAL_HOSTNAME.RAISE_SEV'     THEN
           y(idx('continue')).function_executed := 'Y';
           y(p_idx).function_executed           := 'Y';
           y(p_idx).function_value              :=  p_val;
           --
           IF y(idx('continue')).function_value = 'Y' AND p_val = 'N' AND y(p_idx).function_severity > 3                       THEN
             y(idx('continue')).function_value  := 'N';
           END IF;
        END IF;
      END checkmark;
      --
      PROCEDURE raise_sev(p_idx IN INTEGER, p_sev IN CHAR, p_val IN CHAR) AS
      BEGIN
      	tetools.admin_tnsnames.who_called(v_this_object);
      	--
      	IF y(p_idx).function_name = 'idx_internal_check'                                                                       THEN
      	  RAISE idx_internal_check;
      	END IF;
        y(p_idx).function_severity           :=  p_sev;
        checkmark(p_idx, p_val);
      END raise_sev;
      --
      FUNCTION change2null(p_param_in VARCHAR2 DEFAULT '0904341073') RETURN VARCHAR2 AS
        v_is_numeral             CHAR(1);
        v_input                  VARCHAR2(10);
        p_output                 VARCHAR2(10);
      BEGIN
      	--
      	IF p_param_in IS NULL                              THEN
      	  v_input :=           '0904341073';
      	ELSE
      	  v_input :=           p_param_in;
      	END IF;
      	--
      	SELECT CASE
               WHEN REGEXP_LIKE(v_input, '^([0-9.]*)$') THEN 'Y'
                                                           ELSE 'N'
             END is_number INTO v_is_numeral
        FROM DUAL;
        --
        IF v_is_numeral = 'N'                              THEN
          p_output := ''''||v_input||'''';
        ELSIF v_input = '0904341073'                       THEN
          p_output := 'NULL';
        -- /* Below is commented out, this function is created _just_ for  quoting NULLs instead of text                    COMMENT */
        --ELSE
        --  p_output := v_input;
        END IF;
        --
        RETURN p_output;
      END change2null;
  BEGIN
    --
    tetools.admin_tnsnames.who_called(v_this_object);
    --
    SELECT TREAT(json_string as json) INTO INTER FROM dual;
    --
    --
    data                  := new JSON_OBJECT_T(inter);
    crud                  := data.get_string('crud');
    tns_id                := data.get_string('tns_id');
    tns_alias             := data.get_string('tns_alias');
    target_phase          := data.get_string('target_phase');
    target_envs           := data.get_string('target_envs');
    host_name             := data.get_string('host_name');
    service_name          := data.get_string('service_name');
    port                  := data.get_string('port');
    date_valid_from       := data.get_string('date_valid_from');
    entry_description     := data.get_string('entry_description');
    date_valid_end        := data.get_string('date_valid_end');
    i_connect_timeout     := data.get_string('connect_timeout');
    i_retry_delay         := data.get_string('retry_delay');
    i_retry_count         := data.get_string('retry_count');
    failover              := data.get_string('failover');
    load_balance          := data.get_string('load_balance');
    cont                  := data.get_string('continue');
    --
    --IF tns_id                IS NULL THEN tns_id            := change2null(tns_id);       ELSE tns_id       := change2null(tns_id); END IF;
    IF i_connect_timeout IS NOT NULL THEN s_connect_timeout := TO_CHAR(i_connect_timeout); END IF;
    IF i_retry_delay     IS NOT NULL THEN s_retry_delay     := TO_CHAR(i_retry_delay); END IF;
    IF i_retry_count     IS NOT NULL THEN s_retry_count     := TO_CHAR(i_retry_count); END IF;
    IF failover          IS     NULL THEN failover          := change2null(failover);     ELSE failover     := change2null(failover); END IF;
    IF load_balance      IS     NULL THEN load_balance      := change2null(load_balance); ELSE load_balance := change2null(load_balance); END IF;
    --
    IF crud = 'C'                                                                                                                THEN
      --v_sql_cmd := 'INSERT INTO TETOOLS.ADMIN_TNSNAMES_BASE (TNS_ALIAS, PHASE, TARGET_ENV, HOST_NAME, INSTANCE_NAME, PORT, DATE_VALID_FROM, DESCRIPTION, DATE_VALID_END, CONNECT_TIMEOUT, RETRY_DELAY, RETRY_COUNT, FAILOVER, LOAD_BALANCE) VALUES ('''||tns_alias||''', '''||target_phase||''', '''||target_envs||''', '''||host_name||''', '''||service_name||''', '||port||', TO_DATE('''||date_valid_from||''', '''||'YYYY-MM-DD'||'''), '''||entry_description||''', TO_DATE('''||date_valid_end||''', '''||'YYYY-MM-DD'||'''), '||s_connect_timeout||', '||s_retry_delay||', '||s_retry_count||', '||failover||', '||load_balance||')';
      v_sql_cmd := 'INSERT INTO TETOOLS.ADMIN_TNSNAMES_BASE (TNS_ALIAS, PHASE, TARGET_ENV, HOST_NAME, INSTANCE_NAME, PORT, DATE_VALID_FROM, DESCRIPTION, DATE_VALID_END, CONNECT_TIMEOUT, RETRY_DELAY, RETRY_COUNT, FAILOVER, LOAD_BALANCE) VALUES ('''||tns_alias||''', '''||target_phase||''', '''||target_envs||''', '''||host_name||''', '''||service_name||''', '||port||', TO_DATE('''||date_valid_from||''', '''||'YYYY-MM-DD'||'''), '''||entry_description||''', TO_DATE('''||date_valid_end||''', '''||'YYYY-MM-DD'||'''), '||s_connect_timeout||', '||s_retry_delay||', '||s_retry_count||', '||failover||', '||load_balance||')';
      --
      EXECUTE IMMEDIATE v_sql_cmd || ' RETURNING TNS_ID INTO :NEW_TNS' USING OUT v_tns_id_OUT;
      p_tns_id := v_tns_id_OUT;
    ELSIF crud = 'R'                                                                                                             THEN
      RAISE crud_retrieve;
    ELSIF crud = 'U'                                                                                                             THEN
      v_sql_cmd := 'UPDATE TETOOLS.ADMIN_TNSNAMES_BASE SET TNS_ALIAS = '''||tns_alias||''', PHASE = '''||target_phase||''', TARGET_ENV = '''||target_envs||''', HOST_NAME = '''||host_name||''', INSTANCE_NAME = '''||service_name||''', PORT = '||port||', DATE_VALID_FROM = TO_DATE('''||date_valid_from||''',''YYYY-MM-DD''), DESCRIPTION = '''||entry_description||''', DATE_VALID_END = TO_DATE('''||date_valid_end||''', ''YYYY-MM-DD''), CONNECT_TIMEOUT = '||s_connect_timeout||', RETRY_DELAY = '||s_retry_delay||', RETRY_COUNT = '||s_retry_count||', FAILOVER = '||failover||', LOAD_BALANCE = '||load_balance||' WHERE tns_id = '||tns_id;
      --
      EXECUTE IMMEDIATE v_sql_cmd;
      --
      p_tns_id := tns_id;
    ELSIF crud = 'D'                                                                                                             THEN
      v_sql_cmd := 'DELETE FROM TETOOLS.ADMIN_TNSNAMES_BASE WHERE tns_id = '||tns_id;
      --
      EXECUTE IMMEDIATE v_sql_cmd;
      --
      p_tns_id := tns_id;
    ELSE
      RAISE crud_unknown;
    END IF;
    --
    EXCEPTION
    WHEN crud_retrieve                                                                                                           THEN
      notify('0422544095 > crud_retrieve      : ', v_this_object, DBMS_UTILITY.format_error_stack);
      --RAISE;
    WHEN crud_unknown                                                                                                        THEN
      notify('3938215116 > crud_unknown      : ', v_this_object, DBMS_UTILITY.format_error_stack);
      --RAISE;
    WHEN idx_internal_check                                                                                                  THEN
      notify('7702778517 > idx_internal_check   : ', v_this_object, DBMS_UTILITY.format_error_stack);
      RAISE;
    WHEN OTHERS                                                                                                              THEN
      notify('7895709957 > others               : ', v_this_object, DBMS_UTILITY.format_error_stack);
      RAISE;
  END crud;
  --
  -- /* PROCEDURE > compare_roles ------------------------------------------------------------------- QUERY GRANTED ROLES FOR QUERIED SESSION ----- */
  --
  PROCEDURE compare_roles(p_inv_roles          OUT        VARCHAR2,
                          p_isinvusr_adm       OUT        VARCHAR2,
                          p_isinvusr_con       OUT        VARCHAR2)
  AS
    v_this_object            VARCHAR2(128);
    v_username               VARCHAR2(128)   := SYS_CONTEXT('USERENV', 'SESSION_USER');
    v_inv_roles              VARCHAR2(2000);
    v_isinvusr_adm           CHAR(1) := 'N';
    v_isinvusr_con           CHAR(1) := 'N';
	--
    CURSOR c_invuser_roles(p_inv_username IN VARCHAR2)
    IS
    SELECT  granted_role
      FROM  dba_role_privs
     WHERE  grantee = UPPER(p_inv_username);
	--
    CURSOR c_tns_roles(p_inv_role IN VARCHAR2)
    IS
    SELECT a.match_count, a.id, b.pref_name, b.tns_roles
       FROM (SELECT rownum AS id, pref_name, count(*) match_count
               FROM tetools.admin_tnsnames_prefs
              WHERE (pref_name = 'ADMINISTRATOR_ROLE' OR pref_name = 'CONTRIBUTOR_ROLE')
              GROUP BY rownum, pref_name) a,
            (SELECT rownum AS id, pref_name, pref_value AS tns_roles, count(*) match_count
               FROM tetools.admin_tnsnames_prefs
              WHERE (pref_name = 'ADMINISTRATOR_ROLE' OR pref_name = 'CONTRIBUTOR_ROLE')
                AND pref_value = p_inv_role
              GROUP BY rownum, pref_name, pref_value) b
      WHERE a.id = b.id(+)
        AND b.match_count >0;
  BEGIN
  	--
    tetools.admin_tnsnames.who_called(v_this_object);
    --
    /* The comparison for admin roles can be altered for them to be retrieved from table tetools.admin_sessions_prefs.  COMMENT */
    /* In addition, this table (and procedure) can be made generic when an extra column is added to reflect the current COMMENT */
    /*   package                                                                                                        COMMENT */
    FOR r_row IN c_invuser_roles(v_username)
    LOOP
      FOR rr_row IN c_tns_roles(r_row.granted_role)
      LOOP
        v_inv_roles := v_inv_roles ||' '|| r_row.granted_role ||',';
        IF    rr_row.pref_name = 'ADMINISTRATOR_ROLE'   THEN
          v_isinvusr_adm := 'Y';
        ELSIF rr_row.pref_name = 'CONTRIBUTOR_ROLE'     THEN
          v_isinvusr_con := 'Y';
        END IF;
      END LOOP;
    END LOOP;
    --
    /* housekeeping on the retrieved string to remove spaces.                                                           COMMENT */
    SELECT REGEXP_REPLACE(v_inv_roles, ',[ ]*$', '') INTO p_inv_roles FROM dual;
    --
    p_isinvusr_adm := v_isinvusr_adm;
    p_isinvusr_con := v_isinvusr_con;
    --
  EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('COMPARE_ROLES ERROR STACK: '|| DBMS_UTILITY.format_error_stack);
    RAISE;
  END compare_roles;
  --
  -- /* PROCEDURE > query_tns ----------------------------------------------------------------------------------- QUERY EXISTING ALIAS ----- HEADER */
  --
  PROCEDURE query_tns (p_tns_alias IN VARCHAR2, p_phase_in IN CHAR, p_does_exist OUT CHAR)
  AS
    v_this_object             VARCHAR2(128);
    v_calling_object          VARCHAR2(128);
    v_does_exist              CHAR(1);
    v_phase_out               CHAR(1);
    v_tns_id                  INTEGER;
    v_host_name               VARCHAR2(128);
    v_service_name            VARCHAR2(128);
	--
    CURSOR c_query_tns_count(p_alias IN VARCHAR2, p_phase IN CHAR) IS
          SELECT CASE WHEN COUNT(a.tns_attr_value) = 1 THEN 'Y' ELSE 'N' END AS does_exist
            FROM tetools.ADMIN_TNSNAMES_ENTRIES a
      INNER JOIN tetools.ADMIN_TNSNAMES_ENTRIES b ON a.tns_id = b.tns_id
           WHERE (UPPER(a.tns_attr_value)  = UPPER(p_alias) AND a.hierarchy_child_id = 2)
             AND (UPPER(b.tns_attr_value)  = UPPER(p_phase) AND b.hierarchy_child_id = 9998);
    --
    CURSOR c_retrieve_tns_rows(p_alias IN VARCHAR2, p_phase IN CHAR) IS
      WITH cte_tns_id AS
      (     SELECT a.tns_id
              FROM tetools.ADMIN_TNSNAMES_ENTRIES a
        INNER JOIN tetools.ADMIN_TNSNAMES_ENTRIES b ON a.tns_id = b.tns_id
             WHERE (UPPER(a.tns_attr_value)  = UPPER(p_alias) AND a.hierarchy_child_id = 2)
               AND (UPPER(b.tns_attr_value)  = UPPER(p_phase) AND b.hierarchy_child_id = 9998))
      SELECT NET_SERVICE_NAME,HOST,PHASE,SERVICE_NAME,SID,INSTANCE_NAME
        FROM
      (
            SELECT a.tns_id, a.tns_attr, a.tns_attr_value 
              FROM tetools.ADMIN_TNSNAMES_ENTRIES a
        INNER JOIN cte_tns_id b ON a.tns_id = b.tns_id
      )
      PIVOT
      (
        MAX(tns_attr_value)
        FOR tns_attr IN ('NET_SERVICE_NAME' AS NET_SERVICE_NAME,'HOST' AS HOST,'PHASE' AS PHASE,'SERVICE_NAME' AS SERVICE_NAME,'SID' AS SID,'INSTANCE_NAME' AS INSTANCE_NAME)
      );
  BEGIN
  	--
    tetools.admin_tnsnames.who_called(v_this_object);
  	--
    tetools.admin_tnsnames.who_called(v_calling_object, 3);
    --
  	FOR r_row IN c_query_tns_count(p_tns_alias, p_phase_in)
      LOOP
        v_does_exist := r_row.does_exist;
      END LOOP;
    --
    IF v_calling_object = '__anonymous_block' THEN
  	  IF v_does_exist = 'Y' THEN
  	    FOR r_row IN c_retrieve_tns_rows(p_tns_alias, p_phase_in)
          LOOP
  	        --tetools.admin_tnsnames.report_existing ( p_tns_alias, v_does_exist, r_row.phase, r_row.host, r_row.instance_name );
  	        NULL;
          END LOOP;
      ELSE
        --tetools.admin_tnsnames.report_existing ( p_tns_alias, v_does_exist, p_phase_in );
        NULL;
  	  END IF;
  	END IF;
  	--
  	p_does_exist := v_does_exist;
  END query_tns;
  --
  -- /* PROCEDURE > existing_tns ------------------------------------------------------------------------------ RETRIEVE EXISTING ALIAS----- HEADER */
  --
  PROCEDURE existing_tns (p_tns_alias IN VARCHAR2, p_phase_in IN CHAR, p_crud OUT CHAR, p_tns_id OUT INTEGER, p_does_exist OUT CHAR, p_phase_out OUT CHAR, p_host_name OUT VARCHAR2, p_service_name OUT VARCHAR2)
  AS
    v_this_object             VARCHAR2(128);
    v_calling_object          VARCHAR2(128);
    v_tns_id                  INTEGER;
    v_does_exist              CHAR(1);
    v_phase_out               CHAR(1);
    v_host_name               VARCHAR2(128);
    v_service_name            VARCHAR2(128);
    --
    CURSOR c_existing_tns_count(p_alias IN VARCHAR2, p_phase IN CHAR) IS
          SELECT CASE WHEN COUNT(p_alias) = 1 THEN 'Y' ELSE 'N' END AS does_exist
            FROM tetools.ADMIN_TNSNAMES_ENTRIES a
      INNER JOIN tetools.ADMIN_TNSNAMES_ENTRIES b ON a.tns_id = b.tns_id
           WHERE (UPPER(a.tns_attr_value)  = UPPER(p_alias) AND a.hierarchy_child_id = 2)
             AND (UPPER(b.tns_attr_value)  = UPPER(p_phase) AND b.hierarchy_child_id = 9998);
    CURSOR c_retrieve_tns_rows(p_alias IN VARCHAR2, p_phase IN CHAR) IS
      SELECT a.tns_ID, b.NET_SERVICE_NAME, b.HOST, b.PHASE, b.SERVICE_NAME, b.SID, b.INSTANCE_NAME
        FROM ( SELECT a.tns_id, a.tns_attr_value as "NET_SERVICE_NAME"
                               FROM tetools.ADMIN_TNSNAMES_ENTRIES a
              INNER JOIN tetools.ADMIN_TNSNAMES_ENTRIES b ON a.tns_id = b.tns_id
                              WHERE (UPPER(a.tns_attr_value)  = UPPER(p_alias) AND a.hierarchy_child_id = 2)
                                AND (UPPER(b.tns_attr_value)  = UPPER(p_phase) AND b.hierarchy_child_id = 9998)
              ) a,
              (
              WITH cte_tns_id AS
              (     SELECT a.tns_id
                      FROM tetools.ADMIN_TNSNAMES_ENTRIES a
                INNER JOIN tetools.ADMIN_TNSNAMES_ENTRIES b ON a.tns_id = b.tns_id
                     WHERE (UPPER(a.tns_attr_value)  = UPPER(p_alias) AND a.hierarchy_child_id = 2)
                       AND (UPPER(b.tns_attr_value)  = UPPER(p_phase) AND b.hierarchy_child_id = 9998))
              SELECT NET_SERVICE_NAME,HOST,PHASE,SERVICE_NAME,SID,INSTANCE_NAME
                FROM
              (     SELECT a.tns_id, a.tns_attr, a.tns_attr_value 
                      FROM tetools.ADMIN_TNSNAMES_ENTRIES a
                INNER JOIN cte_tns_id b ON a.tns_id = b.tns_id
              )
              PIVOT
              (
                MAX(tns_attr_value)
                FOR tns_attr IN ('NET_SERVICE_NAME' AS NET_SERVICE_NAME,'HOST' AS HOST,'PHASE' AS PHASE,'SERVICE_NAME' AS SERVICE_NAME,'SID' AS SID,'INSTANCE_NAME' AS INSTANCE_NAME)
              )
              ) b
        WHERE a.NET_SERVICE_NAME = b.NET_SERVICE_NAME;
  BEGIN
  	--
    tetools.admin_tnsnames.who_called(v_this_object);
  	--
    tetools.admin_tnsnames.who_called(v_calling_object, 3);
    --
  	FOR r_row IN c_existing_tns_count(p_tns_alias, p_phase_in)
      LOOP
        v_does_exist := r_row.does_exist; p_does_exist := r_row.does_exist;
      END LOOP;
    --
  	IF v_does_exist = 'Y' THEN
  	  p_crud := 'U';
  	  FOR r_row IN c_retrieve_tns_rows(p_tns_alias, p_phase_in)
        LOOP
          p_tns_id       := r_row.tns_id;
          p_phase_out    := r_row.phase;
  	      p_host_name    := r_row.host;
  	      p_service_name := r_row.instance_name;
        END LOOP;
    ELSIF v_does_exist = 'N' THEN
      p_crud := 'C';
	  END IF;
	  --
  	p_does_exist := v_does_exist;
	--
  END existing_tns;
  --
  -- /* PROCEDURE > phase_checker ---------------------------------------------------------------------------------------- VALID PHASE ----- HEADER */
  --
  PROCEDURE phase_checker ( p_hostname IN VARCHAR, p_phase IN CHAR, p_isphasevalid OUT CHAR ) AS
      v_param_hostname_IN      VARCHAR(128)                             := UPPER(p_hostname);
      v_param_phase_IN         CHAR(1)                                  := UPPER(p_phase);
      v_valid_phase            CHAR(1)                                  := 'N';
      v_phase_domain_suffix    CHAR(7)                                  := '_DOMAIN';
      v_full_phase_domain_pref VARCHAR2(8)                              := v_param_phase_IN||v_phase_domain_suffix;
  BEGIN
    WITH c_test_phase AS
     (SELECT COUNT(pref_name) NUM FROM tetools.admin_tnsnames_prefs WHERE UPPER(pref_name)=v_full_phase_domain_pref)
       SELECT CASE WHEN c_test_phase.num = 1 THEN 'Y' ELSE 'N' END INTO v_valid_phase FROM c_test_phase;
    --
    p_isphasevalid := v_valid_phase;
  END phase_checker;
  --
  -- /* PROCEDURE > ipaddress_checker ------------------------------------------------------------------------------- VALID IP-ADDRESS ----- HEADER */
  --
  PROCEDURE ipaddress_checker ( p_hostname IN VARCHAR2, p_numperiods OUT INTEGER, p_isnumeral OUT CHAR, p_isvalidip OUT CHAR, p_feedback OUT INTEGER ) AS
      v_count_periods          INTEGER;
      v_is_numeral             CHAR(1);
      v_is_valid_ip            CHAR(1);
      v_feedback               INTEGER;
  BEGIN
  	SELECT REGEXP_COUNT(p_hostname, '[.]'),
           CASE
             WHEN REGEXP_LIKE(p_hostname, '^([0-9.]*)$') THEN 'Y'
                                                         ELSE 'N'
           END,
           CASE
             WHEN REGEXP_LIKE(p_hostname, '^([1-9]{1}|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.(([0-9]{1}|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){2}([1-9]{1}|[0-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$')
                                                         THEN 'Y'
                                                         ELSE 'N'
           END is_valid_ip  INTO v_count_periods, v_is_numeral, v_is_valid_ip
      FROM DUAL;
    --
    p_numperiods                                                        := v_count_periods;
    p_isnumeral                                                         := v_is_numeral;
    p_isvalidip                                                         := v_is_valid_ip;
    --
    IF v_is_numeral = 'Y' AND v_count_periods = 3 THEN
      IF v_is_valid_ip = 'Y' THEN
        p_feedback                                                        := 0;
      ELSIF v_is_valid_ip = 'N' THEN
        p_feedback                                                        := 5;
      ELSE
        p_feedback                                                        := 6;
      END IF;
    ELSIF v_is_numeral = 'Y' AND v_count_periods > 3 THEN
      p_feedback                                                          := 1;
    ELSIF v_is_numeral = 'Y' AND v_count_periods < 3 THEN
      p_feedback                                                          := 2;
    ELSIF v_is_numeral = 'N' THEN
      p_feedback                                                          := 3;
    ELSE
      p_feedback                                                          := 4;
    END IF;
  END ipaddress_checker;
  --
  -- /* PROCEDURE > port_checker ------------------------------------------------------------------------------------------ VALID PORT ----- HEADER */
  --
  PROCEDURE port_checker ( p_port IN VARCHAR2, p_numeral OUT CHAR, p_is_1k OUT CHAR, p_default_port OUT CHAR, p_range_expected OUT CHAR, p_continue OUT CHAR )
  AS
      v_this_object             VARCHAR2(128);
      v_continue                CHAR(1);
      v_is_numeral              CHAR(1);
      v_is_1k                   CHAR(1);
      v_default_port            CHAR(1);
      v_port_range_expected     CHAR(1);
      --port_validation           EXCEPTION;
      --idx_internal_check        EXCEPTION;
      --PRAGMA EXCEPTION_INIT     (idx_internal_check  , -20011);
      --PRAGMA EXCEPTION_INIT     (port_validation     , -20013);
      -- /* Create an varray that allows to set flags for failed checks.                                                  COMMENT */
      -- /* In this way all checks can complete without the need to raise application errors.                             COMMENT */
      -- /* The varray holds all OUT parameters as elements but is only used for the elements ending in "*_validation".   COMMENT */
      -- /* The field "function_value" is superflous, as the OUT parameters themselves are set.                           COMMENT */
      -- /* rec_execution_validation(function_name, function_value, function_severity, function_flag)                     COMMENT */
      --
      u   var_excval :=    var_excval
              (   rec_execution_validation('idx_internal_check', 'X', 'X', 9, 'N')  -- index 1
              ,   rec_execution_validation('numeral_validation', 'X', 'X', 9, 'N')  -- index 2
              ,   rec_execution_validation('1k_validation',      'X', 'X', 1, 'N')  -- index 3
              ,   rec_execution_validation('default_port',       'X', 'X', 1, 'N')  -- index 4
              ,   rec_execution_validation('range_expected',     'X', 'X', 2, 'N')  -- index 5
              ,   rec_execution_validation('continue',           'Y', 'X', 9, 'N')  -- index 6f
              );
      -- /* function idx allows a lookup for the index value in the varray based on a value                               COMMENT */
      FUNCTION idx(p_idx VARCHAR2) RETURN PLS_INTEGER AS
        BEGIN
          FOR i IN 1..u.LAST
            LOOP
              IF (u(i).function_name = p_idx) THEN RETURN i;
              END IF;
            END LOOP;
          RETURN 0;
        END idx;
      --
      PROCEDURE checkmark(p_idx IN INTEGER, p_val IN CHAR) AS
      BEGIN
      	IF u(p_idx).function_name = 'idx_internal_check'                                                                       THEN
      	  RAISE idx_internal_check;
      	END IF;
        IF (u(p_idx).function_value = 'Y' OR u(p_idx).function_value = 'X') OR   v_this_object = 'ADMIN_TNSNAMES.PORT_CHECKER.RAISE_SEV'      THEN
           u(idx('continue')).function_executed := 'Y';
           u(p_idx).function_executed           := 'Y';
           u(p_idx).function_value              :=  p_val;
           --
           IF u(idx('continue')).function_value = 'Y' AND p_val = 'N' AND u(p_idx).function_severity > 3                       THEN
             u(idx('continue')).function_value  := 'N';
           END IF;
        END IF;
      END checkmark;
      --
      PROCEDURE raise_sev(p_idx IN INTEGER, p_sev IN CHAR, p_val IN CHAR) AS
      BEGIN
      	tetools.admin_tnsnames.who_called(v_this_object);
      	--
      	IF u(p_idx).function_name = 'idx_internal_check'                                                                       THEN
      	  RAISE idx_internal_check;
      	END IF;
        u(p_idx).function_severity           :=  p_sev;
        checkmark(p_idx, p_val);
      END raise_sev;
  BEGIN  
    --
    tetools.admin_tnsnames.who_called(v_this_object);
    --
    -- /* perform basic checks against the given portnumber                                                               COMMENT */
    SELECT CASE WHEN REGEXP_LIKE(p_port, '^([0-9.]*)$')    THEN 'Y' ELSE 'N' END,
           CASE WHEN REGEXP_LIKE(p_port, '^([0-9.]*){4}$') THEN 'Y' ELSE 'N' END,
           CASE WHEN REGEXP_LIKE(p_port, '^1521$')         THEN 'Y' ELSE 'N' END
           INTO v_is_numeral, v_is_1k, v_default_port
      FROM dual;
    --
    IF v_is_numeral = 'Y'                                                                                                      THEN
      SELECT CASE WHEN p_port BETWEEN 1520 AND 1600        THEN 'Y' ELSE 'N' END
             INTO v_port_range_expected
        FROM dual;
    ELSE
      v_port_range_expected                     := 'N';
    END IF;
    --
    checkmark(idx('numeral_validation'), v_is_numeral);      p_numeral        := v_is_numeral;
    checkmark(idx('1k_validation'), v_is_1k);                p_is_1k          := v_is_1k;
    checkmark(idx('default_port'), v_default_port);          p_default_port   := v_default_port;
    checkmark(idx('range_expected'), v_port_range_expected); p_range_expected := v_port_range_expected;
    p_continue := u(idx('continue')).function_value;
    --
    EXCEPTION
    WHEN port_validation                                                                                                     THEN
      notify('4403872153', 'port_validation      : ', p_port);
      --RAISE;
    WHEN idx_internal_check                                                                                                  THEN
      notify('9901187350', 'idx_internal_check   : ', p_port);
      RAISE;
    WHEN OTHERS                                                                                                              THEN
      notify('3388488828', 'others               : ', p_port);
      RAISE;
  END port_checker;
  --
  -- /* PROCEDURE > isIPAddress ------------------------------------------------------------------------ VALIDATE HOSTNAME AS VALID IP ----- HEADER */
  --
  PROCEDURE isipaddress ( p_hostname IN VARCHAR2, p_return OUT CHAR )
  AS
    v_this_object            VARCHAR2(128);
    v_return                 CHAR(1);
  BEGIN
  	--
    tetools.admin_tnsnames.who_called(v_this_object);
    --
  	SELECT CASE
             WHEN REGEXP_LIKE(p_hostname, '^([1-9]{1}|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.(([0-9]{1}|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){2}([1-9]{1}|[0-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$')
                  THEN 'Y'
             ELSE      'N'
           END INTO v_return
      FROM DUAL;
    --
    p_return := v_return;
  END isipaddress;
  --
  -- /* PROCEDURE > isfqdn ------------------------------------------------------------------------ IS HOSTNAME A FQDN FOR GIVEN PHASE ----- HEADER */
  --
  PROCEDURE isfqdn ( p_hostname IN VARCHAR2, p_phase IN CHAR, p_force IN CHAR, p_is_valid_phase OUT CHAR, p_is_fqdn OUT CHAR,
                     p_is_valid_dname OUT CHAR, p_param_hostname OUT VARCHAR2, p_param_domain_name OUT VARCHAR2, p_continue OUT CHAR, p_feedback OUT INTEGER )
  AS
    v_this_object            VARCHAR2(128);
    v_param_phase_IN         CHAR(1);
    v_continue               CHAR(1)                                  := 'N';
    v_valid_phase            CHAR(1)                                  := 'N';
    v_phase_domain_suffix    CHAR(7)                                  := '_DOMAIN';
    v_correct_domain_name    CHAR(1)                                  := 'N';
    v_valid_domain_name      CHAR(1)                                  := 'N';
    v_is_possible_fqdn       CHAR(1)                                  := 'N';
    v_is_fqdn                CHAR(1)                                  := 'N';
    v_is_correct_phase       CHAR(1)                                  := 'N';
    v_varray_test            CHAR(1)                                  := 'X';
    v_counter_errors         INTEGER                                  := 0;
    v_count_p_hostname_dot   INTEGER                                  := 0;
    v_count_hostname_out_dot INTEGER                                  := 0;
    v_count_domain_dot       INTEGER                                  := 0;
    v_count_domain           NUMBER;
    v_full_phase_domain_pref VARCHAR2(8);
    v_phase_domain_name      VARCHAR2(128);
    v_param_domain_name      VARCHAR2(128);
    v_param_hostname_IN      VARCHAR(128);
    v_param_hostname_OUT     VARCHAR(128);
    --not_correct_phase        EXCEPTION;
    --no_valid_domain          EXCEPTION;
    --generic_error            EXCEPTION;
    --idx_internal_check       EXCEPTION;
    --PRAGMA EXCEPTION_INIT    (not_correct_phase,  -20001);
    --PRAGMA EXCEPTION_INIT    (no_valid_domain  ,  -20002);
    --PRAGMA EXCEPTION_INIT    (generic_error    ,  -20003);
    --PRAGMA EXCEPTION_INIT    (idx_internal_check, -20011);
    -- /* Create an varray that allows to set flags for failed checks.                                                  COMMENT */
    -- /* In this way all checks can complete without the need to raise application errors.                             COMMENT */
    -- /* The varray holds all OUT parameters as elements but is only used for the elements ending in "*_validation".   COMMENT */
    -- /* The field "function_value" is superflous, as the OUT parameters themselves are set.                           COMMENT */
    -- /* rec_execution_validation(function_name, function_value, function_severity, function_flag)                     COMMENT */
    --
    x   var_excval :=    var_excval
            (   rec_execution_validation('idx_internal_check', 'X', 'X', 9, 'N')  -- index 1
            ,   rec_execution_validation('phase_validation',   'X', 'X', 4, 'N')  -- index 2
            ,   rec_execution_validation('fqdn',               'X', 'X', 1, 'N')  -- index 3
            ,   rec_execution_validation('dname_validation',   'X', 'X', 3, 'N')  -- index 4
            ,   rec_execution_validation('hostname',           'X', 'X', 1, 'N')  -- index 5
            ,   rec_execution_validation('domainname',         'X', 'X', 1, 'N')  -- index 6
            ,   rec_execution_validation('continue',           'Y', 'X', 9, 'N')  -- index 7
            );
--
    -- /* function idx allows a lookup for the index value in the varray based on a value                               COMMENT */
    FUNCTION idx(p_idx VARCHAR2) RETURN PLS_INTEGER AS
      BEGIN
        FOR i IN 1..x.LAST
          LOOP
            IF (x(i).function_name = p_idx) THEN RETURN i;
            END IF;
          END LOOP;
        RETURN 0;
      END idx;
    --
    PROCEDURE checkmark(p_idx IN INTEGER, p_val IN CHAR) AS
    BEGIN
    	IF x(p_idx).function_name = 'idx_internal_check' THEN
    	  RAISE idx_internal_check;
    	END IF;
      IF x(p_idx).function_value = 'Y' OR x(p_idx).function_value = 'X' THEN
         x(p_idx).function_executed           := 'Y';
         x(p_idx).function_value              :=  p_val;
         IF x(idx('continue')).function_value = 'Y' AND p_val = 'N' AND x(p_idx).function_severity > 3 THEN
           x(idx('continue')).function_value    := 'N';
           x(idx('continue')).function_executed := 'Y';
         END iF;
      END IF;
    END checkmark;
  BEGIN
  	--
    tetools.admin_tnsnames.who_called(v_this_object);
    --
    -- /* 1  heeft de p_hostname 4 of meer punten in de naam => vindt plaats in [[eval_hostname]]                       COMMENT */
    -- /* 2a bij 4 of meer punten; bestaat v_phase als pref_name                                                        COMMENT */
    -- /* 2b wat is het gegeven domein van v_hostname                                                                   COMMENT */
    -- /* 2c wat is de gegeven hostname                                                                                 COMMENT */
    -- /* 3a  als v_phase bestaat; komt het domein van de v_hostname overeen met de pref_value                          COMMENT */
    --
    -- 2a
    v_param_hostname_IN                                               := UPPER(p_hostname);
    v_param_phase_IN                                                  := UPPER(p_phase);
    v_full_phase_domain_pref                                          := v_param_phase_IN||v_phase_domain_suffix;
    tetools.admin_tnsnames.phase_checker(v_param_hostname_IN, v_param_phase_IN, v_valid_phase);
    p_is_valid_phase                                                  := v_valid_phase;
    p_continue                                                        := v_valid_phase;
    IF v_valid_phase = 'N' THEN
      p_feedback   := 20;
      RAISE not_correct_phase;
    END IF;
    --
    checkmark(idx('phase_validation'), v_valid_phase);
    -- /* As c_test_phase.num defaults to Y/N the same element can be used to set the function_flag.                    COMMENT */
    -- 2b
    SELECT NVL(SUBSTR(v_param_hostname_IN, INSTR(v_param_hostname_IN,'.', -1, 4) + 1), 'N') INTO v_param_domain_name FROM dual;
    p_param_domain_name                                               := v_param_domain_name;
    checkmark(idx('domainname'), v_param_domain_name);
    -- 2c
    SELECT NVL(regexp_substr(v_param_hostname_IN, '(.*?)(\.|$)', 1, 1, NULL, 1), 'N') INTO v_param_hostname_OUT FROM dual;
    p_param_hostname                                                  := v_param_hostname_OUT;
    checkmark(idx('hostname'), v_param_hostname_OUT);
    -- 3a
    SELECT COUNT(pref_value) INTO v_count_domain FROM admin_tnsnames_prefs WHERE UPPER(pref_value) LIKE UPPER(v_param_domain_name);
    IF v_count_domain > 0 THEN
      v_valid_domain_name                                             := 'Y';
      checkmark(idx('dname_validation'), v_valid_domain_name);
      --
      WITH cte_verify_domain AS
       (SELECT COUNT(pref_value) NUM 
          FROM tetools.admin_tnsnames_prefs
         WHERE UPPER(pref_name)  = v_full_phase_domain_pref
           AND UPPER(pref_value) = v_param_domain_name
       )
       SELECT CASE 
                WHEN cte_verify_domain.num = 1 THEN 'Y' 
                                               ELSE 'N' 
              END INTO v_correct_domain_name
         FROM cte_verify_domain;
    END IF;
    IF v_valid_domain_name = 'N'                                                                                              THEN
      p_continue   := v_valid_domain_name;
      p_feedback   := 21;
      RAISE not_correct_phase;
    END IF;
    --
    checkmark(idx('phase_validation'), v_valid_phase);
    checkmark(idx('dname_validation'), v_valid_domain_name);
    checkmark(idx('dname_validation'), v_correct_domain_name);
    --
    WITH cte_is_fqdn AS (
      SELECT a.pref_name AS phase, b.pref_value AS domain
        FROM            admin_tnsnames_prefs A
             INNER JOIN admin_tnsnames_prefs B  ON A.pref_name = b.pref_name
       WHERE UPPER(a.pref_name)  = v_full_phase_domain_pref
         AND UPPER(b.pref_value) = v_param_domain_name
    )
    SELECT CASE WHEN COUNT(*) = 0 THEN 'N'
                WHEN COUNT(*) = 1 THEN 'Y'
                ELSE 'X'
            END INTO v_is_fqdn
      FROM cte_is_fqdn
     WHERE UPPER(phase) = UPPER(v_full_phase_domain_pref)
       AND UPPER(v_param_hostname_OUT||'.'||domain) = UPPER(p_hostname);
    --
    SELECT REGEXP_COUNT(p_hostname, '[.]'), REGEXP_COUNT(v_param_hostname_OUT, '[.]'), REGEXP_COUNT(v_param_domain_name, '[.]' )
      INTO v_count_p_hostname_dot, v_count_hostname_out_dot, v_count_domain_dot
      FROM dual;
    --
    IF v_count_p_hostname_dot > v_count_hostname_out_dot + v_count_domain_dot + 1 AND v_correct_domain_name = 'Y' THEN
      IF p_force = 'Y' AND x(idx('phase_validation')).function_value = 'Y' AND x(idx('dname_validation')).function_value = 'Y' THEN
        checkmark(idx('fqdn'), 'Y');
      ELSE 
        p_feedback := 10;
        checkmark(idx('fqdn'), v_is_fqdn);
      END IF;
    ELSE
      checkmark(idx('fqdn'), v_is_fqdn);
    END IF;
    --
    p_is_valid_phase    := REGEXP_REPLACE( x(idx('phase_validation')).function_value, '[[:space:]]', '' );
    p_is_fqdn           := REGEXP_REPLACE( x(idx('fqdn')).function_value, '[[:space:]]', '' );
    p_is_valid_dname    := REGEXP_REPLACE( x(idx('dname_validation')).function_value, '[[:space:]]', '' );
    p_param_hostname    := x(idx('hostname')).function_value;
    p_param_domain_name := x(idx('domainname')).function_value;
    p_continue          := REGEXP_REPLACE( x(idx('continue')).function_value, '[[:space:]]', '' );
    --
    EXCEPTION
    WHEN not_correct_phase THEN
      notify('4021918122', v_this_object, DBMS_UTILITY.format_error_stack);
      --RAISE;
    WHEN idx_internal_check THEN
      notify('9186677024', v_this_object, DBMS_UTILITY.format_error_stack);
      RAISE;
    WHEN generic_error THEN
      notify('5491615119', v_this_object, DBMS_UTILITY.format_error_stack);
      RAISE;
    WHEN OTHERS THEN
      notify('0881191835', v_this_object, DBMS_UTILITY.format_error_stack);
      RAISE;
  END isfqdn;
  --
  -- /* PROCEDURE > eval_hostname ------------------------------------------------------------- HAS HOSTNAME A VALID IP ADDRESS FORMAT ----- HEADER */
  --
  PROCEDURE eval_hostname ( p_hostname IN VARCHAR2, p_phase IN CHAR, p_force IN CHAR, p_is_numeral OUT CHAR, p_is_valid_ip OUT CHAR,
                            p_is_valid_phase OUT CHAR, p_is_fqdn OUT CHAR, p_is_valid_dname OUT CHAR, p_feedback_string OUT VARCHAR2,
                            p_param_hostname OUT VARCHAR2, p_param_domain_name OUT VARCHAR2, p_continue OUT CHAR )
  AS
    v_this_object             VARCHAR2(128);
    v_count_periods           INTEGER;
    v_feedback_fqdn           INTEGER;
    v_feedback_ip             INTEGER;
    v_continue                CHAR(1);
    v_is_fqdn                 CHAR(1);
    v_is_numeral              CHAR(1);
    v_is_valid_ip             CHAR(1);
    v_is_valid_phase          CHAR(1);
    v_correct_domain_name     CHAR(1);
    v_valid_domain_name       CHAR(1);
    v_valid_shortname         CHAR(1);
    v_feedback_string         VARCHAR2(128);
    v_sanitized_host_name     VARCHAR2(128);
    v_phase_domain_name       VARCHAR2(128);
    v_param_host_name_isfqdn  VARCHAR2(128);
    v_param_host_name_eval    VARCHAR2(128);
    v_param_domain_name       VARCHAR2(128);
    --hostname_validation       EXCEPTION;
    --fqdn_validation           EXCEPTION;
    --ip_invalid                EXCEPTION;
    --ip_format_invalid         EXCEPTION;
    --shortname_validation      EXCEPTION;
    --not_correct_phase         EXCEPTION;
    --no_valid_domain           EXCEPTION;
    --generic_error             EXCEPTION;
    --idx_internal_check        EXCEPTION;
    --PRAGMA EXCEPTION_INIT     (hostname_validation , -20004);
    --PRAGMA EXCEPTION_INIT     (fqdn_validation     , -20005);
    --PRAGMA EXCEPTION_INIT     (ip_invalid          , -20006);
    --PRAGMA EXCEPTION_INIT     (shortname_validation, -20007);
    --PRAGMA EXCEPTION_INIT     (not_correct_phase   , -20008);
    --PRAGMA EXCEPTION_INIT     (no_valid_domain     , -20009);
    --PRAGMA EXCEPTION_INIT     (generic_error       , -20010);
    --PRAGMA EXCEPTION_INIT     (idx_internal_check  , -20011);
    --PRAGMA EXCEPTION_INIT     (ip_format_invalid   , -20012);
    -- /* Create an varray that allows to set flags for failed checks.                                                  COMMENT */
    -- /* In this way all checks can complete without the need to raise application errors.                             COMMENT */
    -- /* The varray holds all OUT parameters as elements but is only used for the elements ending in "*_validation".   COMMENT */
    -- /* The field "function_value" is superflous, as the OUT parameters themselves are set.                           COMMENT */
    -- /* rec_execution_validation(function_name, function_value, function_severity, function_flag)                     COMMENT */
    --
    y   var_excval :=    var_excval
            (   rec_execution_validation('idx_internal_check', 'X', 'X', 9, 'N')  -- index 1
            ,   rec_execution_validation('numeral_validation', 'X', 'X', 2, 'N')  -- index 2
            ,   rec_execution_validation('ip_validation',      'X', 'X', 1, 'N')  -- index 3
            ,   rec_execution_validation('phase_validation',   'X', 'X', 4, 'N')  -- index 4
            ,   rec_execution_validation('fqdn_validation',    'X', 'X', 4, 'N')  -- index 5
            ,   rec_execution_validation('dname_validation',   'X', 'X', 3, 'N')  -- index 6
            ,   rec_execution_validation('hostname_isfqdn',    'X', 'X', 1, 'N')  -- index 7
            ,   rec_execution_validation('hostname_eval',      'X', 'X', 1, 'N')  -- index 8
            ,   rec_execution_validation('shortname',          'X', 'X', 4, 'N')  -- index 9
            ,   rec_execution_validation('domainname',         'X', 'X', 1, 'N')  -- index 10
            ,   rec_execution_validation('continue',           'Y', 'X', 9, 'N')  -- index 11
            );
    -- /* function idx allows a lookup for the index value in the varray based on a value                               COMMENT */
    FUNCTION idx(p_idx VARCHAR2) RETURN PLS_INTEGER AS
      BEGIN
        FOR i IN 1..y.LAST
          LOOP
            IF (y(i).function_name = p_idx) THEN RETURN i;
            END IF;
          END LOOP;
        RETURN 0;
      END idx;
    --
    PROCEDURE checkmark(p_idx IN INTEGER, p_val IN CHAR) AS
    BEGIN
    	IF y(p_idx).function_name = 'idx_internal_check'                                                                       THEN
    	  RAISE idx_internal_check;
    	END IF;
      IF (y(p_idx).function_value = 'Y' OR y(p_idx).function_value = 'X') OR v_this_object = 'ADMIN_TNSNAMES.EVAL_HOSTNAME.RAISE_SEV'     THEN
         y(idx('continue')).function_executed := 'Y';
         y(p_idx).function_executed           := 'Y';
         y(p_idx).function_value              :=  p_val;
         --
         IF y(idx('continue')).function_value = 'Y' AND p_val = 'N' AND y(p_idx).function_severity > 3                       THEN
           y(idx('continue')).function_value  := 'N';
         END IF;
      END IF;
    END checkmark;
    --
    PROCEDURE raise_sev(p_idx IN INTEGER, p_sev IN CHAR, p_val IN CHAR) AS
    BEGIN
    	tetools.admin_tnsnames.who_called(v_this_object);
    	--
    	IF y(p_idx).function_name = 'idx_internal_check'                                                                       THEN
    	  RAISE idx_internal_check;
    	END IF;
      y(p_idx).function_severity           :=  p_sev;
      checkmark(p_idx, p_val);
    END raise_sev;
  BEGIN
  	--
    tetools.admin_tnsnames.who_called(v_this_object);
    --
    --
    -- /* let's sanitize the incoming hostname from any http[s] header                                                  COMMENT */
    SELECT removehttp(p_hostname) INTO v_sanitized_host_name FROM DUAL;
    --
    --
    -- /* let's check the format of the given hostname if it's a probable and valid IP address                          COMMENT */
    tetools.admin_tnsnames.ipaddress_checker(v_sanitized_host_name, v_count_periods, v_is_numeral, v_is_valid_ip, v_feedback_ip);
    --DBMS_OUTPUT.PUT_LINE('v_feedback_ip: '||v_feedback_ip);
    checkmark(idx('numeral_validation'), v_is_numeral);
    checkmark(idx('ip_validation'), v_is_valid_ip);
    --
    --
    -- /* let's check the given phase if it's a valid phase                                                             COMMENT */
    tetools.admin_tnsnames.phase_checker(v_sanitized_host_name, p_phase, v_is_valid_phase);
    checkmark(idx('phase_validation'), v_is_valid_phase);
    --
    --
    -- /* this is the moneyshot, the bulk of evaluating the hostname takes place in this block                          COMMENT */
    IF y(idx('numeral_validation')).function_value = 'Y' AND y(idx('ip_validation')).function_value = 'N'                    THEN
      -- /* in this case an invalid IP address was given, this should just bug out. 
      raise_sev(idx('ip_validation'), 4, v_is_valid_ip);
    ELSIF y(idx('numeral_validation')).function_value = 'N' AND y(idx('ip_validation')).function_value = 'N'                 THEN
      -- /* below some logic to fugure out what has been given to us as a hostname                                      COMMENT */
      IF v_count_periods >= 4 AND v_is_numeral = 'N'                                                                         THEN
      -- /* let's pass the hosstname and phase to procedure isfqdn to see whether it is a shortname or fully qualified  COMMENT */
        tetools.admin_tnsnames.isfqdn(v_sanitized_host_name, p_phase, p_force, v_is_valid_phase, v_is_fqdn, v_valid_domain_name, v_param_host_name_isfqdn, v_param_domain_name, v_continue, v_feedback_fqdn);
        --
        checkmark(idx('fqdn_validation'), v_is_fqdn);
        checkmark(idx('dname_validation'), v_valid_domain_name);
        checkmark(idx('hostname_isfqdn'), v_param_host_name_isfqdn);
        checkmark(idx('hostname_eval'), v_sanitized_host_name);
        checkmark(idx('domainname'), v_param_domain_name);
        checkmark(idx('continue'), v_continue);
        --
        IF v_continue = 'N'                                                                                                  THEN
          IF v_feedback_fqdn = 20                                                                                            THEN
            p_feedback_string := v_feedback_fqdn;
          ELSIF v_feedback_fqdn = 21                                                                                         THEN
            p_feedback_string := v_feedback_fqdn;
          END IF;
           RAISE not_correct_phase;
        END IF;
      ELSIF v_count_periods < 4 AND v_is_numeral = 'N'                                                                       THEN
        -- /* v_sanitized_host_name _is_ a shortname, this is were we find out.                                       COMMENT */
        -- /* let's check for special characters before we give the ok                                                COMMENT */
        SELECT CASE
                WHEN REGEXP_LIKE(v_sanitized_host_name, '[@!#$%^&*}{:/|><]') THEN 'N'
                  ELSE      'Y'
               END INTO v_valid_shortname
          FROM dual;
        checkmark(idx('shortname'), v_valid_shortname);
        --
        IF v_count_periods = 0 AND v_valid_shortname = 'N'                                                                   THEN
          v_feedback_string := 'name_1';
          p_feedback_string := v_feedback_string;
          --RAISE shortname_validation;
        END IF;
      END IF;
    ELSIF y(idx('numeral_validation')).function_value = 'N' AND y(idx('ip_validation')).function_value = 'Y'                 THEN
      -- /* this is the domain of measuring wtf's p/m and handle the situation accordingly                              COMMENT */
      raise_sev(idx('continue'), 4, 'N');
      RAISE generic_error;
    END IF;
    --
    --
    -- /* retrieve the possible shortname of the hostname given                                                         COMMENT */
    SELECT shortnamer(v_sanitized_host_name) INTO v_param_host_name_eval FROM dual;
    IF v_param_host_name_eval = 'X' OR v_valid_shortname != 'Y'                                                              THEN
      v_valid_shortname := 'N';
    --ELSE
    --  v_valid_shortname := 'Y';
    END IF;
    --
    --
    p_is_numeral            := REGEXP_REPLACE( y(idx('numeral_validation')).function_value, '[[:space:]]', '' );
    p_is_valid_ip           := REGEXP_REPLACE( y(idx('ip_validation')).function_value, '[[:space:]]', '' );
    p_is_valid_phase        := REGEXP_REPLACE( y(idx('phase_validation')).function_value, '[[:space:]]', '' );
    p_is_fqdn               := REGEXP_REPLACE( y(idx('fqdn_validation')).function_value, '[[:space:]]', '' );
    p_is_valid_dname        := REGEXP_REPLACE( y(idx('dname_validation')).function_value, '[[:space:]]', '' );
    p_param_hostname        := REGEXP_REPLACE( y(idx('hostname_isfqdn')).function_value, '[[:space:]]', '' );
    p_param_domain_name     := REGEXP_REPLACE( y(idx('domainname')).function_value, '[[:space:]]', '' );
    p_continue              := REGEXP_REPLACE( y(idx('continue')).function_value, '[[:space:]]', '' );
    --
    IF y(idx('continue')).function_value = 'N'                                                                               THEN
      IF v_feedback_fqdn = 1                                                                                                 THEN
        v_feedback_string := 'fqdn_1';
        --DBMS_OUTPUT.PUT_LINE(v_sanitized_host_name||' registratie heeft een subdomein format.');
        --DBMS_OUTPUT.PUT_LINE('De registratie kan geforceerd opgenomen worden wanneer zeker is dat deze goed is, zie de help functie hiervoor.');
      END IF;
      --
      IF y(idx('numeral_validation')).function_value = 'Y' AND y(idx('ip_validation')).function_value = 'N'                  THEN
        IF v_feedback_ip = 5                                                                                                 THEN
          v_feedback_string := 'ip_5';
          RAISE ip_invalid;
        ELSIF v_feedback_ip >= 4                                                                                             THEN
          v_feedback_string := 'ip_4';
          RAISE generic_error;
        END IF;
        RAISE ip_format_invalid;
      ELSIF y(idx('numeral_validation')).function_value = 'Y' AND y(idx('ip_validation')).function_value = 'Y'               THEN
         v_feedback_string := 'ip_0';
      END IF;
    END IF;
    --
    --
    EXCEPTION
    WHEN fqdn_validation                                                                                                     THEN
      p_feedback_string := v_feedback_string;
      p_continue := v_continue;
      --notify('9265496544', 'fqdn_validation      : ', p_hostname);
    WHEN ip_invalid                                                                                                          THEN
      p_feedback_string := 'ip_5';
      p_continue := v_continue;
      --notify('4552935540', 'ip_invalid           : ', p_hostname);
    WHEN ip_format_invalid                                                                                                   THEN
      IF v_feedback_ip = 1                                                                                                   THEN
        --v_feedback_string := 'IP adres met meer dan 4 octetten? Dat kan niet.';
        v_feedback_string := 'ip_1';
      ELSIF v_feedback_ip = 2                                                                                                THEN
        --v_feedback_string := 'IP adres met minder dan 4 octetten? Dat kan niet.';
        v_feedback_string := 'ip_2';
      ELSIF v_feedback_ip = 3                                                                                                THEN
        --v_feedback_string := 'IP adres wat niet uit cijfers bestaat? Dat kan niet.';
        v_feedback_string := 'ip_3';
      END IF;
      p_feedback_string := v_feedback_string;
      p_continue := v_continue;
      --notify('0422544095', 'ip_format_invalid    : ', p_hostname||': '||v_feedback_string);
    WHEN shortname_validation                                                                                                THEN
      notify('0089443894', 'shortname_validation : ', p_hostname);
      v_feedback_string := 'hn_01';
      p_feedback_string := v_feedback_string;
      p_continue := v_continue;
    WHEN not_correct_phase                                                                                                   THEN
      IF v_feedback_fqdn = 20                                                                                                THEN
        v_feedback_string := 'phase_1';
      ELSIF v_feedback_fqdn = 21                                                                                             THEN
        v_feedback_string := 'phase_2';
      END IF;
      p_feedback_string := v_feedback_string;
      p_continue := v_continue;
      --notify('4552935540', 'not_correct_phase    : ', p_hostname);
    WHEN idx_internal_check                                                                                                  THEN
      p_continue := v_continue;
      notify('6092944524', 'idx_internal_check   : ', p_hostname);
      RAISE;
    WHEN generic_error                                                                                                       THEN
      p_continue := v_continue;
      notify('0904341073', 'generic_error        : ', p_hostname);
      RAISE;
    WHEN OTHERS                                                                                                              THEN
      p_continue := v_continue;
      notify('3491269677', 'others               : ', p_hostname);
      RAISE;
  END eval_hostname;
  --
  -- /* PROCEDURE > validate_tns --------------------------------------------- VALIDATE ALL GIVEN PARAMETERS FOR REGISTERING TNS_ALIAS ----- HEADER */
  --
  PROCEDURE validate_tns ( p_hostname IN VARCHAR2, p_phase IN CHAR, p_force IN CHAR, p_port IN VARCHAR2, p_service_name IN VARCHAR2,
                           p_target_envs IN VARCHAR2, p_is_valid_ip OUT CHAR, p_is_valid_phase OUT CHAR, p_is_fqdn OUT CHAR, p_is_valid_dname OUT CHAR,
                           p_param_hostname OUT VARCHAR2, p_param_domain_name OUT VARCHAR2, p_feedback OUT VARCHAR2, p_is_numeral_port OUT CHAR,
                           p_is_1k OUT CHAR, p_default_port OUT CHAR, p_port_range_expected OUT CHAR, p_continue OUT CHAR )
  AS
    v_this_object             VARCHAR2(128);
    v_count_periods           INTEGER;
    v_feedback_fqdn           INTEGER;
    v_feedback_ip             INTEGER;
    V_DEFAULT_PORT            CHAR(1);
    V_PORT_RANGE_EXPECTED     CHAR(1);
    v_is_1k                   CHAR(1);
    v_continue                CHAR(1);
    v_is_fqdn                 CHAR(1);
    v_is_numeral_name         CHAR(1);
    v_is_numeral_port         CHAR(1);
    v_is_valid_ip             CHAR(1);
    v_is_valid_phase          CHAR(1);
    v_correct_domain_name     CHAR(1);
    v_valid_domain_name       CHAR(1);
    v_valid_shortname         CHAR(1);
    v_feedback_string         VARCHAR2(128);
    v_sanitized_host_name     VARCHAR2(128);
    v_phase_domain_name       VARCHAR2(128);
    v_param_host_name_isfqdn  VARCHAR2(128);
    v_param_host_name_eval    VARCHAR2(128);
    v_param_domain_name       VARCHAR2(128);
    --hostname_validation       EXCEPTION;
    --fqdn_validation           EXCEPTION;
    --ip_invalid                EXCEPTION;
    --ip_format_invalid         EXCEPTION;
    --shortname_validation      EXCEPTION;
    --not_correct_phase         EXCEPTION;
    --no_valid_domain           EXCEPTION;
    --generic_error             EXCEPTION;
    --idx_internal_check        EXCEPTION;
    --PRAGMA EXCEPTION_INIT     (hostname_validation , -20004);
    --PRAGMA EXCEPTION_INIT     (fqdn_validation     , -20005);
    --PRAGMA EXCEPTION_INIT     (ip_invalid          , -20006);
    --PRAGMA EXCEPTION_INIT     (shortname_validation, -20007);
    --PRAGMA EXCEPTION_INIT     (not_correct_phase   , -20008);
    --PRAGMA EXCEPTION_INIT     (no_valid_domain     , -20009);
    --PRAGMA EXCEPTION_INIT     (generic_error       , -20010);
    --PRAGMA EXCEPTION_INIT     (idx_internal_check  , -20011);
    --PRAGMA EXCEPTION_INIT     (ip_format_invalid   , -20012);
    -- /* Create an varray that allows to set flags for failed checks.                                                  COMMENT */
    -- /* In this way all checks can complete without the need to raise application errors.                             COMMENT */
    -- /* The varray holds all OUT parameters as elements but is only used for the elements ending in "*_validation".   COMMENT */
    -- /* The field "function_value" is superflous, as the OUT parameters themselves are set.                           COMMENT */
    -- /* rec_execution_validation(function_name, function_value, function_severity, function_flag)                     COMMENT */
    --
    u   var_excval :=    var_excval
            (   rec_execution_validation('idx_internal_check',  'X', 'X', 9, 'N')  -- index 1
            ,   rec_execution_validation('numeral_validation',  'X', 'X', 2, 'N')  -- index 2
            ,   rec_execution_validation('ip_validation',       'X', 'X', 1, 'N')  -- index 3
            ,   rec_execution_validation('phase_validation',    'X', 'X', 4, 'N')  -- index 4
            ,   rec_execution_validation('fqdn_validation',     'X', 'X', 4, 'N')  -- index 5
            ,   rec_execution_validation('dname_validation',    'X', 'X', 3, 'N')  -- index 6
            ,   rec_execution_validation('hostname_isfqdn',     'X', 'X', 1, 'N')  -- index 7
            ,   rec_execution_validation('hostname_eval',       'X', 'X', 1, 'N')  -- index 8
            ,   rec_execution_validation('shortname',           'X', 'X', 4, 'N')  -- index 9
            ,   rec_execution_validation('domainname',          'X', 'X', 1, 'N')  -- index 10
            ,   rec_execution_validation('numport_validation',  'X', 'X', 1, 'N')  -- index 11
            ,   rec_execution_validation('thousands_validation','X', 'X', 1, 'N')  -- index 12
            ,   rec_execution_validation('port_validation',     'X', 'X', 4, 'N')  -- index 13
            ,   rec_execution_validation('range_validation',    'X', 'X', 1, 'N')  -- index 14
            ,   rec_execution_validation('continue',            'Y', 'Y', 9, 'N')  -- index 15
            );
    -- /* function idx allows a lookup for the index value in the varray based on a value                               COMMENT */
    FUNCTION idx(p_idx VARCHAR2) RETURN PLS_INTEGER AS
      BEGIN
        FOR i IN 1..u.LAST
          LOOP
            IF (u(i).function_name = p_idx) THEN RETURN i;
            END IF;
          END LOOP;
        RETURN 0;
      END idx;
    --
    PROCEDURE checkmark(p_idx IN INTEGER, p_val IN CHAR) AS
    BEGIN
    	IF u(p_idx).function_name = 'idx_internal_check'                                                                       THEN
    	  RAISE idx_internal_check;
    	END IF;
      IF (u(p_idx).function_value = 'Y' OR u(p_idx).function_value = 'X') OR   v_this_object = 'EVAL_HOSTNAME.RAISE_SEV'     THEN
         u(idx('continue')).function_executed := 'Y';
         u(p_idx).function_executed           := 'Y';
         u(p_idx).function_value              :=  p_val;
         --
         IF u(idx('continue')).function_value = 'Y' AND p_val = 'N' AND u(p_idx).function_severity > 3                       THEN
           u(idx('continue')).function_value  := 'N';
         END IF;
      END IF;
    END checkmark;
    --
    PROCEDURE raise_sev(p_idx IN INTEGER, p_sev IN CHAR, p_val IN CHAR) AS
    BEGIN
    	tetools.admin_tnsnames.who_called(v_this_object);
    	--
    	IF u(p_idx).function_name = 'idx_internal_check'                                                                       THEN
    	  RAISE idx_internal_check;
    	END IF;
      u(p_idx).function_severity           :=  p_sev;
      checkmark(p_idx, p_val);
    END raise_sev;
  BEGIN
  	--
    tetools.admin_tnsnames.who_called(v_this_object);
    --
    -- /* first up: let's put the given parameters through our checks and see what's what                               COMMENT */
    tetools.admin_tnsnames.eval_hostname ( p_hostname, p_phase, p_force, v_is_numeral_name, v_is_valid_ip, v_is_valid_phase, v_is_fqdn, v_valid_domain_name, v_feedback_string, v_param_host_name_eval, v_param_domain_name, v_continue);
    p_continue            := v_continue;
    --
    IF v_feedback_string LIKE 'ip%' THEN
      IF v_feedback_string = 'ip_5' THEN
        RAISE ip_invalid;
      ELSE
        RAISE ip_format_invalid;
      END IF;
    ELSIF v_feedback_string LIKE 'hn%' THEN
      RAISE shortname_validation;
    ELSIF v_feedback_string LIKE 'phase%' THEN
      RAISE not_correct_phase;
    END IF;
    --
    --checkmark(idx('numeral_validation'), v_is_numeral_name);           p_numeral           := v_is_numeral_name;
    checkmark(idx('ip_validation'),      v_is_valid_ip);          p_is_valid_ip       := v_is_valid_ip;
    checkmark(idx('phase_validation'),   v_is_valid_phase);       p_is_valid_phase    := v_is_valid_phase;
    checkmark(idx('fqdn_validation'),    v_is_fqdn);              p_is_fqdn           := v_is_fqdn;
    checkmark(idx('dname_validation'),   v_valid_domain_name);    p_is_valid_dname    := v_valid_domain_name;
    checkmark(idx('hostname_eval'),      v_param_host_name_eval); p_param_hostname    := v_param_host_name_eval;
    checkmark(idx('domainname'),         v_param_domain_name);    p_param_domain_name := v_param_domain_name;
    checkmark(idx('continue'),           v_continue);             p_continue          := v_continue;
    p_continue            := v_continue;
    --
    -- /* let's find out what was given as a port                                                                       COMMENT */
    tetools.admin_tnsnames.port_checker( p_port, v_is_numeral_port, v_is_1k, v_default_port, v_port_range_expected, v_continue);
    --          
    checkmark(idx('numport_validation'),   v_is_numeral_port);     p_is_numeral_port     := v_is_numeral_port;
    checkmark(idx('thousands_validation'), v_is_1k);               p_is_1k               := v_is_1k;
    checkmark(idx('port_validation'),      v_default_port);        p_default_port        := v_default_port;
    checkmark(idx('range_validation'),     v_port_range_expected); p_port_range_expected := v_port_range_expected;
    checkmark(idx('continue'),             v_continue);            
    p_continue            := v_continue;
    --
    EXCEPTION
    WHEN fqdn_validation                                                                                                     THEN
      notify('9265496544', 'fqdn_validation      : ', p_hostname);
      RAISE;
    WHEN ip_invalid                                                                                                          THEN
      --notify('4552935540', 'ip_invalid           : ', p_hostname);
      v_feedback_string := 'IP adres qua format juist, maar is qua octet-waarde ongeldig.';
      p_feedback := v_feedback_string;
      --RAISE;
    WHEN ip_format_invalid                                                                                                   THEN
      IF v_feedback_string = 'ip_1'                                                                                           THEN
        v_feedback_string := 'IP adres met meer dan 4 octetten? Dat kan niet.';
      ELSIF v_feedback_string = 'ip_2'                                                                                        THEN
        v_feedback_string := 'IP adres met minder dan 4 octetten? Dat kan niet.';
      ELSIF v_feedback_string = 'ip_3'                                                                                        THEN
        v_feedback_string := 'IP adres wat niet uit cijfers bestaat? Dat kan niet.';
      END IF;
      --notify('0422544095', 'ip_format_invalid    : ', p_hostname||': '||v_feedback_string);
      p_feedback := v_feedback_string;
      --RAISE;
    WHEN shortname_validation                                                                                                THEN
      --notify('0089443894', 'shortname_validation : ', p_hostname);
      v_feedback_string := 'De opgegeven shortname (hostname) kon niet worden gevalideerd.';
      p_feedback := v_feedback_string;
      --RAISE;
    WHEN not_correct_phase                                                                                                   THEN
      --notify('4552935540', 'not_correct_phase    : ', p_hostname);
      IF v_feedback_string = 'phase_1'                                                                                       THEN
        v_feedback_string := 'De opgegeven fase is niet in gebruik binnen IV-GD.';
      ELSIF v_feedback_string = 'phase_2'                                                                                    THEN
        v_feedback_string := 'De opgegeven fase van de hostnaam is niet in gebruik binnen IV-GD.';
      END IF;
      p_feedback := v_feedback_string;
      --RAISE;
    WHEN idx_internal_check                                                                                                  THEN
      notify('6092944524', 'idx_internal_check   : ', p_hostname);
      RAISE;
    WHEN generic_error                                                                                                       THEN
      notify('0904341073', 'generic_error        : ', p_hostname);
      RAISE;
    WHEN OTHERS                                                                                                              THEN
      notify('5157279616', 'others               : ', p_hostname);
      notify('5157279616', v_this_object, DBMS_UTILITY.format_error_stack);
      RAISE;
  END validate_tns;
--
  PROCEDURE register_tns ( p_tns_alias IN VARCHAR2, p_target_phase IN CHAR, p_target_envs IN VARCHAR2, p_host_name IN VARCHAR2, p_service_name IN VARCHAR2, p_port IN NUMBER,
                           p_date_valid_from IN VARCHAR2 DEFAULT SYSDATE, p_description IN VARCHAR2 DEFAULT NULL, p_date_valid_end IN VARCHAR2 DEFAULT '9999-12-31', p_connect_timeout IN NUMBER DEFAULT NULL,
                           p_retry_delay IN NUMBER DEFAULT NULL, p_retry_count IN NUMBER DEFAULT NULL, p_failover IN VARCHAR2 DEFAULT NULL, p_load_balance IN VARCHAR2 DEFAULT NULL, p_force IN CHAR DEFAULT 'N' )
  AS
    v_this_object            VARCHAR2(128);
    --
    v_crud                   CHAR(1);
    v_tns_id                 INTEGER;
    v_tns_id_OUT             INTEGER;
    v_tns_alias              VARCHAR2(128)       := p_tns_alias ;       --  := 'crud_test03';
    v_target_phase           CHAR(1)             := p_target_phase ;    --  := 'T';
    v_target_envs            VARCHAR2(128)       := p_target_envs ;     --  := 'DTA';
    v_hostname               VARCHAR2(128)       := p_host_name ;       --  := 'crud_host02';
    v_servicename            VARCHAR2(128)       := p_service_name ;    --  := 'service02';
    v_port                   NUMBER              := p_port ;            --  := 1521;
    v_date_valid_from        VARCHAR2(128)       := p_date_valid_from ; --  := '2024-09-16';
    v_description            VARCHAR2(256)       := p_description ;     --  := 'TEST description 2';
    v_date_valid_end         VARCHAR2(128)       := p_date_valid_end ;  --  := '2099-01-01';
    v_connect_timeout        NUMBER              := p_connect_timeout ;
    v_retry_delay            NUMBER              := p_retry_delay;
    v_retry_count            NUMBER              := p_retry_count ;
    v_failover               VARCHAR2(5)         := p_failover ;
    v_load_balance           VARCHAR2(5)         := p_load_balance ;
    v_force                  CHAR(1)             := p_force ;           --  := 'N';
    --
    v_is_numeral             CHAR(1);
    v_phase                  CHAR(1);
    v_phase_out              CHAR(1);
    v_does_exist             CHAR(1);
    v_json                   VARCHAR2(4000);
    i                        NUMBER              := 0;
    v_is_valid_ip            CHAR(1);
    v_is_valid_phase         CHAR(1);
    v_is_fqdn                CHAR(1);
    v_is_valid_dname         CHAR(1);
    v_param_hostname         VARCHAR2(128);
    v_param_domain_name      VARCHAR2(128);
    v_feedback               VARCHAR2(128);
    v_is_numeral_port        CHAR(1);
    v_is_1k                  CHAR(1);
    v_default_port           CHAR(1);
    v_port_range_expected    CHAR(1);
    v_continue               CHAR(1);
    v_hostname_out           VARCHAR2(128);
    v_servicename_out        VARCHAR2(128);
    --
    v_status                 VARCHAR2(11);
    v_role                   VARCHAR(2000);
    --
    --wrong_crud               EXCEPTION;
    --operation_halted         EXCEPTION;
    --generic_error            EXCEPTION;
    --idx_internal_check       EXCEPTION;
    --PRAGMA EXCEPTION_INIT    (wrong_crud          , -20020);
    --PRAGMA EXCEPTION_INIT    (operation_halted    , -20019);
    --PRAGMA EXCEPTION_INIT    (generic_error       , -20010);
    --PRAGMA EXCEPTION_INIT    (idx_internal_check  , -20011);
  BEGIN
  	--
    tetools.admin_tnsnames.who_called(v_this_object);
  	--
    tetools.admin_tnsnames.tnsnames_status(v_status,v_role,v_continue);
    --
    tetools.admin_tnsnames.query_tns(v_tns_alias, v_target_phase, v_does_exist);
    --
    tetools.admin_tnsnames.existing_tns(v_tns_alias, v_target_phase, v_crud, v_tns_id, v_does_exist, v_phase_out, v_hostname_out, v_servicename_out);
    --
    tetools.admin_tnsnames.validate_tns( v_hostname           ,
                                         v_target_phase       ,
                                         v_force              ,
                                         v_port               ,
                                         v_servicename        ,
                                         v_target_envs        ,
                                         v_is_valid_ip        ,
                                         v_is_valid_phase     ,
                                         v_is_fqdn            ,
                                         v_is_valid_dname     ,
                                         v_param_hostname     ,
                                         v_param_domain_name  ,
                                         v_feedback           ,
                                         v_is_numeral_port    ,
                                         v_is_1k              ,
                                         v_default_port       ,
                                         v_port_range_expected,
                                         v_continue
                                       );
    --
    SELECT JSON_OBJECT('crud'                 VALUE v_crud,
                       'tns_id'               VALUE v_tns_id,
                       'tns_alias'            VALUE v_tns_alias,
                       'target_phase'         VALUE v_target_phase,
                       'target_envs'          VALUE v_target_envs,
                       'host_name'            VALUE v_hostname,
                       'service_name'         VALUE v_servicename,
                       'port'                 VALUE v_port,
                       'date_valid_end'       VALUE v_date_valid_end,
                       'description'          VALUE v_description,
                       'date_valid_from'      VALUE v_date_valid_from,
                       'connect_timeout'      VALUE v_connect_timeout,
                       'retry_delay'          VALUE v_retry_delay,
                       'retry_count'          VALUE v_retry_count,
                       'failover'             VALUE v_failover,
                       'load_balance'         VALUE v_load_balance,
                       'forced'               VALUE v_force,
                       'dname_validation'     VALUE v_is_valid_dname,
                       'domainname'           VALUE v_param_domain_name,
                       'fqdn_validation'      VALUE v_is_fqdn,
                       'ip_validation'        VALUE v_is_valid_ip,
                       'numeral_validation'   VALUE v_is_numeral,
                       'numport_validation'   VALUE v_is_numeral,
                       'phase_validation'     VALUE v_is_valid_phase,
                       'port_validation'      VALUE v_default_port,
                       'range_validation'     VALUE v_port_range_expected,
                       'shortname'            VALUE v_param_hostname,
                       'thousands_validation' VALUE v_is_1k,
                       'feedback'             VALUE v_feedback,
                       'continue'             VALUE v_continue)
           INTO v_json
      FROM dual;
    --
    
    --
    IF v_does_exist = 'Y' AND v_continue = 'Y' THEN
      IF v_crud = 'C' THEN
        --tetools.admin_tnsnames.report_existing ( v_tns_alias, v_does_exist, v_target_phase, v_hostname, v_servicename );
        NULL;
      ELSIF v_crud = 'U' THEN
        --
        tetools.admin_tnsnames.crud(v_json, v_tns_id);
        --tetools.admin_tnsnames.report_registration(v_json, v_tns_id);
        NULL;
      END IF;
    ELSIF v_does_exist = 'N' AND v_continue = 'Y' THEN
      v_crud := 'C';
      --
      tetools.admin_tnsnames.crud(v_json, v_tns_id_OUT);
      --
      SELECT JSON_TRANSFORM( v_json, replace '$.tns_id' = v_tns_id_OUT create on missing ) INTO v_json FROM DUAL;
      --
      --tetools.admin_tnsnames.report_registration(v_json, v_tns_id_OUT);
      NULL;
    ELSE
      RAISE operation_halted;
    END IF;
    --
    EXCEPTION
    WHEN wrong_crud           THEN
      --tetools.admin_tnsnames.report_existing ( v_tns_alias, v_does_exist, v_target_phase, v_hostname, v_servicename );
      NULL;
    WHEN operation_halted     THEN
      tetools.admin_tnsnames.report_status(v_status, v_role, v_continue, v_feedback);
    WHEN generic_error        THEN
      notify('0089443894', v_this_object, DBMS_UTILITY.format_error_stack);
      RAISE;
    WHEN OTHERS               THEN
      notify('1240988336', v_this_object, DBMS_UTILITY.format_error_stack);
      RAISE;
  END register_tns;
  --
END admin_tnsnames;
/



