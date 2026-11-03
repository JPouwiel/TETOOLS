-- Run as the SAME disposable schema. Fixed names only; no cascade user drop.
whenever sqlerror exit failure rollback
set define off
drop package ao3_poc;
drop table ao3_fp purge;
drop table ao3_finding purge;
drop table ao3_release purge;
drop table ao3_catalog purge;
drop table ao3_t purge;
-- AO3_PK/AO3_IX and constraints disappear with AO3_T. No production objects touched.
