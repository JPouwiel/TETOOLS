# ADMIN_LOGGER — LDR-03/04/05: test-, API- en omgevingsplan

Status DESIGN_ONLY. Alle Oracle-tests NOT_EXECUTED; RAC-readiness NOT_DEMONSTRATED. [Canonieke beleidsstandaard](../../../../COMMUNICATION_RELAY/policy/TETOOLS_DEVELOPMENT_STANDARD.md): besluiten 4, 13–15, 23, 24, 26–30 en interpretatie F03. Bronversie 20261015_500. Acht testcategorieën verplicht beoordeeld; risicogestuurde diepgang.

| Categorie | Diepgang | Toetsbare gevallen | Vereist bewijs/status |
|---|---|---|---|
| 1 Statische analyse | Hoog | Exact twee DDL-diffs, PKS/PKB/API/blob ongewijzigd, dependencyvolgorde en SQL slash-terminators | Diffreview; concept PASS for defect identification, actual patch NOT_EXECUTED |
| 2 Installatie en compilatie | Hoog | Leeg geautoriseerd Oracle 19c schema; fail-fast SQL, sequence/tables/indexes/spec/body; USER_ERRORS, warnings, USER_OBJECTS, USER_CONSTRAINTS, USER_INDEXES | SQL spool met nul onverwachte fouten; NOT_EXECUTED |
| 3 Functioneel | Middel | Incident insert/PK-conflict, logbatch-positie uniek, guard, log/config, help/version | Testdata, expected/actual; NOT_EXECUTED |
| 4 Regressie | Hoog | Alle LOG_* en FORCE overloads, toggles, session_details_revert, clear_*; signatures/defaults en error/output | Vergelijk met gepinde baseline; NOT_EXECUTED |
| 5 Beveiliging/transacties | Hoog | Definer-rights direct grants, onderhoudsrechten, autonomous commit/rollback, exception fallback | Privilegematrix en rollback traces; NOT_EXECUTED |
| 6 Performance/concurrency | Risicogestuurd middel | Gelijktijdige batch inserts, guard lock WAIT 5, uniqueness race; p50/p95, redo/waits | Metingen vóór/na, geen ongewenste regressie; NOT_EXECUTED |
| 7 RAC | Hoog voor RAC-release; beperkte voorlopige pilot | Drie nodes: local/remote session purge, INST_ID/CON_ID, index uniqueness, reconnect/failover, service routing | Per-node testlogs; NOT_EXECUTED; niet N/A voor RAC_READY |
| 8 Bewijs/acceptatie | Hoog | RU, hashes, scripts, SQL spools, test-ID's, reviewers, DBA, rollback en centrale autorisatie | Complete audittrail; NOT_EXECUTED |

Een DDL-only codepilot mag vóór volledige RAC-validatie worden ontworpen, maar niet als RAC_READY worden geaccepteerd. Geen categorie is stilzwijgend N/A; volledige failover blijft een **uitgestelde releasevoorwaarde** en geen vrijstelling.

## Besluit 23 / F03 — zes contractacceptaties

1. **Aanroepertransactie intact:** schrijf business-row, roep LOG_* aan, ROLLBACK business; business-row verdwijnt terwijl toegestane autonome log/diagnostiek blijft.
2. **Atomair beheer:** injecteer fout tussen sessie- en configuratiewijziging; geen gedeeltelijke commit, guard correct vrijgegeven.
3. **Duurzame diagnostiek:** beheerrollback gevolgd door zelfstandig bewaarde incident/exception-informatie; indien fallback zelf faalt, begrensde afhandeling.
4. **Foutclassificatie:** onderscheid incidentele registratieproblemen, sessiebrede fouten en diagnostische fallback; assert aanroeper- en gebruikersmelding.
5. **API-specifiek gedrag:** LOG_RUNTIME best-effort bij incidentele registratieproblemen maar mag bij sessiebrede fout onderbreken; LOG_INFO/LOG_WARNING interne foutafhandeling; LOG_ERROR/LOG_DEBUG/LOG_*_FORCE verplichte gebruiker- én applicatieterugmelding. Test zowel procedure- als function-overloads. Huidige conformiteit UNVERIFIED.
6. **Geen recursieve fallback:** simuleer storing in logging en diagnostische API; geen eindeloze logging-recursie, stackgroei of stilzwijgend verlies van kritieke fout.

Bron: SPEC regels 376–491, BODY 514–1446. Behoud publieke `session_details_revert` (SPEC 432, BODY 946–1011) en expliciete caller-visible defaults. Geen API-wijziging geautoriseerd.

## Omgevings- en DBA-afhankelijkheden

| Gegeven | Status | Eigenaar / bewijs |
|---|---|---|
| Exacte Oracle 19c RU, SQL patch inventory | UNVERIFIED | DBA: V$VERSION, DBA_REGISTRY_SQLPATCH |
| Schema TETOOLS, PDB/CDB en CON_ID | UNVERIFIED | DBA: SYS_CONTEXT(USERENV, CON_ID), container metadata |
| Drie RAC-nodes, services, connectiepool, replay | UNVERIFIED | DBA/app: GV$INSTANCE/GV$SESSION, service/driverconfig |
| Directe grants, AUTHID DEFINER en SYS.V_$SESSION | UNVERIFIED | DBA: DBA_TAB_PRIVS + compile onder TETOOLS |
| DBA-/onderhoudsrechten versus normale EXECUTE | UNVERIFIED | DBA/security: effectieve grants en negatieve autorisatietest |
| Representatieve geïsoleerde RAC-testomgeving | UNVERIFIED | DBA: drie-node toegang, testdata, monitorrechten |
| Bestaande objecten/data, duplicate index keys | UNVERIFIED | DBA: USER_OBJECTS, USER_INDEXES, data-integriteitsquery |
| Rollback snapshot en DDL-herstelprocedure | UNVERIFIED | DBA: herstelproef en backupbewijs |
| Werkelijke API-consumers en releasevolgorde | UNVERIFIED | TETOOLS__REGIE/module-regies: compatibiliteitsmanifest |

**RAC:** remote sessie-opruiming (RAC-A-001), identity provenance (002), maintenance privileges (012) en failover (008) zijn niet opgelost door de DDL-pilot. Het bestaande suite-impactsignaal `LOGGER-RAC-20261105-001` blijft de centrale referentie; geen duplicaat. Performance is niet gemeten. Oracle compile/install/runtime/load/failover NOT_EXECUTED.
