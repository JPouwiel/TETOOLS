-- Configuration REQUEST only; these variables never grant execution permission.
-- G09 is NOT_GRANTED in the reviewed source, regardless of these values.
-- A future approval must supply a separately reviewed authorization artifact.
DEFINE EXECUTION_APPROVED = 'NO'
DEFINE DBA_ENV_APPROVED = 'NO'
DEFINE TARGET_SCHEMA = 'TETOOLS'
DEFINE TARGET_PRINCIPAL = 'UNVERIFIED'
DEFINE TARGET_PDB = 'UNVERIFIED'
DEFINE TARGET_CON_ID = '-1'
DEFINE TARGET_DB_UNIQUE_NAME = 'UNVERIFIED'
DEFINE TARGET_INSTANCE = 'UNVERIFIED'
DEFINE TARGET_SERVICE = 'UNVERIFIED'
DEFINE TEST_RUN_ID = 'UNVERIFIED'
DEFINE TEST_CLIENT_ID = 'UNVERIFIED'
-- Run/client IDs: 1..48 uppercase ASCII letters, digits or underscore, unique per run/client.
-- Real settings remain private. Do not put passwords here.
