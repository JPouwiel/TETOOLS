# PM-001 004 installatiecorrectie (niet-bevroren werkexemplaar)

Dit is de actuele uitvoeringsset met DBA-/schema-aanduidingen en een begrensd quota-voorbeeld. De oorspronkelijke release 004 blijft bytegelijk en historisch controleerbaar. Gebruik voor installatie en tests de scripts en RUNBOOK.md uit **deze** map, niet de oude release-scripts. De onderlinge relatieve SQL-verwijzingen zijn behouden. Er zijn geen functionele PL/SQL-wijzigingen aangebracht, alleen commentaar en runbooktekst. Het quota 100M is een voorbeeld; de DBA kiest de echte waarde en het juiste default tablespace. De Oracle 19c-runtimevalidatie blijft NOT_EXECUTED.

## Oracle 19c privilege-verduidelijking

De DBA verleent tevens `CREATE SEQUENCE` voor expliciete sequences in het eigen testschema. Voor indexes op eigen tabellen is geen aparte `CREATE INDEX`-systeemgrant nodig. De identity-kolom in `AO4_FINDING` gebruikt een intern gegenereerde sequence; dit is geen zelfstandig bewijs voor de noodzaak van `CREATE SEQUENCE`. Geen `CREATE ANY INDEX` of `CREATE ANY SEQUENCE` verlenen. Zie `sql/00_privileges.sql` en `RUNBOOK.md` en de Oracle 19c SQL Language Reference (CREATE TABLE / CREATE INDEX / CREATE SEQUENCE).
