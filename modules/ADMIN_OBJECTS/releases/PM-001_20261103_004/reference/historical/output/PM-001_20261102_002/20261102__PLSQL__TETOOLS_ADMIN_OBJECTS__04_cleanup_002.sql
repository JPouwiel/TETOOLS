-- Only in the SAME disposable PoC schema. DDL commits; no CASCADE broad cleanup.
whenever sqlerror exit failure rollback
begin
 for r in (select object_name,object_type from user_objects where object_name in
  ('AO2_POC','AO2_TYPES','AO2_SAMPLE','AO2_EQUAL','AO2_PROPERTY','AO2_PROFILE')
  and object_type in ('TABLE','PACKAGE')) loop
  if r.object_type='TABLE' then execute immediate 'drop table "'||r.object_name||'" purge';
  else execute immediate 'drop package "'||r.object_name||'"';end if;
 end loop;
end;
/
