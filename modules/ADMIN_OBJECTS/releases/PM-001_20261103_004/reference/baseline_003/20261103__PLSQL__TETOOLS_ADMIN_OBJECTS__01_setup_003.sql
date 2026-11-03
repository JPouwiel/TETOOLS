-- Oracle Database 19c, SQL*Plus/SQLcl; new EMPTY disposable PDB schema only.
-- DBA prerequisites are in 00_privileges. No production TETOOLS objects.
whenever sqlerror exit failure rollback
set define off
set serveroutput on
declare n number;begin
 select count(*) into n from user_objects;
 if n<>0 then raise_application_error(-20300,'Use a new empty disposable schema');end if;
end;
/
create table ao3_catalog(type_code varchar2(40) primary key,default_status varchar2(20)
 check(default_status='RECOGNIZED_ONLY'));
insert into ao3_catalog values('CLUSTER','RECOGNIZED_ONLY');
insert into ao3_catalog values('CONSTRAINTS','RECOGNIZED_ONLY');
insert into ao3_catalog values('CONSUMER GROUP','RECOGNIZED_ONLY');
insert into ao3_catalog values('CONTEXT','RECOGNIZED_ONLY');
insert into ao3_catalog values('CREDENTIAL','RECOGNIZED_ONLY');
insert into ao3_catalog values('DATABASE LINK','RECOGNIZED_ONLY');
insert into ao3_catalog values('DESTINATION','RECOGNIZED_ONLY');
insert into ao3_catalog values('DIRECTORY','RECOGNIZED_ONLY');
insert into ao3_catalog values('EDITION','RECOGNIZED_ONLY');
insert into ao3_catalog values('EVALUATION CONTEXT','RECOGNIZED_ONLY');
insert into ao3_catalog values('FUNCTION','RECOGNIZED_ONLY');
insert into ao3_catalog values('INDEX','RECOGNIZED_ONLY');
insert into ao3_catalog values('INDEX PARTITION','RECOGNIZED_ONLY');
insert into ao3_catalog values('INDEXTYPE','RECOGNIZED_ONLY');
insert into ao3_catalog values('JAVA CLASS','RECOGNIZED_ONLY');
insert into ao3_catalog values('JAVA DATA','RECOGNIZED_ONLY');
insert into ao3_catalog values('JAVA RESOURCE','RECOGNIZED_ONLY');
insert into ao3_catalog values('JAVA SOURCE','RECOGNIZED_ONLY');
insert into ao3_catalog values('JOB','RECOGNIZED_ONLY');
insert into ao3_catalog values('JOB CLASS','RECOGNIZED_ONLY');
insert into ao3_catalog values('LIBRARY','RECOGNIZED_ONLY');
insert into ao3_catalog values('LOB','RECOGNIZED_ONLY');
insert into ao3_catalog values('LOB PARTITION','RECOGNIZED_ONLY');
insert into ao3_catalog values('MATERIALIZED VIEW','RECOGNIZED_ONLY');
insert into ao3_catalog values('OPERATOR','RECOGNIZED_ONLY');
insert into ao3_catalog values('PACKAGE','RECOGNIZED_ONLY');
insert into ao3_catalog values('PACKAGE BODY','RECOGNIZED_ONLY');
insert into ao3_catalog values('PRIVILEGES','RECOGNIZED_ONLY');
insert into ao3_catalog values('PROCEDURE','RECOGNIZED_ONLY');
insert into ao3_catalog values('PROFILES','RECOGNIZED_ONLY');
insert into ao3_catalog values('PROGRAM','RECOGNIZED_ONLY');
insert into ao3_catalog values('QUEUE','RECOGNIZED_ONLY');
insert into ao3_catalog values('RESOURCE PLAN','RECOGNIZED_ONLY');
insert into ao3_catalog values('ROLES','RECOGNIZED_ONLY');
insert into ao3_catalog values('RULE','RECOGNIZED_ONLY');
insert into ao3_catalog values('RULE SET','RECOGNIZED_ONLY');
insert into ao3_catalog values('SCHEDULE','RECOGNIZED_ONLY');
insert into ao3_catalog values('SCHEDULER GROUP','RECOGNIZED_ONLY');
insert into ao3_catalog values('SEQUENCE','RECOGNIZED_ONLY');
insert into ao3_catalog values('SYNONYM','RECOGNIZED_ONLY');
insert into ao3_catalog values('TABLE','RECOGNIZED_ONLY');
insert into ao3_catalog values('TABLESPACES','RECOGNIZED_ONLY');
insert into ao3_catalog values('TABLE PARTITION','RECOGNIZED_ONLY');
insert into ao3_catalog values('TABLE SUBPARTITION','RECOGNIZED_ONLY');
insert into ao3_catalog values('TRIGGER','RECOGNIZED_ONLY');
insert into ao3_catalog values('TYPE','RECOGNIZED_ONLY');
insert into ao3_catalog values('TYPE BODY','RECOGNIZED_ONLY');
insert into ao3_catalog values('UNDEFINED','RECOGNIZED_ONLY');
insert into ao3_catalog values('UNIFIED AUDIT POLICY','RECOGNIZED_ONLY');
insert into ao3_catalog values('USERS','RECOGNIZED_ONLY');
insert into ao3_catalog values('VIEW','RECOGNIZED_ONLY');
insert into ao3_catalog values('WINDOW','RECOGNIZED_ONLY');
insert into ao3_catalog values('XML SCHEMA','RECOGNIZED_ONLY');
-- Registry presence never implies successful evaluation of an encountered object.
create table ao3_release(release_id varchar2(80) primary key,offered_manifest clob,
 installer varchar2(128),started_at timestamp with time zone,execution_result varchar2(30));
create table ao3_fp(release_id varchar2(80) references ao3_release,
 object_owner varchar2(128),object_name varchar2(128),object_type varchar2(40),
 profile_code varchar2(30),profile_version number,canonical_version varchar2(40),
 observed_at timestamp with time zone,con_id number,fingerprint raw(32),object_manifest clob,
 primary key(release_id,object_owner,object_name,object_type));
create table ao3_finding(finding_id number primary key,release_id varchar2(80),
 component_type varchar2(40),component_identity varchar2(400),
 recognition_status varchar2(20),evaluation_status varchar2(30),severity varchar2(12),
 reason_code varchar2(40),recommended_action varchar2(40),exception_reference varchar2(80));
-- Simple heap fixture, including a CHECK, PK and ordinary B-tree index.
create table ao3_t(id number(10,0) not null, message varchar2(40 char),amount number,
 constraint ao3_pk primary key(id),constraint ao3_ck check(amount>=0));
create index ao3_ix on ao3_t(message);
commit;
