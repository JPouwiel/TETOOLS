# TETOOLS Development Standard
Status: PROPOSED / CONCEPT 001 - 6 november 2026. Eigenaar beoordeling: TETOOLS__REGIE.
Publicatie is geen technische goedkeuring. Geen automatische toepassing, migratie of modulecodewijziging.
Bronopdracht: huidige expliciete gebruikersopdracht, voortzetting TETOOLS__REGIE 6ae9e9eb-6400-83eb-859c-580027d25466.
Baseline: main 9f530faa68e7bc231d10fb2be19f0067b2320259; uitvoerder 01a1b054-46d2-7781-9d7d-a39a7d6beb4b.

## 1. Reikwijdte en besluitvorming
Dit concept stelt reviewbare ontwikkelafspraken voor ADMIN_* voor, gericht op Oracle Database 19c Enterprise en het beoogde drie-node RAC. Het verklaart bestaande modules niet conform. Goedgekeurde suitebesluiten en module-uitzonderingen blijven leidend. De module-regie bezit bronanalyse en implementatie; centrale regie beslist over mogelijke gedeelde regels. Leg een afwijking vast met reden, effect, alternatief, bewijs, goedkeurende actor en bron. Een voorstel of onderzoeksdisposition INVESTIGATE geeft geen implementatierecht.

## 2. PL/SQL-contract en onderhoud
Voorgesteld: beschrijf per publieke routine parameters, types, null-/grensgevallen, fouten, transactie-eigenaar, rechten, neveneffecten en compatibiliteit. Inventariseer echte callers voordat een publieke routine wordt verwijderd. Hergebruik bestaande routines/variabelen wanneer hun contract past; introduceer geen gedeelde package uitsluitend wegens gelijkenis.
Gebruik leesbare namen, expliciete conversies en bindwaarden. Onderbouw dynamische identifiers met een toegestane objectscope en invoercontrole. Maak NLS-, charset-, lengte- en tijdsaannames expliciet.
Voorgesteld: behandel fouten op het niveau dat kan herstellen; behoud foutcontext voor de aanroeper. Sluit geen onverwachte fout stilzwijgend af. Compileer met vastgelegde warninginstellingen en beoordeel warnings; registreer werkelijke compileruitvoer en USER_ERRORS. Oracle beschrijft compilewaarschuwingen en runtime-exceptions afzonderlijk [O1].

## 3. Transacties en autorisatie
Voorgesteld: de caller beheert commit/rollback tenzij de gedocumenteerde API expliciet anders bepaalt. Maak autonome transacties, DDL-effecten, savepoints en retrygrenzen zichtbaar in het contract. Leg voor retries idempotentie en reconciliatie na onbekende uitkomst vast.
Review definer-/invokerrechten per object; documenteer minimale directe grants en toegestane/geweigerde callers. Geen brede ANY-rechten als gemakskoppeling. Test normale consumptie en onderhoudsbevoegdheid afzonderlijk. Schema-, datatype-, grant- en objectwijzigingen krijgen expliciete migratie-, rollback- en compatibiliteitsbeoordeling.

## 4. ADMIN_LOGGER-integratie
Voorgesteld: kies de concrete LOGGER-versie per consumer en documenteer gebruikte publieke API, configuratie, loggingkosten en foutbeleid. De beschikbare baseline is 20261015_500; compatibiliteit met de losse SESSIONS-C01-adapter is niet uitgevoerd. Loggerdiagnostiek vervangt geen module-eigen verzoek-/goedkeuringsregistratie; dit blijft een te beoordelen ontwerpkeuze.
Maak onderscheid tussen functionele fouten en loggingfouten: review expliciet wat de caller ervaart wanneer logging faalt. Beperk gevoelige payloads en definieer retentie/onderhoud. Behoud bestaande publieke backup-/restorecontracten tot afzonderlijk goedgekeurde verandering.
Open koppelingen: LOG-OPEN-01..05 en RAC-A-001..012 bij ADMIN_LOGGER__REGIE. Dit concept repareert geen DDL, purge, identiteit of autorisatie.

## 5. RAC, sessies en containers
Voorgesteld: documenteer database-/container-/instancecontext, fysieke sessiegeneratie en logische correlatie afzonderlijk. Bepaal de benodigde identiteit op basis van de handeling; kies nog geen nieuw suite-datatype of API. Bespreek hergebruik van SID, reconnect, pooling en replay met modules en DBA.
Oracle documenteert dat GV$ instancegegevens met INST_ID bevat; zicht vanuit root hangt mede af van CONTAINER_DATA. Dynamische views bieden geen gegarandeerde read consistency [O2]. Een globale view alleen bewijst daarom geen veilige targetselectie of liveness.
Voorgesteld: een onderhoudsroutine mag onvolledige zichtbaarheid niet zonder vastgesteld beleid als afwezigheid interpreteren. Test remote levende sessies, ontbrekend zicht en alle relevante nodeparen. Voor een onomkeerbare targetactie: opnieuw identiteit, bevoegdheid en actuele toestand toetsen volgens goedgekeurd modulecontract.
RAC-ARCH-01..03 en LOGGER-/SESSIONS-/OBJECTS-signalen blijven INVESTIGATE. Exacte RU, services, CDB/PDB, grants, client/pool en AC/TAC/replay zijn nog te leveren. Geen gedeelde identity-migratie is goedgekeurd.

## 6. Performance en concurrency
Voorgesteld: stel per relevante handeling een reproduceerbare baseline vast: dataomvang/verdeling, concurrency, nodes, warm/koud cacheprofiel, parameters en herhalingen. Rapporteer latencyverdeling, throughput, CPU, logical/physical reads, redo/undo en wachten voor zover werkelijk gemeten en toegestaan.
Onderzoek eerst het dure pad. Vergelijk SQL-georiënteerde verwerking en begrensde bulkverwerking waar passend, met geheugen- en foutsemantiek. Oracle behandelt bulk binding en profiling als tuningonderwerpen [O3]. Dat is geen bewijs van winst voor deze modules.
Leg lockvolgorde, claimatomiciteit, timeout, crashherstel en callerrollback vast. Vermijd ongefundeerde optimalisaties en claims op basis van alleen broninspectie. Gebruik uitsluitend beschikbare en gelicentieerde meetmiddelen; bepaal vooraf of benodigde opties zijn toegestaan.

## 7. Tests en bewijs
Voorgestelde matrix: statische integriteit/bronherkomst; schone installatie/compile; API/null/grensgevallen; positieve en negatieve privileges; commit/rollback/loggingfouten; concurrerende claims/locks; remote liveness; restart/crash; per toegestane reconnect-/replaymodus; consumentintegratie en regressie; gemeten performance.
Bewijs bevat broncommit, scriptversie, exacte omgeving/RU/container/nodes/grants, invoer, verwachting, werkelijke uitvoer, tijd, uitvoerder en PASS/FAIL/NOT_EXECUTED met reden. Een statische check is geen Oracle-uitvoering. Isolatie en toestemming voor verstorende tests worden vooraf bepaald.
Testinrichting of tooling zoals utPLSQL is nog geen gekozen suite-afhankelijkheid. Selectie volgt afzonderlijke beoordeling; verzin geen testresultaten.

## 8. Voorgestelde PR-gates
| Gate | Voor publicatie of technische vrijgave vereist |
|---|---|
| Scope | Opdracht, module-eigenaar, broncommit, besluiten/eisen en uitzonderingen |
| Diff | Alleen toegestane bestanden; bevroren releases onveranderd; publieke contractdelta expliciet |
| Relay | Eigen registratie/activiteit correct; unieke IDs; schema/validator; historie onveranderd of opvolgrecord; concurrencyreview |
| Oracle | Relevante compile/runtime- en privilegebewijzen; ontbrekende uitvoering blokkeert technische vrijgave |
| RAC/performance | Relevante multi-node/concurrency/fout- en meetbewijzen; geen universele readinessclaim uit steekproef |
| Review | Modulegoedkeuring; centrale goedkeuring voor nieuwe suitearchitectuur; concrete open punten/eigenaren |
| Publicatie | Gecontroleerd PR-head, actuele main vergelijken, merge en bestanden teruglezen |
Documentatie- of bronimport kan met expliciet NOT_EXECUTED worden gepubliceerd; dit verleent geen deploy-/runtimeacceptatie. Gates zijn een concept, geen nieuw automatisch CI-beleid.

## 9. Beslispunten voor centrale regie
Beoordeel de normtekst, uitzonderingsprocedure, verplichte LOGGER-contractinhoud, identiteit/provenance, testmatrix, meetbudgetten en gates. Inventariseer eerst consumers en beheerde omgevingen. Maak daarna afzonderlijke moduleopdrachten; geen terugwerkende conformiteitsclaim of ongevraagde refactoring.

## Bronnen
Project: COMMUNICATION_RELAY/RELAY_CONTRACT.md, SUITE_ARCHITECTURE.md, reports/RAC_STATUS_20261106.md en modules/*/{DECISIONS,OPEN_POINTS}.md. Canonieke module-eigenaars blijven leidend.
- [O1 Oracle 19c PL/SQL Error Handling](https://docs.oracle.com/en/database/oracle/oracle-database/19/lnpls/plsql-error-handling.html)
- [O2 Oracle 19c Dynamic Performance Views](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/about-dynamic-performance-views.html)
- [O3 Oracle 19c Optimization and Tuning](https://docs.oracle.com/en/database/oracle/oracle-database/19/lnpls/plsql-optimization-and-tuning.html)
Oracle-bronnen geraadpleegd 6 november 2026; productdocumentatie bewijst geen doelconfiguratie of testresultaat.
