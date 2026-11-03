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
def check_log(path):
 s=Path(path).read_text(encoding='utf-8-sig')
 if 'ORA-' in s or 'SP2-' in s:raise ValueError('Oracle/SQLPlus error in test log')
 if 'PASS complete bounded test sequence' not in s:raise ValueError('test sequence incomplete')
 def section(begin,end):return s.split(begin,1)[1].split(end,1)[0]
 m=json.loads(''.join(section('MANIFEST_BEGIN','MANIFEST_END').splitlines()))
 actual=bytes.fromhex(section('CANONICAL_BEGIN','CANONICAL_END'))
 expected=encode(m)
 assert actual==expected,'Oracle bytes differ from independent encoder'
 assert hashlib.sha256(actual).hexdigest().upper()==m['sha256'],'SHA256 mismatch'
 print('PASS independent bytes and SHA256;',len(actual),'canonical bytes')
if __name__=='__main__':
 if len(sys.argv)!=2:raise SystemExit('Provide ao3_test_results.log (UTF-8).')
 check_log(sys.argv[1])
