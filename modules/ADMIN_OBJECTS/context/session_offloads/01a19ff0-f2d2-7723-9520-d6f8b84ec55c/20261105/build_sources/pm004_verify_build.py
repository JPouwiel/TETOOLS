from pathlib import Path
import re,json,hashlib,importlib.util,zipfile
OUT=Path('output/PM-001_20261103_004');SRC=OUT/'reference/baseline_003'
TOOLS=OUT/'tools';TOOLS.mkdir(exist_ok=True)
old=next(SRC.glob('*verify_log*')).read_text(encoding='utf-8')
encoder=old[:old.index('def check_log')]
reference=json.loads(next(SRC.glob('*objectmanifest_voorbeeld*')).read_text(encoding='utf-8'))
hex_=next(SRC.glob('*canonieke_bytes*')).read_text().strip()
vector="""-- Exact full 003 CAN-001 reference vector, executed on Oracle by 03_tests.sql.
declare m clob;b blob;expected_ blob;h raw(32);r raw(32767);begin
 m:=q'~"""+json.dumps(reference,ensure_ascii=True,separators=(',',':'))+"""~';
 ao4_poc.serialize_manifest(m,b,h);dbms_lob.createtemporary(expected_,true);
 r:=hextoraw('"""+hex_+"""');dbms_lob.writeappend(expected_,utl_raw.length(r),r);
 if dbms_lob.compare(b,expected_)<>0 or rawtohex(h)<>'"""+reference['sha256']+"""' then
   raise_application_error(-20450,'Full CAN-001 reference differs');end if;
 dbms_lob.freetemporary(m);dbms_lob.freetemporary(b);dbms_lob.freetemporary(expected_);
 dbms_output.put_line('PASS T63_FULL_FIXED_VECTOR');
exception when others then
 if dbms_lob.istemporary(m)=1 then dbms_lob.freetemporary(m);end if;
 if dbms_lob.istemporary(b)=1 then dbms_lob.freetemporary(b);end if;
 if dbms_lob.istemporary(expected_)=1 then dbms_lob.freetemporary(expected_);end if;raise;
end;
/
"""
# SQL*Plus input lines are kept below its line-size limit.
vector=vector.replace("m:=q'~", "m:=q'~\n").replace("~';", "\n~';").replace("');dbms_lob.writeappend", "');\n dbms_lob.writeappend")
# JSON can contain arbitrary line breaks between tokens, never split within a string.
vector=vector.replace(json.dumps(reference,ensure_ascii=True,separators=(',',':')),json.dumps(reference,ensure_ascii=True,indent=1))
(OUT/'sql/03_reference_vector.sql').write_text(vector,encoding='utf-8')
tests=(OUT/'sql/03_tests.sql').read_text()+vector
ids=sorted(set(re.findall(r'\b(T\d\d_[A-Z0-9_]+)\b',tests)))
assert len(ids)==63 and {int(x[1:3]) for x in ids}==set(range(1,64))
(OUT/'EXPECTED_ASSERTIONS.json').write_text(json.dumps(ids,indent=2)+'\n')
verifier=encoder+'''
def need(ok,msg):
 if not ok:raise ValueError(msg)
def read_log(path):
 s=Path(path).read_text(encoding='utf-8-sig')
 need(not re.search(r'(^|\\s)(ORA-|SP2-|PLS-|TNS-|LRM-|ERROR at line)',s),'Error in '+str(path))
 return s
def check_logs(main,persistent,privilege,cleanup):
 s=read_log(main);p=read_log(persistent);d=read_log(privilege);c=read_log(cleanup)
 required=json.loads((Path(__file__).resolve().parents[1]/'EXPECTED_ASSERTIONS.json').read_text())
 passes=re.findall(r'^PASS ([A-Z0-9_]+)\\s*$',s,re.M)
 for x in required:need(passes.count(x)==1,'Missing/duplicate assertion '+x)
 need(s.count('SUITE_COMPLETE PM001_004')==1,'Missing suite completion')
 docs={}
 pattern=r'^EVIDENCE_BEGIN ([^\\r\\n]+)\\r?\\nJSON_BEGIN\\r?\\n(.*?)\\r?\\nJSON_END\\r?\\nHEX_BEGIN\\r?\\n(.*?)\\r?\\nHEX_END\\r?\\nEVIDENCE_END'
 for match in re.finditer(pattern,s,re.M|re.S):
  identity,j,h=match.groups();need(identity not in docs,'Duplicate evidence identity')
  m=json.loads(''.join(j.splitlines()));actual=bytes.fromhex(h);expected=encode(m)
  need(actual==expected,'Canonical bytes differ: '+identity)
  need(hashlib.sha256(actual).hexdigest().upper()==m['sha256'],'Digest differs: '+identity)
  docs[identity]=m
 for key in ['CDB_TABLE','DBA_TABLE','DATATYPES','LONG_CHECK']:need(key in docs,'Missing '+key)
 need(encode(docs['CDB_TABLE'])==encode(docs['DBA_TABLE']),'CDB/DBA bytes mismatch')
 root=docs['CDB_TABLE'];source=root['source'];children=[r for r in root['records'] if r['component'] in ('CONSTRAINTS','INDEX')]
 expected_keys={'STORED_TABLE_'+source['table_name']}
 for r in children:
  kind=r['component'];identity=r['source_identity'];key='STORED_'+kind+'_'+identity;expected_keys.add(key)
  need(key in docs,'Missing stored child '+key)
  cm=docs[key];need(cm['records']==[r],'Child records diverge '+key)
  need(cm['profile_code']==('INDEX_CORE' if kind=='INDEX' else 'CONSTRAINT_CORE'),'Child profile')
 stored={k for k in docs if k.startswith('STORED_')};need(stored==expected_keys,'Stored key/count mismatch')
 need(encode(docs['STORED_TABLE_'+source['table_name']])==encode(root),'Stored table mismatch')
 for key in stored:
  tail=key.removeprefix('STORED_');need(passes.count('ROW_HASH_'+tail)==1,'Missing row hash assertion '+tail)
  need(passes.count('ROW_META_'+tail)==1,'Missing row metadata assertion '+tail)
 for id_ in ['P01_PERSISTENT_OBJECTS','P02_PERSISTENT_DIGESTS','P03_PERSISTENT_FINDINGS']:
  need(len(re.findall(r'^PASS '+id_+r'\\s*$',p,re.M))==1,'Missing persistent assertion '+id_)
 need('PERSISTENCE_COMPLETE PM001_004' in p,'Missing persistence completion')
 for id_ in ['D01_REAL_PRIVILEGE_ERROR','D02_EXPLICIT_DBA_ROUTE']:
  need(len(re.findall(r'^PASS '+id_+r'\\s*$',d,re.M))==1,'Missing privilege assertion '+id_)
 need('PRIVILEGE_COMPLETE PM001_004' in d,'Missing privilege completion')
 need(len(re.findall(r'^PASS C01_SCHEMA_EMPTY\\s*$',c,re.M))==1,'Missing cleanup assertion')
 need('CLEANUP_COMPLETE PM001_004' in c,'Missing cleanup completion')
 print('PASS',len(required),'mandatory database assertion markers;',len(stored),'individual object byte/digest proofs; persistence and cleanup markers')
 print('This verifies supplied logs. Confirm their Oracle 19c provenance and fresh-session execution separately.')
if __name__=='__main__':
 if len(sys.argv)!=5:raise SystemExit('Usage: python tools/verify_logs.py ao4_tests.log ao4_persistence.log ao4_privilege.log ao4_cleanup.log')
 check_logs(*sys.argv[1:])
'''
(TOOLS/'verify_logs.py').write_text(verifier,encoding='utf-8')
spec=importlib.util.spec_from_file_location('verifier',TOOLS/'verify_logs.py');mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)
m=json.loads(next(SRC.glob('*objectmanifest_voorbeeld*')).read_text(encoding='utf-8'))
encoded=mod.encode(m);expected=bytes.fromhex(next(SRC.glob('*canonieke_bytes*')).read_text())
assert encoded==expected and hashlib.sha256(encoded).hexdigest().upper()==m['sha256']
vectors=json.loads(next(SRC.glob('*CAN001_testvectoren*')).read_text(encoding='utf-8'))
print('PASS inherited reference fixture:',len(encoded),'bytes;',m['sha256'])
print('PASS complete static assertion ID inventory:',len(ids))
put= lambda p,s:p.write_text(s.strip()+'\n',encoding='utf-8')
put(TOOLS/'verify_integrity.py','''import hashlib,json,sys
from pathlib import Path
root=Path(__file__).resolve().parents[1]
manifest=json.loads((root/'manifest.json').read_text(encoding='utf-8'))
for e in manifest['files']:
 p=root/e['path']
 if p.stat().st_size!=e['bytes'] or hashlib.sha256(p.read_bytes()).hexdigest()!=e['sha256']:
  raise SystemExit('FAIL '+e['path'])
for line in (root/'SHA256SUMS.txt').read_text().splitlines():
 digest,name=line.split('  ',1)
 if hashlib.sha256((root/name).read_bytes()).hexdigest()!=digest:raise SystemExit('FAIL '+name)
print('PASS delivery manifest and SHA256SUMS')
''')
