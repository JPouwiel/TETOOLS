# GitHub-verbinding en documentatie-PR
## Toegang controleren
Open https://github.com/JPouwiel/TETOOLS met je eigen account.
Controleer dat main en de bestanden AGENTS.md en COMMUNICATION_RELAY zichtbaar zijn.
Controleer in ChatGPT bij plugins/verbindingen dat de GitHub-verbinding toegang
heeft tot JPouwiel/TETOOLS. Laat de agent een bestaand bestand lezen.
Installeer of verruim geen rechten als een bestaande verbinding al volstaat.
Een 404 kan ook onvoldoende repositorytoegang betekenen.
Lokale Git-toegang test je afzonderlijk door clone of git fetch.

## Documentatie via de website
1. Open de repository en kies main.
2. Maak via de branchkiezer een eigen branch, bijvoorbeeld docs/tetools-config-update.
3. Kies Add file > Create new file en vul docs/CONFIGURATION/BESTANDSNAAM.md in.
   De schuine strepen maken mappen; Git bewaart geen lege map.
4. Plak de Markdown en commit naar de nieuwe branch.
5. Upload een cumulatieve PDF via Add file > Upload files op dezelfde branch.
6. Werk sessie- en changeregister volgens het contract bij in dezelfde PR.
7. Kies Compare & pull request; base main, compare de eigen branch.
8. Beschrijf bron, basiscommit, scope, controlebewijs en open punten.
9. Beoordeel alle gewijzigde paden en laat de PR controleren.

## Lokale variant voor een volgende documentatie-update
Alleen in schone, bijgewerkte checkout:
```powershell
git switch -c docs/tetools-config-update
# Bewerk uitsluitend de afgesproken documenten en relay-records.
git diff --stat
git diff --check
git add -- docs/CONFIGURATION
# Voeg de daadwerkelijk gewijzigde relay-bestanden afzonderlijk toe.
git diff --cached --stat
git commit -m "docs: update TETOOLS configuration guides"
git push -u origin docs/tetools-config-update
```

Open de PR via GitHub. Commit identiteit zo nodig lokaal instellen met je eigen
naam en het door GitHub getoonde gewenste e-mailadres; verzin geen adres.
Stage geen ongerelateerde wijzigingen met git add . .

## Merge en controle
Het contract schrijft branch/PR en teruglezen na merge voor; het bevat geen
algemene expliciete plicht om voor iedere documentatie-merge gebruikersgoedkeuring
te vragen. Deze opdracht vraagt publicatie via PR. Laat de PR daarom ter review
open; er wordt geen technische of architecturale goedkeuring geclaimd.
Na geautoriseerde merge: open PR, controleer merged=true en mergecommit, lees de
documenten en registraties vanaf main terug, vergelijk bestandsidentiteiten en
werk verificatie als opvolgend record bij. Claim voor die stap geen IMPLEMENTED.

