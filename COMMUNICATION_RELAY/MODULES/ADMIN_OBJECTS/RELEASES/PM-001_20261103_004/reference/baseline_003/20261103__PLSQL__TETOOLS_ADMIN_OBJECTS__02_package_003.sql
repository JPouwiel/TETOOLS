-- Oracle 19c. Install only in the NEW disposable schema described by README.
whenever sqlerror exit failure rollback
set define off
create package ao3_poc authid definer as
  -- Exact dictionary spelling. Only this package owner's tables are readable.
  -- On ANY exception discard ALL OUT values. Caller frees returned temporary LOBs.
  procedure calculate(p_table varchar2, p_source varchar2,
    p_manifest out clob, p_bytes out blob, p_hash out raw);
  -- Storage coordinator: inserts TABLE + individual INDEX/CONSTRAINT observations.
  -- No commit; caller owns transaction. Release row must already exist.
  procedure store_observations(p_table varchar2,p_source varchar2,p_release varchar2);
  function uint32(p_n number) return raw;
  function value_frame(p_tag pls_integer,p_text varchar2 default null) return raw;
  function recognition(p_type varchar2) return varchar2;
  function binary_compare(p_x raw,p_y raw) return pls_integer;
end;
/
create package body ao3_poc as
  function recognition(p_type varchar2) return varchar2 is n number;
  begin
    select count(*) into n from ao3_catalog where type_code=p_type;
    if n=1 then return 'RECOGNIZED_ONLY';end if;return 'UNKNOWN';
  end;
  function binary_compare(p_x raw,p_y raw) return pls_integer is
    posn pls_integer;nx pls_integer:=nvl(utl_raw.length(p_x),0);
    ny pls_integer:=nvl(utl_raw.length(p_y),0);bx number;by_ number;
  begin
    -- UTL_RAW.COMPARE returns a mismatch POSITION, NOT a signed sort result.
    posn:=utl_raw.compare(p_x,p_y);
    if posn=0 or posn>least(nx,ny) then return sign(nx-ny);end if;
    bx:=to_number(rawtohex(utl_raw.substr(p_x,posn,1)),'XX');
    by_:=to_number(rawtohex(utl_raw.substr(p_y,posn,1)),'XX');
    return sign(bx-by_);
  end;
  function uint32(p_n number) return raw is
    n number:=p_n; h varchar2(8):=''; digits constant varchar2(16):='0123456789ABCDEF';
  begin
    if n is null or n<0 or n>4294967295 or n<>trunc(n) then
      raise_application_error(-20301,'uint32 out of range'); end if;
    -- Arithmetic deliberately avoids signed PLS_INTEGER overflow at 2^31.
    for i in 1..8 loop h:=substr(digits,mod(n,16)+1,1)||h;n:=trunc(n/16);end loop;
    return hextoraw(h);
  end;
  function value_frame(p_tag pls_integer,p_text varchar2 default null) return raw is
    b raw(32767); t raw(1);
  begin
    if p_tag is null or p_tag not in (0,1,2,3) then
      raise_application_error(-20302,'Unsupported value tag');end if;
    t:=utl_raw.substr(uint32(p_tag),4,1);
    if p_tag in (0,1) then
      if p_text is not null then raise_application_error(-20303,'NULL/N/A has payload');end if;
      return utl_raw.concat(t,uint32(0));end if;
    if p_text is null then
      -- Oracle VARCHAR2 cannot represent an empty string independently of NULL.
      raise_application_error(-20304,'Use NULL tag; empty text unsupported by PoC');end if;
    if p_tag=3 and (not regexp_like(p_text,'^(0|-[1-9][0-9]*|[1-9][0-9]*)$','c')) then
      raise_application_error(-20305,'Noncanonical integer');end if;
    b:=utl_i18n.string_to_raw(p_text,'AL32UTF8');
    if utl_raw.length(b)>8000 then raise_application_error(-20306,'Field exceeds 8000 bytes');end if;
    return utl_raw.concat(t,uint32(utl_raw.length(b)),b);
  end;
  procedure calculate(p_table varchar2,p_source varchar2,
    p_manifest out clob,p_bytes out blob,p_hash out raw) is
    type item_t is record(b raw(32767),j json_object_t);
    type items_t is table of item_t index by binary_integer;
    type strings_t is table of varchar2(32767) index by varchar2(128);
    items items_t; cc strings_t; ic strings_t; checks strings_t;
    n pls_integer:=0; body_raw raw(32767); fields json_array_t;
    v_prefix varchar2(4); v_owner varchar2(128):=sys_context('USERENV','CURRENT_USER');
    v_con number:=to_number(sys_context('USERENV','CON_ID'));
    filter_sql varchar2(200); c sys_refcursor; rowj json_object_t;
    v_name varchar2(128); v_type varchar2(128); v_s varchar2(32767);
    a varchar2(4000); b varchar2(4000); d varchar2(4000); e varchar2(4000);
    g varchar2(4000); h varchar2(4000); k varchar2(4000); z varchar2(4000);
    q1 number;q2 number;q3 number;q4 number;q5 number;
    dc integer; ignored integer; got integer; off_bytes integer; chunk varchar2(8000);
    v_long varchar2(32767); v_version varchar2(100); inst number;
    manifest json_object_t:=json_object_t(); records json_array_t:=json_array_t();
    provenance json_object_t:=json_object_t();
    procedure fail(msg varchar2) is begin raise_application_error(-20310,msg);end;
    function nt(x number) return varchar2 is begin
      return to_char(x,'TM9','NLS_NUMERIC_CHARACTERS=''.,''');end;
    function wh(p_owner_col varchar2,p_table_col varchar2) return varchar2 is begin
      return ' where '||p_owner_col||'=:own and '||p_table_col||'=:tab'||filter_sql;end;
    procedure op(sql_text varchar2) is begin
      -- All source identifiers are fixed by the CDB/DBA allowlist. Values are binds.
      if p_source='CDB' then open c for sql_text using v_owner,p_table,v_con;
      else open c for sql_text using v_owner,p_table;end if;
    end;
    procedure start_record is begin body_raw:=null;fields:=json_array_t();end;
    procedure field(fid pls_integer,label varchar2,tag pls_integer,val varchar2 default null) is
      part raw(32767); j json_object_t:=json_object_t();
    begin
      part:=utl_raw.concat(uint32(fid),value_frame(tag,val));
      if nvl(utl_raw.length(body_raw),0)+utl_raw.length(part)>15995 then fail('Record exceeds 16000 bytes');end if;
      body_raw:=utl_raw.concat(body_raw,part);
      j.put('id',fid);j.put('property',label);j.put('tag',tag);
      if val is null then j.put_null('value');else j.put('value',val);end if;
      fields.append(j);
    end;
    procedure text_field(fid pls_integer,label varchar2,val varchar2) is begin
      if val is null then field(fid,label,0);else field(fid,label,2,val);end if;end;
    procedure int_field(fid pls_integer,label varchar2,val number) is begin
      if val is null then field(fid,label,0);else field(fid,label,3,nt(val));end if;end;
    procedure finish(tag raw,kind varchar2) is begin
      n:=n+1;if n>1000 then fail('More than 1000 records');end if;
      items(n).b:=utl_raw.concat(tag,uint32(utl_raw.length(body_raw)),body_raw);
      items(n).j:=json_object_t();items(n).j.put('component',kind);items(n).j.put('fields',fields);
      -- Diagnostic identity stays outside the canonical bytes (generated names).
      items(n).j.put('source_identity',v_name);
    end;
    procedure list_add(m in out nocopy strings_t,key_name varchar2,col varchar2,dir varchar2 default null) is
      s varchar2(32767); part varchar2(32767);
    begin
      -- Ordered list grammar: uppercase HEX(value_frame(STRING,name)[,direction]).
      -- Outer field is STRING. No delimiter or locale ambiguity is introduced.
      part:=rawtohex(value_frame(2,col));
      if dir is not null then part:=part||rawtohex(value_frame(2,dir));end if;
      if m.exists(key_name) then s:=m(key_name);end if;
      if nvl(length(s),0)+length(part)>8000 then fail('Ordered column list too large');end if;
      m(key_name):=s||part;
    end;
    procedure sort_items(lo pls_integer,hi pls_integer) is
      i pls_integer:=lo;j pls_integer:=hi;p raw(32767);tmp item_t;
    begin
      p:=items(trunc((lo+hi)/2)).b;
      while i<=j loop
        while binary_compare(items(i).b,p)<0 loop i:=i+1;end loop;
        while binary_compare(items(j).b,p)>0 loop j:=j-1;end loop;
        if i<=j then tmp:=items(i);items(i):=items(j);items(j):=tmp;i:=i+1;j:=j-1;end if;
      end loop;
      if lo<j then sort_items(lo,j);end if;if i<hi then sort_items(i,hi);end if;
    end;
    procedure write_raw(r raw) is begin
      if dbms_lob.getlength(p_bytes)+utl_raw.length(r)>1000000 then fail('Canonical BLOB exceeds 1 MB');end if;
      dbms_lob.writeappend(p_bytes,utl_raw.length(r),r);
    end;
  begin
    p_hash:=null;p_manifest:=null;p_bytes:=null;
    if p_source is null or p_source not in ('CDB','DBA') then fail('Source must be CDB or DBA');end if;
    v_prefix:=p_source||'_';
    if p_source='CDB' then filter_sql:=' and con_id=:cid';end if;
    -- No cross-container LONG reads: run inside the target PDB (or local root).
    op('select iot_type,cluster_name,temporary,nested,partitioned,secondary from sys.'||v_prefix||'tables'||wh('owner','table_name'));
    fetch c into a,b,d,e,g,h;
    if c%notfound then fail('Table absent OR invisible in selected source; no fingerprint');end if;
    if a is not null or b is not null or d<>'N' or e<>'NO' or g<>'NO' or h<>'N' then fail('Only permanent nonpartitioned heap tables supported');end if;
    fetch c into a,b,d,e,g,h;if c%found then fail('Duplicate table metadata');end if;close c;
    op('select table_name from sys.'||v_prefix||'external_tables'||wh('owner','table_name'));
    fetch c into v_name;if c%found then fail('External table unsupported');end if;close c;
    v_name:=p_table;start_record;field(1,'TABLE_KIND',2,'HEAP');finish(hextoraw('10'),'TABLE');
    op('select column_name,column_id,data_type,data_precision,data_scale,char_length,char_used,data_length,nullable,hidden_column,virtual_column,identity_column,default_length,collation from sys.'||v_prefix||'tab_cols'||wh('owner','table_name'));
    loop
      fetch c into v_name,q1,v_type,q2,q3,q4,a,q5,b,d,e,g,ignored,h;exit when c%notfound;
      if d<>'NO' or e<>'NO' or g<>'NO' or q1 is null or nvl(ignored,0)>0 then fail('Hidden/invisible/virtual/identity/default column unsupported');end if;
      if v_type not in ('NUMBER','FLOAT','CHAR','VARCHAR2','NCHAR','NVARCHAR2','RAW','DATE') then fail('Unsupported datatype: '||v_type);end if;
      start_record;field(1,'COLUMN_NAME',2,v_name);int_field(2,'COLUMN_ID',q1);field(3,'DATA_TYPE',2,v_type);
      if v_type in ('NUMBER','FLOAT') then int_field(4,'DATA_PRECISION',q2);int_field(5,'DATA_SCALE',q3);
      else field(4,'DATA_PRECISION',1);field(5,'DATA_SCALE',1);end if;
      if v_type in ('CHAR','VARCHAR2','NCHAR','NVARCHAR2') then int_field(6,'CHAR_LENGTH',q4);text_field(7,'CHAR_USED',a);
      else field(6,'CHAR_LENGTH',1);field(7,'CHAR_USED',1);end if;
      -- Draft rule only. Historical rationale for omission remains unproven.
      if v_type='RAW' or (v_type in ('CHAR','VARCHAR2') and a='B') then int_field(8,'DATA_LENGTH',q5);
      else field(8,'DATA_LENGTH',1);end if;
      field(9,'NULLABLE',2,b);text_field(10,'COLLATION',h);finish(hextoraw('11'),'COLUMN');
    end loop;close c;
    if n=1 then fail('No visible column metadata');end if;
    op('select constraint_name,column_name,position from sys.'||v_prefix||'cons_columns'||wh('owner','table_name')||' order by nlssort(constraint_name,''NLS_SORT=BINARY''),position nulls last,nlssort(column_name,''NLS_SORT=BINARY'')');
    loop fetch c into v_name,a,q1;exit when c%notfound;list_add(cc,v_name,a);end loop;close c;
    -- Read complete CHECK LONG values once per table; never use truncating *_VC.
    dc:=dbms_sql.open_cursor;
    dbms_sql.parse(dc,'select constraint_name,search_condition from sys.'||v_prefix||'constraints'||wh('owner','table_name')||' and constraint_type=''C''',dbms_sql.native);
    dbms_sql.bind_variable(dc,':own',v_owner);dbms_sql.bind_variable(dc,':tab',p_table);
    if p_source='CDB' then dbms_sql.bind_variable(dc,':cid',v_con);end if;
    dbms_sql.define_column(dc,1,v_name,128);dbms_sql.define_column_long(dc,2);ignored:=dbms_sql.execute(dc);
    while dbms_sql.fetch_rows(dc)>0 loop
      dbms_sql.column_value(dc,1,v_name);v_long:=null;off_bytes:=0;
      loop
        dbms_sql.column_value_long(dc,2,8000,off_bytes,chunk,got);exit when got=0;
        if nvl(lengthb(v_long),0)+lengthb(chunk)>8000 then fail('CHECK text exceeds PoC buffer');end if;
        v_long:=v_long||chunk;off_bytes:=off_bytes+got;
      end loop;
      if v_long is null then fail('Missing CHECK expression');end if;checks(v_name):=v_long;
    end loop;dbms_sql.close_cursor(dc);dc:=null;
    op('select constraint_name,constraint_type,generated,status,deferrable,deferred,validated,rely from sys.'||v_prefix||'constraints'||wh('owner','table_name'));
    loop fetch c into v_name,a,b,d,e,g,h,k;exit when c%notfound;
      if a not in ('P','U','C') then fail('Constraint type unsupported in this PoC: '||a);end if;
      start_record;
      if b='GENERATED NAME' then field(1,'CONSTRAINT_NAME',1);else field(1,'CONSTRAINT_NAME',2,v_name);end if;
      field(2,'CONSTRAINT_TYPE',2,a);field(3,'STATUS',2,d);field(4,'DEFERRABLE',2,e);field(5,'DEFERRED',2,g);field(6,'VALIDATED',2,h);
      -- RELY is not meaningful for validated constraints.
      if h='NOT VALIDATED' then text_field(7,'RELY',k);else field(7,'RELY',1);end if;
      if not cc.exists(v_name) then fail('Missing constraint columns');end if;
      field(8,'ORDERED_COLUMNS_HEX',2,cc(v_name));
      if a='C' then if not checks.exists(v_name) then fail('Missing CHECK text');end if;field(9,'CHECK_TEXT',2,checks(v_name));
      else field(9,'CHECK_TEXT',1);end if;
      finish(hextoraw('12'),'CONSTRAINTS');
    end loop;close c;
    op('select index_name,column_name,column_position,descend,index_owner from sys.'||v_prefix||'ind_columns'||wh('table_owner','table_name')||' order by nlssort(index_name,''NLS_SORT=BINARY''),column_position');
    loop fetch c into v_name,a,q1,b,d;exit when c%notfound;
      if d<>v_owner then fail('Cross-owner index unsupported');end if;
      list_add(ic,v_name,a,b);end loop;close c;
    op('select index_name,index_type,uniqueness,generated,partitioned,status,visibility,compression,prefix_length,owner from sys.'||v_prefix||'indexes'||wh('table_owner','table_name'));
    loop fetch c into v_name,a,b,d,e,g,h,k,q1,z;exit when c%notfound;
      if z<>v_owner then fail('Cross-owner index unsupported');end if;
      if a<>'NORMAL' or e<>'NO' then fail('Only nonpartitioned NORMAL B-tree indexes supported');end if;
      if not ic.exists(v_name) then fail('Missing index columns');end if;
      start_record;
      if d='Y' then field(1,'INDEX_NAME',1);else field(1,'INDEX_NAME',2,v_name);end if;
      field(2,'INDEX_TYPE',2,a);field(3,'UNIQUENESS',2,b);field(4,'STATUS',2,g);field(5,'VISIBILITY',2,h);
      field(6,'COMPRESSION',2,k);if k='ENABLED' then int_field(7,'PREFIX_LENGTH',q1);else field(7,'PREFIX_LENGTH',1);end if;
      field(8,'ORDERED_COLUMNS_DIRECTIONS_HEX',2,ic(v_name));finish(hextoraw('13'),'INDEX');
    end loop;close c;
    sort_items(1,n);dbms_lob.createtemporary(p_bytes,true);
    -- Header: magic AO3\0, wire version=1, profile tuple value frames, record count.
    write_raw(hextoraw('414F330000000001'));
    write_raw(value_frame(2,'TABLE_CORE'));write_raw(value_frame(3,'2'));
    write_raw(value_frame(2,'CAN-001-DRAFT-1'));write_raw(value_frame(2,'SHA256'));write_raw(uint32(n));
    for i in 1..n loop write_raw(items(i).b);records.append(items(i).j);end loop;
    p_hash:=dbms_crypto.hash(p_bytes,dbms_crypto.hash_sh256);
    -- Runtime context is provenance ONLY. It never enters the canonical bytes.
    execute immediate 'select instance_number,version from sys.gv_$instance where inst_id=to_number(sys_context(''USERENV'',''INSTANCE''))' into inst,v_version;
    provenance.put('dictionary_family',p_source);provenance.put('con_id',v_con);
    provenance.put('con_name',sys_context('USERENV','CON_NAME'));provenance.put('instance',inst);provenance.put('version',v_version);
    provenance.put('owner',v_owner);provenance.put('table_name',p_table);
    manifest.put('profile_code','TABLE_CORE');manifest.put('profile_version',2);
    manifest.put('canonical_version','CAN-001-DRAFT-1');manifest.put('coverage','BOUNDED_PROFILE');
    manifest.put('source',provenance);manifest.put('records',records);manifest.put('sha256',rawtohex(p_hash));
    p_manifest:=manifest.to_clob;
  exception when others then
    if c%isopen then close c;end if;
    if dc is not null then if dbms_sql.is_open(dc) then dbms_sql.close_cursor(dc);end if;end if;
    if dbms_lob.istemporary(p_bytes)=1 then dbms_lob.freetemporary(p_bytes);end if;
    if dbms_lob.istemporary(p_manifest)=1 then dbms_lob.freetemporary(p_manifest);end if;
    raise;
  end;
  procedure store_observations(p_table varchar2,p_source varchar2,p_release varchar2) is
    m clob;bb blob;hh raw(32);child blob;cm clob;
    root json_object_t;rs json_array_t;r json_object_t;fs json_array_t;f json_object_t;
    child_doc json_object_t;one_row json_array_t;src json_object_t;
    payload raw(32767);wire raw(32767);profile varchar2(30);kind varchar2(40);tag raw(1);
    owner_name varchar2(128);identity_name varchar2(128);container_id number;
    procedure release_lobs is begin
      if dbms_lob.istemporary(m)=1 then dbms_lob.freetemporary(m);end if;
      if dbms_lob.istemporary(bb)=1 then dbms_lob.freetemporary(bb);end if;
      if dbms_lob.istemporary(child)=1 then dbms_lob.freetemporary(child);end if;
      if dbms_lob.istemporary(cm)=1 then dbms_lob.freetemporary(cm);end if;
    end;
  begin
    -- Savepoint makes this observation set atomic without committing caller work.
    savepoint ao3_store;
    calculate(p_table,p_source,m,bb,hh);root:=json_object_t.parse(m);
    src:=root.get_object('source');rs:=root.get_array('records');
    owner_name:=src.get_string('owner');container_id:=src.get_number('con_id');
    insert into ao3_fp values(p_release,owner_name,p_table,'TABLE',
      'TABLE_CORE',2,'CAN-001-DRAFT-1',systimestamp,container_id,hh,m);
    for i in 0..rs.get_size-1 loop
      r:=treat(rs.get(i) as json_object_t);kind:=r.get_string('component');
      if kind in ('CONSTRAINTS','INDEX') then
        if kind='INDEX' then profile:='INDEX_CORE';tag:=hextoraw('13');
        else profile:='CONSTRAINT_CORE';tag:=hextoraw('12');end if;
        payload:=null;fs:=r.get_array('fields');
        for j in 0..fs.get_size-1 loop
          f:=treat(fs.get(j) as json_object_t);
          payload:=utl_raw.concat(payload,uint32(f.get_number('id')),
            value_frame(f.get_number('tag'),f.get_string('value')));
        end loop;
        wire:=utl_raw.concat(tag,uint32(utl_raw.length(payload)),payload);
        dbms_lob.createtemporary(child,true);
        payload:=utl_raw.concat(hextoraw('414F330000000001'),value_frame(2,profile),
          value_frame(3,'1'),value_frame(2,'CAN-001-DRAFT-1'),value_frame(2,'SHA256'),uint32(1));
        dbms_lob.writeappend(child,utl_raw.length(payload),payload);
        dbms_lob.writeappend(child,utl_raw.length(wire),wire);
        hh:=dbms_crypto.hash(child,dbms_crypto.hash_sh256);
        child_doc:=json_object_t();one_row:=json_array_t();one_row.append(r);
        child_doc.put('profile_code',profile);child_doc.put('profile_version',1);
        child_doc.put('canonical_version','CAN-001-DRAFT-1');child_doc.put('source',src);
        child_doc.put('coverage','BOUNDED_PROFILE');child_doc.put('records',one_row);child_doc.put('sha256',rawtohex(hh));
        cm:=child_doc.to_clob;
        identity_name:=r.get_string('source_identity');
        insert into ao3_fp values(p_release,owner_name,identity_name,kind,
          profile,1,'CAN-001-DRAFT-1',systimestamp,container_id,hh,cm);
        dbms_lob.freetemporary(child);dbms_lob.freetemporary(cm);
      end if;
    end loop;
    release_lobs;
  exception when others then rollback to ao3_store;release_lobs;raise;
  end;
end;
/
-- CREATE PACKAGE can complete with compilation errors; inspect explicitly.
declare n number;begin
 select count(*) into n from user_errors where name='AO3_POC';
 if n>0 then raise_application_error(-20399,'AO3_POC has compilation errors; inspect USER_ERRORS');end if;
end;
/
