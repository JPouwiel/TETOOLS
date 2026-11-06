# Relaybeheer en herstel
Datum 6 november 2026. Uitwerking van bestaand contract binnen goedgekeurde acceptatieopdracht; geen nieuwe dienst of architectuur.
Normatief blijft RELAY_CONTRACT.md. Eigenaar: TETOOLS__REGIE voor contract, acceptatie en afwijkingsdisposition; project-/GitHub-eigenaar JPouwiel voor toegangsbeheer en expliciete cleanupgoedkeuring. Module-regies behouden hun technische inhoud. Iedere schrijver valideert eigen wijzigingen; onafhankelijke ontvanger bevestigt alleen feitelijke ontvangst.

## Bij iedere wijziging
1. Lees actuele main en noteer SHA; lees open signalen inclusief opvolgende dispositions.
2. Wijzig op branch; behoud andermans sessie-entry en bestaande change-records. Voeg correcties als opvolgrecord toe.
3. Voer vanaf repositoryroot uit:
   - python COMMUNICATION_RELAY/tools/validate_relay.py
   - python -m unittest discover -s COMMUNICATION_RELAY/tools -p 'test_*.py' -v
   - python COMMUNICATION_RELAY/tools/session_retention_review.py --as-of YYYY-MM-DD
4. Aanvullende acceptatiecontrole: installeer tools/requirements-acceptance.txt in een afzonderlijke omgeving. Bewaar CHANGE_REGISTER.json van de gelezen main-SHA als baseline.json. Voer python COMMUNICATION_RELAY/tools/validate_acceptance.py --baseline-ledger baseline.json uit. Dit gebruikt JSON Schema 2020-12 en vergelijkt het volledige bestaande recordprefix, inclusief volgorde. De eigenlijke baseline moet onafhankelijk uit main komen: een vergelijking met zichzelf bewijst geen historiebehoud.
5. Review diff en bronverwijzingen; controleer direct voor merge main en geraakte entries opnieuw. Integreer gelijktijdige wijzigingen vanaf actuele main; geen force-overwrite. Merge alleen gecontroleerd head; lees alle gewijzigde blobs terug en vergelijk verwacht bewijs.
6. Werk activiteit bij op betekenisvolle overgang; bij afronding resultaat, afhankelijkheden en KEEP/cleanupreden vastleggen, activiteit wissen. CLOSED vereist echte overdracht en closed_at. Geen automatische chatsynchronisatie.

De JSON-schema's beschrijven de bestaande v1-structuur, met projectovererving voor oude change-records. Ze wijzigen geen lifecyclebetekenis. De bestaande validator blijft zonder externe dependencies bruikbaar. Schema's bewijzen geen schrijversidentiteit, toestemming, bronvolledigheid of Oracle-correctheid.
Validatie gebeurt bij start/hervatting, iedere PR, overdracht, afsluiting en na merge. Er is geen periodieke taak of automatisch CI ingesteld.

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
