CREATE OR REPLACE PROCEDURE ADMIN_VERSION_VALIDATE (p_current_version IN VARCHAR2, p_min_version IN VARCHAR2, p_max_version IN VARCHAR2, p_return OUT VARCHAR2)
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
  logbatch_id               PLS_INTEGER;
  l_depth                   PLS_INTEGER;
  l_lvl_object              PLS_INTEGER;
  l_lvl_caller              PLS_INTEGER;
  segment_numeral           EXCEPTION;
  version_lt_min            EXCEPTION;
  version_gt_max            EXCEPTION;
  PRAGMA EXCEPTION_INIT     (segment_numeral , -20011);
  PRAGMA EXCEPTION_INIT     (version_lt_min  , -20012);
  PRAGMA EXCEPTION_INIT     (version_gt_max  , -20013);
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
  v_caller      := UTL_CALL_STACK.concatenate_subprogram(UTL_CALL_STACK.subprogram(l_lvl_object));
  v_this_object := UTL_CALL_STACK.concatenate_subprogram(UTL_CALL_STACK.subprogram(l_lvl_caller));
  --
  tetools.admin_logger.toggle_logging(modus => 'ON', send_log_to_in => 'T');
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
END ADMIN_VERSION_VALIDATE;
/



DECLARE
  v_status          VARCHAR2(14);
  v_current_version VARCHAR2(12) := '26.1.3.0.3';
  v_min_version     VARCHAR2(12) := '19.1.03';
  v_max_version     VARCHAR2(12) := '26.1.0';
BEGIN
  ADMIN_VERSION_VALIDATE(v_current_version, v_min_version, v_max_version, v_status);
  DBMS_OUTPUT.PUT_LINE('VERSION: '||v_current_version||' has validation status: '||v_status);
END;
/







SQL> DECLARE
  2    v_status          VARCHAR2(12);
  3    v_current_version VARCHAR2(12) := '19.1.3.0.3';
  4    v_min_version     VARCHAR2(12) := '19.1.03';
  5    v_max_version     VARCHAR2(12) := '26.1.0';
  6  BEGIN
  7    admin_validate_version(v_current_version, v_min_version, v_max_version, v_status);
  8    DBMS_OUTPUT.PUT_LINE('VERSION: '||v_current_version||' has validation status: '||v_status);
  9  END;
 10  /
VERSION: 19.1.3.0.3 has validation status: PASS

SQL> DECLARE
  2    v_status          VARCHAR2(12);
  3    v_current_version VARCHAR2(12) := '19.1.0.0.3';
  4    v_min_version     VARCHAR2(12) := '19.1.03';
  5    v_max_version     VARCHAR2(12) := '26.1.0';
  6  BEGIN
  7    recursive_proce(v_current_version, v_min_version, v_max_version, v_status);
  8    DBMS_OUTPUT.PUT_LINE('VERSION: '||v_current_version||' has validation status: '||v_status);
  9  END;
 10  /
CURRENT VERSION is less than minimum required version.
Consider upgrading the module.
Exiting...
VERSION: 19.1.0.0.3 has validation status: FAIL

SQL> DECLARE
  2    v_status          VARCHAR2(12);
  3    v_current_version VARCHAR2(12) := '26.1.0.0.3';
  4  BEGIN
  5    recursive_proce(v_current_version, v_status);
  6    DBMS_OUTPUT.PUT_LINE('VERSION: '||v_current_version||' has validation status: '||v_status);
  7  END;
  8  /
CURRENT VERSION is greater than maximum required version.
Consider reloading the required objects for this version of module.
Exiting...
VERSION: 26.1.0.0.3 has validation status: FAIL

PL/SQL procedure successfully completed.

SQL> DECLARE
  2    v_status          VARCHAR2(12);
  3    v_current_version VARCHAR2(12) := '7.1.0.0.3';
  4  BEGIN
  5    recursive_proce(v_current_version, v_status);
  6    DBMS_OUTPUT.PUT_LINE('VERSION: '||v_current_version||' has validation status: '||v_status);
  7  END;
  8  /
CURRENT VERSION is less than minimum required version.
Consider upgrading the module.
Exiting...
VERSION: 7.1.0.0.3 has validation status: FAIL