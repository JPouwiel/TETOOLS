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


## Stap-4-correctiepublicatie — 9 november 2026, review nog vereist

Uitvoering namens bestaande ADMIN_LOGGER-REGIE-20261104-01 door expliciet gemachtigde Codex-sessie a9edd3a9-d49a-4cb8-a102-868f3808e7bf; geen nieuwe sessie-ID. Ontvangst: Issue #104 comment6752079844. De vroegere reviewer is nu implementer; de herreview moet door een andere onafhankelijke sessie gebeuren. Historische FAIL en review/evidence blijven ongewijzigd.

Codecommit `61c476eb4e33ed2c7a1e1e1542e5f3954a2e2ff6`: [correctiematrix](tests/step4_20261109_001/correction_matrix.md) / [statisch bewijs](tests/step4_20261109_001/static_evidence.json). Zeven bevindingen CORRECTED_PENDING_REVIEW; LGR4-04/05/10/11 behouden BLOCKED restscope voor echte incident-PK-fixture, volledige regressie/onderhoud/027/functionele verduidelijking, veilige injectie/benchmark/herstel en feitelijke principals/grants/maintenance. Module/DBA/centrale eigenaren staan per punt in de matrix.41 broncontroles en9 negatieve broncontroles PASS op code-head; geen Oracle-parser of runtime. Alle39 payloadbestanden exact van GitHub teruggelezen. Alle database-uitvoeringen NOT_EXECUTED; G01-G08 open, G09 NOT_GRANTED. Gedeelde gate weigert uitvoering ongeacht private YES/achtergebleven waarden.

Uitsluitend PR102-branch-publicatie: PR niet gemerged, main-teruglezing van correcties PENDING. Vraag volledige-head-herreview aan en laat TETOOLS__REGIE de mergegate beoordelen; geen eigen merge/Oracle/releasevrijgave. Bestaand LOGGER-RAC-20261105-001/Issue55 hergebruikt; geen nieuw architectuurbesluit. Relay-baseline ASSESSED-afwijking ongewijzigd; aanvullende JSON Schema NOT_EXECUTED bij ontbrekend jsonschema, geen groene totaalgate. De afgebakende codevoorbereiding is overgedragen; module-regiesessie blijft ACTIVE/KEEP met expliciete afhankelijkheden en current_activity null. Issue #104 blijft open.


## Second-herreview correction - 10 November 2026

Independent PR108 FAIL on `613f294cba8242c8fa1ff288b5d86653e52f4830` and central receipt6762869095 retained. Delegated existing Codex executor01a1c472-55b9-7281-882f-53425c5c8937 received in Issue104 comment6763336114; codecommit `d2f42960c259d5a4801511b7fd26b8c50dff6665` corrects RR01 (typed parent pairs + SUBOBJECT_NAME IS NULL) and RR02 (2positive suites/6mutation rejections/1analytical prefixcheck). CORRECTED_PENDING_INDEPENDENT_REVIEW, not accepted/CLOSED. 42 checker controls and9+8 offline unittest methods PASS at exact codecommit; no Oracle/client/runtime evidence.

LGR4-04/05/10/11 remain BLOCKED. [Dependency matrix](tests/step4_20261109_001/blocked_dependencies.md) lists owners, required decisions/evidence, technical dependencies and blockers; [finding-to-commit matrix](tests/step4_20261109_001/correction_matrix.md) links current changes. Existing ADMIN_LOGGER-REGIE-20261104-01 + DBA/security retain technical work; central regie holds mergegate. C02-C06 BLOCKED, G01-G08 open, G09 NOT_GRANTED. New independent full-head review required. No PR102/108 merge or main-registration claim; Issue104 OPEN, KEEP. LOGGER-RAC-20261105-001 / Issue55 and historical reviews unchanged. Record LOGGER-STEP4-RR-CORRECTION-20261110-001.
