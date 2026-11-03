CREATE OR REPLACE PACKAGE tetools.admin_logger AUTHID DEFINER 
IS
  -- VER SPEC VERSION 20261013_500_PROPOSAL_027
  --B-  /* ======================================================================================================= */
  --B-  --
  --B-  -- BANNER FOR PACKAGE TETOOLS.ADMIN_LOGGER
  --B-  --
  --B-  /* ------------------------------------------------------------------------------------------------------- */
  --B-  
  --B-    Package name:  ADMIN_LOGGER
  --B-     Author:       JPouwiel
  --B-     Version:      0.3
  --B-     Purpose:      Provide a comprehensive logging tool
  --B-     Parameters:   Depends on procedure/function called
  --B-  
  --B-    History     
  --B-    Version  Date       Changed by     Remark
  --B-    -------- ---------- -------------- ------------------------------------
  --B-         0.1 2026.05.27 JPouwiel       Setup of package
  --B-         0.2 2026.06.11 JPouwiel       Added functionality to package to control debug settings via table.
  --B-         0.3 2026.07.22 JPouwiel       Altered package to use toggle procedures instead DML operations for config.
  --B-         0.4 2026.09.07 JPouwiel       Added session state backup procedure, debugged override target
  --B-   
  --B-  /* ======================================================================================================= */
  --
  --HS-  /* ======================================================================================================= */
  --HS-  --
  --HS-  -- HELP / USAGE SCENARIOS FOR PACKAGE TETOOLS.ADMIN_LOGGER
  --HS-  --
  --HS-  /* ------------------------------------------------------------------------------------------------------- */
  --HS-  
  --HS-   DISPLAY THIS HELP SECTION
  --HS-   -----------------------------------------------------------------------
  --HS-   exec TETOOLS.ADMIN_LOGGER.help[(verbose => 'N/Y')]; --DEFAULT = No
  --HV-   
  --HV-   DESCRIPTION OF:  TETOOLS.ADMIN_LOGGER.help
  --HV-   -----------------------------------------------------------------------
  --HV-   The [help] procedure will display usage scenarios and examples of the procedures contained within the 
  --HV-   [ADMIN_LOGGER] package which are made public via the header.
  --HV-   
  --HV-   ACCEPTED PARAMETERS FOR:  TETOOLS.ADMIN_LOGGER.help
  --HV-   -----------------------------------------------------------------------
  --HV-   verbose: 'Y'
  --HV-   verbose: 'N' -- Default.
  --HV-   
  --HV-   --  The [help] procedure takes one (1) parameter < verbose >. Using this parameter, the user may choose whether
  --HV-       to display the extended help/usage information contained in the specification of the header.
  --HV-   
  --HV-   (SAMPLE) OUTPUT OF:  TETOOLS.ADMIN_LOGGER.help
  --HV-   -----------------------------------------------------------------------
  --HV-
  --HV-       --HS-   DISPLAY THIS HELP SECTION
  --HV-       --HS-   -----------------------------------------------------------------------
  --HV-       --HS-   exec TETOOLS.ADMIN_LOGGER.help[(verbose => 'N/Y')]; --DEFAULT = No
  --HV-       --HS-   
  --HV-       --HV-   DESCRIPTION OF:  TETOOLS.ADMIN_LOGGER.help
  --HV-       --HV-   -----------------------------------------------------------------------
  --HV-       --HV-   The [help] procedure will display usage scenarios and examples of the procedures contained within the 
  --HV-       --HV-   [ADMIN_LOGGER] package which are made public via the header.
  --HV-       --HV-   The [help] procedure takes one (1) parameter < verbose >. Using this parameter, the user may choose whether
  --HV-       --HV-   to display the extended help/usage information contained in the specification of the header.
  --HV-   
  --HS-  
  --HS-  
  --HS-   DISPLAY THE PACKAGE BANNER
  --HS-   -----------------------------------------------------------------------
  --HS-   exec TETOOLS.ADMIN_LOGGER.banner;
  --HV-   
  --HV-   DESCRIPTION OF:  TETOOLS.ADMIN_LOGGER.banner
  --HV-   -----------------------------------------------------------------------
  --HV-   The [banner] procedure will display the details and specifications of the physical package itself.
  --HV-   banner takes no parameters and displays source; first-reference package initialization still applies.
  --HV-   
  --HV-   ACCEPTED PARAMETERS FOR:  TETOOLS.ADMIN_LOGGER.banner
  --HV-   -----------------------------------------------------------------------
  --HV-   The [banner] procedure does NOT take any parameters
  --HV-   
  --HV-   (SAMPLE) OUTPUT OF:  TETOOLS.ADMIN_LOGGER.banner
  --HV-   -----------------------------------------------------------------------
  --HV-
  --HV-     /* ======================================================================================================= */
  --HV-     --
  --HV-     -- BANNER FOR PACKAGE TETOOLS.ADMIN_LOGGER
  --HV-     --
  --HV-     /* ------------------------------------------------------------------------------------------------------- */
  --HV-   
  --HV-       Package name:  ADMIN_LOGGER
  --HV-        Author:       TET
  --HV-        Version:      0.3
  --HV-        Purpose:      Provide a comprehensive logging tool
  --HV-        Parameters:   Depends on procedure being called. Execute TETOOLS.ADMIN_LOGGER.help for usage examples.
  --HV-   
  --HV-       History
  --HV-       Version  Date       Changed by     Remark
  --HV-       -------- ---------- -------------- --------------------
  --HV-            0.1 2026.05.27 JPouwiel       Setup package
  --HV-            0.2 2026.06.11 JPouwiel       Added functionality to package to control debug settings via table.
  --HV-            0.3 2026.07.22 JPouwiel       Altered package to use toggle procedures instead DML operations for config.
  --HV-            0.4 2026.09.07 JPouwiel       Added session state backup procedure, debugged override target
  --HV-   
  --HV-     /* ======================================================================================================= */
  --HV-
  --HS-
  --HS-
  --HS- SHC  DISPLAY CONFIGURATION FOR CURRENT SESSION
  --HS- SHC  ---------------------------------------------------------------------------------------------------------------
  --HS- SHC  exec tetools.admin_logger.show_config;
  --HV- SHC  
  --HV- SHC  DESCRIPTION OF:  TETOOLS.ADMIN_LOGGER.show_config
  --HV- SHC  -----------------------------------------------------------------------
  --HV- SHC  The [show_config] procedure will display the details and configuration for the current session.
  --HV- SHC  show_config loads validated state (including required repair) and displays it; HELP is optional.
  --HV- SHC  
  --HV- SHC  ACCEPTED PARAMETERS FOR:  TETOOLS.ADMIN_LOGGER.show_config
  --HV- SHC  -----------------------------------------------------------------------
  --HV- SHC  The [show_config] procedure does take ONE parameter: 'HELP' or none.
  --HV- SHC  
  --HV- SHC  (SAMPLE) OUTPUT OF:  TETOOLS.ADMIN_LOGGER.show_config
  --HV- SHC  -----------------------------------------------------------------------
  --HV- SHC    
  --HV- SHC    CURRENT LOGGING SETTINGS FOR TETOOLS
  --HV- SHC    CONFIG_KEY     VALUE
  --HV- SHC    -------------- -------------------------
  --HV- SHC    logsession_id  92
  --HV- SHC    sid            249
  --HV- SHC    serial#        51386
  --HV- SHC    audsid         35826884
  --HV- SHC    logon_user     TETOOLS
  --HV- SHC    batch_mode     S
  --HV- SHC    LogBatch ID    0
  --HV- SHC    current_user   TETOOLS
  --HV- SHC    current_schema TETOOLS
  --HV- SHC    proxy_user
  --HV- SHC    logon_time     2026-07-22 07:45:03
  --HV- SHC    logging        FALSE
  --HV- SHC    logging_target LOGGING TABLE
  --HV- SHC    debug          FALSE
  --HV- SHC    debug_target   LOGGING TABLE
  --HV- SHC      
  --HV- SHC    When calling any function/procedure in the ADMIN_LOGGER package, the calling session is registered into the
  --HV- SHC    TETOOLS.ADMIN_LOGGER_CONFIG and TETOOLS.ADMIN_LOGGER_SESSIONS tables.
  --HV- SHC    Although initially registered, the registration is per default disabled, and must be enabled or forced.
  --HV-
  --HS-
  --HS-
  --HS- CSE  CLEAR SESSION ENTRIES
  --HS- CSE  -------------------------------------------------------------------------------------------------------
  --HS- CSE  exec TETOOLS.ADMIN_LOGGER.clear_session_entries[(before_in => '<DATE>')]; --DEFAULT = NULL
  --HV- CSE   
  --HV- CSE  DESCRIPTION OF:  TETOOLS.ADMIN_LOGGER.clear_session_entries
  --HV- CSE  -----------------------------------------------------------------------
  --HV- CSE  The [clear_session_entries] purges the TETOOLS.ADMIN_LOGGER_CONFIG and TETOOLS.ADMIN_LOGGER_SESSIONS tables.
  --HV- CSE  This procedure takes one optional parameter.
  --HV- CSE  Use TRUNC(input); remove inactive sessions with logon day < cutoff minus 3 days.
  --HV- CSE  If the parameter is omitted, it defaults to the current date.
  --HV- CSE  
  --HV- CSE  ACCEPTED PARAMETERS FOR:  TETOOLS.ADMIN_LOGGER.clear_session_entries
  --HV- CSE  -----------------------------------------------------------------------
  --HV- CSE  Accept YYYY-MM-DD, YYYY-MM-DD HH24:MI:SS, or HELP. NULL uses today.
  --HV- CSE  
  --HV- CSE  (SAMPLE) USAGE OF:  TETOOLS.ADMIN_LOGGER.clear_session_entries;
  --HV- CSE  -------------------------------------------------------------------------------------------------------
  --HV- CSE    SELECT COUNT(*) FROM admin_logger_config;
  --HV- CSE    COUNT(*)
  --HV- CSE    ----------
  --HV- CSE            29
  --HV- CSE    
  --HV- CSE    SQL> exec tetools.admin_logger.clear_session_entries('2026-07-22');
  --HV- CSE    
  --HV- CSE    SELECT COUNT(*) FROM admin_logger_config;
  --HV- CSE    COUNT(*)
  --HV- CSE    ----------
  --HV- CSE            25
  --HV- CSE    
  --HV- CSE    SQL> exec tetools.admin_logger.clear_session_entries;
  --HV- CSE    
  --HV- CSE    PL/SQL procedure successfully completed.
  --HV- CSE    
  --HV- CSE    SELECT COUNT(*) FROM admin_logger_config;
  --HV- CSE    COUNT(*)
  --HV- CSE    ----------
  --HV- CSE             2
  --HV- CSE  
  --HS-
  --HS-
  --HS- CLS  CLEAR LOGGER SESSIONS
  --HS- CLS  -------------------------------------------------------------------------------------------------------
  --HS- CLS  exec TETOOLS.ADMIN_LOGGER.clear_log_entries[(before_in => '<DATE>')]; --DEFAULT = NULL
  --HV- CLS   
  --HV- CLS  DESCRIPTION OF:  TETOOLS.ADMIN_LOGGER.clear_log_entries
  --HV- CLS  -----------------------------------------------------------------------
  --HV- CLS  clear_log_entries removes rows from ADMIN_LOGGER_LOG; it excludes configured active batches.
  --HV- CLS  The [clear_log_entries] procedure takes one (1) optional parameter,
  --HV- CLS  Delete created_on <= midnight of the cutoff day. This does not delete the entire cutoff day.
  --HV- CLS  If the parameter is omitted, it defaults to the current date.
  --HV- CLS  
  --HV- CLS  ACCEPTED PARAMETERS FOR:  TETOOLS.ADMIN_LOGGER.clear_log_entries
  --HV- CLS  -----------------------------------------------------------------------
  --HV- CLS  Accept YYYY-MM-DD, YYYY-MM-DD HH24:MI:SS, or HELP. NULL uses today.
  --HV- CLS  
  --HV- CLS  (SAMPLE) USAGE OF:  TETOOLS.ADMIN_LOGGER.clear_log_entries;
  --HV- CLS  -------------------------------------------------------------------------------------------------------
  --HV- CLS    SELECT COUNT(*) FROM admin_logger_config;
  --HV- CLS    COUNT(*)
  --HV- CLS    ----------
  --HV- CLS            29
  --HV- CLS    
  --HV- CLS    SQL> exec tetools.admin_logger.clear_log_entries('2026-07-22');
  --HV- CLS    
  --HV- CLS    SELECT COUNT(*) FROM admin_logger_config;
  --HV- CLS    COUNT(*)
  --HV- CLS    ----------
  --HV- CLS            25
  --HV- CLS    
  --HV- CLS    SQL> exec tetools.admin_logger.clear_log_entries;
  --HV- CLS    
  --HV- CLS    PL/SQL procedure successfully completed.
  --HV- CLS    
  --HV- CLS    SELECT COUNT(*) FROM admin_logger_config;
  --HV- CLS    COUNT(*)
  --HV- CLS    ----------
  --HV- CLS             2
  --HV- CLS  
  --HS-   
  --HS-   
  --HS- TLO  TOGGLE LOGGER ON/OFF
  --HS- TLO  -------------------------------------------------------------------------------------------------------
  --HS- TLO  exec tetools.admin_logger.toggle_logging (modus => 'ON',  send_log_to_in => ['S' / 'T']); --DEFAULT = 'T'
  --HV- TLO   
  --HV- TLO  DESCRIPTION OF:  TETOOLS.ADMIN_LOGGER.toggle_logging
  --HV- TLO  -----------------------------------------------------------------------
  --HV- TLO  The [toggle_logging] stores the log setting in the TETOOLS.ADMIN_LOGGER_CONFIG and TETOOLS.ADMIN_LOGGER_SESSIONS tables.
  --HV- TLO  The [toggle_logging] procedure takes two (2) parameters, it modifies the registration values in the mentioned tables.
  --HV- TLO  
  --HV- TLO  ACCEPTED PARAMETERS FOR:  TETOOLS.ADMIN_LOGGER.toggle_logging
  --HV- TLO  -----------------------------------------------------------------------
  --HV- TLO  The [toggle_logging] procedure takes two (2) parameters:
  --HV- TLO  The [modus] parameter takes 'ON' or 'OFF' as argument. 'ON' being the default.
  --HV- TLO  The [send_log_to_in] parameter takes 'T' (table) or 'S' (screen) as argument. 'T' being the default.
  --HV- TLO  
  --HV- TLO  (SAMPLE) USAGE OF:  TETOOLS.ADMIN_LOGGER.toggle_logging;
  --HV- TLO  -------------------------------------------------------------------------------------------------------
  --HV- TLO    exec tetools.admin_logger.toggle_logging (modus => 'ON',  send_log_to_in => 'S');
  --HV- TLO    PL/SQL procedure successfully completed.
  --HV- TLO  
  --HS-   
  --HS-   
  --HS- TLD  TOGGLE LOGGER DEBUG MODE ON/OFF
  --HS- TLD  -------------------------------------------------------------------------------------------------------
  --HS- TLD  exec ADMIN_LOGGER.toggle_debug (modus => 'ON', set_debug_target => ['S' / 'T']); --DEFAULT = 'S'
  --HV- TLD   
  --HV- TLD  DESCRIPTION OF:  TETOOLS.ADMIN_LOGGER.toggle_debug
  --HV- TLD  -----------------------------------------------------------------------
  --HV- TLD  The [toggle_debug] stores the debug setting in the TETOOLS.ADMIN_LOGGER_CONFIG and TETOOLS.ADMIN_LOGGER_SESSIONS tables.
  --HV- TLD  The [toggle_debug] procedure takes two (2) parameters, it modifies the registration values in the mentioned tables.
  --HV- TLD  
  --HV- TLD  ACCEPTED PARAMETERS FOR:  TETOOLS.ADMIN_LOGGER.toggle_debug
  --HV- TLD  -----------------------------------------------------------------------
  --HV- TLD  The [toggle_debug] procedure takes two (2) parameters:
  --HV- TLD  The [modus] parameter takes 'ON' or 'OFF' as argument. 'OFF' being the default.
  --HV- TLD  The [set_debug_target] parameter takes 'T' (table) or 'S' (screen) as argument. 'S' being the default.
  --HV- TLD  
  --HV- TLD  (SAMPLE) USAGE OF:  TETOOLS.ADMIN_LOGGER.toggle_debug;
  --HV- TLD  -------------------------------------------------------------------------------------------------------
  --HV- TLD    exec ADMIN_LOGGER.toggle_debug (modus => 'ON', set_debug_target => 'T');
  --HV- TLD    PL/SQL procedure successfully completed.
  --HV- TLD  
  --HS-   
  --HS-   
  --HS- LOG  LOG DATA USING LOG_RUNTIME / LOG_INFO / LOG_WARNING / LOG_ERROR
  --HS- LOG  -------------------------------------------------------------------------------------------------------
  --HS- LOG  exec LOG_RUNTIME       (context_in => '<MODULE>', data_in => '<MESSAGE>');
  --HS- LOG  exec LOG_INFO          (context_in => '<MODULE>', data_in => '<MESSAGE>');
  --HS- LOG  exec LOG_WARNING       (context_in => '<MODULE>', data_in => '<MESSAGE>');
  --HS- LOG  exec LOG_ERROR         (context_in => '<MODULE>', data_in => '<MESSAGE>');
  --HS- LOG  exec LOG_RUNTIME_FORCE (context_in => '<MODULE>', data_in => '<MESSAGE>');
  --HS- LOG  exec LOG_INFO_FORCE    (context_in => '<MODULE>', data_in => '<MESSAGE>');
  --HS- LOG  exec LOG_WARNING_FORCE (context_in => '<MODULE>', data_in => '<MESSAGE>');
  --HS- LOG  exec LOG_ERROR_FORCE   (context_in => '<MODULE>', data_in => '<MESSAGE>');
  --HV- LOG   
  --HV- LOG  DESCRIPTION OF:  TETOOLS.ADMIN_LOGGER.log_*[_*]
  --HV- LOG  -----------------------------------------------------------------------
  --HV- LOG  The procedures [LOG_RUNTIME], [LOG_INFO], [LOG_WARNING], and [LOG_ERROR], as well as their counterparts [LOG_*_FORCE],
  --HV- LOG  can be used to write log messages to the [ADMIN_LOGGER_LOG] table, where the each procedure will log the messages using
  --HV- LOG  the distincive name component as log-category. The [LOG_*_FORCE] counterparts will log the messages despite the status
  --HV- LOG  of the session configuration.
  --HV- LOG  
  --HV- LOG  FORCE always targets the table. Normal non-DEBUG calls use debug_target when debug is ON, otherwise logger_target.
  --HV- LOG  DEBUG writes only when debug is ON. Log functions return 1 for normal call completion, not as a stored-row receipt.
  --HV- LOG  
  --HV- LOG  ACCEPTED PARAMETERS FOR:  TETOOLS.ADMIN_LOGGER.log_*[_*]
  --HV- LOG  -----------------------------------------------------------------------
  --HV- LOG  Log procedures take context_in and data_in; DATE overloads also accept format_in.
  --HV- LOG  The [context] parameter takes a string as argument. Internally this is set to the codeblock calling the [log_*[_*]] procedure.
  --HV- LOG  The [data_in] parameter, due to overloading, takes a VARCHAR2, BOOLEAN, CLOB, or DATE type. The body of the message goes here.
  --HV- LOG  Use toggle_batch(ON,BATCH) to start or preserve a group; OFF or ON,SINGLE ends it.
  --HV- LOG  Single table rows use NULL batch metadata. Batch counters count stored normal table rows only.
  --HV- LOG  
  --HV- LOG  (SAMPLE) USAGE OF:  TETOOLS.ADMIN_LOGGER.log_runtime_force;
  --HV- LOG  -------------------------------------------------------------------------------------------------------
  --HV- LOG  DECLARE
  --HV- LOG    l_context                VARCHAR2(128) := $$PLSQL_UNIT
  --HV- LOG    --
  --HV- LOG    CURSOR c_query(p_parameter IN VARCHAR2) IS
  --HV- LOG      SELECT something
  --HV- LOG        FROM another
  --HV- LOG       WHERE onething = p_parameter
  --HV- LOG         ORDER BY 1 ASC;
  --HV- LOG  BEGIN
  --HV- LOG    DBMS_LOB.CREATETEMPORARY(v_full_clob,TRUE);
  --HV- LOG    DBMS_LOB.OPEN(v_full_clob, DBMS_LOB.LOB_READWRITE);
  --HV- LOG    DBMS_LOB.append(v_full_clob, v_caller||':: '||CHR(10));
  --HV- LOG    --
  --HV- LOG    FOR r_row IN c_query(l_context)
  --HV- LOG    LOOP
  --HV- LOG      DBMS_LOB.append(v_full_clob, REPLACE(r_row.text,',',', '));
  --HV- LOG    END LOOP;
  --HV- LOG    --
  --HV- LOG    tetools.admin_logger.log_runtime_force (l_context, v_full_clob);      -- THIS IS THE LOGGING ACTION
  --HV- LOG    --
  --HV- LOG    DBMS_LOB.CLOSE(lob_loc => v_full_clob);
  --HV- LOG    DBMS_LOB.FREETEMPORARY(lob_loc => v_full_clob);
  --HV- LOG  END;
  --HV- LOG  
  --HV- LOG  Normal calls with debug ON use debug_target; FORCE still targets the table.
  --HV- LOG  Explicitly enable debug to send normal output to screen.
  --HV- LOG  
  --HV- LOG  CASE: exec ADMIN_LOGGER.toggle_debug (modus => 'ON', set_debug_target => 'T');
  --HV- LOG    Then the messages will be written to the logging table.
  --HV-   
  --HS-   
  --HS- 
  --HS-  /* ======================================================================================================= */
  --
  --HS- TBI  BATCH MODE
  --HS- TBI  exec tetools.admin_logger.toggle_batch('ON','BATCH');
  --HV- TBI  Repeated ON preserves a valid active batch. OFF or ON,SINGLE ends it.
  --HV- SHC  p_settings_id in a status function asserts the current config_id; another ID is rejected.
  --HV- SHC  Backup/restore requires a non-NULL five-character key; nested backup is rejected.
  --HV- SHC  Session repair stores an incident and uses safe OFF defaults for a replacement registration.
  -- CONSTANTS
  --
  -- 
  c_true                    CONSTANT BOOLEAN        := TRUE;
  c_false                   CONSTANT BOOLEAN        := FALSE;
  c_on                      CONSTANT VARCHAR2 (2)   := 'ON';
  c_off                     CONSTANT VARCHAR2 (3)   := 'OFF';
  c_y                       CONSTANT VARCHAR2 (1)   := 'Y';
  c_n                       CONSTANT VARCHAR2 (1)   := 'N';
  c_b                       CONSTANT CHAR (1)       := 'B';
  c_s                       CONSTANT CHAR (1)       := 'S';
  c_batch                   CONSTANT CHAR (5)       := 'BATCH';
  c_single                  CONSTANT CHAR (6)       := 'SINGLE';
  c_date_mask               CONSTANT VARCHAR2 (30)  := 'YYYY-MM-DD HH24:MI:SS' ;
  c_to_screen               CONSTANT CHAR (1)       := 'S';
  c_to_table                CONSTANT CHAR (1)       := 'T';
  c_helpme                  CONSTANT VARCHAR2 (4)   := 'HELP';
  g_debug_on                CONSTANT BOOLEAN        := c_false;
  g_logging_target          CONSTANT CHAR (1)       := c_to_table;
  g_debug_target            CONSTANT CHAR (1)       := c_to_screen;
  g_override_target         CONSTANT CHAR (1)       := c_to_table;
  g_session_recovery_busy            BOOLEAN        := FALSE;
  --
  -- TYPES
  --
  --
  SUBTYPE maxvarchar2     IS          VARCHAR2 (32767)                     ; 
  TYPE    maxvarchar2_aat IS TABLE OF VARCHAR2 (32767) INDEX BY PLS_INTEGER; 
  --
  --  FUNCTIONS
  --
  --
  -- /* FUNCTION > get_invoking_sid ------------------------------------------------------------------ INVOKING_SID ----- */
  --
  FUNCTION get_invoking_sid RETURN NUMBER;
  --
  -- /* FUNCTION > get_invoking_serial ----------------------------------------------------------- INVOKING_SERIAL# ----- */
  --
  FUNCTION get_invoking_serial RETURN NUMBER;
  --
  -- /* FUNCTION > get_logon_time ---------------------------------------------------------------------- LOGON_TIME ----- */
  --
  FUNCTION get_logon_time ( p_sid IN NUMBER, p_serial IN NUMBER ) RETURN DATE;
  --
  -- /* FUNCTION > get_audsid ------------------------------------------------------------------------------ AUDSID ----- */
  --
  FUNCTION get_audsid ( p_sid IN NUMBER, p_serial IN NUMBER ) RETURN NUMBER;
  --  
  -- /* FUNCTION > logging_is_on ------------------------------------------------------------------ LOGGING_IS_ON ----- */
  --
  FUNCTION logging_is_on           ( p_settings_id IN INTEGER DEFAULT NULL
                                   ) RETURN CHAR;
  --
  -- /* FUNCTION > debug_is_on ---------------------------------------------------------------------- DEBUG_IS_ON ----- */
  --
  FUNCTION debug_is_on             ( p_settings_id IN INTEGER DEFAULT NULL
                                   ) RETURN CHAR;
  --
  -- /* FUNCTION > get_batchid -------------------------------------------------------------- INTEGER ----- */
  -- 
  FUNCTION get_batchid ( batch_mode IN CHAR ) RETURN INTEGER;
  --  
  FUNCTION LOG_RUNTIME (context_in IN VARCHAR2, data_in IN VARCHAR2) RETURN PLS_INTEGER;
  FUNCTION LOG_INFO    (context_in IN VARCHAR2, data_in IN VARCHAR2) RETURN PLS_INTEGER;
  FUNCTION LOG_WARNING (context_in IN VARCHAR2, data_in IN VARCHAR2) RETURN PLS_INTEGER;
  FUNCTION LOG_ERROR   (context_in IN VARCHAR2, data_in IN VARCHAR2) RETURN PLS_INTEGER;
  FUNCTION LOG_DEBUG   (context_in IN VARCHAR2, data_in IN VARCHAR2) RETURN PLS_INTEGER;
  FUNCTION LOG_RUNTIME_FORCE (context_in IN VARCHAR2, data_in IN VARCHAR2) RETURN PLS_INTEGER;
  FUNCTION LOG_INFO_FORCE    (context_in IN VARCHAR2, data_in IN VARCHAR2) RETURN PLS_INTEGER;
  FUNCTION LOG_WARNING_FORCE (context_in IN VARCHAR2, data_in IN VARCHAR2) RETURN PLS_INTEGER;
  FUNCTION LOG_ERROR_FORCE   (context_in IN VARCHAR2, data_in IN VARCHAR2) RETURN PLS_INTEGER ;
  --  
  -- /* FUNCTION > Substitutes for DBMS_OUTPUT.PUT_LINE ------------------------------------------------- BOOL2VC ----- */
  --
  FUNCTION bool2vc                ( bool IN BOOLEAN
                                  ) RETURN VARCHAR2; 
  --  
  -- /* FUNCTION > Substitutes for DBMS_OUTPUT.PUT_LINE -------------------------------------------------- BOOL2C ----- */
  --
  FUNCTION bool2c                 ( bool IN BOOLEAN
                                  ) RETURN CHAR; 
  -- 
  -- /* FUNCTION > Substitutes for DBMS_OUTPUT.PUT_LINE ----------------------------------------------- GEN_TOKEN ----- */
  --
  FUNCTION gen_token RETURN VARCHAR2;
  --
  --  PROCEDURES
  --
  PROCEDURE who_called ( p_level IN NUMBER, p_trm_result OUT VARCHAR2 );
  PROCEDURE session_details;
  PROCEDURE session_details_revert(modus IN VARCHAR2, config_key IN VARCHAR2 DEFAULT NULL);
  --PROCEDURE show_config;
  PROCEDURE show_config ( modus IN VARCHAR DEFAULT NULL );
  --
  PROCEDURE help( verbose IN VARCHAR2 DEFAULT 'N');
  PROCEDURE banner;
  PROCEDURE version;
  --
  PROCEDURE clear_session_entries ( before_in              IN VARCHAR2 DEFAULT NULL );
  PROCEDURE clear_log_entries    ( before_in               IN VARCHAR2 DEFAULT NULL ); 
  PROCEDURE toggle_logging       ( modus                   IN VARCHAR2 DEFAULT c_on, 
                                   send_log_to_in          IN VARCHAR2 DEFAULT g_logging_target);
  --
  PROCEDURE toggle_debug         ( modus                   IN VARCHAR2 DEFAULT c_off,
                                   set_debug_target        IN CHAR     DEFAULT g_debug_target );
  --
  PROCEDURE toggle_batch     ( modus IN VARCHAR2 DEFAULT c_off, batch IN VARCHAR2 DEFAULT c_single );
  --
  PROCEDURE LOG_RUNTIME (context_in IN VARCHAR2, data_in IN VARCHAR2);
  PROCEDURE LOG_RUNTIME (context_in IN VARCHAR2, data_in IN CLOB    );
  PROCEDURE LOG_RUNTIME (context_in IN VARCHAR2, data_in IN BOOLEAN );
  PROCEDURE LOG_RUNTIME (context_in IN VARCHAR2, data_in IN DATE,     format_in IN VARCHAR2 DEFAULT c_date_mask );
  PROCEDURE LOG_INFO    (context_in IN VARCHAR2, data_in IN VARCHAR2);
  PROCEDURE LOG_INFO    (context_in IN VARCHAR2, data_in IN CLOB    );
  PROCEDURE LOG_INFO    (context_in IN VARCHAR2, data_in IN BOOLEAN );
  PROCEDURE LOG_INFO    (context_in IN VARCHAR2, data_in IN DATE,     format_in IN VARCHAR2 DEFAULT c_date_mask );
  PROCEDURE LOG_WARNING (context_in IN VARCHAR2, data_in IN VARCHAR2);
  PROCEDURE LOG_WARNING (context_in IN VARCHAR2, data_in IN CLOB    );
  PROCEDURE LOG_WARNING (context_in IN VARCHAR2, data_in IN BOOLEAN );
  PROCEDURE LOG_WARNING (context_in IN VARCHAR2, data_in IN DATE,     format_in IN VARCHAR2 DEFAULT c_date_mask );
  PROCEDURE LOG_ERROR   (context_in IN VARCHAR2, data_in IN VARCHAR2);
  PROCEDURE LOG_ERROR   (context_in IN VARCHAR2, data_in IN CLOB    );
  PROCEDURE LOG_ERROR   (context_in IN VARCHAR2, data_in IN BOOLEAN );
  PROCEDURE LOG_ERROR   (context_in IN VARCHAR2, data_in IN DATE,     format_in IN VARCHAR2 DEFAULT c_date_mask );
  PROCEDURE LOG_DEBUG   (context_in IN VARCHAR2, data_in IN VARCHAR2);
  PROCEDURE LOG_DEBUG   (context_in IN VARCHAR2, data_in IN CLOB    );
  PROCEDURE LOG_DEBUG   (context_in IN VARCHAR2, data_in IN BOOLEAN );
  PROCEDURE LOG_DEBUG   (context_in IN VARCHAR2, data_in IN DATE,     format_in IN VARCHAR2 DEFAULT c_date_mask );
  --
  PROCEDURE LOG_RUNTIME_FORCE (context_in IN VARCHAR2, data_in IN VARCHAR2);
  PROCEDURE LOG_RUNTIME_FORCE (context_in IN VARCHAR2, data_in IN CLOB    );
  PROCEDURE LOG_RUNTIME_FORCE (context_in IN VARCHAR2, data_in IN BOOLEAN );
  PROCEDURE LOG_RUNTIME_FORCE (context_in IN VARCHAR2, data_in IN DATE,     format_in IN VARCHAR2 DEFAULT c_date_mask);
  PROCEDURE LOG_INFO_FORCE    (context_in IN VARCHAR2, data_in IN VARCHAR2);
  PROCEDURE LOG_INFO_FORCE    (context_in IN VARCHAR2, data_in IN CLOB    );
  PROCEDURE LOG_INFO_FORCE    (context_in IN VARCHAR2, data_in IN BOOLEAN );
  PROCEDURE LOG_INFO_FORCE    (context_in IN VARCHAR2, data_in IN DATE,     format_in IN VARCHAR2 DEFAULT c_date_mask);
  PROCEDURE LOG_WARNING_FORCE (context_in IN VARCHAR2, data_in IN VARCHAR2);
  PROCEDURE LOG_WARNING_FORCE (context_in IN VARCHAR2, data_in IN CLOB    );
  PROCEDURE LOG_WARNING_FORCE (context_in IN VARCHAR2, data_in IN BOOLEAN );
  PROCEDURE LOG_WARNING_FORCE (context_in IN VARCHAR2, data_in IN DATE,     format_in IN VARCHAR2 DEFAULT c_date_mask);
  PROCEDURE LOG_ERROR_FORCE   (context_in IN VARCHAR2, data_in IN VARCHAR2);
  PROCEDURE LOG_ERROR_FORCE   (context_in IN VARCHAR2, data_in IN CLOB    );
  PROCEDURE LOG_ERROR_FORCE   (context_in IN VARCHAR2, data_in IN BOOLEAN );
  PROCEDURE LOG_ERROR_FORCE   (context_in IN VARCHAR2, data_in IN DATE,     format_in IN VARCHAR2 DEFAULT c_date_mask);
  --
  PROCEDURE put_line ( data_in   IN VARCHAR2 ); 
  PROCEDURE put_line ( data_in   IN BOOLEAN ); 
  PROCEDURE put_line ( data_in   IN DATE, format_in IN VARCHAR2 DEFAULT c_date_mask );
  PROCEDURE put_line ( clob_in   IN CLOB ); 
  --
END admin_logger;
/






