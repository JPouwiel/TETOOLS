# Relaybeheer en herstel
Datum 6 november 2026. Uitwerking van bestaand contract binnen goedgekeurde acceptatieopdracht; geen nieuwe dienst of architectuur.
Normatief blijft RELAY_CONTRACT.md. Eigenaar: TETOOLS__REGIE voor contract, acceptatie en afwijkingsdisposition; project-/GitHub-eigenaar JPouwiel voor toegangsbeheer en expliciete cleanupgoedkeuring. Module-regies behouden hun technische inhoud. Iedere schrijver valideert eigen wijzigingen; onafhankelijke ontvanger bevestigt alleen feitelijke ontvangst.

## Controles per werkpakket

Leg de controles vooraf vast op het taakissue. Kies de passende zwaarte en voeg verplichte controles uit beleid, repositoryregels of taakautorisatie toe.

| Werk | Controles |
|---|---|
| Taakmelding of administratieve overdracht op een issue | Controleer taak, bronversie, status, bereikbare bewijslinks en eigenaar van restwerk. Lees de gepubliceerde melding terug. |
| Documentatie of administratieve repositorywijziging | Controleer afgebakende diff, verwijzingen, behoud van historie en bronpaden. Bij gewijzigde registers: validator, relevante schema’s en vergelijking met onafhankelijk opgeslagen main. |
| Functionele wijziging | Controleer de acceptatiecriteria met relevante tests en review. Gebruik de eerder gecontroleerde basis en lees de relevante verschillen. |
| Hoog risico, bijvoorbeeld publieke interface, security, transacties of RAC | Leg onafhankelijke beoordeling en technische acceptatiecontroles vooraf vast. Voer Oracle-tests uit binnen de afzonderlijk verleende scope en beschikbare omgeving. Registreer ontbrekend bewijs expliciet. |
| Wijziging van relaycontract, schema of validatiehulpmiddel | Voer de volledige relaytests, stdlib-validator, beide JSON-schema’s, append-only vergelijking en de toepasselijke overdrachts- en retentioncontrole uit. |

Bij PR-publicatie: controleer actuele main, gewijzigde entries en de precieze versie van de PR. Verwerk gelijktijdige wijzigingen vanaf de actuele basis. Merge binnen de verleende bevoegdheid en lees de gewijzigde bestanden op main terug. Gebruik `validate_acceptance.py --baseline-ledger baseline.json` met de voorgeschreven dependencies en een baseline uit de gecontroleerde main-commit. Bundel resultaat, registratie en bewijs in één PR waar dat past.

Een opvolger gebruikt de gereedmelding en controleert de eigen startvoorwaarden. Bij mijlpaalafsluiting beoordeelt de regie alle taakstatussen en bewijslinks samen en voert de geplande integratie- of acceptatiecontrole uit. Leg afwijkingen en eigenaarschap van restwerk vast. Een volledige hercontrole is passend bij een gewijzigde of ontbrekende basis, een mislukte controle of een afwijking met gevolgen voor acceptatie.

## Afwijking en herstel
Stop de betreffende merge of acceptatieclaim bij FAIL. Bewaar foutuitvoer, basis-/head-SHA, pad en record-ID. Sessie blijft KEEP; leg blokkade en volgende eigenaar vast.
Bij verloren/gewijzigde historie: vergelijk eerste-parent main-versies per ID en inhoud. Bewaar beide versies met broncommits; herschrijf geen oude records of Gitgeschiedenis. Voeg herstel-/supersedesrecord toe en vraag centrale disposition. Herstel nooit door een oud compleet register over nieuwere entries te kopiëren.
Bij verdwenen bron: registreer UNVERIFIED en concrete herstelactie; geen verzonnen bewijs. Bij toegangsfout: NOT_REGISTERED/BLOCKED en concreet publicatiepakket, geen mergeclaim.
Bij foutieve publicatie: correctie op opvolgbranch/PR en herhaalde validatie/readback; een revert van registers mag geen latere historie verwijderen. Escaleer noodzakelijke inhoudelijke correctie naar de eigenaar.
Bij onverwacht afgebroken chat: ouderdom is alleen onderzoekshint; gemachtigde reviewer documenteert bron en actie. Geen proxy-ACTIVE of cleanup zonder bewijs.

## Acceptatie 20261106
Zie reports/RELAY_ACCEPTANCE_20261106.md en Issue #62. Historische mutatie OBJECTS-PM002-OFFLOAD-20261105-001 en twee herordeningen zijn bewaard in RELAY_HISTORY_AUDIT_20261106.json. Disposition/herstelacceptatie bij TETOOLS__REGIE; OPERATIONAL nog niet toegekend.

## Onafhankelijke eindacceptatie - 6 november 2026
REGIE-RELAY-ACCEPTANCE-20261106-001: bestaande schema's/gate, handmatige beheerprocedure en lokale herstelproef geaccepteerd. OPERATIONAL geldt voor deze begrensde relay na geverifieerde publicatie; geen automatische enforcement of Oracle/RAC-vrijgave. Zie rapport revisie002 en Issue62 voor werkelijk merge/readbackbewijs. De oude acceptatiepassage hierboven is de historische momentopname vóór regiebeoordeling.
Voor de aanvullende schemagate: gebruik een Python-versie die jsonschema==4.26.0 ondersteunt (deze toets: gebundelde Python3.12); de stdlibtools behouden hun bestaande Python3.8+-pad. Bewaar een baseline uit de gelezen main-SHA vóór wijzigingen. De onafhankelijke herstelproef wees mutatie af en accepteerde behoud van baseline plus nieuw correctierecord; beide lokale versies bewaard. Geen live herstel of historie-rewrite nodig.
