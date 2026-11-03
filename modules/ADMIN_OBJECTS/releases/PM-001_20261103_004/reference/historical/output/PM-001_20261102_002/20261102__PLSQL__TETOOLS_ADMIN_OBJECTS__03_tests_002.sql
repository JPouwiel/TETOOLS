whenever sqlerror exit failure rollback
set serveroutput on
set define off
spool ao2_test_results.log
select product,version_full from product_component_version;
select object_name,status from user_objects where object_name='AO2_POC';
select line,position,text from user_errors order by sequence;
declare
 m clob;v clob;b raw(2000);h raw(32);b0 raw(2000);h0 raw(32);
 procedure ck(ok boolean,msg varchar2) is begin
  if ok is null or not ok then raise_application_error(-20100,msg);end if;
  dbms_output.put_line('PASS '||msg);
 end;
begin
 ao2_poc.calculate('AO2_SAMPLE',m,v,b,h);b0:=b;h0:=h;
 dbms_output.put_line(dbms_lob.substr(m,32767,1));
 dbms_output.put_line(dbms_lob.substr(v,32767,1));
 dbms_output.put_line('BYTES='||rawtohex(b));dbms_output.put_line('SHA256='||rawtohex(h));
 ao2_poc.calculate('AO2_EQUAL',m,v,b,h);
 ck(b=b0 and h=h0,'Equal selected metadata despite root name');
 execute immediate 'alter session set nls_numeric_characters='',.''';
 ao2_poc.calculate('AO2_SAMPLE',m,v,b,h);
 ck(b=b0 and h=h0,'NLS independence');
 ck(rawtohex(ao2_poc.frame(null))='4E','Explicit NULL token');
 ck(rawtohex(ao2_poc.frame('A'))='5630303030303030313A41','Known frame vector');
 execute immediate 'alter table ao2_equal modify id number(18,0)';
 ao2_poc.calculate('AO2_EQUAL',m,v,b,h);ck(h<>h0,'Selected precision changes hash');
 begin
  ao2_poc.calculate('AO2_MISSING',m,v,b,h);
  raise_application_error(-20101,'Expected missing-object failure');
 exception when no_data_found then dbms_output.put_line('PASS missing metadata raises; caller discards outputs');end;
end;
/
-- Separate fixtures avoid widening the first object beyond the RAW budget.
create table ao2_types (x number);
declare
 m clob;v clob;b raw(2000);h raw(32);h0 raw(32);
 procedure run_type(ddl varchar2) is begin
  execute immediate ddl;ao2_poc.calculate('AO2_TYPES',m,v,b,h);
  dbms_output.put_line(ddl||chr(10)||dbms_lob.substr(m,32767,1));
 end;
begin
 run_type('alter table ao2_types modify x number');
 run_type('alter table ao2_types modify x number(12,2)');
 run_type('alter table ao2_types modify x float');
 run_type('alter table ao2_types modify x float(20)');
 run_type('alter table ao2_types modify x varchar2(10 byte)');
 run_type('alter table ao2_types modify x varchar2(10 char)');
 run_type('alter table ao2_types modify x raw(8)');
 run_type('alter table ao2_types modify x date');
 -- Component addition changes bytes, or hard-fails at the documented bound.
 execute immediate 'alter table ao2_types add (y number,z number)';
 begin
  ao2_poc.calculate('AO2_TYPES',m,v,b,h);
  raise_application_error(-20102,'Expected byte limit failure');
 exception when others then if sqlcode<>-20003 then raise;end if;
  dbms_output.put_line('PASS hard overflow failure');end;
 execute immediate 'alter table ao2_types drop (y,z)';
 execute immediate 'alter table ao2_types drop column x';
 execute immediate 'alter table ao2_types add x clob';
 begin
  ao2_poc.calculate('AO2_TYPES',m,v,b,h);
  raise_application_error(-20103,'Expected unsupported datatype failure');
 exception when others then if sqlcode<>-20007 then raise;end if;
  dbms_output.put_line('PASS unsupported datatype failure');end;
end;
/
spool off
-- Supplementary manual acceptance (not claimed executed): concurrent DDL,
-- partitioned heap/null tablespace, quoted Unicode names, invisible/virtual/
-- identity/hidden columns, profile contract tampering, duplicate fixture keys.
