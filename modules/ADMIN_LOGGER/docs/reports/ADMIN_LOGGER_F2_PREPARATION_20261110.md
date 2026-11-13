# ADMIN_LOGGER — F2 werkpakket B, technische besluitvoorbereiding
Datum 2026-11-10; revisie 001; eigenaar ADMIN_LOGGER-REGIE-20261104-01. **PROPOSED / DESIGN_ONLY / F2 BLOCKED.**
Opdracht [Issue104 comment6765310902](https://github.com/JPouwiel/TETOOLS/issues/104#issuecomment-6765310902); [ontvangst](https://github.com/JPouwiel/TETOOLS/issues/104#issuecomment-6769416919). Uitvoering namens bestaande module-regie in huidige Codex-chat; oorspronkelijk gesprek 6aeaf394-82a0-83ed-bef9-457342486257; platform-ID huidige uitvoeringschat niet zelfstandig vastgesteld, niet als oorspronkelijke chat voorgesteld.

## Bevoegdheid en herkomst
Gelezen GitHub-main **b7e035b00bfc115e815b52e8e388a002f0edfeae**; START_HERE, RELAY_CONTRACT, MANUAL_HANDOFF, PROJECT, CURRENT_STATUS, MODULE_REGISTRY, sessie-/changeregister, canoniek beleid rev002, module-status/besluiten/open punten en LDR-/reviewdossiers. Open suite-signalen inclusief opvolgende INVESTIGATE-dispositions bekeken; LOGGER-RAC-20261105-001/Issue55 hergebruikt. Geen nieuw signaal of centrale registerwijziging: werkpakket C bezit die publicatie. Fase-indeling PR109/comment6764414199 wordt niet opnieuw gemaakt.
PR102-bronreferentie **afb5330ac538cb913e7d5e3eb8d92c7daeddc123**, blocked_dependencies.md blob c0eff3b1eed8a78751a67c950b3cad2cfe84c364. Onafhankelijke review A heeft eigen ontvangst6765342751; geen reviewopdracht of onafhankelijk PASS door B. Historische FAILs blijven intact. Deze publicatie is uitsluitend documentatie, geen mergevrijgave, testimplementatie, sourcecorrectie of G09.

## 1. Concrete bron-vs-027 vergelijking
Paden relatief aan modules/ADMIN_LOGGER. Bron B = src/20261015_500/PACKAGE_BODY/PACKAGE-BODY_TETOOLS_ADMIN_LOGGER__20261015_500.pkb (blob febb57c5aebe3ce5d23799f60c6c38f793681d00); P = proposals/20261013_500_PROPOSAL_027/PACKAGE-BODY_TETOOLS_ADMIN_LOGGER__20261013_500_PROPOSAL.pkb (c95f944efbd99a32bd1b7a8a4e4cf10f04964918). SPEC B 9331a2756b1c2196280cda3f10bf1643285f61ab; P 7dbd395b310269189adc158acc958847e07bd1ec. GitHub op basiscommit gelezen. DEV 20261109_501_DEV behoudt B-PKS/PKB; alleen twee TABLE-correcties volgens manifest. 027 is ouder testvoorstel, geen upgradebaseline of bewezen RAC-oplossing.

| Onderwerp / bewijs | Geobserveerd bronverschil of overeenkomst | Voorstel / besluit nodig |
|---|---|---|
| Publieke API B-SPEC/P-SPEC | B declareert 70 routines/overloads; P 71. Alle 70 B-declaraties zijn gelijk in P na witruimtenormalisatie; P voegt get_batchid(batch_mode IN CHAR) RETURN INTEGER toe (in B uitgecommentarieerd). | Niet als ondersteunde huidige API behandelen of introduceren zonder afzonderlijk besluit; actuele consumers onderzoeken. |
| BACKUP/RESTORE B946–1011, P854–911 | Beide vereisen BACKUP/RESTORE, niet-NULL sleutel van lengte 5, weigeren tweede BACKUP, bewaren logging/debug/batch in packagegeheugen en wissen sleutel pas na geslaagde save. Beide herstellen lokale cache bij save-fout. | BEHOUDEN publieke signature en geldige roundtrip; geen databasebackup beloven. |
| RESTORE-identiteit zelfde routines | B bewaart log_session/config_id maar RESTORE-tak toetst alleen sleutel. P toetst daarnaast bewaarde log_session en config_id tegenover huidige registratie. | CORRIGEREN-kandidaat: identiteit binden; centraal bevestigen gewenst refusal-/recoverycontract vóór afzonderlijk ontwerp/sourceopdracht. Geen automatische overname van P. |
| Batchrestore zelfde routines | Beide lezen MAX(log_lines)+1 voor huidige sessie/batch; geen batch geeft interne 0/0. | Behouden voor ononderbroken geldige registratie; races en identity-wissel apart toetsen, geen exactly-onceclaim. |
| Purge B1715–1820, P1664–1769 | Beide gebruiken lokale V$SESSION voor liveness; sessiecutoff TRUNC(logon_time) < cutoff-3. Logpurge <= middernacht, actieve geconfigureerde batches uitgesloten. | 027 lost remote RAC-liveness niet op. CORRIGEREN-kandidaat RAC-A-001; huidige daggrenzen behouden totdat expliciet ander retentiecontract besloten is. |
| Batch B1190 e.v., P1069 e.v. | Beide accepteren B/BATCH en S/SINGLE, ON hergebruikt geldige batch; OFF/SINGLE eindigt batch. | BEHOUDEN aliases/defaults; consumententests vereist. |
| Routing B internal_logging vanaf1270 / P gelijknamige routines | Bron laat normale non-DEBUG logging bij logging OF debug toe; debug heeft targetvoorrang; FORCE gebruikt override/table. | BEHOUDEN expliciete routingmatrix; geen impliciete filterverandering uit technische consolidatie. |
| Schema/installatie P INSTALL_MANIFEST.txt, SUPPORT_SCHEMA_PROPOSAL.sql | P veronderstelt normale single-instance READ COMMITTED, coöperatieve guard en één schrijver per batch; voegt incidentkolommen/guard toe en bevat niet-idempotente migratie. B heeft deze objecten al in TABLE; DEV corrigeert indexvolgorde/komma. | P-support niet bovenop B installeren. Geen nieuwe sequence vanaf1 bij bestaande historie; migratie/historische conflicten apart besluiten. |
| Fout- en transactiecontract | Autonome routines, eigen commits en fallback in bron zijn geen bewijs van naleving van besluit23/F03. | Beleidscontract leidend; C01–C06 uitvoeren na afzonderlijke toestemming. P-aanname is geen acceptatiebewijs. |

Dit is een onderwerpsgerichte vergelijking voor LOG-OPEN-04, geen claim dat alle circa 2000 regels van beide bodies semantisch equivalent of volledig gereviewd zijn. P-support, constraints en preflight zijn voorstelartefacten, niet uitgevoerd.

## 2. Functionele baseline en centrale beslispunten
Volledige publieke declarations/defaults staan ongewijzigd in de SPEC; appendix hieronder neemt ze letterlijk over. Constants: datumformaat YYYY-MM-DD HH24:MI:SS, loggingtarget T, debugtarget S; toggle_logging standaard ON, toggle_debug OFF, toggle_batch OFF/SINGLE. Function-return 1 betekent normale callcompletion, geen ontvangstbewijs van opslag. Geen LOG_DEBUG_FORCE declaratie.

| Beslispunt | Classificatievoorstel | Concrete keuze gevraagd aan TETOOLS__REGIE / toets |
|---|---|---|
| API en overloads | BEHOUDEN | PKS als compatibiliteitsbaseline bevestigen; test 5 gewone +4 FORCE functies (VARCHAR2), 36 procedures (VARCHAR2/CLOB/BOOLEAN/DATE), datumdefault, NULL/lege/lange data en eigen return per aanroep. |
| Filter/routing | BEHOUDEN | Logging/debug OFF/OFF: normale calls zonder opslag; ON/OFF gebruikt logtarget; debug ON gebruikt debugtarget voor normale calls; DEBUG alleen debug ON; FORCE naar TABLE. Beide targets en categorie/tekst/return per combinatie assert. HELP-filter is selectie van documentatie, geen logcategorie-filter. |
| Batch/retentie/clear | BEHOUDEN grenzen; RAC-liveness CORRIGEREN | ON,BATCH herhaling behoudt ID; OFF en ON,SINGLE beëindigen; SINGLE opslag NULL batchmetadata. Cutoff exact <= middernacht en sessies < dag-3 behouden of apart wijzigen. Test cutoff-1ms/exact/+1ms, drie-daggrens, tijdzone, ongeldige datum, HELP zonder mutatie en remote levende oude sessie die nooit verwijderd mag worden. |
| BACKUP/RESTORE | BEHOUDEN + identiteit CORRIGEREN-kandidaat | Sleutel/nesting refusal behouden; kies expliciete weigering bij gewijzigde registratie, geen herstel over fysieke reconnect/poolgebruik heen; melding/exception en herinitialisatie vastleggen. Geen geheim of authenticatietoken: sleutel is tijdelijke matching key. |
| Maintenance | HEROVERWEGEN autorisatiemodel | Onderhoudstoegang per methode/principal vaststellen; normale EXECUTE is onvoldoende bewijs van functionele onderhoudsautorisatie. Geen nieuwe grants/API in deze opdracht. |
| Foutcontract | CORRIGEREN waar tests afwijking bewijzen | Besluit23/F03 behouden; registratie-, sessiebrede en fallbackfouten afzonderlijk expected exception én gebruikersmelding vastleggen; geen stilzwijgende vrijstelling. |
| Consumers | HEROVERWEGEN onduidelijke legacycalls | Onderstaande bronconsumers aan echte deploymentversies koppelen; behoud geldige gebruiksmogelijkheden, beslis migratie van ongeldige calls afzonderlijk. |
| Performance/herstel | PROPOSED | Workload en hieronder beschreven meet-/budgetmethode goedkeuren; concrete harde grenzen pas na DBA/consumergegevens. |

Onderhoudsmatrixvoorstel: POSITIVE gewone LOG/toggle/eigen BACKUP/RESTORE; NEGATIVE geen EXECUTE/toegang; MAINTENANCE uitsluitend expliciet gemachtigde clear_*; OBSERVER read-only begrensde views; RECOVERY uitsluitend herstelrunbook. OWNER voert installatie uit maar vervangt geen consumer. Security moet vaststellen hoe public EXECUTE toegang tot clear_* momenteel doorlaat. Ontbrekende weigering is finding, niet te maskeren met een onzichtbaar object.

### Aangetroffen consumerbewijs, geen deploymentclaim
Repositoryzoekactie in ADMIN_OBJECTS/ADMIN_SESSIONS/ADMIN_TNSNAMES SQL/PLSQL-bronnen:
- ADMIN_OBJECTS source/original_20261012_001/PACKAGES/PACKAGE_BODY/PACKAGE-BODY_TETOOLS_ADMIN_OBJECTS__20261012_001.pkb:175/213 en258/293 geldige token-BACKUP/RESTORE-paren; **322/357 zonder sleutel**, strijdig met de huidige verplichte sleutelcontrole. 1032 gebruikt batch B, 1238 BATCH; beide door logger aanvaard. Foutpaden1110–1140 vereisen controle op restore plus batchreset.
- ADMIN_OBJECTS source/original_20261012_001/FUNCTION/FUNCTION__TETOOLS_ADMIN_VERSION_NUMBERFY_FUNC__20260819_001.sql:21/46 session_details en log_error_force; JOBS en TABLES bevatten runtime/debugcalls.
- ADMIN_SESSIONS SOURCE/CONCEPT/concept_admin_session_diag.sql:75/78/81 FORCE ERROR/WARNING/INFO; RELEASES bevat een kopie, geen tweede onafhankelijke consumer.
- Geen volledigheidsclaim voor TNSNAMES, dynamische SQL, externe applicaties of ADMIN_MONITOR. DBA dependencies/gebruikstelemetrie en module-eigenaarbevestiging ontbreken. Consumers met statische verwijzing zijn kandidaat-regressiegevallen, geen bevestigde productieconsumers.

## 3. Fixtureontwerpen, nog geen uitvoerbare of goedgekeurde injectoren
Gemeenschappelijk: disposable doel met identiteit DB_UNIQUE_NAME/PDB/CON_ID/OWNER/RU, unieke RUN_ID/case/client en externe observer; geen productiedata. Voor iedere probe eigen actuele autorisatie-/doelcontrole. Foutallowlist, object/key-scope, maximale duur, stopbevoegdheid, injection-off en herstelbewijs vóór G09 vastleggen. Voor-/na-rijen en cache waar observeerbaar vergelijken. Elke onverwachte fout = FAIL/STOP; ontbrekende observatie = INCONCLUSIVE, geen PASS.

| Fixture / contract | Ontwerp en verwachte asserties | Nog nodig |
|---|---|---|
| D01 echt incident-PK-conflict | Eerste keuze: DBA onderzoekt of een testspecifieke BEFORE INSERT-trigger op alleen incidenttabel de gegenereerde :NEW.incident_id naar één bestaande RUN-fixturerij kan zetten. Dit is een kandidaat, niet bewezen 19c-methode. Alleen exacte ORA-00001 op ADMIN_LOGGER_INCIDENT_PK met bewezen doelrij telt. | DBA moet trigger/ALWAYS-identitygedrag aantonen in apart geautoriseerde disposable proef en trigger-DDL/herstel laten reviewen. ORA-32795, clone-PK-conflict of geen nieuwe rij is geen bewijs. Bij onmogelijkheid alternatieve fixture apart ontwerpen; geen identity/sourcewijziging nu. |
| BACKUP/RESTORE D03 | Voor elke case nieuwe fysieke sessie; snapshot instellingen, BACKUP('B0001'), tijdelijk andere targets/batch, RESTORE, vergelijk alle velden. Negatief: NULL/leeg/4/6 tekens, ongeldige modus, verkeerde sleutel, restore zonder backup, nesting, tweede restore. | Bij refusal geen persistente/cachemutatie; juiste sleutel blijft na verkeerde restore bruikbaar. Onderbroken save, registratievervanging en reconnect apart; huidige bron mag op gewenste identity-refusal FAIL geven. DBA snapshot/herstel. |
| C02 atomair beheer | Gecontroleerde eenmalige injectie tussen sessie- en configuratiemutatie; onafhankelijke observer toont geen gedeeltelijke duurzame wijziging en latere guardacquisitie. | Geen publieke hook aanwezig: kies afzonderlijk goedgekeurde testinstrumentatie of exact begrensde trigger met aantoonbaar bereik van foutpad. Geen schemawide fouttrigger. |
| C03 diagnostiek | Zelfde beheerfout, eerst diagnostiek beschikbaar; observer na rollback ziet incident/error met RUN_ID, stack en oorzaak. Tweede geval diagnostiek zelf onbeschikbaar. | Oorspronkelijke fout mag niet worden vervangen door vermeend succes; vooraf exacte toegestane foutcodes per pad/fixture afleiden. |
| C04/C05 classificatie/API | Matrix incidentele loginsertfout, sessieregistratiefout, fallbackfout tegen alle API-families en overloads; leg return, exception, stdout en duurzame rows apart vast. | RUNTIME incidenteel best-effort; sessiebreed mag onderbreken. INFO/WARNING intern; ERROR/DEBUG/FORCE vereiste applicatie- en gebruikersfeedback. C01 business-rowrollback voor elke relevante muterende familie. |
| C06 recursie | Een run waarin primaire opslag en fallback falen; externe watchdog registreert callcount/stack waar beschikbaar, voltooiing/exception en begrensde duur. | Geen logger als watchdog gebruiken; collector mag zelf niet terugloggen. Stop/cancel door DBA exact geautoriseerd, niet automatisch willekeurige sessies killen. |

Een trigger/instrumentatie vereist afzonderlijke scopegoedkeuring, eigen versiepins en herstel; deze tekst creëert niets. Clonefixtures kunnen logica voorbereiden maar sluiten D01/C02–C06 niet.

### Concurrency D06 / T06–T07
Coördinator buiten logger, clients A/B op verschillende vastgestelde instance-routes, observer O en recovery R. Barrierprotocol: READY met fysieke tuple (INST_ID,CON_ID,SID,SERIAL#,LOGON_TIME); A neemt guard; observer bevestigt lock; RELEASE_B; B probeert; observer bevestigt wacht of exact toegestane timeout; A beëindigt transactie; C bewijst heracquisitie. Alle events met monotone clientduur en UTC-correlatie, geen uitsluitend sleep-gebaseerde race.
Voorgestelde watchdog **30 s per probe** als onderzoeksbudget rond bron-WAIT5, geen goedgekeurde locklatencygrens. DBA moet polling/netwerk/ruiscorrectie en harde guardupperbound bepalen. Watchdog timeout geeft FAIL/STOP, geen veronderstelde ORA-30006.
Afzonderlijke scenario's: gelijktijdige batches (geen dubbele positie), configuratie versus purge, oude levende remote sessie versus purge, sessieherstelrace, identieke batchpositieconflict. Een test mag bewust verwacht conflict opleveren; geen verloren updates of verkeerde sessieverwijdering. Herhaal op drie werkelijke instances en verwissel rollen. Synthetisch één instance bewijst geen RAC.

## 4. Performance en herstel: onderbouwde voorstellen, geen goedgekeurde grenzen
Bronmatige risicogrond: autonome commit per tabelregistratie, callstack/contextopbouw, CLOB-pad, gedeelde guard WAIT5, purgevolume en MAX(log_lines)-restore. Daarom meten vóór optimalisatie; geen gemeten vertraging of winst geclaimd.
Voorgestelde meetopzet: baseline B/DEV met identieke SQL/RU/stats/config/data/client/netwerk; eerst buildgates, dan warmup, minimaal vijf onafhankelijke meetvensters van60s per cel, voldoende samples voor p95 (voorstel >=1000 calls; anders onzekerheid rapporteren). Volgorde baseline/kandidaat afwisselen. Clients1/3/12 als verkennende schaalpunten, payload128B/4KB/32KB en CLOB64KB, TABLE/SCREEN/OFF, single/batch, normal/FORCE; aantallen en mix door consumers vervangen/bevestigen. SCREEN omvat expliciete clientdrain. Eerste connect/repair apart van steady state.
Rapporteer p50/p95/p99, throughput, errors/timeouts, CPU/redo/logical reads per call, waits en guardduur met toegestane collector. Geen AWR/ASH/licentie aannemen.
**Voorstel onderzoeksalarm:** p95 >1,20x baseline of throughput <0,80x baseline in herhaalde gematchte vensters leidt tot onderzoek. 20% is een voorlopige triageband voor ontbrekende baseline/ruis, geen release-SLO of geaccepteerde regressie. DBA/consumers moeten absolute latency/throughput/resourcebudgetten en statistische onzekerheid leveren; centrale regie keurt uiteindelijke grenzen goed. Integriteit/foutcontract blijft harde functionele eis, ongeacht snelheid.

BACKUP/RESTORE-API bewaart packageinstellingen; dit is **geen databaseherstel**. Cleanup90 weigert bewust en is geen restoreprocedure.
D08/G06 herstelrunbook moet bevatten: exact herstelpunt/backup-ID en scope; logevidence buiten doel bewaren; stop nieuwe clients; identificeer alleen RUN-sessies; DBA stopt/cancelt volgens bevoegdheid; injection-off; snapshotrestore of goedgekeurde disposable teardown/rebuild; object/grant/hash-/rowintegriteitscontrole; positieve logger- en consumer-smoke; onafhankelijke herstelacceptatie. DDL en autonome commits worden niet met caller ROLLBACK hersteld.
**RTO-voorstel als begroting:** RTO = detectie + stop/isolatie + restore/rebuild + verificatie + operationele vrijgave. Meet iedere component in geautoriseerde rehearsal; vraag DBA p95-duur per component, datavolume en platformminimum. Voorlopig planningsbudget = som van die gemeten componentbudgetten plus expliciet centraal gekozen marge; geen minutenwaarde verzinnen zonder platformbewijs. Centraal bepaalt maximaal toelaatbare uitval vóór uitvoering. RPO afzonderlijk bepalen: welke testdata mogen verloren gaan, welke log/incident-evidence moet extern behouden blijven. Geen RTO/RPO gehaald of recovery getest.

## 5. D01–D11: eigenaars, bewijs en resterende blokkade
Alle onderstaande statussen **BLOCKED**; rollen zijn geen persoonsaanvaarding. F2 ontwerpt/besluit, F3 verifieert na aparte G09, F4 accepteert integraal.

| ID / finding | Verantwoordelijke rol | In dit dossier voorbereid / vereist sluitbewijs |
|---|---|---|
| D01 LGR4-04 incident-PK | Module + DBA | §3 kandidaat; echte PK/identityfixture en onafhankelijke runtimewaarneming ontbreken. |
| D02 LGR4-05 regressie | Module + centrale regie | §2 API/routing/boundaries; volledige geversioneerde assertions en functionele besluiten ontbreken. |
| D03 LGR4-05 027/backup | Module + DBA; centraal functioneel | §1/3 verschil/negatieven; identitycontract, goedgekeurde fixture en compatibilitybewijs ontbreken. |
| D04 LGR4-05 consumers/maintenance | Module + consumerowners | §2 concrete broncalls; deployed versies, owneracceptatie en maintenancebaseline ontbreken. |
| D05 LGR4-10 injectie C02–C06 | Module + DBA | §3 per contract; echte allowlisted injectoren, watchdog en review ontbreken. |
| D06 LGR4-10 races | Module + DBA-coördinator | §3 barrierontwerp; goedgekeurde uitvoerbare coördinator/resources/upperbound ontbreken. |
| D07 LGR4-10 benchmark | Module + DBA; centraal criteria | §4 risico/methode/triage; representatieve mix, collector/licenties en goedgekeurde numerieke SLO's ontbreken. |
| D08 LGR4-10 herstel/RTO | DBA recovery + module | §4 runbook/RTO-budget; backup-ID, getekende commands/stopowner en rehearsal ontbreken. |
| D09 LGR4-11 principals/grants | DBA/security + module | §2 rollen; echte principals, direct/PUBLIC/effectieve grants en acceptatie ontbreken. |
| D10 LGR4-11 visibility | DBA/security + observer | §3 fysieke keys; bounded PDB/dictionary/sessionvisibility en denial-versus-absencebewijs ontbreken. |
| D11 LGR4-11 maintenance | Module + DBA/security; centraal scope | §2 method-to-principal voorstel; beslissing en negatieve fixture/weigerbewijs ontbreken. |

| Gate | Eigenaar / nog te leveren bewijs | Status |
|---|---|---|
| G01 | DBA: 19c EE RU/SQLPATCH, DB/PDB/CON_ID, drie instances/routes, client/driver/clocks | OPEN |
| G02 | DBA: disposable doel, volledige inventory/data-isolatie en doeltoestemming | OPEN |
| G03 | Security/DBA: werkelijke owner/consumer/negative/observer/recovery, direct/PUBLIC/roles | OPEN |
| G04 | Module/DBA: bronpins beschikbaar; werkelijke exports/client-failfast/installbewijs ontbreekt | OPEN / offline gedeeltelijk |
| G05 | Module/DBA: per-case goedgekeurde fixtures/injectoren/barriers/stop en herstel | OPEN / BLOCKED |
| G06 | DBA recovery: getekend snapshot/runbook/RTO/RPO en afzonderlijke rehearsalautorisatie | OPEN |
| G07 | DBA/observer: originele logs, betrouwbare externe opslag, collector/licenties | OPEN |
| G08 | Module/consumers/centrale regie: baselinebesluiten, deployed consumers en numerieke SLO's | OPEN |
| G09 | TETOOLS__REGIE: apart exact doel/principals/cases/venster/stop/herstel-GO | **NOT_GRANTED** |

## 6. Eén concreet verzoek om ontbrekende contacten en omgeving
Aan gebruiker/repositorybeheerder via bestaande Issue104, voor doorgeleiding naar bevoegde beheerorganisatie:
**Bevestig één aanspreekpunt/coördinator en de werkelijke DBA-, security-, recovery- en consumerverantwoordelijken (rollen mogen gecombineerd worden indien bevoegd), plus welke geïsoleerde niet-productie Oracle19c EE/PDB en drie RAC-routes beschikbaar zijn. Lever of laat die personen één samenhangend G01–G08-bewijspakket publiceren: RU/topologie/identiteiten, inventory, directe/PUBLIC grants, client/driver en toegestane observatie/licenties, test-/injectiescope, snapshot/restore/stoprunbook met RTO/RPO-componentbudgetten, deployed consumers/workload en voorgestelde harde SLO's. Bevestig per rol ontvangst en bevoegdheid. Geen wachtwoorden, tokens, connection secrets of productiedata aanleveren.**
Projectbronnen geraadpleegd: module-LDR-testplan, centrale stap4-voorbereiding, PR102-dependencies/environment, sessie-/module-registers en Issue104/55. Daaruit zijn verantwoordelijkheidsrollen afleidbaar, geen door B bevestigde werkelijke DBA/security/recovery-personen of concrete testomgeving. Daarom geen persoonsnamen verzonnen. Dit verzoek is informatie-inventarisatie, geen G09-aanvraag of toestemming.

## 7. Verificatie, publicatie en vervolg
Alleen documentatie en eigen bestaande module-sessie-entry op branch; OPEN_POINTS verwijst hiernaar. Centrale CHANGE_REGISTER/DECISIONS-optieC-publicatie blijft bij C; formele registratie van B kan centraal na ontvangst worden gekoppeld zonder concurrerende registerwijziging.
Statisch: GitHub bronblobs gelezen, onderwerpsvergelijking en concrete consumerzoekactie; geen volledige semantische equivalentiereview of onafhankelijk PASS. Oracle/SQLPlus/SQLcl/compilatie/runtime/RAC/performance/herstel **NOT_EXECUTED** wegens expliciete scope/G09 NOT_GRANTED. Testscripts en modulebron ongewijzigd. D01–D11, LGR4-04/05/10/11 en C02–C06 blijven BLOCKED.
Publicatie is branch/PR-readback, **geen merge/main-publicatie**. Centrale mergegate PR102 blijft afhankelijk van A en expliciete centrale beoordeling; B verleent geen vrijgave. Na centrale ontvangst: module-regie behoudt technisch eigenaarschap, centrale regie beslist §2/4, werkelijke beheer-/consumerrollen leveren §6; geen nieuwe sessie vereist. Handoff niet CLOSED zonder ontvangst. KEEP wegens open dependencies.

### Werkelijk uitgevoerde offline verificatie
Publieke declaraties geëxtraheerd na uitsluiten van commentaar: B70/P71, uitsluitend P-get_batchid extra. Eigen sessie-entry is de enige gewijzigde entry; centrale CHANGE_REGISTER exact behouden. Gepinde GitHub-main validator en session_retention_review opgehaald op basiscommit en apart uitgevoerd op baseline en voorstel: beide FAIL uitsluitend op bestaande REGIE-LOGGER-READINESS-20261109 status ASSESSED. Geen nieuwe validatorfout. Een eerste run met gelijktijdig lokaal gewijzigde validator gaf PASS en is daarom niet als canoniek bewijs gebruikt; lokale wijzigingen van andere werkzaamheden niet aangepast. Aanvullende JSON-Schema-validatie NOT_EXECUTED: jsonschema ontbreekt in de geselecteerde Python-runtime. Geen groene totaalgate.

## Appendix — letterlijke publieke declarations uit SPEC B
Onderstaande catalogus is statisch uit de niet-gecommentarieerde SPEC-declaraties overgenomen; datatype- en constantverwijzingen blijven brongetrouw.

```sql
FUNCTION get_invoking_sid RETURN NUMBER;
FUNCTION get_invoking_serial RETURN NUMBER;
FUNCTION get_logon_time ( p_sid IN NUMBER, p_serial IN NUMBER ) RETURN DATE;
FUNCTION get_audsid ( p_sid IN NUMBER, p_serial IN NUMBER ) RETURN NUMBER;
FUNCTION logging_is_on           ( p_settings_id IN INTEGER DEFAULT NULL
                                   ) RETURN CHAR;
FUNCTION debug_is_on             ( p_settings_id IN INTEGER DEFAULT NULL
                                   ) RETURN CHAR;
FUNCTION LOG_RUNTIME (context_in IN VARCHAR2, data_in IN VARCHAR2) RETURN PLS_INTEGER;
FUNCTION LOG_INFO    (context_in IN VARCHAR2, data_in IN VARCHAR2) RETURN PLS_INTEGER;
FUNCTION LOG_WARNING (context_in IN VARCHAR2, data_in IN VARCHAR2) RETURN PLS_INTEGER;
FUNCTION LOG_ERROR   (context_in IN VARCHAR2, data_in IN VARCHAR2) RETURN PLS_INTEGER;
FUNCTION LOG_DEBUG   (context_in IN VARCHAR2, data_in IN VARCHAR2) RETURN PLS_INTEGER;
FUNCTION LOG_RUNTIME_FORCE (context_in IN VARCHAR2, data_in IN VARCHAR2) RETURN PLS_INTEGER;
FUNCTION LOG_INFO_FORCE    (context_in IN VARCHAR2, data_in IN VARCHAR2) RETURN PLS_INTEGER;
FUNCTION LOG_WARNING_FORCE (context_in IN VARCHAR2, data_in IN VARCHAR2) RETURN PLS_INTEGER;
FUNCTION LOG_ERROR_FORCE   (context_in IN VARCHAR2, data_in IN VARCHAR2) RETURN PLS_INTEGER ;
FUNCTION bool2vc                ( bool IN BOOLEAN
                                  ) RETURN VARCHAR2;
FUNCTION bool2c                 ( bool IN BOOLEAN
                                  ) RETURN CHAR;
FUNCTION gen_token RETURN VARCHAR2;
PROCEDURE who_called ( p_level IN NUMBER, p_trm_result OUT VARCHAR2 );
PROCEDURE session_details;
PROCEDURE session_details_revert(modus IN VARCHAR2, config_key IN VARCHAR2 DEFAULT NULL);
PROCEDURE show_config ( modus IN VARCHAR DEFAULT NULL );
PROCEDURE help( verbose IN VARCHAR2 DEFAULT 'N');
PROCEDURE banner;
PROCEDURE version;
PROCEDURE clear_session_entries ( before_in              IN VARCHAR2 DEFAULT NULL );
PROCEDURE clear_log_entries    ( before_in               IN VARCHAR2 DEFAULT NULL );
PROCEDURE toggle_logging       ( modus                   IN VARCHAR2 DEFAULT c_on, 
                                   send_log_to_in          IN VARCHAR2 DEFAULT g_logging_target);
PROCEDURE toggle_debug         ( modus                   IN VARCHAR2 DEFAULT c_off,
                                   set_debug_target        IN CHAR     DEFAULT g_debug_target );
PROCEDURE toggle_batch     ( modus IN VARCHAR2 DEFAULT c_off, batch IN VARCHAR2 DEFAULT c_single );
PROCEDURE LOG_RUNTIME (context_in IN VARCHAR2, data_in IN VARCHAR2);
PROCEDURE LOG_RUNTIME (context_in IN VARCHAR2, data_in IN CLOB    );
PROCEDURE LOG_RUNTIME (context_in IN VARCHAR2, data_in IN BOOLEAN );
PROCEDURE LOG_RUNTIME (context_in IN VARCHAR2, data_in IN DATE,     format_in IN VARCHAR2 DEFAULT c_date_mask );
PROCEDURE LOG_INFO    (context_in IN VARCHAR2, data_in IN VARCHAR2);
PROCEDURE LOG_INFO    (context_in IN VARCHAR2, data_in IN CLOB    );
PROCEDURE LOG_INFO    (context_in IN VARCHAR2, data_in IN BOOLEAN );
PROCEDURE LOG_INFO    (context_in IN VARCHAR2, data_in IN DATE,     format_in IN VARCHAR2 DEFAULT c_date_mask );
PROCEDURE LOG_WARNING (context_in IN VARCHAR2, data_in IN VARCHAR2);
PROCEDURE LOG_WARNING (context_in IN VARCHAR2, data_in IN CLOB    );
PROCEDURE LOG_WARNING (context_in IN VARCHAR2, data_in IN BOOLEAN );
PROCEDURE LOG_WARNING (context_in IN VARCHAR2, data_in IN DATE,     format_in IN VARCHAR2 DEFAULT c_date_mask );
PROCEDURE LOG_ERROR   (context_in IN VARCHAR2, data_in IN VARCHAR2);
PROCEDURE LOG_ERROR   (context_in IN VARCHAR2, data_in IN CLOB    );
PROCEDURE LOG_ERROR   (context_in IN VARCHAR2, data_in IN BOOLEAN );
PROCEDURE LOG_ERROR   (context_in IN VARCHAR2, data_in IN DATE,     format_in IN VARCHAR2 DEFAULT c_date_mask );
PROCEDURE LOG_DEBUG   (context_in IN VARCHAR2, data_in IN VARCHAR2);
PROCEDURE LOG_DEBUG   (context_in IN VARCHAR2, data_in IN CLOB    );
PROCEDURE LOG_DEBUG   (context_in IN VARCHAR2, data_in IN BOOLEAN );
PROCEDURE LOG_DEBUG   (context_in IN VARCHAR2, data_in IN DATE,     format_in IN VARCHAR2 DEFAULT c_date_mask );
PROCEDURE LOG_RUNTIME_FORCE (context_in IN VARCHAR2, data_in IN VARCHAR2);
PROCEDURE LOG_RUNTIME_FORCE (context_in IN VARCHAR2, data_in IN CLOB    );
PROCEDURE LOG_RUNTIME_FORCE (context_in IN VARCHAR2, data_in IN BOOLEAN );
PROCEDURE LOG_RUNTIME_FORCE (context_in IN VARCHAR2, data_in IN DATE,     format_in IN VARCHAR2 DEFAULT c_date_mask);
PROCEDURE LOG_INFO_FORCE    (context_in IN VARCHAR2, data_in IN VARCHAR2);
PROCEDURE LOG_INFO_FORCE    (context_in IN VARCHAR2, data_in IN CLOB    );
PROCEDURE LOG_INFO_FORCE    (context_in IN VARCHAR2, data_in IN BOOLEAN );
PROCEDURE LOG_INFO_FORCE    (context_in IN VARCHAR2, data_in IN DATE,     format_in IN VARCHAR2 DEFAULT c_date_mask);
PROCEDURE LOG_WARNING_FORCE (context_in IN VARCHAR2, data_in IN VARCHAR2);
PROCEDURE LOG_WARNING_FORCE (context_in IN VARCHAR2, data_in IN CLOB    );
PROCEDURE LOG_WARNING_FORCE (context_in IN VARCHAR2, data_in IN BOOLEAN );
PROCEDURE LOG_WARNING_FORCE (context_in IN VARCHAR2, data_in IN DATE,     format_in IN VARCHAR2 DEFAULT c_date_mask);
PROCEDURE LOG_ERROR_FORCE   (context_in IN VARCHAR2, data_in IN VARCHAR2);
PROCEDURE LOG_ERROR_FORCE   (context_in IN VARCHAR2, data_in IN CLOB    );
PROCEDURE LOG_ERROR_FORCE   (context_in IN VARCHAR2, data_in IN BOOLEAN );
PROCEDURE LOG_ERROR_FORCE   (context_in IN VARCHAR2, data_in IN DATE,     format_in IN VARCHAR2 DEFAULT c_date_mask);
PROCEDURE put_line ( data_in   IN VARCHAR2 );
PROCEDURE put_line ( data_in   IN BOOLEAN );
PROCEDURE put_line ( data_in   IN DATE, format_in IN VARCHAR2 DEFAULT c_date_mask );
PROCEDURE put_line ( clob_in   IN CLOB );
```


---

## Gedateerde dossierrevisie 002 — 11 november 2026: F1-mainbasis, centrale verduidelijkingen en F2-beslisdossier

**Status:** PROPOSED / DESIGN_ONLY / F2_NOT_COMPLETE. Dit is een *opvolging* van revisie 001 (10 november), geen vervanging of herschrijving van de oorspronkelijke bronvergelijking, meetvoorstellen of afhankelijkheden. Centrale ontvangst en beoordeling: [Issue #104 comment 6769721217](https://github.com/JPouwiel/TETOOLS/issues/104#issuecomment-6769721217), oordeel **ACCEPTED_AS_F2_DOCUMENTATION_PROPOSAL**. Actuele opdracht: [comment 6796577670](https://github.com/JPouwiel/TETOOLS/issues/104#issuecomment-6796577670). F1 is nu op main gepubliceerd: [PR #102](https://github.com/JPouwiel/TETOOLS/pull/102) **MERGED**, mergecommit \`63fd06659426088d6634d5d810884684c1b2ec5e\`, alleen **STATIC_TEST_PREPARATION**. F1-testpakket op main is vanaf deze revisie de referentie voor testcasenamen, veiligheidsstop, 28 cases, zes contracten en risicotrace; historische pre-merge heads in revisie 001 blijven historische referenties. De onafhankelijke F1-hercontrole [comment 6796287811](https://github.com/JPouwiel/TETOOLS/issues/104#issuecomment-6796287811) is CONDITIONAL_PASS voor F1, niet F2/F3/F4.

### A. Vaststaande centrale ontwerprichting versus open besluiten

| Onderwerp | Centrale ontwerprichting (ontvangen, geen codevrijgave) | Nog te nemen concreet besluit | Ontbrekend acceptatiebewijs | Beslisser / uitvoerende rol |
|---|---|---|---|---|
| RESTORE-identiteit D03 | Behoud same-session roundtrip, publieke signatures en geldige key/nesting; **fail-closed** bij niet-verifieerbare of gewijzigde loggerregistratie/configuratie/fysieke sessie. Sleutel is geen authenticatie. | Definieer identiteitstuple en levensduur: fysieke \`INST_ID/CON_ID/SID/SERIAL#/LOGON_TIME\` plus logger \`log_session_id/config_id\` waar betrouwbaar beschikbaar; bepaal atomair refusalcontract, backup-status en gecontroleerde herinitialisatie. | Werkelijke metadata, scenario's en observerasserties voor NULL/verschil/registratiewissel, reconnect en poolhergebruik; onafhankelijke ontwerpcontrole. | Module ontwerp; TETOOLS__REGIE functioneel contract; DBA fysieke identiteit en runtimebewijs |
| Keyless ADMIN_OBJECTS-calls D04 | De broncalls zonder sleutel (oorspronkelijke body regels 322/357) conflicteren met huidige verplichte LOGGER-sleutelcontrole. **Geen versoepeling** van LOGGER-validatie. | Welke werkelijk gebruikte OBJECTS-versie/callpath krijgt een apart compatibel consumerwijzigingsvoorstel (expliciete matching key of een afzonderlijk goedgekeurde overgang)? Wat is het fout-/rollbackcontract? | Werkelijke consumerrelease, callsites inclusief dynamische calls, owneracceptatie, negatieve sleutel-/nestingtests en installatievolgorde. | Bestaande OBJECTS-module-eigenaar (na aanwijzing/ontvangst), LOGGER-regie interfaceanalyse; TETOOLS__REGIE compatibiliteit/scope |
| Maintenance D04/D09–D11 | Consumer-EXECUTE is niet gelijk aan onderhoudsbevoegdheid. Geen nieuwe grant/API/actoridentiteit goedgekeurd. | Per methode: gewone LOG/toggle/eigen BACKUP/RESTORE versus \`clear_session_entries\`, \`clear_log_entries\`, observatie en recovery; wie mag *welke sessie-, log-, incident- of configuratierijen* wijzigen/zien, in welke PDB en met welke actorcontrole? | Echte direct/PUBLIC/role grants, definer-/invokercontext, schema-/objecteigenaar, actor- en gegevensscopematrix, negatieve refusalcases. | TETOOLS__REGIE functionele maintenancegrens; DBA/security technische bevoegdheid en bewijs; module contract |
| Incident-PK-trigger D01 | Trigger op GENERATED ALWAYS identity blijft **onbewezen fixturekandidaat**, niet bewezen uitvoerbaar op Oracle 19c. | DBA moet eerst zonder runtimeclaim kiezen tussen aantoonbaar veilige test-only trigger of alternatief dat *werkelijk* de bedoelde incident-PK-conflictcode oplevert; apart scope/rollback/DDL-commit ontwerp. | Identity/constraint-DDL, Oracle19c-compatibiliteitsbewijs, onafhankelijke fixture-review, RUN-isolatie, herstel en exacte ORA-00001-observatie na afzonderlijke GO. | DBA fixtureontwerp + module; TETOOLS__REGIE alleen voor eventuele afwijking/GO |
| Injectie/races D05–D06 | Externe observer/barriers, RUN-identiteit, stopbevoegdheid en bounded recovery zijn ontwerpvereisten. | Exacte foutpunten, errorallowlist, injectie-off, lock-/watchdogstop en rolchoreografie goedkeuren; geen schemawide injectie of onbevoegde KILL. | Uitvoerbare maar nog niet geactiveerde fixture-specificaties, onafhankelijke observer en DBA-ondertekende resource/stopgrenzen. | Module + DBA-coördinator + DBA/security |
| Performance D07 | Gematchte workload, baseline/kandidaat, herhaalde vensters, onafhankelijke licentiebewuste observatie. **30s watchdog en 20% triage zijn alleen hypothesen.** | Representatieve clientmix/payload/venster/sampleplan en absolute latency/throughput/resource-/locklimieten vaststellen; operationeel veilige maximale probe-duur separaat goedkeuren. | Werkelijke consumers, collector/licenties, metingen, variantie, onzekerheidsintervallen en expliciete fout-/integriteitscriteria. | Consumers + DBA voor workload/methode; TETOOLS__REGIE voor acceptatiegrenzen |
| Recovery D08 | BACKUP/RESTORE-API is geen DB-backup; cleanup90 is geen herstel. Componenten zijn planningsonderdelen. | Doel/RPO, herstelpunt, stopowner, herstelstrategie, totale toegestane RTO en vrijgavecriteria vaststellen. **Som van component-p95 is geen bewezen totale p95-RTO.** | Getekend runbook, herstelbare backup/snapshot, volumeafhankelijkheid, geautoriseerde rehearsal en gemeten *end-to-end* RTO-verdeling inclusief correlatie en onzekerheid. | Aangewezen DBA/recovery-eigenaar; operationeel eigenaar RPO/RTO-behoefte; TETOOLS__REGIE scope/acceptatie |

**Voorgesteld RESTORE-contract (nog geen implementatiebesluit):** Bij BACKUP wordt de beschikbare registratie- en fysieke identiteit als één context vastgelegd. Bij RESTORE wordt elke relevante component **NULL-veilig** vergeleken: gelijkheid is uitsluitend aangetoond als beide waarden niet-NULL en gelijk zijn, of als voor een expliciet toegestane optionele component beide NULL zijn. Een verplichte identiteit die NULL of onbekend is, resulteert in *refusal*, niet in stilzwijgende gelijkheid. Bij refusal: geen wijziging van persistente configuratie of actuele cache, geen verbruik van de geldige backup zonder expliciet besloten lifecyclecontract, en een herleidbare fout. Na een vastgestelde registratiewissel moet een afzonderlijk veilig pad de actuele configuratie opnieuw laden, de oude backupcontext ongeldig maken en een nieuwe geldige sessiecontext vastleggen **zonder bestaande configuratierijen te verwijderen of te overschrijven**. Het precieze atomische gedrag van deze stappen is een open ontwerpbesluit en moet met negatieve tests worden onderbouwd.

**Pool versus reconnect:** Poolhergebruik kan dezelfde fysieke databasesessie behouden terwijl de functionele aanroeper wijzigt; identieke SID/serial bewijst dan niet dezelfde applicatiecontext of autorisatie. Een echte reconnect kan nieuwe fysieke identiteit en verloren package-state opleveren. Beide zijn aparte regressieklassen. Geen cross-connection herstel op basis van oude package-backup aannemen. Onderzoek tevens session reset/package state bij pooluitgifte en RAC-instancewissel; geen deploymentgedrag claimen zonder driver/poolbewijs.

**Statistiek en herstel:** De revisie-001 voorstellen \`30 s\`, \`20%\`, \`>=1000 calls\`, vijf vensters en 1/3/12 clients zijn **verkennende ontwerpwaarden**, niet goedgekeurde veiligheidstermijnen, SLO's, statistisch voldoende steekproefomvang of harde regressiegrenzen. p99 vraagt aantoonbaar voldoende tail-observaties, onafhankelijkheid/afhankelijkheid van metingen en onzekerheidsrapportage. Voor RTO rapporteert men een gemeten end-to-end herstelduur per proef; afzonderlijke component-p95-percentielen mogen niet worden opgeteld en als totale p95 gepresenteerd. Herstelvensters en harde watchdoggrenzen volgen uitsluitend uit goedgekeurde DBA/operationele randvoorwaarden.

### B. D01–D11: open besluit, bewijs, eigenaar en status

Alle rijen blijven **BLOCKED**; rolbenaming is **geen** bevestigde persoonsaanwijzing. \`AANWIJZEN\` betekent dat de gebruiker/beheerorganisatie één coördinator moet aanwijzen die de bevoegde persoon en diens ontvangst laat vastleggen. TETOOLS__REGIE beslist functionele scope, niet namens DBA/security.

| ID | Concrete nog open beslisvraag | Ontbrekend bewijs voor sluiting | Aan zet / persoonsstatus | Status |
|---|---|---|---|---|
| D01 | Welke echte incident-PK-conflictfixture is veilig en 19c-geschikt, zonder productiedata of onbevoegde DDL? | Identity/PK-DDL, foutcode, RUN-isolatie, review, rollback/herstel en geautoriseerde proef | Module + DBA fixture; DBA **AANWIJZEN** | BLOCKED |
| D02 | Welke API-, filter-, batch-, retentie-, clear- en foutsemantiek is de geldige compatibiliteitsbaseline? | Besluit per afwijking, versiegebonden regressieasserties en echte consumers | TETOOLS__REGIE + module + consumereigenaren **AANWIJZEN** | BLOCKED |
| D03 | Welke NULL-veilige identity-/refusal-/backup-lifecycle- en herinitialisatiegarantie geldt voor RESTORE? | Geversioneerd tuple- en state-transitionontwerp; pool/reconnectcases; metadata en negatieve tests | Module ontwerp; TETOOLS__REGIE gedrag; DBA **AANWIJZEN** | BLOCKED |
| D04 | Welke echte OBJECTS/SESSIONS/overige consumers, versies en maintenancecalls moeten compatibel blijven of migreren? | Deployed dependency- en callsite-inventaris, eigenaarbevestiging, keyless-correctievoorstel, matrix van toegestane maintenance | Consumereigenaren **AANWIJZEN**, module; centraal scope | BLOCKED |
| D05 | Welke exacte C02–C06 injectoren, errorallowlists, observer en stopvoorwaarden zijn veilig? | Per-case instrumentatie/fixture, onafhankelijke review, injection-off en recovery | Module + DBA/security **AANWIJZEN** | BLOCKED |
| D06 | Welke drie RAC-routes, barrier-events, lockupperbounds en cancelregels zijn toegestaan? | Werkelijke instances/services, run/client-tuples, observer, choreografie, watchdog en DBA-goedgekeurde stop | DBA testcoördinator **AANWIJZEN**, module | BLOCKED |
| D07 | Welke workload, collector, absolute SLO's en statistische zekerheid gelden? | Consumer-mix, licensing, baseline, herhalingen/CI en absolute acceptatiegrenzen | Consumers/DBA **AANWIJZEN**; TETOOLS__REGIE besluit | BLOCKED |
| D08 | Welke recovery-scope, RPO/RTO, stopowner en rehearsal zijn aanvaardbaar? | Snapshot/backup-ID, herstelrunbook, eind-tot-eind metingen en onafhankelijke signoff | Recovery- en operationeel eigenaar **AANWIJZEN**, DBA; centraal scope | BLOCKED |
| D09 | Welke werkelijke principals/direct/PUBLIC grants gelden per methode? | Effectieve grant-/schema-/rolcontext, OWNER/POSITIVE/NEGATIVE/OBSERVER/RECOVERY bewijs | DBA/security **AANWIJZEN**, module | BLOCKED |
| D10 | Hoe wordt echte PDB/dictionary/GV$-zichtbaarheid bewezen zonder absence als denial te tellen? | Container-/instancekaart, observer grants, positieve/negatieve fout- en zichtbaarheidscases | DBA/security + onafhankelijke observer **AANWIJZEN** | BLOCKED |
| D11 | Welke principal mag welke onderhoudsmethode uitvoeren op welke gegevensscope? | Method-to-principal-to-row-scopebesluit, betrouwbare actoridentiteit, negatieve refusaltest en eventuele apart geautoriseerde correctie | TETOOLS__REGIE functioneel; security/DBA **AANWIJZEN**; module | BLOCKED |

### C. G01–G08: bewijsaanvraag, verantwoordelijkheid en status

| Gate | Exact ontbrekend bewijs | Aan te wijzen bevoegde rol / aanwijzer | Status |
|---|---|---|---|
| G01 | Exact Oracle19c EE RU/SQLPATCH, DB_UNIQUE_NAME/PDB/CON_ID, drie fysieke RAC-instances en serviceroutes, drivers/clients, clocks | Beheerorganisatie wijst DBA-platformeigenaar aan | OPEN |
| G02 | Disposable niet-productie doel, object-/data-inventory, isolatie, toestemming en eigenaar | Beheerorganisatie wijst DBA-schema-/omgevingsbeheer aan | OPEN |
| G03 | Echte OWNER/POSITIVE/NEGATIVE/OBSERVER/RECOVERY-principals, direct/PUBLIC/role grants en containercontext | Beheerorganisatie wijst security-/DBA-autorisatie-eigenaar aan | OPEN |
| G04 | F1-main bronpins versus feitelijke exports, clientfailfast, installvolgorde en object/compilatiebewijs | Module bereidt offline pins; DBA-platformeigenaar levert doelbewijs | OPEN; alleen offline pins beschikbaar |
| G05 | D01–D06/D11 fixtures, toegestane foutcodes, resource-/stop-/watchdoggrenzen, injection-off en herstel | Module ontwerpt; aangewezen DBA/testcoördinator autoriseert voorbereidingsontwerp | OPEN / BLOCKED |
| G06 | Getekend snapshot/backup, restore/rebuild, RPO/RTO-behoefte, stopowner, rehearsalontwerp | Beheerorganisatie wijst recovery-eigenaar én operationeel beslisser aan | OPEN |
| G07 | Externe originele stdout/stderr/exit, spool-/RUN-keys, observator en gelicentieerde collector/evidenceopslag | DBA-platformeigenaar wijst observator/evidence-eigenaar aan | OPEN |
| G08 | Echte deployed consumers/API/defaults, source-vs-027, maintenancebaseline, workload en functionele/performancegrenzen | Beheerorganisatie wijst consumereigenaren aan; TETOOLS__REGIE beslist scope | OPEN |

**G09: NOT_GRANTED.** Geen enkele voorbereidende beschrijving is een uitvoeringsautorisatie. C02–C06 en LGR4-04/05/10/11 blijven BLOCKED; F2_NOT_COMPLETE. Oracle, SQL*Plus, SQLcl, RAC, performance, herstel en triggerfixture zijn NOT_EXECUTED.

### D. Eén gezamenlijk verzoek aan beheerorganisatie en betrokken eigenaren

**Aan gebruiker/beheerorganisatie — coördinatoraanwijzing gevraagd.** Wijs **één verantwoordelijke coördinator** aan voor dit F2-bewijspakket en laat die de werkelijk bevoegde DBA-platform-/schema-eigenaar, security-/grant-eigenaar, recovery-/operationeel eigenaar, testcoördinator/observer en eigenaren van de geïnstalleerde LOGGER-consumers identificeren. Laat ieder bevoegdheid, ontvangst en beschikbaarheid bevestigen; onbekende namen blijven **UNASSIGNED**. Lever één gestructureerde G01–G08-inventaris met: 19c RU/PDB/3-node servicekaart, disposable target/inventory, echte principals/grants/visibility, F1-export- en clientdetails, goedgekeurde fixture-/stop-/watchdogontwerpen, snapshot/recovery/RTO/RPO en bewijsopvang/licenties, deployed consumer-versies/calls, workload en voorgestelde meetgrenzen. **Geen wachtwoorden, tokens, connectiestringgeheimen of productiedata.** Niet aanleveren betekent open afhankelijkheid, geen stilzwijgende acceptatie of fictieve eigenaar.

**TETOOLS__REGIE** wordt afzonderlijk gevraagd om de nog open concrete functionele besluiten D02/D03/D04/D07/D08/D11 en eventuele scope-/afwijkingsbesluiten te prioriteren. Centrale optie-C-registerpublicatie en onafhankelijke F1-review behoren niet tot dit werkpakket.

### E. Verificatie- en publicatiegrens revisie 002

Dit is een gedateerde *dossieraanvulling* op bestaande PR #114. Revisie 001 blijft letterlijk behouden. Alleen dit Markdown-dossier wordt gewijzigd; geen wijziging aan code, tests, frozen releases, CHANGE_REGISTER, andere sessie-entries of centrale besluitregistratie. Na commit worden het exacte dossierblob, PR-head en Issue #104 teruggelezen. Zonder merge blijft PR114 PROPOSED en F2 niet geaccepteerd. De historische FAIL, bestaande LOGGER-RAC-20261105-001/Issue55 en eerder geregistreerde bronverschillen blijven behouden.
