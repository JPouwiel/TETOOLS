from pathlib import Path
import json, hashlib, zipfile, shutil, re

ROOT=Path.cwd()
OUT=ROOT/'output/PM-001_20261103_004'
REF=OUT/'reference'
REF.mkdir(parents=True,exist_ok=True)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def write(name,text): (REF/name).write_text(text.strip()+'\n',encoding='utf-8')
zip_path=ROOT/'output/20261103__PLSQL__TETOOLS_ADMIN_OBJECTS__PM001_PoC_003.zip'
review=ROOT/'output/PM001_review_20261103/PM001_003_review.pdf'
assert sha(zip_path)=='ac7b6d2bb084c87326eaf2cd9b5e8c49296759d73b743217a15ad9fe6dcde85d'
src=REF/'baseline_003';src.mkdir(exist_ok=True)
with zipfile.ZipFile(zip_path) as z:
    for n in z.namelist():
        assert Path(n).name==n
        (src/n).write_bytes(z.read(n))
base=json.loads((src/'manifest.json').read_text())
for e in base['files']:
    p=src/e['name'];assert p.stat().st_size==e['bytes'] and sha(p)==e['sha256']
historical=[]
for e in base['sources']:
    if 'relative_path' in e:
        p=ROOT/e['relative_path'];ok=p.exists() and sha(p)==e['sha256']
        assert ok,p
        dest=REF/'historical'/Path(e['relative_path'])
        dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,dest)
        historical.append(dict(e,verified=True,packaged_path=dest.relative_to(OUT).as_posix()))
shutil.copyfile(zip_path,REF/zip_path.name)
shutil.copyfile(review,REF/review.name)
shutil.copyfile(ROOT/'output/PM001_review_20261103/PM001_003_review.md',REF/'PM001_003_review.md')
setup=next(src.glob('*01_setup*')).read_text()
context=next(src.glob('*contextoverdracht*')).read_text(encoding='utf-8')
labels=re.findall(r"insert into ao3_catalog values\('([^']+)'",setup)
catalog=context.split('```text',1)[1].split('```',1)[0].strip().splitlines()
assert labels==catalog and len(set(labels))==53
write('CATALOG_003.txt','\n'.join(labels))
write('DECISIONS.md',r'''
# PM-001 / revisie 004 / gecontroleerde besluitenbasis v1
Peildatum: 2026-11-03. Status: brongecontroleerde implementatiebasis, geen nieuwe ontwerpacceptatie.

Bronvolgorde: actuele expliciete gebruikersopdracht (S04/S05), daarna de in 003 vastgelegde besluiten (S01-C, §§1-10), actuele H28-H35 (S01-H), met review S02 als controle. H01-H27 en 001/002 zijn historische context. Adviezen uit S02 zijn geen goedgekeurde besluiten. S03 bevat slechts zes recente turns; oudere oorspronkelijke reviewgesprekken ontbreken.

| ID | Status | Besluit / grens | Bron |
|---|---|---|---|
| D01 | Besloten | Oracle Database 19c EE; alleen nieuw leeg disposable lokaal PDB-schema; geen productieobjecten wijzigen | S04; C§9; H35 |
| D02 | Besloten | Bewaar alle 53 cataloguslabels exact; herkenning is geen evaluatie; RECOGNIZED_ONLY en UNKNOWN expliciet rapporteren | S04; C§1; H29 |
| D03 | Besloten | Alleen eenvoudige permanente niet-gepartitioneerde heap, P/U/C-constraints, NORMAL B-tree-indexes werkelijk evalueren | C§1/9; H30-31; S04 |
| D04 | Besloten | Geen reconstructie oorspronkelijke CREATE/ALTER-DDL; dictionarymetadata als waarneming | C§2 A; H28/31 |
| D05 | Besloten | PROFILE_CODE, profielversie en CANONICAL_VERSION expliciet; versiegebonden normalisatieregels | C§2 B/E; H30/32 |
| D06 | Besloten principe; invulling voorstel | Exacte canonieke bytes, onderscheiden NULL/N/A, framing/sortering/grenzen; CAN-001-DRAFT-1 blijft concreet voorstel | C§5; H32 |
| D07 | Besloten | Extractie, normalisatie, serialisatie en opslag scheiden met testbare interfaces (B03) | C§2 H/§3 11; S04 |
| D08 | Besloten | CDB_* + GV_$INSTANCE voorkeur; expliciet DBA_* + GV_$INSTANCE alternatief; geen stilzwijgende fallback | C§4; H31; S02 B06 |
| D09 | Expliciet afgewezen | Geen samengestelde installatiehash; alleen individuele objectfingerprints aan release gekoppeld | C§3/8; H28/33; S04 |
| D10 | Besloten | Objectmanifest met genormaliseerde getypeerde waarden, minimaal type/identiteit; pakbon tekst/JSON; aanbod apart van werkelijk resultaat | C§2 C/F/J; C§6; H33 |
| D11 | Besloten | Onvoldoende betrouwbare opgeslagen fingerprint opnieuw berekenen; exacte vertrouwenscriteria open | C§3 12; H31/34 |
| D12 | Besloten | Echte preflightbevindingen persistent opslaan: herkenning/evaluatie, ernst, reden, advies, exception reference; geen synthetische placeholders (B04) | C§7; S04 |
| D13 | Uitgesteld | RECOMMENDED/FORCE_ALL/SELECTIVE uitvoeringsmodi, autorisatie-engine, overwritebeleid, lifecycle en retentie later; technische onuitvoerbaarheid nooit negeren | C§3 15/19; C§7; H34 |
| D14 | Besloten | Exceptionverzoek is geen goedkeuring; voorbeeld in 003 verleent geen echte autorisatie | C§6; H33 |
| D15 | Besloten opdracht | Volledige databaseassertions B07; statisch controleren, geen Oracle-runtimeclaim zonder echte database | S04; C§9; S02 B07 |
| D16 | Besloten planning | M1 profielcontract, M2 CAN-001, M3 PoC, M4 pakbon/individuele registratie, M5 preflight, M6 lifecycle; niet automatisch voltooid | C§8; H34 |
| D17 | Open; niet herinterpreteren | Historische reden voor DATA_LENGTH-omissie niet vastgesteld; datatypeafhankelijke regel van 003 blijft voorstel | C§3 DATA_LENGTH; H30; S02 B02 |
| D18 | Besloten opdracht | Eerst deze vijf referentiebestanden controleren; uitsluitend deze basis gebruiken; iedere afwijking registreren | S05 |

Concrete bevroren PoC-invulling (geen nieuwe acceptatie): TABLE_CORE/2, CONSTRAINT_CORE/1, INDEX_CORE/1, CAN-001-DRAFT-1, AO3_RULES_1; AL32UTF8, SHA256, magic 414F330000000001. Grenzen 8000 bytes/veld, 16000 bytes/record, 1000 records/document en 1000000 bytes/document. Exacte veldregels, profielwaarden en bronuitsluitingen zijn versiegebonden in S01-H H30-H32 en S01-S2 bewaard; bij conflict niet stilzwijgend kiezen maar afwijking registreren. COLUMN is een intern recordtype, geen 54e cataloguslabel.

Historische context ontbreekt: oorspronkelijke woordelijke reviewrondes 01/02 en complete regiegeschiedenis zijn niet teruggeleverd door read_thread. De overdracht C is reconstructief. Wij claimen alleen volledigheid tegenover dit beschikbare corpus. Het losse oorspronkelijke `Pasted text.txt` is niet als zelfstandig bestand geverifieerd; C is de beschikbare tekstbron, met eigen hash.
''')
write('REQUIREMENTS.md',r'''
# PM-001 / revisie 004 / eisenbaseline v1
Alle eisen zijn uitvoeringsopdrachten of herleidbare grenzen. Implementatiestatus en Oracle-acceptatie staan afzonderlijk in TRACEABILITY.csv en VALIDATION.json; onderstaande lijst zegt niet dat tests uitgevoerd zijn.

| Eis | Contract / acceptatiepoort | Besluit / bron |
|---|---|---|
| R01 | 003 ZIP en alle 17 manifestentries bytebehoud; 53 labels exact; historische status behouden | D02/D18; S01/S02/S05 |
| R02 | Publieke extractie -> getypeerde ruwe dataset; geen normalisatie of opslag | D07; S04 B03 |
| R03 | Pure normalisatie(dataset) -> getypeerd manifest; geen dictionaryquery, hash of DML | D05/D07; S04 B03 |
| R04 | Pure CAN-001-serialisatie(manifest) -> exacte bytes/SHA256; geen dictionaryquery of DML | D06/D07; S04 B03 |
| R05 | Aparte opslagcoördinator; één metadata-extractie; individuele table/constraint/index-observaties; savepoint en callercommit | D07/D09; H33; S04 |
| R06 | Preflight op actuele aanvragen/objecten; opgeslagen recognized-only, unknown, unsupported shape, extraction error; geen success-digest bij fout | D12; S04 B04 |
| R07 | Findings met release, type/identiteit, herkenning/evaluatie, severity, reason, action, exception; werkelijke foutcode/-tekst en bron voor fouten | D10/D12; S02 B04 |
| R08 | CDB en DBA uitvoeren en profiel/bytes/digest vergelijken; zichtbaarheid/fout nooit als wereldwijde afwezigheid uitleggen | D08; S04 B07 |
| R09 | Assertions USER_ERRORS/VALID, vaste CAN-vectoren en overflows; determinisme/NLS en datatypevelden | D15; S02 B07/H34 |
| R10 | Iedere opgeslagen TABLE/CONSTRAINTS/INDEX-digest onafhankelijk reconstrueren; volledige rijaantallen, profiel, manifest, bytes controleren | D09/D15; S04 B07 |
| R11 | Assertions rollback callertransactie, gedeeltelijke opslagfout, duplicaat, ontbrekende release, unsupported/foutpaden en cleanup | D15; S04 B07 |
| R12 | SQL*Plus/SQLcl setup/package/tests/cleanup, directe privileges en stapsgewijs runbook; geen productiegebruik | D01/D15; S04 |
| R13 | Downloadbare ZIP, offline HTML ontwerp, PDF, registers, traceability, bronindex, checksums; behoud 003 | D18; S04/S05 |
| R14 | Bewijsgrens: alleen werkelijk uitgevoerde lokale controles claimen; Oracle compilation/runtime NOT_EXECUTED zonder echte database | D15; S04 |
| R15 | Geen installatiehash, uitvoeringsmodi, exception-engine of productielifecycle implementeren | D09/D13/D14; S04 |
| R16 | Alle implementatiekeuzes/afwijkingen tegen baseline registreren, inclusief motivatie en gevolgen voor compatibiliteit/acceptatie | D18; S05 |

Poorten: G0 bronintegriteit; G1 statische controle/artefacten; G2 echte Oracle 19c-compilatie en privileges; G3 volledige databaseassertions plus onafhankelijke bytes/digests; G4 commit-herverbinding en cleanupbewijs; G5 review van open ontwerpvoorstellen. G0/G1 vervangen G2-G5 niet.

Refactoringconcept B03: hergebruik de veldregels en bytegrammatica van 003. Verplaats uitsluitend het ophalen naar extract_metadata; normaliseer de uitgelezen dataset afzonderlijk; laat serialize_manifest de framing/sortering/hashing uitvoeren; laat store_observations de individuele waarnemingen opslaan. calculate blijft uitsluitend coördineren. Geen generieke productieprofielengine. Een getypeerde dataset met benoemde querysets en afzonderlijke NUMBER-/tekstcellen houdt Oracle-getallen vrij van impliciete NLS-conversie. Eén dataset per tabel voorkomt herhaalde extractie per kindhash. Deze opzet is de uitwerking van het al geautoriseerde B03-besluit, geen nieuwe volledige productierefactoring.
''')
write('OPEN_POINTS.md',r'''
# PM-001 / revisie 004 / open punten v1
Geen van deze punten wordt door het bouwen van code stilzwijgend goedgekeurd.

| ID | Open onderwerp | Mijlpaal / bron | Afhandeling 004 |
|---|---|---|---|
| OP-01 | Definitieve CAN-001-wireformatacceptatie | M2; H32/34 | DRAFT-1 behouden |
| OP-02 | Profielscope/datatypekeuze en historische DATA_LENGTH-redenering | M1; C§3/H30 | regels 003 behouden als voorstel; oorspronkelijke reden onbekend |
| OP-03 | Portable objectidentiteit/naamnormalisatie | M2; H32/34 | diagnostische identiteit buiten canonical bytes; generated-name-regels 003 |
| OP-04 | Versie-/hashprecedentie bij installatie | M5; H34 | geen installatiebeleid |
| OP-05 | Vertrouwde gelijkheid/baseline | M5; H34 | vers berekenen; observatie is geen accepted baseline |
| OP-06 | Actualiteit/freshness | M5; H34 | DDL-vrij testvenster; geen cachebewijs |
| OP-07 | Pakbonopslag en productiesleutels | M4/M5; H33/34 | bestaand PoC-releasecontract, geen productieclaim |
| OP-08 | Uitzonderings-/autorisatiebeleid | M5; C§6/H34 | voorbeeld behouden; niet uitvoeren |
| OP-09 | Historie/retentie | M6; H34 | uitgesteld |
| OP-10 | Meerdere waarnemingen/concurrency | M6; H34 | duplicate zichtbaar afwijzen; geen overwrite |
| OP-11 | Evaluatieovergangen/correctie | M6; H34 | uitgesteld |
| OP-12 | Hashpad/grenzen definitief accepteren | M2; H32/34 | vaste bounds 003 testen |
| OP-13 | Productie-extractie, consistentie en containerzichtbaarheid | M1/M3; C§4/H31 | twee expliciete lokale PDB-routes, geen root/multi-PDBclaim |
| HIST-01 | Originele woordelijke reviewrondes 01/02 en volledige regiegeschiedenis ontbreken | S02 B02; S03 | uitsluitend reconstructieve C als beschikbare besluitenbasis; niet als volledig historisch bewijs presenteren |
| HIST-02 | Los origineel Pasted text.txt niet teruggevonden/gehasht | S01 manifest/sources | eigen C-teksthash leidend; geen gelijkheidsclaim met origineel |
| HIST-03 | Oorspronkelijke reden DATA_LENGTH weglating ontbreekt | C§3; S02 | hypothese niet als besluit gebruiken |
| VAL-01 | Oracle 19c EE database/verbinding ontbreekt in sessie | S04 | runtime NOT_EXECUTED; uitvoerlogs later vereist |
| M4-01 | Volledige objectversie-/installerworkflow is nog geen productiecontract | S02 B05 | enkel waarnemingen en echte preflight; tests zijn geen installerresultaat |

OP-samenvattingen zijn ontleend aan actuele H34 en de review; zij vervangen de bewaarde originele tekst in baseline_003 niet. Bij een ontbrekende oorspronkelijke nuance: HIST-01, geen nieuwe interpretatie als besloten beleid.
''')
write('SOURCE_INDEX.md',r'''
# PM-001 / revisie 004 / bronindex v1
Alle pakketpaden relatief aan de revisie-004-root. SHA-256 en byteaantallen staan in manifest.json. Een hash bewijst identiteit, niet historische volledigheid.

| ID | Bron / precieze vindplaats | Gebruik / betrouwbaarheid |
|---|---|---|
| S01 | reference/20261103__PLSQL__TETOOLS_ADMIN_OBJECTS__PM001_PoC_003.zip; uitgepakt in reference/baseline_003 | 18 entries; 17 geverifieerde manifestbestanden; ongewijzigde baseline |
| S01-C | baseline_003/*contextoverdracht_003.txt §§1-10 | beschikbare reconstructieve besluitenoverdracht; geen woordelijk origineel |
| S01-H | baseline_003/*ontwerp_profielmanifest_003.html H28-H35 | actuele cumulatieve specificatie; H01-H27 historisch |
| S01-S0..4 | baseline_003/*00_privileges*, *01_setup*, *02_package*, *03_tests*, *04_cleanup* | implementatie 003; geen Oracle-runtimebewijs |
| S01-V/J/B | baseline_003/*CAN001_testvectoren*, *objectmanifest_voorbeeld*, *canonieke_bytes_voorbeeld* | referentiebytes; geen echte databasewaarneming |
| S02 | reference/PM001_003_review.pdf; tekstcompanion PM001_003_review.md §§4-9 en bijlagen | beoordelingsbron, B03/B04/B07 uitvoeringshiaten; adviezen zijn geen besluiten |
| S03 | regiechat 6ae1c678-2a98-83ed-99b0-c8895440f708, read_thread 2026-11-03, turnLimit 10 | zes recente turns, geen oudere cursor; geen volledige oorspronkelijke reviews; bijlagen lokaal beschikbaar |
| S04 | reference/USER_SCOPE_004.md | letterlijke actuele implementatieopdracht; voorrang boven eerdere voorstellen |
| S05 | reference/USER_REFERENCE_FIRST_004.md | letterlijke actuele instructie: eerst referentiepakket, afwijkingen registreren |
| H001/H002 | reference/historical/output/PM-001_* | 12 lokale historische bestanden uit manifest 003 opnieuw op SHA-256 gecontroleerd en meegeleverd; uitsluitend historie |

Oracle 19c primaire technische bronnen (semantiek, geen TETOOLS-beleidsbesluiten):
- O1 CDB_* Views: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/cdb_-views.html (huidige container, directe grants, zichtbaarheid).
- O2 ALL_TAB_COLS: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/ALL_TAB_COLS.html (NUMBER/FLOAT, length/char semantics).
- O3 DBMS_CRYPTO: https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_CRYPTO.html (SHA256 BLOB).
- O4 UTL_RAW: https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/UTL_RAW.html (COMPARE-resultaat, RAW-grenzen).
- O5 AUTHID: https://docs.oracle.com/en/database/oracle/oracle-database/19/lnpls/invokers-rights-and-definers-rights-authid-property.html (definerrechten/directe grants).
- O6 DBMS_SQL: https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_SQL.html (getypeerde kolomextractie/LONG).

O1/O3/O5/O6 zijn in deze sessie online geraadpleegd; O2/O4 staan tevens in S02 en dienen bij de betreffende codecontrole opnieuw geraadpleegd te worden. Ontbrekende oorspronkelijke chatteksten, niet-teruggevonden losse uploads en ontbrekend Oracle-testbewijs zijn expliciet opgenomen in OPEN_POINTS.md.
''')
write('USER_SCOPE_004.md','''Voer NU de implementatieopdracht uit voor TETOOLS ADMIN_OBJECTS PM-001 revisie 004, Oracle 19c EE. Gebruik /mnt/data/20261103__PLSQL__TETOOLS_ADMIN_OBJECTS__PM001_PoC_003.zip en /mnt/data/PM001_003_review.pdf als bron; vraag om herupload indien ontoegankelijk. Behoud revisie 003 en alle overeengekomen besluiten. Lever daadwerkelijk downloadbare ZIP met HTML ontwerp, SQL setup/package/tests/cleanup, privileges, runbook, versiegebonden DECISIONS/REQUIREMENTS/OPEN_POINTS/SOURCE_INDEX, traceability matrix, checksums, PDF. Implementeer B03 scheiding metadata-extractie, normalisatie, CAN-001 serialisatie en opslag met testbare interfaces; B04 echte persistent geregistreerde preflightbevindingen inclusief recognized-only, unknown, unsupported shape en extractiefout, geen synthetische placeholders; B07 volledige databaseassertions voor compilatie, CDB/DBA-route, canonieke bytes/digests, individuele tabel/constraint/index-hashes, opslag, rollback, foutpaden, cleanup. Scope: eenvoudige heap table met constraints en indexes, herkenningscatalogus 53 labels, geen samengestelde installatiehash; preflight uitvoeringsmodi blijven later. Streef naar zo goed mogelijk statisch gecontroleerde Oracle 19c uitvoerbaarheid, maar claim geen Oracle runtime-validatie zonder echte database. Test enkel in nieuw leeg disposable schema, geen productieobjecten wijzigen. Voeg stapsgewijze installatie en SQL*Plus/SQLcl runinstructies toe, rollback/cleanup en duidelijke acceptatiepoorten. Gebruiker vraagt expliciet nu opzetten en uitvoeren zodat pakket later op database kan worden uitgerold.''')
write('USER_REFERENCE_FIRST_004.md','''Stel eerst `DECISIONS.md`, `REQUIREMENTS.md`, `OPEN_POINTS.md`, `SOURCE_INDEX.md` en `manifest.json` samen. Controleer deze tegen de beschikbare PM-001-bronnen. Markeer ontbrekende historische context expliciet. Gebruik uitsluitend dit gecontroleerde referentiepakket als uitgangspunt voor revisie 004 en registreer iedere afwijking.''')
files=[dict(path=p.relative_to(OUT).as_posix(),bytes=p.stat().st_size,sha256=sha(p)) for p in sorted(REF.rglob('*')) if p.is_file() and p.name!='manifest.json']
manifest=dict(design_id='PM-001',revision='004',reference_version='v1',status='SOURCE_CHECKED_IMPLEMENTATION_BASELINE',oracle_scope='19c EE, local disposable PDB schema',oracle_runtime_validated=False,history_complete=False,source_zip_sha256=sha(zip_path),checks={'zip_manifest_entries_verified':17,'catalog_exact_order_unique_labels':53,'historical_files_hash_verified':12},historical_sources=historical,missing_context=['HIST-01','HIST-02','HIST-03','VAL-01'],files=files,self_hash_policy='manifest.json excluded; external SHA256SUMS hashes this manifest')
(REF/'manifest.json').write_text(json.dumps(manifest,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
print(json.dumps({'reference':str(REF),'files':len(files),'checks':manifest['checks']},indent=2))
