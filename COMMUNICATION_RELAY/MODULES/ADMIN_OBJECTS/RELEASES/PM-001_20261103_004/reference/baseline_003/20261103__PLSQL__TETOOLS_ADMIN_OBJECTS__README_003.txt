1. DBA reviews 00_privileges; create NEW EMPTY disposable local PDB schema and quota.
2. Exclude concurrent DDL. Use SQL*Plus/SQLcl, connected inside that target PDB.
3. Run 01_setup_003.sql, then 02_package_003.sql. Inspect USER_ERRORS/VALID status.
4. Run 03_tests_003.sql once. Keep ao3_test_results.log encoded as UTF-8.
5. Run Python 3: <downloaded verify_log_003.py> ao3_test_results.log.
   It must confirm exact Oracle bytes and SHA-256, plus complete SQL test sequence.
6. If both CDB and DBA direct view grants exist, compare fresh calculations manually
   with source CDB vs DBA; provenance may differ, canonical bytes must match.
7. Review remaining manual scenarios in chapter 34. Preserve results and Oracle RU.
8. Run 04_cleanup_003.sql as SAME schema. It drops only six named AO3 objects; DBA removes schema if desired.
   Exact objects: AO3_POC, AO3_FP, AO3_FINDING, AO3_RELEASE, AO3_CATALOG, AO3_T.
DDL commits implicitly. Failed setup/tests require diagnosis; no blind rerun.
Only use the 003 scripts as one set. Never mix AO2 code with AO3 rules or profiles.
