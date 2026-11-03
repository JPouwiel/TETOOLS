CREATE OR REPLACE PROCEDURE isfqdn ( p_hostname IN VARCHAR2, p_phase IN CHAR, p_is_fqdn OUT CHAR, p_is_valid_dname OUT CHAR, p_param_domain_name OUT VARCHAR2 )
  AS
    v_this_object            VARCHAR2(128);
    v_valid_phase            CHAR(1)       := 'N';
    v_phase_domain_suffix    CHAR(7)       := '_DOMAIN';
    v_valid_domain_name      CHAR(1)       := 'N';
    v_is_possible_fqdn       CHAR(1)       := 'N';
    v_is_fqdn                CHAR(1)       := 'N';
    v_count_domain           NUMBER;
    v_is_correct_phase       CHAR(1)       := 'N';
    v_full_phase_domain_pref VARCHAR2(8);
    v_phase_domain_name      VARCHAR2(14);
    not_correct_phase        EXCEPTION;
    no_valid_domain          EXCEPTION;
    generic_error            EXCEPTION;
  BEGIN
  	--
    tetools.admin_tnsnames.who_called(v_this_object);
    --
    -- 1  heeft de p_hostname 4 of meer punten in de naam => vindt plaats in [[eval_hostname]]
    -- 2a bij 4 of meer punten; bestaat v_phase als pref_name
    -- 2b wat is het gegeven domein van v_hostname
    -- 3a  als v_phase bestaat; komt het domein van de v_hostname overeen met de pref_value
    --
    -- 2a
    v_full_phase_domain_pref := UPPER(p_phase)||v_phase_domain_suffix;
    WITH c_test_phase AS
     (SELECT COUNT(pref_name) NUM FROM tetools.admin_tnsnames_prefs WHERE pref_name=v_full_phase_domain_pref)
     SELECT CASE WHEN c_test_phase.num = 1 THEN 'Y' ELSE 'N' END INTO v_valid_phase FROM c_test_phase;
    -- 2b
    --SELECT NVL(REGEXP_SUBSTR(UPPER(p_hostname), '['|| UPPER(v_phase) || ']{1}-DC\.BA\.UWV\.NL(\/.*)?$'), 'INCORRECT_PHASE') INTO v_phase_domain_name FROM dual;
    --SELECT NVL(REGEXP_SUBSTR(UPPER(p_hostname), '[^."]+', 1, 1), 'INCORRECT_FORMAT') INTO v_param_domain_name FROM dual;
    SELECT SUBSTR(p_hostname, INSTR(p_hostname,'.', -1, 4) + 1) INTO p_param_domain_name FROM dual;
    -- 3a
    IF v_valid_phase = 'N' THEN
      p_is_valid_dname := 'N';
      RAISE not_correct_phase;
    ELSE
      p_is_valid_dname := v_valid_phase;
    END IF;

    WITH c_verify_domain AS
     (SELECT COUNT(pref_value) NUM FROM  tetools.admin_tnsnames_prefs WHERE pref_name=v_full_phase_domain_pref AND pref_value=v_param_domain_name)
     SELECT CASE WHEN c_verify_domain = 1 THEN 'Y' ELSE 'N' END INTO v_valid_domain_name FROM c_verify_domain;
    IF v_valid_domain_name = 'N' THEN
      RAISE no_valid_domain;
    ELSE
      p_is_valid_dname := v_valid_domain_name;
    END IF;
    --
    EXCEPTION
    WHEN not_correct_phase THEN
      DBMS_OUTPUT.PUT_LINE(v_this_object|| ' > 4021918122 '|| DBMS_UTILITY.format_error_stack);
    WHEN generic_error THEN
      DBMS_OUTPUT.PUT_LINE(v_this_object|| ' > 5491615119 '|| DBMS_UTILITY.format_error_stack);
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE(v_this_object|| ' > 0881191835 '|| DBMS_UTILITY.format_error_stack);
  END;
/* valid ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */




    SELECT NVL(REGEXP_SUBSTR(UPPER(p_hostname), '['|| UPPER(p_phase) || ']{1}-DC\.BA\.UWV\.NL(\/.*)?$'), 'INCORRECT_PHASE') INTO v_phase_domain_name
        FROM admin_tnsnames_prefs
       WHERE pref_name = v_full_phase_domain_pref;


/* host_name --------------------------------------------- */
select regexp_substr(demo_value, '(.*?)(\.|$)', 1, 1, NULL, 1) reg
  from admin_tnsnames_demo
 where REGEXP_LIKE(demo_value, '^([a-zA-Z.-]*)$');

/* domain_name ------------------------------------------- */
SELECT demo_value,
       INSTR(demo_value,'.', -1, 4) count,
       substr(demo_value, INSTR(demo_value,'.', -1, 4) + 1) reg
  from admin_tnsnames_demo
 where REGEXP_LIKE(demo_value, '^([a-zA-Z.-]*)$');




    SELECT 'Y' INTO v_valid_phase
      FROM admin_tnsnames_prefs
     WHERE pref_name = v_full_phase_domain_pref;
    --
    IF v_valid_phase = 'N' THEN
      RAISE not_correct_phase;
    ELSIF v_valid_phase != 'Y' THEN
      RAISE generic_error;
    ELSIF v_valid_phase = 'Y' THEN
      SELECT CASE
               WHEN REGEXP_SUBSTR(UPPER(pref_value), '^[' || UPPER(v_phase) || ']{1}') = UPPER(v_phase) THEN 'Y'
               ELSE 'N'
             END INTO v_is_correct_phase
        FROM admin_tnsnames_prefs
       WHERE pref_name = v_full_phase_domain_pref;;
    END IF;
    --
    SELECT CASE
         WHEN REGEXP_COUNT (p_hostname, '[.]') >= v_count_domain THEN 'Y'
         ELSE 'N'
         END INTO v_is_possible_fqdn
    FROM dual;
    --
    IF v_is_possible_fqdn = 'Y' THEN
      SELECT NVL(REGEXP_SUBSTR(UPPER(v_hostname1), '['|| UPPER(v_phase) || ']{1}-DC\.BA\.UWV\.NL(\/.*)?$'), 'INCORRECT_PHASE') INTO v_phase_domain_name
        FROM admin_tnsnames_prefs
       WHERE pref_name = v_full_phase_domain_pref;
      IF v_phase_domain_name != 'INCORRECT_PHASE' THEN
        p_is_valid_dname    = 'Y';
        p_is_fqdn           = 'Y';
        p_phase_domain_name = v_phase_domain_name;
      --
      --SELECT NVL(pref_value, 'X') INTO v_phase_domain_name
      --    FROM admin_tnsnames_prefs
      --   WHERE pref_name = v_full_phase_domain_pref;
      --
      --IF v_valid_domain_name = 'Y' AND v_phase_domain_name = v_param_domain_name THEN
      --  p_is_valid_dname := 'Y';
      --END if;


select demo_id, demo_value full, REGEXP_SUBSTR(upper(demo_value), '[^."]+', 1, 1) reg1
  from admin_tnsnames_demo
 where demo_key='HOST_NAME'
   and REGEXP_LIKE(demo_value, '^([a-zA-Z]{1})([a-zA-Z0-9.-]*|[a-zA-Z0-9-]*|[a-zA-Z0-9]*|[a-zA-Z0-9]*)$');


SELECT demo_value col1,NVL(REGEXP_SUBSTR(UPPER(REGEXP_SUBSTR(demo_value,'^([a-zA-Z]{2})([a-zA-Z0-9.-]*|[a-zA-Z0-9-]*|[a-zA-Z0-9]*|[a-zA-Z0-9]*)$')), '[^."]+', 1, 1), 'X') col2
      FROM admin_tnsnames_demo
 where demo_key='HOST_NAME' ORDER BY 1;




DECLARE
  v_hostname               varchar2(128);
  v_count_periods          NUMBER;
  v_phase                  CHAR(1)       := 'T';
  v_continue               CHAR(1)       := 'N';
  v_is_fqdn                CHAR(1);
  v_is_numeral             CHAR(1);
  v_is_valid_ip            CHAR(1);
  v_is_valid_phase         CHAR(1);
  v_valid_domain_name      CHAR(1)       := 'N';
  v_phase_domain_name      VARCHAR2(128);
  v_param_host_name        VARCHAR2(128);
  v_valid_shortname        VARCHAR2(128);
  v_param_domain_name      VARCHAR2(128);
  CURSOR c_hostname IS
  SELECT demo_value FROM ADMIN_TNSNAMES_DEMO WHERE demo_key='HOST_NAME' AND UPPER(DEMO_VALUE) LIKE '%T-DC%' AND ROWNUM < 11;
BEGIN
	FOR row IN c_hostname
    LOOP
      tetools.admin_tnsnames.eval_hostname( row.demo_value, v_phase, v_is_numeral, v_is_valid_ip, v_is_valid_phase, v_is_fqdn, v_valid_domain_name, v_param_host_name, v_param_domain_name, v_continue);
      --PROCEDURE eval_hostname ( row.demo_value, v_phase, v_is_numeral, v_is_valid_ip, v_is_valid_phase, v_is_fqdn, v_valid_domain_name, v_param_host_name, v_param_domain_name, v_continue);
      DBMS_OUTPUT.PUT_LINE('HOST_NAME: '||row.demo_value||'; FASE: '||v_phase||'; IS_NUM: '||v_is_numeral||'; IP_VALID: '||v_is_valid_ip||'; FASE_VALID: '||v_is_valid_phase||'; FQDN: '||v_is_fqdn||'; DNAME_VALID: '||v_valid_domain_name||'; HOST: '||v_param_host_name||'; DOMAIN: '||v_param_domain_name||'; CONTINUE?: '||v_continue);
	  END LOOP;
END;


HOST_NAME: example.invalid;              FASE: T; IS_NUM: N; IP_VALID: N; FASE_VALID: Y; FQDN: Y; DNAME_VALID: Y; HOST: HOST;            DOMAIN: example.invalid; CONTINUE?: Y
HOST_NAME: example.invalid;          FASE: T; IS_NUM: N; IP_VALID: N; FASE_VALID: Y; FQDN: Y; DNAME_VALID: Y; HOST: HOST;            DOMAIN: example.invalid; CONTINUE?: Y
HOST_NAME: example.invalid;    FASE: T; IS_NUM: N; IP_VALID: N; FASE_VALID: Y; FQDN: Y; DNAME_VALID: Y; HOST: ABR-T6-DB;       DOMAIN: example.invalid; CONTINUE?: Y
HOST_NAME: example.invalid;     FASE: T; IS_NUM: N; IP_VALID: N; FASE_VALID: Y; FQDN: Y; DNAME_VALID: Y; HOST: DBHOTEL3;        DOMAIN: example.invalid; CONTINUE?: Y
HOST_NAME: example.invalid;   FASE: T; IS_NUM: N; IP_VALID: N; FASE_VALID: Y; FQDN: Y; DNAME_VALID: Y; HOST: host-demo; DOMAIN: example.invalid; CONTINUE?: Y
HOST_NAME: example.invalid;   FASE: T; IS_NUM: N; IP_VALID: N; FASE_VALID: Y; FQDN: Y; DNAME_VALID: Y; HOST: host-demo; DOMAIN: example.invalid; CONTINUE?: Y
HOST_NAME: example.invalid;   FASE: T; IS_NUM: N; IP_VALID: N; FASE_VALID: Y; FQDN: Y; DNAME_VALID: Y; HOST: host-demo; DOMAIN: example.invalid; CONTINUE?: Y
HOST_NAME: example.invalid;   FASE: T; IS_NUM: N; IP_VALID: N; FASE_VALID: Y; FQDN: Y; DNAME_VALID: Y; HOST: host-demo; DOMAIN: example.invalid; CONTINUE?: Y
HOST_NAME: example.invalid;   FASE: T; IS_NUM: N; IP_VALID: N; FASE_VALID: Y; FQDN: Y; DNAME_VALID: Y; HOST: host-demo; DOMAIN: example.invalid; CONTINUE?: Y
HOST_NAME: example.invalid; FASE: T; IS_NUM: N; IP_VALID: N; FASE_VALID: Y; FQDN: Y; DNAME_VALID: Y; HOST: WERKNL-T3-DB;    DOMAIN: example.invalid; CONTINUE?: Y

PL/SQL procedure successfully completed.

notify('4021918122', v_this_object, DBMS_UTILITY.format_error_stack);
DBMS_OUTPUT.PUT_LINE(v_caller|| ' > '|| v_message_num || ' ' ||v_message_string);
notify(i,' ad-hoc ', x(i).function_name);
 > 3790595218
---------------------- >
 ad-hoc  > 7

notify('3790595218', NULL, NULL);
notify(NULL, '----------------------', NULL);
notify(i,' ad-hoc ', x(i).function_name);
notify(i,' ad-hoc ', x(i).function_value);
notify(i,' ad-hoc ', x(i).function_severity);
notify(i,' ad-hoc ', x(i).function_flag);





DECLARE
  v_hostname               varchar2(128);
  v_count_periods          NUMBER;
  v_phase                  VARCHAR2(128)    := 'F';
  v_force                  VARCHAR2(128)    := 'Y';
  v_continue               VARCHAR2(128)    := 'N';
  v_is_fqdn                VARCHAR2(128)    := 'N';
  v_is_numeral             VARCHAR2(128)    := 'N';
  v_is_valid_ip            VARCHAR2(128)    := 'N';
  v_is_valid_phase         VARCHAR2(128)    := 'N';
  v_valid_domain_name      VARCHAR2(128)    := 'N';
  v_phase_domain_name      VARCHAR2(128);
  v_param_host_name        VARCHAR2(128);
  v_valid_shortname        VARCHAR2(128);
  v_param_domain_name      VARCHAR2(128);
  CURSOR c_hostname IS
  SELECT demo_value FROM ADMIN_TNSNAMES_DEMO WHERE demo_key='HOST_NAME' AND UPPER(DEMO_VALUE) LIKE '%T-DC%' AND ROWNUM < 20;
  CURSOR c_hostname_select IS
    SELECT demo_value FROM ADMIN_TNSNAMES_DEMO WHERE demo_key='HOST_NAME' AND DEMO_VALUE IN ('example.invalid', 'example.invalid', 'example.invalid');
BEGIN
	FOR row IN c_hostname_select
    LOOP
      --tetools.admin_tnsnames.eval_hostname( row.demo_value, v_phase, v_is_numeral, v_is_valid_ip, v_is_valid_phase, v_is_fqdn, v_valid_domain_name, v_param_host_name, v_param_domain_name, v_continue);
      --eval_hostname ( row.demo_value, v_phase, v_force, v_is_numeral, v_is_valid_ip, v_is_valid_phase, v_is_fqdn, v_valid_domain_name, v_param_host_name, v_param_domain_name, v_continue);
      --DBMS_OUTPUT.PUT_LINE('HOST_NAME: '||row.demo_value||'; FASE: '||v_phase||'; IS_NUM: '||v_is_numeral||'; IP_VALID: '||v_is_valid_ip||'; FASE_VALID: '||v_is_valid_phase||'; FQDN: '||v_is_fqdn||'; DNAME_VALID: '||v_valid_domain_name||'; HOST: '||v_param_host_name||'; DOMAIN: '||v_param_domain_name||'; CONTINUE?: '||v_continue);
      eval_hostname ( row.demo_value, v_phase, v_force, v_is_numeral, v_is_valid_ip, v_is_valid_phase, v_is_fqdn, v_valid_domain_name, v_param_host_name, v_param_domain_name, v_continue);
      --DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');
      --DBMS_OUTPUT.PUT_LINE('HOST_NAME         : '||row.demo_value);
      --DBMS_OUTPUT.PUT_LINE('IS_NUMERAL        : *'||v_is_numeral||'*');
      --DBMS_OUTPUT.PUT_LINE('IS_VALID_IP       : *'||v_is_valid_ip||'*');
      --DBMS_OUTPUT.PUT_LINE('FASE_VALID        : *'||v_is_valid_phase||'*');
      --DBMS_OUTPUT.PUT_LINE('FQDN              : *'||v_is_fqdn||'*');
      --DBMS_OUTPUT.PUT_LINE('DNAME_VALID       : *'||v_valid_domain_name||'*');
      --DBMS_OUTPUT.PUT_LINE('PARAM HOST_NAME   : *'||v_param_host_name||'*');
      --DBMS_OUTPUT.PUT_LINE('PARAM DOMAIN_NAME : *'||v_param_domain_name||'*');
      --DBMS_OUTPUT.PUT_LINE('CONTINUE?         : *'||v_continue||'*');
	  END LOOP;
END;


DECLARE
  v_hostname               varchar2(128);
  v_count_periods          NUMBER;
  v_phase                  CHAR(1)    := 'T';
  v_force                  CHAR(1)    := 'Y';
  v_continue               CHAR(1)    := 'N';
  v_is_fqdn                CHAR(1)    := 'N';
  v_is_numeral             CHAR(1)    := 'N';
  v_is_valid_ip            CHAR(1)    := 'N';
  v_is_valid_phase         CHAR(1)    := 'N';
  v_valid_domain_name      CHAR(1)    := 'N';
  v_feedback_string        VARCHAR2(128);
  v_phase_domain_name      VARCHAR2(128);
  v_param_host_name        VARCHAR2(128);
  v_param_host_name_isfqdn VARCHAR2(128);
  v_param_host_name_eval   VARCHAR2(128);
  v_valid_shortname        VARCHAR2(128);
  v_param_domain_name      VARCHAR2(128);
  CURSOR c_hostname IS
    SELECT demo_value FROM ADMIN_TNSNAMES_DEMO WHERE demo_key='HOST_NAME' AND UPPER(DEMO_VALUE) LIKE '%T-DC%' OR REGEXP_LIKE(demo_value, '^([0-9.]*)$');
  CURSOR c_hostname_test IS
    SELECT demo_value FROM ADMIN_TNSNAMES_DEMO WHERE demo_key='HOST_NAME' AND ((NOT UPPER(DEMO_VALUE) LIKE '%P-DC%' OR NOT UPPER(DEMO_VALUE) LIKE '%H-DC%') OR REGEXP_LIKE(demo_value, '^([0-9.]*)$'));
  CURSOR c_hostname_select IS
    SELECT demo_value FROM ADMIN_TNSNAMES_DEMO WHERE demo_key='HOST_NAME' AND DEMO_VALUE IN ('example.invalid', 'example.invalid', 'example.invalid');
  CURSOR c_hostname_een IS
    SELECT demo_value FROM ADMIN_TNSNAMES_DEMO WHERE demo_key='HOST_NAME' AND DEMO_VALUE IN ('example.invalid');
  CURSOR c_hostname_www IS
    SELECT demo_value FROM ADMIN_TNSNAMES_DEMO WHERE demo_key='HOST_NAME' AND DEMO_VALUE LIKE '%example%';
  CURSOR c_hostname_all IS
    SELECT demo_value FROM ADMIN_TNSNAMES_DEMO WHERE demo_key='HOST_NAME';
  CURSOR c_hostname_ipaddress IS
    SELECT demo_value FROM ADMIN_TNSNAMES_DEMO WHERE demo_key='HOST_NAME' AND (REGEXP_LIKE(demo_value, '^([0-9.]*)$') OR demo_value LIKE '%example%' OR demo_value LIKE 'a%');
  CURSOR c_hostname_uwv IS
    SELECT demo_value FROM ADMIN_TNSNAMES_DEMO WHERE demo_key='HOST_NAME' AND UPPER(demo_value) LIKE UPPER('UWV%');
BEGIN
	FOR row IN c_hostname_test
    LOOP
      tetools.admin_tnsnames.eval_hostname ( row.demo_value, v_phase, v_force, v_is_numeral, v_is_valid_ip, v_is_valid_phase, v_is_fqdn, v_valid_domain_name, v_feedback_string, v_param_host_name, v_param_domain_name, v_continue);
      --eval_hostname ( row.demo_value, v_phase, v_force, v_is_numeral, v_is_valid_ip, v_is_valid_phase, v_is_fqdn, v_valid_domain_name, v_param_host_name, v_param_domain_name, v_continue);
      IF v_continue = 'N' THEN
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('HOST_NAME           : '||row.demo_value);
        DBMS_OUTPUT.PUT_LINE('v_phase             : *'||v_phase||'*');
        DBMS_OUTPUT.PUT_LINE('v_force             : *'||v_force||'*');
        DBMS_OUTPUT.PUT_LINE('v_is_numeral        : *'||v_is_numeral||'*');
        DBMS_OUTPUT.PUT_LINE('v_is_valid_ip       : *'||v_is_valid_ip||'*');
        DBMS_OUTPUT.PUT_LINE('v_is_valid_phase    : *'||v_is_valid_phase||'*');
        DBMS_OUTPUT.PUT_LINE('v_is_fqdn           : *'||v_is_fqdn||'*');
        DBMS_OUTPUT.PUT_LINE('v_valid_domain_name : *'||v_valid_domain_name||'*');
        DBMS_OUTPUT.PUT_LINE('v_feedback_string?  : *'||v_feedback_string||'*');
        DBMS_OUTPUT.PUT_LINE('v_param_host_name   : *'||v_param_host_name||'*');
        DBMS_OUTPUT.PUT_LINE('v_param_domain_name : *'||v_param_domain_name||'*');
        DBMS_OUTPUT.PUT_LINE('v_continue?         : *'||v_continue||'*');
    END IF;
	END LOOP;
END;



DECLARE
  v_port                   VARCHAR2(6)          := 1521;
  v_continue               CHAR(1);
  v_is_numeral             CHAR(1);
  v_is_1k                  CHAR(1);
  v_default_port           CHAR(1);
  v_port_range_expected    CHAR(1);
BEGIN
  port_checker(v_port, v_is_numeral, v_is_1k, v_default_port, v_port_range_expected, v_continue );
  DBMS_OUTPUT.PUT_LINE('numeral: '||v_is_numeral||', 1k: '||v_is_1k||', default: '||v_default_port||', range: '||v_port_range_expected||', continue: '||v_continue);
END;
/





DECLARE
  v_is_numeral             CHAR(1);
  v_is_1k                  CHAR(1);
  v_default_port           CHAR(1);
  v_port_range_expected    CHAR(1);
  v_phase                  CHAR(1);
  v_phase_out              CHAR(1);
  v_force                  CHAR(1);
  v_port                   INTEGER              := 1521;
  v_service_name           VARCHAR2(128)        := 'foobar';
  v_service_name_out       VARCHAR2(128);
  v_tns_alias              VARCHAR2(128)        := 'maandag_';
  v_target_envs            VARCHAR2(4)          := 'T';
  v_host_name              VARCHAR2(128);
  v_is_valid_ip            CHAR(1);
  v_is_valid_phase         CHAR(1);
  v_is_fqdn                CHAR(1);
  v_is_valid_dname         CHAR(1);
  v_does_exist             CHAR(1);
  v_param_hostname         VARCHAR2(128);
  v_param_domain_name      VARCHAR2(128);
  v_feedback               VARCHAR2(128);
  v_json                   VARCHAR2(4000);
  v_continue               CHAR(1);
  i                        NUMBER              := 0;
  CURSOR c_hostname IS
    SELECT demo_value FROM ADMIN_TNSNAMES_DEMO WHERE demo_key='HOST_NAME' AND UPPER(DEMO_VALUE) LIKE '%T-DC%' OR REGEXP_LIKE(demo_value, '^([0-9.]*)$');
  CURSOR c_hostname_test IS
    select demo_value from admin_tnsnames_demo
     where demo_key = 'HOST_NAME'
       AND ((NOT UPPER(DEMO_VALUE) LIKE '%P-DC%' AND NOT UPPER(DEMO_VALUE) LIKE '%HRC%') OR REGEXP_LIKE(demo_value, '^([0-9.]*)$'));
  CURSOR c_hostname_all IS
    SELECT demo_value FROM ADMIN_TNSNAMES_DEMO WHERE demo_key='HOST_NAME';
  CURSOR c_tns_combo IS
    SELECT demo_value FROM admin_tnsnames_demo
     WHERE demo_key = 'HOST_NAME'
       AND (UPPER(DEMO_VALUE) LIKE '%T-DC%' OR REGEXP_LIKE(demo_value, '^([0-9.]*)$')) OR demo_key = 'TNS_ALIAS';
BEGIN
	FOR row IN c_tns_combo
    LOOP
      i := i +1;
      IF MOD(i, 2) = 0 THEN v_phase := 'P'; ELSE v_phase := 'T'; END IF;
      IF MOD(i, 3) = 0 THEN v_force := 'Y'; ELSE v_force := 'N'; END IF;
      --
      --SELECT tns_alias INTO v_tns_alias FROM (SELECT demo_value AS tns_alias FROM admin_tnsnames_demo where demo_key='TNS_ALIAS' ORDER BY DBMS_RANDOM.RANDOM) WHERE rownum < 2;
      --
      existing_tns(row.demo_value, v_phase, v_does_exist, v_phase_out, v_host_name, v_service_name_out);
      --
      IF v_does_exist = 'Y' THEN
        report_existing (row.demo_value, v_does_exist, v_phase_out, v_host_name, v_service_name_out );
        --DBMS_OUTPUT.PUT_LINE('ZEEHOND:      '||v_phase||' '||row.demo_value||' '||v_service_name_out);
        --DBMS_OUTPUT.PUT_LINE('      '||v_phase_out||' '||v_host_name||' '||v_service_name_out);
      ELSE
        NULL;
        --DBMS_OUTPUT.PUT_LINE('TIJGER:      '||v_phase||' '||row.demo_value||' '||v_service_name_out);
          --register_tns( row.demo_value,
          --              v_phase,
          --              v_force,
          --              v_port,
          --              v_service_name,
          --              v_target_envs,
          --              v_is_valid_ip,
          --              v_is_valid_phase,
          --              v_is_fqdn,
          --              v_is_valid_dname,
          --              v_param_hostname,
          --              v_param_domain_name,
          --              v_feedback,
          --              v_is_numeral,
          --              v_is_1k,
          --              v_default_port,
          --              v_port_range_expected,
          --              v_continue );
          --SELECT JSON_OBJECT('tns_alias'            VALUE v_tns_alias,
          --                   'host_name'            VALUE row.demo_value,
          --                   'target_phase'         VALUE v_phase,
          --                   'forced'               VALUE v_force,
          --                   'port'                 VALUE v_port,
          --                   'service_name'         VALUE v_service_name,
          --                   'target_envs'          VALUE v_target_envs,
          --                   'ip_validation'        VALUE v_is_valid_ip,
          --                   'phase_validation'     VALUE v_is_valid_phase,
          --                   'fqdn_validation'      VALUE v_is_fqdn,
          --                   'dname_validation'     VALUE v_is_valid_dname,
          --                   'shortname'            VALUE v_param_hostname,
          --                   'domainname'           VALUE v_param_domain_name,
          --                   'feedback'             VALUE v_feedback,
          --                   'numeral_validation'   VALUE v_is_numeral,
          --                   'numport_validation'   VALUE v_is_numeral,
          --                   'thousands_validation' VALUE v_is_1k,
          --                   'port_validation'      VALUE v_default_port,
          --                   'range_validation'     VALUE v_port_range_expected,
          --                   'continue'             VALUE v_continue)
          --       INTO v_json
          --  FROM dual;
          --report(v_json);
        END IF;
      --END IF;
    END LOOP;
END;
/





  CURSOR c_hostname_select IS
    SELECT demo_value FROM ADMIN_TNSNAMES_DEMO WHERE demo_key='HOST_NAME' AND DEMO_VALUE IN ('example.invalid', 'example.invalid', 'example.invalid');
  CURSOR c_hostname_een IS
    SELECT demo_value FROM ADMIN_TNSNAMES_DEMO WHERE demo_key='HOST_NAME' AND DEMO_VALUE IN ('example.invalid');
  CURSOR c_hostname_www IS
    SELECT demo_value FROM ADMIN_TNSNAMES_DEMO WHERE demo_key='HOST_NAME' AND DEMO_VALUE LIKE '%example%';
  CURSOR c_hostname_ipaddress IS
    SELECT demo_value FROM ADMIN_TNSNAMES_DEMO WHERE demo_key='HOST_NAME' AND (REGEXP_LIKE(demo_value, '^([0-9.]*)$') OR demo_value LIKE '%example%' OR demo_value LIKE 'a%');
  CURSOR c_hostname_uwv IS
    SELECT demo_value FROM ADMIN_TNSNAMES_DEMO WHERE demo_key='HOST_NAME' AND UPPER(demo_value) LIKE UPPER('UWV%');

        --DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');
        --DBMS_OUTPUT.PUT_LINE('i: '||i||'    hostname: '||row.demo_value||'       cont: '||v_continue);
        ----DBMS_OUTPUT.PUT_LINE('HOST_NAME           : '||row.demo_value);
        ----DBMS_OUTPUT.PUT_LINE('v_is_valid_ip       : *'||v_is_valid_ip||'*');
        --DBMS_OUTPUT.PUT_LINE('v_is_valid_phase    : *'||v_is_valid_phase||'*');
        --DBMS_OUTPUT.PUT_LINE('v_is_fqdn?          : *'||v_is_fqdn||'*');
        ----DBMS_OUTPUT.PUT_LINE('v_is_valid_dname    : *'||v_is_valid_dname||'*');
        --DBMS_OUTPUT.PUT_LINE('v_param_hostname    : *'||v_param_hostname||'*');
        ----DBMS_OUTPUT.PUT_LINE('v_param_domain_name : *'||v_param_domain_name||'*');
        ----DBMS_OUTPUT.PUT_LINE('v_continue?         : *'||v_continue||'*');


CREATE OR REPLACE PROCEDURE ipaddress_checker ( p_hostname IN VARCHAR2, p_numperiods OUT INTEGER, p_isnumeral OUT CHAR, p_isvalidip OUT CHAR, p_feedback OUT INTEGER ) AS
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
      p_feedback                                                          := 0;
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
/

CREATE OR REPLACE PROCEDURE phase_checker ( p_hostname IN VARCHAR, p_phase IN CHAR, p_isphasevalid OUT CHAR ) AS
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
/

CREATE OR REPLACE PROCEDURE ipaddress_checker ( p_hostname IN VARCHAR2, p_numperiods OUT INTEGER, p_isnumeral OUT CHAR, p_isvalidip OUT CHAR, p_feedback OUT INTEGER ) AS
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
    p_feedback                                                          := 1;
  ELSIF v_is_numeral = 'Y' AND v_count_periods > 3 THEN
    p_feedback                                                          := 2;
  ELSIF v_is_numeral = 'Y' AND v_count_periods < 3 THEN
    p_feedback                                                          := 3;
  ELSIF v_is_numeral = 'N' THEN
    p_feedback                                                          := 4;
  ELSE
    p_feedback                                                          := 5;
  END IF;
END ipaddress_checker;
/



DECLARE
  v_hostname               varchar2(128);
  v_numperiods             INTEGER;
  v_isnumeral              CHAR(1);
  v_isvalidip              CHAR(1);
  v_feedback               INTEGER;
  CURSOR c_hostname IS
    SELECT demo_value FROM ADMIN_TNSNAMES_DEMO WHERE demo_key='HOST_NAME' AND (REGEXP_LIKE(demo_value, '^([0-9.]*)$') OR demo_value LIKE '%example%' OR demo_value LIKE 'a%');
BEGIN
	FOR row IN c_hostname
    LOOP
	    ipaddress_checker(row.demo_value, v_numperiods, v_isnumeral, v_isvalidip, v_feedback);
      DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');
      DBMS_OUTPUT.PUT_LINE('HOST:> '||row.demo_value);
	    DBMS_OUTPUT.PUT_LINE('numperiods?: '||v_numperiods);
	    DBMS_OUTPUT.PUT_LINE('isnumeral?: '||v_isnumeral);
	    DBMS_OUTPUT.PUT_LINE('isvalidip?: '||v_isvalidip);
	    DBMS_OUTPUT.PUT_LINE('feedback?: '||v_feedback);
	  END LOOP;
END;


DECLARE
  v_hostname               varchar2(128);
  v_phase                  CHAR(1)         := 'T';
  v_isphasevalid           CHAR(1);
BEGIN
	phase_checker(v_hostname, v_phase, v_isphasevalid);
	DBMS_OUTPUT.PUT_LINE('Phase is valid?: '||v_isphasevalid);
END;

SELECT demo_value col1, NVL(REGEXP_SUBSTR(REGEXP_REPLACE(v_param_host_name_eval, '^http[s]?://(www[1]?\.)?|^www[1]?\.', '', 1), '(.+?)(/|$)'), 'X') col2 from admin_tnsnames_demo where demo_value like '%example%';
select demo_value col1, REGEXP_SUBSTR(REGEXP_REPLACE(demo_value, '^http[s]?://(www[1]?\.)?|^www[1]?\.', '', 1), '(.+?)(/|$)') col2 from admin_tnsnames_demo where demo_value like '%example%'; --where REGEXP_LIKE(demo_value, '^([0-9.]*)$');
SELECT demo_value col1, NVL(REGEXP_SUBSTR(UPPER(REGEXP_SUBSTR(demo_value,'^([a-zA-Z]{2})([a-zA-Z0-9.-]*|[a-zA-Z0-9-]*|[a-zA-Z0-9]*|[a-zA-Z0-9]*)$')), '[^."]+', 1, 1), 'X') col2 from admin_tnsnames_demo;


-- WITH sanitizer AS
-- ( SELECT NVL(REGEXP_SUBSTR(UPPER(REGEXP_SUBSTR(demo_value,'^([a-zA-Z]{2})([a-zA-Z0-9.-]*|[a-zA-Z0-9-]*|[a-zA-Z0-9]*|[a-zA-Z0-9]*)$')), '[^."]+', 1, 1), 'X') AS sani_name FROM admin_tnsnames_demo)
-- SELECT sani_name col1,
--        NVL(REGEXP_SUBSTR(REGEXP_REPLACE(sani_name, '^http[s]?://(www[1]?\.)?|^www[1]?\.', '', 1), '(.+?)(/|$)'), 'X') col2
--   from sanitizer order by 1;


--WITH sanitizer2 AS
--( SELECT NVL(REGEXP_SUBSTR(REGEXP_REPLACE(demo_value, '^http[s]?://(www[1]?\.)?|^www[1]?\.', '', 1), '(.+?)(/|$)'), 'X') AS sani_name2 FROM admin_tnsnames_demo)
--SELECT sani_name2 col1,
--       NVL(REGEXP_SUBSTR(UPPER(REGEXP_SUBSTR(sani_name2,'^([a-zA-Z]{2})([a-zA-Z0-9.-]*|[a-zA-Z0-9-]*|[a-zA-Z0-9]*|[a-zA-Z0-9]*)$')), '[^."]+', 1, 1), 'X') AS col2
--  from sanitizer2 order by 1;

SELECT NVL(REGEXP_SUBSTR(UPPER(REGEXP_SUBSTR(removehttp(demo_value),'^([a-zA-Z]{2})([a-zA-Z0-9.-]*|[a-zA-Z0-9-]*|[a-zA-Z0-9]*|[a-zA-Z0-9]*)$')), '[^."]+', 1, 1), 'X') AS col2
  from admin_tnsnames_demo order by 1;

FUNCTION shortnamer(p_hostname IN VARCHAR2) RETURN VARCHAR2 AS
    v_hostname                 VARCHAR2(128);
  BEGIN
  	SELECT NVL(REGEXP_SUBSTR(UPPER(REGEXP_SUBSTR(removehttp(p_hostname),'^([a-zA-Z]{2})([a-zA-Z0-9.-]*|[a-zA-Z0-9-]*|[a-zA-Z0-9]*|[a-zA-Z0-9]*)$')), '[^."]+', 1, 1), 'X')  INTO v_hostname FROM DUAL;
  	RETURN v_hostname;
  END shortnamer;
/


SELECT demo_value AS col1, shortnamer(demo_value) AS col2 FROM admin_tnsnames_demo order by 1;

/*      sanitize http       */
SELECT demo_value col1,regexp_replace(demo_value, '(https{0,1}:\/\/)(www){0,1}\.{0,1}', 'www.') col2 FROM admin_tnsnames_demo
 where demo_key='HOST_NAME' ORDER BY 1;
/*      validate shortname  */
SELECT demo_value col1,NVL(REGEXP_SUBSTR(UPPER(REGEXP_SUBSTR(demo_value,'^([a-zA-Z]{2})([a-zA-Z0-9.-]*|[a-zA-Z0-9-]*|[a-zA-Z0-9]*|[a-zA-Z0-9]*)$')), '[^."]+', 1, 1), 'X') col2
      FROM admin_tnsnames_demo
 where demo_key='HOST_NAME' ORDER BY 1;


FUNCTION removehttp(p_hostname IN VARCHAR2) RETURN VARCHAR2 AS
    v_hostname                 VARCHAR2(128);
  BEGIN
  	SELECT regexp_replace(p_hostname, '(https{0,1}:\/\/)(www){0,1}\.{0,1}', 'www.') INTO v_hostname FROM DUAL;
  	RETURN v_hostname;
  END removehttp;

select demo_value col1, REGEXP_SUBSTR(REGEXP_REPLACE(demo_value, '^http[s]?://(www[1]?\.)?|^www[1]?\.', '', 1), '(.+?)(/|$)') col2 from admin_tnsnames_demo where demo_value like '%example%';

CREATE OR REPLACE TYPE var_excval
  IS
  VARRAY(32) OF rec_execution_validation;



PROCEDURE isfqdn ( v_hostname IN VARCHAR2, p_phase IN CHAR, p_is_valid_phase OUT CHAR, p_is_fqdn OUT CHAR, p_is_valid_dname OUT CHAR, p_param_hostname OUT VARCHAR2, p_param_domain_name OUT VARCHAR2, p_continue OUT CHAR )
PROCEDURE isfqdn ( v_hostname, v_phase, v_is_valid_phase, v_is_fqdn, v_is_valid_dname, v_param_hostname, v_param_domain_name, v_continue )
      DBMS_OUTPUT.PUT_LINE(||'*');
      DBMS_OUTPUT.PUT_LINE(||'*');
      DBMS_OUTPUT.PUT_LINE(||'*');
      DBMS_OUTPUT.PUT_LINE(||'*');
      DBMS_OUTPUT.PUT_LINE(||'*');

DECLARE
  v_hostname               varchar2(128);
  v_count_periods          NUMBER;
  v_phase                  CHAR(1)       := 'T';
  v_continue               CHAR(1);
  v_force                  CHAR(1);
  v_is_fqdn                CHAR(1);
  v_is_numeral             CHAR(1);
  v_is_valid_ip            CHAR(1);
  v_is_valid_phase         CHAR(1);
  v_valid_domain_name      CHAR(1);
  v_phase_domain_name      VARCHAR2(128);
  v_param_host_name        VARCHAR2(128);
  v_valid_shortname        VARCHAR2(128);
  v_param_domain_name      VARCHAR2(128);
  CURSOR c_hostname IS
    SELECT demo_value FROM ADMIN_TNSNAMES_DEMO WHERE demo_key='HOST_NAME' AND UPPER(DEMO_VALUE) LIKE '%-DC%' AND  REGEXP_COUNT(demo_value, '[.]') > 3 AND NOT REGEXP_LIKE(demo_value, '^([0-9.]*)$') AND ROWNUM < 21;
  CURSOR c_hostname_select IS
    SELECT demo_value FROM ADMIN_TNSNAMES_DEMO WHERE demo_key='HOST_NAME' AND DEMO_VALUE IN ('example.invalid', 'example.invalid', 'example.invalid');
  CURSOR c_hostname_een IS
    SELECT demo_value FROM ADMIN_TNSNAMES_DEMO WHERE demo_key='HOST_NAME' AND DEMO_VALUE IN ('example.invalid');
BEGIN
	FOR row IN c_hostname_een
    LOOP
      --SELECT upper(rpad(SUBSTR(row.demo_value, INSTR(row.demo_value,'.', -1, 4) + 1), 1)) INTO v_phase FROM dual;
      --tetools.admin_tnsnames.isfqdn ( row.demo_value, v_phase, v_force, v_is_valid_phase, v_is_fqdn, v_valid_domain_name, v_param_host_name, v_param_domain_name, v_continue );
      isfqdn ( row.demo_value, v_phase, v_force, v_is_valid_phase, v_is_fqdn, v_valid_domain_name, v_param_host_name, v_param_domain_name, v_continue );
      DBMS_OUTPUT.PUT_LINE('-----------------------------------------------');
      DBMS_OUTPUT.PUT_LINE('HOST_NAME    : '||row.demo_value||'*');
      DBMS_OUTPUT.PUT_LINE('PHASE        : '||v_phase||'*');
      DBMS_OUTPUT.PUT_LINE('VALID_PHASE  : '||v_is_valid_phase||'*');
      DBMS_OUTPUT.PUT_LINE('FQDN         : '||v_is_fqdn||'*');
      DBMS_OUTPUT.PUT_LINE('VALID_DNAME  : '||v_valid_domain_name||'*');
      DBMS_OUTPUT.PUT_LINE('GVN_HOSTNAME : '||v_param_host_name||'*');
      DBMS_OUTPUT.PUT_LINE('GVN_DNMAE    : '||v_param_domain_name||'*');
      DBMS_OUTPUT.PUT_LINE('CONTINUE?    : '||v_continue||'*');
    END LOOP;
END;
/


SELECT demo_value col1, NVL(
                 REGEXP_SUBSTR(
                               UPPER(REGEXP_SUBSTR(demo_value,'^([a-zA-Z]{2})([a-zA-Z0-9.-]*|[a-zA-Z0-9-]*|[a-zA-Z0-9]*|[a-zA-Z0-9]*)$'))
                               , '[^."]+', 1, 1)
                 , 'X') col2
        FROM admin_tnsnames_demo;



CREATE OR REPLACE PROCEDURE notify (p_message_num IN NUMBER, p_caller IN VARCHAR2, p_message_string IN VARCHAR2)
AS
    v_this_object            VARCHAR2(128);
    v_caller                 VARCHAR2(512)   := p_caller;
    v_message_num            NUMBER          := p_message_num;
    v_message_string         VARCHAR2(4000)  := p_message_string;
BEGIN
	--DBMS_OUTPUT.PUT_LINE(v_caller|| ' > '|| v_message_num || ' ' ||DBMS_UTILITY.format_error_stack);
	DBMS_OUTPUT.PUT_LINE(v_caller|| ' > '|| v_message_num || ' ' ||p_message_string);
END;
/



DECLARE

   TYPE pt_array  IS TABLE OF number   INDEX BY VARCHAR2(25);
   TYPE prj_array IS TABLE OF pt_array INDEX BY VARCHAR2(25);

   pt_array_ pt_array;
   pj_array_ prj_array;

   PROCEDURE Add (
      act_  IN VARCHAR2,
      pt_   IN VARCHAR2,
      val_  IN NUMBER )
   IS
   BEGIN
      IF not pj_array_.EXISTS(act_) THEN
         pj_array_(act_) := pt_array();
      END IF;
      IF not pj_array_(act_).EXISTS(pt_) THEN
         pj_array_(act_)(pt_) := val_;
      END IF;
   END Add;

BEGIN
   Add ('A', '123', 1);
   Add ('A', '456', 2);
   Add ('B', '456', 3);

   dbms_output.put_line ( pj_array_ ('A')('123') );
   dbms_output.put_line ( pj_array_ ('A')('456') );
   dbms_output.put_line ( pj_array_ ('B')('456') );
END;
/



DECLARE
  TYPE t1 IS VARRAY(10) OF INTEGER;  -- varray of integer
  va t1 := t1(2,3,5);

  TYPE nt1 IS VARRAY(10) OF t1;      -- varray of varray of integer
  nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);

  i INTEGER;
  va1 t1;
BEGIN
  i := nva(1)(1);
  DBMS_OUTPUT.PUT_LINE('nva(1)(1) = 2  > ' || i);
  i := nva(4)(2);
  DBMS_OUTPUT.PUT_LINE('nva(4)(2) = 3  > ' || i);
  i := nva(3)(2);
  DBMS_OUTPUT.PUT_LINE('nva(3)(2) = 4  > ' || i);
  i := nva(2)(3);
  DBMS_OUTPUT.PUT_LINE('nva(2)(3) = 73 > ' || i);

  nva.EXTEND;
  nva(5) := t1(56, 32);          -- replace inner varray elements
  nva(4) := t1(45,43,67,43345);  -- replace an inner integer element
  nva(4)(4) := 1;                -- replace 43345 with 1

  nva(4).EXTEND;    -- add element to 4th varray element
  nva(4)(5) := 89;  -- store integer 89 there
  i := nva(5)(2);
  DBMS_OUTPUT.PUT_LINE('nva(5)(2) = 32 > ' || i);
END;
/



=-=-=
declare
--    type AE is record
--    (
--        term    VARCHAR2(20)
--    ,   blabla  VARCHAR2(20)
--    ,   bla     NUMBER(10)
--    ,   q       CHAR(1)
--    );
--    type G is VARRAY(5) of AE;
--

    x   G :=    G
                (
                    AE('abc', 'ooo', 12, NULL)
                ,   AE('def', 'zzz',  3, 'X')
                ,   AE('klm', 'fefd', 7, NULL)
                );

    iets    number(10);

    function    idx(p_idx VARCHAR2) return PLS_INTEGER as
    begin
        for i in 1..x.LAST
        loop
            if (x(i).term = p_idx)
            then
                return i;
            end if;
        end loop;
        return 0;
    end;


begin
--    select  max(p.bla)
--            into iets
--    from    table(x) p
--    where   p.q is not null;

    x(idx('klm')).q := 'X';

    for i in 1..x.LAST
    loop
        DBMS_OUTPUT.PUT_LINE
        (
            'term: '   ||x(i).term   ||','||
            'blabla: ' ||x(i).blabla ||','||
            'bla: '    ||x(i).bla    ||','||
            'q: '      ||x(i).q
        );
    end loop;
--    DBMS_OUTPUT.PUT_LINE('iets: '||iets);
end;
=-=-=



DECLARE
  v_hostname               varchar2(128);
  p_hostname               varchar2(128)   := 'example.invalid';
  v_shortname              varchar(128)    := 'dbhotel3';
  v_full_phase_domain_pref varchar2(128)   := 'T_DOMAIN';
  v_param_domain_name      varchar2(128)   := 'example.invalid';
  v_is_fqdn                char(1)         := 'N';
  v_filler                 number(1);
BEGIN
	--SELECT NVL('Y', 'N') INTO v_is_fqdn FROM admin_tnsnames_prefs WHERE pref_name = v_full_phase_domain_pref AND pref_value = v_param_domain_name;
	SELECT 1, NVL('Y', 'N') INTO v_filler, v_is_fqdn FROM admin_tnsnames_prefs WHERE pref_name = v_full_phase_domain_pref AND v_shortname||'.'||v_param_domain_name = p_hostname;
  DBMS_OUTPUT.PUT_LINE('v_full_phase_domain_pref: '||v_full_phase_domain_pref||'; v_param_domain_name: '||v_param_domain_name||'; v_is_fqdn: '||v_is_fqdn);
END;





SELECT CASE WHEN COUNT(*) = 0 THEN 'N'
            WHEN COUNT(*) = 1 THEN 'Y'
            ELSE 'X'
        END AS "VALID"
  FROM admin_tnsnames_prefs
 WHERE pref_name = 'T_DOMAIN'
   AND 'dbhotel3'||'.'||'example.invalid' = 'example.invalid';


SELECT CASE WHEN COUNT(*) = 0 THEN 'N'
            WHEN COUNT(*) = 1 THEN 'Y'
            ELSE 'X'
        END AS "VALID"
  FROM admin_tnsnames_prefs
 WHERE pref_name = 'X_DOMAIN'
   AND 'dbhotel3'||'.'||'example.invalid' = 'example.invalid';


WITH cte AS (
  SELECT a.pref_name AS phase, b.pref_value AS domain
    FROM            admin_tnsnames_prefs A
         INNER JOIN admin_tnsnames_prefs B  ON A.pref_name = b.pref_name
   WHERE a.pref_name LIKE 'T%'
     AND b.pref_value = 'example.invalid'
)
SELECT CASE WHEN COUNT(*) = 0 THEN 'N'
            WHEN COUNT(*) = 1 THEN 'Y'
            ELSE 'X'
        END AS "VALID"
  FROM cte
 WHERE phase = 'T_DOMAIN'
   AND 'dbhotel3'||'.'||domain = 'example.invalid';



WITH cte AS (
  SELECT a.pref_name AS phase, b.pref_value AS domain
    FROM            admin_tnsnames_prefs A
         INNER JOIN admin_tnsnames_prefs B  ON A.pref_name = b.pref_name
   WHERE a.pref_name LIKE 'T%'
     AND b.pref_value = 'example.invalid'
)
SELECT CASE WHEN COUNT(*) = 0 THEN 'N'
            WHEN COUNT(*) = 1 THEN 'Y'
            ELSE 'X'
        END AS "VALID"
  FROM cte
 WHERE phase = 'T_DOMAIN'
   AND 'dbhotel3'||'.'||domain = 'example.invalid';





DECLARE
  v_json                   VARCHAR2(4000);
BEGIN
  SELECT JSON_OBJECT('crud'            VALUE 'U',
                     'tns_id'          VALUE 21,
                     'tns_alias'       VALUE 'crud_test01',
                     'target_phase'    VALUE 'T',
                     'target_envs'     VALUE 'DTA',
                     'host_name'       VALUE 'crud_host01',
                     'service_name'    VALUE 'service01',
                     'port'            VALUE 1521,
                     'date_valid_from' VALUE '2024-08-16',
                     'description'     VALUE 'TEST description',
                     'date_valid_end'  VALUE '2099-01-01',
                     'connect_timeout' VALUE 5,
                     'retry_delay'     VALUE 7,
                     'retry_count'     VALUE 3,
                     'failover'        VALUE 'TRUE',
                     'load_balance'    VALUE NULL,
                     'cont'            VALUE 'Y')
         INTO v_json
    FROM dual;
    --
  crud(v_json);
END;
/


DECLARE
  v_json                   VARCHAR2(4000);
BEGIN
  SELECT JSON_OBJECT('crud'            VALUE 'I',
                     'tns_id'          VALUE 21,
                     'tns_alias'       VALUE 'crud_test01',
                     'target_phase'    VALUE 'T',
                     'target_envs'     VALUE 'DTA',
                     'host_name'       VALUE 'crud_host01',
                     'service_name'    VALUE 'service01',
                     'port'            VALUE 1521,
                     'date_valid_from' VALUE '2024-08-16',
                     'description'     VALUE 'TEST description',
                     'date_valid_end'  VALUE '2099-01-01',
                     'connect_timeout' VALUE NULL,
                     'retry_delay'     VALUE NULL,
                     'retry_count'     VALUE NULL,
                     'failover'        VALUE NULL,
                     'load_balance'    VALUE NULL,
                     'cont'            VALUE 'Y')
         INTO v_json
    FROM dual;
    --
  crud(v_json);
END;
/



DECLARE
  v_json                   VARCHAR2(4000);
BEGIN
  SELECT JSON_OBJECT('crud'            VALUE 'U',
                     'tns_id'          VALUE 182,
                     'tns_alias'       VALUE 'crud_test02',
                     'target_phase'    VALUE 'T',
                     'target_envs'     VALUE 'DTA',
                     'host_name'       VALUE 'crud_host02',
                     'service_name'    VALUE 'service02',
                     'port'            VALUE 1521,
                     'date_valid_from' VALUE '2024-07-16',
                     'description'     VALUE 'TEST description',
                     'date_valid_end'  VALUE '2099-01-01',
                     'connect_timeout' VALUE NULL,
                     'retry_delay'     VALUE NULL,
                     'retry_count'     VALUE NULL,
                     'failover'        VALUE NULL,
                     'load_balance'    VALUE NULL,
                     'cont'            VALUE 'Y')
         INTO v_json
    FROM dual;
    --
  crud(v_json);
END;
/





DECLARE
    v_username               VARCHAR2(128)   := SYS_CONTEXT('USERENV', 'SESSION_USER');
    CURSOR c_invuser_roles(p_inv_username IN VARCHAR2)
    IS
    SELECT  granted_role
      FROM  dba_role_privs
     WHERE  grantee = UPPER(p_inv_username);
    CURSOR c_tns_roles(p_inv_role IN VARCHAR2)
    IS
    SELECT a.match_count, a.id, b.tns_roles
       FROM (SELECT rownum AS id, count(*) match_count
               FROM tetools.admin_tnsnames_prefs
              WHERE (pref_name = 'ADMINISTRATOR_ROLE' OR pref_name = 'CONTRIBUTOR_ROLE')
              GROUP BY rownum) a,
            (SELECT rownum AS id, pref_value AS tns_roles, count(*) match_count
               FROM tetools.admin_tnsnames_prefs
              WHERE (pref_name = 'ADMINISTRATOR_ROLE' OR pref_name = 'CONTRIBUTOR_ROLE')
                AND pref_value = p_inv_role
              GROUP BY rownum, pref_value) b
      WHERE a.id = b.id(+)
        AND b.match_count >0;
BEGIN
	FOR r_row IN c_invuser_roles(v_username)
    LOOP
      --DBMS_OUTPUT.PUT_LINE(r_row.granted_role);
      FOR rr_row IN c_tns_roles(r_row.granted_role)
      LOOP
        --IF rr_row.tns_roles
          DBMS_OUTPUT.PUT_LINE(rr_row.tns_roles);
        --END IF;
      END LOOP;
    END LOOP;
END;
/






CREATE OR REPLACE FUNCTION change2null(p_input IN VARCHAR DEFAULT '0904341073') RETURN VARCHAR AS
      v_is_numeral             CHAR(1);
      p_output                 VARCHAR2(8);
    BEGIN
    	DBMS_OUTPUT.PUT_LINE('change2null input: '||p_input);
    	SELECT CASE
             WHEN REGEXP_LIKE(p_input, '^([0-9.]*)$') THEN 'Y'
                                                      ELSE 'N'
           END is_number INTO v_is_numeral
      FROM DUAL;
      --
    	DBMS_OUTPUT.PUT_LINE('change2null numeral: '||v_is_numeral);
      --
      IF v_is_numeral = 'N'                           THEN
        p_output := ''||p_input||'';
      ELSIF p_input = '0904341073'                    THEN
        p_output := 'NULL';
      END IF;
      --
    	DBMS_OUTPUT.PUT_LINE('change2null output: '||p_input);
      RETURN p_output;
    END change2null;




CREATE OR REPLACE TRIGGER TETOOLS.TRG_EMP_CUD
BEFORE INSERT OR UPDATE OR DELETE ON TETOOLS.EMP
FOR EACH ROW
DECLARE
  v_modify_date                   DATE := sysdate;
  v_svn_id                        NUMBER(4);
  v_username                      VARCHAR2(128);
  v_cud                           CHAR(1);
  v_inv_roles                     VARCHAR2(2000);
  v_isinvusr_adm                  CHAR(1);
  v_isinvusr_con                  CHAR(1);
BEGIN
	SELECT user INTO v_username FROM dual;
	SELECT FLOOR(DBMS_RANDOM.VALUE(1000, 9999)) INTO v_svn_id FROM dual;
	--
	compare_roles(v_inv_roles, v_isinvusr_adm, v_isinvusr_con);
	--
  IF INSERTING THEN
    v_cud := 'I';
  ELSIF UPDATING THEN
    v_cud := 'U';
  ELSIF DELETING THEN
    v_cud := 'D';
  END IF;
  INSERT INTO TETOOLS.emp_svn VALUES(:OLD.EMPNO + 33, :OLD.ENAME, :OLD.JOB, :OLD.MGR, :OLD.HIREDATE, :OLD.SAL, :OLD.COMM, :OLD.DEPTNO) RETURNING EMPNO INTO v_svn_id;
  INSERT INTO TETOOLS.emp_meta VALUES(v_svn_id, v_username, v_cud, NULL, v_modify_date, v_inv_roles, v_isinvusr_adm, v_isinvusr_con );
  --
END;
/



DECLARE
  v_is_numeral             CHAR(1);
  v_is_1k                  CHAR(1);
  v_default_port           CHAR(1);
  v_port_range_expected    CHAR(1);
  v_phase                  CHAR(1);
  v_phase_out              CHAR(1);
  v_force                  CHAR(1);
  v_service_name_out       VARCHAR2(128);
  v_is_valid_ip            CHAR(1);
  v_is_valid_phase         CHAR(1);
  v_is_fqdn                CHAR(1);
  v_is_valid_dname         CHAR(1);
  v_does_exist             CHAR(1);
  v_param_hostname         VARCHAR2(128);
  v_param_domain_name      VARCHAR2(128);
  v_feedback               VARCHAR2(128);
  v_json                   VARCHAR2(4000);
  v_continue               CHAR(1);
  i                        NUMBER              := 0;
  v_crud                   CHAR(1);
  v_tns_id                 NUMBER              := NULL;
  v_tns_alias              VARCHAR2(128)       := 'crud_test03';
  v_target_phase           CHAR(1)             := 'T';
  v_target_envs            VARCHAR2(128)       := 'DTA';
  v_host_name              VARCHAR2(128)       := 'crud_host03';
  v_host_name_out          VARCHAR2(128);
  v_service_name           VARCHAR2(128)       := 'service03';
  v_port                   NUMBER              := 1521;
  v_date_valid_from        VARCHAR2(128)       := '2024-10-10';
  v_description            VARCHAR2(256)       := 'TEST description 3';
  v_date_valid_end         VARCHAR2(128)       := '2099-01-01';
  v_connect_timeout        NUMBER              := NULL;
  v_retry_delay            NUMBER              := NULL;
  v_retry_count            NUMBER              := NULL;
  v_failover               VARCHAR2(5)         := NULL;
  v_load_balance           VARCHAR2(5)         := NULL;
  v_cont                   VARCHAR2(128)       := 'Y';
--    SELECT JSON_OBJECT('crud'          VALUE 'C',
--                     'tns_id'          VALUE NULL,
--                     'tns_alias'       VALUE 'crud_test02',
--                     'target_phase'    VALUE 'T',
--                     'target_envs'     VALUE 'DTA',
--                     'host_name'       VALUE 'crud_host02',
--                     'service_name'    VALUE 'service02',
--                     'port'            VALUE 1521,
--                     'date_valid_from' VALUE '2024-07-16',
--                     'description'     VALUE 'TEST description',
--                     'date_valid_end'  VALUE '2099-01-01',
--                     'connect_timeout' VALUE NULL,
--                     'retry_delay'     VALUE NULL,
--                     'retry_count'     VALUE NULL,
--                     'failover'        VALUE NULL,
--                     'load_balance'    VALUE NULL,
--                     'cont'            VALUE 'Y')
--         INTO v_json
--    FROM dual;
BEGIN
  --
  existing_tns(v_tns_alias, v_target_phase, v_tns_id, v_does_exist, v_phase_out, v_host_name_out, v_service_name_out);
  --
  IF v_does_exist = 'Y' THEN
    v_crud := 'U';
  ELSE
    v_crud := 'C';
    --register_tns( v_tns_alias,
    --              v_target_phase,
    --              v_force,
    --              v_port,
    --              v_service_name,
    --              v_target_envs,
    --              v_is_valid_ip,
    --              v_is_valid_phase,
    --              v_is_fqdn,
    --              v_is_valid_dname,
    --              v_param_hostname,
    --              v_param_domain_name,
    --              v_feedback,
    --              v_is_numeral,
    --              v_is_1k,
    --              v_default_port,
    --              v_port_range_expected,
    --              v_continue );
    register_tns( v_crud, v_tns_id, v_tns_alias, v_target_phase, v_target_envs, v_host_name, v_service_name , v_port,
                  v_date_valid_from, v_description, v_date_valid_end, v_connect_timeout,
                  v_retry_delay, v_retry_count, v_failover, v_load_balance, v_force );
  END IF;
  --
  SELECT JSON_OBJECT('crud'                 VALUE v_crud,
                     'tns_id'               VALUE v_tns_id,
                     'tns_alias'            VALUE v_tns_alias,
                     'host_name'            VALUE NVL(v_host_name_out, v_host_name),
                     'target_phase'         VALUE v_target_phase,
                     'forced'               VALUE v_force,
                     'port'                 VALUE v_port,
                     'service_name'         VALUE v_service_name,
                     'target_envs'          VALUE v_target_envs,
                     'ip_validation'        VALUE v_is_valid_ip,
                     'phase_validation'     VALUE v_is_valid_phase,
                     'fqdn_validation'      VALUE v_is_fqdn,
                     'dname_validation'     VALUE v_is_valid_dname,
                     'shortname'            VALUE v_param_hostname,
                     'domainname'           VALUE v_param_domain_name,
                     'feedback'             VALUE v_feedback,
                     'numeral_validation'   VALUE v_is_numeral,
                     'numport_validation'   VALUE v_is_numeral,
                     'thousands_validation' VALUE v_is_1k,
                     'port_validation'      VALUE v_default_port,
                     'range_validation'     VALUE v_port_range_expected,
                     'description'          VALUE v_description,
                     'continue'             VALUE v_continue)
         INTO v_json
    FROM dual;
  --
  --crud(v_json);
  --
  IF v_does_exist = 'Y' THEN
    DBMS_OUTPUT.PUT_LINE('ZEEHOND:      '||v_tns_id||' '||v_phase||' '||v_tns_alias||' '||v_service_name_out);
  ELSIF v_does_exist = 'N' THEN
    tetools.admin_tnsnames.report_registration(v_json, v_tns_id );
  END IF;
END;
/


declare
  v_status                 VARCHAR2(11)   := 'DISABLED';
  v_role                   VARCHAR(2000)  := 'No contributor';
  v_cont                   CHAR(1)        := 'N';
begin
  --tetools.admin_tnsnames.report_status(v_status,v_role,v_cont);
  tetools.admin_tnsnames.tnsnames_status(v_status,v_role,v_cont);
  --DBMS_OUTPUT.PUT_LINE('MAINTENANCE STATUS: '||v_status||'; ASSIGNED ROLE(S): '||v_role||'; CONTINUE?: '||v_cont);
  --
  tetools.admin_tnsnames.query_tns('crud_test02', 'T');
end;
/


/* 20241010 001 
DECLARE
  v_force                  CHAR(1)             := 'N';
  v_tns_alias              VARCHAR2(128)       := 'crud_test05';
  v_target_phase           CHAR(1)             := 'T';
  v_target_envs            VARCHAR2(128)       := 'DTA';
  v_hostname               VARCHAR2(128)       := 'crud_host05';
  v_servicename            VARCHAR2(128)       := 'service05';
  v_port                   NUMBER              := 1522;
  v_date_valid_from        VARCHAR2(128)       := '2024-10-10';
  v_description            VARCHAR2(256)       := 'TEST description 5';
  v_date_valid_end         VARCHAR2(128)       := '2099-01-01';
  v_connect_timeout        NUMBER              := NULL;
  v_retry_delay            NUMBER              := NULL;
  v_retry_count            NUMBER              := NULL;
  v_failover               VARCHAR2(5)         := NULL;
  v_load_balance           VARCHAR2(5)         := NULL;
  --
  v_tns_id                 INTEGER;
  v_is_numeral             CHAR(1);
  v_phase                  CHAR(1);
  v_phase_out              CHAR(1);
  v_does_exist             CHAR(1);
  v_json                   VARCHAR2(4000);
  i                        NUMBER              := 0;
  v_crud                   CHAR(1);
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
  v_cont                   CHAR(1);
BEGIN
	--
  tetools.admin_tnsnames.tnsnames_status(v_status,v_role,v_cont);
  --
  tetools.admin_tnsnames.query_tns(v_tns_alias, v_target_phase, v_does_exist);
  --DBMS_OUTPUT.PUT_LINE('v_does_exist: '||v_does_exist);
  --
  IF v_does_exist = 'Y' THEN
    v_crud := 'U';
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
  ELSE
    v_crud := 'C';
    register_tns( v_crud, 
              v_tns_id, 
              v_tns_alias, 
              v_target_phase, 
              v_target_envs, 
              v_hostname, 
              v_servicename , 
              v_port,
              v_date_valid_from,
              v_description, 
              v_date_valid_end, 
              v_connect_timeout,
              v_retry_delay, 
              v_retry_count, 
              v_failover, 
              v_load_balance, 
              v_force );
    --
    SELECT JSON_OBJECT('crud'                 VALUE v_crud,
                       'tns_id'               VALUE v_tns_id,
                       'tns_alias'            VALUE v_tns_alias,
                       'host_name'            VALUE NVL(v_hostname_out, v_hostname),
                       'target_phase'         VALUE v_target_phase,
                       'forced'               VALUE v_force,
                       'port'                 VALUE v_port,
                       'service_name'         VALUE v_servicename,
                       'target_envs'          VALUE v_target_envs,
                       'ip_validation'        VALUE v_is_valid_ip,
                       'phase_validation'     VALUE v_is_valid_phase,
                       'fqdn_validation'      VALUE v_is_fqdn,
                       'dname_validation'     VALUE v_is_valid_dname,
                       'shortname'            VALUE v_param_hostname,
                       'domainname'           VALUE v_param_domain_name,
                       'feedback'             VALUE v_feedback,
                       'numeral_validation'   VALUE v_is_numeral,
                       'numport_validation'   VALUE v_is_numeral,
                       'thousands_validation' VALUE v_is_1k,
                       'port_validation'      VALUE v_default_port,
                       'range_validation'     VALUE v_port_range_expected,
                       'description'          VALUE v_description,
                       'continue'             VALUE v_continue)
           INTO v_json
      FROM dual;
    --

    tetools.admin_tnsnames.report_registration(v_json, v_tns_id );
  END IF;
  --
END;
/
*/

/* 20241010 002
DECLARE
  v_force                  CHAR(1)             := 'N';
  v_tns_alias              VARCHAR2(128)       := 'crud_test05';
  v_target_phase           CHAR(1)             := 'T';
  v_target_envs            VARCHAR2(128)       := 'DTA';
  v_hostname               VARCHAR2(128)       := 'crud_host05';
  v_servicename            VARCHAR2(128)       := 'service05';
  v_port                   NUMBER              := 1522;
  v_date_valid_from        VARCHAR2(128)       := '2024-10-10';
  v_description            VARCHAR2(256)       := 'TEST description 5';
  v_date_valid_end         VARCHAR2(128)       := '2099-01-01';
  v_connect_timeout        NUMBER              := NULL;
  v_retry_delay            NUMBER              := NULL;
  v_retry_count            NUMBER              := NULL;
  v_failover               VARCHAR2(5)         := NULL;
  v_load_balance           VARCHAR2(5)         := NULL;
  --
  v_tns_id                 INTEGER;
  v_is_numeral             CHAR(1);
  v_phase                  CHAR(1);
  v_phase_out              CHAR(1);
  v_does_exist             CHAR(1);
  v_json                   VARCHAR2(4000);
  i                        NUMBER              := 0;
  v_crud                   CHAR(1);
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
  v_cont                   CHAR(1);
BEGIN
	--
  --tetools.admin_tnsnames.tnsnames_status(v_status,v_role,v_cont);
  --
  --tetools.admin_tnsnames.query_tns(v_tns_alias, v_target_phase, v_does_exist);
  --
  --existing_tns(v_tns_alias, v_target_phase, v_tns_id, v_does_exist, v_phase_out, v_hostname_out, v_servicename_out);
  --
  --tetools.admin_tnsnames.validate_tns( v_hostname           ,
  --                                     v_target_phase       ,
  --                                     v_force              ,
  --                                     v_port               ,
  --                                     v_servicename        ,
  --                                     v_target_envs        ,
  --                                     v_is_valid_ip        ,
  --                                     v_is_valid_phase     ,
  --                                     v_is_fqdn            ,
  --                                     v_is_valid_dname     ,
  --                                     v_param_hostname     ,
  --                                     v_param_domain_name  ,
  --                                     v_feedback           ,
  --                                     v_is_numeral_port    ,
  --                                     v_is_1k              ,
  --                                     v_default_port       ,
  --                                     v_port_range_expected,
  --                                     v_continue
  --                                   );
  --
  --IF v_does_exist = 'Y' THEN
  --  v_crud := 'U';
  ----
  --ELSE
  --  v_crud := 'C';
  --END IF;
  --
  register_tns( v_crud, 
                v_tns_id, 
                v_tns_alias, 
                v_target_phase, 
                v_target_envs, 
                v_hostname, 
                v_servicename , 
                v_port,
                v_date_valid_from,
                v_description, 
                v_date_valid_end, 
                v_connect_timeout,
                v_retry_delay, 
                v_retry_count, 
                v_failover, 
                v_load_balance, 
                v_force
              );
  ----
  --SELECT JSON_OBJECT('crud'                 VALUE v_crud,
  --                   'tns_id'               VALUE v_tns_id,
  --                   'tns_alias'            VALUE v_tns_alias,
  --                   'host_name'            VALUE NVL(v_hostname_out, v_hostname),
  --                   'target_phase'         VALUE v_target_phase,
  --                   'forced'               VALUE v_force,
  --                   'port'                 VALUE v_port,
  --                   'service_name'         VALUE v_servicename,
  --                   'target_envs'          VALUE v_target_envs,
  --                   'ip_validation'        VALUE v_is_valid_ip,
  --                   'phase_validation'     VALUE v_is_valid_phase,
  --                   'fqdn_validation'      VALUE v_is_fqdn,
  --                   'dname_validation'     VALUE v_is_valid_dname,
  --                   'shortname'            VALUE v_param_hostname,
  --                   'domainname'           VALUE v_param_domain_name,
  --                   'feedback'             VALUE v_feedback,
  --                   'numeral_validation'   VALUE v_is_numeral,
  --                   'numport_validation'   VALUE v_is_numeral,
  --                   'thousands_validation' VALUE v_is_1k,
  --                   'port_validation'      VALUE v_default_port,
  --                   'range_validation'     VALUE v_port_range_expected,
  --                   'description'          VALUE v_description,
  --                   'continue'             VALUE v_continue)
  --       INTO v_json
  --  FROM dual;
  ----
  --tetools.admin_tnsnames.report_registration(v_json, v_tns_id );
  --
END;
/
 */

/* 20241015 001
DECLARE
  v_force                  CHAR(1)             := 'N';
  v_tns_alias              VARCHAR2(128)       := 'crud_test06';
  v_target_phase           CHAR(1)             := 'T';
  v_target_envs            VARCHAR2(128)       := 'DTA';
  v_hostname               VARCHAR2(128)       := 'crud_host06';
  v_servicename            VARCHAR2(128)       := 'service06';
  v_port                   NUMBER              := 1526;
  v_date_valid_from        VARCHAR2(128)       := '2024-11-10';
  v_description            VARCHAR2(256)       := 'TEST description 6';
  v_date_valid_end         VARCHAR2(128)       := '2026-07-01';
  v_connect_timeout        NUMBER              := NULL;
  v_retry_delay            NUMBER              := NULL;
  v_retry_count            NUMBER              := NULL;
  v_failover               VARCHAR2(5)         := NULL;
  v_load_balance           VARCHAR2(5)         := NULL;
  --
  v_tns_id                 INTEGER;
  v_is_numeral             CHAR(1);
  v_phase                  CHAR(1);
  v_phase_out              CHAR(1);
  v_does_exist             CHAR(1);
  v_json                   VARCHAR2(4000);
  i                        NUMBER              := 0;
  v_crud                   CHAR(1);
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
  v_cont                   CHAR(1);
BEGIN
  --
  tetools.admin_tnsnames.register_tns( v_tns_alias,
  --register_tns( v_tns_alias,  
                v_target_phase, 
                v_target_envs, 
                v_hostname, 
                v_servicename , 
                v_port,
                v_date_valid_from,
                v_description, 
                v_date_valid_end, 
                v_connect_timeout,
                v_retry_delay, 
                v_retry_count, 
                v_failover, 
                v_load_balance, 
                v_force
              );
  --
END;
/
 */
 
/* 20241015 002 */
DECLARE
  v_force                  CHAR(1)             := 'N';
  v_tns_alias              VARCHAR2(128)       := 'crud_test07';
  v_target_phase           CHAR(1)             := 'T';
  v_target_envs            VARCHAR2(128)       := 'DTA';
  v_hostname               VARCHAR2(128)       := 'crud_host07';
  v_servicename            VARCHAR2(128)       := 'service07';
  v_port                   NUMBER              := 1526;
  v_date_valid_from        VARCHAR2(128)       := '2025-01-10';
  v_description            VARCHAR2(256)       := 'TEST description 6 adjusted twice again';
  v_date_valid_end         VARCHAR2(128)       := '2026-07-01';
  v_connect_timeout        NUMBER              := 5;
  v_retry_delay            NUMBER              := 5;
  v_retry_count            NUMBER              := 5;
  v_failover               VARCHAR2(5)         := 'TRUE';
  v_load_balance           VARCHAR2(5)         := 'FALSE';
  --
BEGIN
  --
  tetools.admin_tnsnames.register_tns( v_tns_alias,
  --register_tns( v_tns_alias,  
                v_target_phase, 
                v_target_envs, 
                v_hostname, 
                v_servicename , 
                v_port,
                v_date_valid_from,
                v_description, 
                v_date_valid_end, 
                v_connect_timeout,
                v_retry_delay, 
                v_retry_count, 
                v_failover, 
                v_load_balance, 
                v_force
              );
  --
END;
/




--  v_force                  CHAR(1)             := 'N';
--  v_tns_alias              VARCHAR2(128)       := 'crud_test05';
--  v_target_phase           CHAR(1)             := 'T';
--  v_target_envs            VARCHAR2(128)       := 'DTA';
--  v_hostname               VARCHAR2(128)       := 'crud_host05';
--  v_servicename            VARCHAR2(128)       := 'service05';
--  v_port                   NUMBER              := 1522;
--  v_date_valid_from        VARCHAR2(128)       := '2024-10-10';
--  v_description            VARCHAR2(256)       := 'TEST description 5';
--  v_date_valid_end         VARCHAR2(128)       := '2099-01-01';
--  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--  !!                                                                                                !!
--  !!! WARNING !!   TET - TRG_ADMIN_TNSNAMES_BASE_CUD                                                !!
--  !!                                                                                                !!
--  !!  On a functional level the requested update had no effect.                                     !!
--  !!  No changes were made on a row-level.                                                          !!
--  !!                                                                                                !!
--  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--
--
--  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--  !!                                                                                                               !!
--  !!          .#@@@%**%@+                                                                                          !!
--  !!       :%@@=.  =.   .=    TET - TNSNAMES ADMINISTRATION PACKAGE 0.301                                          !!
--  !!     :@@%: .=#%@@@=  .                                                                                         !!
--  !!    #@@= =@@@@%@@%=.                                                                                           !!
--  !!  .@@@::@@@=  =:          TNS Registration       : crud_test05 (15-OCT-24 03:36:10 PM)                         !!
--  !!  *@@%.@@# :.:::.:= -     USER                   : TETOOLS                                                     !!
--  !!  @@@#=@@: +:-*#**:#:                                                                                          !!
--  !!  *@@@=%@                                                                                                      !!
--  !!   =@@@@@@@@#:                                                                                                 !!
--  !!                                                                                                               !!
--  !!---------------------------------------------------------------------------------------------------------------!!
--  !!- RESULTING ADDITION / ALTERATION - U -------------------------------------------------------------------------!!
--  !!                                                                                                               !!
--  !!   PHASE                     : T                                                                               !!
--  !!   TARGET ENVIRONMENTS       : DTA                                                                             !!
--  !!   ----------------------------------------------------                                                        !!
--  !!                                                                                                               !!
--  !!   # [crud_test05 - 2024-10-15] :: TEST description 5                                                          !!
--  !!   crud_test05 =                                                                                               !!
--  !!     (DESCRIPTION =                                                                                            !!
--  !!     (ADDRESS = TCP)                                                                                           !!
--  !!       (HOST = crud_host05)                                                                                    !!
--  !!       (PORT = 1522)                                                                                           !!
--  !!       )                                                                                                       !!
--  !!       (CONNECT_DATA =                                                                                         !!
--  !!         (SERVER = DEDICATED)                                                                                  !!
--  !!         (SERVICE_NAME = service05)                                                                            !!
--  !!       )                                                                                                       !!
--  !!     )                                                                                                         !!
--  !!                                                                                                               !!
--  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--                                                        Don't forget to execute TETOOLS.ADMIN_TNSNAMES.GENERATE_TNS !


-- Eind datum aangepast
--  v_force                  CHAR(1)             := 'N';
--  v_tns_alias              VARCHAR2(128)       := 'crud_test05';
--  v_target_phase           CHAR(1)             := 'T';
--  v_target_envs            VARCHAR2(128)       := 'DTA';
--  v_hostname               VARCHAR2(128)       := 'crud_host05';
--  v_servicename            VARCHAR2(128)       := 'service05';
--  v_port                   NUMBER              := 1522;
--  v_date_valid_from        VARCHAR2(128)       := '2024-10-10';
--  v_description            VARCHAR2(256)       := 'TEST description 5';
--  v_date_valid_end         VARCHAR2(128)       := '2025-01-01';
--  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--  !!                                                                                                !!
--  !!! WARNING !!   TET - TRG_ADMIN_TNSNAMES_BASE_CUD                                                !!
--  !!                                                                                                !!
--  !!  On a functional level the requested update had no effect.                                     !!
--  !!  Only DATE_VALID_FROM and/or DATE_VALID_END was updated.                                       !!
--  !!                                                                                                !!
--  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--
--
--  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--  !!                                                                                                               !!
--  !!          .#@@@%**%@+                                                                                          !!
--  !!       :%@@=.  =.   .=    TET - TNSNAMES ADMINISTRATION PACKAGE 0.301                                          !!
--  !!     :@@%: .=#%@@@=  .                                                                                         !!
--  !!    #@@= =@@@@%@@%=.                                                                                           !!
--  !!  .@@@::@@@=  =:          TNS Registration       : crud_test05 (15-OCT-24 03:41:07 PM)                         !!
--  !!  *@@%.@@# :.:::.:= -     USER                   : TETOOLS                                                     !!
--  !!  @@@#=@@: +:-*#**:#:                                                                                          !!
--  !!  *@@@=%@                                                                                                      !!
--  !!   =@@@@@@@@#:                                                                                                 !!
--  !!                                                                                                               !!
--  !!---------------------------------------------------------------------------------------------------------------!!
--  !!- RESULTING ADDITION / ALTERATION - U -------------------------------------------------------------------------!!
--  !!                                                                                                               !!
--  !!   PHASE                     : T                                                                               !!
--  !!   TARGET ENVIRONMENTS       : DTA                                                                             !!
--  !!   ----------------------------------------------------                                                        !!
--  !!                                                                                                               !!
--  !!   # [crud_test05 - 2024-10-15] :: TEST description 5                                                          !!
--  !!   crud_test05 =                                                                                               !!
--  !!     (DESCRIPTION =                                                                                            !!
--  !!     (ADDRESS = TCP)                                                                                           !!
--  !!       (HOST = crud_host05)                                                                                    !!
--  !!       (PORT = 1522)                                                                                           !!
--  !!       )                                                                                                       !!
--  !!       (CONNECT_DATA =                                                                                         !!
--  !!         (SERVER = DEDICATED)                                                                                  !!
--  !!         (SERVICE_NAME = service05)                                                                            !!
--  !!       )                                                                                                       !!
--  !!     )                                                                                                         !!
--  !!                                                                                                               !!
--  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--                                                        Don't forget to execute TETOOLS.ADMIN_TNSNAMES.GENERATE_TNS !  


--  v_force                  CHAR(1)             := 'N';
--  v_tns_alias              VARCHAR2(128)       := 'crud_test06';
--  v_target_phase           CHAR(1)             := 'T';
--  v_target_envs            VARCHAR2(128)       := 'DTA';
--  v_hostname               VARCHAR2(128)       := 'crud_host06';
--  v_servicename            VARCHAR2(128)       := 'service06';
--  v_port                   NUMBER              := 1526;
--  v_date_valid_from        VARCHAR2(128)       := '2024-11-10';
--  v_description            VARCHAR2(256)       := 'TEST description 5';
--  v_date_valid_end         VARCHAR2(128)       := '2025-11-01';
--  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--  !!                                                                                                               !!
--  !!          .#@@@%**%@+                                                                                          !!
--  !!       :%@@=.  =.   .=    TET - TNSNAMES ADMINISTRATION PACKAGE 0.301                                          !!
--  !!     :@@%: .=#%@@@=  .                                                                                         !!
--  !!    #@@= =@@@@%@@%=.                                                                                           !!
--  !!  .@@@::@@@=  =:          TNS Registration       : crud_test06 (15-OCT-24 04:16:48 PM)                         !!
--  !!  *@@%.@@# :.:::.:= -     USER                   : TETOOLS                                                     !!
--  !!  @@@#=@@: +:-*#**:#:                                                                                          !!
--  !!  *@@@=%@                                                                                                      !!
--  !!   =@@@@@@@@#:                                                                                                 !!
--  !!                                                                                                               !!
--  !!---------------------------------------------------------------------------------------------------------------!!
--  !!- RESULTING ADDITION / ALTERATION - C -------------------------------------------------------------------------!!
--  !!                                                                                                               !!
--  !!   PHASE                     : T                                                                               !!
--  !!   TARGET ENVIRONMENTS       : DTA                                                                             !!
--  !!   CREATED TNS_ID            : 501                                                                             !!
--  !!   ----------------------------------------------------                                                        !!
--  !!                                                                                                               !!
--  !!   # [crud_test06 - 2024-10-15] :: TEST description 5                                                          !!
--  !!   crud_test06 =                                                                                               !!
--  !!     (DESCRIPTION =                                                                                            !!
--  !!     (ADDRESS = TCP)                                                                                           !!
--  !!       (HOST = crud_host06)                                                                                    !!
--  !!       (PORT = 1526)                                                                                           !!
--  !!       )                                                                                                       !!
--  !!       (CONNECT_DATA =                                                                                         !!
--  !!         (SERVER = DEDICATED)                                                                                  !!
--  !!         (SERVICE_NAME = service06)                                                                            !!
--  !!       )                                                                                                       !!
--  !!     )                                                                                                         !!
--  !!                                                                                                               !!
--  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--                                                        Don't forget to execute TETOOLS.ADMIN_TNSNAMES.GENERATE_TNS !










DECLARE
  v_force                  CHAR(1)             := 'N';
  v_tns_alias              VARCHAR2(128)       := 'crud_test07';
  v_target_phase           CHAR(1)             := 'T';
  v_target_envs            VARCHAR2(128)       := 'DTA';
  v_hostname               VARCHAR2(128)       := 'crud_host07';
  v_servicename            VARCHAR2(128)       := 'service07';
  v_port                   NUMBER              := 1521;
  v_date_valid_from        VARCHAR2(128)       := '2025-01-16';
  v_description            VARCHAR2(256)       := 'TEST description 7';
  v_date_valid_end         VARCHAR2(128)       := '2099-01-01';
BEGIN
  register_tns(v_tns_alias, v_target_phase, v_target_envs, v_hostname, v_servicename, v_port);
--
END;
/


col invoking_user for a18
col table_name for a20
col column_name for a24
col old_value for a24
col new_value for a24
col backup_record for a24

UPDATE TETOOLS.ADMIN_TNSNAMES_BASE SET TNS_ALIAS = 'crud_test03', PHASE = 'T', TARGET_ENV = 'ALL', HOST_NAME = 'crud_host01', INSTANCE_NAME = 'service01', PORT = 1521, DATE_VALID_FROM = TO_DATE('2024-08-16','YYYY-MM-DD'), DESCRIPTION = 'TEST description', DATE_VALID_END = TO_DATE('2099-01-01', 'YYYY-MM-DD'), CONNECT_TIMEOUT = NULL, RETRY_DELAY = NULL, RETRY_COUNT = NULL, FAILOVER = NULL, LOAD_BALANCE = NULL WHERE tns_id = 202;
INSERT TETOOLS.ADMIN_TNSNAMES_BASE () VALUES ();

DECLARE
  v_json                   VARCHAR2(4000);
BEGIN
  SELECT JSON_OBJECT('crud'            VALUE 'C',
                     'tns_id'          VALUE NULL,
                     'tns_alias'       VALUE 'crud_test02',
                     'target_phase'    VALUE 'T',
                     'target_envs'     VALUE 'ALL',
                     'host_name'       VALUE 'crud_host02',
                     'service_name'    VALUE 'service02',
                     'port'            VALUE 1521,
                     'date_valid_from' VALUE to_char(sysdate, 'YYYY-MM-DD'),
                     'description'     VALUE 'TEST description',
                     'date_valid_end'  VALUE '2099-01-01',
                     'connect_timeout' VALUE NULL,
                     'retry_delay'     VALUE NULL,
                     'retry_count'     VALUE NULL,
                     'failover'        VALUE NULL,
                     'load_balance'    VALUE NULL,
                     'cont'            VALUE 'Y')
         INTO v_json
    FROM dual;
    --
  crud(v_json);
  --DBMS_OUTPUT.PUT_LINE(v_json);
END;
/

INSERT INTO TETOOLS.ADMIN_TNSNAMES_BASE (TNS_ALIAS, PHASE, TARGET_ENV, HOST_NAME, INSTANCE_NAME, PORT, DATE_VALID_FROM, DESCRIPTION, DATE_VALID_END, CONNECT_TIMEOUT, RETRY_DELAY, RETRY_COUNT, FAILOVER, LOAD_BALANCE) VALUES ('crud_test02', 'T', 'DTA', 'crud_host02', 'service02', 1521, TO_DATE('2024-07-16', 'YYYY-MM-DD'), 'TEST description', TO_DATE('2099-01-01', 'YYYY-MM-DD'), NULL, NULL, NULL, NULL, NULL);

CREATE OR REPLACE TRIGGER TETOOLS.TRG_ADMIN_TNSNAMES_BASE_CUD
AFTER UPDATE OR INSERT OR DELETE ON TETOOLS.ADMIN_TNSNAMES_BASE
FOR EACH ROW
DECLARE
  i                               INTEGER           := 0;
  y                               INTEGER           := 0;
  v_tname                         VARCHAR2(48)      := 'ADMIN_TNSNAMES_BASE';
  v_this_object                   VARCHAR2(128);
  v_svn_date                      DATE              := sysdate;
  v_svn_pk                        INTEGER           := 0;
  v_svn_id                        INTEGER           := 0;
  v_username                      VARCHAR2(128);
  v_userid                        NUMBER;
  v_cud                           CHAR(1);  -- DML CAN BE: 'I'-INSERT, 'U'-UPDATE, 'D'-DELETE
  v_inv_roles                     VARCHAR2(2000);
  v_backup                        VARCHAR2(4000);
  v_isinvusr_adm                  CHAR(1);
  v_isinvusr_con                  CHAR(1);
  --
BEGIN
 --
  tetools.admin_tnsnames.who_called(v_this_object);
  --
	SELECT user INTO v_username FROM dual;
	SELECT user_id INTO v_userid FROM dba_users WHERE username = v_username;
	--
	compare_roles(v_inv_roles, v_isinvusr_adm, v_isinvusr_con);
  --
  tetools.admin_tnsnames_audit.max_svn(v_svn_id);
	--
	v_backup :=  JSON_OBJECT('TNS_ALIAS'       VALUE :NEW.TNS_ALIAS,
                           'PHASE'           VALUE :NEW.PHASE,
                           'TARGET_ENV'      VALUE :NEW.TARGET_ENV,
                           'HOST_NAME'       VALUE :NEW.HOST_NAME,
                           'INSTANCE_NAME'   VALUE :NEW.INSTANCE_NAME,
                           'PORT'            VALUE :NEW.PORT,
                           'DATE_VALID_FROM' VALUE :NEW.DATE_VALID_FROM,
                           'DESCRIPTION'     VALUE :NEW.DESCRIPTION,
                           'DATE_VALID_END'  VALUE :NEW.DATE_VALID_END,
                           'CONNECT_TIMEOUT' VALUE NVL(:NEW.CONNECT_TIMEOUT, NULL),
                           'RETRY_DELAY'     VALUE NVL(:NEW.RETRY_DELAY, NULL),
                           'RETRY_COUNT'     VALUE NVL(:NEW.RETRY_COUNT, NULL),
                           'FAILOVER'        VALUE NVL(:NEW.FAILOVER, NULL),
                           'LOAD_BALANCE'    VALUE NVL(:NEW.LOAD_BALANCE, NULL));
  --
	INSERT INTO TETOOLS.admin_tnsnames_meta (SVN_ID,
                                           USER_ID,
                                           USERNAME,
                                           ISADMIN,
                                           ISCONTRIBUTOR,
                                           USER_ROLES,
                                           CALLED_FROM) VALUES (v_svn_id,
                                                                v_userid,
                                                                v_username,
                                                                v_isinvusr_adm,
                                                                v_isinvusr_con,
                                                                JSON_OBJECT('INVOKING_USER_ROLES' VALUE v_inv_roles),
                                                                v_this_object);
	--
  IF INSERTING   THEN 
    v_cud := 'C';
    --
    INSERT INTO TETOOLS.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, TNS_ID, TABLE_NAME, BACKUP_RECORD) VALUES (v_svn_id, SYSDATE, v_cud, USER, :NEW.TNS_ID, v_tname, v_backup) RETURNING SVN_ID INTO v_svn_id;
    --
    y := 1;
  ELSIF UPDATING THEN
    v_cud := 'U';
    --
    IF ( UPDATING( 'TNS_ID' ) ) THEN
      tetools.admin_tnsnames_audit.check_val(v_cud, NVL(:OLD.TNS_ID, :NEW.TNS_ID), v_tname, 'TNS_ID', NVL(:NEW.TNS_ID, NULL), :OLD.TNS_ID, v_backup, v_svn_id, i);
      y := y + i;
    END IF;
    IF ( UPDATING( 'TNS_ALIAS' ) ) THEN
      tetools.admin_tnsnames_audit.check_val(v_cud, NVL(:OLD.TNS_ID, :NEW.TNS_ID), v_tname, 'TNS_ALIAS', NVL(:NEW.TNS_ALIAS, NULL), :OLD.TNS_ALIAS, v_backup, v_svn_id, i);
      y := y + i;
    END IF;
    IF ( UPDATING( 'PHASE' ) ) THEN
      tetools.admin_tnsnames_audit.check_val(v_cud, NVL(:OLD.TNS_ID, :NEW.TNS_ID), v_tname, 'PHASE', NVL(:NEW.PHASE, NULL), :OLD.PHASE, v_backup, v_svn_id, i);
      y := y + i;
    END IF;
    IF ( UPDATING( 'TARGET_ENV' ) ) THEN
      tetools.admin_tnsnames_audit.check_val(v_cud, NVL(:OLD.TNS_ID, :NEW.TNS_ID), v_tname, 'TARGET_ENV', NVL(:NEW.TARGET_ENV, NULL), :OLD.TARGET_ENV, v_backup, v_svn_id, i);
      y := y + i;
    END IF;
    IF ( UPDATING( 'HOST_NAME' ) ) THEN
      tetools.admin_tnsnames_audit.check_val(v_cud, NVL(:OLD.TNS_ID, :NEW.TNS_ID), v_tname, 'HOST_NAME', NVL(:NEW.HOST_NAME, NULL), :OLD.HOST_NAME, v_backup, v_svn_id, i);
      y := y + i;
    END IF;
    IF ( UPDATING( 'INSTANCE_NAME' ) ) THEN
      tetools.admin_tnsnames_audit.check_val(v_cud, NVL(:OLD.TNS_ID, :NEW.TNS_ID), v_tname, 'INSTANCE_NAME', NVL(:NEW.INSTANCE_NAME, NULL), :OLD.INSTANCE_NAME, v_backup, v_svn_id, i);
      y := y + i;
    END IF;
    IF ( UPDATING( 'PORT' ) ) THEN
      tetools.admin_tnsnames_audit.check_val(v_cud, NVL(:OLD.TNS_ID, :NEW.TNS_ID), v_tname, 'PORT', NVL(:NEW.PORT, NULL), :OLD.PORT, v_backup, v_svn_id, i);
      y := y + i;
    END IF;
    IF ( UPDATING( 'DATE_VALID_FROM' ) ) THEN
      tetools.admin_tnsnames_audit.check_val(v_cud, NVL(:OLD.TNS_ID, :NEW.TNS_ID), v_tname, 'DATE_VALID_FROM', NVL(:NEW.DATE_VALID_FROM, NULL), :OLD.DATE_VALID_FROM, v_backup, v_svn_id, i);
      y := y + i;
    END IF;
    IF ( UPDATING( 'DESCRIPTION' ) ) THEN
      tetools.admin_tnsnames_audit.check_val(v_cud, NVL(:OLD.TNS_ID, :NEW.TNS_ID), v_tname, 'DESCRIPTION', NVL(:NEW.DESCRIPTION, NULL), :OLD.DESCRIPTION, v_backup, v_svn_id, i);
      y := y + i;
    END IF;
    IF ( UPDATING( 'DATE_VALID_END' ) ) THEN
      tetools.admin_tnsnames_audit.check_val(v_cud, NVL(:OLD.TNS_ID, :NEW.TNS_ID), v_tname, 'DATE_VALID_END', NVL(:NEW.DATE_VALID_END, NULL), :OLD.DATE_VALID_END, v_backup, v_svn_id, i);
      y := y + i;
    END IF;
    IF ( UPDATING( 'CONNECT_TIMEOUT' ) ) THEN
      tetools.admin_tnsnames_audit.check_val(v_cud, NVL(:OLD.TNS_ID, :NEW.TNS_ID), v_tname, 'CONNECT_TIMEOUT', NVL(:NEW.CONNECT_TIMEOUT, NULL), :OLD.CONNECT_TIMEOUT, v_backup, v_svn_id, i);
      y := y + i;
    END IF;
    IF ( UPDATING( 'RETRY_DELAY' ) ) THEN
      tetools.admin_tnsnames_audit.check_val(v_cud, NVL(:OLD.TNS_ID, :NEW.TNS_ID), v_tname, 'RETRY_DELAY', NVL(:NEW.RETRY_DELAY, NULL), :OLD.RETRY_DELAY, v_backup, v_svn_id, i);
      y := y + i;
    END IF;
    IF ( UPDATING( 'RETRY_COUNT' ) ) THEN
      tetools.admin_tnsnames_audit.check_val(v_cud, NVL(:OLD.TNS_ID, :NEW.TNS_ID), v_tname, 'RETRY_COUNT', NVL(:NEW.RETRY_COUNT, NULL), :OLD.RETRY_COUNT, v_backup, v_svn_id, i);
      y := y + i;
    END IF;
    IF ( UPDATING( 'FAILOVER' ) ) THEN
      tetools.admin_tnsnames_audit.check_val(v_cud, NVL(:OLD.TNS_ID, :NEW.TNS_ID), v_tname, 'FAILOVER', NVL(:NEW.FAILOVER, NULL), :OLD.FAILOVER, v_backup, v_svn_id, i);
      y := y + i;
    END IF;
    IF ( UPDATING( 'LOAD_BALANCE' ) ) THEN
      tetools.admin_tnsnames_audit.check_val(v_cud, NVL(:OLD.TNS_ID, :NEW.TNS_ID), v_tname, 'LOAD_BALANCE', NVL(:NEW.LOAD_BALANCE, NULL), :OLD.LOAD_BALANCE, v_backup, v_svn_id, i);
      y := y + i;
    END IF;
    --
  ELSIF DELETING THEN
    v_cud := 'D';
    --
    INSERT INTO TETOOLS.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, TNS_ID, TABLE_NAME, BACKUP_RECORD) VALUES (v_svn_id, SYSDATE, v_cud, USER, :OLD.TNS_ID, v_tname, v_backup) RETURNING SVN_ID INTO v_svn_id;
    --
    y := 1;
  END IF;
  --
  i := 0; y := 0; v_svn_id := 0;
END;
/





DECLARE
  v_crud                   CHAR(1)             := 'C';
  v_tns_id                 INTEGER             := NULL;
  v_tns_alias              VARCHAR2(128)       := 'test_alias09';
  v_target_phase           CHAR(1)             := 'T';
  v_target_envs            VARCHAR2(128)       := 'DTA';
  v_hostname               VARCHAR2(128)       := 'example.invalid';
  v_servicename            VARCHAR2(128)       := 'service01';
  v_port                   NUMBER              := 1521;
  v_date_valid_from        VARCHAR2(128)       := '2024-09-16';
  v_description            VARCHAR2(256)       := 'TEST description';
  v_date_valid_end         VARCHAR2(128)       := '2099-01-01';
  v_connect_timeout        NUMBER;
  v_retry_delay            NUMBER;
  v_retry_count            NUMBER;
  v_failover               VARCHAR2(5);
  v_load_balance           VARCHAR2(5);
  v_force                  CHAR(1)             := 'N';
BEGIN
  tetools.admin_tnsnames.register_tns(v_crud, v_tns_id, v_tns_alias, v_target_phase, v_target_envs, v_hostname,  v_servicename,  v_port, v_date_valid_from, v_description, v_date_valid_end, v_connect_timeout, v_retry_delay, v_retry_count, v_failover, v_load_balance, v_force);
  --
END;
/


{
  "crud":"U",
  "tns_id":null,
  "tns_alias":"crud_test05",
  "target_phase":"T",
  "target_envs":"DTA",
  "host_name":"crud_host02",
  "service_name":"service02",
  "port":1521,
  "date_valid_end":"2099-01-01",
  "description":"TEST description 2",
  "date_valid_from":"2024-09-16",
  "connect_timeout":null,
  "retry_delay":null,
  "retry_count":null,
  "failover":null,
  "load_balance":null,
  "forced":"N",
  "dname_validation":"X",
  "domainname":"X",
  "fqdn_validation":"X",
  "ip_validation":"N",
  "numeral_validation":null,
  "numport_validation":null,
  "phase_validation":"Y",
  "port_validation":"Y",
  "range_validation":"Y",
  "shortname":"X",
  "thousands_validation":"Y",
  "feedback":null,
  "continue":"Y"
}

  --DBMS_OUTPUT.PUT_LINE('v_crud : '||v_crud||', v_tns_alias : '||v_tns_alias||', v_target_phase : '||v_target_phase||', v_target_envs : '||v_target_envs||', v_hostname : '||v_hostname||', v_servicename : '||v_servicename||', v_port : '||v_port||', v_date_valid_from : '||v_date_valid_from||', v_description : '||v_description||', v_date_valid_end : '||v_date_valid_end||', v_connect_timeout : '||v_connect_timeout||', v_retry_delay : '||v_retry_delay||', v_retry_count : '||v_retry_count||', v_failover : '||v_failover||', v_load_balance : '||v_load_balance||', v_force : '||v_force);
 
v_crud : C,
v_tns_alias : crud_test02,
v_target_phase : T, 
v_target_envs : DTA, 
v_hostname : crud_host02, 
v_servicename : service02, 
v_port : 1521, 
v_date_valid_from : 2024-09-16, 
v_description : TEST description 2, 
v_date_valid_end : 2099-01-01, 
v_connect_timeout : , 
v_retry_delay : , 
v_retry_count : , 
v_failover : , 
v_load_balance : , 
v_force : N





1240988336
DBMS_OUTPUT.PUT_LINE(v_this_object || ' > ');
DBMS_OUTPUT.PUT_LINE(v_this_object || ' > ');
DBMS_OUTPUT.PUT_LINE(v_this_object || ' > ');
DBMS_OUTPUT.PUT_LINE(v_this_object || ' > ');
DBMS_OUTPUT.PUT_LINE(v_this_object || ' > ');
DBMS_OUTPUT.PUT_LINE(v_this_object || ' > ');
DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 6406230138');
DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 7710921383');
DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 8479660418');
DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 5587626301');
DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 8836113663');
DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 4377040434');
DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 7757691286');
DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 6837076494');
DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 7582105561');
DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 7370520219');
DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 7746992021');
DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 1587646476');
DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 0588937712');
DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 5391845716');
DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 1323465355');
DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 9088591796');
DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 2260945686');
DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 7192397949');
DBMS_OUTPUT.PUT_LINE(v_this_object || ' > 8402872395');



