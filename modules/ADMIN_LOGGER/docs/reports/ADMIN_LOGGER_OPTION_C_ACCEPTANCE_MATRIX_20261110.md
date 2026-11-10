# ADMIN_LOGGER — optie C, gefaseerde acceptatie (voorstel)
Datum: 2026-11-10. Opdracht: TETOOLS__REGIE via Issue #104 comment 6764122808; relay `RELAY-HANDOFF-20261110-LOGGER-REREVIEW-001`. Eigenaar technische uitwerking: bestaande `ADMIN_LOGGER-REGIE-20261104-01`. Platform: Oracle Database 19c Enterprise, beoogd 3-node RAC. **Besluit optie C inhoudelijk APPROVED door gebruiker; deze matrix is PROPOSED voor centrale controle/publicatie.** De formele centrale besluitregistratie op main blijft afzonderlijk PENDING. Dit document is geen G09 of acceptatiebewijs.

## Geverifieerde GitHub-uitgangssituatie
- Gelezen main `28adcf32d04f6f6e7d0e2551010abb30f1c974c5` (2026-11-10).
- [PR #102](https://github.com/JPouwiel/TETOOLS/pull/102) OPEN/NOT_MERGED, head `afb5330ac538cb913e7d5e3eb8d92c7daeddc123`. Correcties RR01/RR02 zijn branch-gepubliceerd, `CORRECTED_PENDING_INDEPENDENT_REVIEW`, niet geaccepteerd. Pakket 28 cases, T01–T08, C01–C06, 17 canonieke risico/openpunten.
- De [tweede review FAIL](https://github.com/JPouwiel/TETOOLS/issues/104#issuecomment-6762681287) betreft historische head `613f294cba8242c8fa1ff288b5d86653e52f4830`; FAIL-historie behouden. [Nieuwe reviewaanvraag](https://github.com/JPouwiel/TETOOLS/issues/104#issuecomment-6763624708) voor `afb5330...` is al gepubliceerd; ontvangst en resultaat **PENDING**. Beoogde onafhankelijke reviewer: bestaande `d58c7999-a8ba-4534-ab08-1c8c87181b64` / thread `01a19fe0-7428-7763-8c6c-bb8b9c26abc3`. Reviewer dient onafhankelijkheid en ontvangst opnieuw zelf te bevestigen. De huidige uitvoerders mogen geen onafhankelijk PASS afgeven.
- [PR #108](https://github.com/JPouwiel/TETOOLS/pull/108) OPEN/DRAFT/NOT_MERGED; alleen historische reviewdocumentatie. Niet mergen zonder afzonderlijke centrale vrijgave.
- [Elf concrete BLOCKED-dependencies](https://github.com/JPouwiel/TETOOLS/blob/afb5330ac538cb913e7d5e3eb8d92c7daeddc123/modules/ADMIN_LOGGER/tests/step4_20261109_001/blocked_dependencies.md). [G01–G09 bronmatrix](https://github.com/JPouwiel/TETOOLS/blob/afb5330ac538cb913e7d5e3eb8d92c7daeddc123/modules/ADMIN_LOGGER/tests/step4_20261109_001/environment.template.md). Het bestaande suite-signaal `LOGGER-RAC-20261105-001` / Issue #55 wordt hergebruikt. Geen nieuw SUITE_IMPACT_SIGNAL.

## Vier strikt afzonderlijke acceptatiemomenten

| Fase | Onderwerp en scope | Eigenaar uitvoering / besluit | Vereiste objectieve evidence | Criteria voor faseovergang | Huidige status |
|---|---|---|---|---|---|
| **F1 STATIC_TEST_PREPARATION** | Volledige PR102-head inclusief veiligheidsstops, RR01/RR02, 28 cases, 6 contracten, 17 risico's, zes bronpins, audit/relay en niet-uitvoeringsgrenzen; **alleen testvoorbereiding** | Onafhankelijke reviewer: eigen volledige-headreview; ADMIN_LOGGER__REGIE: technische verwerking; TETOOLS__REGIE: scope en mergegate | Exact head-SHA en volledige diff, onafhankelijke toetsing met eigen bewijs, status per bevinding, centrale beslissing over welke documentatie statisch geaccepteerd kan worden | Onafhankelijke review en centrale inhoudelijke scope-/mergebeoordeling; geen automatische merge, geen G09, geen Oracle-acceptatie | **WAITING_INDEPENDENT_REVIEW**; oude FAIL geldig; PR102 OPEN |
| **F2 EXECUTION_PREPARATION** | Elf LGR4-04/05/10/11-afhankelijkheden; complete C02–C06 fixtures/injectie, herstel, regressie, consumers/027, security/principals; G01–G08 concreet voorbereiden en afzonderlijk beoordelen | ADMIN_LOGGER__REGIE technische testontwerpen; DBA/security omgeving, grants, herstel, observatie; consumers API-inventaris; TETOOLS__REGIE functionele scope/criteria | Geversioneerde fixtures, case-contracttrace, werkelijke principals/privileges, 3-servicekaart en RU, negatieve/positieve scenario's, meetgrenzen en signed herstelrunbook, voor iedere gate echte evidence en eigenaar | G01–G08 expliciet beoordeeld, alle relevante BLOCKED-testscenario's veilig uitvoerbaar ontworpen, risicovolle scope/criteria centraal besloten. **Nog geen uitvoering** | **BLOCKED** door 11 dependencies en G01–G08 |
| **F3 ORACLE_RAC_VALIDATION** | Na expliciete aparte G09: echte Oracle 19c EE-install/compile, functionele en regressietests, security/transactions, concurrency/performance en **3 verschillende RAC-instances** plus failover/recovery binnen verleende case/window | DBA/testcoördinator: uitvoering en veilige omgeving; module: scripts/diagnostiek; onafhankelijk bewijsbeoordelaar; TETOOLS__REGIE: G09 toestemming | G09-besluit dat DB/PDB/CON_ID/RU, principals, cases, stop/recovery en tijdvenster bindt; gesigneerde G01–G08, meetbare PASS/FAIL en originele client/DB/observer/spool-bewijzen | Alle verplichte tests aantoonbaar geslaagd of expliciet centraal geaccepteerd restrisico; bij FAIL terug naar voorbereiding/correctie en hertest | **NOT_AUTHORIZED / NOT_EXECUTED**; G09 NOT_GRANTED |
| **F4 MODULE_RAC_ACCEPTANCE** | Integrale moduleacceptatie, inclusief waar nodig **afzonderlijk geautoriseerde** productbroncorrecties, volledige regressie/hertest, functionaliteit/consumers, RAC-gedrag, restpunten en release-/beheeracceptatie | ADMIN_LOGGER__REGIE technisch dossier; DBA/security acceptatie operationeel bewijs; consumers functionele bevestiging; TETOOLS__REGIE definitief besluit/afwijkingen/RAC_READY | Integrale testresultaten T01–T08, C01–C06; geverifieerde fixes en hertest, consumentencompatibiliteit, meetgrenzen en DBA-signoff, centraal expliciet restrisicobesluit | Alleen expliciete centrale modulevrijgave; geen afleiding uit F1/F2/F3 of GitHub mergeability | **NOT_READY / RAC_READY_NOT_DEMONSTRATED** |

**Fasegrens:** F1 kan als statische voorbereiding worden geaccepteerd terwijl F2–F4 geblokkeerd blijven. Een F1-merge, indien ooit afzonderlijk toegestaan, is geen DBA-goedkeuring, G09, productiebronvrijgave of RAC_READY. Afsluiting van een eerdere fase verleent geen automatische bevoegdheid voor de volgende.

## Elf afhankelijkheden — exacte fasetoewijzing, eigenaar en beslisser

Bron: [blocked_dependencies.md, PR102-head afb5330](https://github.com/JPouwiel/TETOOLS/blob/afb5330ac538cb913e7d5e3eb8d92c7daeddc123/modules/ADMIN_LOGGER/tests/step4_20261109_001/blocked_dependencies.md). Alle rijen blijven **BLOCKED**; genoemde eigenaren zijn verantwoordelijkheidsrollen, nog geen geverifieerde persoonlijke ontvangst.

| Nr. | Bevinding / afhankelijkheid | Voorbereiding | Bewijs-/validatiefase | Technisch eigenaar | Centraal besluit / grens |
|---|---|---|---|---|---|
| D01 | LGR4-04 werkelijk incident-PK-conflictfixture | F2 | F3, acceptatie F4 | Module + DBA | Fixture scope/veiligheid, eventuele functionele afwijking |
| D02 | LGR4-05 volledige regressie incl. filters, batches en maintenance | F2 | F3/F4 | Module; centrale regie functionele ambiguïteit | Behouden/corrigeren/heroverwegen en wijzigingsscope |
| D03 | LGR4-05 voorstel 027 en BACKUP/RESTORE semantiek | F2 | F3/F4 | Module + DBA | Source-vs-027, backward compatibility, negative backup/restore scope |
| D04 | LGR4-05 consumenten en maintenance baseline | F2 | F3/F4 | Module + consumer-eigenaren | Officiële ondersteunde API/consumers/onderhoudsomvang |
| D05 | LGR4-10 veilige fault injection C02–C06 | F2 | F3/F4 | Module + DBA | Testcase-/foutinjectiescope; G09 afzonderlijk |
| D06 | LGR4-10 concurrency/races/choreografie | F2 | F3/F4 | Module + DBA-coördinator | Resource-/veiligheidsgrenzen en event. afwijkingen |
| D07 | LGR4-10 performance/benchmark | F2 | F3/F4 | Module + DBA | **Numerieke** latency/throughput/resources acceptatiecriteria en relevante licenties |
| D08 | LGR4-10 backup, recovery en RTO | F2 | F3/F4 | DBA recovery + module | Snapshot-scope, stop/rollback en maximaal RTO |
| D09 | LGR4-11 werkelijk principals en directe/PUBLIC grants | F2 | F3/F4 | DBA/security + module | Least-privilege/maintenance scheiding; bronaanpassing afzonderlijk |
| D10 | LGR4-11 PDB-/dictionary-/sessiezichtbaarheid | F2 | F3/F4 | DBA/security + onafhankelijke observer + module | Negatieve security-PASS alleen bij bewezen visibility/denial |
| D11 | LGR4-11 maintenance-autorisatie | F2 | F3/F4 | Module + DBA/security | Welke principal welke onderhoudsfunctie mag uitvoeren; eventuele API/bronwijziging apart |

Er is **geen** vervangende fictieve PASS om blokkades weg te boeken; iedere D01–D11 blijft open tot gevalideerde specifieke fixture, besluit, bewijs en herstelvoorwaarden zijn gepubliceerd. Niet alle D01–D11 vereisen vooraf een centrale functionele wijzigingsbeslissing; alleen hieronder genoemde regiegrenzen leggen besluiten bij TETOOLS__REGIE.

## C01–C06 en G01–G09 per fase

| Contract/gate | F1 | F2 | F3 | F4 | Status |
|---|---|---|---|---|---|
| C01 business rollback vs autonome diagnostiek | Statische ontwerp-/assertiecheck | Fixture, grants, DBA-rollback-bewijsopzet | Werkelijke transactieasserties | Functionele acceptatie | NOT_EXECUTED |
| C02 management atomiciteit | Script/design, geen execution | D05 injector + observer + herstel | Contracttest | Integrale acceptatie | BLOCKED |
| C03 duurzame diagnostiek | Script/design, geen execution | D05/08 durable evidence + recovery | Contracttest | Integrale acceptatie | BLOCKED |
| C04 failure-classificatie | Script/design, geen execution | D05 observer, toegestane errorcodes | Contracttest | Integrale acceptatie | BLOCKED |
| C05 LOG_* specifiek feedback | Script/design, geen execution | D02/05 API/fixtures/expected returns | Contracttest | Integrale acceptatie | BLOCKED |
| C06 geen recursieve foutlogging | Script/design, geen execution | D05 fault path + watchdog/stop | Contracttest | Integrale acceptatie | BLOCKED |
| G01 Oracle 19c RU, RAC services, clocks | Geen runtimebewijs | DBA inventariseert+verifieert | Route- en omgevingidentiteit tijdens tests | DBA acceptance | OPEN |
| G02 geïsoleerde PDB/schema en inventory | Geen runtimebewijs | DBA keurt disposable doel/objects goed | Voor- en nameting | Operationele acceptatie | OPEN |
| G03 principals/direct/PUBLIC grants | Bronmatige dependency-inventaris | DBA/security verifieert matrix | Positieve/negatieve privilege-tests | Security acceptance | OPEN |
| G04 zes bronpins, export/client/installer | Offline 6 source hashes mogelijk | DBA/export+SQL-client/identity/audit | Feitelijke install/compile/error flow | Bewijsacceptatie | PARTIAL/OFFLINE; OPEN |
| G05 fixtures/injecties/watchdog | Alleen ontwerp | D01,D02,D03,D05,D06,D11 geautoriseerd ontwerp | Testcases incl. stop/cancel | Fixturebewijs acceptatie | OPEN/BLOCKED |
| G06 snapshot/recovery/RTO | Alleen ontwerp | DBA tekent recoveryplan | Alleen geautoriseerde herstelproef | Operationele acceptatie | OPEN |
| G07 evidencestore/licenties/collector | Statische evidenceplancheck | DBA/module verifieert opvang en licenties | Originele logs/metrics/observer | Evidencedossier acceptatie | OPEN |
| G08 echte consumers, API/027 en criteria | API-inventaris offline | Module+centrale regie/consumers besluiten | Regressie en representatieve load | Functionele acceptatie | OPEN |
| **G09** centrale uitvoeringsautorisatie | Niet verleend | Voorbereiding kan zonder GO; geen uitvoering | **Afzonderlijke expliciete GO vereist voor aanvang** | Geen impliciete vrijgave | **NOT_GRANTED** |

## Functionele besluiten die TETOOLS__REGIE moet nemen of agenderen

1. **F1/mergegate:** Accepteert TETOOLS__REGIE bij onafhankelijke PASS (en gespecificeerde restblokkades) een merge van uitsluitend statisch testvoorbereidingsmateriaal? Geen automatische toestemming uit dit document; behoud PR102 OPEN tot regiebesluit.
2. **G08 / LGR4-05:** Bevestig welke bestaande API/consumers/versies als compatibiliteitsbaseline gelden en het gewenste gedrag van filter, batch, retentie, clear en onderhoud; klasseer BEHOUDEN/CORRIGEREN/HEROVERWEGEN volgens canoniek beleid.
3. **LOG-OPEN-04 / 027:** Bevestig of backup/restore-semantiek en negatieve backup-key/nestingcases worden behouden of afzonderlijk functioneel gewijzigd. Geen impliciete implementatie.
4. **RAC-A-012 / maintenance:** Beslis welke maintenance-operaties voor welke principal rol/functioneel toegestaan zijn; eventuele publieke API-/broncodeaanpassing afzonderlijk laten autoriseren.
5. **Performance:** Goedkeuring representatieve workload, baseline, numerieke latency/throughput/lock- en RTO-grenzen, met DBA en consumers.
6. **F2→F3 / G09:** Pas na alle relevante G01–G08-bewijzen en review: afzonderlijk beslissen over exacte database/PDB/CON_ID, principals, testcases/operaties, venster, stop- en herstelbevoegdheid.
7. **F4:** Afzonderlijk besluiten over resterende risico's, compatibiliteit en `RAC_READY`; niet uit F3 of GitHub-status afleiden.

Dit zijn benodigde **beslispunten/voorstellen**, niet reeds goedgekeurde concrete antwoorden. TETOOLS__REGIE behoudt formeel zeggenschap over afwijkingen, scope-uitbreiding, merge en G09.

## Technische bewijsopdrachten aan DBA / security / owners

- DBA G01: exact `19c EE` RU/SQLPATCH, topology van werkelijk drie verschillende instances, concrete service-routing, DB_UNIQUE_NAME/PDB/CON_ID, client/driver, clocks/timezones; bewijs plus testverantwoordelijke.
- DBA G02: disposable schema/PDB, vóór/na objectlijst en databeperkingen, installatie-ordervalidatie; eigenaar en herstelpunt.
- DBA/security G03: werkelijke OWNER/POSITIVE/NEGATIVE/OBSERVER/RECOVERY-identiteiten, grants direct en PUBLIC inclusief context, positieve/negatieve verwachte toegangen, PDB/dictionary-zichtbaarheid.
- DBA/module G04: exportbytes, hashes, SQL*Plus/SQLcl-versies, foutpropagatie, sourceinstallatievolgorde en herleidbaar bewijs; offline pins alleen zijn onvoldoende.
- DBA/module G05: iedere veilige fixture met Oracle identity/PK-metadataspecificatie, negatieve foutcode, watchdog/barrier/timeout, injection-off en cleanup; D01/D05/D06/D11.
- DBA recovery G06: afzonderlijk getekend snapshot/backup, herstelcommando's, stop-/rollback-eigenaar, meetbaar RTO, herstelproef uitsluitend na GO.
- DBA/observer G07: unieke run/client/spool, externe stdout/stderr+exit, fysieke GV$-sessietuple en metrics/licenties, betrouwbare evidenceopslag.
- Module + consumers + centrale regie G08: geldende API/defaults, echte consumers, voorstel027, functionaliteit, workload en numerieke performancecriteria.

**Geen van deze feiten over de werkelijke DBA-omgeving is al aangeleverd of runtime-gevalideerd.** Eigenaar in de tabel is een roltoewijzing en geen bewijs dat een persoon de taak al aanvaard heeft.

## Review- en mergegatevervolg

1. De eerdere [onafhankelijke review FAIL](https://github.com/JPouwiel/TETOOLS/issues/104#issuecomment-6762681287) wordt niet overschreven. De [reviewaanvraag exacte head afb5330](https://github.com/JPouwiel/TETOOLS/issues/104#issuecomment-6763624708) wordt hergebruikt; een *echte* handmatige revieweractivatie/ack is nog nodig.
2. Nieuwe onafhankelijk vastgelegde `PASS/CONDITIONAL_PASS/FAIL` van **de volledige head** met bewijs is nodig voor de F1-regiebeoordeling. `CONDITIONAL_PASS` is geen automatische mergevrijgave.
3. TETOOLS__REGIE beslist daarna afzonderlijk of uitsluitend F1/testvoorbereiding naar main mag. PR108 is historische reviewdocumentatie, zonder impliciete merge.
4. F2 blijft onafhankelijk doorgaan op bewijs-/fixturevoorbereiding; F3 pas na expliciete G09; F4 na feitelijke 3-node RAC- en regressievalidatie.

## Beperkingen en status
Dit is een **documentatie-/coördinatievoorstel**. Geen module- of testpakketbron gewijzigd. Geen frozen release, privileges of productiecode gewijzigd. Geen Oracle-connectie, SQLPlus, SQLcl, compilatie, runtime, RAC, performance, failover, herstel of G09. Geen PR102/108-merge. Main-registratie van deze matrix volgt pas na apart geautoriseerde merge/readback. Huidige onafhankelijke review ontbreekt; daarom geen onafhankelijke PASS, RAC_READY of volledige moduleacceptatie. Bestaande `LOGGER-RAC-20261105-001` en Issue55 blijven ongewijzigd.
