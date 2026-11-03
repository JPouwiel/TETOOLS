# ADMIN_OBJECTS

Canonieke modulelocatie: `modules/ADMIN_OBJECTS`. Oracle RDBMS 19c; PM-001 PoC: 19c EE.

## Actuele oplevering

- [PM-001 revisie 004](releases/PM-001_20261103_004/README.md), gedateerd 3 november 2026.
- [Runbook](releases/PM-001_20261103_004/RUNBOOK.md) en [SQL](releases/PM-001_20261103_004/sql/).
- [Ontwerp HTML](releases/PM-001_20261103_004/DESIGN.html) en [PDF](releases/PM-001_20261103_004/PM001_004.pdf).
- [Besluiten](releases/PM-001_20261103_004/DECISIONS.md), [eisen](releases/PM-001_20261103_004/REQUIREMENTS.md), [open punten](releases/PM-001_20261103_004/OPEN_POINTS.md), [traceerbaarheid](releases/PM-001_20261103_004/TRACEABILITY.csv) en [teststatus](releases/PM-001_20261103_004/TEST_RESULTS.csv).

Status: bevroren en statisch gecontroleerde PoC; **Oracle-compilatie en runtime NOT_EXECUTED**. Geen productieklare volledige module en geen nieuwe ontwerpacceptatie. CAN-001-DRAFT-1 blijft een voorstel. B03/B04/B07 zijn opgenomen, niet op Oracle bewezen.

De release is bytegelijk aan de bestaande publicatie onder de relay; dezelfde Git-tree wordt hergebruikt. De oude bevroren publicatie en daarin opgenomen revisies 001/002/003 blijven behouden. Nieuwe inhoudelijke wijzigingen krijgen een nieuwe revisie.

## Bron en context

- [Bronoverzicht](SOURCE_INDEX.md): oorspronkelijke ADMIN_OBJECTS-upload en onderscheid met de nieuwere PM-001 PoC.
- [Originele bronbestanden](source/original_20261012_001/): BODY20261012_001, SPEC20261008_001, DDL20261001_003 en bijbehorende scripts. Historische ontwikkelbron, niet stilzwijgend bijgewerkt naar PoC 004.
- [Analyse van 14 oktober](history/analysis_20261014/README.md): drie offline HTML-rapporten, codeconcepten en bronmanifest in de originele rapportenset.
- [Ontwerpafspraken tot 28 oktober](context/20261028__ADMIN_OBJECTS__ontwerpafspraken_en_hervatting.md). Historische ontwerpverkenning; de PM-001-besluitenbasis is leidend voor de begrensde PoC.
- [Besluitenoverzicht](DECISIONS.md), [open punten](OPEN_POINTS.md) en [actuele status](CURRENT_STATUS.md).
- [Publicatieherkomst](PROVENANCE.json) en [individuele bestandsinventaris](SOURCE_MANIFEST.json).

## Communicatie en bewijs

Gebruik het [relaycontract](../../COMMUNICATION_RELAY/RELAY_CONTRACT.md). Deze import is uitgevoerd vanuit sessie `01a138d4-ee43-7930-aea2-4ec084041013` na raadpleging van ADMIN_OBJECTS__REGIE. Verdere regie/review en Oracle-uitvoer blijven herleidbaar via de centrale registers en de bewaarde release. Nieuwe Oracle-logs horen bij een eigen run-ID en omgevingsidentiteit, zonder credentials.

Een import in GitHub is geen bevestiging dat alle historische chats volledig zijn geëxporteerd en geen toestemming om chats te verwijderen.
