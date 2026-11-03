# Tests and evidence

Oracle scope: 19c. inspect_oracle19c.sql is a read-only protocol, NOT_EXECUTED.
No Oracle compiler output, runtime logs, privilege inventory, connection tests,
concurrency results or benchmarks exist from this session. All are NOT_EXECUTED.

Historical evidence in historical_* records the original 2026-10-28 report QA:
27 findings, 346 local links, controls, JSON handling and mobile fit; the export
download was canceled, not saved. Seven illustrative Python byte-format checks
passed; they do not execute module code or establish Oracle/TNS equivalence.
The sanitized derivative has a different byte identity; earlier browser success
does not automatically validate this derivative. publication_checks.json records
the checks actually performed for this import.

Run python canonical_contract_examples.py to reproduce the seven abstract
byte-contract assertions. This is a design experiment, not a module regression
test. sha256 and Git blob IDs identify file integrity only.
