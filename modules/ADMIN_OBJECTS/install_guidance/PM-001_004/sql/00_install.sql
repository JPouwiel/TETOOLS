-- EXECUTION ROLE: AO4_POC_<suffix> in the target disposable Oracle 19c test PDB.
-- DBA preparation (user/default tablespace/quota/direct grants) must finish first.
-- Connect to a NEW EMPTY AO4_POC_<suffix> schema in the target PDB first.
-- DBA grants/quota are a separate reviewed action; this driver grants nothing.
whenever oserror exit failure rollback
whenever sqlerror exit failure rollback
set echo on
spool ao4_install.log
@@01_setup.sql
@@02_package.sql
prompt INSTALL_COMPLETE PM001_004
spool off
