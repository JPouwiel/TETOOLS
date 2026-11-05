from pathlib import Path
import json,csv,html,re,shutil
OUT=Path('output/PM-001_20261103_004');REF=OUT/'reference'
for name in ['DECISIONS.md','REQUIREMENTS.md','OPEN_POINTS.md','SOURCE_INDEX.md']:
    shutil.copyfile(REF/name,OUT/name)
def put(name,text):(OUT/name).write_text(text.strip()+'\n',encoding='utf-8')
put('README.md','''# TETOOLS ADMIN_OBJECTS PM-001 revisie 004
Oracle Database 19c Enterprise Edition - disposable lokaal PDB-schema.

Start met RUNBOOK.md. De gecontroleerde basis staat in reference/manifest.json; lees DECISIONS.md, REQUIREMENTS.md, OPEN_POINTS.md en SOURCE_INDEX.md. REFERENCE_CHECK.md beschrijft de uitgevoerde broncontrole; DEVIATIONS.md registreert de implementatiekeuzes. DESIGN.html is het offline ontwerp met actuele SQL en oorspronkelijke 003-verwijzingen. PM001_004.pdf bevat ontwerp, runbook, registers en bewijsgrenzen; exacte uitvoerbare code staat onder sql/.

Status: code en tests opgeleverd, lokale statische controles uitgevoerd; Oracle-compilatie en runtime NOT_EXECUTED. G2-G4 zijn pas geslaagd na echte Oracle-logs. Geen productie-upgrade, geen installatiehash, geen uitvoeringsmodi.

SQL-volgorde: 00_install.sql -> 03_tests.sql -> nieuwe verbinding: 04_verify_persistence.sql -> DBA revoke CDB_TABLES, nieuwe verbinding: 06_privilege_error.sql -> DBA restore -> 05_cleanup.sql. Volg het runbook voor exacte verbinding, rechten en logcontrole.

De originele ZIP 003 is bytegelijk meegeleverd. Historische bronvolledigheid is begrensd: oorspronkelijke reviewrondes en oudere regieturns ontbreken. Geen Oracle-log is gefabriceerd of als geslaagd bijgevoegd.
''')
mapping=[
('R01','D02/D18','reference/manifest.json; sql/01_setup.sql','G0; T03','SOURCE_CHECKED'),
('R02','D07','sql/02_package.sql extract_metadata','T16','IMPLEMENTED_NOT_RUN'),
('R03','D05/D07','sql/02_package.sql normalize_metadata','T17/T18/T21-T24','IMPLEMENTED_NOT_RUN'),
('R04','D06/D07','sql/02_package.sql serialize_manifest','T05-T13/T19/T52-T57/T63; tools/verify_logs.py','IMPLEMENTED_NOT_RUN'),
('R05','D07/D09','sql/02_package.sql store_observations','T30-T40','IMPLEMENTED_NOT_RUN'),
('R06','D12','sql/02_package.sql preflight','T41-T49; D01/D02','IMPLEMENTED_NOT_RUN'),
('R07','D10/D12','sql/01_setup.sql ao4_finding; package preflight','T43-T47/P03','IMPLEMENTED_NOT_RUN'),
('R08','D08','package extract_metadata; explicit route selection','T14; D01/D02; byteproof CDB_TABLE/DBA_TABLE','IMPLEMENTED_NOT_RUN'),
('R09','D15','sql/03_tests.sql; 03_reference_vector.sql','T01-T29/T51-T63','IMPLEMENTED_NOT_RUN'),
('R10','D09/D15','sql/03_tests.sql; tools/verify_logs.py','T30-T32; ROW_HASH/ROW_META; stored byteproofs','IMPLEMENTED_NOT_RUN'),
('R11','D15','sql/03_tests.sql;04_verify_persistence.sql;05_cleanup.sql','T33-T40/T49/P01-P03/C01','IMPLEMENTED_NOT_RUN'),
('R12','D01/D15','sql/00_privileges.sql;00_install.sql;RUNBOOK.md','G2/G3/G4','DELIVERED_NOT_RUN'),
('R13','D18','DESIGN.html;PM001_004.pdf;registers;manifest.json','G0/G1; verify_integrity.py','DELIVERED'),
('R14','D15','VALIDATION.json;TEST_RESULTS.csv;RUNBOOK.md','Oracle runtime fields false/NOT_EXECUTED','ENFORCED_IN_REPORTING'),
('R15','D09/D13/D14','DECISIONS.md;DEVIATIONS.md; package bounded API','static scope scan; no installer mode API','SCOPE_PRESERVED'),
('R16','D18','DEVIATIONS.md K01-K16;REFERENCE_CHECK.md','reference hashes retained; root register byte equality','REGISTERED')]
with (OUT/'TRACEABILITY.csv').open('w',newline='',encoding='utf-8') as f:
    w=csv.writer(f);w.writerow(['requirement','decisions','implementation','assertion_or_gate','status']);w.writerows(mapping)
ids=json.loads((OUT/'EXPECTED_ASSERTIONS.json').read_text())
with (OUT/'TEST_RESULTS.csv').open('w',newline='',encoding='utf-8') as f:
    w=csv.writer(f);w.writerow(['test_id','expected','actual','evidence'])
    for id_ in ids:w.writerow([id_,'assertion true / PASS '+id_,'NOT_EXECUTED','Oracle 19c required; sql/03_tests.sql or 03_reference_vector.sql'])
    for id_ in ['ROW_HASH_EACH_STORED_OBJECT','ROW_META_EACH_STORED_OBJECT','P01_PERSISTENT_OBJECTS','P02_PERSISTENT_DIGESTS','P03_PERSISTENT_FINDINGS','D01_REAL_PRIVILEGE_ERROR','D02_EXPLICIT_DBA_ROUTE','C01_SCHEMA_EMPTY']:
        w.writerow([id_,'assertion true / PASS','NOT_EXECUTED','Oracle 19c required; see RUNBOOK.md'])
put('DESIGN.md','''# PM-001 revisie 004 - actueel ontwerp
3 november 2026 | Oracle Database 19c EE | opvolger van 003

## PM-001-36 - Referentie en voorrang
De vooraf gecontroleerde reference/manifest.json v1 is de enige inhoudelijke besluitenbasis. De vier registers zijn in de root bytegelijk gekopieerd. De oorspronkelijke revisie 003 en historische bronnen blijven ongewijzigd beschikbaar onder reference/. H28-H35 uit 003 bepalen de behouden profiel-/protocolregels; 004 vervangt uitsluitend de implementatie en testdekking voor B03/B04/B07 zoals geregistreerd in DEVIATIONS.md. H01-H27 blijven historie. De concrete profielinvulling en CAN-001 zijn nog voorstellen; de architectuurscheiding en afwijzing van de installatiehash zijn besluiten.

## PM-001-37 - Testbare interfaces (B03)
extract_metadata(table, source) retourneert METADATA_V1: eigenaar, tabel, bronroute, container, instance/versie en acht datasets met ruwe Oraclewaarden. Elke dataset bevat records met afzonderlijke NUMBER- en VARCHAR2-cellen. Alleen de extractor leest SYS.CDB_/DBA_ en GV_$INSTANCE. Identifiers zijn vast uit een allowlist; eigenaar/tabel/container zijn binds. De owner is de package-eigenaar binnen definerrechten; geen vrije cross-schemaextractie.

normalize_metadata(dataset) retourneert een JSON-CLOB met genormaliseerde getypeerde veldrecords. Het doet geen dictionaryquery, opslag of hashing. De 003-regels blijven identiek voor geldige invoer. Ordered-column HEX-waarden blijven de bestaande profielgrammatica en gebruiken de gedeelde pure value_frame-helper. De test wijzigt een kopie van de raw dataset; de normalizer moet die wijziging behandelen zonder opnieuw de dictionary te lezen.

serialize_manifest(manifest) retourneert BLOB en SHA-256. Het valideert de profieltupel, canonical version, recordaantallen, veld-ID-volgorde, tags, JSON-null/tekst en bytegrenzen, sorteert de volledige records unsigned binair en schrijft de CAN-001-header en records. Het doet geen dictionaryquery of DML. calculate coördineert de drie stappen en voegt alleen de digest aan de diagnostische manifest-JSON toe.

store_observations(table, source, release) maakt één verse extractie via calculate, registreert de TABLE_CORE/2-observatie en serialiseert ieder constraint/index-record afzonderlijk als CONSTRAINT_CORE/1 of INDEX_CORE/1. Het leest geen metadata opnieuw per kind. Iedere individuele manifest/digest krijgt een releasekoppeling. De interne savepoint maakt de nieuwe set atomair zonder callerwerk te committen. Duplicaatsleutels overschrijven niets. Er komt geen samengestelde installatiehash.

Foutcontract: op iedere exception alle OUT-waarden verwerpen. Bij succesvolle extractie zijn er geen LOBs; bij succesvolle normalisatie/serialisatie/calculatie moet de caller geretourneerde tijdelijke LOBs vrijgeven. Packagecoördinatoren ruimen hun eigen tijdelijke LOBs op. Geen enkele packageprocedure commit. Er is geen metadata- of baselinecache.

## PM-001-38 - METADATA_V1 datasetcontract
Alle slots bestaan, ook wanneer hun rows_ leeg is. Records zijn dicht geïndexeerd vanaf 1. Tekstkolommen staan in txt(k), NUMBER-kolommen in num(k), inclusief expliciete NULL-waarden. De kolomposities volgen de vaste selectielijst in extract_metadata. De datasets zijn geen vrij uitbreidbare productie-API: bij wijziging is een nieuwe contractversie nodig.

| Slot | Dataset | Kolommen in selectvolgorde (N = NUMBER, overige tekst) |
|---|---|---|
| 1 | TABLES | iot_type, cluster_name, temporary, nested, partitioned, secondary |
| 2 | EXTERNAL_TABLES | table_name |
| 3 | TAB_COLS | column_name, column_id(N), data_type, data_precision(N), data_scale(N), char_length(N), char_used, data_length(N), nullable, hidden_column, virtual_column, identity_column, default_length(N), collation |
| 4 | CONS_COLUMNS | constraint_name, column_name, position(N); binary name/position order |
| 5 | CONSTRAINTS | constraint_name, constraint_type, generated, status, deferrable, deferred, validated, rely |
| 6 | IND_COLUMNS | index_name, column_name, column_position(N), descend, index_owner; binary name/position order |
| 7 | INDEXES | index_name, index_type, uniqueness, generated, partitioned, status, visibility, compression, prefix_length(N), owner |
| 8 | CHECK LONG | constraint_name, complete search_condition; DBMS_SQL COLUMN_VALUE_LONG |

De extractor bewaart de volledige CHECK LONG tot de expliciete buffergrens. Geen *_VC-truncatie. Per dataset maximaal 1000 rijen; de genormaliseerde documentgrens blijft 1000 records. De extra extractiebound voorkomt onbeperkte opslag vóór normalisatie. CDB filtert eigenaar+tabel+actuele CON_ID; DBA leest dezelfde lokale PDB met eigenaar+tabel. GV_$INSTANCE is provenance buiten de canonical bytes. Geen root-, cross-container- of atomair-snapshotclaim. Tijdens alle vergelijkingen geen gelijktijdige DDL [O1/O6].

## PM-001-39 - Profielen en CAN-001 behouden
TABLE_CORE/2 bevat het HEAP-record, kolomrecords en de geselecteerde P/U/C-constraint- en NORMAL-indexrecords. NUMBER-precisie is decimaal; FLOAT-precisie is binair. NUMBER/FLOAT bewaren scale afzonderlijk. CHAR_LENGTH en CHAR_USED gelden alleen voor tekentypen; DATA_LENGTH wordt volgens de bestaande voorstelregel alleen voor RAW en BYTE CHAR/VARCHAR2 geëvalueerd. Overige toepasselijkheden zijn N/A, ontbrekende toepasselijke waarden NULL. De oorspronkelijke historische reden voor de DATA_LENGTH-omissie blijft onbekend [O2].

Canonieke header: hex 414F330000000001, value frames voor profielcode, profielversie als integertekst, CAN-001-DRAFT-1, SHA256, daarna uint32-recordaantal. Record: één typetag (10 TABLE, 11 COLUMN, 12 CONSTRAINTS, 13 INDEX in hex), uint32-payloadlengte, daarna velden met uint32-ID plus value frame. Value frame: één tag (0 NULL, 1 N/A, 2 UTF-8 STRING, 3 canonieke integertekst), uint32-bytelengte en payload. Alle uint32 zijn unsigned big-endian. Tekst is expliciet AL32UTF8. Integertekst heeft geen plus, voorloopnul of -0. Oracle lege string is NULL; lege STRING-payload is in deze PoC uitgesloten.

Records worden op volledige raw bytes gesorteerd; multipliciteit blijft behouden. Maximaal 8000 UTF-8-bytes/veld, 15995 payloadbytes plus 5 framingbytes/record, 1000 records en 1000000 documentbytes. SHA256 gebruikt de volledige BLOB [O3]. Runtimebron en diagnostische identiteit blijven buiten de hash; generated constraint/indexnamen volgen de 003-N/A-regels. Een TABLE-objectprofiel met componentrecords is geen installatiehash. De volledige vaste 003-vector wordt ongewijzigd uitgevoerd en onafhankelijk geverifieerd.

## PM-001-40 - Echte preflight (B04)
preflight(label, identity, source, release) verwerkt een concrete componentaanvraag. TABLE wordt vers uitgelezen. INDEX en CONSTRAINTS resolveren hun parent in dezelfde gekozen bron en selecteren hun eigen genormaliseerde record; een unsupported parent voorkomt dus ook een misleidend kindresultaat. Een ondersteund resultaat heet RECOGNIZED/EVALUATED_WITHIN_PROFILE met reden BOUNDED_PROFILE; dit is de concrete invulling van het in de regie voorgestelde SUPPORTED, begrensd tot profieldekking.

Bekende niet-geëvalueerde zelfstandige objecttypen krijgen pas na lokale identiteitscontrole RECOGNIZED_ONLY/NOT_EVALUATED. UNKNOWN betekent geen catalogusmapping voor het werkelijk aangeboden label; de aangeboden identiteit moet wel werkelijk bestaan. Het package verzint geen onbekend Oracle-type. De test biedt een ongemapt label bij de bestaande view AO4_V aan. USER_OBJECTS is hier een hulpbron voor lokale identiteit, niet de bron van de objectfingerprint.

Unsupported shapes en expliciete extractiebounds leveren UNSUPPORTED/UNSUPPORTED_SHAPE. Ontbrekende of ontoegankelijke metadata levert ERROR/EXTRACTION_ERROR; onverwachte fouten in latere fases krijgen NORMALIZATION_ERROR of SERIALIZATION_ERROR. De werkelijke SQLCODE/SQLERRM, fase, bron, container, tijd en aanbevolen BLOCK_AND_REVIEW worden opgeslagen. Foutpaden leveren geen nieuwe succesvolle digest op. Registratiefouten zelf worden doorgegeven; het package kan niet beloven een bevinding te bewaren als de findingopslag zelf faalt.

AO4_FINDING heeft een release-FK en identity-ID. Caller COMMIT maakt findings persistent; ROLLBACK verwijdert ze. Preflight schrijft geen accepted baseline en voert geen aangeboden DDL uit. Uitzonderingsautorisatie, uitvoeringsmodi en productielifecycle blijven buiten scope. De vijf gecommitte basisgevallen worden na herverbinding opnieuw gecontroleerd; de privilegeproef voegt afzonderlijk de werkelijke toegangsweigering toe.

## PM-001-41 - Verificatie en grenzen (B07)
TEST_RESULTS.csv bevat de 63 vaste T-assertions plus dynamische rijassertions, drie persistentieassertions, twee privilegeassertions en cleanup, alle bij oplevering NOT_EXECUTED. TRACEABILITY.csv koppelt R01-R16 aan code en assertions. De onafhankelijke Pythonchecker reconstrueert alle werkelijke JSON/hex-evidence uit het latere Oracle-log en vergelijkt iedere opgeslagen kindobservatie met het bijbehorende bronrecord. Hij verlangt alle afzonderlijke markers. Synthetische invoer is uitsluitend gebruikt voor lokale checkerzelftests; zulke logs zijn geen Oracle-bewijs en worden niet meegeleverd als database-uitvoer.

Lokale controle is begrensd: bronintegriteit, lexicale/scriptstructuur, interfaceverantwoordelijkheden, allowlists, testinventaris, referentie-encoder en documentopmaak. Dit is geen Oracle-compiler of runtime. Zie VALIDATION.json voor werkelijk uitgevoerde controles, RUNBOOK.md voor G0-G5 en OPEN_POINTS.md voor de resterende besluiten. Productieautorisatie en volledige historische sluitendheid worden niet geclaimd.

Aanvullende technische bron O7: Oracle 19c JSON Data Structures, https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/json-types.html. JSON-null wordt expliciet geïnspecteerd; niet-tekstwaarden worden niet impliciet naar canonical STRING geconverteerd. Dit is technische onderbouwing van K12/K15 en geen nieuwe besluitenbron.

## PM-001-42 - Leeswijzer en legenda
Lees eerst de registers, afwijkingen en runbook. De actuele uitvoerbare scripts zijn uitsluitend sql/00_install.sql, 01_setup.sql, 02_package.sql, 03_tests.sql met 03_reference_vector.sql, 04_verify_persistence.sql, 06_privilege_error.sql en 05_cleanup.sql. sql/00_privileges.sql is een DBA-reviewtemplate. De code uit 003 is uitsluitend baseline/historie; meng nooit revisies.

Codeweergave: Courier New 11 pt of vergelijkbaar monospace. Er is geen syntactische kleurcodering met betekenis. Besluitstatus staat altijd als tekst: Besloten, Afgewezen, Voorstel, Open, Uitgesteld. Kopkleuren zijn uitsluitend navigatie. De PDF is een leesdocument met registers/runbook; de exacte scripts en volledige 003-historie blijven losse pakketbestanden.
''')
dev=OUT/'DEVIATIONS.md';s=dev.read_text(encoding='utf-8')
if 'K15' not in s:
    s=s.replace('| K14 |','| K15 | D15; R04 | Oracle 19c JSON-type-documentatie aanvullend technisch gecontroleerd; expliciete JSON-null/STRING-validatie | Geen besluitenbasis uitgebreid; voorkomt impliciete GET_STRING-conversie; exacte geldige 003-bytes behouden |\n| K14 |')
    dev.write_text(s,encoding='utf-8')
def inline(s):
    s=html.escape(s)
    s=re.sub(r'`([^`]+)`',r'<code>\1</code>',s)
    s=re.sub(r'(https://[^\s<]+)',r'<a href="\1">\1</a>',s)
    return s
def md_html(text):
    out=[];code=False;table=False
    for line in text.splitlines():
        if line.startswith('```'):
            if table:out.append('</tbody></table>');table=False
            out.append('</code></pre>' if code else '<pre><code>');code=not code;continue
        if code:out.append(html.escape(line)+'\n');continue
        if line.startswith('|'):
            if re.fullmatch(r'[| :\-]+',line):continue
            if not table:out.append('<table><tbody>');table=True
            out.append('<tr>'+''.join('<td>'+inline(v.strip())+'</td>' for v in line.strip('|').split('|'))+'</tr>');continue
        if table:out.append('</tbody></table>');table=False
        if line.startswith('#'):
            level=len(line)-len(line.lstrip('#'));out.append(f'<h{level}>{inline(line[level:].strip())}</h{level}>')
        elif line:out.append('<p>'+inline(line)+'</p>')
    if table:out.append('</tbody></table>')
    return '\n'.join(out)
parts=[]
for name in ['DESIGN.md','REFERENCE_CHECK.md','DECISIONS.md','REQUIREMENTS.md','OPEN_POINTS.md','SOURCE_INDEX.md','DEVIATIONS.md','RUNBOOK.md']:
    parts.append('<section id="'+name.split('.')[0]+'">'+md_html((OUT/name).read_text(encoding='utf-8'))+'</section>')
parts.append('<h1>Actuele scripts revisie 004</h1>')
for p in sorted((OUT/'sql').glob('*.sql')):
    parts.append('<details><summary>'+html.escape(p.name)+'</summary><pre><code>'+html.escape(p.read_text(encoding='utf-8'))+'</code></pre></details>')
old_html=next((REF/'baseline_003').glob('*.html')).relative_to(OUT).as_posix()
nav=' '.join('<a href="#'+n+'">'+n+'</a>' for n in ['DESIGN','REFERENCE_CHECK','DECISIONS','REQUIREMENTS','OPEN_POINTS','SOURCE_INDEX','DEVIATIONS','RUNBOOK'])
put('DESIGN.html','''<!doctype html><html lang="nl"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>PM-001 revisie 004 - TETOOLS ADMIN_OBJECTS</title><style>
body{font:16px/1.55 system-ui,sans-serif;color:#182a35;background:#f4f6f8;margin:0}main{max-width:1180px;margin:auto;padding:32px;background:white}nav{position:sticky;top:0;padding:12px;background:#182a35;color:white;display:flex;gap:14px;flex-wrap:wrap}nav a{color:white;font-size:13px}h1,h2{color:#16485d;line-height:1.25}h1{margin-top:40px}h2{margin-top:30px}section{border-bottom:2px solid #d4dfe5;padding-bottom:28px;scroll-margin-top:95px}pre{font:11pt/1.45 'Courier New',monospace;background:#f2f5f7;padding:18px;overflow:auto;white-space:pre-wrap;overflow-wrap:anywhere}code{font-family:'Courier New',monospace}table{border-collapse:collapse;width:100%;font-size:14px;margin:20px 0}td{border:1px solid #cbd5df;vertical-align:top;padding:9px}tr:first-child{font-weight:bold;background:#eaf0f4}a{color:#155e89}details{margin:15px 0}summary{cursor:pointer;font-weight:bold}.status{border-left:5px solid #b56a00;padding:18px;background:#fff3dc}button{padding:8px 14px;font:inherit}@media print{nav,button{display:none}body,main{background:white;padding:0}pre{font-size:11pt}table{font-size:10pt}h1,h2,summary{break-after:avoid}tr{break-inside:avoid}}
</style></head><body><nav>'''+nav+'''</nav><main><p class="status"><strong>PM-001 revisie 004</strong> - code en testpakket voorbereid. Oracle 19c-compilatie en runtime: NOT_EXECUTED. Historische volledigheid begrensd. Geen productie-uitrol.</p><p><button onclick="window.print()">Afdrukken</button> <a href="PM001_004.pdf">PDF leesdocument</a> | <a href="'''+old_html+'''">Volledig ongewijzigd cumulatief ontwerp 003</a> | <a href="TRACEABILITY.csv">Traceability</a> | <a href="TEST_RESULTS.csv">Teststatus</a></p>'''+''.join(parts)+'''</main><script>let saved;addEventListener('beforeprint',()=>{saved=[...document.querySelectorAll('details')].map(x=>[x,x.open]);saved.forEach(([x])=>x.open=true)});addEventListener('afterprint',()=>saved?.forEach(([x,o])=>x.open=o));</script></body></html>''')
print('Generated design, registers, runbook links, traceability and unexecuted test register')
