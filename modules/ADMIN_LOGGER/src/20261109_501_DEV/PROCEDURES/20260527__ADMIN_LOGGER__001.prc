CREATE OR REPLACE PROCEDURE do_more_stuff (p_emp_no IN NUMBER)
IS
  l_context     VARCHAR2(128) := $$PLSQL_UNIT;
  v_username    VARCHAR2(128) := 'TETOOLS';
  v_module      VARCHAR2(64);
  v_action      VARCHAR2(64);
  v_client_info VARCHAR2(64);
BEGIN
   admin_logger.log_activity (l_context, 'Starting empno: '||p_emp_no);
   FOR rec IN (SELECT *
                 FROM emp
                WHERE empno >= p_emp_no)
   LOOP
      admin_logger.log_activity (l_context, rec.empno||' employee_name = ' ||RPAD(rec.ename, 12, ' ')||' salary = ' || NVL(rec.sal, 0) * 1.02);
   END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE do_stuff (min_sal_in IN NUMBER)
IS
  l_context     VARCHAR2(128) := $$PLSQL_UNIT;
  v_username    VARCHAR2(128) := 'TETOOLS';
  v_module      VARCHAR2(64);
  v_action      VARCHAR2(64);
  v_client_info VARCHAR2(64);
BEGIN
   admin_logger.log_activity (l_context, 'Starting salary: '||min_sal_in);

   FOR rec IN (SELECT *
                 FROM emp
                WHERE sal >= min_sal_in)
   LOOP
      admin_logger.log_activity (l_context, 'employee_id = ' || rec.empno);
      do_more_stuff (rec.empno);
      admin_logger.log_activity (l_context, 'new salary = ' || NVL(rec.sal, 0));
   END LOOP;
END;
/