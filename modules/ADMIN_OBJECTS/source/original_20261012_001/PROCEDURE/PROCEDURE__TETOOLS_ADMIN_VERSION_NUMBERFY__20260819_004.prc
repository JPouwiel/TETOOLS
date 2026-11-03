CREATE OR REPLACE PROCEDURE ADMIN_VERSION_NUMBERFY (p_current_version IN VARCHAR2, p_return OUT VARCHAR2)
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
  v_caller      := UTL_CALL_STACK.concatenate_subprogram(UTL_CALL_STACK.subprogram(l_lvl_object));
  v_this_object := UTL_CALL_STACK.concatenate_subprogram(UTL_CALL_STACK.subprogram(l_lvl_caller));
  --
  tetools.admin_logger.toggle_logging(modus => 'ON', send_log_to_in => 'S');
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
    tetools.admin_logger.log_runtime (l_context, RPAD(v_caller||':: SEGMENT',54)||seg_current_var||' is not a number.) (CUR: '||TO_CHAR(seg_current_num)||')');
    p_return := 'FAIL';
    --RAISE;
  WHEN OTHERS                                                                                                              THEN
    RAISE;
END ADMIN_VERSION_NUMBERFY;
/

DECLARE
  v_version1                VARCHAR2(16)  := '26.03.07.01';
  v_version2                VARCHAR2(16)  := '26.04';
  v_result                  VARCHAR2(16);
  --
BEGIN
  ADMIN_VERSION_NUMBERFY(v_version1, v_result);
  DBMS_OUTPUT.PUT_LINE(v_result);
  --
  ADMIN_VERSION_NUMBERFY(v_version2, v_result);
  DBMS_OUTPUT.PUT_LINE(v_result);
END;
/
