# Runbook — review and test preparation only

1. Read README, DECISIONS, OPEN_POINTS and the frozen analysis. Establish the installed source and provider permission envelope.
2. Confirm Oracle 19c topology: local PDB, RAC and/or CDB root. Record database identity without publishing credentials.
3. Resolve AS-01/02, reconcile package names, type/seed preferences, and define least-privilege direct grants in a successor change.
4. In an isolated schema, create the tables and prerequisites, then spec/body, trigger and views after review.
   This is a dependency outline, not a runnable certified installer. Keep jobs disabled; supplied jobs enable themselves and target the wrong name.
5. Inspect USER_ERRORS and object validity. Reject deployment on any compile error. Verify the authoritative permission and target matrix.
6. Use an engine test double for state transitions and concurrent claims before any real kill test.
7. Execute real stop scenarios only against deliberately created disposable sessions under provider policy.
   Record expected/actual engine outcomes and audit persistence; do not claim target disappearance from command acceptance alone.
8. Certify the actual ADMIN_LOGGER version before enabling C01; preserve original errors and caller instrumentation.
9. Enable corrected housekeeping last, after preference, expiry and reconciliation tests pass.

Rollback/cleanup: no reviewed cleanup script exists. Preserve requests and audit history.
Do not run blanket DROP, DELETE or broad privilege revocation commands from this import.
An operator must design object-scoped cleanup and recovery from captured pre-change state.
No suite-wide or combined installation hash is defined. Individual file hashes identify bytes only.
