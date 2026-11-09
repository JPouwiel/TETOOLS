-- DROP SEQUENCE tetools.admin_logger_logbatch_seq;
-- DROP TABLE tetools.admin_logger_log;
-- DROP TABLE tetools.admin_logger_config;
-- DROP TABLE tetools.admin_logger_sessions;

-- Zie SEQ_20260527__ADMIN_LOGGER__001.sql
--CREATE SEQUENCE tetools.admin_logger_logbatch_seq
--  START WITH     1
--  MINVALUE       1
--  INCREMENT BY   1
--  ORDER;

--SELECT tetools.admin_logger_logbatch_seq.nextval FROM dual;




CREATE TABLE tetools.admin_logger_sessions 
( 
  logsession_id      INTEGER GENERATED ALWAYS AS IDENTITY,
  created_on         DATE                     NOT NULL,
  sid                NUMBER                   NOT NULL,
  serial#            NUMBER                   NOT NULL,
  audsid             NUMBER                   NOT NULL,
  logon_user         VARCHAR2(128)            NOT NULL,
  logon_time         DATE                     NOT NULL,
  current_user       VARCHAR2(128)                    ,
  current_schema     VARCHAR2(128)                    ,
  proxy_user         VARCHAR2(128)                    ,
  incident_id        INTEGER                          ,
  CONSTRAINT admin_logger_session_details_pk PRIMARY KEY (logsession_id) ENABLE,
  CONSTRAINT admin_logger_session_phys_uk    UNIQUE (sid,serial#,audsid,logon_user,logon_time)
)
  PARTITION BY RANGE (created_on) 
  INTERVAL(NUMTOYMINTERVAL(1, 'YEAR'))
    ( PARTITION p2026 VALUES LESS THAN (TO_DATE('1-1-2027', 'DD-MM-YYYY'))
    )
/

COMMENT ON  TABLE tetools.admin_logger_sessions IS 'Logging table for sessions that call admin_logger package.';
COMMENT ON COLUMN tetools.admin_logger_sessions.created_on IS 'Creation datetime for logrow for session.';
COMMENT ON COLUMN tetools.admin_logger_sessions.sid IS 'sid of logged session.';
COMMENT ON COLUMN tetools.admin_logger_sessions.serial# IS 'serial# of logged session.';
COMMENT ON COLUMN tetools.admin_logger_sessions.audsid IS 'audsid of logged session.';
COMMENT ON COLUMN tetools.admin_logger_sessions.logon_user IS 'logon_user of logged session.';
COMMENT ON COLUMN tetools.admin_logger_sessions.logon_time IS 'logon_time of logged session.';
COMMENT ON COLUMN tetools.admin_logger_sessions.current_user IS 'current_user of logged session.';
COMMENT ON COLUMN tetools.admin_logger_sessions.current_schema IS 'current_schema of logged session.';
COMMENT ON COLUMN tetools.admin_logger_sessions.proxy_user IS 'proxy_user of logged session.';
COMMENT ON COLUMN tetools.admin_logger_sessions.incident_id IS 'corresponding incident_ID of logged session if created by procedure persist_session_incident.';



CREATE TABLE tetools.admin_logger_config 
( 
  config_id          INTEGER GENERATED ALWAYS AS IDENTITY,
  created_on         DATE                     NOT NULL,
  logsession_id      INTEGER                  NOT NULL,
  logger_on          VARCHAR2(1)              NOT NULL,
  logger_target      VARCHAR2(1)              NOT NULL,
  debug_on           VARCHAR2(1)                      ,
  debug_target       VARCHAR2(1)                      ,
  batch_mode         VARCHAR2(1)                      ,
  logbatch_id        INTEGER                          ,
  context_filter     VARCHAR2(4000)                   ,
  callstack_filter   VARCHAR2(4000)                   ,
  CONSTRAINT admin_logger_config_pk             PRIMARY KEY (config_id) ENABLE,
  CONSTRAINT admin_logger_config_lsi_uk         UNIQUE (logsession_id) ENABLE,
  CONSTRAINT admin_logger_config_lgo_ck         CHECK (logger_on     IN ('Y','N')) ENABLE,
  CONSTRAINT admin_logger_config_lgt_ck         CHECK (logger_target IN ('S','T')) ENABLE,
  CONSTRAINT admin_logger_config_dbo_ck         CHECK (debug_on      IN ('Y','N')) ENABLE,
  CONSTRAINT admin_logger_config_dbt_ck         CHECK (debug_target  IN ('S','T')) ENABLE,
  CONSTRAINT admin_logger_config_btm_ck         CHECK (batch_mode    IN ('S','B')) ENABLE,
  CONSTRAINT admin_logger_config_batch_state_ck CHECK ((NVL(batch_mode,'S')='S' AND logbatch_id IS NULL) OR (NVL(batch_mode,'S')='B' AND logbatch_id IS NOT NULL AND logbatch_id>0)),
  CONSTRAINT admin_logger_config_sessions_logsession_id_fk FOREIGN KEY (logsession_id) REFERENCES tetools.admin_logger_sessions (logsession_id) DEFERRABLE INITIALLY IMMEDIATE ENABLE
)
  PARTITION BY RANGE (created_on) 
  INTERVAL(NUMTOYMINTERVAL(1, 'YEAR'))
    ( PARTITION p2026 VALUES LESS THAN (TO_DATE('1-1-2027', 'DD-MM-YYYY'))
    )
/

CREATE UNIQUE INDEX tetools.admin_logger_active_batch_uk ON tetools.admin_logger_config(CASE WHEN batch_mode='B' THEN logbatch_id END)
/



COMMENT ON  TABLE tetools.admin_logger_config IS 'Logging table for configurations for sessions that call admin_logger package.';
COMMENT ON COLUMN tetools.admin_logger_config.created_on IS 'Creation datetime for logrow for session.';
COMMENT ON COLUMN tetools.admin_logger_config.logsession_id IS 'Identifier for configuration for session that calls admin_logger package.';
COMMENT ON COLUMN tetools.admin_logger_config.logger_on IS 'Identifies if log functionality is on.';
COMMENT ON COLUMN tetools.admin_logger_config.logger_target IS 'Identifies the log target fr session (Screen or Table)';
COMMENT ON COLUMN tetools.admin_logger_config.debug_on IS 'Identifies if debug functionality is on.';
COMMENT ON COLUMN tetools.admin_logger_config.debug_target IS 'Identifies the debug target fr session (Screen or Table)';
COMMENT ON COLUMN tetools.admin_logger_config.logbatch_id IS 'Identifier for batch on which logrows in admin_logger_log table are grouped, if applicable';
COMMENT ON COLUMN tetools.admin_logger_config.context_filter IS 'Filter for the context being logged.';
COMMENT ON COLUMN tetools.admin_logger_config.callstack_filter IS 'Filter for the callstack logged.';




CREATE TABLE tetools.admin_logger_log 
( 
  logger_id          INTEGER GENERATED ALWAYS AS IDENTITY,
  created_on         TIMESTAMP(3)             NOT NULL,
  logsession_id      NUMBER                   NOT NULL,
  logbatch_id        INTEGER                          ,
  log_category       VARCHAR2(7)                      ,
  log_lines          INTEGER                          ,
  context            VARCHAR2(4000)                   , 
  text               CLOB                             , 
  callstack          CLOB                             ,
  CONSTRAINT admin_logger_log_pk                     PRIMARY KEY (logger_id) ENABLE,
  CONSTRAINT admin_logger_log_category_ck            CHECK       (log_category IN ('ERROR', 'WARNING', 'INFO', 'RUNTIME', 'DEBUG')) ENABLE
)
  PARTITION BY RANGE (created_on) 
  INTERVAL(NUMTOYMINTERVAL(1, 'MONTH'))
    ( PARTITION p202605 VALUES LESS THAN (TO_DATE('1-6-2026', 'DD-MM-YYYY'))
    )
/

CREATE UNIQUE INDEX tetools.admin_logger_position_uk ON tetools.admin_logger_log (
  CASE WHEN logbatch_id>0 AND log_lines>0 THEN logsession_id END,
  CASE WHEN logbatch_id>0 AND log_lines>0 THEN logbatch_id END,
  CASE WHEN logbatch_id>0 AND log_lines>0 THEN log_lines END
)
/

COMMENT ON  TABLE tetools.admin_logger_log IS 'Logging table target as set in admin_logger_config.logger_target or admin_logger_config.debug_target.';
COMMENT ON COLUMN tetools.admin_logger_log.created_on IS 'Creation datetime for logrow.';
COMMENT ON COLUMN tetools.admin_logger_log.logsession_id IS 'Identifier for configuration for session that calls admin_logger package.';
COMMENT ON COLUMN tetools.admin_logger_log.logbatch_id IS 'Identifier for batch on which logrows in admin_logger_log table are grouped.';
COMMENT ON COLUMN tetools.admin_logger_log.log_category IS 'Category for given logrow (ERROR, WARNING,INFO,RUNTIME,DEBUG).';
COMMENT ON COLUMN tetools.admin_logger_log.log_lines IS 'Sequence for logrow within logbatch.';
COMMENT ON COLUMN tetools.admin_logger_log.context IS 'Module for which row is logged.';
COMMENT ON COLUMN tetools.admin_logger_log.text IS 'Body of logged message.';
COMMENT ON COLUMN tetools.admin_logger_log.callstack IS 'Callstack info when applicable.';



CREATE TABLE tetools.admin_logger_incident
(
  incident_id        INTEGER GENERATED ALWAYS AS IDENTITY,
  created_on         TIMESTAMP(3)             NOT NULL   , 
  context            VARCHAR2(4000)           NOT NULL   ,
  status             VARCHAR2(9)              NOT NULL   ,
  reason             VARCHAR2(10)             NOT NULL   ,
  sid                NUMBER                   NOT NULL   ,
  serial#            NUMBER                   NOT NULL   ,
  audsid             NUMBER                   NOT NULL   ,
  logon_user         VARCHAR2(128)            NOT NULL   ,
  logon_time         DATE                     NOT NULL   ,
  current_user       VARCHAR2(128)                       ,
  current_schema     VARCHAR2(128)                       ,
  proxy_user         VARCHAR2(128)                       ,
  new_logsession_id  INTEGER                             ,
  callstack          CLOB                                ,
  backtrace          CLOB                                ,
  old_logsession_id  INTEGER                             ,
  error_stack        CLOB                                ,
  repair_error       CLOB                                ,
  sessions_snapshot  CLOB                                ,
  config_snapshot    CLOB,
  CONSTRAINT admin_logger_incident_pk                    PRIMARY KEY (incident_id) ENABLE,
  CONSTRAINT admin_logger_incident_context_ck            CHECK       (status IN ('SUBMITTED', 'OPEN', 'RESOLVED', 'CLOSED')) ENABLE
)
/
  
COMMENT ON  TABLE tetools.admin_logger_incident IS 'Logging table for incidents with availability of logsessions.';
COMMENT ON COLUMN tetools.admin_logger_incident.created_on IS 'Creation datetime for logrow.';
COMMENT ON COLUMN tetools.admin_logger_incident.context IS 'Module for which row is logged.';
COMMENT ON COLUMN tetools.admin_logger_incident.status IS 'Status of incident (SUBMITTED,OPEN,RESOLVED,CLOSED).';
COMMENT ON COLUMN tetools.admin_logger_incident.reason IS 'Reason for incident (missing_id,extra_id).';
COMMENT ON COLUMN tetools.admin_logger_incident.sid IS 'sid of logged session.';
COMMENT ON COLUMN tetools.admin_logger_incident.serial# IS 'serial# of logged session.';
COMMENT ON COLUMN tetools.admin_logger_incident.audsid IS 'audsid of logged session.';
COMMENT ON COLUMN tetools.admin_logger_incident.logon_user IS 'logon_user of logged session.';
COMMENT ON COLUMN tetools.admin_logger_incident.logon_time IS 'logon_time of logged session.';
COMMENT ON COLUMN tetools.admin_logger_incident.current_user IS 'current_user of logged session.';
COMMENT ON COLUMN tetools.admin_logger_incident.current_schema IS 'current_schema of logged session.';
COMMENT ON COLUMN tetools.admin_logger_incident.proxy_user IS 'proxy_user of logged session.';
COMMENT ON COLUMN tetools.admin_logger_incident.new_logsession_id IS 'Newly recreated logsession_id for logsession.';
COMMENT ON COLUMN tetools.admin_logger_incident.callstack IS 'Callstack info when applicable.';
COMMENT ON COLUMN tetools.admin_logger_incident.backtrace IS 'Backtrace error message when applicable.';
COMMENT ON COLUMN tetools.admin_logger_incident.old_logsession_id IS  'Last known cached registration ID; NULL if it was not available.';
COMMENT ON COLUMN tetools.admin_logger_incident.new_logsession_id IS  'Validated registration selected after repair; it can be an existing registration.';
COMMENT ON COLUMN tetools.admin_logger_incident.sessions_snapshot IS  'Original matching session rows before cooperative repair; JSON array.';
COMMENT ON COLUMN tetools.admin_logger_incident.config_snapshot   IS  'Original matching configuration rows before cooperative repair; JSON array.';


CREATE TABLE tetools.admin_logger_guard (
  guard_id NUMBER(1) NOT NULL,
  CONSTRAINT admin_logger_guard_pk PRIMARY KEY (guard_id),
  CONSTRAINT admin_logger_guard_ck CHECK (guard_id=1)
);
INSERT INTO tetools.admin_logger_guard(guard_id) VALUES (1);
COMMIT;
-- All cooperative registration/configuration/purge writers must lock this row.
-- The audit helper and table log writer must not lock it.

-- DROP SEQUENCE tetools.admin_logger_logbatch_seq;
-- DROP TABLE tetools.admin_logger_logging;
-- DROP TABLE tetools.admin_logger_session_details;
-- DROP TABLE tetools.admin_logger_settings;