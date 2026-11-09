-- T06-01 Client B only, while Client A holds guard lock. Capture wall-clock.
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SET TIMING ON
SELECT guard_id FROM tetools.admin_logger_guard WHERE guard_id=1 FOR UPDATE WAIT 5;
PROMPT If A retained lock for >5s, expect ORA-30006; record actual result.
ROLLBACK;
