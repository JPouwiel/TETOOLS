CREATE OR REPLACE PACKAGE BODY admin_tnsnames_proto
AS
  --
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
  --E-  not_correct_phase        EXCEPTION; PRAGMA EXCEPTION_INIT   (not_correct_phase       , -20001); 'THE PHASE GIVEN IS NOT COMMONLY USED IN GD.'
  --E-  no_valid_domain          EXCEPTION; PRAGMA EXCEPTION_INIT   (no_valid_domain         , -20002); 'DOMAIN NAME VALIDATION FAILED, MOST LIKELY A DOMAIN NOT COMMONLY USED IN GD.'
  --E-  generic_error            EXCEPTION; PRAGMA EXCEPTION_INIT   (generic_error           , -20003); 'SOUNDS LIKE A BUG.'
  --E-  hostname_validation      EXCEPTION; PRAGMA EXCEPTION_INIT   (hostname_validation     , -20004); 'VALIDATION OF THE HOSTNAME FAILED, MOST LIKELY A TYPO.'
  --E-  fqdn_validation          EXCEPTION; PRAGMA EXCEPTION_INIT   (fqdn_validation         , -20005); 'VALIDATION OF THE FQDN FAILED FOR THE GIVEN HOSTNAME, CHECK AGAIN.'
  --E-  ip_invalid               EXCEPTION; PRAGMA EXCEPTION_INIT   (ip_invalid              , -20006); 'VALIDATION OF THE GIVEN IP ADDRESS FAILED, EITHER FORMAT IS WRONG OR A BROADCAST ADDRESS WAS GIVEN.'
  --E-  shortname_validation     EXCEPTION; PRAGMA EXCEPTION_INIT   (shortname_validation    , -20007); 'VALIDATION OF THE DB SERVER SHORTNAME FAILED, MOST LIKELY A SUBDOMAIN.'
  --E-  not_correct_phase        EXCEPTION; PRAGMA EXCEPTION_INIT   (not_correct_phase       , -20008); 'GIVEN PHASE IS NOT USED WITHIN GD.'
  --E-  no_valid_domain          EXCEPTION; PRAGMA EXCEPTION_INIT   (no_valid_domain         , -20009); 'DOMAIN VALIDATION FAILED.'
  --E-  generic_error            EXCEPTION; PRAGMA EXCEPTION_INIT   (generic_error           , -20010); 'SOUNDS LIKE A BUG.'
  --E-  idx_internal_check       EXCEPTION; PRAGMA EXCEPTION_INIT   (idx_internal_check      , -20011); 'INDEX FOR VARRAY FAILED INTERNALLY, TECHNICAL ISSUE MOST LIKELY.'
  --E-  ip_format_invalid        EXCEPTION; PRAGMA EXCEPTION_INIT   (ip_format_invalid       , -20012); 'IP ADDRESS FORMAT IS INVALID'
  --E-  port_validation          EXCEPTION; PRAGMA EXCEPTION_INIT   (port_validation         , -20013); 'PORT VALIDATION FAILED'
  --E-  crud_read                EXCEPTION; PRAGMA EXCEPTION_INIT   (crud_read               , -20014); 'REQUESTED CRUD OPERATION (READ) NOT APPLICABLE FOR THIS PACKAGE.'
  --E-  crud_unknown             EXCEPTION; PRAGMA EXCEPTION_INIT   (crud_unknown            , -20015); 'REQUESTED CRUD OPERATION IN TNSNAMES BASE TABLE IS INVALID.'
  --E-  no_contributor           EXCEPTION; PRAGMA EXCEPTION_INIT   (no_contributor          , -20016); 'INVOKING USER HAS NO PRIVILEGES TO CONTRIBUTE TO TNSNAMES. CONTACT TET.'
  --E-  maintenance_mode_enabled EXCEPTION; PRAGMA EXCEPTION_INIT   (maintenance_mode_enabled, -20017); 'INVOKING USER HAS NO PRIVILEGES TO ADMINISTER TO TNSNAMES WHILE MAINTENANCE MODE IS ENABLED. CONTACT TET.'
  --E-  no_update_found          EXCEPTION; PRAGMA EXCEPTION_INIT   (no_update_found         , -20018); 'NO DISCERNABLE UPDATE VALUES FOUND TO PROCESS AS TNS REGISTRATION. TRY AGAIN.'
  --E-  operation_halted         EXCEPTION; PRAGMA EXCEPTION_INIT   (operation_halted        , -20019); 'SOMEHOW, SOMEWHERE, SOMETHINGs NOT GOOD. TRY AGAIN. CALL TET.'
  --E-  wrong_crud               EXCEPTION; PRAGMA EXCEPTION_INIT   (wrong_crud              , -20020); 'CANt UPDATE WHEN IT ALREADY EXISTS, OR SIMILAR. TRY AGAIN.'
  --E-  mismatch_type_numhosts   EXCEPTION; PRAGMA EXCEPTION_INIT   (mismatch_type_numhosts  , -20021); 'A SPECIFIC NUMBER OF ADDRESSES CAN/MUST BE USED WITH THE TYPE OF REGISTRATION. SIMPLE: 1, ADVANCED: 1 to 3.'
  --E-  invalid_numhosts         EXCEPTION; PRAGMA EXCEPTION_INIT   (invalid_numhosts        , -20022); 'A SPECIFIC RANGE OF NUMBER OF ADDRESSES CAN BE USED TO REGISTER A NET SERVICE NAME: [1 - 3].'
  --E-  validation_error         EXCEPTION; PRAGMA EXCEPTION_INIT   (validation_error        , -20023); 'A VALIDATION ERROR HAS OCCURED VALIDATING THE PROTO TNS ENTRY. SEE FEEDBACK FOR OFFENDING ATTRIBUTE.'
  --E-  no_parent_attr_name      EXCEPTION; PRAGMA EXCEPTION_INIT   (no_parent_attr_name,    , -02291); 'A PARSE ERROR HAS OCCURED TRYING TO VALIDATE THE GIVEN ATTRIBUTE NAME. THIS ATTRIBUTE HAS BEEN MISSPELLED OR NOT IN SUPPORT.'
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
  -- /* TYPE > admin_tnsnames_attr_proto_type --------------------------------------------------------------------------------- RECORD ----- HEADER */
  --
  --TYPE admin_tnsnames_attr_proto_type
  --IS RECORD
  --( tns_attr_name   VARCHAR2(64),
  --  tns_attr_status VARCHAR2(64)
  --);
  --
  -- /* TYPE > admin_tnsnames_attr_proto_table --------------------------------------------------------------------------------- TABLE ----- HEADER */
  --
  --TYPE admin_tnsnames_attr_proto_table
  --IS TABLE OF
  --admin_tnsnames_attr_proto_type;
  --
  -- /* ================================================================================================================================================================= */
  --  FUNCTIONS
  -- /* ================================================================================================================================================================= */
  --
  -- /* FUNCTION > num_period_dname --------------------------------------------------------------------------------------------- BOOL ----- HEADER */
  --
  --FUNCTION admin_tnsnames_attr_proto_vald (p_value IN VARCHAR2, p_stmnt IN VARCHAR2 ) RETURN admin_tnsnames_attr_proto_table IS
  --  tns_attr_name        VARCHAR2(64);
  --  tns_attr_status      VARCHAR2(64);
  FUNCTION admin_tnsnames_attr_proto_vald (p_value IN VARCHAR2, p_stmnt IN VARCHAR2 ) RETURN admin_tnsnames_attr_proto_table AS
    v_attr_proto_table     admin_tnsnames_attr_proto_table;
  BEGIN
    SELECT  attr,
            CASE
              WHEN x.matching = 0 THEN 'NOT VALIDATED'
              WHEN x.matching > 0 THEN 'VALIDATED'
              ELSE 'ERROR'
       --     END INTO tns_attr_name, tns_attr_status
            END BULK COLLECT INTO v_attr_proto_table
       FROM (
             SELECT attr, COUNT(*) matching FROM (
               SELECT p_value as attr, 1
                 FROM DUAL
                WHERE REGEXP_LIKE(p_value, p_stmnt, 'i'))) x;
       RETURN v_attr_proto_table;
       --RETURN admin_tnsnames_attr_proto_table(tns_attr_name, tns_attr_status);
  END;
  --
  -- /* ================================================================================================================================================================= */
  --  PROCEDURES
  -- /* ================================================================================================================================================================= */
  --
  --
  -- /* PROCEDURE > report_proto_registration ------------------------------------------------------------------------- USAGE EXAMPLES ----- HEADER */
  --
  PROCEDURE report_proto_registration ( json_string IN CLOB, p_tns_id IN INTEGER, p_type IN VARCHAR2 DEFAULT 'ALL')
  AS
    inter                 CLOB;
    data                  JSON_OBJECT_T;
    cont                  CHAR(1);
    v_num_indexes         INTEGER;
    --
    l_clob                CLOB;
    l_top_obj             JSON_OBJECT_T;
    l_top_key_list        JSON_KEY_LIST;
    v_key                 VARCHAR2(4000);
    v_object              JSON_OBJECT_T;
    v_array               JSON_ARRAY_T;
    v_array_obj           JSON_OBJECT_T;
    v_array_obj_key_list  JSON_KEY_LIST;
    --
    --
    PROCEDURE ECHO( STRING IN VARCHAR2)
    AS
    BEGIN
      --DBMS_OUTPUT.PUT_LINE( '  !' || RPAD( STRING, 196, PAD) || '!!');
      DBMS_OUTPUT.PUT_LINE( STRING );
    END ECHO;
    --
    FUNCTION inner_echo( p_string IN VARCHAR2, p_size IN INTEGER, p_pad IN VARCHAR2 DEFAULT ' ' ) RETURN VARCHAR2 AS
      v_string                           VARCHAR2(256);
      BEGIN
        SELECT RPAD( p_string, p_size, p_pad )||' ' INTO v_string FROM dual;
        RETURN v_string;
      END inner_echo;
    --
  BEGIN
    SELECT TREAT(json_string as json) INTO INTER FROM dual;
  	data                  := new JSON_OBJECT_T(INTER);
  	--
  	cont                  := data.get_string('cont');
  	--
  	--
    l_top_obj      := JSON_OBJECT_T(data);
    l_top_key_list := l_top_obj.get_keys;
    --
    DBMS_OUTPUT.put_line(' ');
    --DBMS_OUTPUT.put_line(l_top_key_list.count);
    --DBMS_OUTPUT.put_line(v_num_indexes);
    --DBMS_OUTPUT.put_line(json_string);
    --DBMS_OUTPUT.put_line(' ');
    --
    ECHO( ' ');
    ECHO( ' ');
    ECHO( ' ');
    ECHO( ' ');
    ECHO( '           .#@@@%**%@+');
    ECHO( '        :%@@=.  =.   .=    TET - TNSNAMES ADMINISTRATION PACKAGE 0.301');
    ECHO( '      :@@%: .=#%@@@=  .');
    ECHO( '     #@@= =@@@@%@@%=.');
    ECHO( '   .@@@::@@@=  =:          PROTO TNS Registration : ' || p_tns_id || ' (' || to_char( sysdate, 'dd-MON-yy hh:mi:ss AM') || ')');
    ECHO( '   *@@%.@@# :.:::.:= -     USER                   : ' || USER());
    ECHO( '   @@@#=@@: +:-*#**:#:');
    ECHO( '   *@@@=%@');
    ECHO( '    =@@@@@@@@#:');
    ECHO( ' ');
    --
    IF p_type = 'ERROR' THEN
      ECHO( ' ' ||  inner_echo('  -- ERROR:  ERROR IN VALIDATION [KEY / VALUE] ', 152, '-'));
    ELSIF p_type = 'WARNING' THEN
      ECHO( ' ' ||  inner_echo('  -- WARNING:  ERROR IN PROTO VALIDATION [VALUE] ', 152, '-'));
    ELSIF p_type = 'ALL' THEN
      ECHO( ' ' ||  inner_echo('  -- REPORT:  STATUS OF PROTO_REGISTRATION ', 152, '-'));
    END IF;
    ECHO( ' ');
    --
    FOR i IN l_top_key_list.FIRST .. l_top_key_list.LAST LOOP
      v_key := l_top_key_list(i);
      --dbms_output.put_line('KEY: '||v_key);
      --
      IF l_top_obj.get(v_key).is_array THEN
        --
        v_array := TREAT(l_top_obj.get(l_top_key_list(i)) AS JSON_ARRAY_T);
        FOR j IN 0 .. v_array.get_size - 1 LOOP
          IF v_array.get(j).is_object THEN
            v_array_obj := TREAT(v_array.get(j) AS JSON_OBJECT_T);
            v_array_obj_key_list := v_array_obj.get_keys;
            --
            v_num_indexes  := v_array_obj_key_list.count;
            SELECT TO_NUMBER(v_num_indexes - 1) INTO v_num_indexes FROM dual;
            --
            FOR k IN 1 .. v_array_obj_key_list.count LOOP
              IF p_type = 'ERROR' OR p_type = 'WARNING' THEN
                IF v_array_obj.get_string(v_array_obj_key_list(k)) = 'UNMATCHED_VALUE' THEN
                  ECHO( '!! ' ||  inner_echo(v_array_obj_key_list(k), 32) || '< ! >  PROTO VALIDATION FAILURE !');
                ELSE
                  ECHO( '   ' ||  inner_echo(v_array_obj_key_list(k), 32) || ' = ' || inner_echo(v_array_obj.get_string(v_array_obj_key_list(k)), 52));
                END IF;
              ELSIF p_type = 'ALL' THEN
                ECHO( '   ' ||  inner_echo(v_array_obj_key_list(k), 32) || ' = ' || inner_echo(v_array_obj.get_string(v_array_obj_key_list(k)), 52));
              END IF;
            END LOOP;
            NULL;
          ELSE
            DBMS_OUTPUT.put_line('UNHANDLED EXCEPTION in PROCEDURE report_proto_registration!');
          END IF;
        END LOOP;
        --
      ELSIF l_top_obj.get(v_key).is_number THEN
        ECHO( '  # ' ||  inner_echo(v_key || ' : ' || l_top_obj.get_number(l_top_key_list(i)), 32));
      ELSIF l_top_obj.get(v_key).is_string THEN
        ECHO( '  # ' ||  inner_echo(v_key || ' : ' || l_top_obj.get_string(l_top_key_list(i)), 52));
      END IF;
      --
    END LOOP;
    --
    IF p_type = 'ALL' THEN
      ECHO( ' ');
      ECHO( '                                                        Don''t forget to execute TETOOLS.ADMIN_TNSNAMES.REGISTER_TNS !');
    END IF;
    DBMS_OUTPUT.PUT_LINE(chr(13)||chr(10));
    --
    ECHO( ' ');
    ECHO( ' ');
    --
    DBMS_OUTPUT.put_line(' ');
    --
  END report_proto_registration;
  --
  -- /* PROCEDURE > evaluate_entry ------------------------------------------------------------------------------ EVALUATE PROTO ENTRY ----- HEADER */
  --
  PROCEDURE evaluate_entry ( p_proto_tns_id IN INTEGER) AS
  --
    v_this_object                         VARCHAR2(128);
    v_proto_tns_id                        INTEGER                            := p_proto_tns_id;
    v_proto_errors                        INTEGER;
    v_maintenance_mode                    VARCHAR2(8);
    v_tnsnames_status                     VARCHAR2(8)                        := 'ENABLED';
    v_username                            VARCHAR2(128);
    v_userid                              NUMBER;
    v_role_invusr                         VARCHAR2(2000);
    v_isinvusr_adm                        CHAR(1);
    v_isinvusr_con                        CHAR(1);
    v_syntax_valdtd                       CHAR(1)                            := 'N';
    v_value_valdtd                        CHAR(1)                            := 'N';
    v_entry_accepted                      CHAR(1)                            := 'B';  -- APART STANDPUNT ZODAT WE ZEKER WETEN DAT DE VAR IS AANGEPAST
    v_cont                                CHAR(1)                            := 'Y';
    v_last_validated                      DATE;
    v_tns_alias                           VARCHAR2(32);
    v_target_phase                        VARCHAR2(3);
    v_does_exist                          CHAR(1);
    validation_error                      EXCEPTION;
    no_contributor                        EXCEPTION;
    maintenance_mode_enabled              EXCEPTION;
    no_parent_attr_name                   EXCEPTION;
    generic_error                         EXCEPTION;
    PRAGMA EXCEPTION_INIT                 (validation_error        , -20023);
    PRAGMA EXCEPTION_INIT                 (no_contributor          , -20016);
    PRAGMA EXCEPTION_INIT                 (maintenance_mode_enabled, -20017);
    PRAGMA EXCEPTION_INIT                 (no_parent_attr_name     , -02291);
    PRAGMA EXCEPTION_INIT                 (generic_error           , -20010);
    --
    row_rowid                             VARCHAR2(32);
    row_proto_tns_id                      INTEGER;
    row_proto_tns_order_line              INTEGER;
    row_proto_tns_entry_line              VARCHAR2(64);
    row_attribute_name                    VARCHAR2(64);
    row_ref_attribute_name                VARCHAR2(64);
    row_attribute_value                   VARCHAR2(64);
    --
    TYPE ref_cursor_type               IS REF CURSOR;
    c_validate_gvn_entry                  ref_cursor_type;
    --
    PROCEDURE EXEC_DSQL( CMD IN VARCHAR2)
    AS
    BEGIN
      EXECUTE IMMEDIATE cmd;
      --
      EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXEC_DSQL> Error was: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('EXEC_DSQL> OFFENDING STATEMENT: ' || cmd);
    END EXEC_DSQL;
    --
  BEGIN
    --
    tetools.admin_tnsnames.who_called(v_this_object);
    --
    tetools.admin_tnsnames.compare_roles(v_role_invusr, v_isinvusr_adm, v_isinvusr_con);
    --
    OPEN c_validate_gvn_entry
    FOR
    q'[WITH transform_data AS
       ( SELECT atpe.proto_tns_id, atpe.tns_attr attribute_name
              , decode(atpe.INTAKE_LINE_SYNTAX_VALIDATED, 'N', 1, 0) AS SYNTAX_VALIDATED
              , decode(atpe.INTAKE_LINE_VALUE_VALIDATED, 'N', 1, 0) AS VALUE_VALIDATED
           FROM admin_tnsnames_proto_entries atpe
          WHERE atpe.proto_tns_id = :v_proto_tns_id
         ORDER BY atpe.proto_tns_id
       )
       SELECT proto_tns_id, attribute_name, SYNTAX_VALIDATED + VALUE_VALIDATED AS num_err
         FROM transform_data
        --WHERE SYNTAX_VALIDATED + VALUE_VALIDATED > 0
    ]' USING v_proto_tns_id;
    --
    LOOP
    --
      FETCH c_validate_gvn_entry INTO v_proto_tns_id, row_attribute_name, v_proto_errors;
      EXIT WHEN c_validate_gvn_entry%NOTFOUND;
      --
      v_last_validated := SYSDATE;
      --
      IF v_proto_errors = 0 AND v_entry_accepted != 'N' THEN
        v_entry_accepted  := 'Y';
      ELSIF v_proto_errors > 0  OR v_entry_accepted = 'N' THEN
        v_last_validated := NULL;
        v_entry_accepted  := 'N';
        row_ref_attribute_name := row_attribute_name;
      ELSE
        v_last_validated := NULL;
        v_entry_accepted  := 'N';
      END IF;
      --
    END LOOP;
    --
    IF v_entry_accepted = 'Y' THEN
      EXECUTE IMMEDIATE 'UPDATE TETOOLS.ADMIN_TNSNAMES_PROTO_ENTRIES SET INTAKE_ENTRY_ACCEPTED = '''|| 'Y' || ''' WHERE PROTO_TNS_ID = :v_proto_tns_id' USING p_proto_tns_id;
    END IF;
    --
    CLOSE c_validate_gvn_entry;
    --
    EXCEPTION
    WHEN no_parent_attr_name      THEN
      ROLLBACK;
      notify('5546673008', v_this_object, ' OFFENDING ENTRY LINE: '|| row_ref_attribute_name);
    WHEN validation_error         THEN
      ROLLBACK;
      RAISE;
    WHEN no_contributor           THEN
      ROLLBACK;
      v_role_invusr := ' NO CONTRIBUTOR';
      v_cont        := 'N';
      tetools.admin_tnsnames.report_status(v_tnsnames_status, v_role_invusr, v_cont, NULL);
      RAISE;
    WHEN maintenance_mode_enabled THEN
      ROLLBACK;
      tetools.admin_tnsnames.report_status(v_tnsnames_status, v_role_invusr, v_cont, NULL);
      IF v_cont = 'N'             THEN
        RAISE;
      END IF;
    WHEN generic_error            THEN
      ROLLBACK;
      notify('0089443894', v_this_object, DBMS_UTILITY.format_error_stack);
    WHEN OTHERS                   THEN
      ROLLBACK;
      notify('9889359543', v_this_object, DBMS_UTILITY.format_error_stack);
  END evaluate_entry;
  --
  -- /* PROCEDURE > intake_entry ---------------------------------------------------------------------------------- INTAKE PROTO ENTRY ----- HEADER */
  --
  PROCEDURE intake_entry ( p_proto_entry IN CLOB ) AS
  --
    v_this_object                         VARCHAR2(128);
    v_proto_tns_id                        INTEGER;
    v_maintenance_mode                    VARCHAR2(8);
    v_tnsnames_status                     VARCHAR2(8)                        := 'ENABLED';
    v_username                            VARCHAR2(128);
    v_userid                              NUMBER;
    v_role_invusr                         VARCHAR2(2000);
    v_isinvusr_adm                        CHAR(1);
    v_isinvusr_con                        CHAR(1);
    --v_syntax_valdtd                       CHAR(1)                            := 'B';
    --v_value_valdtd                        CHAR(1)                            := 'B';
    --v_entry_accepted                      CHAR(1)                            := 'B';
    v_int_l_syntax_valdtd                 CHAR(1)                            := 'B';
    v_int_l_value_valdtd                  CHAR(1)                            := 'B';
    v_int_e_accepted                      CHAR(1)                            := 'B';
    v_reg_l_syntax_valdtd                 CHAR(1)                            := 'N';
    v_reg_l_value_valdtd                  CHAR(1)                            := 'N';
    v_reg_e_accepted                      CHAR(1)                            := 'N';
    v_reg_e_process_date                  DATE;
    v_last_i_valdtd_date                  DATE;
    v_last_reg_valdtd_date                DATE;
    v_cont                                CHAR(1)                            := 'Y';
    v_last_validated                      DATE;
    v_tns_alias                           VARCHAR2(32);
    v_target_phase                        VARCHAR2(3);
    v_does_exist                          CHAR(1);
    v_json                                VARCHAR2(2000);
    v_ptt_gte_part                        VARCHAR2(32)                       := 'ORA$PTT_given_tns_entry';
    v_ptt_spte_part                       VARCHAR2(32)                       := 'ORA$PTT_split_proto_tns_entries';
    v_audsid                              NUMBER                             := TO_CHAR(USERENV('SESSIONID'));
    v_ptt_gte                             VARCHAR2(64)                       := v_ptt_gte_part||'_'||v_audsid;
    v_ptt_spte                            VARCHAR2(64)                       := v_ptt_spte_part; --||'_'||v_audsid;
    v_ptt_spte_seq                        VARCHAR2(64)                       := 'PTT_split_proto_tns_entries_order_seq';
    v_ptt_gte_cr8_cmd                     VARCHAR2(256)                      := 'CREATE PRIVATE TEMPORARY TABLE '||v_ptt_gte||' (proto_tns_id INTEGER, gvn_tns_entry VARCHAR2(4000)) ON COMMIT PRESERVE DEFINITION';
    v_ptt_spte_cr8_cmd                    VARCHAR2(256)                      := 'CREATE PRIVATE TEMPORARY TABLE '||v_ptt_spte||' (proto_tns_id INTEGER, proto_tns_order_line INTEGER, proto_tns_entry_line VARCHAR2(4000)) ON COMMIT PRESERVE DEFINITION';
    v_ptte_spte_seq_cmd                   VARCHAR2(256)                      := 'CREATE SEQUENCE tetools.'||v_ptt_spte_seq||' START WITH 1 MINVALUE 1 INCREMENT BY 1 ORDER';
    v_ptte_spte_drp_cmd                   VARCHAR2(256)                      := 'DROP SEQUENCE '||v_ptt_spte_seq;
    v_ptt_gte_drp_cmd                     VARCHAR2(256)                      := 'DROP TABLE '||v_ptt_gte;
    v_ptt_spte_drp_cmd                    VARCHAR2(256)                      := 'DROP TABLE '||v_ptt_spte;
    v_pt_del_cmd                          VARCHAR2(256)                      := 'DELETE FROM TETOOLS.TEMP_TNSNAMES_PROTO_ENTRIES';
    v_insert_cmd                          VARCHAR2(4000);                    -- := 'INSERT INTO tetools.admin_tnsnames_proto_entries () VALUES (';
    validation_error                      EXCEPTION;
    no_contributor                        EXCEPTION;
    maintenance_mode_enabled              EXCEPTION;
    no_parent_attr_name                   EXCEPTION;
    generic_error                         EXCEPTION;
    PRAGMA EXCEPTION_INIT                 (validation_error        , -20023);
    PRAGMA EXCEPTION_INIT                 (no_contributor          , -20016);
    PRAGMA EXCEPTION_INIT                 (maintenance_mode_enabled, -20017);
    PRAGMA EXCEPTION_INIT                 (no_parent_attr_name     , -02291);
    PRAGMA EXCEPTION_INIT                 (generic_error           , -20010);
    --
    row_rowid                             VARCHAR2(32);
    row_proto_tns_id                      INTEGER;
    row_proto_tns_order_line              INTEGER;
    row_proto_tns_entry_line              VARCHAR2(64);
    row_attribute_name                    VARCHAR2(64);
    row_ref_attribute_name                VARCHAR2(64);
    row_attribute_value                   VARCHAR2(64);
    --
    TYPE ref_cursor_type               IS REF CURSOR;
    c_validate_gvn_entry                  ref_cursor_type;
    --
    PROCEDURE EXEC_DSQL( CMD IN VARCHAR2)
    AS
    BEGIN
      EXECUTE IMMEDIATE cmd;
      --
      EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXEC_DSQL> Error was: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('EXEC_DSQL> OFFENDING STATEMENT: ' || cmd);
    END EXEC_DSQL;
    --
    FUNCTION echo( p_string IN VARCHAR2, p_size IN INTEGER, p_pad IN VARCHAR2 DEFAULT ' ' ) RETURN VARCHAR2 AS
      v_string                           VARCHAR2(128);
      BEGIN
        SELECT RPAD( p_string, p_size, p_pad )||' ' INTO v_string FROM dual;
        RETURN v_string;
      END echo;
    --
    PROCEDURE max_proto_id(p_max_proto_id OUT INTEGER) AS
      v_proto_id    INTEGER;
    BEGIN
      SELECT COUNT(PROTO_TNS_ID) INTO v_proto_id FROM tetools.admin_tnsnames_proto_entries;
      --
      IF v_proto_id != 0 THEN
        SELECT MAX(PROTO_TNS_ID)+1 INTO v_proto_id FROM tetools.admin_tnsnames_proto_entries;
      ELSE
        v_proto_id := v_proto_id + 1;
      END IF;
      p_max_proto_id := v_proto_id;
    END max_proto_id;
    --
  BEGIN
    --
    tetools.admin_tnsnames.who_called(v_this_object);
    --
    tetools.admin_tnsnames.compare_roles(v_role_invusr, v_isinvusr_adm, v_isinvusr_con);
    --
    tetools.admin_tnsnames.query_tns(v_tns_alias, v_target_phase, v_does_exist);
    --
          SELECT user INTO v_username FROM dual;
          SELECT user_id INTO v_userid FROM dba_users WHERE username = v_username;
          max_proto_id(v_proto_tns_id);
    --
    EXEC_DSQL(v_ptt_gte_cr8_cmd);
    EXEC_DSQL(v_ptte_spte_seq_cmd);
    --
    SELECT tetools.admin_tnsnames_proto_entries_prototnsid_seq.nextval INTO v_proto_tns_id FROM dual;
    --
    EXECUTE IMMEDIATE 'INSERT INTO tetools.ORA$PTT_given_tns_entry_'||v_audsid||' (proto_tns_id, gvn_tns_entry) VALUES ( :v_proto_tns_id, :p_proto_entry)' USING v_proto_tns_id, p_proto_entry;
     EXECUTE IMMEDIATE 'INSERT INTO TETOOLS.TEMP_TNSNAMES_PROTO_ENTRIES (proto_tns_id, proto_tns_order_line, proto_tns_entry_line)
      SELECT proto_tns_id,
             tetools.PTT_split_proto_tns_entries_order_seq.nextval,
             regexp_replace(TRIM(x.str), ''[,?<>!@$%^&~`+]'', '''', 1, 0, ''i'') AS proto_tns_entry_line
        FROM tetools.ORA$PTT_given_tns_entry_'||v_audsid||'
       CROSS JOIN TABLE(tetools.slice_clob( gvn_tns_entry )) x
       WHERE proto_tns_id = :v_proto_tns_id
         AND TRIM(x.str) IS NOT NULL' USING v_proto_tns_id;
    --
    OPEN c_validate_gvn_entry
    FOR
    q'[SELECT atp.proto_tns_id
         , atp.order_id
         , atp.proto_tns_entry_line
         , atp.tns_attr attribute_name
         , NVL(ata.attribute_name, 'UNMATCHED_ATTRIBUTE') as ref_attribute_name
         --, ata.attribute_name as ref_attribute_name
         , atp.TNS_ATTR_VALUE
    FROM  admin_tnsnames_attributes ata
    RIGHT OUTER JOIN tetools.admin_tnsnames_proto_checks atp ON ata.attribute_name = atp.tns_attr
    ORDER BY atp.proto_tns_id, atp.order_id
    ]';
    --
    LOOP
      FETCH c_validate_gvn_entry INTO row_proto_tns_id, row_proto_tns_order_line, row_proto_tns_entry_line, row_attribute_name, row_ref_attribute_name, row_attribute_value;
      EXIT WHEN c_validate_gvn_entry%NOTFOUND;
      --
      -- We hoeven niet te kijken of het attribute wel goed gevormd is, als dit niet zo is, wordt dit afgevangen door de foreign key constraint.
      v_int_l_syntax_valdtd  := 'Y';
      v_int_l_value_valdtd   := 'N';
      v_last_i_valdtd_date := SYSDATE;
      --
      IF row_attribute_value != 'UNMATCHED_VALUE' THEN
        v_int_l_value_valdtd   := 'Y';
      ELSE
        v_cont           := 'N';
      END IF;
      --
      EXECUTE IMMEDIATE 'INSERT INTO tetools.admin_tnsnames_proto_entries (PROTO_TNS_ID,TNS_ATTR,TNS_ATTR_VALUE,USER_ID,USERNAME,ISADMIN,ISCONTRIBUTOR,USER_ROLES,CALLED_FROM,INTAKE_LINE_SYNTAX_VALIDATED,INTAKE_LINE_VALUE_VALIDATED,LAST_INTAKE_VALIDATION_DATE) VALUES ( :v_proto_tns_id,:row_ref_attribute_name,:row_attribute_value,:v_userid,:v_username,:v_isinvusr_adm,:v_isinvusr_con,:v_role_invusr,:v_this_object,:v_int_l_syntax_valdtd,:v_int_l_value_valdtd,:v_last_i_valdtd_date )' USING v_proto_tns_id,row_ref_attribute_name,row_attribute_value,v_userid,v_username,v_isinvusr_adm,v_isinvusr_con,JSON_OBJECT('INVOKING_USER_ROLES' VALUE v_role_invusr),v_this_object,v_int_l_syntax_valdtd,v_int_l_value_valdtd,v_last_i_valdtd_date;
      END LOOP;
    --
    SELECT JSON_SERIALIZE(
             JSON_OBJECT('PROTO_TNS_ID' VALUE at1.proto_tns_id,
                         'attributes' VALUE
                         JSON_ARRAYAGG(
                           JSON_OBJECT( KEY at1.tns_attr VALUE at1.tns_attr_value
                           )
                         )
             ) PRETTY
           ) INTO v_json
      FROM admin_tnsnames_proto_entries at1
     WHERE at1.proto_tns_id = v_proto_tns_id
     GROUP BY at1.proto_tns_id;
    --
    EXEC_DSQL('COMMIT');
    --
    evaluate_entry(v_proto_tns_id);
    --
    IF v_cont = 'Y' THEN
      report_proto_registration(v_json, v_proto_tns_id, 'ALL');
    ELSIF v_cont = 'N' THEN
      report_proto_registration(v_json, v_proto_tns_id, 'WARNING');
    ELSE
      report_proto_registration(v_json, v_proto_tns_id, 'ERROR');
    END IF;
    --
    --
    CLOSE c_validate_gvn_entry;
    --
    EXEC_DSQL(v_ptt_gte_drp_cmd);
    EXEC_DSQL(v_ptte_spte_drp_cmd);
    EXEC_DSQL(v_pt_del_cmd);
    --
    --
    EXCEPTION
    WHEN no_parent_attr_name      THEN
      ROLLBACK;
      EXEC_DSQL(v_ptt_gte_drp_cmd);
      EXEC_DSQL(v_ptte_spte_drp_cmd);
      EXEC_DSQL(v_pt_del_cmd);
      --DBMS_OUTPUT.PUT_LINE( echo(v_proto_tns_id, 8) || echo(row_ref_attribute_name, 32) || echo(row_attribute_value, 52) || echo(v_userid, 8) || echo(v_username, 8) || echo(v_isinvusr_adm, 3) || echo(v_isinvusr_con, 3) || echo(v_this_object, 16) || echo(v_syntax_valdtd, 3) );
      --DBMS_OUTPUT.PUT_LINE('');
      notify('5546673008', v_this_object, ' OFFENDING ENTRY LINE: '|| row_ref_attribute_name);
    WHEN validation_error         THEN
      ROLLBACK;
      EXEC_DSQL(v_ptt_gte_drp_cmd);
      EXEC_DSQL(v_ptte_spte_drp_cmd);
      EXEC_DSQL(v_pt_del_cmd);
      tetools.admin_tnsnames.report_registration(v_json, v_proto_tns_id);
      RAISE;
    WHEN no_contributor           THEN
      ROLLBACK;
      EXEC_DSQL(v_ptt_gte_drp_cmd);
      EXEC_DSQL(v_ptte_spte_drp_cmd);
      EXEC_DSQL(v_pt_del_cmd);
      v_role_invusr := ' NO CONTRIBUTOR';
      v_cont        := 'N';
      tetools.admin_tnsnames.report_status(v_tnsnames_status, v_role_invusr, v_cont, NULL);
      RAISE;
    WHEN maintenance_mode_enabled THEN
      ROLLBACK;
      EXEC_DSQL(v_ptt_gte_drp_cmd);
      EXEC_DSQL(v_ptte_spte_drp_cmd);
      EXEC_DSQL(v_pt_del_cmd);
      tetools.admin_tnsnames.report_status(v_tnsnames_status, v_role_invusr, v_cont, NULL);
      IF v_cont = 'N'             THEN
        RAISE;
      END IF;
    WHEN generic_error            THEN
      ROLLBACK;
      EXEC_DSQL(v_ptt_gte_drp_cmd);
      EXEC_DSQL(v_ptte_spte_drp_cmd);
      EXEC_DSQL(v_pt_del_cmd);
      notify('0089443894', v_this_object, DBMS_UTILITY.format_error_stack);
    WHEN OTHERS                   THEN
      ROLLBACK;
      EXEC_DSQL(v_ptt_gte_drp_cmd);
      EXEC_DSQL(v_ptte_spte_drp_cmd);
      EXEC_DSQL(v_pt_del_cmd);
      notify('9889359543', v_this_object, DBMS_UTILITY.format_error_stack);
  END intake_entry;
  --
END admin_tnsnames_proto;
/

