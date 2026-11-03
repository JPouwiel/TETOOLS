# Source selection and provenance

Origin: session 01a184a4-b6f6-76d3-be6a-38608571155a, Analyseer ADMIN_TNSNAMES.
Archive: user-supplied ADMIN_TNSNAMES.zip. Nine code/reference files are exported;
the tenth file, production tnsnames.ora, is withheld. Original archive and file
hashes are in DOCS/source_provenance.json, without raw connection data.

Content, call sites and contracts establish the selected baseline: the body
20260921_301 is paired with the supplied specification and DDL for analysis,
not assumed to be mutually compatible. No later repaired code was produced in
this session. PROTO revisions and experimental standalone helpers are not silently
promoted to a replacement for the regular package. File timestamps were not used
as the selection criterion.

Reports: RELEASES/ATN-20261028-001_SANITIZED. Tests and evidence: TESTS.
The earlier chat Oracle tabelstructuur vergelijken was read through the chat
tool, ID 6ae1c678-2a98-83ed-99b0-c8895440f708. Its sandbox handover files were not
retrieved. Historical report references to ADMIN_OBJECTS body 20261012_001 are
not claims about the later PM-001 004 release now in the repository.

Source rules: DOCS/source_provenance.json maps original hashes to publication
hashes. Each publication file is inventoried in manifest.json. Original line
counts are preserved for code, but redacted text differs. No Oracle-generated
metadata, runtime transcript, installed privilege inventory or independent source
review was supplied. Old report status is not proof of deployed state.
