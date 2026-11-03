# ADMIN_TNSNAMES

Oracle Database 19c. Module of the TETOOLS suite.
Canonical module location: `modules/ADMIN_TNSNAMES`.

## Current delivery

Publication **ATN-PUB-20261103-001** was imported through
[PR #8](https://github.com/JPouwiel/TETOOLS/pull/8) and merged into `main`.
Status: **source and analysis available; known build and contract blockers**.
This is not a compiled, runtime-validated or deployment-ready release.

The module source covers TNS alias registration, validation, configuration and
reporting. The separate PROTO package contains descriptor-intake experiments.
The supplied template generator prints examples; it is not evidence of a complete,
validated descriptor-generation pipeline.

- [Current source snapshot](SOURCE/SNAPSHOT/)
- [Source selection and component index](SOURCE_INDEX.md)
- [Installation reference and limitations](SOURCE/README.md)
- [Documentation and runbook](DOCS/README.md)
- [Decisions and proposals](DECISIONS.md)
- [Open work and missing evidence](OPEN_POINTS.md)
- [Test protocols and evidence status](TESTS/README.md)
- [Individual-file integrity manifest](manifest.json)

## Source of truth

The latest input analysed in this session is `ADMIN_TNSNAMES.zip`. It contains a
**mixed component snapshot**, not one certified module revision:

| Component | Supplied revision | Published source |
|---|---|---|
| Main package body | `20260921_301` | [Body](SOURCE/SNAPSHOT/PACKAGE_BODY/PCK_ADMIN_TNSNAMES_20260921_301.pkb) |
| Main package specification | `20250129_301` | [Specification](SOURCE/SNAPSHOT/PACKAGE_SPECIFICATION/PCK_ADMIN_TNSNAMES_20250129_301.pks) |
| PROTO package body | `20250220_301` | [Body](SOURCE/SNAPSHOT/PACKAGE_BODY/PCK_ADMIN_TNSNAMES_PROTO_20250220_301.pkb) |
| PROTO package specification | `20250217_306` | [Specification](SOURCE/SNAPSHOT/PACKAGE_SPECIFICATION/PCK_ADMIN_TNSNAMES_PROTO_20250217_306.pks) |
| Main DDL | `20260825_300` | [DDL](SOURCE/SNAPSHOT/TABLE/TAB_TETOOLS_ADMIN_TNSNAMES_20260825_300.sql) |
| PROTO DDL | `20250220_302` | [DDL](SOURCE/SNAPSHOT/TABLE/TAB_TETOOLS_ADMIN_TNSNAMES_PROTO_20250220_302.sql) |

A specification header also states Version 0.1. No implemented repair or newer
validated module was produced in this session. This baseline is the latest
available session input, not proof that a newer deployed or local version does
not exist. The regular package, PROTO package and standalone experiments must
not be treated as interchangeable releases.

The [source provenance record](DOCS/source_provenance.json) identifies the original
archive and files by SHA-256 and records the published derivatives. Publication
hashes identify individual file bytes; they are not Oracle installation hashes.
The manifest excludes itself to avoid a self-referential checksum.

## Analysis and design context

The frozen analysis **ATN-20261028-001** contains 27 findings with source references,
impact, priorities and verification protocols:

- [Analysis](RELEASES/ATN-20261028-001_SANITIZED/20261028__TETOOLS__ADMIN_TNSNAMES__analyse__20260921_301_STE_001.html)
- [Technical detail](RELEASES/ATN-20261028-001_SANITIZED/20261028__TETOOLS__ADMIN_TNSNAMES__verdieping__20260921_301_STE_002.html)
- [Solutions and recovery concept](RELEASES/ATN-20261028-001_SANITIZED/20261028__TETOOLS__ADMIN_TNSNAMES__oplossingen__20260921_301_STE_003.html)
- [Normalisation comparison and resumption notes](RELEASES/ATN-20261028-001_SANITIZED/comparison_and_resumption.md)
- [Publication note](RELEASES/ATN-20261028-001_SANITIZED/PUBLICATION_NOTE.md)

The source has compile blockers and differences between DDL, views and persistence
code. The solution report is a concept for review, not a replacement package.
Complete installation, privilege and cleanup scripts and dependency contracts
were not available. The experimental SQL and FUNCTION files contain examples
and DML; do not run them as a module installer.

The ADMIN_OBJECTS comparison is historical design context. It does not approve
a shared package or supersede later ADMIN_OBJECTS PM-001 decisions. Keep the
frozen reports unchanged; record subsequent corrections in a successor revision.

## Module boundaries and communication

Keep ADMIN_TNSNAMES source, reports, tests and module-specific decisions in this
directory. Shared repository storage does not imply one mandatory database
installation or a combined suite release. This import provides no suite installer.

Use the [COMMUNICATION_RELAY contract](../../COMMUNICATION_RELAY/RELAY_CONTRACT.md)
for project coordination. Its [ADMIN_TNSNAMES entry](../../COMMUNICATION_RELAY/MODULES/ADMIN_TNSNAMES/README.md)
points here; it is not a second source or decisions register. The origin session
is `01a184a4-b6f6-76d3-be6a-38608571155a`.

## Imported data and privacy

The import consists of nine code/reference files, reports, design context and
provenance. No database-row export or production runtime log was imported.

Published files are **sanitized derivatives**, not byte-identical copies of the
private input. Host/domain and IP samples, personal author names and local user
paths were redacted. Domain-policy literals were also affected and require review
before use. These substitutions are not defect corrections. The production
`tnsnames.ora` and original archive were deliberately excluded. Original local
and synchronized reference files remain unchanged.

## Verification and remaining work

The original analysis has historical browser checks and seven illustrative
byte-format checks. The import checks are recorded in
[publication_checks.json](TESTS/publication_checks.json). Historical results
do not automatically validate the sanitized derivative. In particular, the
historical JSON export download was canceled, not saved.

From the repository root, run the abstract encoding examples with:

```text
python modules/ADMIN_TNSNAMES/TESTS/canonical_contract_examples.py
```

This checks seven byte-contract examples. It does not parse a TNS descriptor or
execute PL/SQL. [inspect_oracle19c.sql](TESTS/inspect_oracle19c.sql) is a read-only
Oracle inspection protocol and has not been executed in this session.

Oracle installation, compilation, runtime, privileges, concurrency and performance
tests remain **NOT_EXECUTED**. Resolve the known blockers and capture actual
Oracle 19c evidence before any deployment approval. GitHub publication and merge
are not evidence of functional correctness, complete historical preservation or
permission to delete the original chat.
