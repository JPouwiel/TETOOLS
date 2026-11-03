  CREATE OR REPLACE PROCEDURE KILL_SESSION( p_sid IN NUMBER, p_serial IN NUMBER )
  AS
    v_this_object            VARCHAR2(128);
    v_sid                    NUMBER;
    v_serial                 NUMBER;
    v_audsid                 NUMBER;
    v_inv_username           VARCHAR2(128) := SYS_CONTEXT('USERENV', 'SESSION_USER');
    v_result_num             NUMBER;
    v_result                 VARCHAR2(2000);
    v_audsid1                NUMBER := SYS_CONTEXT('USERENV','SESSIONID');
    v_username               VARCHAR2(128);
    p_cursor                 sys_refcursor;
    --
    FUNCTION get_invoking_serial RETURN NUMBER
    AS
     v_return NUMBER;
    BEGIN
      SELECT dbms_debug_jdwp.current_session_serial INTO v_return FROM dual;
    --
      RETURN v_return;
    END get_invoking_serial;
--
  BEGIN
  /* This procedure is the beginning of a termination request. */
    --
    tetools.admin_session.who_called(v_this_object);
    --
    v_serial := get_invoking_serial;
    --
    DBMS_OUTPUT.PUT_LINE('SID: '||v_sid||', SERIAL#: '||v_serial);
    DBMS_OUTPUT.PUT_LINE(' ');
    --
    --open p_cursor for
    --   SELECT DECODE(ses.username, NULL, SUBSTR(prc.PROGRAM, -5, 4), ses.username) username,
    --        DECODE(ses.audsid,SYS_CONTEXT('USERENV','SESSIONID'),'*', NULL) s,
    --        TO_CHAR(ses.logon_time, 'YYYY-MM-DD HH24:MI:SS') logon_time,
    --        DECODE(ses.audsid, 0, 'Not eligible for termination!', DECODE(ses.username, NULL, 'Not eligible for termination!', ' EXEC TETOOLS.ADMIN_SESSION.terminate_session('||ses.sid||', '||ses.serial#||');')) statement,
    --        audsid, 
    --        ses.sid, 
    --        ses.serial#
    --   FROM v$session ses, v$process prc, dba_users dba
    --  WHERE ses.paddr = prc.addr(+)
    --    AND ses.user# = dba.user_id
    --    AND dba.oracle_maintained = 'N'
    --    AND ses.username = v_inv_username
    --    AND ses.status   = 'ACTIVE'
    --    AND ses.audsid  != v_audsid1;
    ----
    --DBMS_SQL.return_result(p_cursor);
    --DBMS_OUTPUT.PUT_LINE(' ');
    --
    WITH cte_sessions AS (
       SELECT username, DECODE(audsid,SYS_CONTEXT('USERENV','SESSIONID'),'*', NULL) invoking_session, sid, serial#, audsid, status, state
         FROM v$session
        WHERE username = SYS_CONTEXT('USERENV', 'SESSION_USER')
    ),
    cte_active_sessions AS (
      SELECT username, invoking_session, sid, serial#, audsid, status, state
        FROM cte_sessions
       WHERE status = 'ACTIVE'
         AND invoking_session IS NULL
    )
    SELECT NVL(sid, 0), NVL(serial#, 0)
      INTO v_sid, v_serial
      FROM cte_active_sessions
     WHERE sid = p_sid AND serial# = p_serial
    ORDER BY 1,2;
    --
    IF v_sid != 0 AND v_serial != 0 THEN
      DBMS_OUTPUT.PUT_LINE('FINAL SID: '||v_sid||', FINAL SERIAL#: '||v_serial);
    ELSE
      DBMS_OUTPUT.PUT_LINE('Uh-Oh !');
    END IF;
    DBMS_OUTPUT.PUT_LINE(' ');
  --
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END KILL_SESSION;
/



