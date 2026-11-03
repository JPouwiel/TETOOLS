CREATE OR REPLACE PACKAGE admin_tnsnames AUTHID DEFINER
IS
  --B-  /* ======================================================================================================= */
  --B-  --
  --B-  -- BANNER FOR PACKAGE TETOOLS.ADMIN_TNSNAMES
  --B-  --
  --B-  /* ------------------------------------------------------------------------------------------------------- */
  --B-  
  --B-    Package name:  ADMIN_TNSNAMES
  --B-     Author:       TET
  --B-     Version:      0.1
  --B-     Purpose:      This package allows users to administer the TNSNAMES registrations.
  --B-     Parameters:   Depends on procedure being called. Execute TETOOLS.ADMIN_TNSNAMES.help for usage examples.
  --B-  
  --B-    History     
  --B-    Version  Date       Changed by     Remark
  --B-    -------- ---------- -------------- ------------------------------------
  --B-         0.1 2024-06-25     [AUTHOR REDACTED] Setup package
  --B-   
  --B-  /* ======================================================================================================= */
  --
  --HS-  /* ======================================================================================================= */
  --HS-  --
  --HS-  -- HELP / USAGE SCENARIOS FOR PACKAGE TETOOLS.ADMIN TNSNAMES
  --HS-  --
  --HS-  /* ------------------------------------------------------------------------------------------------------- */
  --HS-  
  --HS-   DISPLAY THIS HELP SECTION
  --HS-   ---------------------------------------------------------------------------------
  --HS-   exec TETOOLS.ADMIN_TNSNAMES.help[(p_verbose => 'N/Y')]; --DEFAULT = NO
  --HV-   
  --HV-   DESCRIPTION OF:  TETOOLS.ADMIN_TNSNAMES.help
  --HV-   ---------------------------------------------------------------------------------
  --HV-   The [help] procedure will display usage scenarios and examples of the procedures contained within the 
  --HV-   [ADMIN_TNSNAMES] package which are made public via the header.
  --HV-   
  --HV-   ACCEPTED PARAMETERS FOR:  TETOOLS.ADMIN_TNSNAMES.help
  --HV-   ---------------------------------------------------------------------------------
  --HV-   p_verbose: 'Y'
  --HV-   p_verbose: 'N' -- Default.
  --HV-   
  --HV-   --  The [help] procedure takes one (1) parameter < p_verbose >. Using this parameter, the user may choose whether
  --HV-       to display the extended help/usage information contained in the specification of the header.
  --HV-   
  --HV-   (SAMPLE) OUTPUT OF:  TETOOLS.ADMIN_TNSNAMES.help
  --HV-   ---------------------------------------------------------------------------------
  --HV-
  --HV-       --HS-   DISPLAY THIS HELP SECTION
  --HV-       --HS-   ---------------------------------------------------------------------------------
  --HV-       --HS-   exec TETOOLS.ADMIN_TNSNAMES.help[(p_verbose => 'N/Y')]; --DEFAULT = No
  --HV-       --HS-   
  --HV-       --HV-   DESCRIPTION OF:  TETOOLS.ADMIN_TNSNAMES.help
  --HV-       --HV-   ---------------------------------------------------------------------------------
  --HV-       --HV-   The [help] procedure will display usage scenarios and examples of the procedures contained within the 
  --HV-       --HV-   [ADMIN_TNSNAMES] package which are made public via the header.
  --HV-       --HV-   The [help] procedure takes one (1) parameter < p_verbose >. Using this parameter, the user may choose whether
  --HV-       --HV-   to display the extended help/usage information contained in the specification of the header.
  --HV-
  --HS-
  --HS-   REGISTER A TNS ALIAS
  --HS-   -----------------------------------------------------------------------
  --HS-   EXEC TETOOLS.ADMIN_TNSNAMES.register_tns ( p_crud           , 
  --HS-                                              p_tns_id         , 
  --HS-                                              p_tns_alias      , 
  --HS-                                              p_target_phase   , 
  --HS-                                              p_target_envs    , 
  --HS-                                              p_host_name      , 
  --HS-                                              p_service_name   , 
  --HS-                                              p_port           , 
  --HS-                                              p_date_valid_from, 
  --HS-                                              p_description    , 
  --HS-                                              p_date_valid_end , 
  --HS-                                              p_connect_timeout, 
  --HS-                                              p_retry_delay    , 
  --HS-                                              p_retry_count    , 
  --HS-                                              p_failover       , 
  --HS-                                              p_load_balance   , 
  --HS-                                              p_force          );
  --HS- 
  --HV-   
  --HV-   DESCRIPTION OF:  TETOOLS.ADMIN_SESSION.register_tns
  --HV-   ---------------------------------------------------------------------------------
  --HV-   The [register_tns] procedure will insert, update, or delete the (if exists)
  --HV-   the corresponding record for the given tns_alias details. 
  --HV-   
  --HV-   ACCEPTED PARAMETERS FOR:  TETOOLS.ADMIN_SESSION.register_tns
  --HV-   ---------------------------------------------------------------------------------
  --HV-   p_crud            IN CHAR
  --HV-   p_tns_id          IN INTEGER
  --HV-   p_tns_alias       IN VARCHAR2
  --HV-   p_target_phase    IN CHAR
  --HV-   p_target_envs     IN VARCHAR2
  --HV-   p_host_name       IN VARCHAR2
  --HV-   p_service_name    IN VARCHAR2
  --HV-   p_port            IN NUMBER
  --HV-   p_date_valid_from IN VARCHAR2   DEFAULT SYSDATE
  --HV-   p_description     IN VARCHAR2   DEFAULT NULL
  --HV-   p_date_valid_end  IN VARCHAR2   DEFAULT '9999-12-31'
  --HV-   p_connect_timeout IN NUMBER     DEFAULT NULL
  --HV-   p_retry_delay     IN NUMBER     DEFAULT NULL
  --HV-   p_retry_count     IN NUMBER     DEFAULT NULL
  --HV-   p_failover        IN VARCHAR2   DEFAULT NULL
  --HV-   p_load_balance    IN VARCHAR2   DEFAULT NULL
  --HV-   p_force           IN CHAR       DEFAULT 'N'
  --HV-   
  --HV-   --  The [register_tns] procedure takes seventeen (17) parameters.
  --HV-       Not all of these parameters need to be given, as some have default values.
  --HV-   
  --HV-   (SAMPLE) OUTPUT OF:  TETOOLS.ADMIN_SESSION.register_tns
  --HV-   ---------------------------------------------------------------------------------
  --HV-     OUTPUT AS ADMIN/DBA USER
  --HV-     ---------------------------------------------------------------------------------
  --HV-     DECLARE
  --HV-       v_crud                   CHAR(1)             := 'C';
  --HV-       v_tns_id                 INTEGER             := NULL;
  --HV-       v_tns_alias              VARCHAR2(128)       := 'test_alias07';
  --HV-       v_target_phase           CHAR(1)             := 'T';
  --HV-       v_target_envs            VARCHAR2(128)       := 'DTA';
  --HV-       v_hostname               VARCHAR2(128)       := 'example.invalid';
  --HV-       v_servicename            VARCHAR2(128)       := 'service01';
  --HV-       v_port                   NUMBER              := 1521;
  --HV-       v_date_valid_from        VARCHAR2(128)       := '2024-09-16';
  --HV-       v_description            VARCHAR2(256)       := 'TEST description';
  --HV-       v_date_valid_end         VARCHAR2(128)       := '2099-01-01';
  --HV-       v_connect_timeout        NUMBER;
  --HV-       v_retry_delay            NUMBER;
  --HV-       v_retry_count            NUMBER;
  --HV-       v_failover               VARCHAR2(5);
  --HV-       v_load_balance           VARCHAR2(5);
  --HV-       v_force                  CHAR(1)             := 'N';
  --HV-     BEGIN
  --HV-       tetools.admin_tnsnames.register_tns( v_crud, 
  --HV-                                            v_tns_id, 
  --HV-                                            v_tns_alias, 
  --HV-                                            v_target_phase, 
  --HV-                                            v_target_envs, 
  --HV-                                            v_hostname,  
  --HV-                                            v_servicename,  
  --HV-                                            v_port, 
  --HV-                                            v_date_valid_from, 
  --HV-                                            v_description, 
  --HV-                                            v_date_valid_end, 
  --HV-                                            v_connect_timeout, 
  --HV-                                            v_retry_delay, 
  --HV-                                            v_retry_count, 
  --HV-                                            v_failover, 
  --HV-                                            v_load_balance, 
  --HV-                                            v_force
  --HV-                                          );
  --HV-     END;
  --HV-     /
  --HV-
  --HV-       !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  --HV-       !!                                                                                                               !!
  --HV-       !!          .#@@@%**%@+                                                                                          !!
  --HV-       !!       :%@@=.  =.   .=    TET - TNSNAMES ADMINISTRATION PACKAGE 0.301                                          !!
  --HV-       !!     :@@%: .=#%@@@=  .                                                                                         !!
  --HV-       !!    #@@= =@@@@%@@%=.                                                                                           !!
  --HV-       !!  .@@@::@@@=  =:          TNS Registration       : test_alias07 (22-AUG-24 02:05:09 PM)                        !!
  --HV-       !!  *@@%.@@# :.:::.:= -     USER                   : TETOOLS                                                     !!
  --HV-       !!  @@@#=@@: +:-*#**:#:                                                                                          !!
  --HV-       !!  *@@@=%@                                                                                                      !!
  --HV-       !!   =@@@@@@@@#:                                                                                                 !!
  --HV-       !!                                                                                                               !!
  --HV-       !!---------------------------------------------------------------------------------------------------------------!!
  --HV-       !!- RESULTING ADDITION / ALTERATION - C -------------------------------------------------------------------------!!
  --HV-       !!                                                                                                               !!
  --HV-       !!   PHASE                     : T                                                                               !!
  --HV-       !!   TARGET ENVIRONMENTS       : DTA                                                                             !!
  --HV-       !!   CREATED TNS_ID            : 441                                                                             !!
  --HV-       !!   ----------------------------------------------------                                                        !!
  --HV-       !!                                                                                                               !!
  --HV-       !!   # [test_alias07 - 2024-08-22] :: TEST description                                                           !!
  --HV-       !!   test_alias07 =                                                                                              !!
  --HV-       !!     (DESCRIPTION =                                                                                            !!
  --HV-       !!     (ADDRESS = TCP)                                                                                           !!
  --HV-       !!       (HOST = example.invalid)                                                                     !!
  --HV-       !!       (PORT = 1521)                                                                                           !!
  --HV-       !!       )                                                                                                       !!
  --HV-       !!       (CONNECT_DATA =                                                                                         !!
  --HV-       !!         (SERVER = DEDICATED)                                                                                  !!
  --HV-       !!         (SERVICE_NAME = service01)                                                                            !!
  --HV-       !!       )                                                                                                       !!
  --HV-       !!     )                                                                                                         !!
  --HV-       !!                                                                                                               !!
  --HV-       !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  --HV-                                                             Don't forget to execute TETOOLS.ADMIN_TNSNAMES.GENERATE_TNS !
  --HV-
  --HV-
  --HS-
  --HS-
  --HS-   GENERATE A TNS REGISTRATION TEMPLATE
  --HS-   ---------------------------------------------------------------------------------
  --HS-   EXEC TETOOLS.ADMIN_TNSNAMES.generate_template ( p_type          , 
  --HS-                                                   p_num_hosts     );
  --HS- 
  --HV-   
  --HV-   DESCRIPTION OF:  TETOOLS.ADMIN_SESSION.generate_template
  --HV-   ---------------------------------------------------------------------------------
  --HV-   The [generate_template] procedure will generate a valid JSON template
  --HV-   where the required parameters for registering a tns alias are given. 
  --HV-   The given placeholders can/must be replaced with the correct parameters.
  --HV-   
  --HV-   ACCEPTED PARAMETERS FOR:  TETOOLS.ADMIN_SESSION.generate_template
  --HV-   ---------------------------------------------------------------------------------
  --HV-   p_type            IN VARCHAR2(8)   : 'SIMPLE'     -- DEFAULT
  --HV-   p_type            IN VARCHAR2(8)   : 'ADVANCED' 
  --HV-   p_num_hosts       IN INTEGER       : MAX(3)       -- DEFAULT 1
  --HV-   
  --HV-   --  The [generate_template] procedure takes two (2) parameters.
  --HV-       Not all of these parameters need to be given, as some have default values.
  --HV-       When choosing a 'SIMPLE' template, the number of hosts is limited to one (1).
  --HV-   
  --HV-   (SAMPLE) OUTPUT OF:  TETOOLS.ADMIN_SESSION.generate_template
  --HV-   ---------------------------------------------------------------------------------
  --HV-     OUTPUT AS ADMIN/DBA USER
  --HV-     ---------------------------------------------------------------------------------
  --HV-     DECLARE
  --HV-       v_type                   VARCHAR2(8)         := 'SIMPLE';
  --HV-       v_num_hosts              INTEGER             := 1;
  --HV-     BEGIN
  --HV-       tetools.admin_tnsnames.generate_template(v_type, v_num_hosts);
  --HV-       --
  --HV-     END;
  --HV-     /
  --HV-
  --HV-       !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  --HV-       !!                                                                                                               !!
  --HV-       !!          .#@@@%**%@+                                                                                          !!
  --HV-       !!       :%@@=.  =.   .=    TET - TNSNAMES ADMINISTRATION PACKAGE 0.301                                          !!
  --HV-       !!     :@@%: .=#%@@@=  .                                                                                         !!
  --HV-       !!    #@@= =@@@@%@@%=.                                                                                           !!
  --HV-       !!  .@@@::@@@=  =:          TNS Registration       : test_alias07 (22-AUG-24 02:05:09 PM)                        !!
  --HV-       !!  *@@%.@@# :.:::.:= -     USER                   : TETOOLS                                                     !!
  --HV-       !!  @@@#=@@: +:-*#**:#:                                                                                          !!
  --HV-       !!  *@@@=%@                                                                                                      !!
  --HV-       !!   =@@@@@@@@#:                                                                                                 !!
  --HV-       !!                                                                                                               !!
  --HV-       !!---------------------------------------------------------------------------------------------------------------!!
  --HV-       !!- RESULTING ADDITION / ALTERATION - C -------------------------------------------------------------------------!!
  --HV-       !!                                                                                                               !!
  --HV-       !!   PHASE                     : T                                                                               !!
  --HV-       !!   TARGET ENVIRONMENTS       : DTA                                                                             !!
  --HV-       !!   CREATED TNS_ID            : 441                                                                             !!
  --HV-       !!   ----------------------------------------------------                                                        !!
  --HV-       !!                                                                                                               !!
  --HV-       !!   # [test_alias07 - 2024-08-22] :: TEST description                                                           !!
  --HV-       !!   test_alias07 =                                                                                              !!
  --HV-       !!     (DESCRIPTION =                                                                                            !!
  --HV-       !!     (ADDRESS = TCP)                                                                                           !!
  --HV-       !!       (HOST = example.invalid)                                                                     !!
  --HV-       !!       (PORT = 1521)                                                                                           !!
  --HV-       !!       )                                                                                                       !!
  --HV-       !!       (CONNECT_DATA =                                                                                         !!
  --HV-       !!         (SERVER = DEDICATED)                                                                                  !!
  --HV-       !!         (SERVICE_NAME = service01)                                                                            !!
  --HV-       !!       )                                                                                                       !!
  --HV-       !!     )                                                                                                         !!
  --HV-       !!                                                                                                               !!
  --HV-       !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  --HV-                                                             Don't forget to execute TETOOLS.ADMIN_TNSNAMES.GENERATE_TNS !
  --HV-
  --HV-
  --HS-  /* ======================================================================================================= */
  --
  -- FUNCTIONS
  --
  --  
  FUNCTION                  get_pref ( p_pref_name           IN admin_sessions_prefs.pref_name%type
                                     )                                                              RETURN VARCHAR2;
  --
  FUNCTION          num_period_dname                                                                RETURN NUMBER;
  --
  FUNCTION                removehttp ( p_hostname            IN VARCHAR2
                                     ) RETURN VARCHAR2;
  --
  FUNCTION                shortnamer ( p_hostname            IN VARCHAR2
                                     ) RETURN VARCHAR2;
  --
  --  PROCEDURES
  --
  PROCEDURE                     help ( p_verbose             IN VARCHAR2  DEFAULT 'N'
                                     );
  --
  PROCEDURE                   banner;
  --
  PROCEDURE        generate_template ( p_type                IN VARCHAR2  DEFAULT 'SIMPLE',
                                       p_num_hosts           IN INTEGER   DEFAULT 1
                                     );
  --
  PROCEDURE          tnsnames_status ( p_status             OUT VARCHAR2,
                                       p_role               OUT VARCHAR2,
                                       p_cont               OUT VARCHAR2
                                     );                                   
  --
  PROCEDURE            report_status ( p_status              IN VARCHAR2,
                                       p_role                IN VARCHAR2,
                                       p_cont                IN VARCHAR2,
                                       p_feedback            IN VARCHAR2
                                     );
  --
  PROCEDURE          report_existing ( p_tns_alias           IN VARCHAR2,
                                       p_does_exist          IN CHAR,
                                       p_phase               IN VARCHAR2,
                                       p_host_name           IN VARCHAR2  DEFAULT NULL,
                                       p_service_name        IN VARCHAR2  DEFAULT NULL
                                     );
  --
  PROCEDURE      report_registration ( json_string           IN CLOB,
                                       p_tns_id              IN INTEGER
                                     );
  --
  PROCEDURE               who_called ( p_trm_result         OUT VARCHAR2,
                                       p_level               IN INTEGER   DEFAULT 2
                                     );
  --
  PROCEDURE                   notify ( p_message_num         IN NUMBER,
                                       p_caller              IN VARCHAR2,
                                       p_message_string      IN VARCHAR2
                                     );
  --
  PROCEDURE                     crud ( json_string           IN CLOB,
                                       p_tns_id             OUT INTEGER
                                     );
  --
  PROCEDURE            compare_roles ( p_inv_roles          OUT VARCHAR2,
                                       p_isinvusr_adm       OUT VARCHAR2,
                                       p_isinvusr_con       OUT VARCHAR2
                                     );
  --
  PROCEDURE                query_tns ( p_tns_alias           IN VARCHAR2,
                                       p_phase_in            IN CHAR,
                                       p_does_exist         OUT CHAR
                                     );
  --
  PROCEDURE             existing_tns ( p_tns_alias           IN VARCHAR2,
                                       p_phase_in            IN CHAR,
                                       p_crud               OUT CHAR,
                                       p_tns_id             OUT INTEGER,
                                       p_does_exist         OUT CHAR,
                                       p_phase_out          OUT CHAR,
                                       p_host_name          OUT VARCHAR2,
                                       p_service_name       OUT VARCHAR2
                                     );
  --
  PROCEDURE            phase_checker ( p_hostname            IN VARCHAR,
                                       p_phase               IN CHAR,
                                       p_isphasevalid       OUT CHAR
                                     );
  --
  PROCEDURE        ipaddress_checker ( p_hostname            IN VARCHAR2,
                                      p_numperiods          OUT INTEGER,
                                      p_isnumeral           OUT CHAR,
                                      p_isvalidip           OUT CHAR,
                                      p_feedback            OUT INTEGER
                                    );
  --
  PROCEDURE            port_checker ( p_port                 IN VARCHAR2,
                                      p_numeral             OUT CHAR,
                                      p_is_1k               OUT CHAR,
                                      p_default_port        OUT CHAR,
                                      p_range_expected      OUT CHAR,
                                      p_continue            OUT CHAR
                                    );
  --
  PROCEDURE             isipaddress ( p_hostname             IN VARCHAR2,
                                      p_return              OUT CHAR
                                    );
  --
  PROCEDURE                  isfqdn ( p_hostname             IN VARCHAR2,
                                      p_phase                IN CHAR,
                                      p_force                IN CHAR      DEFAULT 'N',
                                      p_is_valid_phase      OUT CHAR,
                                      p_is_fqdn             OUT CHAR,
                                      p_is_valid_dname      OUT CHAR,
                                      p_param_hostname      OUT VARCHAR2,
                                      p_param_domain_name   OUT VARCHAR2,
                                      p_continue            OUT CHAR,
                                      p_feedback            OUT INTEGER
                                    );
  --
  PROCEDURE           eval_hostname ( p_hostname             IN VARCHAR2,
                                      p_phase                IN CHAR,
                                      p_force                IN CHAR      DEFAULT 'N',
                                      p_is_numeral          OUT CHAR,
                                      p_is_valid_ip         OUT CHAR, 
                                      p_is_valid_phase      OUT CHAR,
                                      p_is_fqdn             OUT CHAR,
                                      p_is_valid_dname      OUT CHAR,
                                      p_feedback_string     OUT VARCHAR2,
                                      p_param_hostname      OUT VARCHAR2,
                                      p_param_domain_name   OUT VARCHAR2,
                                      p_continue            OUT CHAR
                                    );
  --
  PROCEDURE            validate_tns ( p_hostname             IN VARCHAR2,
                                      p_phase                IN CHAR,
                                      p_force                IN CHAR,
                                      p_port                 IN VARCHAR2,
                                      p_service_name         IN VARCHAR2,
                                      p_target_envs          IN VARCHAR2,
                                      p_is_valid_ip         OUT CHAR,
                                      p_is_valid_phase      OUT CHAR,
                                      p_is_fqdn             OUT CHAR,
                                      p_is_valid_dname      OUT CHAR,
                                      p_param_hostname      OUT VARCHAR2,
                                      p_param_domain_name   OUT VARCHAR2,
                                      p_feedback            OUT VARCHAR2,
                                      p_is_numeral_port     OUT CHAR,
                                      p_is_1k               OUT CHAR,
                                      p_default_port        OUT CHAR,
                                      p_port_range_expected OUT CHAR,
                                      p_continue            OUT CHAR
                                    );
  --
  PROCEDURE            register_tns ( p_tns_alias            IN VARCHAR2,
                                      p_target_phase         IN CHAR,
                                      p_target_envs          IN VARCHAR2,
                                      p_host_name            IN VARCHAR2,
                                      p_service_name         IN VARCHAR2,
                                      p_port                 IN NUMBER,
                                      p_date_valid_from      IN VARCHAR2  DEFAULT SYSDATE,
                                      p_description          IN VARCHAR2  DEFAULT NULL,
                                      p_date_valid_end       IN VARCHAR2  DEFAULT '9999-12-31',
                                      p_connect_timeout      IN NUMBER    DEFAULT NULL,
                                      p_retry_delay          IN NUMBER    DEFAULT NULL,
                                      p_retry_count          IN NUMBER    DEFAULT NULL,
                                      p_failover             IN VARCHAR2  DEFAULT NULL,
                                      p_load_balance         IN VARCHAR2  DEFAULT NULL,
                                      p_force                IN CHAR      DEFAULT 'N'
                                    );
  --PROCEDURE add_additional_alias ( p_base_id IN NUMBER, tns_alias IN VARCHAR2, p_continue OUT CHAR );
END admin_tnsnames;
/
