# Decisions and proposals

Project PLSQL_TETOOLS; module ADMIN_SESSIONS; revision AS-PUB-20261103-001; origin/recorded-by session `01a138df-aece-73c1-a082-32fa2d835303`.
Source: [relevant user requests](DOCS/SESSION_CONTEXT.md). Exact original message IDs: UNVERIFIED.
Publishing authorization is not technical design acceptance or deployment approval.

| ID | Status | Record | Source / approval actor | Supersedes |
|---|---|---|---|---|
| AS-DEC-01 | APPROVED_SCOPE | Publish to modules/ADMIN_SESSIONS in JPouwiel/TETOOLS via own branch and open PR; do not merge | User publication request, 2026-11-03; actor: user | none |
| AS-DEC-02 | APPROVED_SCOPE | Oracle 19c, honest evidence, sanitized copies, individual checksums only | User/project instructions and publication request; actor: user | none |
| AS-DEC-03 | PROPOSED | Preserve complete source baseline and keep C01 independent; no source fix imported | Static analysis AS-01..24; actor: no design approval recorded | none |
| AS-DEC-04 | PROPOSED | Keep domain workflow authoritative; use an adapter for logger diagnostics | AS-23/24 solutions report; actor: no design approval recorded | none |
| AS-DEC-05 | PROPOSED | Exact identity, explicit target permissions, durable claims and outcome reconciliation | AS-06..20; actor: no design approval recorded | none |

All records entered 2026-11-03, revision AS-PUB-20261103-001. Branch/PR and base revision are in manifest.json and Git history.
No technical record is marked IMPLEMENTED or APPROVED. Earlier source comments do not prove design decisions.
