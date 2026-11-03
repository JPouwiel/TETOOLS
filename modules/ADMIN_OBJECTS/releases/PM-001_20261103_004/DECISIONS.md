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
