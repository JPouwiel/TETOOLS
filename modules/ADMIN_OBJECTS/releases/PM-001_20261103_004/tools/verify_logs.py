"""Independent CAN-001-DRAFT-1 encoder; Python 3 standard library only.
Usage: python <this-file> ao3_test_results.log
No Oracle connection or credentials are used. This is NOT an Oracle compiler.
"""
import json,hashlib,struct,re,sys
from pathlib import Path
TAGS={'TABLE':0x10,'COLUMN':0x11,'CONSTRAINTS':0x12,'INDEX':0x13}
def u32(n):
 if not isinstance(n,int) or not 0<=n<=0xffffffff:raise ValueError('uint32')
 return struct.pack('>I',n)
def value(tag,v=None):
 if tag not in range(4):raise ValueError('tag')
 if tag in (0,1):
  if v is not None:raise ValueError('NULL/N/A payload')
  b=b''
 else:
  if not isinstance(v,str) or not v:raise ValueError('empty/text')
  if tag==3 and not re.fullmatch(r'(0|-[1-9][0-9]*|[1-9][0-9]*)',v):raise ValueError('integer')
  b=v.encode('utf-8')
  if len(b)>8000:raise ValueError('field limit')
 return bytes([tag])+u32(len(b))+b
def record(r):
 ids=[f['id'] for f in r['fields']]
 if ids!=sorted(set(ids)):raise ValueError('field order/duplicates')
 b=b''.join(u32(f['id'])+value(f['tag'],f['value']) for f in r['fields'])
 if len(b)>15995:raise ValueError('record limit')
 return bytes([TAGS[r['component']]])+u32(len(b))+b
def encode(m):
 if (m['profile_code'],m['profile_version']) not in [('TABLE_CORE',2),('INDEX_CORE',1),('CONSTRAINT_CORE',1)] or m['canonical_version']!='CAN-001-DRAFT-1':raise ValueError('profile contract')
 rs=sorted(record(r) for r in m['records'])
 if not 1<=len(rs)<=1000:raise ValueError('record count')
 b=bytes.fromhex('414F330000000001')+value(2,m['profile_code'])+value(3,str(m['profile_version']))+value(2,'CAN-001-DRAFT-1')+value(2,'SHA256')+u32(len(rs))+b''.join(rs)
 if len(b)>1000000:raise ValueError('document limit')
 return b

def need(ok,msg):
 if not ok:raise ValueError(msg)
def read_log(path):
 s=Path(path).read_text(encoding='utf-8-sig')
 need(not re.search(r'(^|\s)(ORA-|SP2-|PLS-|TNS-|LRM-|ERROR at line)',s),'Error in '+str(path))
 return s
def check_logs(main,persistent,privilege,cleanup):
 s=read_log(main);p=read_log(persistent);d=read_log(privilege);c=read_log(cleanup)
 required=json.loads((Path(__file__).resolve().parents[1]/'EXPECTED_ASSERTIONS.json').read_text())
 passes=re.findall(r'^PASS ([A-Z0-9_]+)\s*$',s,re.M)
 for x in required:need(passes.count(x)==1,'Missing/duplicate assertion '+x)
 need(s.count('SUITE_COMPLETE PM001_004')==1,'Missing suite completion')
 docs={}
 pattern=r'^EVIDENCE_BEGIN ([^\r\n]+)\r?\nJSON_BEGIN\r?\n(.*?)\r?\nJSON_END\r?\nHEX_BEGIN\r?\n(.*?)\r?\nHEX_END\r?\nEVIDENCE_END'
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
  need(len(re.findall(r'^PASS '+id_+r'\s*$',p,re.M))==1,'Missing persistent assertion '+id_)
 need('PERSISTENCE_COMPLETE PM001_004' in p,'Missing persistence completion')
 for id_ in ['D01_REAL_PRIVILEGE_ERROR','D02_EXPLICIT_DBA_ROUTE']:
  need(len(re.findall(r'^PASS '+id_+r'\s*$',d,re.M))==1,'Missing privilege assertion '+id_)
 need('PRIVILEGE_COMPLETE PM001_004' in d,'Missing privilege completion')
 need(len(re.findall(r'^PASS C01_SCHEMA_EMPTY\s*$',c,re.M))==1,'Missing cleanup assertion')
 need('CLEANUP_COMPLETE PM001_004' in c,'Missing cleanup completion')
 print('PASS',len(required),'mandatory database assertion markers;',len(stored),'individual object byte/digest proofs; persistence and cleanup markers')
 print('This verifies supplied logs. Confirm their Oracle 19c provenance and fresh-session execution separately.')
if __name__=='__main__':
 if len(sys.argv)!=5:raise SystemExit('Usage: python tools/verify_logs.py ao4_tests.log ao4_persistence.log ao4_privilege.log ao4_cleanup.log')
 check_logs(*sys.argv[1:])
