-- PM-001 revision 004. See reference/DECISIONS.md D07 and REQUIREMENTS R02-R05.
whenever sqlerror exit failure rollback
set define off
set sqlblanklines on
create package ao4_poc authid definer as
  -- METADATA_V1: positional query contracts documented in DESIGN.html.
  -- Separate NUMBER and text cells avoid any NLS-dependent numeric conversion.
  type text_cells is table of varchar2(32767) index by pls_integer;
  type number_cells is table of number index by pls_integer;
  type metadata_row is record(txt text_cells,num number_cells);
  type metadata_rows is table of metadata_row index by pls_integer;
  type metadata_set is record(rows_ metadata_rows);
  type metadata_sets is table of metadata_set index by pls_integer;
  type metadata_t is record(contract_version varchar2(30),sets_ metadata_sets,
    owner_name varchar2(128),table_name varchar2(128),source_family varchar2(3),
    container_id number,container_name varchar2(128),instance_number number,db_version varchar2(100));
  -- No stage commits. Discard OUT values on exception. Caller frees successful LOBs.
  procedure extract_metadata(p_table varchar2,p_source varchar2,p_data out metadata_t);
  procedure normalize_metadata(p_data metadata_t,p_manifest out clob);
  procedure serialize_manifest(p_manifest clob,p_bytes out blob,p_hash out raw);
  procedure calculate(p_table varchar2,p_source varchar2,p_manifest out clob,p_bytes out blob,p_hash out raw);
  procedure store_observations(p_table varchar2,p_source varchar2,p_release varchar2);
  -- p_label is an encountered offer label, NOT a fabricated Oracle object type.
  -- p_identity must exist locally, except TABLE extraction records a missing target error.
  procedure preflight(p_label varchar2,p_identity varchar2,p_source varchar2,p_release varchar2);
  function uint32(p_n number) return raw;
  function value_frame(p_tag pls_integer,p_text varchar2 default null) return raw;
  function recognition(p_type varchar2) return varchar2;
  function binary_compare(p_x raw,p_y raw) return pls_integer;
end;
/
create package body ao4_poc as
  function recognition(p_type varchar2) return varchar2 is n number;
  begin
    select count(*) into n from ao4_catalog where type_code=p_type;
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

  procedure extract_metadata(p_table varchar2,p_source varchar2,p_data out metadata_t) is
    v_owner varchar2(128):=sys_context('USERENV','CURRENT_USER');
    v_con number:=to_number(sys_context('USERENV','CON_ID'));
    v_prefix varchar2(4);filter_sql varchar2(100);
    dc integer;cnt integer;ignored integer;descs dbms_sql.desc_tab2;
    n number;t varchar2(32767);chunk varchar2(8000);got integer;off_ integer;r pls_integer;
    empty_set metadata_set;row_ metadata_row;
    function wh(p_owner_col varchar2,p_table_col varchar2) return varchar2 is begin
      return ' where '||p_owner_col||'=:own and '||p_table_col||'=:tab'||filter_sql;end;
    procedure read_set(slot pls_integer,statement_ varchar2) is
    begin
      dc:=dbms_sql.open_cursor;
      dbms_sql.parse(dc,statement_,dbms_sql.native);
      dbms_sql.bind_variable(dc,':own',v_owner);dbms_sql.bind_variable(dc,':tab',p_table);
      if p_source='CDB' then dbms_sql.bind_variable(dc,':cid',v_con);end if;
      dbms_sql.describe_columns2(dc,cnt,descs);
      p_data.sets_(slot):=empty_set;
      for col in 1..cnt loop
        if descs(col).col_type=2 then dbms_sql.define_column(dc,col,n);
        elsif descs(col).col_type=8 then dbms_sql.define_column_long(dc,col);
        else dbms_sql.define_column(dc,col,t,32767);end if;
      end loop;
      ignored:=dbms_sql.execute(dc);r:=0;
      while dbms_sql.fetch_rows(dc)>0 loop
        r:=r+1;
        if r>1000 then raise_application_error(-20311,'Metadata set exceeds 1000 rows');end if;
        row_.txt.delete;row_.num.delete;
        for col in 1..cnt loop
          if descs(col).col_type=2 then
            dbms_sql.column_value(dc,col,n);row_.num(col):=n;
          elsif descs(col).col_type=8 then
            t:=null;off_:=0;
            loop
              dbms_sql.column_value_long(dc,col,8000,off_,chunk,got);exit when got=0;
              -- Complete LONG, or an explicit bound failure. Never truncate *_VC.
              if nvl(lengthb(t),0)+lengthb(chunk)>8000 then
                raise_application_error(-20312,'CHECK LONG exceeds bounded extractor buffer');end if;
              t:=t||chunk;off_:=off_+got;
            end loop;
            row_.txt(col):=t;
          else dbms_sql.column_value(dc,col,t);row_.txt(col):=t;
          end if;
        end loop;
        p_data.sets_(slot).rows_(r):=row_;
      end loop;
      dbms_sql.close_cursor(dc);dc:=null;
    end;
  begin
    if p_source is null or p_source not in ('CDB','DBA') then
      raise_application_error(-20313,'Source must be CDB or DBA');end if;
    if v_con<3 then raise_application_error(-20314,'Local target PDB only');end if;
    if p_table is null then raise_application_error(-20315,'Table identity required');end if;
    p_data.contract_version:='METADATA_V1';p_data.owner_name:=v_owner;p_data.table_name:=p_table;
    p_data.source_family:=p_source;p_data.container_id:=v_con;
    p_data.container_name:=sys_context('USERENV','CON_NAME');
    v_prefix:=p_source||'_';if p_source='CDB' then filter_sql:=' and con_id=:cid';end if;
    read_set(1,'select iot_type,cluster_name,temporary,nested,partitioned,secondary from sys.'||v_prefix||'tables'||wh('owner','table_name'));
    read_set(2,'select table_name from sys.'||v_prefix||'external_tables'||wh('owner','table_name'));
    read_set(3,'select column_name,column_id,data_type,data_precision,data_scale,char_length,char_used,data_length,nullable,hidden_column,virtual_column,identity_column,default_length,collation from sys.'||v_prefix||'tab_cols'||wh('owner','table_name'));
    read_set(4,'select constraint_name,column_name,position from sys.'||v_prefix||'cons_columns'||wh('owner','table_name')||' order by nlssort(constraint_name,''NLS_SORT=BINARY''),position nulls last,nlssort(column_name,''NLS_SORT=BINARY'')');
    read_set(5,'select constraint_name,constraint_type,generated,status,deferrable,deferred,validated,rely from sys.'||v_prefix||'constraints'||wh('owner','table_name'));
    read_set(6,'select index_name,column_name,column_position,descend,index_owner from sys.'||v_prefix||'ind_columns'||wh('table_owner','table_name')||' order by nlssort(index_name,''NLS_SORT=BINARY''),column_position');
    read_set(7,'select index_name,index_type,uniqueness,generated,partitioned,status,visibility,compression,prefix_length,owner from sys.'||v_prefix||'indexes'||wh('table_owner','table_name'));
    read_set(8,'select constraint_name,search_condition from sys.'||v_prefix||'constraints'||wh('owner','table_name')||' and constraint_type=''C''');

    if p_data.sets_(1).rows_.count<>1 then
      raise_application_error(-20316,'Table absent OR invisible OR duplicate in selected local source');end if;
    execute immediate 'select instance_number,version from sys.gv_$instance where inst_id=to_number(sys_context(''USERENV'',''INSTANCE''))'
      into p_data.instance_number,p_data.db_version;
  exception when others then
    if dc is not null then if dbms_sql.is_open(dc) then dbms_sql.close_cursor(dc);end if;end if;
    raise;
  end;
  procedure normalize_metadata(p_data metadata_t,p_manifest out clob) is
    type item_t is record(j json_object_t);
    type items_t is table of item_t index by binary_integer;
    type strings_t is table of varchar2(32767) index by varchar2(128);
    items items_t; cc strings_t; ic strings_t; checks strings_t;
    n pls_integer:=0; fields json_array_t;
    v_owner varchar2(128):=p_data.owner_name;
    v_con number:=p_data.container_id;
    slot pls_integer;pos_ pls_integer;found_ boolean;
    v_name varchar2(128); v_type varchar2(128);
    a varchar2(4000); b varchar2(4000); d varchar2(4000); e varchar2(4000);
    g varchar2(4000); h varchar2(4000); k varchar2(4000); z varchar2(4000);
    q1 number;q2 number;q3 number;q4 number;q5 number;
    ignored integer;
    v_long varchar2(32767);
    manifest json_object_t:=json_object_t(); records json_array_t:=json_array_t();
    provenance json_object_t:=json_object_t();
    procedure fail(msg varchar2) is begin raise_application_error(-20310,msg);end;
    function nt(x number) return varchar2 is begin
      return to_char(x,'TM9','NLS_NUMERIC_CHARACTERS=''.,''');end;
    procedure open_set(p_slot pls_integer) is begin slot:=p_slot;pos_:=0;end;
    procedure next_row is begin pos_:=pos_+1;
        found_:=p_data.sets_(slot).rows_.exists(pos_);end;
    procedure start_record is begin fields:=json_array_t();end;
    procedure field(fid pls_integer,label varchar2,tag pls_integer,val varchar2 default null) is
      j json_object_t:=json_object_t();
    begin
      j.put('id',fid);j.put('property',label);j.put('tag',tag);
      if val is null then j.put_null('value');else j.put('value',val);end if;
      fields.append(j);
    end;
    procedure text_field(fid pls_integer,label varchar2,val varchar2) is begin
      if val is null then field(fid,label,0);else field(fid,label,2,val);end if;end;
    procedure int_field(fid pls_integer,label varchar2,val number) is begin
      if val is null then field(fid,label,0);else field(fid,label,3,nt(val));end if;end;
    procedure finish(kind varchar2) is begin
      n:=n+1;if n>1000 then fail('More than 1000 records');end if;
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
  begin
    p_manifest:=null;
    if p_data.contract_version is null or p_data.contract_version<>'METADATA_V1' then
      fail('Wrong metadata contract');end if;
    -- Raw dataset is a local-PDB observation; normalization performs no database reads.
    open_set(1);
    next_row;if found_ then
        a:=p_data.sets_(slot).rows_(pos_).txt(1);
        b:=p_data.sets_(slot).rows_(pos_).txt(2);
        d:=p_data.sets_(slot).rows_(pos_).txt(3);
        e:=p_data.sets_(slot).rows_(pos_).txt(4);
        g:=p_data.sets_(slot).rows_(pos_).txt(5);
        h:=p_data.sets_(slot).rows_(pos_).txt(6);end if;
    if not found_ then fail('Table absent OR invisible in selected source; no fingerprint');end if;
    if d is null or e is null or g is null or h is null or a is not null or b is not null or d<>'N' or e<>'NO' or g<>'NO' or h<>'N' then fail('Only permanent nonpartitioned heap tables supported');end if;
    next_row;if found_ then
        a:=p_data.sets_(slot).rows_(pos_).txt(1);
        b:=p_data.sets_(slot).rows_(pos_).txt(2);
        d:=p_data.sets_(slot).rows_(pos_).txt(3);
        e:=p_data.sets_(slot).rows_(pos_).txt(4);
        g:=p_data.sets_(slot).rows_(pos_).txt(5);
        h:=p_data.sets_(slot).rows_(pos_).txt(6);end if;if found_ then fail('Duplicate table metadata');end if;
    open_set(2);
    next_row;if found_ then
        v_name:=p_data.sets_(slot).rows_(pos_).txt(1);end if;if found_ then fail('External table unsupported');end if;
    v_name:=p_data.table_name;start_record;field(1,'TABLE_KIND',2,'HEAP');finish('TABLE');
    open_set(3);
    loop
      next_row;if found_ then
        v_name:=p_data.sets_(slot).rows_(pos_).txt(1);
        q1:=p_data.sets_(slot).rows_(pos_).num(2);
        v_type:=p_data.sets_(slot).rows_(pos_).txt(3);
        q2:=p_data.sets_(slot).rows_(pos_).num(4);
        q3:=p_data.sets_(slot).rows_(pos_).num(5);
        q4:=p_data.sets_(slot).rows_(pos_).num(6);
        a:=p_data.sets_(slot).rows_(pos_).txt(7);
        q5:=p_data.sets_(slot).rows_(pos_).num(8);
        b:=p_data.sets_(slot).rows_(pos_).txt(9);
        d:=p_data.sets_(slot).rows_(pos_).txt(10);
        e:=p_data.sets_(slot).rows_(pos_).txt(11);
        g:=p_data.sets_(slot).rows_(pos_).txt(12);
        ignored:=p_data.sets_(slot).rows_(pos_).num(13);
        h:=p_data.sets_(slot).rows_(pos_).txt(14);end if;exit when not found_;
      if d is null or e is null or g is null or d<>'NO' or e<>'NO' or g<>'NO' or q1 is null or nvl(ignored,0)>0 then fail('Hidden/invisible/virtual/identity/default column unsupported');end if;
      if v_type not in ('NUMBER','FLOAT','CHAR','VARCHAR2','NCHAR','NVARCHAR2','RAW','DATE') then fail('Unsupported datatype: '||v_type);end if;
      start_record;field(1,'COLUMN_NAME',2,v_name);int_field(2,'COLUMN_ID',q1);field(3,'DATA_TYPE',2,v_type);
      if v_type in ('NUMBER','FLOAT') then int_field(4,'DATA_PRECISION',q2);int_field(5,'DATA_SCALE',q3);
      else field(4,'DATA_PRECISION',1);field(5,'DATA_SCALE',1);end if;
      if v_type in ('CHAR','VARCHAR2','NCHAR','NVARCHAR2') then int_field(6,'CHAR_LENGTH',q4);text_field(7,'CHAR_USED',a);
      else field(6,'CHAR_LENGTH',1);field(7,'CHAR_USED',1);end if;
      -- Draft rule only. Historical rationale for omission remains unproven.
      if v_type='RAW' or (v_type in ('CHAR','VARCHAR2') and a='B') then int_field(8,'DATA_LENGTH',q5);
      else field(8,'DATA_LENGTH',1);end if;
      field(9,'NULLABLE',2,b);text_field(10,'COLLATION',h);finish('COLUMN');
    end loop;
    if n=1 then fail('No visible column metadata');end if;
    open_set(4);
    loop next_row;if found_ then
        v_name:=p_data.sets_(slot).rows_(pos_).txt(1);
        a:=p_data.sets_(slot).rows_(pos_).txt(2);
        q1:=p_data.sets_(slot).rows_(pos_).num(3);end if;exit when not found_;list_add(cc,v_name,a);end loop;
    -- Complete LONG values already extracted in set 8; no dictionary access here.
    open_set(8);loop next_row;exit when not found_;
      v_name:=p_data.sets_(8).rows_(pos_).txt(1);
      v_long:=p_data.sets_(8).rows_(pos_).txt(2);
      if v_long is null then fail('Missing CHECK expression');end if;checks(v_name):=v_long;
    end loop;
    open_set(5);
    loop next_row;if found_ then
        v_name:=p_data.sets_(slot).rows_(pos_).txt(1);
        a:=p_data.sets_(slot).rows_(pos_).txt(2);
        b:=p_data.sets_(slot).rows_(pos_).txt(3);
        d:=p_data.sets_(slot).rows_(pos_).txt(4);
        e:=p_data.sets_(slot).rows_(pos_).txt(5);
        g:=p_data.sets_(slot).rows_(pos_).txt(6);
        h:=p_data.sets_(slot).rows_(pos_).txt(7);
        k:=p_data.sets_(slot).rows_(pos_).txt(8);end if;exit when not found_;
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
      finish('CONSTRAINTS');
    end loop;
    open_set(6);
    loop next_row;if found_ then
        v_name:=p_data.sets_(slot).rows_(pos_).txt(1);
        a:=p_data.sets_(slot).rows_(pos_).txt(2);
        q1:=p_data.sets_(slot).rows_(pos_).num(3);
        b:=p_data.sets_(slot).rows_(pos_).txt(4);
        d:=p_data.sets_(slot).rows_(pos_).txt(5);end if;exit when not found_;
      if d<>v_owner then fail('Cross-owner index unsupported');end if;
      list_add(ic,v_name,a,b);end loop;
    open_set(7);
    loop next_row;if found_ then
        v_name:=p_data.sets_(slot).rows_(pos_).txt(1);
        a:=p_data.sets_(slot).rows_(pos_).txt(2);
        b:=p_data.sets_(slot).rows_(pos_).txt(3);
        d:=p_data.sets_(slot).rows_(pos_).txt(4);
        e:=p_data.sets_(slot).rows_(pos_).txt(5);
        g:=p_data.sets_(slot).rows_(pos_).txt(6);
        h:=p_data.sets_(slot).rows_(pos_).txt(7);
        k:=p_data.sets_(slot).rows_(pos_).txt(8);
        q1:=p_data.sets_(slot).rows_(pos_).num(9);
        z:=p_data.sets_(slot).rows_(pos_).txt(10);end if;exit when not found_;
      if z<>v_owner then fail('Cross-owner index unsupported');end if;
      if a<>'NORMAL' or e<>'NO' then fail('Only nonpartitioned NORMAL B-tree indexes supported');end if;
      if not ic.exists(v_name) then fail('Missing index columns');end if;
      start_record;
      if d='Y' then field(1,'INDEX_NAME',1);else field(1,'INDEX_NAME',2,v_name);end if;
      field(2,'INDEX_TYPE',2,a);field(3,'UNIQUENESS',2,b);field(4,'STATUS',2,g);field(5,'VISIBILITY',2,h);
      field(6,'COMPRESSION',2,k);if k='ENABLED' then int_field(7,'PREFIX_LENGTH',q1);else field(7,'PREFIX_LENGTH',1);end if;
      field(8,'ORDERED_COLUMNS_DIRECTIONS_HEX',2,ic(v_name));finish('INDEX');
    end loop;
    for i in 1..n loop records.append(items(i).j);end loop;
    provenance.put('dictionary_family',p_data.source_family);provenance.put('con_id',v_con);
    provenance.put('con_name',p_data.container_name);provenance.put('instance',p_data.instance_number);
    provenance.put('version',p_data.db_version);provenance.put('owner',v_owner);
    provenance.put('table_name',p_data.table_name);
    manifest.put('profile_code','TABLE_CORE');manifest.put('profile_version',2);
    manifest.put('canonical_version','CAN-001-DRAFT-1');manifest.put('coverage','BOUNDED_PROFILE');
    manifest.put('source',provenance);manifest.put('records',records);manifest.put('normalizer_code','AO3_RULES_1');
    p_manifest:=manifest.to_clob;
  exception when others then
    if dbms_lob.istemporary(p_manifest)=1 then dbms_lob.freetemporary(p_manifest);end if;
    raise;
  end;

  procedure serialize_manifest(p_manifest clob,p_bytes out blob,p_hash out raw) is
    root json_object_t:=json_object_t.parse(p_manifest);rs json_array_t;fs json_array_t;
    r json_object_t;f json_object_t;profile varchar2(30);pv number;kind varchar2(40);cv varchar2(40);ftag number;
    element_ json_element_t;text_value_ varchar2(32767);
    type wires_t is table of raw(32767) index by pls_integer;
    wires wires_t;body_ raw(32767);part raw(32767);tag raw(1);n pls_integer;last_id number;fid number;
    procedure fail(msg varchar2) is begin raise_application_error(-20320,msg);end;
    procedure wr(x raw) is begin
      if dbms_lob.getlength(p_bytes)+utl_raw.length(x)>1000000 then fail('Document exceeds 1 MB');end if;
      dbms_lob.writeappend(p_bytes,utl_raw.length(x),x);
    end;
    procedure sort_(lo pls_integer,hi pls_integer) is
      i pls_integer:=lo;j pls_integer:=hi;p raw(32767);tmp raw(32767);
    begin
      p:=wires(trunc((lo+hi)/2));
      while i<=j loop
        while binary_compare(wires(i),p)<0 loop i:=i+1;end loop;
        while binary_compare(wires(j),p)>0 loop j:=j-1;end loop;
        if i<=j then tmp:=wires(i);wires(i):=wires(j);wires(j):=tmp;i:=i+1;j:=j-1;end if;
      end loop;
      if lo<j then sort_(lo,j);end if;if i<hi then sort_(i,hi);end if;
    end;
  begin
    p_bytes:=null;p_hash:=null;root.on_error(1);
    profile:=root.get_string('profile_code');pv:=root.get_number('profile_version');
    if profile is null or pv is null or not
      ((profile='TABLE_CORE' and pv=2) or (profile in ('INDEX_CORE','CONSTRAINT_CORE') and pv=1))
      then fail('Unknown profile tuple');end if;
    cv:=root.get_string('canonical_version');
    if cv is null or cv<>'CAN-001-DRAFT-1' then fail('Unknown canonical version');end if;
    rs:=root.get_array('records');n:=rs.get_size;
    if n<1 or n>1000 then fail('Record count outside bounds');end if;
    if profile<>'TABLE_CORE' and n<>1 then fail('Individual child profile requires exactly one record');end if;
    for i in 0..n-1 loop
      r:=treat(rs.get(i) as json_object_t);r.on_error(1);kind:=r.get_string('component');
      if kind='TABLE' then tag:=hextoraw('10');elsif kind='COLUMN' then tag:=hextoraw('11');
      elsif kind='CONSTRAINTS' then tag:=hextoraw('12');elsif kind='INDEX' then tag:=hextoraw('13');
      else fail('Unknown record kind');end if;
      if (profile='INDEX_CORE' and kind<>'INDEX') or (profile='CONSTRAINT_CORE' and kind<>'CONSTRAINTS')
        then fail('Child profile record mismatch');end if;
      body_:=null;fs:=r.get_array('fields');last_id:=0;
      if fs.get_size=0 then fail('No fields');end if;
      for j in 0..fs.get_size-1 loop
        f:=treat(fs.get(j) as json_object_t);f.on_error(1);fid:=f.get_number('id');
        if fid is null or fid<=last_id or fid<>trunc(fid) then fail('Field IDs must increase');end if;
        last_id:=fid;
        ftag:=f.get_number('tag');
        if ftag is null or ftag<>trunc(ftag) or ftag not in (0,1,2,3) then fail('Invalid value tag');end if;
        if not f.has('value') then fail('Missing value member');end if;
        element_:=f.get('value');
        if element_.is_null then text_value_:=null;
        elsif element_.is_string then text_value_:=f.get_string('value');
        else fail('Field value must be STRING or JSON null');end if;
        part:=utl_raw.concat(uint32(fid),value_frame(ftag,text_value_));
        if nvl(utl_raw.length(body_),0)+utl_raw.length(part)>15995 then fail('Record exceeds 16000 bytes');end if;
        body_:=utl_raw.concat(body_,part);
      end loop;
      wires(i+1):=utl_raw.concat(tag,uint32(utl_raw.length(body_)),body_);
    end loop;
    sort_(1,n);dbms_lob.createtemporary(p_bytes,true);
    wr(hextoraw('414F330000000001'));wr(value_frame(2,profile));
    wr(value_frame(3,to_char(pv,'TM9','NLS_NUMERIC_CHARACTERS=''.,''')));
    wr(value_frame(2,'CAN-001-DRAFT-1'));wr(value_frame(2,'SHA256'));wr(uint32(n));
    for i in 1..n loop wr(wires(i));end loop;
    p_hash:=dbms_crypto.hash(p_bytes,dbms_crypto.hash_sh256);
  exception when others then
    if dbms_lob.istemporary(p_bytes)=1 then dbms_lob.freetemporary(p_bytes);end if;raise;
  end;
  procedure calculate(p_table varchar2,p_source varchar2,p_manifest out clob,p_bytes out blob,p_hash out raw) is
    data_ metadata_t;doc json_object_t;
  begin
    p_manifest:=null;p_bytes:=null;p_hash:=null;
    extract_metadata(p_table,p_source,data_);normalize_metadata(data_,p_manifest);
    serialize_manifest(p_manifest,p_bytes,p_hash);
    doc:=json_object_t.parse(p_manifest);doc.put('sha256',rawtohex(p_hash));
    dbms_lob.freetemporary(p_manifest);p_manifest:=doc.to_clob;
  exception when others then
    if dbms_lob.istemporary(p_manifest)=1 then dbms_lob.freetemporary(p_manifest);end if;
    if dbms_lob.istemporary(p_bytes)=1 then dbms_lob.freetemporary(p_bytes);end if;raise;
  end;
  procedure store_observations(p_table varchar2,p_source varchar2,p_release varchar2) is
    m clob;bb blob;hh raw(32);child blob;cm clob;
    root json_object_t;rs json_array_t;r json_object_t;
    child_doc json_object_t;one_row json_array_t;src json_object_t;
    profile varchar2(30);kind varchar2(40);
    owner_name varchar2(128);identity_name varchar2(128);container_id number;
    procedure release_lobs is begin
      if dbms_lob.istemporary(m)=1 then dbms_lob.freetemporary(m);end if;
      if dbms_lob.istemporary(bb)=1 then dbms_lob.freetemporary(bb);end if;
      if dbms_lob.istemporary(child)=1 then dbms_lob.freetemporary(child);end if;
      if dbms_lob.istemporary(cm)=1 then dbms_lob.freetemporary(cm);end if;
    end;
  begin
    -- Savepoint makes this observation set atomic without committing caller work.
    savepoint ao4_store;
    calculate(p_table,p_source,m,bb,hh);root:=json_object_t.parse(m);
    src:=root.get_object('source');rs:=root.get_array('records');
    owner_name:=src.get_string('owner');container_id:=src.get_number('con_id');
    insert into ao4_fp values(p_release,owner_name,p_table,'TABLE',
      'TABLE_CORE',2,'CAN-001-DRAFT-1',systimestamp,container_id,hh,m);
    for i in 0..rs.get_size-1 loop
      r:=treat(rs.get(i) as json_object_t);kind:=r.get_string('component');
      if kind in ('CONSTRAINTS','INDEX') then
        if kind='INDEX' then profile:='INDEX_CORE';
        else profile:='CONSTRAINT_CORE';end if;
        child_doc:=json_object_t();one_row:=json_array_t();one_row.append(r);
        child_doc.put('profile_code',profile);child_doc.put('profile_version',1);
        child_doc.put('canonical_version','CAN-001-DRAFT-1');child_doc.put('source',src);
        child_doc.put('coverage','BOUNDED_PROFILE');child_doc.put('records',one_row);
        cm:=child_doc.to_clob;serialize_manifest(cm,child,hh);
        child_doc.put('sha256',rawtohex(hh));dbms_lob.freetemporary(cm);cm:=child_doc.to_clob;
        identity_name:=r.get_string('source_identity');
        insert into ao4_fp values(p_release,owner_name,identity_name,kind,
          profile,1,'CAN-001-DRAFT-1',systimestamp,container_id,hh,cm);
        dbms_lob.freetemporary(child);dbms_lob.freetemporary(cm);
      end if;
    end loop;
    release_lobs;
  exception when others then rollback to ao4_store;release_lobs;raise;
  end;
  procedure preflight(p_label varchar2,p_identity varchar2,p_source varchar2,p_release varchar2) is
    recognition_ varchar2(20);evaluation_ varchar2(30);reason_ varchar2(40);severity_ varchar2(12);
    action_ varchar2(40);phase_ varchar2(20):='VALIDATE';err number;msg varchar2(4000);n number;
    data_ metadata_t;m clob;b blob;h raw(32);actual_ varchar2(128);parent_ varchar2(128);
    doc json_object_t;rs json_array_t;r json_object_t;one_ json_array_t;selected_ boolean;
    query_ varchar2(1000);owner_ varchar2(128):=sys_context('USERENV','CURRENT_USER');
    procedure free_ is begin
      if dbms_lob.istemporary(m)=1 then dbms_lob.freetemporary(m);end if;
      if dbms_lob.istemporary(b)=1 then dbms_lob.freetemporary(b);end if;
    end;
  begin
    -- Findings are durable on caller COMMIT, and intentionally roll back with caller work.
    -- Not autonomous: a failed caller transaction must not leave false accepted results.
    select count(*) into n from ao4_release where release_id=p_release;
    if n<>1 then raise_application_error(-20330,'Preflight release must exist');end if;
    if p_label is null or p_identity is null or p_source is null or p_source not in ('CDB','DBA') then
      raise_application_error(-20331,'Label/identity and valid source required');end if;
    recognition_:=recognition(p_label);
    begin
      if p_label in ('TABLE','INDEX','CONSTRAINTS') then
        recognition_:='RECOGNIZED';phase_:='EXTRACT';
        parent_:=p_identity;
        if p_label<>'TABLE' then
          if p_label='INDEX' then
            query_:='select table_name from sys.'||p_source||'_indexes where owner=:own and index_name=:obj';
          else query_:='select table_name from sys.'||p_source||'_constraints where owner=:own and constraint_name=:obj';end if;
          if p_source='CDB' then
            query_:=query_||' and con_id=:cid';
            execute immediate query_ into parent_ using owner_,p_identity,to_number(sys_context('USERENV','CON_ID'));
          else execute immediate query_ into parent_ using owner_,p_identity;end if;
        end if;
        extract_metadata(parent_,p_source,data_);phase_:='NORMALIZE';normalize_metadata(data_,m);
        if p_label<>'TABLE' then
          doc:=json_object_t.parse(m);rs:=doc.get_array('records');one_:=json_array_t();selected_:=false;
          for i in 0..rs.get_size-1 loop
            r:=treat(rs.get(i) as json_object_t);
            if r.get_string('component')=p_label and r.get_string('source_identity')=p_identity then
              one_.append(r);selected_:=true;end if;
          end loop;
          if not selected_ then raise_application_error(-20317,'Requested child absent from normalized dataset');end if;
          if p_label='INDEX' then doc.put('profile_code','INDEX_CORE');else doc.put('profile_code','CONSTRAINT_CORE');end if;
          doc.put('profile_version',1);doc.put('records',one_);
          dbms_lob.freetemporary(m);m:=doc.to_clob;
        end if;
        phase_:='SERIALIZE';serialize_manifest(m,b,h);
        evaluation_:='EVALUATED_WITHIN_PROFILE';reason_:='BOUNDED_PROFILE';severity_:='INFO';action_:='COMPARE_PROFILE_ONLY';
        actual_:=p_label;
      else
        -- Actual locally encountered object identity is checked, even for unknown offer labels.
        -- This does not invent UNKNOWN Oracle types or claim an extractor for the other 50 labels.
        phase_:='EXTRACT';
        select min(object_type),count(*) into actual_,n from user_objects where object_name=p_identity
          and (recognition_='UNKNOWN' or object_type=p_label);
        if n=0 then raise_application_error(-20332,'Offered object absent OR invisible locally');end if;
        evaluation_:='NOT_EVALUATED';severity_:='WARNING';action_:='REVIEW_COVERAGE';
        if recognition_='UNKNOWN' then reason_:='NO_RECOGNITION_RULE';action_:='REVIEW_MAPPING';
        else reason_:='NO_EVALUATION_RULE';end if;
      end if;
    exception when others then
      err:=sqlcode;msg:=substr(sqlerrm,1,4000);h:=null;
      if (phase_='NORMALIZE' and err=-20310) or (phase_='EXTRACT' and err in (-20311,-20312)) then
        evaluation_:='UNSUPPORTED';reason_:='UNSUPPORTED_SHAPE';
      else evaluation_:='ERROR';reason_:='EXTRACTION_ERROR';
        if phase_='NORMALIZE' then reason_:='NORMALIZATION_ERROR';end if;
        if phase_='SERIALIZE' then reason_:='SERIALIZATION_ERROR';end if;
      end if;
      severity_:='ERROR';action_:='BLOCK_AND_REVIEW';
    end;
    insert into ao4_finding(release_id,component_type,component_identity,recognition_status,
      evaluation_status,severity,reason_code,recommended_action,exception_reference,
      observed_at,source_family,con_id,phase,error_code,error_message,actual_object_type,fingerprint)
    values(p_release,p_label,p_identity,recognition_,evaluation_,severity_,reason_,action_,null,
      systimestamp,p_source,to_number(sys_context('USERENV','CON_ID')),phase_,err,msg,actual_,h);
    free_;
  exception when others then free_;raise;
  end;
end;
/
show errors package ao4_poc
show errors package body ao4_poc
declare n number;begin
 select count(*) into n from user_errors where name='AO4_POC';
 if n<>0 then raise_application_error(-20399,'AO4_POC compilation errors');end if;
 select count(*) into n from user_objects where object_name='AO4_POC' and status='VALID';
 if n<>2 then raise_application_error(-20399,'AO4_POC spec/body not VALID');end if;
end;
/
