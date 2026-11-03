# TETOOLS ADMIN_OBJECTS PM-001 revisie 004
Oracle Database 19c Enterprise Edition - disposable lokaal PDB-schema.

Start met RUNBOOK.md. De gecontroleerde basis staat in reference/manifest.json; lees DECISIONS.md, REQUIREMENTS.md, OPEN_POINTS.md en SOURCE_INDEX.md. REFERENCE_CHECK.md beschrijft de uitgevoerde broncontrole; DEVIATIONS.md registreert de implementatiekeuzes. DESIGN.html is het offline ontwerp met actuele SQL en oorspronkelijke 003-verwijzingen. PM001_004.pdf bevat ontwerp, runbook, registers en bewijsgrenzen; exacte uitvoerbare code staat onder sql/.

Status: code en tests opgeleverd, lokale statische controles uitgevoerd; Oracle-compilatie en runtime NOT_EXECUTED. G2-G4 zijn pas geslaagd na echte Oracle-logs. Geen productie-upgrade, geen installatiehash, geen uitvoeringsmodi.

SQL-volgorde: 00_install.sql -> 03_tests.sql -> nieuwe verbinding: 04_verify_persistence.sql -> DBA revoke CDB_TABLES, nieuwe verbinding: 06_privilege_error.sql -> DBA restore -> 05_cleanup.sql. Volg het runbook voor exacte verbinding, rechten en logcontrole.

De originele ZIP 003 is bytegelijk meegeleverd. Historische bronvolledigheid is begrensd: oorspronkelijke reviewrondes en oudere regieturns ontbreken. Geen Oracle-log is gefabriceerd of als geslaagd bijgevoegd.
