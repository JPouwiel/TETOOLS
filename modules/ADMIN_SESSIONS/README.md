# ADMIN_SESSIONS

Publication revision **AS-PUB-20261103-001**, Oracle Database **19c**.
Status: **SOURCE_IMPORT_WITH_KNOWN_BLOCKERS — REVIEW_PENDING**.
This is a review package, not a compiled or deployment-ready release.
The database package is named `ADMIN_SESSION` (singular); the canonical repository module is `modules/ADMIN_SESSIONS`.

## Current baseline

The latest available complete session source set is the original `VERSIE_0.301` upload:
specification `20251216.301`, body `20260921_300`. These filenames, banner 0.2 and body comment disagree;
they do not prove an installed database release. Selection uses source provenance and the prior analysis,
not file modification times. No later repaired module was produced in this conversation.

- [Source and supporting scripts](SOURCE/README.md)
- [24-finding analysis and design index](DOCS/README.md)
- [Runbook and installation limitations](DOCS/RUNBOOK.md)
- [Frozen sanitized analysis release](RELEASES/AS-20261014-001_SANITIZED/01_analysis.html)
- [Test evidence and NOT_EXECUTED gates](TESTS/README.md)
- [Decisions and proposals](DECISIONS.md), [open points](OPEN_POINTS.md), [source index](SOURCE_INDEX.md)
- [Individual file integrity manifest](manifest.json)

The separate [C01 adapter](SOURCE/CONCEPT/concept_admin_session_diag.sql) demonstrates optional ADMIN_LOGGER diagnostics.
It does not submit, approve or terminate sessions. The earlier analysis used logger BODY407/SPEC408;
the repository's logger baseline is now 20261015_500. Compatibility is **NOT_EXECUTED**.
Domain request/approval state stays in this module; that architecture remains **PROPOSED**.

No passwords, connection files, database rows, production runtime logs or raw archives are included.
Published sources are line-preserving UTF-8 sanitized copies. Original checksums are provenance only.
No automatic installer or cleanup script was supplied; the legacy grants/jobs must not be run as a certified installation.
