-- Read-only helper AND standalone entry: shared gate first; caller case/op preserved.
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
@@00_safety_gate.sql
DECLARE l_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO l_count FROM ALL_OBJECTS WHERE owner='TETOOLS'
    AND object_name IN ('ADMIN_LOGGER_SESSIONS','ADMIN_LOGGER_CONFIG','ADMIN_LOGGER_LOG',
      'ADMIN_LOGGER_INCIDENT','ADMIN_LOGGER_GUARD','ADMIN_LOGGER_LOGBATCH_SEQ') AND status='VALID';
  IF l_count <> 6 THEN RAISE_APPLICATION_ERROR(-20100,'Missing/invalid expected tables or sequence'); END IF;
  SELECT COUNT(*) INTO l_count FROM ALL_OBJECTS WHERE owner='TETOOLS' AND object_name='ADMIN_LOGGER'
    AND object_type IN ('PACKAGE','PACKAGE BODY') AND status='VALID';
  IF l_count <> 2 THEN RAISE_APPLICATION_ERROR(-20101,'Package spec/body not VALID'); END IF;
END;
/
-- Source file pins are checked offline; export installed USER_SOURCE to the evidence bundle.
-- VALID alone is not a database source-hash assertion. No empty-schema requirement here.
