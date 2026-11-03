Runbook — Oracle Database 19c, SQL*Plus of SQLcl
1. DBA maakt een NIEUW LEEG wegwerpschema met CREATE SESSION, CREATE TABLE,
   CREATE PROCEDURE en quota op een testtablespace. Geen TETOOLS-productieschema.
   UTL_RAW en UTL_I18N moeten uitvoerbaar zijn; bij ingetrokken PUBLIC-rechten
   zijn gerichte directe grants nodig. Geen DBA/SELECT ANY DICTIONARY nodig.
2. Maak een nieuwe SQL*Plus/SQLcl-verbinding als dit schema. Zet een DDL-vrij venster.
3. Voer 01_install_002.sql uit, daarna 02_package_002.sql.
   Controleer USER_ERRORS en USER_OBJECTS: AO2_POC PACKAGE en PACKAGE BODY VALID.
   De scripts stoppen op SQL-fouten; een mislukte DDL-installatie is niet rollbackbaar.
4. Voer 03_tests_002.sql eenmaal uit. Bewaar ao2_test_results.log met Oracle-versie,
   manifest, inventory, bytes, fingerprint en PASS-regels. Geen runtime-resultaten
   zijn bij deze levering vooraf ingevuld. Datatypegevallen tonen metadata;
   vergelijk die handmatig met de profielmapping en Oracle 19c-documentatie.
5. Voer de handmatige scenario's uit PM-001-22 uit waar toepasselijk, inclusief
   DDL-race, Unicode, partities, onleesbaarheid en profielcontractwijzigingen.
   Volledige productieacceptatie blijft buiten deze begrensde PoC.
6. Voer 04_cleanup_002.sql uit als hetzelfde testschema. Verwijdert uitsluitend
   de zes benoemde AO2-objecten. Voor herhaling opnieuw een leeg schema gebruiken.
   Tests falen bij afwijking; corrigeer en begin opnieuw, niet blind doorstarten.
Efficiëntie: één bulkread voor kolommen, één tableread, één external-check;
geen dictionaryread per property, geen normalizer-dynamic-SQL. Buffers zijn begrensd.
Niet gemeten: compilatie, runtime, performance, concurrency en Oracle RU-gedrag.
