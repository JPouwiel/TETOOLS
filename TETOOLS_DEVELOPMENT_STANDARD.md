# Goedgekeurd beleidskader - cumulatieve besluiten 1-12

Status: beleidsmatig APPROVED op expliciete gebruikersopdracht; technische uitwerkingen blijven PROPOSED. Registratie/publicatie wordt pas na merge en main-teruglezing als geverifieerd aangemerkt. Datum: 6 november 2026.

Bronnen: chatgpt-conversation://6ae9e9eb-6400-83eb-859c-580027d25466. De beschikbare read_thread-teruglezing bevat vijf laatste beurten (besluit 8-11 en voorstel 8); geen volledige oudere gespreksexport. De huidige expliciete gebruikersopdracht bevestigt besluiten 1-11; de gebruikersaanvulling bevestigt de exacte lijsten bij 2/4, categorie 7 en aanvullend besluit 12. Er zijn geen namen of lijsten gereconstrueerd uit het oudere concept. Oudere exacte bericht-ID's bij 1-7 en de huidige aanvullings-ID zijn UNVERIFIED; de beleidsinhoud is door de huidige gebruiker bevestigd. Besluit 12 is na de oorspronkelijke overdracht toegevoegd.

Uitvoerende sessie: 01a1b115-ba9d-7603-a9a0-ae3a52f121d3. Gelezen main-baseline: 66aef7ad118f5e89e77a4214bee5acbf80e9f154. Registratie: PR #70, merge 7bb9ce26ace7482378c6f59c37cc9fa752975191; eigen entry exact op main teruggelezen.

## Besluit 1 - Bestaande code gefaseerd refactoren

ID: REGIE-POLICY-20261106-001. Beleidsstatus: APPROVED; technische uitvoering: NOT_AUTHORIZED door deze registratie.

Bestaande ADMIN_*-code wordt gefaseerd naar de ontwikkelstandaard gebracht. Dit is beleidsrichting, geen opdracht om nu modules te wijzigen. Per fase blijven scope, bestaande functionaliteit, afhankelijkheden en verificatie expliciet.

Bron: huidige expliciete gebruikersopdracht 2026-11-06; oudere exacte goedkeuringsbeurt UNVERIFIED.

## Besluit 2 - Zes technische ontwikkelcategorieën

ID: REGIE-POLICY-20261106-002. Beleidsstatus: APPROVED; technische uitvoering: NOT_AUTHORIZED door deze registratie.

Voor nieuwe en bestaande ADMIN_*-modules zijn zes technische ontwikkelcategorieën verplicht: (1) Codekwaliteit; (2) API-compatibiliteit; (3) Transactiemanagement; (4) Beveiliging; (5) Performance; (6) Testbaarheid. Dit is de oorspronkelijke technische basis; besluit 9 voegt een gelijkwaardige zevende categorie toe.

Bron: expliciete huidige gebruikersaanvulling 2026-11-06; exact bericht-ID UNVERIFIED.

## Besluit 3 - Zeer strikt centraal afwijkingsbeleid

ID: REGIE-POLICY-20261106-003. Beleidsstatus: APPROVED; technische uitvoering: NOT_AUTHORIZED door deze registratie.

Afwijken is uitsluitend mogelijk na expliciete centrale beoordeling en goedkeuring door TETOOLS__REGIE. Een module kan een afwijking onderbouwd aanvragen, maar niet zelfstandig een suitebrede norm buiten werking stellen. Onderbouwing, gevolgen, alternatieven, bron en goedkeurende actor worden herleidbaar vastgelegd. De oudere ruimere formulering verleent geen zelfstandige modulebevoegdheid meer. Exacte oorspronkelijke nadere uitzonderingscriteria: UNVERIFIED; hier worden geen nieuwe uitzonderingsgronden toegevoegd.

Bron: huidige expliciete gebruikersopdracht 2026-11-06; oudere exacte goedkeuringsbeurt UNVERIFIED.

## Besluit 4 - Acht testcategorieën

ID: REGIE-POLICY-20261106-004. Beleidsstatus: APPROVED; technische uitvoering: NOT_AUTHORIZED door deze registratie.

Iedere beoordeling omvat expliciet acht categorieën: (1) Statische analyse; (2) Succesvolle installatie/compilatie, inclusief beoordeling van waarschuwingen; (3) Functionele tests; (4) Regressietests; (5) Beveiliging en transacties; (6) Performance en concurrency; (7) RAC-compatibiliteit, inclusief relevante multi-instance- en sessietests; (8) Herleidbaar test- en acceptatiebewijs. Niet van toepassing vereist onderbouwing. Ontbrekende verplichte tests blokkeren technische vrijgave. Conceptcode en documentatie mogen als NOT_EXECUTED worden gepubliceerd, zonder technische acceptatie.

Bron: expliciete huidige gebruikersaanvulling 2026-11-06; exact bericht-ID UNVERIFIED.

## Besluit 5 - ADMIN_LOGGER officiële pilot

ID: REGIE-POLICY-20261106-005. Beleidsstatus: APPROVED; technische uitvoering: NOT_AUTHORIZED door deze registratie.

ADMIN_LOGGER is de officiële eerste pilot voor toepassing en beoordeling van het ontwikkelkader. De aanwijzing is beleidsmatig; zij verklaart de huidige module niet conform of RAC-ready en verleent geen code- of deploymentopdracht.

Bron: huidige expliciete gebruikersopdracht 2026-11-06; oudere exacte goedkeuringsbeurt UNVERIFIED.

## Besluit 6 - Integrale herbeoordeling vóór refactoringontwerp

ID: REGIE-POLICY-20261106-006. Beleidsstatus: APPROVED; technische uitvoering: NOT_AUTHORIZED door deze registratie.

Eerst de bestaande module integraal herbeoordelen, met RAC-readiness als hoogste prioriteit. Daarna pas een samenhangend refactoringontwerp. In deze registratie worden geen codewijzigingen uitgevoerd of geautoriseerd. Oracle 19c Enterprise / beoogd drie-node RAC blijft de doelrandvoorwaarde; geschiktheid is niet aangetoond.

Bron: huidige expliciete gebruikersopdracht 2026-11-06; oudere exacte goedkeuringsbeurt UNVERIFIED.

## Besluit 7 - Vier verplichte pilotvoorwaarden

ID: REGIE-POLICY-20261106-007. Beleidsstatus: APPROVED; technische uitvoering: NOT_AUTHORIZED door deze registratie.

De pilot vereist: (1) vastgelegde architectuurafhankelijkheden; (2) een functionele baseline; (3) meetbare acceptatiecriteria; (4) relayregistratie van scope, besluiten, bewijs en open punten. Deze voorwaarden moeten aantoonbaar zijn ingevuld; deze beleidsregistratie claimt geen vervulling ervan.

Bron: huidige expliciete gebruikersopdracht 2026-11-06; oudere exacte goedkeuringsbeurt UNVERIFIED.

## Besluit 8 - Integrale pilotreview met aanvulling bruikbaarheid

ID: REGIE-POLICY-20261106-008. Beleidsstatus: APPROVED; technische uitvoering: NOT_AUTHORIZED door deze registratie.

Beoordeel de volledige ADMIN_LOGGER-module: RAC-readiness, codekwaliteit, functionele compatibiliteit en afhankelijkheden, samenhangend verbeterplan en testontwerp. Toets dit aan het complete ontwikkelkader; technische consolidatie mag begrijpelijke functionaliteit niet ongemerkt verwijderen. ADMIN_LOGGER__REGIE bezit technische analyse en modulevoorstellen; TETOOLS__REGIE beoordeelt suitearchitectuur, samenhang en afwijkingen. Ontwerp volgt na de verplichte herbeoordeling en functionele baseline.

Bron: chatgpt-conversation://6ae9e9eb-6400-83eb-859c-580027d25466; goedkeurende gebruikersbeurt b850fca2-4020-44ba-ab0d-4a9bce02ae3d.

## Besluit 9 - Mensgerichte bruikbaarheid als zevende categorie

ID: REGIE-POLICY-20261106-009. Beleidsstatus: APPROVED; technische uitvoering: NOT_AUTHORIZED door deze registratie.

Mensgerichte bruikbaarheid en functionele consistentie zijn de zevende verplichte ontwikkelcategorie, gelijkwaardig aan de zes technische categorieën, voor nieuwe en bestaande ADMIN_*-modules. Behoud begrijpelijke publieke functies, naamgeving, parameters, configuratie en aanroepgedrag tenzij afzonderlijk goedgekeurd. Technische consolidatie kan achter een stabiele interface plaatsvinden; zij rechtvaardigt op zichzelf geen functieverlies.

Bron: chatgpt-conversation://6ae9e9eb-6400-83eb-859c-580027d25466; goedkeurende gebruikersbeurt 2bc0f67f-329f-4da5-bd7a-b54ccd2ab01c.

## Besluit 10 - Suitebrede functionele interface- en gebruiksstandaard

ID: REGIE-POLICY-20261106-010. Beleidsstatus: APPROVED; technische uitvoering: NOT_AUTHORIZED door deze registratie.

Er komt een afzonderlijk functioneel onderdeel van de suitebrede ontwikkelstandaard. ADMIN_LOGGER is het eerste praktijkvoorbeeld voor API-catalogus, gebruiksscenario's, naamgeving, configuratie, fouten, aanroepgedrag en wijzigingsbeoordeling. Leid herbruikbare conventies af; verklaar niet de volledige LOGGER-API verplicht voor alle modules. De uitwerking van concrete conventies blijft afzonderlijk te beoordelen.

Bron: chatgpt-conversation://6ae9e9eb-6400-83eb-859c-580027d25466; goedkeurende gebruikersbeurt 44d9fe0a-8015-4896-97ed-cf75f8269eb3.

## Besluit 11 - Functionele baseline vóór ontwerp

ID: REGIE-POLICY-20261106-011. Beleidsstatus: APPROVED; technische uitvoering: NOT_AUTHORIZED door deze registratie.

Vóór het refactoringontwerp: inventariseer publieke routines/parameters/defaults, bestaand functioneel gedrag inclusief configuratie en foutafhandeling, de gebruiksdoelen en werkelijke consumers/afhankelijkheden. Classificeer onderbouwd met broncode, documentatie, gebruiksscenario's en beschikbare tests: BEHOUDEN = gewenst gedrag dat compatibel blijft; CORRIGEREN = aantoonbaar onjuist gedrag waarvoor een herstelvoorstel nodig is; HEROVERWEGEN = doel of wenselijkheid onvoldoende duidelijk. Bestaand gedrag wordt standaard behouden; defect of onveilig/RAC-incompatibel gedrag wordt niet automatisch correct verklaard. Functionele of publieke interfacewijzigingen vragen afzonderlijke goedkeuring.

Bron: chatgpt-conversation://6ae9e9eb-6400-83eb-859c-580027d25466; goedkeurende gebruikersbeurt be693f26-7ed9-4b27-8627-25758514ea88.

## Besluit 12 - Doelstelling ADMIN_LOGGER-pilot

ID: REGIE-POLICY-20261106-012. Beleidsstatus: APPROVED; technische uitvoering: NOT_AUTHORIZED door deze registratie.

ADMIN_LOGGER wordt integraal herbeoordeeld met RAC-readiness als technische prioriteit. Het primaire doel is een technisch en functioneel operationele module, niet nieuwe functionaliteit. Refactoring en noodzakelijke defectcorrecties mogen gezamenlijk worden gepland en uitgevoerd na goedkeuring van het technische ontwerp. Behoud bestaande functioneel gewenste gebruiksmogelijkheden. Nieuwe functionaliteit is geen eerste prioriteit; voor RAC-compatibiliteit noodzakelijke nieuwe functionaliteit mag worden voorgesteld met onderbouwing, impactbeoordeling en expliciete goedkeuring. Publieke interfacewijzigingen vereisen afzonderlijke goedkeuring. De bevroren bronrelease blijft ongewijzigd. Registreer Oracle-/RAC-readiness uitsluitend op basis van daadwerkelijk uitgevoerde en gedocumenteerde tests. Deze overdracht autoriseert geen broncodewijzigingen.

Bron: expliciete huidige gebruikersaanvulling 2026-11-06; exact bericht-ID UNVERIFIED.

## Samenhang en vervolgeigenaarschap

De actuele volgorde is: architectuurafhankelijkheden en integrale herbeoordeling met RAC-prioriteit; functionele baseline met BEHOUDEN/CORRIGEREN/HEROVERWEGEN; meetbare acceptatiecriteria en herleidbaar testontwerp; daarna refactoringontwerp; afzonderlijke ontwerp- en eventuele interfacegoedkeuring; pas daarna toegestane uitvoering en daadwerkelijk testen. Relayregistratie loopt door alle stappen. Analyse en baseline mogen samen worden opgebouwd; het ontwerp mag de baseline niet voorafgaan.

ADMIN_LOGGER__REGIE bezit de moduleanalyse en voorstellen (LOG-OPEN-01..05 en RAC-A-001..012); TETOOLS__REGIE bezit suitekader, afwijkingsgoedkeuring en functionele conventies. RAC-ARCH-01..03 en Issue #55 blijven open. Geen nieuw technisch suitebesluit, datatype, grant, object, API, toolafhankelijkheid of gedeelde identity-migratie wordt hiermee goedgekeurd. Oracle-compilatie/runtime/performance/failover: NOT_EXECUTED door deze sessie; RAC-readiness: NOT_DEMONSTRATED. Geen code of bevroren release gewijzigd.

## Relatie met ouder concept en afwijkingshistorie

Deze twaalf goedgekeurde beleidsbesluiten zijn leidend boven de onderstaande conceptuitwerking. Alleen het beleid is goedgekeurd; de technische tekst uit concept 001 wordt niet als geheel goedgekeurd of herschreven. De oudere concept-testmatrix is hulpmateriaal en vervangt de acht categorieën niet.

REGIE-POLICY-20261106-003 volgt uitsluitend het ruimere afwijkingsmandaat van REGIE-20261103-001 op. De oorspronkelijke ledgerrecord en architectuurtekst blijven als historie bewaard; centrale goedkeuring is nu verplicht. Ook de oudere slotzin onder REGIE-20261103-003 in SUITE_ARCHITECTURE.md heeft geen zelfstandige module-goedkeuringswerking meer. Overige onderdelen van die besluiten blijven gelden.

---

# Historische technische conceptuitwerking 001 - PROPOSED

Onderstaande oorspronkelijke tekst is behouden als concept en historische momentopname. Verwijzingen naar een nog te beoordelen ontwikkelstandaard gelden voor de concrete uitwerking; zij trekken het bovenstaande goedgekeurde beleidskader niet in.

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
