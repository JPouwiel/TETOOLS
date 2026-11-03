#!/usr/bin/env python3
"""Verify imported file integrity; does not connect to Oracle or GitHub."""
import base64
import hashlib
import json
import pathlib
import re
import zipfile
from html.parser import HTMLParser
from urllib.parse import unquote
ROOT = pathlib.Path(__file__).resolve().parents[1]

def digest(data):
    return hashlib.sha256(data).hexdigest()

class Page(HTMLParser):
    def __init__(self, text):
        super().__init__(); self.ids=[]; self.links=[]; self.downloads=[]
        self.feed(text)
    def handle_starttag(self, tag, attrs):
        a=dict(attrs)
        if 'id' in a: self.ids.append(a['id'])
        if tag=='a' and 'href' in a:
            self.links.append(a['href'])
            if a.get('download'): self.downloads.append((a['download'],a['href']))

def main():
    manifest=json.loads((ROOT/'SOURCE_MANIFEST.json').read_text())
    entries=manifest['files']; assert len({e['path'] for e in entries})==len(entries)
    for entry in entries:
        p=ROOT/entry['path']; assert p.is_file(),p
        data=p.read_bytes(); assert digest(data)==entry['sha256'],p
        assert len(data)==entry['size_bytes'],p
    actual={p.relative_to(ROOT).as_posix() for p in ROOT.rglob('*') if p.is_file()}
    assert actual=={e['path'] for e in entries}|{'SOURCE_MANIFEST.json'},actual
    archive=ROOT/'archives/TETOOLS.ADMIN_LOGGER_20261015_500.zip'
    assert digest(archive.read_bytes())==manifest['latest_uploaded_archive_sha256']
    with zipfile.ZipFile(archive) as z:
        assert z.testzip() is None
        for n in z.namelist():
            if n.endswith('/'): continue
            rel=pathlib.PurePosixPath(n).parts[1:]
            assert (ROOT/'src/20261015_500'/pathlib.Path(*rel)).read_bytes()==z.read(n),n
    reports=ROOT/'docs/reports'; pages={p.name:Page(p.read_text()) for p in reports.glob('*.html')}
    for name,page in pages.items():
        assert len(page.ids)==len(set(page.ids)),name
        for href in page.links:
            if href.startswith(('http:','https:','data:','mailto:')): continue
            file,sep,anchor=href.partition('#')
            target=pages[file] if file else page
            if anchor: assert unquote(anchor) in target.ids,(name,href)
    proposal=pages['20261013__PLSQL__TETOOLS_ADMIN_LOGGER__oplossingen_20261013_500_STE_027.html']
    downloads=dict(proposal.downloads)
    for p in (ROOT/'proposals/20261013_500_PROPOSAL_027').iterdir():
        if not p.is_file(): continue
        href=downloads[p.name]; assert href.startswith('data:') and ';base64,' in href
        assert base64.b64decode(href.split(',',1)[1])==p.read_bytes(),p.name
    for p in ROOT.rglob('*'):
        if p.is_file() and p.suffix.lower() in {'.sql','.pkb','.pks','.prc','.md','.json','.html'}:
            text=p.read_text()
            assert not re.search(r"user_passwd\s+varchar2\(128\)\s*:=\s*'oracle'",text,re.I),p
    print(f'PASS: {len(entries)} manifest files; 5 extracted original source files; '
          f'{len(pages)} HTML reports and links; proposal payloads; credential redaction. Oracle NOT_EXECUTED.')

if __name__=='__main__':
    main()
