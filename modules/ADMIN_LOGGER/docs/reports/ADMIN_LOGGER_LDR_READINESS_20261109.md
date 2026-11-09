# ADMIN_LOGGER — ontwikkelgereedheid en eerste pilotbeslisvoorstel

**Datum:** 2026-11-09. **Eigenaar:** ADMIN_LOGGER__REGIE (`ADMIN_LOGGER-REGIE-20261104-01`). **Status:** ANALYSIS_COMPLETE / IMPLEMENTATION_NOT_AUTHORIZED. Oracle Database 19c Enterprise, beoogde drie-node RAC. **RAC-readiness NOT_DEMONSTRATED; Oracle NOT_EXECUTED.**

## LDR-01 — bron- en compatibiliteitsbaseline

Canonieke versie **20261015_500** (import [PR #4](https://github.com/JPouwiel/TETOOLS/pull/4), RAC-report-A bronboom `40f0692906c52f576d03c76ea128fb10d3da04db`). Vijf bronbestanden in `modules/ADMIN_LOGGER/src/20261015_500/`, blobs: PKB `febb57c5aebe3ce5d23799f60c6c38f793681d00`; PKS `9331a2756b1c2196280cda3f10bf1643285f61ab`; TABLE `240b6516fcfd7e9a99ae7d47bb18433f77a8686f`; SEQUENCE `47416ff9583c32bc14cbe49007cd277f2449682b`; sample procedure `5a5e4e3181816aa520f5067f2b8c0abd3fef63f1`. Bron-/frozen release-inhoud niet gewijzigd. Huidig gedeployde Oracle objecten en bevroren-releaselijst buiten deze bronset: UNVERIFIED.

Objecten: `ADMIN_LOGGER_SESSIONS`, `ADMIN_LOGGER_CONFIG`, `ADMIN_LOGGER_LOG`, `ADMIN_LOGGER_INCIDENT`, `ADMIN_LOGGER_GUARD`, `ADMIN_LOGGER_LOGBATCH_SEQ`, package spec/body ADMIN_LOGGER en voorbeeldprocedure. Directe afhankelijkheden: `V$SESSION`, `DBA_SOURCE`, `DBMS_DEBUG_JDWP`, autonome transacties, TETOOLS objectgrants; echte rechten/consumergebruik UNVERIFIED. Installatie: schema en grants, tables/constraints vóór indexen, sequence vóór batchgebruik, SPEC vóór BODY, daarna compile/test.

Publieke API (SPEC 376–491): get_invoking_sid/serial, get_logon_time/get_audsid, logging_is_on/debug_is_on, LOG_RUNTIME/INFO/WARNING/ERROR/DEBUG functies en procedure-overloads (VARCHAR2/CLOB/BOOLEAN/DATE), FORCE-varianten, toggle_logging/debug/batch, session_details, session_details_revert, clear_session_entries/log_entries, show_config/help/banner/version/put_line. Behoud parameters/defaults en publieke backup/restore; complete consumer-inventarisatie en werkelijke afhankelijkheden blijven LOG-OPEN-05.

[Traceermatrix met alle 17 bevindingen](ADMIN_LOGGER_LDR_TRACE_20261109.md), gebaseerd op [volledig RAC-rapport A](20261105__PLSQL__TETOOLS_ADMIN_LOGGER__RAC_analyse_A_20261015_500_STE_033.html). Prioriteiten P1/P2 zijn revieweroordelen; geen technische punten gesloten.

## LDR-02 — eerste kandidaat: twee DDL-blokkers

- **RAC-A-010 (P1):** TABLE regels 86–91 maken `admin_logger_position_uk` voordat `ADMIN_LOGGER_LOG` op 108–126 bestaat. Concept: indexstatement verplaatsen naar na log-tabelterminator, zonder inhoudelijke wijziging.
- **RAC-A-011 (P1):** TABLE regels 163–164 missen komma tussen `config_snapshot CLOB` en `admin_logger_incident_pk`. Concept: voeg één komma toe.

Beide zijn statisch reproduceerbare source-defecten. Een geïsoleerde DDL-only wijziging aan één niet-bevroren ontwikkelrevisie is technisch klein en testbaar; risico van installatieprocedure, bestaande data en afhankelijke objecten blijft. [Diepteanalyse, alternatieven, conceptdiff en rollback](ADMIN_LOGGER_LDR_DDL_20261109.md). Geen code of DDL uitgevoerd.

## LDR-03 — beleidsbesluit 23 en F03

Het beleidsmatig APPROVED autonome transactie-/exceptioncontract is **niet technisch gevalideerd**. Zes voorgestelde acceptaties: caller transaction intact, atomaire beheerwijzigingen, duurzame diagnostiek, foutclassificatie, API-afhankelijke feedback/exceptionsemantiek en geen recursieve fallback. `log_runtime` best-effort bij incidentele registratieproblemen; `log_info`/`log_warning` interne foutafhandeling; `log_error`/`log_debug`/`log_*_force` gebruiker- én applicatieterugmelding. Het volledige [testplan](ADMIN_LOGGER_LDR_TESTPLAN_20261109.md) behandelt alle acht voorgeschreven categorieën, risicodiepte en bewijs. Oracle NOT_EXECUTED.

## LDR-04/05 — RAC en omgeving

Instance- en containeridentiteit, remote sessie-opruiming, onderhoudsrechten, Oracle 19c RU, TETOOLS schema/grants, drie-node RAC-testomgeving, service/replay en echte consumers: UNVERIFIED. Het bestaande suite-impactsignaal `LOGGER-RAC-20261105-001` blijft bij TETOOLS__REGIE; geen duplicaat of zelfstandig suitebesluit. RAC-A-001/002/012 blijven relevante risico's buiten de DDL-pilot. Zie [omgevingsregister](ADMIN_LOGGER_LDR_TESTPLAN_20261109.md).

## LDR-06 — exact voorstel voor autorisatie (GEEN IMPLEMENTATIEGOEDKEURING)

**Scope:** maak pas na toestemming een **nieuwe, niet-bevroren ontwikkelrevisie** van uitsluitend `TABLE/TAB_TETOOLS_ADMIN_LOGGER__20261015_202.sql`. Twee wijzigingen: verplaats de bestaande positie-index na LOG CREATE TABLE; voeg komma toe bij INCIDENT. Geen PKS/PKB/API/sequence/grantwijziging, geen gegevensmigratie, geen productie-installatie, geen RAC-architectuurwijziging. Behoud canonieke originele bron en release.

**Risico:** klein op code-niveau, middel op installatieniveau; afhankelijkheid van clean schema, SQL-client fail-fast, privileges, objectvolgorde en bestaande data. **Rollback:** vooraf geverifieerde testschema-snapshot of goedgekeurde omgekeerde DDL met back-up; DDL auto-commit, gewone ROLLBACK is onvoldoende. Een bestaand schema mag niet met een fresh-install script worden overschreven.

**Acceptatie:** diff exact twee inhoudelijke correcties, originele publieke SPEC/API en alle andere bronblobs identiek; lege geautoriseerde Oracle 19c-installatie zonder onverwachte fouten/warnings; juiste tables/constraints/sequence/indexen; PK- en uniqueness-negatieve tests; regressie logging/exception/transaction; privileges; concurrency; herleidbare RU, CON_ID en install-spool; rollbacktest en formele review. Drie-node RAC-validatie blijft vereist voor RAC_READY, niet voor het schrijven van een conceptpatch.

**GO/NO-GO-vraag aan TETOOLS__REGIE:** *Autoriseert de centrale regie één afzonderlijke DDL-only ontwikkelrevisie met precies RAC-A-010 en RAC-A-011, uitsluitend voor gecontroleerde bouw en test, zonder Oracle-uitvoering, productie-installatie, releasevrijgave of RAC_READY op grond van deze opdracht?*

**Advies:** **CONDITIONAL GO voor codewijziging na expliciete toestemming**, mits DBA/testomgeving, installatieharnas en rollback-eigenaar zijn toegewezen. **NO-GO** voor installatie/release/RAC_READY zonder aparte toestemming en bewijs.

## Resterende afhankelijkheden

ADMIN_LOGGER__REGIE: alle RAC-A-001..012 en LOG-OPEN-01..05 blijven OPEN voor verdere technische behandeling. DBA: RU, grants, container, drie-node testtoegang, SQL harness, back-up. TETOOLS__REGIE: expliciet pilotbesluit en centrale disposition van bestaand suite-signaal. Rapporten B/C en modulecodewijzigingen NIET geautoriseerd.

**Bronnen:** [beleid](../../../../COMMUNICATION_RELAY/policy/TETOOLS_DEVELOPMENT_STANDARD.md), [readiness review](../../../../COMMUNICATION_RELAY/reviews/ADMIN_LOGGER_DEVELOPMENT_READINESS_20261109.md), [handoff](../../../../COMMUNICATION_RELAY/reviews/ADMIN_LOGGER_READINESS_HANDOFF_20261109.md), [Issue #47](https://github.com/JPouwiel/TETOOLS/issues/47), [RAC report A](20261105__PLSQL__TETOOLS_ADMIN_LOGGER__RAC_analyse_A_20261015_500_STE_033.html).
