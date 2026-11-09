#!/usr/bin/env python3
"""Offline source/trace/integrity checks only. Never connects to Oracle or runs SQL."""
import argparse,csv,hashlib,json,pathlib,re,subprocess,sys

PKG_PATH='modules/ADMIN_LOGGER/tests/step4_20261109_001'
SOURCE_PATH='modules/ADMIN_LOGGER/src/20261109_501_DEV'
PINS={
'PACKAGE_BODY/PACKAGE-BODY_TETOOLS_ADMIN_LOGGER__20261015_500.pkb':'febb57c5aebe3ce5d23799f60c6c38f793681d00',
'PACKAGE_SPEC/PACKAGE_TETOOLS_ADMIN_LOGGER__20261015_500.pks':'9331a2756b1c2196280cda3f10bf1643285f61ab',
'PROCEDURES/20260527__ADMIN_LOGGER__001.prc':'5a5e4e3181816aa520f5067f2b8c0abd3fef63f1',
'SEQUENCE/SEQ_20261007__ADMIN_LOGGER__001.sql':'47416ff9583c32bc14cbe49007cd277f2449682b',
'TABLE/TAB_TETOOLS_ADMIN_LOGGER__20261015_202.sql':'0c112a15643c62bcf4c2d4ac37fd54e2b656a04a',
'REVISION_MANIFEST.md':'d6319dfa969770a2c9ece7be3e753febee86f5db'}

def sql_code(s):
    return re.sub(r'--[^\n]*','',s)

def check_shared_gate(s):
    first=sql_code(s).split('\n/\n',1)[0]
    assert 'SET DEFINE OFF' in first, 'substitution enabled before denial'
    assert not '&' in first, 'config substitution before G09 denial'
    assert "c_g09_status CONSTANT VARCHAR2(20) := 'NOT_GRANTED';" in first, 'G09 source denial changed'
    assert 'c_g09_reference CONSTANT VARCHAR2(4000) := NULL;' in first, 'approval reference enabled'
    assert "c_g09_status IS NULL OR c_g09_status <> 'GRANTED'" in first, 'null-unsafe approval'
    assert 'RAISE_APPLICATION_ERROR(-20909' in first, 'missing refusal'
    assert not re.search(r'\b(?:INSERT|UPDATE|DELETE|MERGE|CREATE|ALTER|DROP|TRUNCATE|COMMIT)\b',first,re.I), 'gate has writes'
    assert not re.search(r'tetools\s*\.\s*admin_logger',first,re.I), 'gate initializes logger'

def check_entry(s):
    code=sql_code(s)
    gate=code.find('@@00_safety_gate.sql')
    assert gate>=0,'missing shared gate'
    before=code[:gate]
    assert 'WHENEVER OSERROR EXIT FAILURE ROLLBACK' in before, 'OS failure is not fail-fast'
    assert 'WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK' in before, 'SQL failure is not fail-fast'
    assert not re.search(r'^\s*(?:DECLARE|BEGIN|SELECT|INSERT|UPDATE|DELETE|MERGE|CREATE|ALTER|DROP|TRUNCATE|COMMIT|ROLLBACK|EXEC(?:UTE)?|SPOOL)\b',before,re.M|re.I), 'action before gate'
    assert not re.search(r'^\s*@@',before,re.M),'other include before gate'

def verify(package,repo,ref,main,require_material_match=False):
    checks=[]
    def record(name,fn):
        try:
            value=fn();checks.append({'check':name,'status':'PASS','detail':value})
        except Exception as exc:checks.append({'check':name,'status':'FAIL','detail':str(exc)})
    def git(*args):return subprocess.check_output(['git','-C',str(repo),*args],stderr=subprocess.PIPE).decode('utf-8').strip()
    def obj(path,r=ref):return git('rev-parse',r+':'+path)
    record('source_gate_denies_before_substitution',lambda:check_shared_gate((package/'scripts/00_safety_gate.sql').read_text(encoding='utf-8')))
    entries=sorted((package/'scripts').glob('*.sql'))
    for f in entries:
        if f.name!='00_safety_gate.sql':record('entry_gate:'+f.name,lambda f=f:check_entry(f.read_text(encoding='utf-8')))
    def includes():
        out=[]
        for f in entries:
            for n,l in enumerate(f.read_text(encoding='utf-8').splitlines(),1):
                if l.startswith('@@'):
                    target=(f.parent/l[2:].strip()).resolve()
                    assert target.is_file(),str(f.name)+':'+str(n)+' missing '+str(target)
                    out.append({'script':f.name,'line':n,'target':l[2:].strip()})
        return out
    record('include_graph',includes)
    for path,pin in PINS.items():
        def pincheck(path=path,pin=pin):
            actual=obj(SOURCE_PATH+'/'+path);baseline=obj(SOURCE_PATH+'/'+path,main)
            assert actual==baseline==pin,'source pin mismatch'
            return {'expected':pin,'ref':actual,'main':baseline}
        record('pin:'+path,pincheck)
    for path in ['modules/ADMIN_LOGGER/src','COMMUNICATION_RELAY/MODULES/ADMIN_OBJECTS/RELEASES']:
        def unchanged(path=path):
            assert git('ls-tree','-r',ref,path)==git('ls-tree','-r',main,path),'source/frozen tree changed'
            return 'identical Git blob inventory'
        record('unchanged:'+path,unchanged)
    def scope():
        paths=git('diff','--name-only',main,ref).splitlines()
        allowed=['COMMUNICATION_RELAY/SESSION_REGISTRY.json','COMMUNICATION_RELAY/CHANGE_REGISTER.json','modules/ADMIN_LOGGER/OPEN_POINTS.md']
        assert all(p.startswith(PKG_PATH+'/') or p in allowed for p in paths),'out-of-scope change'
        return paths
    record('full_head_scope',scope)
    record('git_diff_whitespace',lambda:git('diff','--check',main,ref))
    cases=json.loads((package/'cases.json').read_text(encoding='utf-8'))['cases']
    ids=[c['test_id'] for c in cases]
    def casecheck():
        assert len(ids)==28 and len(set(ids))==28,'not 28 unique cases'
        assert all(c['execution_status']=='NOT_EXECUTED' for c in cases),'runtime status changed'
        for c in cases:
            for k in ['requirements','procedure','preparation_status','privileges','prerequisites','fixtures','expected','negative_and_stop','evidence','cleanup','approval']:
                assert c.get(k),(c['test_id'],k)
            for path in re.findall(r'(?:scripts/[\w.]+\.sql|[\w]+\.py|[\w]+\.json|[\w]+\.md)',c['procedure']):
                assert (package/path).is_file(),'missing case procedure '+path
        return {'cases':len(ids),'execution':'NOT_EXECUTED'}
    record('case_definitions',casecheck)
    def contracts():
        for n in range(1,7):
            hits=[c for c in cases if f'C{n:02}' in c['requirements']]
            assert len(hits)==1 and hits[0]['test_id']==f'T05-{n+1:02}','contract mapping'
            if n>1:assert hits[0]['preparation_status']=='BLOCKED','unsafe injection unblocked'
        return 'C01..C06 mapped; C02..C06 remain BLOCKED'
    record('contract_mapping',contracts)
    def results():
        rows=list(csv.DictReader((package/'results_template.csv').open(newline='',encoding='utf-8')))
        assert [r['test_id'] for r in rows]==ids,'result IDs/order differ'
        assert all(r['status']==r['execution_status']=='NOT_EXECUTED' for r in rows),'false runtime result'
        return len(rows)
    record('result_inventory',results)
    def trace():
        canonical=git('show',main+':modules/ADMIN_LOGGER/docs/reports/ADMIN_LOGGER_LDR_TRACE_20261109.md')
        text=(package/'traceability.md').read_text(encoding='utf-8')
        for l in canonical.splitlines():
            if re.match(r'\| (RAC-A-\d{3}|LOG-OPEN-\d{2}) \|',l):
                a=[x.strip() for x in l.strip('|').split('|')]
                assert '| '+a[0]+' | '+a[3]+' |' in text,'canonical meaning changed '+a[0]
                assert any(a[0] in c['requirements'] for c in cases),'risk has no case '+a[0]
        return 'all 17 canonical meanings copied; all linked to cases; blocked coverage explicit'
    record('canonical_trace',trace)
    def api():
        spec=git('show',ref+':'+SOURCE_PATH+'/PACKAGE_SPEC/PACKAGE_TETOOLS_ADMIN_LOGGER__20261015_500.pks')
        clean=re.sub(r'--[^\n]*','',spec)
        declarations=[' '.join(m.group(0).split()) for m in re.finditer(r'^\s*(FUNCTION|PROCEDURE)\s+(\w+)\b[^;]*;',clean,re.M)]
        inventory=json.loads((package/'api_inventory.json').read_text(encoding='utf-8'))
        assert declarations==[x['declaration'] for x in inventory['declarations']],'API inventory differs'
        text=(package/'scripts/41_T04_overloads.sql').read_text(encoding='utf-8')
        calls=re.findall(r'^\s*(?:l_ret:=)?tetools\.admin_logger\.(LOG_\w+)\(',text,re.M)
        assert len(calls)==45,'not 45 LOG variants'
        assert text.count("check_row('")==45 and text.count("IF l_ret IS NULL OR l_ret<>1")==9,'missing per-overload assertions'
        assert not 'LOG_DEBUG_FORCE' in calls,'invented API'
        return {'public_declarations':len(declarations),'log_variants':len(calls),'return_assertions':9}
    record('api_and_overload_assertions',api)
    def c01():
        s=(package/'scripts/51_C01_caller_rollback.sql').read_text(encoding='utf-8')
        assert s.index("toggle_logging('ON','T')")<s.index('INSERT INTO tetools.step4_business_fixture'),'setup after business DML'
        assert 'C01 FAIL caller business row committed' in s and 'C01 FAIL missing/duplicate persisted autonomous diagnostic' in s,'half-contract missing'
        assert 'logsession_id=l_sid' in s and 'DBMS_LOB.COMPARE' in s,'diagnostic not exact'
        return 'both halves, unique marker/session and controlled TABLE configuration asserted'
    record('c01_two_sided_assertions',c01)
    def material():
        # Audit output files intentionally excluded from content hash comparison to avoid self-reference.
        out=[]
        for f in sorted(package.rglob('*')):
            if not f.is_file() or '__pycache__' in f.parts or f.suffix=='.pyc':continue
            path=f.relative_to(package).as_posix()
            if path in ['static_evidence.json','correction_matrix.md']:continue
            raw=f.read_bytes(); sha=hashlib.sha1(b'blob '+str(len(raw)).encode()+b'\0'+raw).hexdigest()
            try:published=obj(PKG_PATH+'/'+path)
            except subprocess.CalledProcessError:published=None
            out.append({'path':path,'sha256':hashlib.sha256(raw).hexdigest(),'git_blob':sha,'ref_blob':published,'matches_ref':sha==published})
        if require_material_match:
            assert all(x['matches_ref'] for x in out),'local material differs from exact reference head'
        return out
    record('material_inventory',material)
    return {'verification':'STATIC_SOURCE_ONLY','require_material_match':require_material_match,'ref':ref,'main':main,'oracle_connection':'NOT_USED','oracle_execution':'NOT_EXECUTED',
      'g09':'NOT_GRANTED','independent_review':'PENDING_DIFFERENT_REVIEWER','checks':checks,
      'static_status':'PASS' if all(c['status']=='PASS' for c in checks) else 'FAIL',
      'limitations':['No Oracle parser/compiler/SQLPlus/SQLcl/runtime/RAC/recovery execution',
       'Future execution-enabled authorization artifact not supplied or approved',
       'Audit output files excluded from their own material comparison; final full-head Git inventory is separate']}

def main():
    a=argparse.ArgumentParser(description=__doc__);a.add_argument('--repo',type=pathlib.Path,required=True)
    a.add_argument('--ref',required=True);a.add_argument('--main',required=True);a.add_argument('--out',type=pathlib.Path,required=True)
    a.add_argument('--require-material-match',action='store_true',help='Fail if local source differs from the published exact head')
    v=a.parse_args();j=verify(pathlib.Path(__file__).resolve().parent,v.repo,v.ref,v.main,v.require_material_match)
    v.out.write_text(json.dumps(j,indent=2)+'\n',encoding='utf-8')
    for c in j['checks']:print(c['status'],c['check'],c['detail'] if c['status']=='FAIL' else '')
    print('STATIC',j['static_status'],'; Oracle NOT_EXECUTED; G09 NOT_GRANTED')
    sys.exit(0 if j['static_status']=='PASS' else 1)
if __name__=='__main__':main()
