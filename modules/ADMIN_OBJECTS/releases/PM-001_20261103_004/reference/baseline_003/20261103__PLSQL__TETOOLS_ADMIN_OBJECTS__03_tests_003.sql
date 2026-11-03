-- Run once after setup/package in the disposable schema. Source preference CDB.
whenever sqlerror exit failure rollback
set define off
set serveroutput on size unlimited
set linesize 32767
set trimspool on
spool ao3_test_results.log
select product,version_full from product_component_version;
declare
 m clob;b blob;h raw(32);m2 clob;b2 blob;h2 raw(32);base_hash raw(32);
 original_nls varchar2(100);ctx json_object_t;
 procedure ck(ok boolean,msg varchar2) is begin
  if ok is null or not ok then raise_application_error(-20400,msg);end if;
  dbms_output.put_line('PASS '||msg);
 end;
 procedure free_lobs is begin
  if dbms_lob.istemporary(m)=1 then dbms_lob.freetemporary(m);end if;
  if dbms_lob.istemporary(b)=1 then dbms_lob.freetemporary(b);end if;
  if dbms_lob.istemporary(m2)=1 then dbms_lob.freetemporary(m2);end if;
  if dbms_lob.istemporary(b2)=1 then dbms_lob.freetemporary(b2);end if;
 end;
 procedure calc is begin free_lobs;ao3_poc.calculate('AO3_T','CDB',m,b,h);end;
 procedure expect_reject(msg varchar2) is
  rejected boolean:=false;
 begin
  begin calc;exception when others then
   if sqlcode between -20399 and -20300 then rejected:=true;else raise;end if;
  end;ck(rejected,msg);
 end;
begin
 ck(ao3_poc.recognition('UNDEFINED')='RECOGNIZED_ONLY','UNDEFINED is a known catalog label');
 ck(ao3_poc.recognition('NEW_UNLISTED_TYPE')='UNKNOWN','Unknown label is visible');
 ck(ao3_poc.binary_compare(hextoraw('0102'),hextoraw('0201'))=-1,'Unsigned binary less-than');
 ck(ao3_poc.binary_compare(hextoraw('0201'),hextoraw('0102'))=1,'Unsigned binary greater-than');
 ck(ao3_poc.binary_compare(hextoraw('00'),hextoraw('0000'))=-1,'Prefix with zero padding is shorter');
 ck(ao3_poc.binary_compare(hextoraw('FE'),hextoraw('FF'))=-1,'Unsigned high-byte ordering');
 ck(rawtohex(ao3_poc.value_frame(0,null))='0000000000','Vector NULL');
 ck(rawtohex(ao3_poc.value_frame(1,null))='0100000000','Vector N/A');
 ck(rawtohex(ao3_poc.value_frame(2,unistr('\00E9')))='0200000002C3A9','Vector UTF-8 e-acute');
 ck(rawtohex(ao3_poc.value_frame(3,'-12'))='03000000032D3132','Vector negative integer');
 ck(rawtohex(ao3_poc.uint32(4294967295))='FFFFFFFF','uint32 upper boundary');
 declare rejected boolean:=false;begin
  begin h:=ao3_poc.uint32(4294967296);exception when others then if sqlcode=-20301 then rejected:=true;else raise;end if;end;
  ck(rejected,'uint32 rejects overflow');end;
 calc;base_hash:=h;
 dbms_output.put_line('MANIFEST_BEGIN');
 for i in 0..trunc((dbms_lob.getlength(m)-1)/4000) loop
  dbms_output.put_line(dbms_lob.substr(m,4000,1+i*4000));end loop;
 dbms_output.put_line('MANIFEST_END');
 dbms_output.put_line('CANONICAL_BEGIN');
 for i in 0..trunc((dbms_lob.getlength(b)-1)/8000) loop
  dbms_output.put_line(rawtohex(dbms_lob.substr(b,8000,1+i*8000)));end loop;
 dbms_output.put_line('CANONICAL_END');
 calc;ck(h=base_hash,'Repeated extraction is deterministic');
 select value into original_nls from nls_session_parameters where parameter='NLS_NUMERIC_CHARACTERS';
 execute immediate 'alter session set nls_numeric_characters='',.''';
 calc;ck(h=base_hash,'Numeric NLS independent');
 execute immediate 'alter session set nls_numeric_characters='''||replace(original_nls,'''','''''')||'''';
 execute immediate 'alter table ao3_t disable constraint ao3_ck';
 calc;ck(h<>base_hash,'Disabled CHECK changes fingerprint');
 execute immediate 'alter table ao3_t enable validate constraint ao3_ck';
 calc;ck(h=base_hash,'Restored CHECK restores fingerprint');
 execute immediate 'alter index ao3_ix invisible';
 calc;ck(h<>base_hash,'Index visibility changes fingerprint');
 execute immediate 'alter index ao3_ix visible';
 execute immediate 'alter table ao3_t modify id number(11,0)';
 calc;ck(h<>base_hash,'Precision changes fingerprint');
 execute immediate 'alter table ao3_t modify id number(10,0)';
 execute immediate 'alter table ao3_t modify amount default 0';
 expect_reject('Unsupported default prevents a success fingerprint');
 -- Oracle retains DEFAULT NULL metadata; remove/re-add the nullable fixture column.
 execute immediate 'alter table ao3_t drop constraint ao3_ck';
 execute immediate 'alter table ao3_t drop column amount';
 execute immediate 'alter table ao3_t add amount number';
 execute immediate 'alter table ao3_t add constraint ao3_ck check(amount>=0)';
 calc;
 -- Explicitly record one individual object observation linked to a release.
 insert into ao3_release values('POC-003',to_clob('{"release_id":"POC-003"}'),
  sys_context('USERENV','SESSION_USER'),systimestamp,'TEST_OBSERVATION');
 ao3_poc.store_observations('AO3_T','CDB','POC-003');
 insert into ao3_finding values(1,'POC-003','VIEW','ILLUSTRATIVE_VIEW',
  ao3_poc.recognition('VIEW'),'NOT_EVALUATED','INFO','NO_RULE','REVIEW',null);
 insert into ao3_finding values(2,'POC-003','NEW_UNLISTED_TYPE','ILLUSTRATIVE_UNKNOWN',
  ao3_poc.recognition('NEW_UNLISTED_TYPE'),'NOT_EVALUATED','WARNING','NO_RECOGNITION_RULE','REVIEW',null);
 commit;
 free_lobs;
 dbms_output.put_line('PASS complete bounded test sequence');
exception when others then
 free_lobs;
 if original_nls is not null then
  execute immediate 'alter session set nls_numeric_characters='''||replace(original_nls,'''','''''')||'''';end if;
 raise;
end;
/
-- Both following records are deliberately synthetic classification fixtures.
select component_type,recognition_status,evaluation_status,reason_code from ao3_finding order by finding_id;
select name,type,line,position,text from user_errors where name='AO3_POC' order by sequence;
spool off
