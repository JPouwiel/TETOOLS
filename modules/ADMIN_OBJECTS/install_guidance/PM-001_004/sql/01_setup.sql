-- EXECUTION ROLE: AO4_POC_<suffix> in the target disposable Oracle 19c test PDB.
-- DBA preparation (user/default tablespace/quota/direct grants) must finish first.
-- Oracle Database 19c, SQL*Plus/SQLcl; new EMPTY disposable PDB schema only.
-- DBA prerequisites are in 00_privileges. No production TETOOLS objects.
whenever sqlerror exit failure rollback
set define off
set sqlblanklines on
set serveroutput on
declare n number;begin
 if sys_context('USERENV','SESSION_USER')<>sys_context('USERENV','CURRENT_SCHEMA')
    or not regexp_like(sys_context('USERENV','SESSION_USER'),'^AO4_POC_[A-Z0-9_]+$','c')
    or to_number(sys_context('USERENV','CON_ID'))<3 then
   raise_application_error(-20300,'Use AO4_POC_<suffix> disposable local PDB user, CURRENT_SCHEMA unchanged');end if;
 select count(*) into n from user_objects;
 if n<>0 then raise_application_error(-20300,'Use a new empty disposable schema');end if;
end;
/
create table ao4_catalog(type_code varchar2(40) primary key,default_status varchar2(20)
 check(default_status='RECOGNIZED_ONLY'));
insert into ao4_catalog values('CLUSTER','RECOGNIZED_ONLY');
insert into ao4_catalog values('CONSTRAINTS','RECOGNIZED_ONLY');
insert into ao4_catalog values('CONSUMER GROUP','RECOGNIZED_ONLY');
insert into ao4_catalog values('CONTEXT','RECOGNIZED_ONLY');
insert into ao4_catalog values('CREDENTIAL','RECOGNIZED_ONLY');
insert into ao4_catalog values('DATABASE LINK','RECOGNIZED_ONLY');
insert into ao4_catalog values('DESTINATION','RECOGNIZED_ONLY');
insert into ao4_catalog values('DIRECTORY','RECOGNIZED_ONLY');
insert into ao4_catalog values('EDITION','RECOGNIZED_ONLY');
insert into ao4_catalog values('EVALUATION CONTEXT','RECOGNIZED_ONLY');
insert into ao4_catalog values('FUNCTION','RECOGNIZED_ONLY');
insert into ao4_catalog values('INDEX','RECOGNIZED_ONLY');
insert into ao4_catalog values('INDEX PARTITION','RECOGNIZED_ONLY');
insert into ao4_catalog values('INDEXTYPE','RECOGNIZED_ONLY');
insert into ao4_catalog values('JAVA CLASS','RECOGNIZED_ONLY');
insert into ao4_catalog values('JAVA DATA','RECOGNIZED_ONLY');
insert into ao4_catalog values('JAVA RESOURCE','RECOGNIZED_ONLY');
insert into ao4_catalog values('JAVA SOURCE','RECOGNIZED_ONLY');
insert into ao4_catalog values('JOB','RECOGNIZED_ONLY');
insert into ao4_catalog values('JOB CLASS','RECOGNIZED_ONLY');
insert into ao4_catalog values('LIBRARY','RECOGNIZED_ONLY');
insert into ao4_catalog values('LOB','RECOGNIZED_ONLY');
insert into ao4_catalog values('LOB PARTITION','RECOGNIZED_ONLY');
insert into ao4_catalog values('MATERIALIZED VIEW','RECOGNIZED_ONLY');
insert into ao4_catalog values('OPERATOR','RECOGNIZED_ONLY');
insert into ao4_catalog values('PACKAGE','RECOGNIZED_ONLY');
insert into ao4_catalog values('PACKAGE BODY','RECOGNIZED_ONLY');
insert into ao4_catalog values('PRIVILEGES','RECOGNIZED_ONLY');
insert into ao4_catalog values('PROCEDURE','RECOGNIZED_ONLY');
insert into ao4_catalog values('PROFILES','RECOGNIZED_ONLY');
insert into ao4_catalog values('PROGRAM','RECOGNIZED_ONLY');
insert into ao4_catalog values('QUEUE','RECOGNIZED_ONLY');
insert into ao4_catalog values('RESOURCE PLAN','RECOGNIZED_ONLY');
insert into ao4_catalog values('ROLES','RECOGNIZED_ONLY');
insert into ao4_catalog values('RULE','RECOGNIZED_ONLY');
insert into ao4_catalog values('RULE SET','RECOGNIZED_ONLY');
insert into ao4_catalog values('SCHEDULE','RECOGNIZED_ONLY');
insert into ao4_catalog values('SCHEDULER GROUP','RECOGNIZED_ONLY');
insert into ao4_catalog values('SEQUENCE','RECOGNIZED_ONLY');
insert into ao4_catalog values('SYNONYM','RECOGNIZED_ONLY');
insert into ao4_catalog values('TABLE','RECOGNIZED_ONLY');
insert into ao4_catalog values('TABLESPACES','RECOGNIZED_ONLY');
insert into ao4_catalog values('TABLE PARTITION','RECOGNIZED_ONLY');
insert into ao4_catalog values('TABLE SUBPARTITION','RECOGNIZED_ONLY');
insert into ao4_catalog values('TRIGGER','RECOGNIZED_ONLY');
insert into ao4_catalog values('TYPE','RECOGNIZED_ONLY');
insert into ao4_catalog values('TYPE BODY','RECOGNIZED_ONLY');
insert into ao4_catalog values('UNDEFINED','RECOGNIZED_ONLY');
insert into ao4_catalog values('UNIFIED AUDIT POLICY','RECOGNIZED_ONLY');
insert into ao4_catalog values('USERS','RECOGNIZED_ONLY');
insert into ao4_catalog values('VIEW','RECOGNIZED_ONLY');
insert into ao4_catalog values('WINDOW','RECOGNIZED_ONLY');
insert into ao4_catalog values('XML SCHEMA','RECOGNIZED_ONLY');
-- Registry presence never implies successful evaluation of an encountered object.
create table ao4_release(release_id varchar2(80) primary key,offered_manifest clob,
 installer varchar2(128),started_at timestamp with time zone,execution_result varchar2(30));
create table ao4_fp(release_id varchar2(80) references ao4_release,
 object_owner varchar2(128),object_name varchar2(128),object_type varchar2(40),
 profile_code varchar2(30),profile_version number,canonical_version varchar2(40),
 observed_at timestamp with time zone,con_id number,fingerprint raw(32),object_manifest clob,
 primary key(release_id,object_owner,object_name,object_type));
create table ao4_finding(finding_id number generated always as identity primary key,
 release_id varchar2(80) not null references ao4_release,
 component_type varchar2(128) not null,component_identity varchar2(128) not null,
 recognition_status varchar2(20) not null,evaluation_status varchar2(30) not null,
 severity varchar2(12) not null,reason_code varchar2(40) not null,
 recommended_action varchar2(40) not null,exception_reference varchar2(80),
 observed_at timestamp with time zone not null,source_family varchar2(3) not null,
 con_id number not null,phase varchar2(20),error_code number,error_message varchar2(4000),
 actual_object_type varchar2(128),fingerprint raw(32),
 check (evaluation_status='EVALUATED_WITHIN_PROFILE' or fingerprint is null));
-- Simple heap fixture, including a CHECK, PK and ordinary B-tree index.
create table ao4_t(id number(10,0) not null, message varchar2(40 char),amount number,
 constraint ao4_pk primary key(id),constraint ao4_ck check(amount>=0));
create index ao4_ix on ao4_t(message);
create view ao4_v as select id from ao4_t;
create table ao4_unsupported(id number default 0);
commit;
