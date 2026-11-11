# Actuele taak per geregistreerde sessie

Issue #23, uitvoering 2026-11-05. Besluit: REGIE-ACTIVITY-20261105-001 in CHANGE_REGISTER.json.
Doel: de uitvoerende sessie onderhoudt zelf een kleine actuele taakregistratie in het bestaande
SESSION_REGISTRY. Gebruiker hoeft geen extra voortgangsbestand of dashboard bij te houden.

## Gebruik

Gebruik het taakissue voor actuele voortgang en afmelding. Als je een actuele taak in je eigen sessie-entry vastlegt, gebruik je deze structuur:

```json
"current_activity": {
  "task_reference": "https://github.com/JPouwiel/TETOOLS/issues/23",
  "summary": "Minimale activiteitregistratie implementeren en toetsen",
  "state": "WORKING"
}
```

Werk tegelijk last_confirmed_at en recorded_by bij; behoud alle andere sessiegegevens.
Bij wachten: WAITING, met concrete reden en volgende actie. Bij blokkade: BLOCKED.
Bij hervatten: WORKING. Bij taakafronding/annulering: verwijder het object (of zet null),
bewaar resultaat en bewijs in deliverables/Issue en registreer resterende open_dependencies.
Een volgende opdracht mag een nieuwe taak verklaren. Geen aparte taak-ID, taakstartdatum,
heartbeat, actorveld of duplicaat van bestaande sessietijdstempels nodig.

Bundel de registerwijziging waar mogelijk met de resultaat-PR en publiceer via branch/PR/merge/readback. Alleen eigen
sessie of aantoonbaar gemachtigde reviewer; controleer actuele main voor merge en voeg
gelijktijdige updates opnieuw samen. Niet iedere tussenstap hoeft een aparte statusupdate.

## Toetsen en bekijken

Vanaf repositoryroot, Python 3.8+; uitsluitend standaardbibliotheek:

```sh
python COMMUNICATION_RELAY/tools/validate_relay.py
python -m unittest discover -s COMMUNICATION_RELAY/tools -p 'test_*.py' -v
python COMMUNICATION_RELAY/tools/session_retention_review.py --as-of 2026-11-05
```

De bestaande read-only inventarisatie toont ook de taak. Een verklaarde taak geeft KEEP;
zonder taak blijven alle bestaande conservatieve checks gelden. Ouderdom is geen bewijs
van inactiviteit. Afwezig/null is geen bewijs van voltooiing of chatverwijdering.

## Grenzen en direct gebruik

Direct bruikbaar na merge met bestaande GitHub-toegang en Python; geen Oracle-installatie,
extra infrastructuur, modulewijziging of databasemigratie. Reeds geregistreerde sessies hoeven
niet te worden gemigreerd en krijgen geen verzonnen taak. De regel werkt zodra een actieve
sessie het protocol volgt. Inactieve chats worden niet gewekt, gevonden of bijgewerkt.
Onverwacht afgebroken sessies kunnen een oude taak achterlaten; een gemachtigde reviewer
onderzoekt deze met bronbewijs, wist nooit alleen wegens ouderdom en behoudt bij twijfel KEEP.
Geen chatdetectie, automatische synchronisatie, heartbeat, chatarchivering of chatverwijdering.

## Herkomst en scope

PR #24: onderzoeksvoorstel; #25: retention review; #26: eerste inventarisatie met expliciete
projectiebeperking. Deze opdracht toetst echte GitHub-bestandsinhoud via blobidentiteiten.
Gebruiker heeft op 2026-11-05 expliciet minimaal ontwerp, implementatie, tests, publicatie,
merge/readback en zelfstandige cumulatieve PDF opgedragen. Exacte gebruikersbericht-URL:
UNVERIFIED; voorganger chatgpt-conversation://6ae9e9eb-6400-83eb-859c-580027d25466.
Geen nieuwe modulearchitectuur; PM-001 en hypothetische KT-03 blijven afzonderlijk open.
