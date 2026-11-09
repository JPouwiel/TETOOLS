# ADMIN_LOGGER — stap 4 Oracle-testvoorbereiding

**Dossier-ID:** REGIE-LOGGER-TESTPREP-20261109-001  
**Eigenaar governance:** TETOOLS__REGIE; **technische eigenaar:** ADMIN_LOGGER__REGIE; **omgeving/herstel:** aan te wijzen DBA.  
**Status:** PREPARATION_DOSSIER_COMPLETE / ENVIRONMENT_UNVERIFIED / EXECUTION_NO_GO.  
**Scope:** Oracle Database 19c Enterprise, beoogd 3-node RAC; niet-bevroren DEV-revisie `20261109_501_DEV`. Geen uitvoering, installatie, release of RAC_READY.

## 1. Bron en reeds geleverd bewijs

- PR #97 gemerged `81eadafaf575accadddd18e173d4f733359ea4b7`; onafhankelijke statische review PR #98 PASS; administratieve PR #100 gemerged `55e01d0025f7d294e5afc68ffe9694251459e4a3`.
- De vijf bronblobs en het revisiemanifest zijn op main gecontroleerd; baseline `20261015_500` blijft behouden.
- Bestaand technisch testontwerp: `modules/ADMIN_LOGGER/docs/reports/ADMIN_LOGGER_LDR_TESTPLAN_20261109.md`; dit dossier is een **centrale voorbereiding**, geen vervangend testplan.
- Open: LOG-OPEN-01..05, RAC-A-001..012, suite-signaal `LOGGER-RAC-20261105-001`. DDL-correcties RAC-A-010/011 zijn **source-fixed**, niet Oracle-validated.

## 2. Uitvoeringspoort — bewijs vereist vóór afzonderlijk GO-besluit

| ID | Gate | Bewijs / acceptatie | Eigenaar | Huidige status |
|---|---|---|---|---|
| G01 | Exacte omgeving | Oracle 19c EE versie en RU/SQL patches; DB_UNIQUE_NAME, PDB, CON_ID, testisolatie, instance- en servicekaart | DBA | UNVERIFIED |
| G02 | Testschema en bestaande objecten | Geautoriseerde lege disposable TETOOLS-testschema/PDB, objectinventaris, data-isolatie, geen productiedata | DBA + module | UNVERIFIED |
| G03 | Directe rechten | Direct grants op benodigde SYS.V_$* / DBA views en packages; AUTHID/EXECUTE-rollen, least privilege, onderhoud apart | DBA/security | UNVERIFIED |
| G04 | Installatievolgorde | Version-pinned scripts, SQL client fail-fast/WHENEVER SQLERROR EXIT, tables/constraints, indexes, sequence, PKS/PKB, voorbeeldprocedure alleen indien geautoriseerd | Module + DBA | DESIGN_ONLY |
| G05 | Testdata en determinisme | Per test-ID setup/cleanup, unique keys, logging settings, drie RAC-sessies en herhaalbaarheid | Module | DESIGN_ONLY |
| G06 | Herstelplan | DBA-goedgekeurde snapshot/backup en restore-test of disposable-schema teardown; eigenaar, stopcriteria, herstel-RTO, DDL implicit commit | DBA | UNVERIFIED |
| G07 | Observability | SQL spools, USER_ERRORS/OBJECTS/INDEXES/CONSTRAINTS, GV$SESSION/INSTANCE, CON_ID, timestamps, waits, redo, error/backtrace | DBA + module | UNVERIFIED |
| G08 | API/consumer-impact | Publieke SPEC/defaults, moduleconsumers, backup/restore en privileges; regressiecontract vastgelegd | Module + centrale regie | UNVERIFIED |
| G09 | Formele toestemming | Apart expliciet centraal besluit met omgeving, toegestane DDL, testset, DBA, acceptatie, herstel, tijdvenster en stopcriteria | TETOOLS__REGIE | NOT_GRANTED |

**NO-GO indien een gate onopgelost is en voor de beoogde tests vereist is.** Een beperkte niet-RAC proef mag alleen na afzonderlijk expliciet afgebakend GO; niet impliciet uit deze voorbereiding.

## 3. Testmatrix — acht categorieën en bewijs

| ID | Categorie | Voorgestelde minimumacceptatie | Artefact |
|---|---|---|---|
| T01 | Statisch | Exact twee geautoriseerde DDL-fixes; vijf bronhashes en manifest gelijk aan main | Diff, hashes, reviewer PASS — reeds beschikbaar |
| T02 | Installatie/compilatie | Schone installatie zonder onverwachte SQL-/compilefouten; index bestaat na tabel; incident-PK geldig | Fail-fast spool, USER_ERRORS, USER_OBJECTS, USER_INDEXES, USER_CONSTRAINTS |
| T03 | Functioneel | Logbatchpositie-uniciteit en incident PK-negatief geval; logging/config/guard en help/version positief | Test-ID, setup, expected/actual, cleanup |
| T04 | Regressie/API | Publieke SPEC/defaults ongewijzigd; LOG_* procedure/function-overloads, FORCE, toggles, session_details_revert, clear_* | API-matrix en baselinevergelijking |
| T05 | Security/transacties | Direct grants; definer-rights; onderhoudsrechten apart; zes F03/decision23 contractacceptaties | Privilegematrix, commit/rollback- en fouttraces |
| T06 | Performance/concurrency | Guard lock WAIT 5, parallel batches, uniqueness races; p50/p95 en waits/redo zonder onverklaarde regressie | Meetplan, sessielogs, statistische baseline |
| T07 | RAC | Alle drie instances: remote liveness/purge, INST_ID/CON_ID, failover/reconnect, service routing, uniqueness | Per-node bewijs; verplicht vóór RAC_READY |
| T08 | Audit/acceptatie | RU, objecthashes, logs, DBA sign-off, reviewer, incidenten, rollbackproef, GO/NO-GO | Reproduceerbaar evidence bundle |

Alle T02–T08 zijn **NOT_EXECUTED**. T01 is statisch PASS, niet een Oracle-test.

## 4. Zes verplichte transactie-/exceptioncontracten (besluit 23 / F03)

- C01: business-rollback laat business-row verdwijnen, maar toegestane autonome diagnostiek blijft bestaan.
- C02: fout tussen sessie/config-mutaties leidt niet tot gedeeltelijk gecommitteerde beheerstatus; guard wordt vrijgegeven.
- C03: diagnostische informatie blijft behouden na beheerrollback; begrensde fallback bij eigen fout.
- C04: classificatie van incidentele registratie-, sessiebrede en fallbackfouten is observeerbaar.
- C05: LOG_RUNTIME best-effort voor incidentele registratieproblemen; LOG_INFO/WARNING interne foutafhandeling; LOG_ERROR/DEBUG/FORCE met vereiste feedback, inclusief functie-/procedureoverloads.
- C06: geen recursieve foutlogging bij uitval van logging en diagnostiek.

**Geen huidige conformiteit veronderstellen.** Testuitkomsten kunnen aanleiding geven tot nieuwe codebesluiten, niet tot automatische scope-uitbreiding.

## 5. Risico's en herstel

1. Oracle DDL heeft impliciete commits; gewone ROLLBACK herstelt geen CREATE/DROP-objecten. Gebruik alleen goedgekeurde geïsoleerde omgeving en herstelprocedure.
2. Een bestaand schema mag niet worden overschreven met fresh-install scripts. Geen DROP, PURGE, TRUNCATE of DDL zonder expliciet GO.
3. RAC-A-001/002/008/012 en LOG-OPEN-05 blijven buiten de twee broncorrecties; testvoorbereiding mag geen RAC_READY claimen.
4. SQL-client, direct grants, versie/RU en PDB/CON_ID moeten worden vastgelegd vóór testontwerp wordt bevroren.
5. Stopcriteria bij onverwachte DDL-fout, privilege-escalatie, schade buiten testschema, ontbrekende observability of niet-uitvoerbare recovery.

## 6. Werkverdeling en volgende oplevering

- **ADMIN_LOGGER__REGIE:** lever een uitvoerbaar maar **niet-uitgevoerd** testpakket met scripts/testcases per T01–T08 en C01–C06, expected/actual-formulieren, install-/cleanup-volgorde, privilegevraag en technische risicoanalyse; laat het via eigen branch/PR reviewen.
- **DBA/testeigenaar:** lever ondertekende omgeving- en grantsmatrix, instance/service/RU/CON_ID-bewijs, herstelplan, rollbackproefplanning en testvenster. Als DBA niet beschikbaar is: BLOCKED/UNVERIFIED.
- **TETOOLS__REGIE:** controleer testplan, moduleafhankelijkheden en suite-impact; neem pas na bewijs een afzonderlijk Oracle-uitvoeringsbesluit. Bestaand signaal `LOGGER-RAC-20261105-001` hergebruiken; geen duplicaat.
- **Gebruiker/repositorybeheerder:** bepaal wie als DBA/testeigenaar kan optreden en welke niet-productieomgeving beschikbaar is.

**Eindstatus stap 4:** centraal voorbereidingskader opgesteld; technische/DBA-readiness nog **PENDING**. Dit document is geen testautorisatie.

## Bronnen

- https://github.com/JPouwiel/TETOOLS/pull/97
- https://github.com/JPouwiel/TETOOLS/pull/98
- https://github.com/JPouwiel/TETOOLS/pull/100
- https://github.com/JPouwiel/TETOOLS/issues/55
- `modules/ADMIN_LOGGER/docs/reports/ADMIN_LOGGER_LDR_TESTPLAN_20261109.md`
- `COMMUNICATION_RELAY/policy/TETOOLS_DEVELOPMENT_STANDARD.md`
- `COMMUNICATION_RELAY/RELAY_CONTRACT.md`
