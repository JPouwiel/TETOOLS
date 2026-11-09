-- T06-01 Client A only, separate authorized session; holds row lock until operator ROLLBACK.
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SET SERVEROUTPUT ON
SELECT guard_id FROM tetools.admin_logger_guard WHERE guard_id=1 FOR UPDATE WAIT 5;
PROMPT CLIENT A LOCK HELD. In separate client B run 62_T06_guard_client_B.sql.
PROMPT After capturing client B elapsed/exception, operator must ROLLBACK here.
