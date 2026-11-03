# Decisions and proposals

All records: project PLSQL_TETOOLS; module ADMIN_TNSNAMES; origin/recorder session
01a184a4-b6f6-76d3-be6a-38608571155a. Source references identify visible user
requests by date/topic; exact message IDs are unavailable. supersedes: none.

| ID | Status | Date/revision | Approval actor/source | Meaning |
|---|---|---|---|---|
| ATN-DEC-001 | APPROVED | 2026-10-28 / analysis 001 | User: Analyse ADMIN_TNSNAMES and subsequent Akkoord | Analyse for Oracle 19c under the project/report agreements; preserve originals |
| ATN-DEC-002 | APPROVED | 2026-10-28 / comparison 001 | User: same-session request referencing Oracle tabelstructuur vergelijken | Compare normalisation/manifest design after module analysis; carry forward open points |
| ATN-DEC-003 | APPROVED | 2026-11-03 / ATN-PUB-20261103-001 | User: Publiceer de laatste code ... naar GitHub | Publish under modules/ADMIN_TNSNAMES via own branch and open PR; do not merge; exclude sensitive data |
| ATN-PROP-001 | PROPOSED | 2026-10-28 / analysis 001 | Assistant report, not user implementation approval | Resolve persistence contract and build blockers, enforce access and atomic intake |
| ATN-PROP-002 | PROPOSED | 2026-10-28 / comparison 001 | Assistant comparison; no shared-package approval | Preserve typed instance tree, semantic order, profile/version and unambiguous bytes; test before sharing code |

The earlier user agreed to profile versus object-manifest separation and ad-hoc
object-manifest generation. Assistant proposals for ON_CHANGE history, a history
table or shared utility package were not adopted decisions. Later PM-001 decisions
belong to ADMIN_OBJECTS and are not superseded by this historical comparison.
Publication approval is not approval of the source defects, redacted policies,
repair concepts or production deployment. PR/commit provenance is provided by Git.
