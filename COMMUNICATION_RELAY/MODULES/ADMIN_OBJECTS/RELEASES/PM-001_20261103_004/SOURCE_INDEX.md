# PM-001 / revisie 004 / bronindex v1
Alle pakketpaden relatief aan de revisie-004-root. SHA-256 en byteaantallen staan in manifest.json. Een hash bewijst identiteit, niet historische volledigheid.

| ID | Bron / precieze vindplaats | Gebruik / betrouwbaarheid |
|---|---|---|
| S01 | reference/20261103__PLSQL__TETOOLS_ADMIN_OBJECTS__PM001_PoC_003.zip; uitgepakt in reference/baseline_003 | 18 entries; 17 geverifieerde manifestbestanden; ongewijzigde baseline |
| S01-C | baseline_003/*contextoverdracht_003.txt §§1-10 | beschikbare reconstructieve besluitenoverdracht; geen woordelijk origineel |
| S01-H | baseline_003/*ontwerp_profielmanifest_003.html H28-H35 | actuele cumulatieve specificatie; H01-H27 historisch |
| S01-S0..4 | baseline_003/*00_privileges*, *01_setup*, *02_package*, *03_tests*, *04_cleanup* | implementatie 003; geen Oracle-runtimebewijs |
| S01-V/J/B | baseline_003/*CAN001_testvectoren*, *objectmanifest_voorbeeld*, *canonieke_bytes_voorbeeld* | referentiebytes; geen echte databasewaarneming |
| S02 | reference/PM001_003_review.pdf; tekstcompanion PM001_003_review.md §§4-9 en bijlagen | beoordelingsbron, B03/B04/B07 uitvoeringshiaten; adviezen zijn geen besluiten |
| S03 | regiechat 6ae1c678-2a98-83ed-99b0-c8895440f708, read_thread 2026-11-03, turnLimit 10 | zes recente turns, geen oudere cursor; geen volledige oorspronkelijke reviews; bijlagen lokaal beschikbaar |
| S04 | reference/USER_SCOPE_004.md | letterlijke actuele implementatieopdracht; voorrang boven eerdere voorstellen |
| S05 | reference/USER_REFERENCE_FIRST_004.md | letterlijke actuele instructie: eerst referentiepakket, afwijkingen registreren |
| H001/H002 | reference/historical/output/PM-001_* | 12 lokale historische bestanden uit manifest 003 opnieuw op SHA-256 gecontroleerd en meegeleverd; uitsluitend historie |

Oracle 19c primaire technische bronnen (semantiek, geen TETOOLS-beleidsbesluiten):
- O1 CDB_* Views: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/cdb_-views.html (huidige container, directe grants, zichtbaarheid).
- O2 ALL_TAB_COLS: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/ALL_TAB_COLS.html (NUMBER/FLOAT, length/char semantics).
- O3 DBMS_CRYPTO: https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_CRYPTO.html (SHA256 BLOB).
- O4 UTL_RAW: https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/UTL_RAW.html (COMPARE-resultaat, RAW-grenzen).
- O5 AUTHID: https://docs.oracle.com/en/database/oracle/oracle-database/19/lnpls/invokers-rights-and-definers-rights-authid-property.html (definerrechten/directe grants).
- O6 DBMS_SQL: https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_SQL.html (getypeerde kolomextractie/LONG).

O1/O3/O5/O6 zijn in deze sessie online geraadpleegd; O2/O4 staan tevens in S02 en dienen bij de betreffende codecontrole opnieuw geraadpleegd te worden. Ontbrekende oorspronkelijke chatteksten, niet-teruggevonden losse uploads en ontbrekend Oracle-testbewijs zijn expliciet opgenomen in OPEN_POINTS.md.
