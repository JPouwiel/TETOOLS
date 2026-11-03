# Documentation and runbook

The three standalone HTML reports and comparison are in
../RELEASES/ATN-20261028-001_SANITIZED/. Open the analyse HTML first and keep
its companion files together. findings.json provides the stable 27 finding IDs.
comparison_and_resumption.md records the historical design scope and next steps.
source_provenance.json records selection and privacy transformations.

Runbook: (1) verify manifest integrity; (2) read README, decisions and open points;
(3) inspect the build blockers before attempting installation in an isolated
Oracle 19c test schema; (4) approve a storage/API contract and dependency list;
(5) implement a separately reviewed correction; (6) capture USER_ERRORS and
actual test evidence with RU/client/environment identity; (7) publish successor
frozen revisions without modifying the historical release. Do not execute the
experimental SQL files as an installer or run cleanup inferred from examples.

Review provenance: this session's static analysis is available; no independent
review approval exists. Browser checks and illustrative byte-format tests are
not PL/SQL functional validation. Later ADMIN_OBJECTS work is linked through
the repository's existing module and COMMUNICATION_RELAY, not copied here.
