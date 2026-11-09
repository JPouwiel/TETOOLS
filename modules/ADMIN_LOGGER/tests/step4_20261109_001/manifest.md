# Version-pinned source manifest and static gate

Main source revision `20261109_501_DEV`; source PR #97 merge `81eadafaf575accadddd18e173d4f733359ea4b7`; static independent review PR #98 PASS. Git blob SHA-1 (not raw SHA-256):

| Source file relative to `src/20261109_501_DEV/` | Expected blob |
|---|---|
| PACKAGE_BODY/PACKAGE-BODY_TETOOLS_ADMIN_LOGGER__20261015_500.pkb | `febb57c5aebe3ce5d23799f60c6c38f793681d00` |
| PACKAGE_SPEC/PACKAGE_TETOOLS_ADMIN_LOGGER__20261015_500.pks | `9331a2756b1c2196280cda3f10bf1643285f61ab` |
| PROCEDURES/20260527__ADMIN_LOGGER__001.prc | `5a5e4e3181816aa520f5067f2b8c0abd3fef63f1` |
| SEQUENCE/SEQ_20261007__ADMIN_LOGGER__001.sql | `47416ff9583c32bc14cbe49007cd277f2449682b` |
| TABLE/TAB_TETOOLS_ADMIN_LOGGER__20261015_202.sql | `0c112a15643c62bcf4c2d4ac37fd54e2b656a04a` |
| REVISION_MANIFEST.md | `d6319dfa969770a2c9ece7be3e753febee86f5db` |

Before each approved test run, use `git rev-parse HEAD`, `git ls-tree -r HEAD modules/ADMIN_LOGGER/src/20261109_501_DEV` and `git hash-object <path>`; all six must match. Capture `git diff 20261015_500..20261109_501_DEV` by content (not ref name; directories differ). T01 expects only moved identical index statement (including slash) and one comma after `config_snapshot CLOB`. The original TABLE blob remains `240b6516fcfd7e9a99ae7d47bb18433f77a8686f`.

**Critical install detail:** TABLE SQL includes `CREATE TABLE`, slash-delimited statements, comments, a `CREATE TABLE ADMIN_LOGGER_GUARD` followed by `INSERT` and `COMMIT`. The sequence SQL uses a semicolon. A SQL*Plus script must preserve the supplied terminators and use fail-fast. All scripts use `@@` relative to the executing SQL file. Do not edit baseline or frozen releases.

**Static result:** source Git blobs verified in prior PR #97 merge; this test package's own review pending. **Oracle result:** NOT_EXECUTED.
