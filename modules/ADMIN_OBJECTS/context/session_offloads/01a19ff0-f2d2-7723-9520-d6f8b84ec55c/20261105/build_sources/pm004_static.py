from pathlib import Path
import re,json,hashlib,ast
OUT=Path('output/PM-001_20261103_004');SQL=OUT/'sql'
def strip_literals(s):
    i=0;out=[]
    while i<len(s):
        if s.startswith('--',i):
            e=s.find('\n',i);i=len(s) if e<0 else e;out.append('\n');continue
        if s.startswith('/*',i):
            e=s.find('*/',i+2);assert e>=0,'unclosed comment';i=e+2;out.append(' ');continue
        if s[i:i+2].lower()=="q'":
            delimiter=s[i+2];end={'[':']','{':'}','(':')','<':'>'}.get(delimiter,delimiter)+"'"
            e=s.find(end,i+3);assert e>=0,'unclosed q-string';out.append(' STRING ');i=e+2;continue
        if s[i]=="'":
            i+=1
            while True:
                assert i<len(s),'unclosed string'
                if s[i]=="'":
                    if i+1<len(s) and s[i+1]=="'":i+=2;continue
                    i+=1;break
                i+=1
            out.append(' STRING ');continue
        out.append(s[i]);i+=1
    return ''.join(out)
details=[]
for p in SQL.glob('*.sql'):
    s=p.read_text(encoding='utf-8');plain=strip_literals(s);stack=0
    for c in plain:
        if c=='(':stack+=1
        elif c==')':stack-=1;assert stack>=0,p
    assert stack==0,p
    assert max(map(len,s.splitlines()))<=2499,(p,'SQLPlus line bound')
    for target in re.findall(r'@@([^\s]+)',s):assert (p.parent/target).exists(),target
    assert not re.search(r'\b(drop\s+user|alter\s+system|truncate\s+table)\b',plain,re.I),p
    details.append({'file':p.name,'quotes_comments_parentheses':'PASS','maximum_line_characters':max(map(len,s.splitlines()))})
pkg=(SQL/'02_package.sql').read_text();body=pkg.split('create package body',1)[1]
def section(a,b):return body.split('  procedure '+a,1)[1].split('  procedure '+b,1)[0]
normal=strip_literals(section('normalize_metadata','serialize_manifest'))
serial=strip_literals(section('serialize_manifest','calculate'))
for s in [normal,serial]:assert not re.search(r'\b(select|insert|update|delete\s+from|execute\s+immediate|dbms_sql)\b',s,re.I)
assert not re.search(r'\bcommit\b',strip_literals(body),re.I)
assert 'savepoint ao4_store' in body and 'rollback to ao4_store' in body
labels=re.findall(r"insert into ao4_catalog values\('([^']+)'",(SQL/'01_setup.sql').read_text())
assert labels==(OUT/'reference/CATALOG_003.txt').read_text().splitlines()
for name in ['DECISIONS.md','REQUIREMENTS.md','OPEN_POINTS.md','SOURCE_INDEX.md']:
    assert (OUT/name).read_bytes()==(OUT/'reference'/name).read_bytes()
ref=json.loads((OUT/'reference/manifest.json').read_text(encoding='utf-8'))
for x in ref['files']:assert hashlib.sha256((OUT/x['path']).read_bytes()).hexdigest()==x['sha256']
for p in (OUT/'tools').glob('*.py'):ast.parse(p.read_text(encoding='utf-8'))
creations=set(re.findall(r'create table (ao4_\w+)', '\n'.join(p.read_text(encoding='utf-8') for p in SQL.glob('*.sql')),re.I))
cleanup=(SQL/'05_cleanup.sql').read_text().lower()
for name in creations:assert "drop_('table','"+name.lower()+"')" in cleanup,name
assert cleanup.index("drop_('table','ao4_shape')")<cleanup.index("drop_('table','ao4_t')"),'FK cleanup dependency order'
result={'status':'PASS_LIMITED_STATIC_CHECKS','not_an_oracle_compiler':True,'sql_files':details,'pure_stage_query_dml_scan':'PASS','package_no_commit_scan':'PASS','catalog_53_exact':'PASS','reference_37_hashes':'PASS','root_registers_byte_equal':'PASS','cleanup_all_created_tables':'PASS','python_tools_parse':'PASS'}
(OUT/'STATIC_CHECKS.json').write_text(json.dumps(result,indent=2)+'\n')
print('PASS limited static SQL structure, pure-stage scan, cleanup allowlist, reference hashes and Python parsing; NOT Oracle compilation')
