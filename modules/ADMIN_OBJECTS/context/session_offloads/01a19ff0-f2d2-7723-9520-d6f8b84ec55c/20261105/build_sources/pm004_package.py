from pathlib import Path
from html.parser import HTMLParser
import json,hashlib,zipfile,datetime
ROOT=Path.cwd();OUT=ROOT/'output/PM-001_20261103_004'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
class Links(HTMLParser):
    def __init__(self):super().__init__();self.links=[];self.ids=set()
    def handle_starttag(self,tag,attrs):
        attrs=dict(attrs)
        if 'id' in attrs:self.ids.add(attrs['id'])
        if tag=='a' and 'href' in attrs:self.links.append(attrs['href'])
parser=Links();parser.feed((OUT/'DESIGN.html').read_text(encoding='utf-8'))
for link in parser.links:
    if link.startswith('#'):assert link[1:] in parser.ids,link
    elif not link.startswith('http'):assert (OUT/link).exists(),link
assert len(json.loads((OUT/'EXPECTED_ASSERTIONS.json').read_text()))==63
validation={
 'design_id':'PM-001','revision':'004','date':'2026-11-03',
 'reference_first':True,'controlled_reference_manifest_sha256':sha(OUT/'reference/manifest.json'),
 'oracle_scope':'Oracle Database 19c Enterprise Edition, local disposable PDB schema',
 'oracle_compilation':'NOT_EXECUTED','oracle_runtime':'NOT_EXECUTED',
 'database_connection_available':False,'database_logs_delivered':False,
 'historical_context_complete':False,
 'local_checks':{
  'reference_zip_manifest_entries_verified':17,'historical_file_hashes_verified':12,
  'catalog_exact_unique_labels':53,'frozen_reference_entries_verified':37,
  'register_copies_byte_equal':True,
  'fixed_reference_records':9,'fixed_reference_bytes':1228,
  'fixed_reference_sha256':'1a1e83b0450bc00a53e476d7d15fa8379ea0b07aea999440931f7fa15bd34af1',
  'static_sql_structure_and_pure_stage_scans':'PASS_LIMITED_NOT_A_COMPILER',
  'cleanup_fixed_allowlist_and_fk_dependency_order':'PASS_STATIC_ONLY',
  'fixed_T_assertions_in_inventory':63,'additional_assertions':'ROW_HASH/ROW_META each object; P01-P03; D01-D02; C01',
  'independent_checker_selftest':{'valid_synthetic_input_accepted':1,'damaged_synthetic_inputs_rejected':5,'oracle_evidence':False},
  'python_tool_syntax':'PASS','html_local_links_and_anchors':'PASS',
  'html_browser_runtime':'NOT_EXECUTED','pdf_pages':13,'pdf_rendered_all_pages':True,
  'pdf_contact_sheet_visual_review':'PASS; all pages plus full-size runbook page reviewed',
 },
 'acceptance_gates':{'G0':'LOCAL_PASS_BOUNDED_SOURCES','G1':'LOCAL_PASS_LIMITED_STATIC_CHECKS','G2':'NOT_EXECUTED','G3':'NOT_EXECUTED','G4':'NOT_EXECUTED','G5':'REGIE_REVIEW_REQUIRED_NO_AUTOMATIC_APPROVAL'},
 'limits':['Not an Oracle compiler','No successful Oracle compilation or runtime claim','No fabricated database logs','Missing original review rounds and complete older chat history','Draft profile and CAN-001 decisions remain open','Not a production installer or upgrade']}
(OUT/'VALIDATION.json').write_text(json.dumps(validation,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
# Do not package interpreter-generated files as delivery artifacts.
files=[p for p in sorted(OUT.rglob('*')) if p.is_file() and '__pycache__' not in p.parts and p.name not in ('SHA256SUMS.txt',) and p!=OUT/'manifest.json']
manifest={'design_id':'PM-001','revision':'004','predecessor_revision':'003','controlled_reference_version':'v1',
 'controlled_reference_manifest_sha256':sha(OUT/'reference/manifest.json'),'oracle_runtime_validated':False,
 'history_complete':False,'deviations':'DEVIATIONS.md','validation':'VALIDATION.json',
 'files':[{'path':p.relative_to(OUT).as_posix(),'bytes':p.stat().st_size,'sha256':sha(p)} for p in files],
 'self_hash_policy':'This manifest is excluded from its own file list and hashed by SHA256SUMS.txt. SHA256SUMS.txt is excluded from itself. The ZIP is hashed externally.'}
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
files.append(OUT/'manifest.json')
(OUT/'SHA256SUMS.txt').write_text(''.join(sha(p)+'  '+p.relative_to(OUT).as_posix()+'\n' for p in sorted(files)),encoding='ascii')
zip_path=ROOT/'output/20261103__PLSQL__TETOOLS_ADMIN_OBJECTS__PM001_PoC_004.zip'
with zipfile.ZipFile(zip_path,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as z:
    for p in sorted(files+[OUT/'SHA256SUMS.txt']):z.write(p,p.relative_to(OUT).as_posix())
with zipfile.ZipFile(zip_path) as z:
    assert z.testzip() is None
    for e in manifest['files']:assert hashlib.sha256(z.read(e['path'])).hexdigest()==e['sha256']
ref_zip=ROOT/'output/20261103__PLSQL__TETOOLS_ADMIN_OBJECTS__REFERENCE_004.zip'
with zipfile.ZipFile(ref_zip,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as z:
    for p in sorted((OUT/'reference').rglob('*')):
        if p.is_file():z.write(p,p.relative_to(OUT).as_posix())
    for n in ['REFERENCE_CHECK.md','REGIE_RETRIEVAL_20261103.json']:
        z.write(OUT/n,n)
    z.writestr('README.txt','Controlled implementation baseline v1: read reference/DECISIONS.md, REQUIREMENTS.md, OPEN_POINTS.md, SOURCE_INDEX.md and manifest.json. Paths in reference/manifest.json resolve from this ZIP root. No Oracle-runtime validation. Read REFERENCE_CHECK.md and missing-history entries. The retrieval snapshot does not supply the missing original reviews.\n')
with zipfile.ZipFile(ref_zip) as z:
    assert z.testzip() is None
    ref=json.loads(z.read('reference/manifest.json'))
    for e in ref['files']:assert hashlib.sha256(z.read(e['path'])).hexdigest()==e['sha256']
for p in [zip_path,ref_zip]:p.with_suffix('.sha256.txt').write_text(sha(p)+'  '+p.name+'\n',encoding='ascii')
print(json.dumps({'delivery_zip':str(zip_path),'sha256':sha(zip_path),'bytes':zip_path.stat().st_size,'delivery_entries':len(files)+1,'reference_zip':str(ref_zip)},indent=2))
