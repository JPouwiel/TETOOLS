-- Test proposal for Oracle Database 19c. Run only after the preflight review.
-- These statements do not change existing numeric precision.
ALTER TABLE tetools.admin_logger_incident ADD (
  old_logsession_id  INTEGER,
  error_stack       CLOB,
  repair_error      CLOB,
  sessions_snapshot CLOB,
  config_snapshot   CLOB
);
COMMENT ON COLUMN tetools.admin_logger_incident.old_logsession_id IS
  'Last known cached registration ID; NULL if it was not available.';
COMMENT ON COLUMN tetools.admin_logger_incident.new_logsession_id IS
  'Validated registration selected after repair; it can be an existing registration.';
COMMENT ON COLUMN tetools.admin_logger_incident.sessions_snapshot IS
  'Original matching session rows before cooperative repair; JSON array.';
COMMENT ON COLUMN tetools.admin_logger_incident.config_snapshot IS
  'Original matching configuration rows before cooperative repair; JSON array.';
CREATE TABLE tetools.admin_logger_guard (
  guard_id NUMBER(1) NOT NULL,
  CONSTRAINT admin_logger_guard_pk PRIMARY KEY (guard_id),
  CONSTRAINT admin_logger_guard_ck CHECK (guard_id=1)
);
INSERT INTO tetools.admin_logger_guard(guard_id) VALUES (1);
COMMIT;
-- All cooperative registration/configuration/purge writers must lock this row.
-- The audit helper and table log writer must not lock it.
