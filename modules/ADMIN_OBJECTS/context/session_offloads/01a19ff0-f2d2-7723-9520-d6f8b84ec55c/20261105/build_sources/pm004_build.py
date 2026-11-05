from pathlib import Path
import re,json,hashlib,shutil
OUT=Path('output/PM-001_20261103_004');REF=OUT/'reference';SRC=REF/'baseline_003'
SQL=OUT/'sql';SQL.mkdir(exist_ok=True)
def put(p,s):
    if 'set define off' in s:s=s.replace('set define off','set define off\nset sqlblanklines on',1)
    p.write_text(s.strip()+'\n',encoding='utf-8')
def original(p):return next(SRC.glob(p)).read_text(encoding='utf-8')
manifest=json.loads((REF/'manifest.json').read_text(encoding='utf-8'))
for f in manifest['files']:
    assert hashlib.sha256((OUT/f['path']).read_bytes()).hexdigest()==f['sha256']
old=original('*02_package*')
queries=re.findall(r'op\((.*)\);',old)
assert len(queries)==7
longquery="'select constraint_name,search_condition from sys.'||v_prefix||'constraints'||wh('owner','table_name')||' and constraint_type=''C'''"
spec='''-- PM-001 revision 004. See reference/DECISIONS.md D07 and REQUIREMENTS R02-R05.
whenever sqlerror exit failure rollback
set define off
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
'''
helpers=old.split('create package body ao3_poc as\n',1)[1].split('  procedure calculate(',1)[0].replace('ao3_','ao4_')
extract='''
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
'''
for i,q in enumerate(queries,1):extract+=f'    read_set({i},{q});\n'
extract+=f'    read_set(8,{longquery});\n'
extract+='''
    if p_data.sets_(1).rows_.count<>1 then
      raise_application_error(-20316,'Table absent OR invisible OR duplicate in selected local source');end if;
    execute immediate 'select instance_number,version from sys.gv_$instance where inst_id=to_number(sys_context(''USERENV'',''INSTANCE''))'
      into p_data.instance_number,p_data.db_version;
  exception when others then
    if dc is not null then if dbms_sql.is_open(dc) then dbms_sql.close_cursor(dc);end if;end if;
    raise;
  end;
'''
# Keep every 003 profile field rule, but remove database access and byte serialization.
norm=old[old.index('  procedure calculate(' ,old.index('create package body')):old.index('  procedure store_observations(',old.index('create package body'))]
norm=norm.replace('procedure calculate(p_table varchar2,p_source varchar2,\n    p_manifest out clob,p_bytes out blob,p_hash out raw)', 'procedure normalize_metadata(p_data metadata_t,p_manifest out clob)')
norm=norm.replace('type item_t is record(b raw(32767),j json_object_t);','type item_t is record(j json_object_t);')
norm=norm.replace("v_owner varchar2(128):=sys_context('USERENV','CURRENT_USER')","v_owner varchar2(128):=p_data.owner_name")
norm=norm.replace("v_con number:=to_number(sys_context('USERENV','CON_ID'))","v_con number:=p_data.container_id")
norm=norm.replace('filter_sql varchar2(200); c sys_refcursor; rowj json_object_t;', 'slot pls_integer;pos_ pls_integer;found_ boolean;rowj json_object_t;')
start=norm.index('    function wh(');end=norm.index('    procedure start_record',start)
norm=norm[:start]+'''    procedure open_set(p_slot pls_integer) is begin slot:=p_slot;pos_:=0;end;
    procedure next_row is begin pos_:=pos_+1;found_:=p_data.sets_(slot).rows_.exists(pos_);end;
'''+norm[end:]
norm=norm.replace('procedure start_record is begin body_raw:=null;fields:=json_array_t();end;', 'procedure start_record is begin fields:=json_array_t();end;')
start=norm.index('      part:=utl_raw.concat(uint32(fid)');end=norm.index("      j.put('id'",start)
norm=norm[:start]+norm[end:]
norm=norm.replace('      items(n).b:=utl_raw.concat(tag,uint32(utl_raw.length(body_raw)),body_raw);\n','')
norm=norm.replace('n pls_integer:=0; body_raw raw(32767); fields json_array_t;', 'n pls_integer:=0; fields json_array_t;')
norm=norm.replace('v_prefix varchar2(4); v_owner','v_owner')
norm=norm.replace('found_ boolean;rowj json_object_t;', 'found_ boolean;')
norm=norm.replace(' v_s varchar2(32767);','')
norm=norm.replace('dc integer; ignored integer; got integer; off_bytes integer; chunk varchar2(8000);','ignored integer;')
norm=norm.replace('v_long varchar2(32767); v_version varchar2(100); inst number;', 'v_long varchar2(32767);')
norm=norm.replace('part raw(32767); j json_object_t:=json_object_t();','j json_object_t:=json_object_t();')
norm=norm.replace('procedure finish(tag raw,kind varchar2)', 'procedure finish(kind varchar2)')
norm=re.sub(r"finish\(hextoraw\('[0-9A-F]+'\),",'finish(',norm)
start=norm.index('    procedure sort_items(');end=norm.index('  begin\n    p_hash',start)
norm=norm[:start]+norm[end:]
start=norm.index('    p_hash:=null;');end=norm.index('    -- No cross-container',start)
norm=norm[:start]+'''    p_manifest:=null;
    if p_data.contract_version is null or p_data.contract_version<>'METADATA_V1' then
      fail('Wrong metadata contract');end if;
'''+norm[end:]
for i,q in enumerate(queries,1):norm=norm.replace('op('+q+');',f'open_set({i});')
numeric={'q1','q2','q3','q4','q5','ignored'}
def fetch(m):
    vs=m.group(1).split(',')
    return 'next_row;if found_ then '+''.join(v.strip()+':=p_data.sets_(slot).rows_(pos_).'+('num' if v.strip() in numeric else 'txt')+f'({i});' for i,v in enumerate(vs,1))+'end if;'
norm=re.sub(r'fetch c into ([^;]+);',fetch,norm).replace('c%notfound','not found_').replace('c%found','found_').replace('close c;','')
start=norm.index('    -- Read complete CHECK LONG');end=norm.index('    open_set(5);',start)
norm=norm[:start]+'''    -- Complete LONG values already extracted in set 8; no dictionary access here.
    open_set(8);loop next_row;exit when not found_;
      v_name:=p_data.sets_(8).rows_(pos_).txt(1);
      v_long:=p_data.sets_(8).rows_(pos_).txt(2);
      if v_long is null then fail('Missing CHECK expression');end if;checks(v_name):=v_long;
    end loop;
'''+norm[end:]
norm=norm.replace('v_name:=p_table;','v_name:=p_data.table_name;')
norm=norm.replace('-- No cross-container LONG reads: run inside the target PDB (or local root).','-- Raw dataset is a local-PDB observation; normalization performs no database reads.')
norm=norm.replace("if a is not null or b is not null or d<>'N'", "if d is null or e is null or g is null or h is null or a is not null or b is not null or d<>'N'")
norm=norm.replace("if d<>'NO' or e<>'NO' or g<>'NO'", "if d is null or e is null or g is null or d<>'NO' or e<>'NO' or g<>'NO'")
# Ordered column-list HEX framing is a normalization grammar retained from 003.
start=norm.index('    sort_items(1,n);');end=norm.index("    manifest.put('profile_code'",start)
norm=norm[:start]+'''    for i in 1..n loop records.append(items(i).j);end loop;
    provenance.put('dictionary_family',p_data.source_family);provenance.put('con_id',v_con);
    provenance.put('con_name',p_data.container_name);provenance.put('instance',p_data.instance_number);
    provenance.put('version',p_data.db_version);provenance.put('owner',v_owner);
    provenance.put('table_name',p_data.table_name);
'''+norm[end:]
norm=norm.replace("manifest.put('sha256',rawtohex(p_hash));", "manifest.put('normalizer_code','AO3_RULES_1');")
start=norm.index('  exception when others then')
norm=norm[:start]+'''  exception when others then
    if dbms_lob.istemporary(p_manifest)=1 then dbms_lob.freetemporary(p_manifest);end if;
    raise;
  end;
'''
norm=re.sub(r';(?=[a-z0-9_]+:=p_data)', ';\n        ',norm)
norm=norm.replace('next_row;if found_ then ', 'next_row;if found_ then\n        ')
assert not re.search(r'\b(select|insert|execute immediate|dbms_sql|p_hash|p_bytes|p_table|p_source)\b',norm,re.I),norm
serializer="""
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
"""
store=old[old.index('  procedure store_observations(',old.index('create package body')):old.index('\nend;\n/',old.index('  procedure store_observations(',old.index('create package body')))]
store=store.replace('ao3_','ao4_')
start=store.index('        payload:=null;fs:=');end=store.index('        child_doc:=json_object_t();',start)
store=store[:start]+store[end:]
store=store.replace("child_doc.put('coverage','BOUNDED_PROFILE');child_doc.put('records',one_row);child_doc.put('sha256',rawtohex(hh));\n        cm:=child_doc.to_clob;", "child_doc.put('coverage','BOUNDED_PROFILE');child_doc.put('records',one_row);\n        cm:=child_doc.to_clob;serialize_manifest(cm,child,hh);\n        child_doc.put('sha256',rawtohex(hh));dbms_lob.freetemporary(cm);cm:=child_doc.to_clob;")
store=store.replace('r json_object_t;fs json_array_t;f json_object_t;','r json_object_t;')
store=store.replace('payload raw(32767);wire raw(32767);profile varchar2(30);kind varchar2(40);tag raw(1);','profile varchar2(30);kind varchar2(40);')
store=store.replace("profile:='INDEX_CORE';tag:=hextoraw('13');", "profile:='INDEX_CORE';")
store=store.replace("profile:='CONSTRAINT_CORE';tag:=hextoraw('12');", "profile:='CONSTRAINT_CORE';")
preflight='''
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
'''
package=spec+helpers+extract+norm+serializer+store+preflight+'''end;
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
'''
put(SQL/'02_package.sql',package)
setup=original('*01_setup*').replace('ao3_','ao4_').replace('AO3','AO4')
start=setup.index('create table ao4_finding(');end=setup.index('-- Simple heap fixture',start)
setup=setup[:start]+'''create table ao4_finding(finding_id number generated always as identity primary key,
 release_id varchar2(80) not null references ao4_release,
 component_type varchar2(128) not null,component_identity varchar2(128) not null,
 recognition_status varchar2(20) not null,evaluation_status varchar2(30) not null,
 severity varchar2(12) not null,reason_code varchar2(40) not null,
 recommended_action varchar2(40) not null,exception_reference varchar2(80),
 observed_at timestamp with time zone not null,source_family varchar2(3) not null,
 con_id number not null,phase varchar2(20),error_code number,error_message varchar2(4000),
 actual_object_type varchar2(128),fingerprint raw(32),
 check (evaluation_status='EVALUATED_WITHIN_PROFILE' or fingerprint is null));
'''+setup[end:]
# setup remains completely empty-schema guarded; require deliberate test-schema identity.
setup=setup.replace('declare n number;begin','''declare n number;begin
 if sys_context('USERENV','SESSION_USER')<>sys_context('USERENV','CURRENT_SCHEMA')
    or not regexp_like(sys_context('USERENV','SESSION_USER'),'^AO4_POC_[A-Z0-9_]+$','c')
    or to_number(sys_context('USERENV','CON_ID'))<3 then
   raise_application_error(-20300,'Use AO4_POC_<suffix> disposable local PDB user, CURRENT_SCHEMA unchanged');end if;''',1)
setup=setup.replace('commit;','''create view ao4_v as select id from ao4_t;
create table ao4_unsupported(id number default 0);
commit;''')
put(SQL/'01_setup.sql',setup)
priv=original('*00_privileges*').replace('<POC_SCHEMA>','<AO4_POC_SUFFIX>').replace('CREATE SESSION, CREATE TABLE, CREATE PROCEDURE','CREATE SESSION, CREATE TABLE, CREATE PROCEDURE, CREATE VIEW')
put(SQL/'00_privileges.sql',priv)
print('Generated B03/B04 package and setup from controlled reference only')
