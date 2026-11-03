# PM-001 revisie 004 - actueel ontwerp
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
