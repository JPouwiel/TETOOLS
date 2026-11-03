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
