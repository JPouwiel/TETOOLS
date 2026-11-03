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

Status: OPEN / NOT_EXECUTED. Module-specific PM-001 SEARCH_CONDITION_VC issue remains with ADMIN_OBJECTS__REGIE, not a suite-wide fix.

## Evidence and governance

- Canonical current state: CURRENT_STATUS.md; module locations: MODULE_REGISTRY.md.
- Lifecycle, change records and verification: RELAY_CONTRACT.md, SESSION_REGISTRY.json, CHANGE_REGISTER.json.
- No modifications to frozen module releases in this change.
