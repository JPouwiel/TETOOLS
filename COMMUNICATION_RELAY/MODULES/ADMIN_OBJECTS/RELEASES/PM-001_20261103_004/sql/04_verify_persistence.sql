-- EXECUTION ROLE: AO4_POC_<suffix> (new connection) in the target disposable Oracle 19c test PDB.
-- DBA preparation (user/default tablespace/quota/direct grants) must finish first.
-- Run in a NEW SQL*Plus/SQLcl session as the same disposable schema after 03_tests.
whenever oserror exit failure rollback
whenever sqlerror exit failure rollback
set define off
set sqlblanklines on
set serveroutput on size unlimited
spool ao4_persistence.log
declare n number;expected_ number;b blob;h raw(32);begin
 select count(*) into expected_ from user_constraints where table_name='AO4_T';
 select count(*) into n from user_indexes where table_name='AO4_T';expected_:=expected_+n+1;
 select count(*) into n from ao4_fp where release_id='FINAL004';
 if n<>expected_ then raise_application_error(-20410,'Persistent fingerprint count');end if;
 dbms_output.put_line('PASS P01_PERSISTENT_OBJECTS');
 for x in (select * from ao4_fp where release_id='FINAL004') loop
   ao4_poc.serialize_manifest(x.object_manifest,b,h);
   if h is null or x.fingerprint is null or h<>x.fingerprint then raise_application_error(-20411,'Persistent digest mismatch');end if;
   dbms_lob.freetemporary(b);
 end loop;dbms_output.put_line('PASS P02_PERSISTENT_DIGESTS');
 select count(*) into n from ao4_finding where release_id='FINAL004';
 if n<>5 then raise_application_error(-20412,'Persistent findings missing');end if;
 select count(*) into n from ao4_finding where release_id='FINAL004' and
 ((recognition_status='RECOGNIZED_ONLY' and evaluation_status='NOT_EVALUATED')
  or (recognition_status='UNKNOWN' and evaluation_status='NOT_EVALUATED')
  or (evaluation_status='UNSUPPORTED' and error_code is not null and fingerprint is null)
  or (evaluation_status='ERROR' and error_code is not null and fingerprint is null)
  or (evaluation_status='EVALUATED_WITHIN_PROFILE' and fingerprint is not null));
 if n<>5 then raise_application_error(-20413,'Persistent finding classifications');end if;
 dbms_output.put_line('PASS P03_PERSISTENT_FINDINGS');
 dbms_output.put_line('PERSISTENCE_COMPLETE PM001_004');
exception when others then
 if dbms_lob.istemporary(b)=1 then dbms_lob.freetemporary(b);end if;raise;
end;
/
spool off
