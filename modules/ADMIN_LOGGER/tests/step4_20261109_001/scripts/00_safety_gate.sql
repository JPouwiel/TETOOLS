-- SHARED READ-ONLY gate; no ADMIN_LOGGER reference (initialization is autonomous).
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SET DEFINE OFF
DECLARE
  -- Immutable in this preparation revision. DEFINE/bind/stale client values cannot grant GO.
  c_g09_status CONSTANT VARCHAR2(20) := 'NOT_GRANTED';
  c_g09_reference CONSTANT VARCHAR2(4000) := NULL;
BEGIN
  IF c_g09_status IS NULL OR c_g09_status <> 'GRANTED'
     OR c_g09_reference IS NULL THEN
    RAISE_APPLICATION_ERROR(-20909,'STOP: G09 NOT_GRANTED; separate central GO and reviewed authorization artifact required');
  END IF;
END;
/
-- Unreachable with current G09. No substitution or prompt is reached before the stop above.
-- These additional checks are a prepared design, NOT an authorized execution path.
SET DEFINE ON
DECLARE
  -- All approval pins must be filled ONLY in a separately approved/reviewed artifact.
  c_db CONSTANT VARCHAR2(128) := NULL;
  c_pdb CONSTANT VARCHAR2(128) := NULL;
  c_con CONSTANT NUMBER := NULL;
  c_principal CONSTANT VARCHAR2(128) := NULL;
  c_instance CONSTANT VARCHAR2(128) := NULL;
  c_service CONSTANT VARCHAR2(128) := NULL;
  c_cases CONSTANT VARCHAR2(4000) := NULL;
  c_operations CONSTANT VARCHAR2(4000) := NULL;
  l_cases VARCHAR2(4000) := '&&STEP4_CASE_IDS';
  l_operation VARCHAR2(30) := '&&STEP4_OPERATION';
  l_con NUMBER;
  PROCEDURE required(p_name VARCHAR2,p_value VARCHAR2) IS
  BEGIN
    IF p_value IS NULL OR TRIM(p_value) IS NULL OR UPPER(TRIM(p_value)) IN ('UNVERIFIED','NULL','NONE') THEN
      RAISE_APPLICATION_ERROR(-20901,'Missing/invalid required value: '||p_name);
    END IF;
  END;
BEGIN
  required('approved DB',c_db); required('approved PDB',c_pdb);
  required('approved principal',c_principal); required('approved instance',c_instance);
  required('approved service',c_service); required('approved cases',c_cases);
  required('approved operations',c_operations);
  IF c_con IS NULL OR c_con <= 2 OR c_con <> TRUNC(c_con) THEN
    RAISE_APPLICATION_ERROR(-20902,'Approved application PDB CON_ID required; root/seed/non-CDB forbidden');
  END IF;
  required('EXECUTION_APPROVED','&&EXECUTION_APPROVED');
  required('DBA_ENV_APPROVED','&&DBA_ENV_APPROVED');
  IF NVL('&&EXECUTION_APPROVED','NO') <> 'YES' OR NVL('&&DBA_ENV_APPROVED','NO') <> 'YES' THEN
    RAISE_APPLICATION_ERROR(-20903,'Execution request/DBA confirmation missing');
  END IF;
  required('TARGET_SCHEMA','&&TARGET_SCHEMA'); required('TARGET_PRINCIPAL','&&TARGET_PRINCIPAL');
  required('TARGET_DB_UNIQUE_NAME','&&TARGET_DB_UNIQUE_NAME'); required('TARGET_PDB','&&TARGET_PDB');
  required('TARGET_CON_ID','&&TARGET_CON_ID'); required('TARGET_INSTANCE','&&TARGET_INSTANCE');
  required('TARGET_SERVICE','&&TARGET_SERVICE'); required('TEST_RUN_ID','&&TEST_RUN_ID');
  required('TEST_CLIENT_ID','&&TEST_CLIENT_ID'); required('case IDs',l_cases); required('operation',l_operation);
  IF NOT REGEXP_LIKE('&&TARGET_CON_ID','^[0-9]+$') THEN
    RAISE_APPLICATION_ERROR(-20904,'Invalid CON_ID');
  END IF;
  IF NOT REGEXP_LIKE('&&TEST_RUN_ID','^[A-Z0-9_]{1,48}$')
     OR NOT REGEXP_LIKE('&&TEST_CLIENT_ID','^[A-Z0-9_]{1,48}$') THEN
    RAISE_APPLICATION_ERROR(-20904,'Invalid run/client marker');
  END IF;
  l_con := TO_NUMBER('&&TARGET_CON_ID');
  IF '&&TARGET_SCHEMA' <> 'TETOOLS'
     OR SYS_CONTEXT('USERENV','CURRENT_SCHEMA') <> 'TETOOLS'
     OR SYS_CONTEXT('USERENV','SESSION_USER') <> c_principal
     OR '&&TARGET_PRINCIPAL' <> c_principal
     OR NVL(SYS_CONTEXT('USERENV','DB_UNIQUE_NAME'),'!') <> c_db
     OR '&&TARGET_DB_UNIQUE_NAME' <> c_db
     OR NVL(SYS_CONTEXT('USERENV','CON_NAME'),'!') <> c_pdb OR '&&TARGET_PDB' <> c_pdb
     OR TO_NUMBER(SYS_CONTEXT('USERENV','CON_ID')) <> c_con OR l_con <> c_con
     OR NVL(SYS_CONTEXT('USERENV','INSTANCE_NAME'),'!') <> c_instance OR '&&TARGET_INSTANCE' <> c_instance
     OR NVL(SYS_CONTEXT('USERENV','SERVICE_NAME'),'!') <> c_service OR '&&TARGET_SERVICE' <> c_service THEN
    RAISE_APPLICATION_ERROR(-20905,'Actual connection differs from approved and requested identity');
  END IF;
  IF INSTR(','||c_operations||',',','||l_operation||',')=0 THEN
    RAISE_APPLICATION_ERROR(-20906,'Operation not approved');
  END IF;
  FOR n IN 1..REGEXP_COUNT(l_cases,',')+1 LOOP
    IF INSTR(','||c_cases||',',','||REGEXP_SUBSTR(l_cases,'[^,]+',1,n)||',')=0 THEN
      RAISE_APPLICATION_ERROR(-20907,'Case not approved');
    END IF;
  END LOOP;
END;
/
