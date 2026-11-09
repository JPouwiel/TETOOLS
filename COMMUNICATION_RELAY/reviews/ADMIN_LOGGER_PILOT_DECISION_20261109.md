# TETOOLS__REGIE — formeel besluit eerste ADMIN_LOGGER-ontwikkelpilot

**Besluit-ID:** REGIE-LOGGER-PILOT-20261109-001  
**Datum:** 2026-11-09  
**Status:** CONDITIONAL_GO — uitsluitend codeontwikkeling  
**Platform:** Oracle Database 19c Enterprise, beoogde drie-node RAC  
**Bron:** expliciet besluitverzoek ADMIN_LOGGER__REGIE in huidige conversatie, oorspronkelijke berichtpermalink UNVERIFIED. Analyse gepubliceerd via PR #92 / merge `fab40c1b8181ca1c738c4ec87a474378ccb98735`.

## Besluit

TETOOLS__REGIE autoriseert **een nieuwe, niet-bevroren ontwikkelrevisie** voor uitsluitend de twee DDL-correcties RAC-A-010 en RAC-A-011. Het betreft **codeontwikkeling en statische review**, niet het uitvoeren van SQL of Oracle-installatie, niet productie, niet releasevrijgave, niet RAC_READY.

## Exacte toegestane scope

- Baseline `modules/ADMIN_LOGGER/src/20261015_500/`, bronboom gepind volgens LDR-readiness. Behoud alle originele bestanden en bevroren releases.
- Maak een nieuwe expliciet herkenbare **niet-bevroren ontwikkelrevisie** op een aparte Git-branch; versienummer volgens bestaande moduleconventie, zonder een bestaande versie te overschrijven.
- Wijzig uitsluitend de nieuwe kopie van `TABLE/TAB_TETOOLS_ADMIN_LOGGER__20261015_202.sql`:
  1. **RAC-A-010:** verplaats de ongewijzigde volledige `CREATE UNIQUE INDEX tetools.admin_logger_position_uk` inclusief clientterminator `/` van vóór de LOG-tabel naar direct ná het LOG-`CREATE TABLE`-statement en zijn terminator. Behoud indexnaam, UNIQUE, CASE-expressies, semantiek.
  2. **RAC-A-011:** voeg precies één komma toe achter `config_snapshot CLOB`, vóór `CONSTRAINT admin_logger_incident_pk`.
- Aanpassingen aan nieuw ontwikkelrevisiemanifest, wijzigingslog en **statische** tests/rapportage zijn toegestaan voor traceerbaarheid; geen extra DDL-semantiekaanpassingen.

## Uitgesloten

Geen wijzigingen aan PKS, PKB, publieke API, sequence, grants, overige indexen/constraints, logging-, transacties-, incident- of RAC-logica; geen hernoeming van bestaande constraints. Geen object- of datamigratie. Geen wijzigingen aan oorspronkelijke bronbaseline, bevroren releases, of overige modules. Geen Oracle-connectie/DDL/uitvoering zonder afzonderlijke opdracht. Geen autonome wijziging van installer buiten de expliciet genoemde DDL-file.

## Voorwaarden voor codeontwikkeling (eigenaar ADMIN_LOGGER__REGIE)

1. Branch vanaf actuele `main`; baselinebestanden en blobs vooraf vastleggen. Nieuwe niet-bevroren revisie, oude bron onveranderd.
2. Wijzigingsdiff beperken tot exact de twee DDL-inhoudscorrecties plus onvermijdelijke versie-/manifestdocumentatie. Controleer CRLF, slash-terminators, DDL-volgorde en behoud van de drie index-CASE-expressies.
3. Bevestig dat PKS/PKB, publieke signatures/defaults, sequences en andere bronblobs ongewijzigd zijn; publiceer machine-/handmatig controleerbaar diff- en hashbewijs.
4. Vier-ogenreview met onafhankelijke reviewer; leg eventuele reviewafwijkingen vast en vraag vooraf centrale toestemming voor scope-uitbreiding.
5. Maak afzonderlijk uitvoerbaar Oracle 19c-testplan, fail-fast installatiescript/testharnas, rollback- en herstelplan **zonder deze uit te voeren**; identificeer test-/DBA-eigenaren.
6. PR ter review; merge uitsluitend volgens relay-/repositorycontract en zonder impliciete releaseacceptatie. Publiceer main-readback, commit, afwijkingen en open afhankelijkheden.

## Verplichte test- en acceptatiecriteria

**Voor code-review/ontwikkelafronding:** acht testcategorieën expliciet beoordeeld; statische analyse en diff/hashcontroles uitgevoerd; installatiescript/terminators gecontroleerd; testcases en verwacht resultaat gespecificeerd; code-review PASS. Dit is **geen Oracle-acceptatie**.

**Voor afzonderlijk te autoriseren Oracle-testfase:** (1) schone geïsoleerde Oracle 19c-installatie met fail-fast SQL en nul onverwachte fouten; (2) objecten, indexes, constraints, sequence en PKS/PKB compileren, USER_ERRORS/USER_OBJECTS/USER_INDEXES/USER_CONSTRAINTS gecontroleerd; (3) negatieve PK/unique-tests en functionele incident/logbatch-tests; (4) regressie publieke API/overloads inclusief besluit 23/F03 exceptionsemantiek en session_details_revert; (5) grants, least privilege, autonomous transaction en rollback; (6) risicogestuurde performance/concurrency; (7) relevante RAC-scenario's apart, volledige drie-node RAC-tests verplicht vóór RAC_READY; (8) audittrail met RU, CON_ID, instantiereferenties, scripts, logs, reviewers, herstelproef en expliciete acceptatie.

## Risico, DBA en rollback

- DDL in Oracle heeft impliciete commit; gewone `ROLLBACK` herstelt DDL niet. Geen test tegen bestaande schema's zonder migratie- en back-upplan.
- DBA/testeigenaar (nog **UNASSIGNED**): exacte RU, PDB/CDB/CON_ID, schema/direct grants, testomgeving, back-up/snapshot en herstelproef. **Dit blokkeert Oracle-testautorisatie, niet het opstellen van een codepatch.**
- ADMIN_LOGGER__REGIE: bronbaseline, diff, code-review, testharnas, risico's en ontwerprollback.
- TETOOLS__REGIE: scopebewaking, suite-impact, afzonderlijke go/no-go voor Oracle-testfase en latere release.
- Bestaand suite-signaal `LOGGER-RAC-20261105-001` blijft INVESTIGATE; geen duplicaat of nieuw suitearchitectuurbesluit voor deze twee DDL-only correcties nodig. Overige RAC-A-/LOG-OPEN-punten blijven OPEN.

## Terugmelding

ADMIN_LOGGER__REGIE bevestigt ontvangst in bestaand Issue #47, registreert activiteit, levert diff/hashbewijs, review en niet-uitgevoerde testplannen, PR/merge/main-readback en expliciete vraag om **afzonderlijke** autorisatie voor de Oracle-testfase. Koppel centrale overdracht aan bestaand Issue #55 zonder duplicate issue of signal. Geen wijziging aan bevroren release.

## Bronnen

- `modules/ADMIN_LOGGER/docs/reports/ADMIN_LOGGER_LDR_READINESS_20261109.md`
- `modules/ADMIN_LOGGER/docs/reports/ADMIN_LOGGER_LDR_TRACE_20261109.md`
- `modules/ADMIN_LOGGER/docs/reports/ADMIN_LOGGER_LDR_DDL_20261109.md`
- `modules/ADMIN_LOGGER/docs/reports/ADMIN_LOGGER_LDR_TESTPLAN_20261109.md`
- `COMMUNICATION_RELAY/policy/TETOOLS_DEVELOPMENT_STANDARD.md`
- `COMMUNICATION_RELAY/RELAY_CONTRACT.md`, `MANUAL_HANDOFF.md`; Issues #47/#55; PR #92.
