# Regiecontrole revisie 004 en beoogde PoC

Bron: bestaande kandidaat output/PM-001_20261103_004; onafhankelijke lezing
van SQL, runbook, besluitenbasis en PM001_003_review.md. Geen tweede
implementatie gestart; bestaande releases en sources niet gewijzigd.

| Onderdeel | Bevinding | Bewijsgrens |
|---|---|---|
| B03 | Publieke extract_metadata, normalize_metadata, serialize_manifest en store_observations; acht getypeerde metadatasets; normalizer leest geen database | Statisch gecontroleerd; compilatie en datasetsemantiek wachten op Oracle |
| B04 | preflight verwerkt echte doelen en schrijft AO4_FINDING; foutpad bewaart SQLCODE/SQLERRM; fingerprint ontbreekt bij fout | Implementatie aanwezig; duurzaamheid na COMMIT en rollback staan als uit te voeren assertions |
| B07 | 63 T-assertions, individuele objectbewijzen, drie persistentie-, twee privilege- en een cleanupassertion | Inventaris aanwezig; alle database-uitkomsten NOT_EXECUTED |
| Catalogus | Exact dezelfde 53 unieke labels als 003 | Pythonvergelijking uitgevoerd |
| CAN-001 | BLOB/SHA256; volledige 003-vector opnieuw gecodeerd: 1228 bytes, digest ongewijzigd | Lokale Pythoncontrole, geen Oracle-uitvoer |
| Opslag | Individuele tabel-, constraint- en indexwaarnemingen; savepoint; geen package-COMMIT | Statische inspectie, geen transactiebewijs op Oracle |
| Cleanup | Fout in child/parentvolgorde gevonden, teruggekoppeld en door de implementatiesessie gecorrigeerd | Statische hercontrole geslaagd; echte cleanup na fout vereist Oracle |

## Verschil tussen kandidaat 004 en de uiteindelijke PoC

De kandidaat is de implementatiebasis voor de gevraagde PoC. De regiecontrole
voegt geen concurrerende profielregels of tweede implementatie toe. De
gevonden cleanupvolgorde is in de bestaande kandidaat gecorrigeerd en
statisch opnieuw gecontroleerd. De definitieve bestandsidentiteit
wordt vastgelegd in het centrale manifest en releasebestand.

De PoC kan voorbereid en statisch gecontroleerd worden opgeleverd zonder
Oracle-omgeving. De resterende runtimehiaten worden niet als opgelost
geclaimd: compilatie, privileges, CDB/DBA-bytes, preflight-DML, fingerprints,
opslag, rollback, foutpaden, herverbinding en cleanup vereisen echte 19c-logs.
Het runbook en TEST_RESULTS geven daarvoor de bewijsstatus per test.

Een volledige productie-installer met objectversiebeleid, accepted baselines,
autorisatie, concurrency en lifecycle is volgens de behouden besluiten geen
onderdeel van deze begrensde heap/constraints/indexes-PoC. Deze onderwerpen
blijven expliciet open; zij zijn niet door de code stilzwijgend geaccepteerd.

Technische onderbouwing: [Oracle 19c DBMS_SQL](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_SQL.html),
[CDB-views](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/cdb_-views.html)
en [DBMS_CRYPTO](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_CRYPTO.html).
Deze documentatie onderbouwt API-gedrag en lokale PDB-scope; het eigen
CAN-001-DRAFT-1-protocol blijft de geregistreerde ontwerpstatus houden.
