from pathlib import Path
import importlib.util,json,copy,contextlib,io
ROOT=Path('output/PM-001_20261103_004')
spec=importlib.util.spec_from_file_location('v',ROOT/'tools/verify_logs.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
temp=Path('tmp/pm004_checker_selftest');temp.mkdir(parents=True,exist_ok=True)
ref=json.loads(next((ROOT/'reference/baseline_003').glob('*objectmanifest_voorbeeld*')).read_text(encoding='utf-8'))
def evidence(name,doc):
    wire=v.encode(doc);doc=copy.deepcopy(doc);doc['sha256']=v.hashlib.sha256(wire).hexdigest().upper()
    return '\n'.join(['EVIDENCE_BEGIN '+name,'JSON_BEGIN',json.dumps(doc),'JSON_END','HEX_BEGIN',wire.hex(),'HEX_END','EVIDENCE_END'])
docs=[('CDB_TABLE',ref),('DBA_TABLE',ref),('DATATYPES',ref),('LONG_CHECK',ref),('STORED_TABLE_'+ref['source']['table_name'],ref)]
for r in ref['records']:
    if r['component'] not in ('CONSTRAINTS','INDEX'):continue
    docs.append(('STORED_'+r['component']+'_'+r['source_identity'],dict(profile_code='INDEX_CORE' if r['component']=='INDEX' else 'CONSTRAINT_CORE',profile_version=1,canonical_version='CAN-001-DRAFT-1',records=[r])))
markers=['PASS '+x for x in json.loads((ROOT/'EXPECTED_ASSERTIONS.json').read_text())]
for name,doc in docs:
    if name.startswith('STORED_'):
        markers.extend(['PASS ROW_HASH_'+name[7:],'PASS ROW_META_'+name[7:]])
main='\n'.join(markers+[evidence(*x) for x in docs]+['SUITE_COMPLETE PM001_004'])
persist='\n'.join(['PASS '+x for x in ['P01_PERSISTENT_OBJECTS','P02_PERSISTENT_DIGESTS','P03_PERSISTENT_FINDINGS']]+['PERSISTENCE_COMPLETE PM001_004'])
privilege='PASS D01_REAL_PRIVILEGE_ERROR\nPASS D02_EXPLICIT_DBA_ROUTE\nPRIVILEGE_COMPLETE PM001_004'
cleanup='PASS C01_SCHEMA_EMPTY\nCLEANUP_COMPLETE PM001_004'
paths=[temp/x for x in ['synthetic_main.txt','synthetic_persist.txt','synthetic_privilege.txt','synthetic_cleanup.txt']]
for p,s in zip(paths,[main,persist,privilege,cleanup]):p.write_text(s,encoding='utf-8')
with contextlib.redirect_stdout(io.StringIO()):v.check_logs(*paths)
mutations=[main.replace(markers[0]+'\n','',1),main.replace('414f330000000001','004f330000000001',1),main.replace('SUITE_COMPLETE PM001_004',''),main+'\nORA-00942',main+'\n'+markers[1]]
for s in mutations:
    paths[0].write_text(s,encoding='utf-8')
    try:
        with contextlib.redirect_stdout(io.StringIO()):v.check_logs(*paths)
    except ValueError:pass
    else:raise AssertionError('Verifier accepted a deliberately damaged synthetic log')
print('PASS checker self-test: 1 valid synthetic input; 5 damaged synthetic inputs rejected. NOT Oracle evidence.')
