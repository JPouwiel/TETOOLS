import hashlib,json,sys
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
