# PL/SQL TETOOLS - configuratiehandleidingen
Revisie CFG-20261104-001 | 4 november 2026 | Status: PROPOSED via PR.
Scope: uitsluitend JPouwiel/TETOOLS, Oracle Database 19c Enterprise.
Deze set verandert geen instellingen, broncode, AGENTS.md of bevroren releases.

## Leesvolgorde
1. INVENTORY_AND_SOURCES.md - herkomst en vastgestelde situatie.
2. LOCAL_GIT_WINDOWS_SETUP.md - Git installeren en lokale checkout maken.
3. GITHUB_SETUP.md - verbinding, branch en PR.
4. CHATGPT_PROJECT_INSTRUCTIONS.md - project en primaire map.
5. CHATGPT_CUSTOM_INSTRUCTIONS.md en CODEX_CUSTOM_INSTRUCTIONS.md.
6. AGENTS_GUIDE.md - bestaand instructiebestand gebruiken.
7. CODEX_VERIFICATION.md - controle in een nieuwe sessie.
8. RELAY_WORKFLOW.md - registratie en overdracht.

TETOOLS_CONFIGURATION.pdf bevat alle bovenstaande hoofdstukken cumulatief.
De Markdown-bestanden zijn de kopieerbare bron. De PDF gebruikt Courier New 11 voor
commando's; koppen structureren de tekst, zonder betekenisdragende kleurcodering.
PROJECT_INSTRUCTIONS.txt bevat alleen de tekst om in het projectveld te plakken.

## Afbakening
GitHub-connector, lokale Git-authenticatie en primaire projectmap zijn afzonderlijke
voorzieningen. Een werkende connector maakt geen checkout. Bibliotheekopslag geeft
geen automatische projectsynchronisatie. Het actuele relay-contract blijft leidend.
Neem generieke instructies uit de oude chat niet over naar andere projecten.

## Publicatie en beheer
Canoniek documentatiepad: docs/CONFIGURATION/. Werk toekomstige wijzigingen via PR
bij, genereer de cumulatieve PDF opnieuw en controleer beide versies.
Registratie in een open PR is voorgesteld; pas na merge en main-terugleescontrole
is registratie op main bevestigd. Deze set claimt geen toegepaste configuratie.

