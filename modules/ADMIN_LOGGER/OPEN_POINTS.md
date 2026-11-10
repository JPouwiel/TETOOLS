# Open work

| ID | Open point | Evidence / next action |
|---|---|---|
| LOG-OPEN-01 | Review uploaded source 20261015_500 | Static RAC report A now reviews the unchanged baseline (Issue #47; RAC-A-001..012). Broader source bug/dead-code/optimization review remains open; report A is not Oracle validation. |
| LOG-OPEN-02 | Oracle verification | Confirm target 19c release update, container, direct privileges, compilation and functional test results. No new Oracle run took place during import. |
| LOG-OPEN-03 | Installation reference 003 | Review report 030 and correct the installer through an agreed code change. Do not enable its commented DDL without resolving template and privilege defects. |
| LOG-OPEN-04 | Proposals versus uploaded source | Compare proposal 027 against 20261015_500 before accepting any change. Preserve external backup/restore behavior. |
| LOG-OPEN-05 | Suite dependency and release map | Determine actual ADMIN_LOGGER public consumers, required versions and per-module installation/test order. Shared Git storage does not decide these automatically. |

No open point is silently closed by importing files into Git.

## KT-03 relay-test (2026-11-04)

`LOGGER-KT03-20261104-001` is een **uitsluitend hypothetische testsignalering**, status PROPOSED. Er is geen defect vastgesteld. De mogelijke invloed van RAC instance-context op sessiecorrelatie is slechts een testsituatie. Dit is geen inhoudelijk open moduledefect en geen goedgekeurd architectuurbesluit. Bron: ADMIN_LOGGER__REGIE, gebruiker gaf afzonderlijk toestemming voor KT-03 op 2026-11-04.

## RELAY activity tracking — central review pending (2026-11-04)

- **Signal ID:** `LOGGER-RELAY-ACTIVITY-20261104-001` in `COMMUNICATION_RELAY/CHANGE_REGISTER.json` (`SUITE_IMPACT_SIGNAL`, `PROPOSED`).
- **Origin:** `ADMIN_LOGGER-REGIE-20261104-01`; user request for one shared session activity view, not separate RAC dashboards.
- **Central decision required:** meaning, lifecycle and schema of `current_activity` for all registered sessions. No suite-wide session registry or field semantics changed by this signal.
- **Handoff:** governed by `COMMUNICATION_RELAY/MANUAL_HANDOFF.md`; central review requested from `TETOOLS__REGIE`.

## RAC report A findings (2026-11-05)

Source: [report A](docs/reports/20261105__PLSQL__TETOOLS_ADMIN_LOGGER__RAC_analyse_A_20261015_500_STE_033.html); [Issue #47](https://github.com/JPouwiel/TETOOLS/issues/47). Current source and frozen releases are unchanged. Owner for remaining technical work: ADMIN_LOGGER-REGIE-20261104-01; receipt must be confirmed in Issue #47. No automatic ownership acknowledgement is claimed.

| Finding | Next action / owner |
|---|---|
| RAC-A-001 | Module regie: visibility-aware RAC liveness/purge contract; test live remote sessions before acceptance. |
| RAC-A-002, 003 | Module regie + DBA: physical identity, container scope, minimum grants and actual visibility evidence. |
| RAC-A-004 to 007 | Module regie + DBA: cooperative lock contract and matched-load measurements; no measured gain claimed. |
| RAC-A-008, 009 | Module regie: reconnect/replay, backup and time/retention policy; mode-specific tests. |
| RAC-A-010, 011 | Module regie: later authorized correction of current object-script DDL order/separator; clean install validation. |
| RAC-A-012 | Module regie: separate maintenance authorization expectation from normal logger consumption. |

Suite signal LOGGER-RAC-20261105-001 concerns actual source observations and conditional risks, not the earlier hypothetical KT-03 test. TETOOLS__REGIE must assess cross-module standards; no disposition is approved here.

Historical activity-review paragraph above records the 2026-11-04 state. It is superseded by REGIE-ACTIVITY-20261105-002 / PR #28; Issue #47 is the current task reference. KT-03 permission was separately verified in LOGGER-KT03-20261104-001; it remains hypothetical, not a real defect.


## Onafhankelijke stap-4-testreview — 9 november 2026

[Rapport](docs/reports/ADMIN_LOGGER_STEP4_INDEPENDENT_REVIEW_20261109.md) en [statisch bewijs](docs/reports/ADMIN_LOGGER_STEP4_REVIEW_20261109_EVIDENCE.json); [Issue #104](https://github.com/JPouwiel/TETOOLS/issues/104), reviewrecord `LOGGER-STEP4-REVIEW-20261109-001` in CHANGE_REGISTER. Volledige PR102-head `5c25e83604d8bb0eeb2680a372b3e1b808c320c5`: **FAIL**, twee P1's LGR4-01/02 (standalone safety-gate bypass; lege approval/doelwaarden passeren door NULL-semantiek) en negen P2's LGR4-03..11. PR #102 niet mergegereed. Zes bronhashes matchen main; baseline/frozen releases ongewijzigd. Alle databasecases NOT_EXECUTED; C01 gedeeltelijk, C02–C06 BLOCKED; RAC NOT_DEMONSTRATED. Geen tests of productiebron door reviewer gewijzigd.

**Opvolger:** bestaande ADMIN_LOGGER-REGIE-20261104-01 bevestigt ontvangst in Issue #104 en verwerkt finding-to-commit-correcties op eigen PR102-branch; daarna onafhankelijke volledige-head-herreview. TETOOLS__REGIE beoordeelt mergegate. DBA/module G01–G08, G09 afzonderlijk NOT_GRANTED. Bestaand suitesignaal LOGGER-RAC-20261105-001 blijft de referentie; geen nieuw architectuurbesluit of duplicaatsignaal. Ontvangst/handover nog PENDING; Issue #104 open en sessie COMPLETED/KEEP, geen CLOSED-claim.

## Onafhankelijke volledige-head-herreview — 10 november 2026 (voorstel PR108)

[Rapport](docs/reports/ADMIN_LOGGER_STEP4_REREVIEW_20261110.md) / [bewijs](docs/reports/ADMIN_LOGGER_STEP4_REREVIEW_20261110_EVIDENCE.json), reviewer d58c7999-a8ba-4534-ab08-1c8c87181b64, werkelijke thread 01a19fe0-7428-7763-8c6c-bb8b9c26abc3; [ontvangst Issue104](https://github.com/JPouwiel/TETOOLS/issues/104#issuecomment-6762273739). Exacte volledige PR102-head 613f294cba8242c8fa1ff288b5d86653e52f4830: **FAIL**. LGR4-01/02/06/07/08/09 statisch ondersteund voor de huidige voorbereiding, geen runtimeacceptatie. LGR4-03 niet aanvaard: nieuwe **P2 LGR4-RR-01** in scripts/00_post_install.sql:7-10 telt ALL_OBJECTS op naam zonder type/subobjectfilter, terwijl gepinde bron drie gepartitioneerde tabellen bevat. Module-regie corrigeert exact top-level naam/typecontract; DBA levert later geautoriseerd Oraclebewijs. **P3 LGR4-RR-02:** beschrijf negen source-unittestmethoden correct; geen negen Oracle-negatieve uitvoeringen.

LGR4-04/05/10/11, C02-C06 en G01-G08 blijven geblokkeerd/onbewezen volgens rapport; G09 NOT_GRANTED. Historische FAIL blijft; LOGGER-RAC-20261105-001/Issue55 behouden. Restwerk en ontvangst bij bestaande ADMIN_LOGGER-REGIE-20261104-01 + DBA/security; centrale TETOOLS__REGIE houdt mergegate. Geen codewijziging, merge, Oracleverbinding of uitvoering. Eigen rapport/relay uitsluitend documentatiebranch PR108; main-publicatie PENDING. Issue104 OPEN, reviewer COMPLETED/KEEP voorgesteld, geen CLOSED.
