CREATE OR REPLACE PACKAGE admin_session AUTHID DEFINER
IS
  --B-  /* ======================================================================================================= */
  --B-  --
  --B-  -- BANNER FOR PACKAGE TETOOLS.ADMIN SESSION
  --B-  --
  --B-  /* ------------------------------------------------------------------------------------------------------- */
  --B-  
  --B-    Package name:  ADMIN_SESSION
  --B-     Author:       TET
  --B-     Version:      0.2
  --B-     Purpose:      This package allows users to kill database session.
  --B-                   Depending on the invoking user's privileges, additional confirmation may be required.
  --B-                   Various procedures exist to exert control on the termination requests.
  --B-     Parameters:   Depends on procedure being called. Execute TETOOLS.ADMIN_SESSION.help for usage examples.
  --B-  
  --B-    History     
  --B-    Version  Date       Changed by     Remark
  --B-    -------- ---------- -------------- ------------------------------------
  --B-         0.1 2024-05-07     [AUTHOR REDACTED] Setup package
  --B-         0.2 2024-05-14     [AUTHOR REDACTED] Functional version
  --B-         0.3 2024-05-29     [AUTHOR REDACTED] Alpha version
  --B-   
  --B-  /* ======================================================================================================= */
  --
  --HS-  /* ======================================================================================================= */
  --HS-  --
  --HS-  -- HELP / USAGE SCENARIOS FOR PACKAGE TETOOLS.ADMIN SESSION
  --HS-  --
  --HS-  /* ------------------------------------------------------------------------------------------------------- */
  --HS-  
  --HS-   DISPLAY THIS HELP SECTION
  --HS-   -----------------------------------------------------------------------
  --HS-   exec TETOOLS.ADMIN_SESSION.help[(p_verbose => 'N/Y')]; --DEFAULT = No
  --HV-   
  --HV-   DESCRIPTION OF:  TETOOLS.ADMIN_SESSION.help
  --HV-   -----------------------------------------------------------------------
  --HV-   The [help] procedure will display usage scenarios and examples of the procedures contained within the 
  --HV-   [ADMIN_SESSION] package which are made public via the header.
  --HV-   
  --HV-   ACCEPTED PARAMETERS FOR:  TETOOLS.ADMIN_SESSION.help
  --HV-   -----------------------------------------------------------------------
  --HV-   p_verbose: 'Y'
  --HV-   p_verbose: 'N' -- Default.
  --HV-   
  --HV-   --  The [help] procedure takes one (1) parameter < p_verbose >. Using this parameter, the user may choose whether
  --HV-       to display the extended help/usage information contained in the specification of the header.
  --HV-   
  --HV-   (SAMPLE) OUTPUT OF:  TETOOLS.ADMIN_SESSION.help
  --HV-   -----------------------------------------------------------------------
  --HV-
  --HV-       --HS-   DISPLAY THIS HELP SECTION
  --HV-       --HS-   -----------------------------------------------------------------------
  --HV-       --HS-   exec TETOOLS.ADMIN_SESSION.help[(p_verbose => 'N/Y')]; --DEFAULT = No
  --HV-       --HS-   
  --HV-       --HV-   DESCRIPTION OF:  TETOOLS.ADMIN_SESSION.help
  --HV-       --HV-   -----------------------------------------------------------------------
  --HV-       --HV-   The [help] procedure will display usage scenarios and examples of the procedures contained within the 
  --HV-       --HV-   [ADMIN_SESSION] package which are made public via the header.
  --HV-       --HV-   The [help] procedure takes one (1) parameter < p_verbose >. Using this parameter, the user may choose whether
  --HV-       --HV-   to display the extended help/usage information contained in the specification of the header.
  --HV-   
  --HV-   
  --HV-  
  --HS-  
  --HS-  
  --HS-   DISPLAY THE PACKAGE BANNER
  --HS-   -----------------------------------------------------------------------
  --HS-   exec TETOOLS.ADMIN_SESSION.banner;
  --HV-   
  --HV-   DESCRIPTION OF:  TETOOLS.ADMIN_SESSION.banner
  --HV-   -----------------------------------------------------------------------
  --HV-   The [banner] procedure will display the details and specifications of the physical package itself.
  --HV-   The [banner] procedure does not take parameters, it does not modify or process any data or information.
  --HV-   
  --HV-   ACCEPTED PARAMETERS FOR:  TETOOLS.ADMIN_SESSION.banner
  --HV-   -----------------------------------------------------------------------
  --HV-   The [banner] procedure does NOT take any parameters
  --HV-   
  --HV-   (SAMPLE) OUTPUT OF:  TETOOLS.ADMIN_SESSION.banner
  --HV-   -----------------------------------------------------------------------
  --HV-
  --HV-     /* ======================================================================================================= */
  --HV-     --
  --HV-     -- BANNER FOR PACKAGE TETOOLS.ADMIN SESSION
  --HV-     --
  --HV-     /* ------------------------------------------------------------------------------------------------------- */
  --HV-   
  --HV-       Package name:  ADMIN_SESSION
  --HV-        Author:       TET
  --HV-        Version:      0.2
  --HV-        Purpose:      This package allows users to kill database session.
  --HV-                      Depending on the invoking user's privileges,  additional confirmation may be required.
  --HV-                      Various procedures exist to exert control on the termination requests.
  --HV-        Parameters:   Depends on procedure being called. Execute TETOOLS.ADMIN_SESSION.help for usage examples.
  --HV-   
  --HV-       History
  --HV-       Version  Date       Changed by     Remark
  --HV-   
  --HV-            0.1 2024-05-07     [AUTHOR REDACTED] Setup package
  --HV-            0.2 2024-05-14     [AUTHOR REDACTED] Functional version
  --HV-   
  --HV-     /* ======================================================================================================= */
  --HV-
  --HS-
  --HS-
  --HS-   GENERATE LIST OF AVAILABLE SESSIONS AND TERMINATE COMMANDS
  --HS-   -----------------------------------------------------------------------
  --HS-   exec tetools.admin_session.list_sessions('USER');
  --HV-   
  --HV-   (SAMPLE) OUTPUT OF:  TETOOLS.ADMIN_SESSION.list_sessions('USER');
  --HV-   -----------------------------------------------------------------------
  --HV-     USERNAME         S LOGON_TIME          STATEMENT                                                            AUDSID        SID    SERIAL#
  --HV-     ---------------- - ------------------- ---------------------------------------------------------------- ---------- ---------- ----------
  --HV-     ADMIN_USER1        2024-05-29 08:55:41 TETOOLS.ADMIN_SESSION.terminate_session(444, 49056);                4330016        444      49056
  --HV-     ADMIN_USER2        2024-05-29 08:55:56 TETOOLS.ADMIN_SESSION.terminate_session(443, 44246);                4330017        443      44246
  --HV-     RO_USER1           2024-05-29 08:56:07 TETOOLS.ADMIN_SESSION.terminate_session(1184, 4040);                4330018       1184       4040
  --HV-     
  --HS-   exec tetools.admin_session.list_sessions('SELF');
  --HV-   
  --HV-   (SAMPLE) OUTPUT OF:  TETOOLS.ADMIN_SESSION.list_sessions('SELF');
  --HV-   -----------------------------------------------------------------------
  --HV-     USERNAME         S LOGON_TIME          STATEMENT                                                            AUDSID        SID    SERIAL#
  --HV-     ---------------- - ------------------- ---------------------------------------------------------------- ---------- ---------- ----------
  --HV-     TETOOLS          * 2024-05-29 08:55:08 TETOOLS.ADMIN_SESSION.terminate_session(426, 60713);                4330015        426      60713
  --HV-     TETOOLS            2024-05-29 12:06:05 TETOOLS.ADMIN_SESSION.terminate_session(429, 62550);                4330029        429      62550
  --HV-     
  --HS-   exec tetools.admin_session.list_sessions('ALL');
  --HV-   
  --HV-   (SAMPLE) OUTPUT OF:  TETOOLS.ADMIN_SESSION.list_sessions('ALL');
  --HV-   -----------------------------------------------------------------------
  --HV-     USERNAME         S LOGON_TIME          STATEMENT                                                            AUDSID        SID    SERIAL#
  --HV-     ---------------- - ------------------- ---------------------------------------------------------------- ---------- ---------- ----------
  --HV-     TETOOLS          * 2024-05-29 08:55:08 TETOOLS.ADMIN_SESSION.terminate_session(426, 60713);                4330015        426      60713
  --HV-     ADMIN_USER1        2024-05-29 08:55:41 TETOOLS.ADMIN_SESSION.terminate_session(444, 49056);                4330016        444      49056
  --HV-     ADMIN_USER2        2024-05-29 08:55:56 TETOOLS.ADMIN_SESSION.terminate_session(443, 44246);                4330017        443      44246
  --HV-     RO_USER1           2024-05-29 08:56:07 TETOOLS.ADMIN_SESSION.terminate_session(1184, 4040);                4330018       1184       4040
  --HV-     TETOOLS            2024-05-29 12:06:05 TETOOLS.ADMIN_SESSION.terminate_session(429, 62550);                4330029        429      62550
  --HV-   
  --HV-   DESCRIPTION OF:  TETOOLS.ADMIN_SESSION.list_sessions
  --HV-   -----------------------------------------------------------------------
  --HV-   The [list_sessions] procedure will display the available sessions and respective termination commands and details.
  --HV-   The [list_sessions] procedure takes parameters, it may translate the given parameters to suit the executed query.
  --HV-   
  --HV-   ACCEPTED PARAMETERS FOR:  TETOOLS.ADMIN_SESSION.list_sessions
  --HV-   -----------------------------------------------------------------------
  --HV-   p_username: 'SELF' -- Default. This will displays only the users own sessions.
  --HV-   p_username: 'ALL' 
  --HV-   p_username: '< any part of a username >' 
  --HS-  
  --HS-  
  --HS-   TERMINATE A SESSION
  --HS-   -----------------------------------------------------------------------
  --HS-   EXEC TETOOLS.ADMIN_SESSION.terminate_session(v_sid, v_serial);
  --HV-   
  --HV-   DESCRIPTION OF:  TETOOLS.ADMIN_SESSION.terminate_session
  --HV-   -----------------------------------------------------------------------
  --HV-   The [terminate_session] procedure will validate the callers privilege for requesting the termination of a session.
  --HV-   [terminate_session] 
  --HV-   
  --HV-   ACCEPTED PARAMETERS FOR:  TETOOLS.ADMIN_SESSION.terminate_session
  --HV-   -----------------------------------------------------------------------
  --HV-   p_trgt_sid   : NUMBER
  --HV-   p_trgt_serial: NUMBER
  --HV-   
  --HV-   --  The [terminate_session] procedure takes two (2) parameters < p_trgt_sid > & < p_trgt_serial >.
  --HV-       Both of these parameters need to be numbers, and should point (in pair) to a distinct database session.
  --HV-   
  --HV-   (SAMPLE) OUTPUT OF:  TETOOLS.ADMIN_SESSION.terminate_session
  --HV-   -----------------------------------------------------------------------
  --HV-     OUTPUT AS ADMIN/DBA USER
  --HV-     -----------------------------------------------------------------------
  --HV-     EXEC TETOOLS.ADMIN_SESSION.terminate_session(1184, 56545);
  --HV-
  --HV-     ### ADMIN_SESSION.TERMINATE_SESSION: TERMINATION REQUEST IS ACCEPTED, STATUS = O
  --HV-     ADMIN_SESSION.SET_TRM_STATUS > 0484092389 X, N, N, 123
  --HV-     ADMIN_SESSION.SET_TRM_STATUS > 2505139488 K, Y, N, 123
  --HV-     -- ADMIN_SESSION.TERMINATE_SESSION: TERMINATION WAS SUCCESFUL.
  --HV-
  --HV-
  --HV-     OUTPUT AS REGULAR USER
  --HV-     -----------------------------------------------------------------------
  --HV-     EXEC TETOOLS.ADMIN_SESSION.terminate_session(443, 44246);
  --HV-
  --HV-     TERMINATION REQUEST FOR USER: ADMIN_USER2 WITH DETAILS: (SID: 443, SERIAL#: 44246, SPID: 59771, AUDSID: 4330017) NEEDS ADDITIONAL ACTIVITIES.
  --HV-     ** INVOKING USER OF TERMINATION REQUEST NEEDS TO BE AN ADMIN USER FOR THIS REQUEST/SESSION. TERMINATION REQUEST AWAITS CONFIRMATION. TRM ID: 126
  --HV-     ADMIN_SESSION.SET_TRM_STATUS > 0484092389 C, N, Y, 126
  --HV-
  --HV-
  --HS-
  --HS-  
  --HS-   CONFIRM A TERMINATION REQUEST
  --HS-   -----------------------------------------------------------------------
  --HS-   DECLARE
  --HS-     v_trm                NUMBER  := 203;
  --HS-     v_cfm_gvn            CHAR(1) := 'Y';
  --HS-     p_trm_result_num     NUMBER  := 0;
  --HS-     p_trm_result         VARCHAR2(1000);
  --HS-   BEGIN
  --HS-     TETOOLS.ADMIN_SESSION.terminate_confirm(v_trm, v_cfm_gvn, p_trm_result_num, p_trm_result);
  --HS-     DBMS_OUTPUT.PUT_LINE('*** OUTPUT> ID: '||v_trm||', RESULT: '||p_trm_result);
  --HS-   END;
  --HS-   /
  --HS-  
  --HS-  
  --HS-   DENY A TERMINATION REQUEST
  --HS-   -----------------------------------------------------------------------
  --HS-   DECLARE
  --HS-     v_trm                NUMBER  := 203;
  --HS-     v_cfm_gvn            CHAR(1) := 'N';
  --HS-     p_trm_result_num     NUMBER  := 0;
  --HS-     p_trm_result         VARCHAR2(1000);
  --HS-   BEGIN
  --HS-     TETOOLS.ADMIN_SESSION.terminate_confirm(v_trm, v_cfm_gvn, p_trm_result_num, p_trm_result);
  --HS-     DBMS_OUTPUT.PUT_LINE('*** OUTPUT> ID: '||v_trm||', RESULT: '||p_trm_result);
  --HS-   END;
  --HS-   /
  --HS-  
  --HS-  
  --HS-   DISPLAY STATUS OF A TERMINATION REQUEST VIA TRM ID
  --HS-   -----------------------------------------------------------------------
  --HS-   exec TETOOLS.ADMIN_SESSION.terminate_status(p_trm_id => 203);
  --HS-  
  --HS-  
  --HS-   DISPLAY STATUS OF A TERMINATION REQUEST VIA TRM STATUS
  --HS-   -----------------------------------------------------------------------
  --HS-   exec TETOOLS.ADMIN_SESSION.terminate_status(p_trm_status => 'C');
  --HS-  
  --HS-  
  --HS-   CANCEL AN OUTSTANDING TERMINATION REQUEST
  --HS-   -----------------------------------------------------------------------
  --HS-   exec TETOOLS.ADMIN_SESSION.terminate_cancel(p_trm_id => 203);
  --HS-  
  --HS-  /* ======================================================================================================= */
  --
  -- FUNCTIONS
  --
  --
  -- /* FUNCTION > is_number ------------------------------------------------------------------------- INVOKING_SID ----- */
  --
  FUNCTION is_number(p_str IN VARCHAR2) RETURN boolean;
  --
  -- /* FUNCTION > get_invoking_sid ------------------------------------------------------------------ INVOKING_SID ----- */
  --
  FUNCTION get_invoking_sid RETURN NUMBER;
  --
  -- /* FUNCTION > get_invoking_serial ----------------------------------------------------------- INVOKING_SERIAL# ----- */
  --
  FUNCTION get_invoking_serial RETURN NUMBER;
  --
  -- /* FUNCTION > get_pid ------------------------------------------------------------------------------------ PID ----- */
  --
  FUNCTION get_spid ( p_sid IN NUMBER, p_serial IN NUMBER ) RETURN VARCHAR2;
  --
  -- /* FUNCTION > get_logon_time ---------------------------------------------------------------------- LOGON_TIME ----- */
  --
  FUNCTION get_logon_time ( p_sid IN NUMBER, p_serial IN NUMBER ) RETURN DATE;
  --
  -- /* FUNCTION > get_audsid ------------------------------------------------------------------------------ AUDSID ----- */
  --
  FUNCTION get_audsid ( p_sid IN NUMBER, p_serial IN NUMBER ) RETURN VARCHAR2;
  --
  -- /* FUNCTION > get_pref ---------------------------------------------------------------------------- PREF_VALUE ----- */
  --
  FUNCTION get_pref( p_pref_name IN admin_sessions_prefs.pref_name%type) RETURN VARCHAR2;
  --
  -- /* FUNCTION > list_session ------------------------------------------------------------------- CURRENT SESSION ----- */
  --
  -- /* SQL_MARCO CANNOT EXIST IN THE SAME PACKAGE AS THE FUNCTION/PROCEDURE THAT CALLS IT */
  -- /* AS IT NEEDS TO BE AVAILABLE WHEN ITS PARSED AT COMPILATION                         */
  --FUNCTION list_session( p_user_id IN VARCHAR2 ) RETURN CLOB SQL_MACRO;
  --
  --  PROCEDURES
  --
  PROCEDURE help( p_verbose                      IN         VARCHAR2 DEFAULT 'N');
  PROCEDURE banner;
  PROCEDURE list_session( p_username in varchar2, p_cursor out sys_refcursor );
  PROCEDURE list_sessions( p_username IN VARCHAR2 DEFAULT 'SELF' );
  PROCEDURE grace( p_grace_after_days IN NUMBER DEFAULT NULL );
  PROCEDURE expire( p_expire_after_days IN NUMBER DEFAULT NULL );
  PROCEDURE get_trm_status ( p_trm_id           IN         NUMBER DEFAULT 0,   -- /* TERMINATION REQUEST ID */
                             p_sid              IN         NUMBER DEFAULT 0,
                             p_serial           IN         NUMBER DEFAULT 0,
                             p_result_num       OUT        NUMBER
                           );
  PROCEDURE who_called ( p_trm_result            OUT        VARCHAR2 );
  PROCEDURE get_details ( p_sid                  IN         NUMBER, 
                          p_serial               IN         NUMBER,
                          p_result_num           OUT        NUMBER,
                          P_result               OUT        VARCHAR2,
                          p_audsid               OUT        NUMBER,
                          p_username             OUT        VARCHAR2,
                          p_sql_id               OUT        VARCHAR2, 
                          p_sql_child_number     OUT        NUMBER, 
                          p_trm_req_acc          OUT        VARCHAR2, 
                          p_trm_req_denied_by    OUT        VARCHAR2, 
                          p_trm_req_denied_rsn   OUT        VARCHAR2, 
                          p_sqltext              OUT        VARCHAR2, 
                          p_cpu_msec             OUT        NUMBER,
                          p_phys_read            OUT        NUMBER,
                          p_phys_write           OUT        NUMBER );
  PROCEDURE compare_roles ( p_inv_user           IN         VARCHAR2,
                            p_trg_user           IN         VARCHAR2,
                            p_isinvusr_adm       OUT        VARCHAR2,
                            p_istrgusr_adm       OUT        VARCHAR2,
                            p_inv_roles          OUT        VARCHAR2,
                            p_trg_roles          OUT        VARCHAR2,
                            p_cfm_req            OUT        VARCHAR2);
  -- /* TERMINATE_SESSION -------------------------------------------------------- TERMINATE SESSION BY SID/SERIAL# ----- */
  --
  PROCEDURE terminate_session ( p_trgt_sid       IN         NUMBER,           -- /* TARGET USER SID */
                                p_trgt_serial    IN         NUMBER            -- /* TARGET USER SERIAL# */
                              );
  --
  -- /* TERMINATE_CONFIRM --------------------------------- PROVIDE CONFIRMATION TO TERMINATE SESSION BY TERMSES ID ----- */
  --
  PROCEDURE terminate_confirm ( p_trm_id         IN         NUMBER,    -- /* TERMINATION REQUEST ID */
                                p_cfm_gvn        IN         VARCHAR2,  -- /* SPECIFY CONFIRMATION FOR GIVEN ID Y/N */
                                p_trm_result     IN OUT     VARCHAR2,  -- /* FEEDBACK ON CONFIRMATION */
                                p_trm_result_num OUT        NUMBER     -- /* FEEDBACK NUMBER ON CONFIRMATION */
                               );
 
  --
  -- /* TERMINATE_STATUS ---------------------------------------------------------- QUERY STATUS OF TERMSES REQUEST ----- */
  --
  PROCEDURE terminate_status( p_trm_id           IN        NUMBER   DEFAULT 999999999999,   -- /* TERMINATION REQUEST ID */
                              p_trm_status       IN        VARCHAR2 DEFAULT 'Z'             -- /* TERMINATION REQUEST STATUS */
                            );
  --
  -- /* TERMINATE_CANCEL ----------------------------------------------------- CANCEL TERMSES REQUEST BY TERMSES ID ----- */
  --
  PROCEDURE terminate_cancel( p_trm_id           IN        NUMBER,               -- /* TERMINATION REQUEST ID */
                              p_cnl_given        IN        VARCHAR2 DEFAULT 'Y', -- /* SPECIFY CANCELATION REQUEST FOR GIVEN ID Y/N */
                              p_cnl_reason       IN        VARCHAR2,             -- /* SPECIFY CANCELATION RREASON FOR GIVEN ID */
                              p_trm_result       OUT       VARCHAR2              -- /* FEEDBACK ON CANCELATION REQUEST */
                             );

END admin_session;
/