# Open points

All OPEN, recorded 2026-11-03. No missing proof is treated as success.

- **AS-OPEN-01**: Resolve AS-01/02 and record actual Oracle compile diagnostics.
- **AS-OPEN-02**: Agree provider privileges, caller permission matrix and protected-target rules.
- **AS-OPEN-03**: Agree local/RAC/container scope and migrate complete target identity.
- **AS-OPEN-04**: Repair states, atomic claims, concurrency, crash recovery and caller transaction ownership.
- **AS-OPEN-05**: Repair configuration seed, scheduler names/order and installation/cleanup contract.
- **AS-OPEN-06**: Certify C01 against the actual logger release 20261015_500 or an explicitly selected successor.
- **AS-OPEN-07**: Run isolated Oracle, runtime, RAC, concurrency, recovery and performance tests; all currently NOT_EXECUTED.
- **AS-OPEN-08**: Obtain installed source version, provider environment and any missing historical revisions; no complete history claim.
- **AS-OPEN-09**: Original input archive unavailable on publication day; only retained extraction and historical archive checksum available.
- **AS-OPEN-10**: PR review and post-merge verification pending; do not merge automatically.

Keep this session: KEEP; not CLOSED, ARCHIVED or eligible for deletion.

## Suite-impactmelding — 2026-11-06

`SESSIONS-RAC-20261106-001` (PROPOSED), [centrale beoordeling Issue #55](https://github.com/JPouwiel/TETOOLS/issues/55). Suite-statusuitvoerder `01a1b00b-dfcc-7eb0-9621-c727cb25f06c` bevestigde in het behouden body-snapshot de AS-08/09-bronpaden (globale queries zonder INST_ID, lokaal KILL-commando). Mogelijke gedeelde identiteits-/provenanceafspraken met LOGGER vragen TETOOLS__REGIE-beoordeling. Brononderzoek blijft bij bestaande ADMIN_SESSIONS-regie; geen modulebesluit, API-/migratie-/codewijziging of Oracle-test goedgekeurd. AS-OPEN-01..10 blijven open.
