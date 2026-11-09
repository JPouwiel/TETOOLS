# TETOOLS — geconsolideerd beleidskader 1–39 (CONCEPT ter vaststelling)

**Status van dit document: PROPOSED / REVIEW.** De onderliggende 39 besluiten zijn APPROVED; deze nieuwe samengestelde presentatie is nog niet als leidend beleidsdocument vastgesteld. Geen nieuwe beleidsregels worden zonder gebruikersgoedkeuring ingevoerd. Datum: 2026-11-09. Eigenaar: TETOOLS__REGIE. Scope: Oracle Database 19c Enterprise, beoogd drie-node RAC.

**Bronnen:** [Besluiten 1–12](../../TETOOLS_DEVELOPMENT_STANDARD.md), [besluiten 13–39](REGIE_DECISIONS_13_39_20261109.md), [review](../reviews/POLICY40_INITIAL_REVIEW_20261109.md), [goedgekeurde interpretaties F02–F04](../reviews/POLICY40_F02_F03_F04_APPROVAL_20261109.md). Historische documenten en oorspronkelijke besluit-ID's blijven leidend tot expliciete vaststelling van deze consolidatie. Exacte oorspronkelijke chatbericht-URL's waar aangegeven UNVERIFIED. Oracle-tests NOT_EXECUTED; RAC-readiness NOT_DEMONSTRATED.

## Normatieve leesregels — voorstel voor ordening, geen nieuwe goedkeuring

1. Iedere hieronder opgenomen besluittekst behoudt haar oorspronkelijke besluit-ID en beleidsmatige APPROVED-status; de nieuwe documentstatus blijft PROPOSED.
2. Bij interpretatieverschil gaat een expliciet goedgekeurd later besluit boven een algemenere eerdere formulering voor het specifieke onderwerp, zonder de historie te wissen.
3. Technische ontwerpen, testresultaten, module-implementaties en afwijkingen krijgen afzonderlijke bevoegdheid en bewijs; beleidsgoedkeuring is geen technische acceptatie.

## Deel A — Goedgekeurde besluiten 1–12 (tekst uit bestaande bron)

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


## Deel B — Goedgekeurde besluiten 13–39 (tekst uit bestaande bron)

## Besluit 13 — REGIE-POLICY-20261109-13

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Vier readinessniveaus: build, functioneel, RAC-ready, technische release; echte RAC niet aangetoond; synthetische toets slechts voorlopig.

## Besluit 14 — REGIE-POLICY-20261109-14

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Synthetische RAC-testmatrix verplicht; ontbreken echte RAC blokkeert ontwikkeling niet, wel definitieve RAC-claim.

## Besluit 15 — REGIE-POLICY-20261109-15

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Risicoklassen BLOCKER, REQUIRES_MITIGATION, DEFERRED_VALIDATION en ACCEPTED_LIMITATION.

## Besluit 16 — REGIE-POLICY-20261109-16

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Samenhangende wijzigingen per revisiepakket, individuele traceerbaarheid behouden.

## Besluit 17 — REGIE-POLICY-20261109-17

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Afhankelijkheidsgedreven volgorde; RAC- en funderingscorrecties eerst, bruikbaarheid behouden.

## Besluit 18 — REGIE-POLICY-20261109-18

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Regressie- en herstelmaatregelen per pakket; risicoproportionele uitzondering bij aantoonbaar laag risico; onomkeerbare DB-ingrepen apart goedkeuren.

## Besluit 19 — REGIE-POLICY-20261109-19

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Module-regie mag vereenvoudigde toetsen voor laag risico goedkeuren; middel/hoog/suite-impact naar centrale regie.

## Besluit 20 — REGIE-POLICY-20261109-20

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Kritieke bestaande defecten verhelpen; overige expliciet registreren en risicogestuurd uitstellen.

## Besluit 21 — REGIE-POLICY-20261109-21

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Mensgerichte, suitebrede functionele API; interne consolidatie mogelijk.

## Besluit 22 — REGIE-POLICY-20261109-22

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Publieke API standaard achterwaarts compatibel; breaking changes alleen met afzonderlijk goedgekeurde migratie.

## Besluit 23 — REGIE-POLICY-20261109-23

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Transactie- en exceptioncontract: ADMIN_LOGGER bezit eigen transacties; autonome log-, diagnostische, sessie- en configuratieoperaties; samenhangende beheerwijzigingen atomair in één autonome transactie; diagnostiek na beheerrollback zelfstandig bewaren. Fallback via exception-API zonder recursieve opslag. log_runtime best-effort voor incidentele registratieproblemen maar sessiebrede fout mag onderbreken; log_info/log_warning interne foutafhandeling; log_error/log_debug/log_*_force verplichte gebruiker- én applicatieterugmelding. Aanroeper mag exception lokaal afhandelen of hoger doorgeven; niet stilzwijgend negeren. Foutklassen registratie, sessiebreed, diagnostische fallback. Zes acceptatiecriteria: aanroepertransactie intact; atomaire beheerwijzigingen; duurzame diagnostiek; juiste foutclassificatie; runtime onderscheid; geen recursieve fallback. Technisch NOT_EXECUTED.

## Besluit 24 — REGIE-POLICY-20261109-24

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Foutisolatie voor niet-kritieke ondersteuning; kritieke fouten niet stilzwijgend wegvangen; zie aangescherpt besluit 23.

## Besluit 25 — REGIE-POLICY-20261109-25

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Prioriteit configuratie: centraal, sessie, per-aanroep, volgens expliciet contract.

## Besluit 26 — REGIE-POLICY-20261109-26

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Fysieke Oracle-sessie INST_ID/SID/SERIAL# onderscheiden van logische LOGSESSION_ID; RAC-bewust.

## Besluit 27 — REGIE-POLICY-20261109-27

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Minimale expliciete locking; integriteit voorop, geen onnodige seriële bottlenecks.

## Besluit 28 — REGIE-POLICY-20261109-28

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Performance risicogestuurd onderzoeken en benchmarken bij onderbouwd vermoeden, niet pas na bewezen incident.

## Besluit 29 — REGIE-POLICY-20261109-29

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Pragmatische testautomatisering; utPLSQL slechts onderzoeksoptie, geen installatie aangenomen.

## Besluit 30 — REGIE-POLICY-20261109-30

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Least privilege, gecontroleerde publieke API en afzonderlijke functionele autorisatielaag.

## Besluit 31 — REGIE-POLICY-20261109-31

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Database-identiteit, functionele eindgebruiker en applicatie-/sessiecontext onderscheiden; alleen betrouwbaar vastgestelde identiteit gebruiken.

## Besluit 32 — REGIE-POLICY-20261109-32

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

ADMIN_LOGGER voor operationele logging en diagnostiek; audit als afzonderlijke verantwoordelijkheid, exacte scope nader onderzoeken.

## Besluit 33 — REGIE-POLICY-20261109-33

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Onafhankelijke moduleversies met suite-compatibiliteitsmanifest en reproduceerbare installatiescripts.

## Besluit 34 — REGIE-POLICY-20261109-34

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Schema-evolutie met databehoud; bij breaking upgrade relevante gegevens migreren, geen onbeperkte verouderde compatibiliteitslast.

## Besluit 35 — REGIE-POLICY-20261109-35

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Self-governing: periodieke controle van eigen databaseobjecten tegen vastgestelde baseline en afwijkingen rapporteren/herstel adviseren. Geen autonome herinstallatie, vervanging of reparatie van databaseobjecten. Veilig herstel van eigen tijdelijke interne runtimegegevens toegestaan onder controleerbare voorwaarden; geen algemene machtiging voor willekeurige datamutaties. Technische mechanismen nog te toetsen. 35-OPEN-01 en 35-OPEN-02 beleidsmatig CLOSED.

## Besluit 36 — REGIE-POLICY-20261109-36

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Functionele documentatie inline PL/SQL, procedure-helpparameter en package-help; Confluence voor architectuur, GitHub voor techniek.

## Besluit 37 — REGIE-POLICY-20261109-37

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Risicogestuurde acceptatie/release; onderscheid intern versus extern installeren; frozen releases ongewijzigd.

## Besluit 38 — REGIE-POLICY-20261109-38

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

TETOOLS intern verantwoordelijk voor architectuur, ontwikkeling, interne acceptatie en release; externe DBA kan installatie volgens eigen beleid blokkeren, niet zelfstandig ontwerp bepalen.

## Besluit 39 — REGIE-POLICY-20261109-39

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Externe release-overdracht verplicht uitsluitend punten 1,2,3,5,6,8: release-ID/versie, scripts, privileges, migratie, impact en herstel. Andere interne controles blijven waar relevant bestaan.


## Deel C — Goedgekeurde interpretaties bij punt 40

**F02 (besluiten 4,18,19):** acht testcategorieën verplicht beoordelen; testdiepgang risicogestuurd; onderbouwde N/A; laag risico modulemandaat, middel/hoog/suite-impact centraal; geen vrijgave zonder verplicht bewijs.

**F03 (besluiten 23,24):** het specifieke LOGGER-foutcontract uit 23 concretiseert algemene foutisolatie uit 24; API-afhankelijke meld- en exceptionsemantiek behouden. Technische implementatie en Oracle-test open bij ADMIN_LOGGER__REGIE.

**F04 (besluiten 23,34,35):** veilig herstel van eigen tijdelijke runtimegegevens onder toetsbare voorwaarden toegestaan; geen autonoom object-DDL-herstel, herinstallatie of willekeurige datareconstructie. Technische voorwaarden bij moduleontwerp en tests uitwerken.

## Deel D — Openstaande controles en besluitvorming

- **F01:** na goedkeuring van dit document één expliciet leidende ingang aanwijzen; de historische brondocumenten blijven voor provenance beschikbaar.
- **F05:** RAC-readiness blijft NOT_DEMONSTRATED zolang relevante echte drie-node RAC-proeven ontbreken; synthetische tests zijn voorlopig.
- **F06:** externe overdrachtsset van besluit 39 is beperkt; interne acceptatie en bewijsvereisten van besluit 4 blijven van kracht.
- **F07:** oorspronkelijke exacte chatbericht-URL's voor delen van 1–39 zijn UNVERIFIED; niet reconstrueren.
- **Punt 40:** de definitieve normatieve consolidatie en eventuele interpretatie van bovenstaande leesregels vereisen expliciete goedkeuring van de gebruiker.

**Niet gewijzigd:** bestaande modulebroncode, frozen releases, Oracle-objecten en historische goedgekeurde besluiten.
