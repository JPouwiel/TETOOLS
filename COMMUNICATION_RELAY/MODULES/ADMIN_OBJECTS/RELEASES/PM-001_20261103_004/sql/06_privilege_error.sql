-- After 04_verify_persistence, BEFORE cleanup. DBA first revokes only
-- SELECT ON SYS.CDB_TABLES from this disposable user in the target PDB.
-- Run as the disposable user in a NEW session. DBA restores that direct grant after.
-- Do not run this scenario against any shared or production schema.
whenever oserror exit failure rollback
whenever sqlerror exit failure rollback
set define off
set sqlblanklines on
set serveroutput on size unlimited
spool ao4_privilege.log
declare n number;m clob;b blob;h raw(32);begin
 insert into ao4_release values('PRIV004',to_clob('{"kind":"TEST_OBSERVATION"}'),
   sys_context('USERENV','SESSION_USER'),systimestamp,'TEST_OBSERVATION');
 ao4_poc.preflight('TABLE','AO4_T','CDB','PRIV004');
 select count(*) into n from ao4_finding where release_id='PRIV004'
   and evaluation_status='ERROR' and reason_code='EXTRACTION_ERROR'
   and error_code in (-942,-1031) and error_message is not null
   and fingerprint is null and recommended_action='BLOCK_AND_REVIEW';
 if n<>1 then raise_application_error(-20430,'Expected real CDB privilege denial; check direct/broad grants');end if;
 dbms_output.put_line('PASS D01_REAL_PRIVILEGE_ERROR');
 ao4_poc.calculate('AO4_T','DBA',m,b,h);
 if h is null then raise_application_error(-20431,'Explicit DBA route failed');end if;
 dbms_lob.freetemporary(m);dbms_lob.freetemporary(b);
 dbms_output.put_line('PASS D02_EXPLICIT_DBA_ROUTE');
 commit;dbms_output.put_line('PRIVILEGE_COMPLETE PM001_004');
exception when others then
 rollback;
 if dbms_lob.istemporary(m)=1 then dbms_lob.freetemporary(m);end if;
 if dbms_lob.istemporary(b)=1 then dbms_lob.freetemporary(b);end if;raise;
end;
/
spool off
