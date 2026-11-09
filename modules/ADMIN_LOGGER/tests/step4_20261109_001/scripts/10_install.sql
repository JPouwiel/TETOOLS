-- HIGH RISK. Only for explicitly authorized disposable schema after 00_preflight PASS.
-- Requires approved environment definitions already loaded, operator-verified empty schema.
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SET ECHO ON FEEDBACK ON SERVEROUTPUT ON
SPOOL step4_install.log
PROMPT T02 INSTALL: all original source DDL, unchanged; Oracle DDL commits implicitly.
@@../../../src/20261109_501_DEV/TABLE/TAB_TETOOLS_ADMIN_LOGGER__20261015_202.sql
@@../../../src/20261109_501_DEV/SEQUENCE/SEQ_20261007__ADMIN_LOGGER__001.sql
@@../../../src/20261109_501_DEV/PACKAGE_SPEC/PACKAGE_TETOOLS_ADMIN_LOGGER__20261015_500.pks
SHOW ERRORS PACKAGE TETOOLS.ADMIN_LOGGER
@@../../../src/20261109_501_DEV/PACKAGE_BODY/PACKAGE-BODY_TETOOLS_ADMIN_LOGGER__20261015_500.pkb
SHOW ERRORS PACKAGE BODY TETOOLS.ADMIN_LOGGER
-- Do not install optional sample procedure without separate DBA approval.
@@20_T02_compile.sql
SPOOL OFF
