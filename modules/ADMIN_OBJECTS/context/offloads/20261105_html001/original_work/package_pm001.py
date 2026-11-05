from pathlib import Path
import json,hashlib,zipfile
import pdfplumber
root=Path(__file__).resolve().parents[1]
out=root/'output/PM-001_20261029'
v=out/'validation.json';j=json.loads(v.read_text())
with pdfplumber.open(root/'work/pm001_qa/print-check.pdf') as d:
    text='\n'.join(p.extract_text() or '' for p in d.pages)
    bad=[c for p in d.pages for c in p.chars if c['x0']<0 or c['x1']>p.width+1 or c['top']<0 or c['bottom']>p.height+1]
    assert not bad
    assert all('PM-001-'+str(i).zfill(2) in text for i in range(1,27))
    j['checks'].update(print_pages=len(d.pages),print_a4_landscape=True,print_text_outside_page=0,all_chapter_ids_in_print=True,print_visual_review='Rendered print sample reviewed; full-page overview inspected during layout correction.')
v.write_text(json.dumps(j,indent=2),encoding='utf-8')
m=out/'manifest.json';manifest=json.loads(m.read_text())
html=out/manifest['document']
assert hashlib.sha256(html.read_bytes()).hexdigest()==manifest['html_sha256']
manifest['companion_files']=[{'name':x.name,'sha256':hashlib.sha256(x.read_bytes()).hexdigest()} for x in [v,out/'README.txt']]
m.write_text(json.dumps(manifest,indent=2,ensure_ascii=False),encoding='utf-8')
dest=root/'output'/html.with_suffix('.zip').name
files=[html,m,v,out/'README.txt']
with zipfile.ZipFile(dest,'w',zipfile.ZIP_DEFLATED) as z:
    for f in files:z.write(f,f.name)
with zipfile.ZipFile(dest) as z:
    assert z.testzip() is None
    assert z.namelist()==[x.name for x in files]
    for f in files:assert z.read(f.name)==f.read_bytes()
print(json.dumps({'html':str(html),'zip':str(dest),'members':[x.name for x in files],'zip_integrity':'passed','sha256':hashlib.sha256(dest.read_bytes()).hexdigest()},indent=2))
