# Source status

`SNAPSHOT/` contains eight source scripts from the reviewed upload, grouped exactly as received.
The spec and body have known compile-contract defects (AS-01/02). No fixes are silently applied.
The supplied tables, trigger, views, scheduler and grants are reference scripts, not a validated installation.
The jobs call plural ADMIN_SESSIONS; the actual package is singular ADMIN_SESSION.
Preference seed DML is commented and the grant set is broad/incomplete for a clean installation.
The standalone file named stop_sessie creates KILL_SESSION but only inspects and prints a match.

`CONCEPT/` is new independent proposal C01, NOT_EXECUTED, not part of the current source baseline.
No aggregate installer, uninstall/cleanup script or least-privilege repaired grant script was provided.
Do not invent a destructive cleanup operation from historical object names.
See ../DOCS/RUNBOOK.md and ../DOCS/source_provenance.json before use.
