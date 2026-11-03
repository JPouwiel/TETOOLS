-- Run once after 01_setup.sql and 02_package.sql, in the same disposable PDB schema.
whenever oserror exit failure rollback
whenever sqlerror exit failure rollback
set define off
set sqlblanklines on
set echo off
set serveroutput on size unlimited
set linesize 32767
set trimspool on
set feedback on
spool ao4_tests.log
select product,version_full from product_component_version;
select sys_context('USERENV','SESSION_USER') schema_name,
       sys_context('USERENV','CON_NAME') con_name,
       sys_context('USERENV','CON_ID') con_id from dual;
select owner,table_name,privilege from user_tab_privs_recd where owner='SYS' order by table_name,privilege;
@@03_reference_vector.sql
-- DDL fixture creation precedes all rollback assertions (DDL commits implicitly).
create table ao4_types(n number,f float(30),c char(3 byte),vc varchar2(4 char),
 nc nchar(3),nv nvarchar2(4),r raw(8),dt date,sc number(9,-2),
 constraint ao4_uq unique(c,r));
create table ao4_long(id number);
declare s varchar2(32767):='alter table ao4_long add constraint ao4_long_ck check (';begin
 for i in 1..450 loop s:=s||'id >= 0 and ';end loop;
 execute immediate s||'id >= 0)';
end;
/
declare
 m clob;m2 clob;b blob;b2 blob;h raw(32);h2 raw(32);base_ raw(32);tmp_ raw(32767);
 data_ ao4_poc.metadata_t;bad_ ao4_poc.metadata_t;
 n number;expected_ number;seen_ number;err_ number;old_nls varchar2(100);saved_sort varchar2(100);
 root_ json_object_t;rs_ json_array_t;r_ json_object_t;fs_ json_array_t;f_ json_object_t;
 children_ number;long_len_ number;found_ boolean;child_ json_object_t;one_ json_array_t;
 identity_ varchar2(128);kind_ varchar2(40);
 procedure ck(ok boolean,id_ varchar2) is begin
   if ok is null or not ok then raise_application_error(-20400,'FAIL '||id_);end if;
   dbms_output.put_line('PASS '||id_);
 end;
 procedure free_ is begin
   if dbms_lob.istemporary(m)=1 then dbms_lob.freetemporary(m);end if;
   if dbms_lob.istemporary(m2)=1 then dbms_lob.freetemporary(m2);end if;
   if dbms_lob.istemporary(b)=1 then dbms_lob.freetemporary(b);end if;
   if dbms_lob.istemporary(b2)=1 then dbms_lob.freetemporary(b2);end if;
 end;
 procedure calc(tab_ varchar2 default 'AO4_T',src_ varchar2 default 'CDB') is begin
   free_;ao4_poc.calculate(tab_,src_,m,b,h);
 end;
 procedure emit(id_ varchar2,doc_ clob,wire_ blob) is begin
   dbms_output.put_line('EVIDENCE_BEGIN '||id_);dbms_output.put_line('JSON_BEGIN');
   -- Small character chunks also fit DBMS_OUTPUT's byte limit on multibyte databases.
   for i in 0..trunc((dbms_lob.getlength(doc_)-1)/1000) loop
     dbms_output.put_line(dbms_lob.substr(doc_,1000,1+i*1000));end loop;
   dbms_output.put_line('JSON_END');dbms_output.put_line('HEX_BEGIN');
   for i in 0..trunc((dbms_lob.getlength(wire_)-1)/8000) loop
     dbms_output.put_line(rawtohex(dbms_lob.substr(wire_,8000,1+i*8000)));end loop;
   dbms_output.put_line('HEX_END');dbms_output.put_line('EVIDENCE_END');
 end;
 procedure release_(id_ varchar2) is begin
   insert into ao4_release values(id_,to_clob('{"kind":"TEST_OBSERVATION"}'),
     sys_context('USERENV','SESSION_USER'),systimestamp,'TEST_OBSERVATION');
 end;
 procedure expect_store_error(id_ varchar2,release_id_ varchar2,code_ number) is begin
   err_:=0;begin ao4_poc.store_observations('AO4_T','CDB',release_id_);
     exception when others then err_:=sqlcode;end;ck(err_=code_,id_);
 end;
 procedure reject_shape(id_ varchar2) is begin
   free_;err_:=0;begin ao4_poc.calculate('AO4_SHAPE','CDB',m,b,h);
     exception when others then err_:=sqlcode;end;ck(err_=-20310,id_);
 end;
 function val_(column_ varchar2,property_ varchar2) return varchar2 is begin
   for i in 0..rs_.get_size-1 loop
     r_:=treat(rs_.get(i) as json_object_t);
     if r_.get_string('component')='COLUMN' and r_.get_string('source_identity')=column_ then
       fs_:=r_.get_array('fields');for j in 0..fs_.get_size-1 loop
         f_:=treat(fs_.get(j) as json_object_t);
         if f_.get_string('property')=property_ then return f_.get_string('value');end if;
       end loop;
     end if;
   end loop;return null;
 end;
 procedure finding_(identity_ varchar2,recognition_ varchar2,evaluation_ varchar2,reason_ varchar2,id_ varchar2) is begin
   select count(*) into n from ao4_finding where release_id='PF004'
     and component_identity=identity_ and recognition_status=recognition_
     and evaluation_status=evaluation_ and reason_code=reason_
     and source_family='CDB' and con_id=to_number(sys_context('USERENV','CON_ID'))
     and observed_at is not null and recommended_action is not null
     and (evaluation_status='EVALUATED_WITHIN_PROFILE' or fingerprint is null);
   ck(n=1,id_);
 end;
begin
 select count(*) into n from user_errors where name='AO4_POC';ck(n=0,'T01_COMPILE_ERRORS');
 select count(*) into n from user_objects where object_name='AO4_POC' and status='VALID';ck(n=2,'T02_VALID_SPEC_BODY');
 select count(*) into n from ao4_catalog;ck(n=53,'T03_CATALOG_53');
 ck(ao4_poc.recognition('UNDEFINED')='RECOGNIZED_ONLY' and ao4_poc.recognition('UNMAPPED_OFFER_LABEL')='UNKNOWN','T04_RECOGNITION');
 ck(rawtohex(ao4_poc.value_frame(0,null))='0000000000','T05_NULL');
 ck(rawtohex(ao4_poc.value_frame(1,null))='0100000000','T06_NA');
 ck(rawtohex(ao4_poc.value_frame(2,unistr('\00E9')))='0200000002C3A9','T07_UTF8');
 ck(rawtohex(ao4_poc.value_frame(3,'-12'))='03000000032D3132','T08_INTEGER');
 ck(rawtohex(ao4_poc.uint32(4294967295))='FFFFFFFF','T09_U32_MAX');
 err_:=0;begin tmp_:=ao4_poc.uint32(4294967296);exception when others then err_:=sqlcode;end;ck(err_=-20301,'T10_U32_OVERFLOW');
 err_:=0;begin tmp_:=ao4_poc.value_frame(3,'01');exception when others then err_:=sqlcode;end;ck(err_=-20305,'T11_INTEGER_REJECT');
 err_:=0;begin tmp_:=ao4_poc.value_frame(2,rpad('x',8001,'x'));exception when others then err_:=sqlcode;end;ck(err_=-20306,'T12_FIELD_OVERFLOW');
 ck(ao4_poc.binary_compare(hextoraw('FE'),hextoraw('FF'))=-1 and
    ao4_poc.binary_compare(hextoraw('00'),hextoraw('0000'))=-1 and
    ao4_poc.binary_compare(hextoraw('0201'),hextoraw('0102'))=1,'T13_UNSIGNED_SORT');
 calc;base_:=h;emit('CDB_TABLE',m,b);
 ao4_poc.calculate('AO4_T','DBA',m2,b2,h2);
 ck(h=h2 and dbms_lob.compare(b,b2)=0,'T14_CDB_DBA_BYTES');emit('DBA_TABLE',m2,b2);
 calc;ck(h=base_,'T15_REPEAT');
 ao4_poc.extract_metadata('AO4_T','CDB',data_);
 ck(data_.contract_version='METADATA_V1' and data_.sets_.count=8 and data_.sets_(1).rows_.count=1,'T16_EXTRACT_INTERFACE');
 ao4_poc.normalize_metadata(data_,m2);ao4_poc.serialize_manifest(m2,b2,h2);
 ck(h2=h and dbms_lob.compare(b,b2)=0,'T17_STAGE_EQUIVALENCE');
 -- Alter a copied raw dataset only. The normalizer must consume its input, not query again.
 bad_:=data_;bad_.sets_(1).rows_(1).txt(3):='Y';err_:=0;
 free_;begin ao4_poc.normalize_metadata(bad_,m2);exception when others then err_:=sqlcode;end;
 ck(err_=-20310,'T18_PURE_NORMALIZE');
 calc;root_:=json_object_t.parse(m);root_.put('profile_version',999);m2:=root_.to_clob;err_:=0;
 begin ao4_poc.serialize_manifest(m2,b2,h2);exception when others then err_:=sqlcode;end;ck(err_=-20320,'T19_PROFILE_REJECT');
 select value into old_nls from nls_session_parameters where parameter='NLS_NUMERIC_CHARACTERS';
 select value into saved_sort from nls_session_parameters where parameter='NLS_SORT';
 execute immediate 'alter session set nls_numeric_characters='',.''';
 execute immediate 'alter session set nls_sort=''GERMAN''';
 calc;ck(h=base_,'T20_NLS_INDEPENDENT');
 execute immediate 'alter session set nls_numeric_characters='''||replace(old_nls,'''','''''')||'''';
 execute immediate 'alter session set nls_sort='''||replace(saved_sort,'''','''''')||'''';
 calc('AO4_TYPES');root_:=json_object_t.parse(m);rs_:=root_.get_array('records');
 ck(val_('F','DATA_PRECISION')='30' and val_('SC','DATA_SCALE')='-2','T21_FLOAT_NUMBER');
 ck(val_('C','DATA_LENGTH')='3' and val_('R','DATA_LENGTH')='8' and val_('VC','CHAR_LENGTH')='4','T22_LENGTH_SEMANTICS');
 ck(val_('NC','CHAR_LENGTH')='3' and val_('NV','CHAR_LENGTH')='4' and val_('DT','DATA_TYPE')='DATE','T23_NCHAR_DATE');
 emit('DATATYPES',m,b);
 calc('AO4_LONG');ao4_poc.extract_metadata('AO4_LONG','CDB',data_);long_len_:=0;
 for i in 1..data_.sets_(8).rows_.count loop
   if data_.sets_(8).rows_(i).txt(1)='AO4_LONG_CK' then long_len_:=length(data_.sets_(8).rows_(i).txt(2));end if;
 end loop;ck(long_len_>4000 and long_len_<8000,'T24_COMPLETE_LONG');emit('LONG_CHECK',m,b);
 execute immediate 'alter table ao4_t disable constraint ao4_ck';calc;ck(h<>base_,'T25_CONSTRAINT_CHANGE');
 execute immediate 'alter table ao4_t enable validate constraint ao4_ck';calc;ck(h=base_,'T26_CONSTRAINT_RESTORE');
 execute immediate 'alter index ao4_ix invisible';calc;ck(h<>base_,'T27_INDEX_CHANGE');
 execute immediate 'alter index ao4_ix visible';
 execute immediate 'alter table ao4_t modify id number(11,0)';calc;ck(h<>base_,'T28_PRECISION_CHANGE');
 execute immediate 'alter table ao4_t modify id number(10,0)';calc;ck(h=base_,'T29_PRECISION_RESTORE');
 free_;err_:=0;begin ao4_poc.calculate('AO4_T','AUTO',m,b,h);exception when others then err_:=sqlcode;end;
 ck(err_=-20313,'T51_INVALID_SOURCE');
 ck(utl_raw.length(ao4_poc.value_frame(2,rpad('x',8000,'x')))=8005,'T52_FIELD_BOUNDARY');
 err_:=0;begin tmp_:=ao4_poc.value_frame(0,'x');exception when others then err_:=sqlcode;end;ck(err_=-20303,'T53_NULL_PAYLOAD');
 err_:=0;begin tmp_:=ao4_poc.value_frame(2,null);exception when others then err_:=sqlcode;end;ck(err_=-20304,'T54_EMPTY_TEXT');
 -- Direct serializer tests need no database metadata, and create no preflight findings.
 root_:=json_object_t();root_.put('profile_code','TABLE_CORE');root_.put('profile_version',2);
 root_.put('canonical_version','CAN-001-DRAFT-1');r_:=json_object_t();r_.put('component','TABLE');
 fs_:=json_array_t();f_:=json_object_t();f_.put('id',1);f_.put('tag',2);f_.put('value',rpad('x',8000,'x'));fs_.append(f_);
 f_.put('id',2);fs_.append(f_);r_.put('fields',fs_);rs_:=json_array_t();rs_.append(r_);root_.put('records',rs_);
 m:=root_.to_clob;err_:=0;begin ao4_poc.serialize_manifest(m,b,h);exception when others then err_:=sqlcode;end;
 ck(err_=-20320,'T55_RECORD_BOUND');free_;
 fs_:=json_array_t();f_.put('id',1);fs_.append(f_);r_.put('fields',fs_);rs_:=json_array_t();
 for i in 1..1001 loop rs_.append(r_);end loop;root_.put('records',rs_);m:=root_.to_clob;err_:=0;
 begin ao4_poc.serialize_manifest(m,b,h);exception when others then err_:=sqlcode;end;ck(err_=-20320,'T56_RECORD_COUNT_BOUND');free_;
 rs_:=json_array_t();for i in 1..130 loop rs_.append(r_);end loop;root_.put('records',rs_);m:=root_.to_clob;err_:=0;
 begin ao4_poc.serialize_manifest(m,b,h);exception when others then err_:=sqlcode;end;ck(err_=-20320,'T57_DOCUMENT_BOUND');free_;
 execute immediate 'create table ao4_shape(id number references ao4_t(id))';reject_shape('T58_FK_REJECT');
 execute immediate 'drop table ao4_shape purge';
 execute immediate 'create table ao4_shape(id number, v number generated always as (id+1) virtual)';reject_shape('T59_VIRTUAL_REJECT');
 execute immediate 'drop table ao4_shape purge';
 execute immediate 'create table ao4_shape(id number primary key) organization index';reject_shape('T60_IOT_REJECT');
 execute immediate 'drop table ao4_shape purge';
 execute immediate 'create table ao4_shape(id number) partition by range(id)(partition p0 values less than (maxvalue))';reject_shape('T61_PARTITION_REJECT');
 execute immediate 'drop table ao4_shape purge';
 execute immediate 'create table ao4_shape(id number)';execute immediate 'create index ao4_shape_ix on ao4_shape(abs(id))';reject_shape('T62_FBI_REJECT');
 execute immediate 'drop table ao4_shape purge';
 -- All DDL complete. From here savepoint/rollback assertions have no implicit commits.
 release_('STORE004');savepoint caller_before_store;
 ao4_poc.store_observations('AO4_T','CDB','STORE004');
 select count(*) into expected_ from user_constraints where table_name='AO4_T';
 select count(*) into n from user_indexes where table_name='AO4_T';expected_:=expected_+n+1;
 select count(*) into n from ao4_fp where release_id='STORE004';ck(n=expected_,'T30_STORAGE_COUNT');
 seen_:=0;
 for x in (select * from ao4_fp where release_id='STORE004' order by object_type,object_name) loop
   free_;ao4_poc.serialize_manifest(x.object_manifest,b,h);root_:=json_object_t.parse(x.object_manifest);
   ck(h=x.fingerprint and rawtohex(h)=root_.get_string('sha256'),'ROW_HASH_'||x.object_type||'_'||x.object_name);
   ck(x.con_id=to_number(sys_context('USERENV','CON_ID')) and x.object_owner=sys_context('USERENV','SESSION_USER')
     and x.canonical_version='CAN-001-DRAFT-1' and x.observed_at is not null,'ROW_META_'||x.object_type||'_'||x.object_name);
   emit('STORED_'||x.object_type||'_'||x.object_name,x.object_manifest,b);seen_:=seen_+1;
 end loop;ck(seen_=expected_,'T31_ALL_CHILD_HASHES');
 -- Compare each child with the corresponding record in the fresh table manifest.
 calc;root_:=json_object_t.parse(m);rs_:=root_.get_array('records');children_:=0;
 for i in 0..rs_.get_size-1 loop
   r_:=treat(rs_.get(i) as json_object_t);
   if r_.get_string('component') in ('CONSTRAINTS','INDEX') then
     child_:=json_object_t();one_:=json_array_t();one_.append(r_);
     if r_.get_string('component')='INDEX' then child_.put('profile_code','INDEX_CORE');else child_.put('profile_code','CONSTRAINT_CORE');end if;
     child_.put('profile_version',1);child_.put('canonical_version','CAN-001-DRAFT-1');child_.put('records',one_);
     if dbms_lob.istemporary(m2)=1 then dbms_lob.freetemporary(m2);end if;
     if dbms_lob.istemporary(b2)=1 then dbms_lob.freetemporary(b2);end if;
     m2:=child_.to_clob;ao4_poc.serialize_manifest(m2,b2,h2);
     identity_:=r_.get_string('source_identity');kind_:=r_.get_string('component');
     select count(*) into n from ao4_fp where release_id='STORE004'
       and object_name=identity_ and object_type=kind_ and fingerprint=h2;
     if n<>1 then raise_application_error(-20401,'Child digest/key mismatch');end if;children_:=children_+1;
   end if;
 end loop;ck(children_=expected_-1,'T32_CHILD_SOURCE_MATCH');
 expect_store_error('T33_DUPLICATE','STORE004',-1);
 select count(*) into n from ao4_fp where release_id='STORE004';ck(n=expected_,'T34_DUPLICATE_PRESERVES');
 rollback to caller_before_store;
 select count(*) into n from ao4_fp where release_id='STORE004';ck(n=0,'T35_CALLER_ROLLBACK');
 select count(*) into n from ao4_release where release_id='STORE004';ck(n=1,'T36_CALLER_WORK_PRESERVED');
 expect_store_error('T37_MISSING_RELEASE','MISSING004',-2291);
 -- Seed an actual child collision: TABLE insert succeeds before a child fails.
 release_('PARTIAL004');
 insert into ao4_fp values('PARTIAL004',sys_context('USERENV','SESSION_USER'),'AO4_IX','INDEX',
   'INDEX_CORE',1,'CAN-001-DRAFT-1',systimestamp,to_number(sys_context('USERENV','CON_ID')),hextoraw('00'),null);
 expect_store_error('T38_PARTIAL_FAILURE','PARTIAL004',-1);
 select count(*) into n from ao4_fp where release_id='PARTIAL004';ck(n=1,'T39_PARTIAL_ATOMIC');
 select count(*) into n from ao4_fp where release_id='PARTIAL004' and object_name='AO4_IX' and fingerprint=hextoraw('00');ck(n=1,'T40_SEED_UNCHANGED');
 rollback;
 release_('PF004');
 ao4_poc.preflight('VIEW','AO4_V','CDB','PF004');
 -- An actual offer with an unrecognized label references a real local view.
 ao4_poc.preflight('UNMAPPED_OFFER_LABEL','AO4_V','CDB','PF004');
 ao4_poc.preflight('TABLE','AO4_UNSUPPORTED','CDB','PF004');
 ao4_poc.preflight('TABLE','AO4_ABSENT','CDB','PF004');
 ao4_poc.preflight('TABLE','AO4_T','CDB','PF004');
 ao4_poc.preflight('INDEX','AO4_IX','CDB','PF004');
 ao4_poc.preflight('CONSTRAINTS','AO4_CK','CDB','PF004');
 finding_('AO4_V','RECOGNIZED_ONLY','NOT_EVALUATED','NO_EVALUATION_RULE','T41_REAL_RECOGNIZED');
 finding_('AO4_V','UNKNOWN','NOT_EVALUATED','NO_RECOGNITION_RULE','T42_REAL_UNKNOWN_OFFER');
 finding_('AO4_UNSUPPORTED','RECOGNIZED','UNSUPPORTED','UNSUPPORTED_SHAPE','T43_REAL_UNSUPPORTED');
 finding_('AO4_ABSENT','RECOGNIZED','ERROR','EXTRACTION_ERROR','T44_REAL_EXTRACTION_ERROR');
 finding_('AO4_T','RECOGNIZED','EVALUATED_WITHIN_PROFILE','BOUNDED_PROFILE','T45_REAL_EVALUATED');
 select count(*) into n from ao4_finding where release_id='PF004' and component_type in ('INDEX','CONSTRAINTS')
   and evaluation_status='EVALUATED_WITHIN_PROFILE' and fingerprint is not null;ck(n=2,'T46_CHILD_PREFLIGHT');
 select count(*) into n from ao4_finding where release_id='PF004' and component_identity in ('AO4_UNSUPPORTED','AO4_ABSENT')
   and error_code is not null and error_message is not null and fingerprint is null and recommended_action='BLOCK_AND_REVIEW';
 ck(n=2,'T47_FAILURE_DIAGNOSTICS');
 select count(*) into n from ao4_fp where release_id='PF004';ck(n=0,'T48_PREFLIGHT_NO_BASELINE');
 rollback;
 select count(*) into n from ao4_finding where release_id='PF004';ck(n=0,'T49_FINDING_ROLLBACK');
 -- Preserve real committed findings and object observations for a fresh-session assertion.
 release_('FINAL004');ao4_poc.store_observations('AO4_T','CDB','FINAL004');
 ao4_poc.preflight('VIEW','AO4_V','CDB','FINAL004');
 ao4_poc.preflight('UNMAPPED_OFFER_LABEL','AO4_V','CDB','FINAL004');
 ao4_poc.preflight('TABLE','AO4_UNSUPPORTED','CDB','FINAL004');
 ao4_poc.preflight('TABLE','AO4_ABSENT','CDB','FINAL004');
 ao4_poc.preflight('TABLE','AO4_T','CDB','FINAL004');
 select count(*) into n from ao4_finding where release_id='FINAL004';ck(n=5,'T50_FINAL_FINDINGS');
 commit;free_;dbms_output.put_line('SUITE_COMPLETE PM001_004');
exception when others then
 rollback;free_;
 if old_nls is not null then execute immediate 'alter session set nls_numeric_characters='''||replace(old_nls,'''','''''')||'''';end if;
 if saved_sort is not null then execute immediate 'alter session set nls_sort='''||replace(saved_sort,'''','''''')||'''';end if;
 raise;
end;
/
select release_id,component_type,component_identity,recognition_status,evaluation_status,
 reason_code,error_code,recommended_action from ao4_finding order by finding_id;
spool off
