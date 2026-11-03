CREATE OR REPLACE PROCEDURE ADMIN_VERSION_COMPARE (p_to_compare_version IN VARCHAR2, p_base_version IN VARCHAR2, p_return OUT VARCHAR2)
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
  v_batch                   BOOLEAN       := TRUE;
  logbatch_id               PLS_INTEGER;
  l_depth                   PLS_INTEGER;
  l_lvl_object              PLS_INTEGER;
  l_lvl_caller              PLS_INTEGER;
  segment_numeral           EXCEPTION;
  PRAGMA EXCEPTION_INIT     (segment_numeral , -20011);
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
  WHEN segment_numeral                                                                                                     THEN
    tetools.admin_logger.log_error_force (l_context, RPAD(v_caller||':: SEGMENT',54)||seg_current_var||' is not a number.) (CUR: '||TO_CHAR(seg_current_num)||'; BASE: '||TO_CHAR(v_base_ver)||')');
    p_return := 'FAIL';
    --RAISE;
  WHEN OTHERS                                                                                                              THEN
    RAISE;
END ADMIN_VERSION_COMPARE;
/



DECLARE
  v_status          VARCHAR2(14);
  v_current_version VARCHAR2(12) := '26.1.3.0.3';
  v_base_version    VARCHAR2(12) := '19.1.03';
BEGIN
  ADMIN_VERSION_COMPARE(v_current_version, v_base_version, v_status);
  DBMS_OUTPUT.PUT_LINE('VERSION: '||v_current_version||' has validation status: '||v_status);
END;
/
