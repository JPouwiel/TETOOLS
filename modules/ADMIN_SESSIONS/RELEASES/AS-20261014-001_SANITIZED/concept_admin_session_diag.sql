-- C01: independent concept component; NOT COMPILED OR EXECUTED.
-- Requires a valid TETOOLS.ADMIN_LOGGER exposing SPEC408 procedure overloads.
-- This component does not submit, approve, claim, or terminate a session.
-- It is optional diagnostic logging, not mandatory audit persistence.
CREATE OR REPLACE PACKAGE tetools.admin_session_diag AUTHID DEFINER AS
  PROCEDURE emit_event(
    p_request_id     IN NUMBER,
    p_attempt_id     IN VARCHAR2,
    p_event         IN VARCHAR2,
    p_message       IN VARCHAR2,
    p_level         IN VARCHAR2,
    p_call_completed OUT BOOLEAN,
    p_failure       OUT VARCHAR2);
END admin_session_diag;
/
CREATE OR REPLACE PACKAGE BODY tetools.admin_session_diag AS
  PROCEDURE emit_event(
    p_request_id     IN NUMBER,
    p_attempt_id     IN VARCHAR2,
    p_event         IN VARCHAR2,
    p_message       IN VARCHAR2,
    p_level         IN VARCHAR2,
    p_call_completed OUT BOOLEAN,
    p_failure       OUT VARCHAR2)
  IS
    l_module       VARCHAR2(64);
    l_action       VARCHAR2(64);
    l_client_info  VARCHAR2(64);
    l_saved        BOOLEAN := FALSE;
    l_payload      VARCHAR2(4000);
    l_level        VARCHAR2(10) := UPPER(p_level);
    l_context      VARCHAR2(100);
    -- Restoration must also run when the logger raises an exception.
    PROCEDURE restore_context IS
    BEGIN
      IF l_saved THEN
        DBMS_APPLICATION_INFO.SET_MODULE(l_module, l_action);
        DBMS_APPLICATION_INFO.SET_CLIENT_INFO(l_client_info);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        p_call_completed := FALSE;
        p_failure := SUBSTR(p_failure || CHR(10) ||
          'Context restore failed: ' || SQLERRM, 1, 2000);
    END restore_context;
  BEGIN
    p_call_completed := FALSE;
    p_failure := NULL;
    DBMS_APPLICATION_INFO.READ_MODULE(l_module, l_action);
    DBMS_APPLICATION_INFO.READ_CLIENT_INFO(l_client_info);
    l_saved := TRUE;
    -- Bound diagnostics only. Never truncate executable target identity.
    IF p_event IS NULL OR LENGTH(p_event) > 40
       OR p_attempt_id IS NULL OR LENGTH(p_attempt_id) > 64
       OR p_request_id IS NULL OR p_request_id <= 0
       OR p_request_id != TRUNC(p_request_id)
       OR l_level IS NULL OR l_level NOT IN ('INFO','WARNING','ERROR')
    THEN
      p_failure := 'Invalid diagnostic event contract.';
    ELSE
      l_context := 'ADMIN_SESSION.' || p_event;
      SELECT JSON_OBJECT(
               'request_id' VALUE p_request_id,
               'attempt_id' VALUE p_attempt_id,
               'event' VALUE p_event,
               'message' VALUE SUBSTR(p_message, 1, 500),
               'message_truncated' VALUE
                 CASE WHEN LENGTH(p_message)>500 THEN 'Y' ELSE 'N' END
               RETURNING VARCHAR2(4000))
        INTO l_payload FROM dual;
      -- Use procedure overloads and named arguments, not function status=1.
      -- FORCE is a routing request. It does not acknowledge persistence.
      CASE l_level
        WHEN 'ERROR' THEN
          tetools.admin_logger.log_error_force(
            context_in=>l_context, data_in=>l_payload, batch=>FALSE);
        WHEN 'WARNING' THEN
          tetools.admin_logger.log_warning_force(
            context_in=>l_context, data_in=>l_payload, batch=>FALSE);
        ELSE
          tetools.admin_logger.log_info_force(
            context_in=>l_context, data_in=>l_payload, batch=>FALSE);
      END CASE;
      p_call_completed := TRUE;
    END IF;
    restore_context;
  EXCEPTION
    WHEN OTHERS THEN
      -- The enclosing domain handler must capture its original error first.
      -- This optional adapter returns logger failure without masking it.
      p_call_completed := FALSE;
      p_failure := SUBSTR(DBMS_UTILITY.FORMAT_ERROR_STACK || CHR(10) ||
                         DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 1, 2000);
      restore_context;
  END emit_event;
END admin_session_diag;
/
