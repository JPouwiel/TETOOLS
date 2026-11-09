# Onafhankelijke technische review ADMIN_LOGGER stap 4 — PR #102

**Review-ID:** LOGGER-STEP4-REVIEW-20261109-001  
**Opdracht:** [Issue #104](https://github.com/JPouwiel/TETOOLS/issues/104), RELAY-HANDOFF-20261109-LOGGER-REVIEW-001.  
**Reviewer:** `a9edd3a9-d49a-4cb8-a102-868f3808e7bf`, lokaal gegenereerde UUID; onafhankelijke Codex-reviewsessie, niet de auteur/module-regie. GitHub-schrijfaccount JPouwiel identificeert niet de sessie.  
**Datum:** 9 november 2026. **Autorisatie:** STATIC_REVIEW_ONLY; ORACLE_EXECUTION_NOT_GRANTED.  
**Eindoordeel: FAIL. PR #102 is niet mergegereed. Twee open P1-bevindingen blokkeren merge.**

## 1. Scope, revisie en bronnen

Volledige actuele PR-head beoordeeld: `5c25e83604d8bb0eeb2680a372b3e1b808c320c5`, branch `feature/admin-logger-step4-testprep-20261109`. PR-mergebase: `a317d874e8672cb786b8d3cf0efcbbaeb9de3822`; gelezen actuele main-basis: `d7659bf35549ae4840a32b051703d9d9d065004b`. De volledige diff bevat **24 bestanden**: alle **23** pakketbestanden onder `modules/ADMIN_LOGGER/tests/step4_20261109_001/` plus de activiteit van de bestaande module-regie in SESSION_REGISTRY.json. De tekst in de oorspronkelijke overdracht/PR-body met 22 bestanden is verouderd. Ook de later toegevoegde `41`, `51`, `61` en `62` zijn beoordeeld.

Revisie onder test: `modules/ADMIN_LOGGER/src/20261109_501_DEV/`. Gelezen: de actuele startprocedure, relaycontract, MANUAL_HANDOFF, PROJECT, CURRENT_STATUS, MODULE_REGISTRY, SESSION_REGISTRY, CHANGE_REGISTER, module CURRENT_STATUS/DECISIONS/OPEN_POINTS, centraal [stap-4-dossier uit PR #101](https://github.com/JPouwiel/TETOOLS/blob/d7659bf35549ae4840a32b051703d9d9d065004b/COMMUNICATION_RELAY/reviews/ADMIN_LOGGER_STEP4_ORACLE_TEST_PREPARATION_20261109.md), LDR-testplan en -traceermatrix, DEV-manifest en [onafhankelijke bronreview uit PR #98](https://github.com/JPouwiel/TETOOLS/blob/d7659bf35549ae4840a32b051703d9d9d065004b/COMMUNICATION_RELAY/reviews/ADMIN_LOGGER_PR97_STATIC_REVIEW_20261109.md). PR #98 betreft alleen de twee bron-DDL-correcties; die PASS geldt niet voor dit testpakket.

Alle hierna genoemde pakketpaden zijn relatief aan `modules/ADMIN_LOGGER/tests/step4_20261109_001/`. Regelnummers verwijzen uitsluitend naar bovenstaande vastgelegde head. **BODY**, **SPEC** en **TABLE** verwijzen naar de gelijknamige bestanden van de DEV-bronset. Een volledige bestands-/blobinventaris, include-padcontrole en bronvergelijking staan in [machineleesbaar bewijs](ADMIN_LOGGER_STEP4_REVIEW_20261109_EVIDENCE.json).

**Methode en grenzen:** broncode en volledige diff gelezen; Git-objecten, paden, IDs, JSON en documentatie gecontroleerd. Geen databaseverbinding, Oracle-DDL, SQL-test, SQL*Plus/SQLcl-sessie, compiler, benchmark, RAC-proef, foutinjectie of herstelproef uitgevoerd. Verwacht gedrag hieronder is een statische gevolgtrekking, geen gemeten database-uitkomst. Testscripts en modulebron zijn niet aangepast.

## 2. Bevindingen en concrete correctieopdracht

Prioriteit P1 = veiligheidsblokkade; P2 = relevante onvolledigheid/onjuiste acceptatie of uitvoerbaarheid; P3 = documentatie. Eigenaar van alle testcorrecties: **ADMIN_LOGGER__REGIE**. DBA beslist mee over fixtures/omgeving; TETOOLS__REGIE beslist over governance en de uiteindelijke mergegate. De reviewer keurt geen nieuwe architectuur of testuitvoering goed.

### LGR4-01 — P1 — losse schrijvende scripts omzeilen de veiligheidscontroles

**Locaties:** `scripts/30_T03_functional.sql:2–20`, `40_T04_regression.sql:2–14`, `41_T04_overloads.sql:3–61`, `51_C01_caller_rollback.sql:4–24`, `61_T06_guard_client_A.sql:2–6`, `62_T06_guard_client_B.sql:2–6`; tegenover README.md:7–14. Alleen `10_install.sql:8` roept preflight aan.

Een directe `@scripts/30_T03_functional.sql` schrijft naar hardgecodeerd TETOOLS zonder EXECUTION_APPROVED, DBA_ENV_APPROVED, database-, PDB-, CON_ID- of gebruikercontrole. `40/41/51` roepen de package aan; de eerste referentie kan zelf al autonome registratie/configuratie committen (BODY:1882–1925). `61/62` kunnen de gedeelde guard blokkeren. Dit vereist alleen dat de verbonden principal de betreffende rechten heeft; de private configuratie hoeft niet geladen te zijn. Een oude goedkeuring in een andere sessie voorkomt ook geen reconnect naar een verkeerd doel. Een gewone rollback maakt autonome wijzigingen niet ongedaan ([O3]).

**Correctie:** vóór de eerste package-aanroep, DML of lock in ieder operationeel instappunt een gedeelde, niet-schrijvende en fail-closed doel-/autorisatiecontrole uitvoeren, met voor de fase goedgekeurde principal, DB/PDB/CON_ID en expliciete toegestane testcase/handeling. Hercontroleer de actuele verbinding, vertrouw niet op een eerder PASS-bericht. Gebruik voor installatie een aanvullende lege-schema-controle; zie LGR4-03. Ontbrekende configuratie moet stoppen vóór elke risicovolle actie. Leg de negatieve startscenario's vast voor latere afzonderlijk geautoriseerde validatie.

**Invloed:** directe veiligheids- en mergeblokkade; geen uitvoeringsvrijgave mogelijk zolang de scripts de README-garantie niet afdwingen.

### LGR4-02 — P1 — lege configuratiewaarden laten preflightcontroles overslaan

**Locatie:** `scripts/00_preflight.sql:13–24`, in combinatie met `env.template.sql:3–11`.

De tests gebruiken negatieve vergelijkingen zoals `'&&EXECUTION_APPROVED' <> 'YES'`. Bij een gedefinieerde lege waarde ontstaat in Oracle een NULL-expressie. Wanneer beide approvalvelden leeg zijn, is de OR-expressie NULL; de IF voert de fouttak alleen uit bij TRUE ([O2], [O9]). Hetzelfde probleem treft lege TARGET_PDB/TARGET_CON_ID en TARGET_DB_UNIQUE_NAME. Statisch tegenvoorbeeld: een niet-root PDB, TETOOLS als gebruiker/schema, geen bestaande loggerobjecten, TARGET_SCHEMA=TETOOLS en lege approval-/doelvelden kan de relevante IF-takken passeren. Er is geen Oracle-run van dit tegenvoorbeeld uitgevoerd. Ontbrekende DEFINE-variabelen kunnen daarnaast interactieve substitutievragen opleveren, geen aantoonbare weigering.

**Correctie:** valideer verplichte waarden expliciet op NULL/leegte, toegestane inhoud en numeriek bereik voordat ze worden vergeleken. Approval moet uitsluitend bij de exacte toegestane waarde slagen; iedere andere toestand weigeren. Leg vast hoe ontbrekende variabelen zonder interactieve bypass worden afgehandeld. Vereis run-ID en verwijzing naar het afzonderlijke GO; een zelf ingevulde YES is geen bewijs van een centraal besluit. Neem lege, ontbrekende, ongeldige en verkeerde DB/PDB/CON_ID-gevallen op in de correctiereview.

**Invloed:** ook het installatiepad met preflight is niet fail-closed; P1-mergeblokkade.

### LGR4-03 — P2 — preflight kent geen veilige fase na installatie

**Locatie:** `scripts/00_preflight.sql:26–28`; README.md:23–30.

De preflight weigert zodra een ADMIN_LOGGER-object bestaat. Daardoor kan dezelfde controle niet vóór de latere DML-/API-tests worden hergebruikt. Tegelijk controleert LIKE 'ADMIN_LOGGER%' alleen een deel van de objectinventaris, niet het in G02 vereiste lege schema; underscores zijn bovendien LIKE-wildcards. Bestaande andere objecten worden niet geïnventariseerd. De schone-installatievoorwaarde en de algemene veiligheidscontrole zijn vermengd.

**Correctie:** definieer controle voor doelidentiteit/autorisatie die ook op het geïnstalleerde schema bruikbaar is, en een afzonderlijke installatiefase met DBA-geautoriseerde volledige objectinventaris. Controleer in de testfase juist de verwachte geïnstalleerde objecten, revisie en fixturestatus. Geen package-aanroep gebruiken voor deze veiligheidscontrole vanwege package-initialisatie.

**Invloed:** noodzakelijke voorwaarde voor herstel van LGR4-01 en herhaalbare uitvoering; geen bestaande schema's stilzwijgend als leeg behandelen.

### LGR4-04 — P2 — incident-PK-scenario is niet Oracle-19c-uitgewerkt en guard krijgt verkeerd test-ID

**Locaties:** `casebook.md:15`, `scripts/30_T03_functional.sql:16–23`; TABLE:149–173.

T03-02 verlangt een duplicate incident_id en suggereert OVERRIDING SYSTEM VALUE bij GENERATED ALWAYS. Dat is geen ondersteunde INSERT-route in de Oracle 19c-SQL-grammatica; Oracle documenteert dat expliciete INSERT/UPDATE van een ALWAYS identity een fout geeft ([O4]). Een dergelijke fout bewijst geen PK-conflict. Er is geen uitvoerbaar incidentfixture. Ondertussen meldt regel 18 `T03-02 PASS guard row=1`, hoewel T03-02 in het casebook de incident-PK-test is. De commentaarregels 22–23 noemen het incident vervolgens T03-03, opnieuw strijdig met de matrix.

**Correctie:** verwijder de ongeschikte syntaxsuggestie, laat een afzonderlijk geautoriseerd 19c-fixtureontwerp beoordelen en leg exact vast welke constraint/verwachte fout wordt getest. Geen ALTER IDENTITY of fixture-DDL improviseren. Houd dit scenario BLOCKED zolang een veilige methode ontbreekt. Corrigeer guard-/incident-ID's in script, casebook, trace en resultaatformulier; geen incident-PASS voor alleen een guardtelling.

**Invloed:** Oracle-compatibiliteit en betrouwbaarheid van acceptatie voor RAC-A-011/T03-02 ontbreken.

### LGR4-05 — P2 — overloadmatrix controleert aanroepbaarheid, niet regressiegedrag

**Locaties:** `scripts/40_T04_regression.sql:5–17`, `41_T04_overloads.sql:11–59`, `casebook.md:18–20`.

De 36 LOG-procedureaanroepen en negen VARCHAR2-functieaanroepen in `41` sluiten statisch aan op SPEC:397–405,457–491: vier datatypen voor vijf gewone en vier FORCE-categorieën; geen LOG_DEBUG_FORCE in de SPEC. Dit is geen geconstateerde overload-syntaxfout. De functie-uitkomsten worden echter steeds overschreven; er zijn geen assertions op return, tekst, target, categorie, batch of default datumformaat. Geen gecontroleerde logging/debugconfiguratie of herstel. De bron initialiseert logging/debug OFF (BODY:1909), zodat gewone calls zonder logrij kunnen voltooien; FORCE kan wel autonoom schrijven. T04-03 heeft geen script, ondanks bekende BACKUP/RESTORE-modes en vereiste vijftekensleutel in BODY:948–1011.

**Correctie:** leg per signature concrete beginconfiguratie, verwachte uitkomst, bewijs en herstel vast; assert elke return afzonderlijk en verifieer TABLE/SCREEN en relevante defaults. Werk toggles, BACKUP/RESTORE met sleutel, clear-scope en overige publieke API's uit in afzonderlijk geautoriseerde fixtures. Houd smoke/callability en gedragsacceptatie zichtbaar onderscheiden. Behoud de gepinde productie-API.

**Invloed:** T04 en C05 kunnen op basis van deze scripts geen volledige PASS krijgen; broncompatibiliteit is slechts statisch ondersteund ([O5]).

### LGR4-06 — P2 — C01 assert alleen callerrollback

**Locatie:** `scripts/51_C01_caller_rollback.sql:1–23`; `casebook.md:22,40`.

Alleen l_after=l_before voor de businessfixture wordt afgedwongen. Beide diagnostische tellingen worden alleen afgedrukt. Alleen TABLE als target is onvoldoende: logging moet ook aan staan en debug mag niet naar SCREEN omleiden (BODY:1394–1408). De standaardinitialisatie is OFF. Een run zonder autonome logrij kan dus zonder fout eindigen. Het script waarschuwt terecht dat dit geen automatische PASS is, maar levert de helft van het contract niet uitvoerbaar op. Fixturedefinitie, uniek run-ID en zelfstandige controle van logsession/marker ontbreken in het pakket.

**Correctie:** laat het businessfixture afzonderlijk autoriseren; valideer unieke niet-lege run-ID, gecontroleerde config en schone beginsituatie. Assert zowel verdwijnen van de callerrow als de contractueel toegestane blijvende diagnostiek met exacte marker/session-ID. Leg bewaartermijn en geautoriseerde opruiming van autonome rijen vast. Geen PASS bij gelijke diagnostische tellingen tenzij een expliciet ander, afzonderlijk goedgekeurd contract wordt getest.

**Invloed:** C01/T05-02 blijft gedeeltelijk en afhankelijk van aanvullende fixtures; rollback van de caller bewijst geen autonome duurzaamheid ([O3]).

### LGR4-07 — P2 — verwachte locktimeout verlaat client B als fout

**Locaties:** `scripts/61_T06_guard_client_A.sql:4–6`, `62_T06_guard_client_B.sql:2–6`; `casebook.md:27`.

De bedoelde ORA-30006 van client B wordt niet lokaal afgehandeld. WHENEVER SQLERROR EXIT beëindigt de client vóór de PROMPT en rollback op regels 5–6 ([O1]). Een exit is wel te registreren, maar de huidige procedure onderscheidt niet objectief de verwachte timeout, een andere fout of onverwacht succes. Client A blijft afhankelijk van handmatige rollback. De bestanden bewijzen evenmin guardvrijgave, herstel of het packagepad; ze vergrendelen rechtstreeks de tabelrij.

**Correctie:** vang uitsluitend de exact verwachte locktimeout lokaal af, meet begin/eind en verifieer de afgesproken timingtolerantie; onverwachte fout of succes terwijl A aantoonbaar vasthoudt moet FAIL zijn. Documenteer handoff/barrière, sessie-ID's, rollback bij beide clients en een volgende geslaagde lockpoging als vrijgavebewijs. Meet packageconcurrency apart.

**Invloed:** T06-01 mist reproduceerbare PASS/FAIL en herstelbewijs; geen database-test geslaagd verklaard.

### LGR4-08 — P2 — traceerbaarheid verandert de betekenis van bestaande risico's

**Locaties:** `traceability.md:9–15,19–22`, `casebook.md:14–20,27–35`; vergeleken met canonieke `modules/ADMIN_LOGGER/docs/reports/ADMIN_LOGGER_LDR_TRACE_20261109.md:9–23` en OPEN_POINTS.md.

RAC-A-003 gaat over grants/containerzichtbaarheid, niet guardprogressie. RAC-A-006 gaat over metadatareload/per-line commits, niet alleen uniqueness. RAC-A-009 gaat over klok-/retentiegrenzen, niet algemene performance/servicebewijs. LOG-OPEN-03 betreft installer 003, en LOG-OPEN-04 de vergelijking met voorstel 027 en publiek backup/restoregedrag; hun huidige mapping naar loggingtargets respectievelijk audit/DBA-restore dekt die betekenis niet. Een DBA-snapshotrestore is een andere test dan session_details_revert.

**Correctie:** behoud oorspronkelijke omschrijvingen en voeg per risico concrete dekkende scenario's toe. Neem cutoff/tijdzone/grensgevallen voor RAC-A-009 op; privileges/zichtbaarheid voor 003; reload/commits voor 006; expliciete baseline-versus-voorstel-027- en BACKUP/RESTORE-vergelijking voor LOG-OPEN-04. Markeer niet gedekte aspecten expliciet OPEN/BLOCKED; hernummer bestaande risico's niet.

**Invloed:** aanwezigheid van alle IDs bewijst geen inhoudelijke dekking; huidige trace kan onterecht acceptatie suggereren.

### LGR4-09 — P2 — remote-purgeproef kan zonder relevante kandidaten slagen

**Locatie:** `casebook.md:30–33`, `scripts/70_T07_rac.sql:5–16`; BODY:1726–1746,1755–1768.

Het runbook opent live sessies en laat elders cleanup uitvoeren, zonder de leeftijdselectie van de werkelijke purge vast te leggen. De bron selecteert pas registraties waarvan TRUNC(logon_time) vóór de cutoff minus drie dagen ligt. Nieuw geopende sessies vallen bij de standaardcutoff buiten die selectie. Overleving van zulke rijen toont dus niet aan dat remote liveness correct werkt. `70` bevat alleen lokale identiteit; INST_ID, SERIAL#, AUDSID, service en de observerqueries zijn commentaar. Geen uitgewerkte drie-node-synchronisatie, visibility-denial, failover/replay of cross-node-writefixture.

**Correctie:** definieer met DBA een geïsoleerde, geautoriseerde proef waarin echte live remote sessies aantoonbaar binnen de kandidaatselectie vallen, inclusief before_in, verwachte kandidaten en negatieve controle. Geen vervalste fysieke identiteit of onbeperkte purge. Koppel alle clients aan dezelfde goedgekeurde DB/PDB, drie onderscheiden instances en volledige sessiesleutels; leg reconnect/failover en cross-node-DML apart vast. Houd T07 BLOCKED zolang dit ontbreekt.

**Invloed:** risico op een vacuous PASS voor de belangrijkste RAC-P1; drie identityspools leveren geen RAC-/failoverbewijs.

### LGR4-10 — P2 — bewijsregistratie en herstel zijn nog geen reproduceerbaar pakket

**Locaties:** `results_template.csv:1–4`, `scripts/10_install.sql:6,18`, README.md:14–15, `casebook.md:21–36`, `scripts/90_cleanup.sql:1–7`.

Het resultaatformulier bevat slechts drie van 28 cases. Het enige ingebouwde spoolpad is `step4_install.log`, zonder run-ID; een volgende run kan eerder bewijs overschrijven. Andere scripts vertrouwen volledig op extern spooling zonder vastgelegde instapprocedure. Alleen `00` en `10` zetten WHENEVER OSERROR; een standalone client erft die instelling niet gegarandeerd. C02–C06, parallelle uniqueness, performance en DBA-herstel hebben nog geen exacte fixtures/runstappen/thresholds/watchdog. De blokkadestatus wordt eerlijk vermeld, maar een uitvoerbaar compleet pakket is daarmee nog niet geleverd.

**Correctie:** maak een volledige 28-case-resultaatinventaris met C01–C06-koppeling en expliciete BLOCKED/NOT_EXECUTED-statussen; koppel run-ID, DB/PDB/node, approval, script/sourcehashes en unieke spools. Leg clientinstellingen, OS-/SQL-foutbeleid en controle van SP2-/compilewaarschuwingen vast. WHENEVER SQLERROR vangt geen algemene SQL*Plus-commandofouten ([O1]). Werk ontbrekende modulescenario's uit; verkrijg DBA-goedgekeurd herstel met objectinventaris en stopcriteria. Beschouw gewone ROLLBACK nooit als DDL-herstel ([O6]).

**Invloed:** T05–T08 en T08-acceptatie blijven onvolledig. `90_cleanup.sql` is positief beoordeeld als **fail-closed blokkadescript**: geen DROP/TRUNCATE, onvoorwaardelijke fout vóór enig destructief werk. Het is geen herstelprocedure en bewijst geen herstelbaarheid.

### LGR4-11 — P2 — bekende afhankelijkheden en securitygevallen zijn nog niet concreet uitgewerkt

**Locaties:** `privileges.md:6–9,13`, `scripts/50_T05_security.sql:4–8`; BODY:163–198,265,364,448.

De bron laat nu al V$SESSION, DBA_SOURCE en DBMS_DEBUG_JDWP.current_session_serial zien, naast standaard Oracle-packages. De matrix laat de exacte dependency/grantlijst nog aan later onderzoek over; `50` drukt alleen AUTHID en ontvangen objectgrants af. Er zijn geen positieve/negatieve consumer- of onderhoudsproeven en geen assertions. USER_*-views beschrijven de huidige gebruiker; een aparte DBA-observer krijgt hiermee niet vanzelf TETOOLS-objectbewijs ([O7]).

**Correctie:** inventariseer de bekende statische en dynamische bronafhankelijkheden en laat DBA exacte direct/public grants en PDB-zichtbaarheid bevestigen; geen ANY-rechten als shortcut. Gebruik ownerqueries of geautoriseerde ALL_/DBA_-views met expliciete OWNER voor de observer. Definieer afzonderlijke geautoriseerde principals en positieve/negatieve tests, inclusief normale EXECUTE versus onderhoudsfunctionaliteit. Een mogelijke bron-/autorisatiewijziging blijft een apart module/centraal besluit.

**Invloed:** G03/T05-01/RAC-A-003/012 hebben nog geen doorslaggevend securitybewijs; het ontbreken van grants wordt niet als bewezen doelomgevingsdefect gepresenteerd.

## 3. Controle per bestand

| Bestand | Statische beoordeling / resterend bewijs |
|---|---|
| README.md | Autorisatiegrens en NOT_EXECUTED helder; veiligheidsgarantie niet afgedwongen, LGR4-01/03/10. Relatieve links correct. |
| STATIC_VERIFICATION.md | 23 bestanden, 15 SQL incl. template, 14 operationele scripts correct geteld; zelfcontrole is geen onafhankelijke PASS. |
| casebook.md | 28 unieke IDs; zes contracten aanwezig; concrete hiaten LGR4-04..10. |
| env.template.sql | Veilige standaard NO/UNVERIFIED; verplichte waarden nog niet fail-closed gevalideerd, LGR4-02. |
| environment.template.md | DBA-bewijs expliciet UNVERIFIED; geen werkelijk ingevulde omgeving. |
| manifest.md | Zes bronpins correct; Git-blobhash versus bestand-/databasehash correct onderscheiden. |
| privileges.md | Least-privilege-intentie goed; concrete afhankelijkheden/principals nog uitwerken, LGR4-11. |
| results_template.csv | Alleen drie voorbeeldregels; geen volledige case-registratie, LGR4-10. |
| traceability.md | Alle risico-ID's aanwezig maar betekenis gedeeltelijk verschoven, LGR4-08. |
| scripts/00_preflight.sql | Read-only, rootweigering en TETOOLS-check aanwezig; LGR4-02/03. |
| scripts/10_install.sql | Includevolgorde TABLE → SEQUENCE → SPEC → BODY → compileassertions logisch; alle zes @@-doelen bestaan; geen optional procedure geïnstalleerd. LGR4-02/10 blijven. |
| scripts/20_T02_compile.sql | USER_* kolommen en objectnamen passen statisch. Expliciete USER_ERRORS/statusassertion voorkomt vertrouwen op SHOW ERRORS alleen. Geen volledige dependency-, warning- of constraintkolom/indextype/validatiecontrole. |
| scripts/30_T03_functional.sql | Positieve indexsleutel en DUP_VAL_ON_INDEX-handler passend; rollback voor eigen DML. Guardtelling is geen incidenttest; LGR4-01/04. |
| scripts/40_T04_regression.sql | Bestaande version/help en vijf gewone VARCHAR2-procedures; package-initialisatie heeft autonome effecten. LGR4-01/05. |
| scripts/41_T04_overloads.sql | 36 procedures + 9 functies statisch op SPEC gematcht; CLOB/PLSQL-BOOLEAN/DATE/PLS_INTEGER passen; LGR4-01/05. |
| scripts/50_T05_security.sql | USER_PROCEDURES.AUTHID en USER_TAB_PRIVS_RECD-kolommen passen; uitsluitend observatie, LGR4-11. |
| scripts/51_C01_caller_rollback.sql | Afhankelijk van extern businessfixture; callerrollbackassertion aanwezig, diagnostiek niet geassert; LGR4-01/06. |
| scripts/60_T06_concurrency.sql | Alleen identityquery; commentaar hernummering T06-02/03 wijkt af van casebook. Geen workload/benchmark. |
| scripts/61_T06_guard_client_A.sql | FOR UPDATE WAIT 5 past bij guard; houdt transactionele lock vast voor handmatige release; LGR4-01/07. |
| scripts/62_T06_guard_client_B.sql | Geldige lockprobe; verwachte timeout wordt clientfout; LGR4-01/07. |
| scripts/70_T07_rac.sql | SYS_CONTEXT-identiteit passend; GV$ observerqueries zijn commentaar, geen failover-/RAC-bewijs; LGR4-09. |
| scripts/80_T08_evidence.sql | Read-only object/error/identitysnapshot; geen hash/approval/restore/PASS-verificatie; LGR4-10. |
| scripts/90_cleanup.sql | Fail-closed STOP met -20990; geen destructieve SQL. Geen uitvoerbare recovery. |
| COMMUNICATION_RELAY/SESSION_REGISTRY.json | Volledige PR-diff bekeken: alleen current_activity van ADMIN_LOGGER-REGIE-20261104-01 toegevoegd; geen nieuwe architectuur of vreemde sessie gewijzigd. Eigen reviewerregistratie afzonderlijk via PR #105. |

SQL*Plus statementgrenzen in de nieuwe scripts zijn statisch coherent: PL/SQL END; gevolgd door `/`, losse SQL met `;`, geen extra `/` na semicolon-SQL. Bron-TABLE bewaart slashterminators, guard-CREATE/INSERT/COMMIT met semicolons; SEQUENCE met semicolon en PKS/PKB met slash. @@ vanaf scripts bereikt via `../../../src` de juiste ADMIN_LOGGER/src-directory ([O8]). `SHOW ERRORS` is informatief; `20` controleert expliciet. USER_ERRORS telt ook warnings, zodat T02-02 nog een afzonderlijk warningbeleid behoeft. Geen Oracle-parser- of clientuitvoering geclaimd.

## 4. Volledige testdekking — alle 28 cases

**Alle databasecases: NOT_EXECUTED; uitvoering geblokkeerd door G09 NOT_GRANTED.** Onderstaande classificatie beschrijft de voorbereiding, niet geslaagde runtime. `Kern` betekent aanwezige uitvoerbare deeltest, niet volledige acceptatie. `Handmatig` betekent aanvullende concrete stappen nodig; `Fixture` betekent ontbrekend script/data/injectiemechanisme; `DBA` betekent externe omgeving/rechten/herstelafhankelijkheid. Deze eigenschappen kunnen samen gelden.

| Case | Voorbereiding en ontbrekende acceptatie |
|---|---|
| T01-01 | OFFLINE STATIC_PASS: zes pins en twee toegestane DDL-diffs bevestigd. |
| T01-02 | OFFLINE bron/API-preservatie PASS; volledig uitgeschreven publieke signature/default-inventaris ontbreekt; 45 LOG-aanroepen afzonderlijk gematcht. |
| T02-01 | Kern: 00/10/20; veiligheidsblokkades. DBA-omgeving, echte install/compile/spool vereist. |
| T02-02 | Handmatig/DBA: warnings, ALL_DEPENDENCIES en eventueel apart geautoriseerde recompile; geen apart script. |
| T03-01 | Kern: uniqueness-negatieve test in 30; single-position NULL/niet-positieve varianten niet uitgewerkt. |
| T03-02 | Fixture/DBA: incident-NOT-NULL/PK-fixture ontbreekt; LGR4-04, geen PASS uit guardtelling. |
| T03-03 | Kern alleen guard count; Handmatig/Fixture voor initialize/session/config-consistentie. |
| T03-04 | Handmatig/Fixture: toggles, targets, filters en batch met expected/actual ontbreken. |
| T04-01 | Kern: 40 plus VARCHAR2-calls 41; geen concrete output-/returnasserties. |
| T04-02 | Kern: 41 telt 45 LOG-varianten; gedrags/defaultacceptatie en outputcontrole handmatig/onuitgewerkt. |
| T04-03 | Handmatig/Fixture/DBA: toggles, BACKUP/RESTORE-sleutel en clear-scope niet uitgewerkt. |
| T05-01 | Kern uitsluitend 50-observatie; Handmatig/Fixture/DBA voor effectieve grants en positieve/negatieve principals. |
| T05-02 / C01 | Kern: 51 callerrollback; Fixture/DBA businessrow/config; diagnostische assert ontbreekt. |
| T05-03 / C02 | BLOCKED Fixture/DBA: geen exact foutinjectiepunt en uitvoerbaar herstel-/atomiciteitsbewijs. |
| T05-04 / C03 | BLOCKED Fixture/DBA: beheerrollback, duurzame incidentdiagnostiek en fallbackfout niet uitvoerbaar. |
| T05-05 / C04 | BLOCKED Fixture/DBA: drie foutklassen zonder exacte injecties/observatieasserties. |
| T05-06 / C05 | BLOCKED Fixture/DBA: failurematrix en feedback ontbreken; 41 dekt alleen callability. |
| T05-07 / C06 | BLOCKED Fixture/DBA: dubbel falen en externe watchdog niet geleverd. |
| T06-01 | Kern: 61/62 locks; Handmatig/DBA synchronisatie, timeoutassertie en release/herstel ontbreken. |
| T06-02 | Handmatig/Fixture/DBA: parallelle positieve sleutel, commitvolgorde, repeats en cleanup niet gescript. |
| T06-03 | Handmatig/Fixture/DBA: geen workload, gemeten baseline, drempels, metricscollector of resourcecap. |
| T07-01 | Kern: 70 lokale identity; Handmatig/DBA drie verschillende instances en volledige observersleutels correleren. |
| T07-02 | BLOCKED Fixture/DBA: leeftijd-eligible live remote kandidaten, visibility-negatief en geautoriseerde purge ontbreken. |
| T07-03 | BLOCKED Fixture/DBA: services, driver/replay, failoveractie en voor/na-identiteit niet uitgewerkt. |
| T07-04 | Handmatig/Fixture/DBA: drie-node uniqueness en incidentconsistentie niet gescript. |
| T08-01 | Kern: 80 snapshot; Handmatig/DBA compleet evidencebundle, alle resultaten en sign-off ontbreken. |
| T08-02 | BLOCKED DBA: ondertekend herstelrunbook en echte herstelproef ontbreken; 90 blokkeert terecht. |
| T08-03 | Handmatig/DBA/centrale regie: eindacceptatie afhankelijk van alle echte tests, opgeloste P1's en afzonderlijke releasebesluiten. |

C01 is gedeeltelijk uitvoerbaar; C02–C06 zijn expliciet BLOCKED en geen contract is runtime aangetoond. Een diagnostische printf, code-aanroep zonder assertion, commentaarplan of statische RAC-inspectie telt niet als PASS.

## 5. Bronintegriteit en uitgevoerde controles

| DEV-bestand | Git-blob op PR-head én gelezen main |
|---|---|
| PACKAGE_BODY/PACKAGE-BODY_TETOOLS_ADMIN_LOGGER__20261015_500.pkb | `febb57c5aebe3ce5d23799f60c6c38f793681d00` |
| PACKAGE_SPEC/PACKAGE_TETOOLS_ADMIN_LOGGER__20261015_500.pks | `9331a2756b1c2196280cda3f10bf1643285f61ab` |
| PROCEDURES/20260527__ADMIN_LOGGER__001.prc | `5a5e4e3181816aa520f5067f2b8c0abd3fef63f1` |
| SEQUENCE/SEQ_20261007__ADMIN_LOGGER__001.sql | `47416ff9583c32bc14cbe49007cd277f2449682b` |
| TABLE/TAB_TETOOLS_ADMIN_LOGGER__20261015_202.sql | `0c112a15643c62bcf4c2d4ac37fd54e2b656a04a` |
| REVISION_MANIFEST.md | `d6319dfa969770a2c9ece7be3e753febee86f5db` |

**6/6 PASS** tegen het manifest en main. Originele TABLE-blob `240b6516fcfd7e9a99ae7d47bb18433f77a8686f` behouden; de gehele `src/20261015_500`-tree is gelijk tussen gelezen main en PR-head. Vier overige bronbestanden zijn baseline-identiek. De TABLE-diff bevestigt uitsluitend verplaatsing van hetzelfde indexstatement inclusief slash en de komma na config_snapshot CLOB. Geen ADMIN_LOGGER-productiecode of bevroren release gewijzigd door PR102 of deze review. Ook de bevroren ADMIN_OBJECTS-release-tree is byte-identiek. Alle zes @@-include-doelen bestaan. Volledige PR-diff `git diff --check` zonder fouten; 28 unieke case-IDs bevestigd.

**Relay-validatiebeperking:** bestaande `tools/validate_relay.py` faalt op `REGIE-LOGGER-READINESS-20261109: invalid change status` (bestaande status ASSESSED). Exact dezelfde fout is op ongewijzigde main en na eigen registratie gereproduceerd. Dit is geen nieuw door de review ingevoerde fout; geen historische registratie is gerepareerd of als geldig goedgekeurd. Parseerbaarheid, unieke IDs, de eigen entry en prefixbehoud zijn apart gecontroleerd. De aanvullende JSON-Schema-gate is NOT_EXECUTED: jsonschema is niet geïnstalleerd in de beschikbare Python-omgeving. De volledige stdlib-gate blijft FAIL met uitsluitend de genoemde baselineafwijking; geen groene totaalgate geclaimd. Geen Oracle-tests uitgevoerd.

## 6. DBA-afhankelijkheden G01–G09

| Gate | Nog benodigd / bevoegde eigenaar |
|---|---|
| G01 | DBA: exacte 19c EE RU/SQLPATCH, DB_UNIQUE_NAME, DB/PDB/CON_ID, drie instance-/serviceroutes, clientversie. |
| G02 | DBA + module: aantoonbaar disposable geïsoleerde TETOOLS-omgeving, volledige object-/data-inventaris. |
| G03 | DBA/security + module: concrete direct/public grants, dependencylijst, visibility, consumer/negatieve principals, onderhoudsgrens. |
| G04 | Module + DBA: gecorrigeerde veilige instappunten, doel- en fasecontroles, later echte SQL*Plus-install/compile. |
| G05 | Module: run-ID's, deterministische fixtures/assertions, C02–C06-injecties, concurrency/RAC-orchestratie. |
| G06 | DBA: snapshot/backup, herstelprocedure, eigenaar/RTO/stopcriteria en echte herstelrepetitie. |
| G07 | DBA + module: unieke spools, sessiesleutels, geautoriseerde metrics/waarneming, licentiebevestiging waar relevant. |
| G08 | Module + centrale regie: publieke consumenten/defaults, backup/restorecompatibiliteit en goedgekeurde performancedrempels. |
| G09 | TETOOLS__REGIE: afzonderlijk expliciet, omgevings- en testcasegebonden GO. Huidig NOT_GRANTED. |

Open suitesignalen gelezen, waaronder LOGGER-RAC-20261105-001 en SESSIONS-RAC-20261106-001; hypothetische KT-03 is geen vastgesteld defect. Bestaande LOGGER-signaal/Issue #55 blijft de route voor mogelijke moduleoverstijgende identity-, purge- en onderhoudsimpact. Deze review voegt bewijs voor testontwerp toe, geen nieuw gedeeld architectuurbesluit en geen duplicaatsignaal. Of andere modules dezelfde testgateproblemen hebben, is niet onderzocht.

## 7. Mergeadvies en overdracht

**FAIL; PR #102 NIET MERGEN op de beoordeelde head.** Twee P1's (LGR4-01/02) vereisen concrete correcties. LGR4-03..11 zijn negen P2-punten over uitvoerbaarheid, acceptatie en reproduceerbaarheid. Dit oordeel blokkeert de huidige testpublicatie volgens Issue #104, niet het publiceren van dit onafhankelijke rapport.

ADMIN_LOGGER__REGIE verwerkt de correcties in de eigen PR-branch, zonder productiebron of frozen release te wijzigen, en meldt nieuwe SHA plus een finding-to-commit-resolutiematrix in Issue #104. Laat ieder punt aantoonbaar corrigeren of door TETOOLS__REGIE expliciet als resterende voorbereidingsafhankelijkheid behandelen; geen stilzwijgende afsluiting. Daarna volgt **nieuwe onafhankelijke beoordeling van de volledige gewijzigde PR-head**. Een oude review op 5c25e836… blijft historische onderbouwing, geen PASS voor een latere commit. Geen merge of Oracle-GO door deze reviewer.

Eigen sessie geregistreerd via [PR #105](https://github.com/JPouwiel/TETOOLS/pull/105), merge `84a46a16bfac9a3336de9243c109ced1b6f18cfa`; ACTIVE/KEEP-entry op main teruggelezen en ontvangst in Issue #104 bevestigd. Rapport, bewijs en relay-update worden via een eigen review-PR gepubliceerd; feitelijke merge-/main-terugleesbewijzen worden daarna in Issue #104 en PR #102 vastgelegd. Geen toekomstige publicatie vooraf als voltooid geclaimd.

Na geverifieerde publicatie is de afgebakende review **COMPLETED/KEEP** en wordt current_activity verwijderd. **CLOSED wordt niet geclaimd zolang module-/centrale ontvangst niet is bevestigd.** Open eigenaarschap: correcties en vervolgtestontwerp bij bestaande ADMIN_LOGGER-REGIE-20261104-01; mergegate bij TETOOLS__REGIE; G01–G08 bij module/DBA en G09 bij centrale regie. Issue #104 blijft open voor correcties/ontvangst/herreview. Oracle NOT_EXECUTED; herstel NOT_VERIFIED; uitvoeringsreadiness NOT_READY; RAC-readiness NOT_DEMONSTRATED.

## Oracle 19c-bronnen

- **[O1]** [SQL*Plus WHENEVER SQLERROR](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqpug/WHENEVER-SQLERROR.html) en [WHENEVER OSERROR](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqpug/WHENEVER-OSERROR.html).
- **[O2]** [PL/SQL IF-semantiek](https://docs.oracle.com/en/database/oracle/oracle-database/19/lnpls/IF-statement.html): fouttak wordt alleen bij TRUE uitgevoerd.
- **[O3]** [Autonome transacties](https://docs.oracle.com/en/database/oracle/oracle-database/19/lnpls/autonomous-transactions.html).
- **[O4]** [CREATE TABLE, identity_clause](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/CREATE-TABLE.html) en [INSERT-grammatica](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/INSERT.html).
- **[O5]** [Overloaded subprograms](https://docs.oracle.com/en/database/oracle/oracle-database/19/lnpls/overloaded-subprograms.html) en [parameters/defaults](https://docs.oracle.com/en/database/oracle/oracle-database/19/lnpls/subprogram-parameters.html).
- **[O6]** [COMMIT en impliciete DDL-commits](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/COMMIT.html).
- **[O7]** [USER_PROCEDURES](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/USER_PROCEDURES.html) en [USER_TAB_PRIVS_RECD](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/USER_TAB_PRIVS_RECD.html).
- **[O8]** [SQL*Plus @@](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqpug/double-at-sign.html).

- **[O9]** [Oracle 19c NULLs en lege strings](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/Nulls.html).
