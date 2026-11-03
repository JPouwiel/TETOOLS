-- Fixed allowlist only. Safe after partial setup; never drop a user or cascade a schema.
whenever oserror exit failure rollback
whenever sqlerror exit failure rollback
set define off
set sqlblanklines on
set serveroutput on
spool ao4_cleanup.log
declare
 procedure drop_(kind_ varchar2,name_ varchar2) is begin
   execute immediate 'drop '||kind_||' '||name_||case when kind_='table' then ' purge' end;
 exception when others then
   if (kind_='table' and sqlcode=-942) or (kind_='view' and sqlcode=-942)
      or (kind_='package' and sqlcode=-4043) then null;else raise;end if;
 end;
begin
 if not regexp_like(sys_context('USERENV','SESSION_USER'),'^AO4_POC_[A-Z0-9_]+$','c')
   or sys_context('USERENV','SESSION_USER')<>sys_context('USERENV','CURRENT_SCHEMA')
   or to_number(sys_context('USERENV','CON_ID'))<3 then
   raise_application_error(-20420,'Wrong disposable local PDB schema');end if;
 drop_('package','AO4_POC');drop_('view','AO4_V');
 drop_('table','AO4_FP');drop_('table','AO4_FINDING');drop_('table','AO4_RELEASE');
 -- SHAPE can retain its FK to AO4_T if an assertion fails immediately after CREATE.
 drop_('table','AO4_SHAPE');drop_('table','AO4_CATALOG');drop_('table','AO4_T');
 drop_('table','AO4_UNSUPPORTED');drop_('table','AO4_TYPES');drop_('table','AO4_LONG');
end;
/
declare n number;begin
 select count(*) into n from user_objects;
 if n<>0 then raise_application_error(-20421,'Cleanup left objects: inspect USER_OBJECTS; nothing else is dropped');end if;
 dbms_output.put_line('PASS C01_SCHEMA_EMPTY');
 dbms_output.put_line('CLEANUP_COMPLETE PM001_004');
end;
/
spool off
