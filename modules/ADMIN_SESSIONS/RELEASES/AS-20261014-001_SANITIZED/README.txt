ADMIN_SESSIONS — AS-20261014-001 — 2026-10-14
Oracle RDBMS 19c. 24 fixed finding IDs across three reports.
Extract the ZIP to one folder. Open 01_analysis.html.
All report CSS, JavaScript, diagrams and original source snapshots are embedded.
Oracle documentation links need internet access. Relative report links work offline.
Print complete report opens all findings; source snapshots are omitted from print.
Code uses Courier New 11 pt or equivalent. See the legend in each report.

The archive creates ADMIN_SESSION (singular), despite plural module/table naming.
Local logger baseline: BODY407 / SPEC408. Prior logger analysis reviewed 500.
No Oracle compilation, execution or performance benchmark was performed.
Original source files were not changed. Source hashes are in manifest.json.
concept_admin_session_diag.sql is an independent optional diagnostic concept.
It does not perform session termination or acknowledge durable log delivery.
Do not install it before isolated compilation and dependency verification.
Full refactoring is described as a concept, not implemented as a replacement.
findings.json preserves review content; validation.json lists performed checks.
