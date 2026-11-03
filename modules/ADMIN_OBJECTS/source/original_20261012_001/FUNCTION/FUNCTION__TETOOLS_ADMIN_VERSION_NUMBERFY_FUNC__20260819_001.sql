CREATE OR REPLACE FUNCTION ADMIN_VERSION_NUMBERFY_FUNC (p_current_version IN VARCHAR2 )
RETURN VARCHAR2
IS
  l_context                 VARCHAR2(128) := $$PLSQL_UNIT;
  v_this_object             VARCHAR2(128);
  v_caller                  VARCHAR2(128);
  v_current_version         VARCHAR2(32)  := p_current_version;
  v_result                  VARCHAR2(32);
  is_numeral                CHAR(1)       := 'N';
  v_rowtext                 VARCHAR2(32767);
  v_batch                   BOOLEAN       := TRUE;
  logbatch_id               PLS_INTEGER;
  l_depth                   PLS_INTEGER;
  l_lvl_object              PLS_INTEGER;
  l_lvl_caller              PLS_INTEGER;
  segment_numeral           EXCEPTION;
  PRAGMA EXCEPTION_INIT     (segment_numeral , -20011);
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
  admin_version_numberfy(v_current_version, v_result);
  --
  IF v_result = 'FAIL' THEN
    RAISE segment_numeral;
  ELSE
    RETURN (v_result);
  END IF;
  --
  EXCEPTION
  WHEN segment_numeral                                                                                                     THEN
    tetools.admin_logger.log_error_force (l_context, v_current_version||' is not a number.');
    v_result := 'FAIL';
	RETURN (v_result);
END ADMIN_VERSION_NUMBERFY_FUNC;
/




WITH cte_val AS (
SELECT 911 AS cat, 'low'  AS pos, '26.1.3.0.3' AS val, '26001.003000003' numberfied, ADMIN_VERSION_NUMBERFY_FUNC('26.1.3.0.3') AS num FROM dual UNION ALL
SELECT 911 AS cat, 'mid'  AS pos, '26.1.99'    AS val, '26001.099'       numberfied, ADMIN_VERSION_NUMBERFY_FUNC('26.1.99')    AS num FROM dual UNION ALL
SELECT 911 AS cat, 'fail' AS pos, '26.a1.79'   AS val, 'FAIL'            numberfied, ADMIN_VERSION_NUMBERFY_FUNC('26.a1.79')   AS num FROM dual UNION ALL
SELECT 911 AS cat, 'high' AS pos, '26.3'       AS val, '26003'           numberfied, ADMIN_VERSION_NUMBERFY_FUNC('26.3')       AS num FROM dual
),
     cte_max AS (
SELECT MAX(num) num FROM cte_val WHERE REGEXP_LIKE(REPLACE(num, '.', ''), '^([0-9]*)$')
)
SELECT a.*
  FROM cte_val a
  JOIN cte_max b ON a.num = b.num;
 

