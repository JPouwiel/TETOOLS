# PM-001 revisie 004 - Oracle 19c EE runbook

Dit pakket is voorbereid en lokaal statisch gecontroleerd. Oracle-compilatie en database-uitvoering zijn NIET uitgevoerd. Gebruik alleen een nieuw leeg disposable lokaal schema in een test-PDB. Geen bestaande TETOOLS-installatie bijwerken. CAN-001-DRAFT-1 en de concrete profielregels blijven voorstellen.

## 1. Controleer de overdracht - G0

Pak de ZIP volledig uit. Behoud de mappenstructuur. Lees eerst reference/DECISIONS.md, REQUIREMENTS.md, OPEN_POINTS.md, SOURCE_INDEX.md en manifest.json, daarna DEVIATIONS.md en REFERENCE_CHECK.md. De bestanden met dezelfde registernamen in de pakketroot zijn bytegelijke leesexemplaren van de bevroren referentiebasis. Het manifest in de root beschrijft de volledige oplevering; reference/manifest.json beschrijft de vooraf gecontroleerde basis.

Voer vanuit de uitgepakte pakketroot uit met Python 3:

```text
python tools/verify_integrity.py
```

Verwacht: PASS delivery manifest and SHA256SUMS. Een verschil blokkeert verder gebruik. De externe ZIP-checksum hoort bij de ZIP; de interne checksums horen bij de uitgepakte bestanden. De referentie-ZIP kan zelfstandig aan een volgende sessie worden gegeven.

## 2. DBA-voorbereiding - G2

Leg PDB-service, Oracle 19c EE-versie/RU, instance, schema, SQL*Plus/SQLcl-versie en testdatum vast. De applicatie vermeldt PRODUCT_COMPONENT_VERSION en runtimeherkomst; laat de DBA aanvullend het werkelijk toegepaste RU/patchniveau bevestigen. Gebruik een DDL-vrij venster. De acht dictionaryqueries zijn geen atomair snapshot bij gelijktijdige DDL.

De DBA maakt zelf een nieuwe lokale gebruiker AO4_POC_<suffix>, bijvoorbeeld AO4_POC_PM001004, met een geschikt testtablespace en begrensd quota. Wachtwoorden en CREATE USER staan bewust buiten de scripts. Setup vereist exact deze naamvorm, CURRENT_SCHEMA gelijk aan SESSION_USER, CON_ID >= 3 en nul USER_OBJECTS. Geef het schema geen productieobjecten of brede dictionaryrechten.

Lees sql/00_privileges.sql: dit is een gecontroleerd DBA-sjabloon, geen automatisch grantprogramma. Benodigd zijn CREATE SESSION, CREATE TABLE, CREATE PROCEDURE en CREATE VIEW; EXECUTE op SYS.DBMS_CRYPTO, SELECT op SYS.GV_$INSTANCE en directe SELECT-grants op beide families CDB_/DBA_ van TABLES, EXTERNAL_TABLES, TAB_COLS, CONSTRAINTS, CONS_COLUMNS, INDEXES en IND_COLUMNS. Beide families zijn verplicht voor de acceptatietests. Als PUBLIC-toegang ontbreekt: verleen ook direct EXECUTE op DBMS_SQL, DBMS_LOB, UTL_RAW en UTL_I18N. JSON_OBJECT_T/JSON_ARRAY_T zijn ingebouwde 19c-afhankelijkheden; lokale lockdowns kunnen DBA-aanpassing vereisen. Rollen alleen leveren in deze definerrechtenpackage onvoldoende rechten [O5].

Er zijn geen CREATE ANY, ALTER ANY, DROP ANY, SET CONTAINER, ALTER SYSTEM of common-userrechten nodig. De brede SELECT ANY DICTIONARY-grant is niet nodig en verhindert de gerichte privilegeproef. USER_OBJECTS wordt uitsluitend gebruikt voor lokale fixture-/identiteitscontrole en cleanup; profielmetadata komt uit de gekozen CDB/DBA-route [O1].

## 3. Installatie

Start SQL*Plus of SQLcl vanuit de uitgepakte pakketroot. Verbind interactief met de PDB-service als het nieuwe disposable schema. Zet geen wachtwoord in een commandoregel of spoolbestand. Gebruik voor SQL*Plus een UTF-8-client, bijvoorbeeld NLS_LANG=.AL32UTF8 ingesteld voordat de client start. SQLcl-logbestanden moeten eveneens als UTF-8 worden bewaard.

```sql
@sql/00_install.sql
```

De driver spoolet ao4_install.log en roept setup en package relatief aan zichzelf aan. Setup voert DDL uit en commit de catalogus. De packagecontrole vraagt expliciet USER_ERRORS en VALID-status van spec en body op; CREATE PACKAGE zonder zo'n controle is onvoldoende. Verwacht INSTALL_COMPLETE PM001_004 en geen compileerfouten. Bewaar de volledige log. Bij fouten: stop, inspecteer USER_ERRORS en grants; niet blind opnieuw installeren. Cleanup en een nieuw leeg schema geven een reproduceerbare herstart.

## 4. Databaseassertions - G3

```sql
@sql/03_tests.sql
```

Dit script draait eenmalig en maakt uitsluitend benoemde AO4-fixtures. Het voert eerst sql/03_reference_vector.sql uit met de exacte volledige 003-vector: 1228 bytes en SHA-256 1A1E83B0450BC00A53E476D7D15FA8379EA0B07AEA999440931F7FA15BD34AF1. Daarna volgen 62 aanvullende assertions, individuele ROW_HASH-/ROW_META-assertions en JSON/hex-bewijs voor CDB, DBA, datatypes, lange CHECK en alle opgeslagen objecten. De marker SUITE_COMPLETE PM001_004 is alleen een eindmarker; alle assertions en bytes moeten ook slagen.

De test omvat pure interfaceverwerking, NLS, FLOAT/NUMBER, CHAR/BYTE/NCHAR/NVARCHAR2/RAW/DATE, negatieve schaal, lange CHECK >4000 tekens, grensoverschrijdingen, mutatie/herstel, FK/virtual/IOT/partition/function-index-afwijzing, volledige opslag, duplicaten, ontbrekende release, savepoint, gedeeltelijke kindfout en callerrollback. De collision seed bij PARTIAL004 is uitdrukkelijke foutinjectie, wordt teruggedraaid en is geen preflightbevinding.

De echte preflightgevallen zijn: AO4_V als VIEW, dezelfde werkelijk bestaande view met een onbekend aangeboden label, AO4_UNSUPPORTED met echte defaultmetadata, een werkelijk ontbrekend tabeldoel AO4_ABSENT en de ondersteunde AO4_T. UNKNOWN gaat hier over de inkomende labelmapping, niet over een verzonnen onbekend Oracle-dictionarytype. INDEX en CONSTRAINTS worden via hun parenttabel afzonderlijk geëvalueerd. Er is geen inventarisatie-engine voor de overige 50 labels.

Het script commit FINAL004 met de individuele observaties en vijf echte bevindingen. TEST_OBSERVATION is geen uitgevoerde productie-installatie en geen accepted baseline. Foutbevindingen bevatten bron/container, fase, werkelijke SQLCODE/SQLERRM, reden en advies; zij krijgen geen nieuwe fingerprint. Een exception reference blijft NULL: geen autorisatie wordt uitgevoerd.

## 5. Herverbinding en persistentie - G4

Sluit de testsessie af. Start een NIEUWE clientverbinding naar dezelfde PDB als hetzelfde disposable schema; verander CURRENT_SCHEMA niet.

```sql
@sql/04_verify_persistence.sql
```

Verwacht P01-P03 en PERSISTENCE_COMPLETE PM001_004 in ao4_persistence.log. Hiermee worden gecommitte objectobservaties/digests en de vijf classificaties opnieuw uit de database opgevraagd. Het script kan niet zelfstandig bewijzen dat de operator werkelijk een nieuwe clientverbinding opende; leg dat vast in het uitvoerverslag.

## 6. Echte privilegefout - G3, DBA-handoff

Laat de DBA in deze test-PDB uitsluitend voor dit disposable schema tijdelijk uitvoeren, met de werkelijk gekozen schemanaam:

```sql
revoke select on sys.cdb_tables from AO4_POC_PM001004;
```

Start vervolgens opnieuw een verbinding als het disposable schema en voer uit:

```sql
@sql/06_privilege_error.sql
```

Verwacht D01_REAL_PRIVILEGE_ERROR en D02_EXPLICIT_DBA_ROUTE in ao4_privilege.log. De proef vereist een echte ORA-00942 of ORA-01031 die door preflight is opgevangen en geregistreerd; de fout wordt niet verzonnen of alleen in een log geplaatst. DBA wordt uitsluitend expliciet aangeroepen; geen automatische fallback. Als bredere rechten de fout verhinderen, faalt de assertion: laat de DBA het nieuwe testschema met alleen de benoemde directe grants gebruiken. Verwijder geen rechten uit andere schema's.

Laat de DBA de grant ook na een mislukte proef herstellen:

```sql
grant select on sys.cdb_tables to AO4_POC_PM001004;
```

De voorbeeldnaam vervangen door de echte disposable gebruiker. Bewaar DBA-uitvoer met revoke en restore. Een mislukte herstelgrant is een open beheeractie en geen geslaagde acceptatie.

## 7. Cleanup en onafhankelijke logcontrole - G4

Archiveer alle logs en eventuele aanvullende databasequeries BUITEN het te verwijderen schema. Voer in dezelfde disposable gebruiker uit:

```sql
@sql/05_cleanup.sql
```

Cleanup gebruikt een vaste lijst packages/views/tabellen. Alleen ontbrekende benoemde objecten worden genegeerd, zodat cleanup ook na gedeeltelijke setup werkt. Andere fouten blijven zichtbaar. Constraints/indexes en de identitysequence verdwijnen met hun tabel. Er volgt een assertion dat USER_OBJECTS leeg is. Bij onbekende resterende objecten: inspecteren, niet automatisch uitbreiden naar DROP USER CASCADE. Verwacht C01_SCHEMA_EMPTY en CLEANUP_COMPLETE PM001_004 in ao4_cleanup.log. De DBA kan daarna de disposable gebruiker verwijderen volgens het eigen beheerproces.

Voer buiten SQL*Plus/SQLcl uit:

```text
python tools/verify_logs.py ao4_tests.log ao4_persistence.log ao4_privilege.log ao4_cleanup.log
```

De checker verlangt alle 63 T-markers, alle individuele opgeslagen kindbewijzen, drie persistentieassertions, twee privilegeassertions en cleanup. Hij reconstrueert alle aangeleverde canonieke bytes/digests onafhankelijk in Python, vergelijkt de bronrecords met de kindmanifesten en weigert ontbrekende markers/foutmeldingen. Deze controle bewijst consistentie van aangeleverde logs; authenticiteit, doelomgeving en daadwerkelijk herverbinden blijven operatorbewijs. In het pakket zitten geen fictieve Oracle-uitvoerlogs.

## 8. Foutafhandeling en rollback

DDL commit impliciet: ROLLBACK verwijdert geen tabellen, grants of geslaagde compilatie. De tests voeren DDL daarom voor de transactionele assertions uit. store_observations gebruikt een intern savepoint en commit niet; een fout verwijdert alleen de nieuwe set, met behoud van eerder callerwerk. De caller bepaalt COMMIT of ROLLBACK. preflightbevindingen zijn eveneens gewone caller-DML, niet autonoom: zonder COMMIT zijn ze niet duurzaam, bij ROLLBACK verdwijnen ze. Na een fout eerst logs veiligstellen, vervolgens de vaste cleanup uitvoeren. Herhaal een installatie uitsluitend in een weer leeg disposable schema.

Bij gelijktijdige DDL of ongekende metadata: resultaten niet accepteren. Herstel het DDL-vrije venster en herhaal in een schoon schema. Er is geen productieconcurrency-, benchmark-, caching- of lifecycleclaim.

## 9. Acceptatiepoorten

| Poort | Vereist bewijs | Status bij oplevering |
|---|---|---|
| G0 | Bronhashes, catalogus, besluiten/eisen/open punten gecontroleerd | Lokaal uitgevoerd |
| G1 | Interne statische controles, referentie-encoder, checkerzelftests, PDF/ZIP-integriteit | Zie VALIDATION.json |
| G2 | Echte 19c EE/RU-identiteit, directe grants, foutloze spec/body-compilatie | NOT_EXECUTED |
| G3 | Alle databaseassertions, exacte bytes/digests, echte privilegefout, onafhankelijke logcheck | NOT_EXECUTED |
| G4 | Nieuwe sessie, persistente inhoud, rollbackbewijs, cleanup en herstelde grant | NOT_EXECUTED |
| G5 | Regiebeoordeling open profiel-/CAN-001-voorstellen en oplevering | Niet automatisch goedgekeurd |

Alleen G0/G1 rechtvaardigen de aanduiding 'voorbereid en statisch gecontroleerd'. Technisch gevalideerd vereist G2-G4 met echte logs. Productieacceptatie vereist bovendien de nog open ontwerpbesluiten en valt buiten deze PoC.

Technische bronnen O1-O6: zie SOURCE_INDEX.md. [O1] Oracle 19c CDB_* Views; [O5] Oracle 19c AUTHID; [O3/O6] DBMS_CRYPTO/DBMS_SQL. Deze bronnen onderbouwen Oracle-gedrag, niet de eigen profielkeuzes.
