# ChatGPT-project en projectinstructies
## Plaatsen
Open PL/SQL TETOOLS. Open het projectmenu en kies Project bewerken / Edit project.
Kies Map toevoegen / Add folder, selecteer de gecontroleerde TETOOLS-checkout en
kies bij die map Primair maken / Make primary. Laat sources/ en de projectspiegel
ongemoeid. Start daarna een nieuwe lokale Codex-chat binnen dit project.
Dit volgt de [OpenAI-projectdocumentatie](https://learn.chatgpt.com/docs/projects).

Open de projectinstructies in het projectmenu en voeg onderstaande TETOOLS-tekst
toe aan de bestaande normen. Bewaar de Oracle 19c-, onderbouwing-, efficiëntie- en
refactoringafspraken. PROJECT_INSTRUCTIONS.txt is dezelfde plaktekst zonder uitleg.

## Kopieerbare tekst
```text
Project: PL/SQL TETOOLS (PLSQL_TETOOLS).
Repository: JPouwiel/TETOOLS; standaardbranch main.
Scope: uitsluitend TETOOLS, Oracle Database 19c Enterprise.
Beoogde omgeving: drie RAC-nodes; technische effecten vereisen apart bewijs.
Centrale regie: TETOOLS__REGIE; modulewerk blijft bij de betreffende ADMIN_*-regie.

Lees bij werkstart repository-AGENTS.md en:
COMMUNICATION_RELAY/START_HERE_TETOOLS_REGIE.md,
RELAY_CONTRACT.md, CURRENT_STATUS.md, PROJECT.md, MODULE_REGISTRY.md,
SESSION_REGISTRY.json, CHANGE_REGISTER.json en relevante module-registers.
Noteer basiscommit en sessieherkomst. Volg registratie, branch, PR, verificatie
en overdracht volgens het actuele contract. Een read-only configuratietest
met expliciet schrijfverbod voert geen registratie uit en meldt dat.

Onderbouw suggesties en correcties met redenering en controleerbare bronnen.
Controleer juistheid en Oracle 19c-toepasselijkheid; weeg efficiëntie mee.
Lever complete refactoring eerst als onderbouwd concept ter beoordeling.
Geef bij complexe code inline commentaar. Gebruik voor code Courier New 11
of een vergelijkbaar monospacefont; leg betekenisdragende opmaak uit.

Respecteer bevroren releases. Neem geen zelfstandig architectuurbesluit.
Signaleer mogelijke suite-impact volgens het relay-contract.
Bewaar oorspronkelijke besluiten en markeer voorstellen en aannames.
Claim geen registratie, merge, synchronisatie of Oracle-test zonder bewijs.
Rapporteer blokkades en niet-uitgevoerde controles afzonderlijk.
Behandel gesynchroniseerde sources/ als alleen-lezen referentiemateriaal.
```

