whenever sqlerror exit failure rollback
set define off
create package ao2_poc authid definer as
 -- p_name is dictionary spelling, not uppercased; no dynamic SQL.
 -- One extraction returns ALL outputs. Caller must discard all outputs if this call raises.
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
  cursor col_cursor is select column_name,column_id,internal_column_id,data_type,data_type_owner,data_precision,data_scale,char_length,char_used,data_length,nullable,hidden_column,virtual_column,identity_column from user_tab_cols where table_name=p_name order by column_id nulls last,internal_column_id;
  type cols_t is table of col_cursor%rowtype;
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
    or t.nested<>'NO' or t.secondary<>'N' then
   raise_application_error(-20005,'Unsupported table shape');end if;
  select count(*) into n from user_external_tables where table_name=p_name;
  if n>0 then raise_application_error(-20005,'External table unsupported');end if;
  open col_cursor;fetch col_cursor bulk collect into cs;close col_cursor;
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
