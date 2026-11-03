# PM-001 / revisie 004 / open punten v1
Geen van deze punten wordt door het bouwen van code stilzwijgend goedgekeurd.

| ID | Open onderwerp | Mijlpaal / bron | Afhandeling 004 |
|---|---|---|---|
| OP-01 | Definitieve CAN-001-wireformatacceptatie | M2; H32/34 | DRAFT-1 behouden |
| OP-02 | Profielscope/datatypekeuze en historische DATA_LENGTH-redenering | M1; C§3/H30 | regels 003 behouden als voorstel; oorspronkelijke reden onbekend |
| OP-03 | Portable objectidentiteit/naamnormalisatie | M2; H32/34 | diagnostische identiteit buiten canonical bytes; generated-name-regels 003 |
| OP-04 | Versie-/hashprecedentie bij installatie | M5; H34 | geen installatiebeleid |
| OP-05 | Vertrouwde gelijkheid/baseline | M5; H34 | vers berekenen; observatie is geen accepted baseline |
| OP-06 | Actualiteit/freshness | M5; H34 | DDL-vrij testvenster; geen cachebewijs |
| OP-07 | Pakbonopslag en productiesleutels | M4/M5; H33/34 | bestaand PoC-releasecontract, geen productieclaim |
| OP-08 | Uitzonderings-/autorisatiebeleid | M5; C§6/H34 | voorbeeld behouden; niet uitvoeren |
| OP-09 | Historie/retentie | M6; H34 | uitgesteld |
| OP-10 | Meerdere waarnemingen/concurrency | M6; H34 | duplicate zichtbaar afwijzen; geen overwrite |
| OP-11 | Evaluatieovergangen/correctie | M6; H34 | uitgesteld |
| OP-12 | Hashpad/grenzen definitief accepteren | M2; H32/34 | vaste bounds 003 testen |
| OP-13 | Productie-extractie, consistentie en containerzichtbaarheid | M1/M3; C§4/H31 | twee expliciete lokale PDB-routes, geen root/multi-PDBclaim |
| HIST-01 | Originele woordelijke reviewrondes 01/02 en volledige regiegeschiedenis ontbreken | S02 B02; S03 | uitsluitend reconstructieve C als beschikbare besluitenbasis; niet als volledig historisch bewijs presenteren |
| HIST-02 | Los origineel Pasted text.txt niet teruggevonden/gehasht | S01 manifest/sources | eigen C-teksthash leidend; geen gelijkheidsclaim met origineel |
| HIST-03 | Oorspronkelijke reden DATA_LENGTH weglating ontbreekt | C§3; S02 | hypothese niet als besluit gebruiken |
| VAL-01 | Oracle 19c EE database/verbinding ontbreekt in sessie | S04 | runtime NOT_EXECUTED; uitvoerlogs later vereist |
| M4-01 | Volledige objectversie-/installerworkflow is nog geen productiecontract | S02 B05 | enkel waarnemingen en echte preflight; tests zijn geen installerresultaat |

OP-samenvattingen zijn ontleend aan actuele H34 en de review; zij vervangen de bewaarde originele tekst in baseline_003 niet. Bij een ontbrekende oorspronkelijke nuance: HIST-01, geen nieuwe interpretatie als besloten beleid.
