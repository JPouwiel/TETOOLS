# Punt 40 F05 — RAC-readiness en releasegrens

Datum 2026-11-09. Status ANALYSIS / PROPOSED INTERPRETATION, NOT_APPROVED als nieuwe norm. Eigenaar TETOOLS__REGIE. Gebruikersopdracht 'Laten we F05 starten.' in huidige projectchat; exacte thread URL UNVERIFIED.

## Bestaand goedgekeurd beleid

Besluit 13 onderscheidt build, functionele, RAC-ready en technische release-readiness. Besluit 14 verplicht synthetische RAC-matrix zonder echte RAC te simuleren als definitief bewijs. Besluit 37 maakt release/acceptatie risicogestuurd; besluit 4 verlangt acht toetscategorieën en herleidbaar bewijs. Besluit 3 reserveert suite-afwijkingen voor TETOOLS__REGIE.

## Analyse

Synthetische tests kunnen scenario's rond INST_ID, SID/SERIAL#, CON_ID, concurrency, nodewissels, failover en privileges onderzoeken, maar leveren op zichzelf geen empirisch bewijs van gedrag in een representatieve drie-node RAC-omgeving. Testresultaten moeten beperkt worden tot feitelijk uitgevoerde configuraties. Ontwikkeling en voorlopige technische beoordeling kunnen doorgaan met RAC NOT_DEMONSTRATED; dit is geen RAC-ready claim. Het ontbreken van een echte RAC-testomgeving is geen automatische productie- of deploymentvrijgave.

## Voorstel statuscommunicatie (nog niet goedgekeurde namen)

- BUILD_VERIFIED: uitsluitend aantoonbare compilatie/installatiecontrole in de gemeten omgeving.
- FUNCTIONAL_VERIFIED: functionele tests voor de vastgelegde scope geslaagd.
- RAC_PROVISIONAL: synthetische RAC-matrix uitgevoerd en geëvalueerd, echte RAC-validatie ontbreekt.
- RAC_READY: alleen na relevante representatieve RAC-tests, met exacte omgevingsscope en bewijs.
- TECHNICAL_RELEASE: afzonderlijk acceptatiebesluit, niet automatisch afgeleid uit één van bovenstaande niveaus.

## Besluitvraag

Mag een expliciet beperkte interne release of externe installatieoverdracht plaatsvinden zonder echte RAC-validatie, mits risico, beperkingen, afwijkingsgoedkeuring en nog te leveren RAC-bewijs zijn vastgelegd? Dit vergt expliciete beslissing, en mag niet worden afgeleid uit besluit 14. Voorstel: alleen via centraal afwijkingsmandaat, zonder RAC_READY-claim of automatische productieacceptatie.

## Grenzen

Geen Oracle-compilatie, runtime, failover of RAC-test uitgevoerd. Geen broncode, object, frozen release of eerdere beleidsbesluiten gewijzigd. Module-eigen technische bewijsvoering bij ADMIN_LOGGER__REGIE en relevante module-regies; suitebesluit bij TETOOLS__REGIE.
