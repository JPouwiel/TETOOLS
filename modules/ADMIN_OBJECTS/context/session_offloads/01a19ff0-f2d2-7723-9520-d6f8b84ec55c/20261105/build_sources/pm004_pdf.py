from pathlib import Path
from reportlab.platypus import SimpleDocTemplate,Paragraph,Spacer,PageBreak,Preformatted,KeepTogether
from reportlab.lib.styles import getSampleStyleSheet,ParagraphStyle
from reportlab.lib.enums import TA_LEFT
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from xml.sax.saxutils import escape
import re,textwrap
OUT=Path('output/PM-001_20261103_004')
pdfmetrics.registerFont(TTFont('ArialLocal','C:/Windows/Fonts/arial.ttf'))
pdfmetrics.registerFont(TTFont('ArialBoldLocal','C:/Windows/Fonts/arialbd.ttf'))
pdfmetrics.registerFont(TTFont('CourierLocal','C:/Windows/Fonts/cour.ttf'))
styles=getSampleStyleSheet()
styles.add(ParagraphStyle(name='BodyLocal',fontName='ArialLocal',fontSize=10,leading=13.8,spaceAfter=7,splitLongWords=True))
styles.add(ParagraphStyle(name='RowLocal',parent=styles['BodyLocal'],fontSize=9,leading=12,spaceAfter=5,leftIndent=7,borderPadding=3,borderColor=colors.HexColor('#dce3e8'),borderWidth=.35))
styles.add(ParagraphStyle(name='H1Local',fontName='ArialBoldLocal',fontSize=21,leading=25,spaceAfter=17,textColor=colors.HexColor('#16485d'),keepWithNext=True))
styles.add(ParagraphStyle(name='H2Local',fontName='ArialBoldLocal',fontSize=14,leading=18,spaceBefore=14,spaceAfter=8,textColor=colors.HexColor('#16485d'),keepWithNext=True))
styles.add(ParagraphStyle(name='CodeLocal',fontName='CourierLocal',fontSize=11,leading=14,spaceAfter=10))
story=[]
def para(s,style='BodyLocal'):
    s=s.replace('\u2011','-').replace('\u2013','-').replace('\u2014','-')
    story.append(Paragraph(escape(s),styles[style]))
for section,name in enumerate(['DESIGN.md','REFERENCE_CHECK.md','DECISIONS.md','REQUIREMENTS.md','OPEN_POINTS.md','SOURCE_INDEX.md','DEVIATIONS.md','RUNBOOK.md']):
    if section in (1,7):story.append(PageBreak())
    elif section:story.append(Spacer(1,18))
    code=False;buf=[]
    for line in (OUT/name).read_text(encoding='utf-8').splitlines():
        if line.startswith('```'):
            if code:
                # Text only; code font is Courier New 11 pt, without syntax colors.
                lines=[]
                for row in buf:lines.extend(textwrap.wrap(row,width=74,replace_whitespace=False,drop_whitespace=False) or [''])
                story.append(Preformatted('\n'.join(lines),styles['CodeLocal']));buf=[]
            code=not code;continue
        if code:buf.append(line);continue
        if line.startswith('# '):para(line[2:],'H1Local')
        elif line.startswith('## '):para(line[3:],'H2Local')
        elif line.startswith('|'):
            if re.fullmatch(r'[| :\-]+',line):continue
            cells=[x.strip() for x in line.strip('|').split('|')]
            para(' | '.join(cells),'RowLocal')
        elif line:para(line)
def footer(c,d):
    w,h=A4;c.setStrokeColor(colors.HexColor('#bdcbd4'));c.line(44,39,w-44,39)
    c.setFont('ArialLocal',8);c.setFillColor(colors.HexColor('#47616f'))
    c.drawString(44,27,'TETOOLS ADMIN_OBJECTS | PM-001 / 004 | Oracle runtime: NOT_EXECUTED')
    c.drawRightString(w-44,27,str(d.page))
doc=SimpleDocTemplate(str(OUT/'PM001_004.pdf'),pagesize=A4,rightMargin=44,leftMargin=44,topMargin=44,bottomMargin=53,title='TETOOLS ADMIN_OBJECTS PM-001 revisie 004',author='PL/SQL TETOOLS')
doc.build(story,onFirstPage=footer,onLaterPages=footer)
print('Created',OUT/'PM001_004.pdf')
