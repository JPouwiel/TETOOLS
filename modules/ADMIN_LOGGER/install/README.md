# Installation reference - not ready for execution

The reviewed source is CREATE-TETOOLS_ADMIN_LOGGER__20261023__003.sql.
The uploaded original contained a hardcoded password literal. Repository policy
forbids stored credentials. The Git copy replaces that single literal with NULL
and an explicit redaction comment. All other original bytes are preserved.
The original upload remains outside Git; its SHA-256 is recorded in the manifest.
The redacted file is not byte-identical to the uploaded installer.

See ../docs/reports/20261023__PLSQL__TETOOLS_ADMIN_LOGGER__installatie_review_003_STE_030.html.
The source has commented creation calls, no GRANT execution in its grant loop,
invalid DDL templates, an intentional error injection and unreliable final
failure status. It is a reference awaiting correction, not an installation entrypoint.

Infrastructure/account setup and module object scripts remain separate stages.
Do not create runtime objects or apply privileges merely by running this import.
The redacted credential is not a usable installation password.
