-- Oracle 19c; SQL*Plus/SQLcl. Use a NEW, EMPTY disposable schema.
-- DBA: CREATE SESSION, CREATE TABLE, CREATE PROCEDURE and tablespace quota.
-- No production schema access is required. No CREATE OR REPLACE is used.
whenever sqlerror exit failure rollback
set define off
set serveroutput on
-- Fail before DDL if this is not an empty schema. DDL auto-commits.
declare n number; begin
 select count(*) into n from user_objects;
 if n<>0 then raise_application_error(-20001,'Use a new empty PoC schema'); end if;
end;
/
create table ao2_profile (
 profile_code varchar2(30) primary key, profile_version number not null,
 canonical_version varchar2(30) not null, hash_algorithm varchar2(10) not null,
 rule_contract varchar2(30) not null, status varchar2(10) not null);
create table ao2_property (
 component_code varchar2(10), property_id number, property_code varchar2(30),
 source_attribute varchar2(100), value_type varchar2(10), normalizer_code varchar2(30),
 applicability varchar2(200), primary key(component_code,property_id));
-- A single-profile fixture repository, NOT the proposed generic production model.
insert into ao2_profile values('TABLE_CORE',1,'POC_TLV_1','SHA256','AO2_RULES_1','DRAFT');
create table ao2_sample (id number(19,0) not null);
create table ao2_equal (id number(19,0) not null);
insert into ao2_property values('TABLE',1,'TABLESPACE_NAME','USER_TABLES.TABLESPACE_NAME','STRING','EXACT_1','always; dictionary NULL allowed');
insert into ao2_property values('TABLE',2,'PARTITIONED','USER_TABLES.PARTITIONED','ENUM','EXACT_1','always YES/NO');
insert into ao2_property values('COLUMN',1,'COLUMN_NAME','USER_TAB_COLS.COLUMN_NAME','STRING','EXACT_1','always');
insert into ao2_property values('COLUMN',2,'COLUMN_ID','USER_TAB_COLS.COLUMN_ID','INTEGER','INT_1','always');
insert into ao2_property values('COLUMN',3,'DATA_TYPE','USER_TAB_COLS.DATA_TYPE','STRING','EXACT_1','supported type only');
insert into ao2_property values('COLUMN',4,'DATA_PRECISION','USER_TAB_COLS.DATA_PRECISION','INTEGER','INT_1','NUMBER/FLOAT; else A');
insert into ao2_property values('COLUMN',5,'DATA_SCALE','USER_TAB_COLS.DATA_SCALE','INTEGER','INT_1','NUMBER/FLOAT; else A');
insert into ao2_property values('COLUMN',6,'CHAR_LENGTH','USER_TAB_COLS.CHAR_LENGTH','INTEGER','INT_1','CHAR/VARCHAR2; else A');
insert into ao2_property values('COLUMN',7,'CHAR_USED','USER_TAB_COLS.CHAR_USED','ENUM','EXACT_1','CHAR/VARCHAR2; else A');
insert into ao2_property values('COLUMN',8,'DATA_LENGTH','USER_TAB_COLS.DATA_LENGTH','INTEGER','INT_1','RAW or CHAR/VARCHAR2 BYTE; else A');
insert into ao2_property values('COLUMN',9,'NULLABLE','USER_TAB_COLS.NULLABLE','ENUM','EXACT_1','always Y/N');
commit;
