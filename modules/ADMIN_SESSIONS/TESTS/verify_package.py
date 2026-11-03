"""Read-only publication integrity checks; no Oracle connection or execution."""
from pathlib import Path
import hashlib,json,re
from html.parser import HTMLParser
from urllib.parse import unquote,urlsplit

def verify(root):
 m=json.loads((root/'manifest.json').read_text(encoding='utf-8'))
 for f in m['files']:
  p=root/f['path'];b=p.read_bytes()
  assert len(b)==f['bytes'],f['path']
  assert hashlib.sha256(b).hexdigest()==f['sha256'],f['path']
 actual={p.relative_to(root).as_posix() for p in root.rglob('*') if p.is_file() and '__pycache__' not in p.parts}
 assert actual=={x['path'] for x in m['files']}|{'manifest.json'},'unindexed files'
 for p in root.rglob('*.json'):json.loads(p.read_text(encoding='utf-8'))
 class Page(HTMLParser):
  def __init__(self,s):super().__init__();self.ids=[];self.links=[];self.feed(s)
  def handle_starttag(self,tag,attrs):
   a=dict(attrs)
   if 'id' in a:self.ids.append(a['id'])
   if tag=='a' and 'href' in a:self.links.append(a['href'])
   if tag in ('script','img','link'):
    assert not a.get('src',a.get('href','')).startswith(('http:','https:')),'remote required asset'
 pages={p:Page(p.read_text(encoding='utf-8')) for p in root.rglob('*.html')}
 links=0
 for p,parser in pages.items():
  assert len(parser.ids)==len(set(parser.ids)),p
  assert all(f'AS-{i:02}' in parser.ids for i in range(1,25)),p
  for href in parser.links:
   u=urlsplit(href)
   if u.scheme or u.netloc:continue
   dest=(p.parent/unquote(u.path)).resolve() if u.path else p
   assert dest.exists(),(p,href)
   if u.fragment:assert dest in pages and unquote(u.fragment) in pages[dest].ids,(p,href)
   links+=1
 return dict(status='PASS',manifest_entries=len(m['files']),html_files=len(pages),html_links_checked=links,json_parse='PASS',oracle='NOT_EXECUTED')

if __name__=='__main__':
 print(json.dumps(verify(Path(__file__).resolve().parents[1]),indent=2))
