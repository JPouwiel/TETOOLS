# TETOOLS suite architecture — central REGIE

Project: PLSQL_TETOOLS. Baseline: Oracle Database 19c Enterprise. Date: 2026-11-03.

## Approved governance — REGIE-20261103-001

- TETOOLS__REGIE is the central architecture and governance conversation for all ADMIN_* modules.
- Each module maintains a module-specific REGIE conversation for design, bugs and implementation decisions.
- Suite-wide architecture decisions form the default baseline for modules.
- Module-specific deviations are permitted where a suite-wide decision demonstrably harms module functionality, performance or other material requirements. Record the rationale, impact, alternatives, approval and source in that module's registers, with cross-reference to the central decision.
- Work/Codex implements only explicitly agreed scope. COMMUNICATION_RELAY is the durable audit trail, not automatic chat synchronization.

Source: user's explicit instruction in TETOOLS__REGIE conversation on 2026-11-03; exact thread ID unavailable. Recorded by locally generated session UUID 67c27cf6-aa30-4b97-b4e2-753c195f277c.

## Architecture baseline / review — REGIE-20261103-002

The project start protocol records Oracle Database 19c Enterprise and a target of three RAC nodes. This is a design constraint, **not runtime validation**. Investigate before technical approval:

- RAC-ARCH-01: instance/session identity, instance-specific and global views, concurrent sessions and logging correlation.
- RAC-ARCH-02: CDB/PDB and CON_ID context, data dictionary availability and least-privilege grants.
- RAC-ARCH-03: locking/concurrency, deployment consistency across nodes, and reproducible Oracle 19c tests.

Status: OPEN / NOT_EXECUTED. PM-001 SEARCH_CONDITION_VC originates in ADMIN_OBJECTS__REGIE and is also escalated for suite-wide impact assessment; no suite-wide fix is yet approved.

## Evidence and governance

- Canonical current state: CURRENT_STATUS.md; module locations: MODULE_REGISTRY.md.
- Lifecycle, change records and verification: RELAY_CONTRACT.md, SESSION_REGISTRY.json, CHANGE_REGISTER.json.
- No modifications to frozen module releases in this change.

## Cross-module findings — REGIE-20261103-003 (approved governance)

Module-regie identifies, investigates and proposes technical measures. TETOOLS__REGIE evaluates possible cross-module effects and decides whether a shared standard or solution is appropriate. Potential impact is sufficient to raise a signal; confirmed impact is not required. Register signals in CHANGE_REGISTER.json as SUITE_IMPACT_SIGNAL, with origin, evidence, uncertainty, affected modules and status. Central regie reviews open signals and records a disposition. Module deviations from central decisions remain possible with documented justification.

### Initial signal: PM-001 / SEARCH_CONDITION_VC — REGIE-20261103-004

Origin: ADMIN_OBJECTS__REGIE. Potential relevance: Oracle 19c data dictionary metadata extraction, datatype limits and normalization patterns used by other ADMIN_* modules. This is a hypothesis requiring assessment, **not** a confirmed cross-module defect. Source: user's clarification in TETOOLS__REGIE conversation, 2026-11-03 (exact thread ID unavailable). Status: PROPOSED / assessment OPEN. Technical investigation stays with ADMIN_OBJECTS__REGIE; suite-wide assessment belongs to TETOOLS__REGIE.

## Current activity - REGIE-ACTIVITY-20261105-001 / -002

Minimale suitebrede relayregel gepubliceerd en op main geverifieerd via PR #28, merge
4114710b228fe8f23eeb190c35d01266d21fd2e8. Normatieve definitie: RELAY_CONTRACT.md;
gebruik: CURRENT_ACTIVITY.md; canonieke besluit-/bewijsrecords: CHANGE_REGISTER.json.
Een optionele handmatig bijgewerkte taak per sessie; afronden wist de taak en behoudt bewijs.
Geen modulearchitectuurwijziging of automatische chataanwezigheid/verwijdering.

## RAC suite-signalen — centrale review 2026-11-06 (Issue #55)

Na lezing van [RAC-statusrapport](reports/RAC_STATUS_20261106.md) en actuele modulebronnen stelt TETOOLS__REGIE voor alle drie signalen de formele onderzoeksdisposition **INVESTIGATE** vast. Dit is uitsluitend goedkeuring van de **beoordelings-/onderzoeksrichting**, niet van ontwerp, implementatie, wijzigingen aan publieke API, datatypes, privileges of bevroren releases. Vervolgrecords zijn append-only in CHANGE_REGISTER.json: REGIE-RAC-DISPOSITION-20261106-001..003. De oorspronkelijke signalen blijven historisch PROPOSED.

| Signaal | Disposition | Afbakening en verantwoordelijke |
|---|---|---|
| LOGGER-RAC-20261105-001 | INVESTIGATE | Gemeenschappelijke sessie/provenance, instance-/containerzichtbaarheid en liveness als mogelijke suite-randvoorwaarden. TETOOLS__REGIE beoordeelt conventies; ADMIN_LOGGER__REGIE houdt RAC-A-001..012/LOG-OPEN-01..05 en modulewijzigingen. |
| SESSIONS-RAC-20261106-001 | INVESTIGATE | Onderzoek volledige fysieke targetidentiteit, selectie/hercontrole en autorisatie bij globale RAC-views. ADMIN_SESSIONS-regie houdt brononderzoek en modulebesluiten. |
| REGIE-20261103-004 | INVESTIGATE (behouden) | Onderzoek welke andere modules daadwerkelijk metadata/constraints uitlezen; ADMIN_OBJECTS__REGIE behoudt OP-13 en mogelijke SEARCH_CONDITION_VC-truncatie. Geen suitebreed defect vastgesteld. |

**Vereist extern bewijs:** exacte Oracle 19c RU, RAC-instances en services, CDB/PDB/CON_ID, gedeelde schema's, directe grants en zichtbaarheid, werkelijke consumers en client/replay-modus. Daarna afzonderlijk goedgekeurde compile-, node-/concurrency-, load- en failovertests. Huidig oordeel: RAC-readiness **NIET AANGETOOND**, alle Oracle-tests NOT_EXECUTED. Zie [Issue #55](https://github.com/JPouwiel/TETOOLS/issues/55).

**Overdrachten:** ADMIN_LOGGER__REGIE bevestigde ontvangst in [Issue #47](https://github.com/JPouwiel/TETOOLS/issues/47#issuecomment-6681208293), via PR #57 teruggelezen. ADMIN_OBJECTS__REGIE-ontvangst [Issue #45](https://github.com/JPouwiel/TETOOLS/issues/45) nog niet bevestigd. Issue-bevestigingen zijn geen runtimebewijs.
