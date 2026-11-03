# ADMIN_LOGGER

Oracle Database 19c EE. Module of the TETOOLS suite.

## Source of truth

The latest uploaded module source found for this import is **20261015_500**, from
`TETOOLS.ADMIN_LOGGER_20261015_500.zip`. BODY and SPEC both identify 20261015_500.
See [the source manifest](SOURCE_MANIFEST.json) for original paths and SHA-256 values.
This is the latest **available upload**, not a claim that a newer database or local
version does not exist. No Oracle compilation, execution or new bug review was
performed for this repository import.

- [Current uploaded source](src/20261015_500/)
- [Original uploaded archive](archives/TETOOLS.ADMIN_LOGGER_20261015_500.zip)
- [Documentation and report index](docs/README.md)
- [Installation reference and limitations](install/README.md)
- [Historical proposals](proposals/README.md)
- [Current module status](CURRENT_STATUS.md)
- [Requirements and decisions](DECISIONS.md)
- [Open work](OPEN_POINTS.md)
- [Integrity and link validation](tools/verify_import.py)

## Module boundaries

Keep ADMIN_LOGGER source, installation references, tests and reports in this
module directory. Other modules can use the public API; shared repository
storage does not imply one mandatory database installation or one combined
release. The exact dependency graph and per-module release policy remain to be
specified. This import does not create a suite-wide installer.

`COMMUNICATION_RELAY` remains the project-wide coordination layer. Its
[ADMIN_LOGGER entry](../../COMMUNICATION_RELAY/MODULES/ADMIN_LOGGER/README.md)
points here and does not duplicate the module source.

## Imported data

The imported data consists of source files, code proposals, reports and provenance.
No database-row export or production runtime log was supplied or imported.
Original source files are retained byte for byte. The installation reference is
a separately labelled redacted derivative; see its README before any use.

## Verification

Run `python3 modules/ADMIN_LOGGER/tools/verify_import.py` from the repository root.
This checks files, original archive extraction, embedded report proposal payloads,
and HTML links. It does not run SQL on a database.
