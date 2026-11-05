from pathlib import Path
from xml.sax.saxutils import escape
import re, json, hashlib
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Preformatted, PageBreak
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib import colors
root=Path('output/TETOOLS_CONFIGURATION_20261104')
pdfmetrics.registerFont(TTFont('CourierNew','C:/Windows/Fonts/cour.ttf'))
styles=getSampleStyleSheet()
styles.add(ParagraphStyle(name='Code11',fontName='CourierNew',fontSize=11,leading=14,spaceAfter=8))
styles['BodyText'].fontSize=10.5
styles['BodyText'].leading=15
names=['README.md','INVENTORY_AND_SOURCES.md','LOCAL_GIT_WINDOWS_SETUP.md','GITHUB_SETUP.md','CHATGPT_PROJECT_INSTRUCTIONS.md','CHATGPT_CUSTOM_INSTRUCTIONS.md','CODEX_CUSTOM_INSTRUCTIONS.md','AGENTS_GUIDE.md','CODEX_VERIFICATION.md','RELAY_WORKFLOW.md']
story=[]
for ix,name in enumerate(names):
 if ix: story.append(PageBreak())
 code=False; buf=[]; para=[]
 def flush():
  if para:
   text=escape(' '.join(para))
   text=re.sub(r'\[([^\]]+)\]\(([^)]+)\)',r'\1 (\2)',text)
   text=text.replace('`','')
   story.append(Paragraph(text,styles['BodyText'])); para.clear()
 for line in (root/name).read_text(encoding='utf-8').splitlines():
  if line.startswith('```'):
   flush()
   if code:
    # Wrap at spaces without changing the canonical Markdown commands.
    import textwrap
    wrapped=[]
    for item in buf: wrapped.extend(textwrap.wrap(item,width=110,break_long_words=False,break_on_hyphens=False) or [''])
    story.append(Preformatted('\n'.join(wrapped),styles['Code11']));buf=[]
   code=not code
  elif code: buf.append(line)
  elif line.startswith('#'):
   flush();level=len(line)-len(line.lstrip('#'));story.append(Paragraph(escape(line.lstrip('# ')),styles['Heading1' if level==1 else 'Heading2']))
  elif not line.strip(): flush();story.append(Spacer(1,5))
  else:
   if re.match(r'^(\d+\. |- )',line): flush()
   para.append(line)
 flush()
def footer(c,d):
 c.setFont('Helvetica',8); c.setFillColor(colors.HexColor('#444444'))
 c.drawString(42,24,'PL/SQL TETOOLS | CFG-20261104-001 | PROPOSED')
 c.drawRightString(800,24,str(d.page))
SimpleDocTemplate(str(root/'TETOOLS_CONFIGURATION.pdf'),pagesize=(842,740),rightMargin=42,leftMargin=42,topMargin=35,bottomMargin=40).build(story,onFirstPage=footer,onLaterPages=footer)
manifest={p.name:{'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'bytes':p.stat().st_size} for p in sorted(root.iterdir()) if p.is_file() and p.name!='MANIFEST.json'}
(root/'MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
from pypdf import PdfReader
print('pages',len(PdfReader(root/'TETOOLS_CONFIGURATION.pdf').pages))
