from pathlib import Path
import re,html,json,hashlib,zipfile
R=Path(__file__).resolve().parents[2]; O=R/'output/PM-001_20261102_002'; S=R/'output/PM-001_20261029'
PREFIX='20261102__PLSQL__TETOOLS_ADMIN_OBJECTS__'
def save(n,s): (O/(PREFIX+n+'_002.sql')).write_text(s.strip()+'\n',encoding='utf-8')
save('01_install',r"""
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
create table ao2_sample (id number(19,0) not null, message varchar2(40 char),
 amount number, ratio float(20), bytes raw(8));
create table ao2_equal (id number(19,0) not null, message varchar2(40 char),
 amount number, ratio float(20), bytes raw(8));
""")
props=[('TABLE',1,'TABLESPACE_NAME','USER_TABLES.TABLESPACE_NAME','STRING','EXACT_1','always; dictionary NULL allowed'),('TABLE',2,'PARTITIONED','USER_TABLES.PARTITIONED','ENUM','EXACT_1','always YES/NO')]
for i,(n,t,rule,app) in enumerate([('COLUMN_NAME','STRING','EXACT_1','always'),('COLUMN_ID','INTEGER','INT_1','always'),('DATA_TYPE','STRING','EXACT_1','supported type only'),('DATA_PRECISION','INTEGER','INT_1','NUMBER/FLOAT; else A'),('DATA_SCALE','INTEGER','INT_1','NUMBER/FLOAT; else A'),('CHAR_LENGTH','INTEGER','INT_1','CHAR/VARCHAR2; else A'),('CHAR_USED','ENUM','EXACT_1','CHAR/VARCHAR2; else A'),('DATA_LENGTH','INTEGER','INT_1','RAW or CHAR/VARCHAR2 BYTE; else A'),('NULLABLE','ENUM','EXACT_1','always Y/N')],1):props.append(('COLUMN',i,n,'USER_TAB_COLS.'+n,t,rule,app))
p=O/(PREFIX+'01_install_002.sql')
with p.open('a',encoding='utf-8') as f:
 for row in props:f.write('insert into ao2_property values('+','.join(str(x) if isinstance(x,int) else "'"+x.replace("'","''")+"'" for x in row)+');\n')
 f.write('commit;\n')
save('02_package',r"""
whenever sqlerror exit failure rollback
set define off
create package ao2_poc authid definer as
 -- p_name is dictionary spelling, not uppercased; no dynamic SQL.
 -- One extraction returns ALL outputs. Outputs are cleared on failure.
 procedure calculate(p_name varchar2, p_manifest out clob,
   p_inventory out clob, p_bytes out raw, p_hash out raw);
 function frame(p_value varchar2) return raw;
end;
/
create package body ao2_poc as
 function num(n number) return varchar2 is begin
  return to_char(n,'TM9','NLS_NUMERIC_CHARACTERS=''.,''');
 end;
 function frame(p_value varchar2) return raw is
  r raw(32767); b raw(32767);
 begin
  -- NULL token N; value token V + 8 ASCII hex byte-length digits + ':' + UTF8.
  -- No delimiter escaping needed: lengths delimit payloads. Oracle '' = NULL.
  if p_value is null then return hextoraw('4E'); end if;
  b:=utl_i18n.string_to_raw(p_value,'AL32UTF8');
  if utl_raw.length(b)>1900 then raise_application_error(-20002,'Field too large'); end if;
  r:=utl_i18n.string_to_raw('V'||lpad(to_char(utl_raw.length(b),'FMXXXXXXXX'),8,'0')||':','AL32UTF8');
  return utl_raw.concat(r,b);
 end;
 procedure calculate(p_name varchar2,p_manifest out clob,p_inventory out clob,
   p_bytes out raw,p_hash out raw) is
  type cols_t is table of user_tab_cols%rowtype;
  cs cols_t; t user_tables%rowtype; n number;
  buf raw(2000); m varchar2(32767); inv varchar2(32767);
  procedure token(v varchar2) is r raw(32767); begin
   r:=frame(v);
   -- 2000 bytes is intentional: SQL RAW limit with MAX_STRING_SIZE=STANDARD.
   -- Never truncate, hash chunks separately or silently promote to a LOB.
   if nvl(utl_raw.length(buf),0)+utl_raw.length(r)>2000 then
    raise_application_error(-20003,'Canonical input exceeds 2000 bytes'); end if;
   buf:=utl_raw.concat(buf,r);
  end;
  procedure rec(cat varchar2,ident varchar2,pos number,pid number,
    typ varchar2,st varchar2,v varchar2) is begin
   token('R');token(cat);token(ident);token(num(pos));token(num(pid));
   token(typ);token(st);token(v);
   m:=m||cat||'/'||ident||'/'||num(pos)||'/'||num(pid)||' '||typ||' '||st||' '||v||chr(10);
  end;
  procedure val(cat varchar2,ident varchar2,pos number,pid number,
    typ varchar2,v varchar2,applies boolean default true) is begin
   if not applies then rec(cat,ident,pos,pid,typ,'A',null);
   elsif v is null then rec(cat,ident,pos,pid,typ,'N',null);
   else rec(cat,ident,pos,pid,typ,'V',v);end if;
  end;
 begin
  p_manifest:=null;p_inventory:=null;p_bytes:=null;p_hash:=null;
  -- Metadata fixture must match the compiled, immutable rule contract.
  select count(*) into n from ao2_profile where profile_code='TABLE_CORE'
    and profile_version=1 and canonical_version='POC_TLV_1'
    and rule_contract='AO2_RULES_1' and hash_algorithm='SHA256' and status='DRAFT';
  if n<>1 then raise_application_error(-20004,'Unsupported profile contract');end if;
  -- No storage coordination, ledger writes or dynamic profile execution here.
  -- Caller must prevent concurrent DDL. Multiple reads are NOT an atomic snapshot.
  select * into t from user_tables where table_name=p_name;
  if t.temporary<>'N' or t.iot_type is not null or t.cluster_name is not null
    or t.nested<>'NO' or t.secondary<>'N' or t.external<>'NO' then
   raise_application_error(-20005,'Unsupported table shape');end if;
  select * bulk collect into cs from user_tab_cols where table_name=p_name
    order by column_id nulls last, internal_column_id;
  if cs.count=0 then raise_application_error(-20006,'No columns');end if;
  for i in 1..cs.count loop
   if cs(i).hidden_column<>'NO' or cs(i).virtual_column<>'NO'
    or cs(i).identity_column<>'NO' or cs(i).column_id is null
    or cs(i).data_type_owner is not null
    or cs(i).data_type not in ('NUMBER','FLOAT','VARCHAR2','CHAR','RAW','DATE') then
    raise_application_error(-20007,'Unsupported column');end if;
   if i>1 then
    if cs(i).column_id=cs(i-1).column_id then raise_application_error(-20008,'Duplicate position');end if;
   end if;
   if cs(i).nullable not in ('Y','N') or cs(i).nullable is null then
    raise_application_error(-20009,'Unknown nullable');end if;
   if cs(i).data_type in ('CHAR','VARCHAR2') and
     (cs(i).char_used is null or cs(i).char_used not in ('B','C')) then
    raise_application_error(-20010,'Unknown char semantics');end if;
  end loop;
  token('AO2');token('TABLE_CORE');token('1');token('POC_TLV_1');token('SHA256');
  token('AO2_RULES_1');token(num(cs.count));
  m:='TABLE_CORE/1/POC_TLV_1/SHA256/AO2_RULES_1'||chr(10);
  inv:='TABLE '||p_name||chr(10);
  -- Owner/name intentionally excluded from hash (PoC choice); root identity @.
  val('TABLE','@',1,1,'STRING',t.tablespace_name);
  if t.partitioned not in ('YES','NO') or t.partitioned is null then
   raise_application_error(-20011,'Unknown partition flag');end if;
  val('TABLE','@',1,2,'ENUM',t.partitioned);
  for i in 1..cs.count loop
   inv:=inv||'COLUMN '||cs(i).column_name||chr(10);
   val('COLUMN',cs(i).column_name,cs(i).column_id,1,'STRING',cs(i).column_name);
   val('COLUMN',cs(i).column_name,cs(i).column_id,2,'INTEGER',num(cs(i).column_id));
   val('COLUMN',cs(i).column_name,cs(i).column_id,3,'STRING',cs(i).data_type);
   val('COLUMN',cs(i).column_name,cs(i).column_id,4,'INTEGER',num(cs(i).data_precision),cs(i).data_type in ('NUMBER','FLOAT'));
   val('COLUMN',cs(i).column_name,cs(i).column_id,5,'INTEGER',num(cs(i).data_scale),cs(i).data_type in ('NUMBER','FLOAT'));
   val('COLUMN',cs(i).column_name,cs(i).column_id,6,'INTEGER',num(cs(i).char_length),cs(i).data_type in ('CHAR','VARCHAR2'));
   val('COLUMN',cs(i).column_name,cs(i).column_id,7,'ENUM',cs(i).char_used,cs(i).data_type in ('CHAR','VARCHAR2'));
   val('COLUMN',cs(i).column_name,cs(i).column_id,8,'INTEGER',num(cs(i).data_length),cs(i).data_type='RAW' or (cs(i).data_type in ('CHAR','VARCHAR2') and cs(i).char_used='B'));
   val('COLUMN',cs(i).column_name,cs(i).column_id,9,'ENUM',cs(i).nullable);
  end loop;
  token('END');
  -- SQL hash over RAW: no session character encoding conversion of hash input.
  select standard_hash(buf,'SHA256') into p_hash from dual;
  p_manifest:=m;p_inventory:=inv;p_bytes:=buf;
 exception when others then
  p_manifest:=null;p_inventory:=null;p_bytes:=null;p_hash:=null;raise;
 end;
end;
/
-- SQL*Plus SHOW ERRORS alone does not fail installation. Check USER_ERRORS.
declare n number;begin
 select count(*) into n from user_errors where name='AO2_POC';
 if n>0 then raise_application_error(-20012,'AO2_POC has compilation errors; query USER_ERRORS');end if;
end;
/
""")
# Reduce sample to fit the intentionally small RAW bound; broader datatype tests separately.
p=O/(PREFIX+'01_install_002.sql');s=p.read_text();s=s.replace('id number(19,0) not null, message varchar2(40 char),\n amount number, ratio float(20), bytes raw(8)','id number(19,0) not null');p.write_text(s,encoding='utf-8')
save('03_tests',r"""
whenever sqlerror exit failure rollback
set serveroutput on
set define off
spool ao2_test_results.log
select banner_full from v$version where banner_full like 'Oracle Database%';
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
 exception when no_data_found then ck(h is null and b is null,'Missing metadata produces no hash');end;
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
 execute immediate 'alter table ao2_types modify x clob';
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
""")
save('04_cleanup',r"""
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
""")
print('SQL generated')

