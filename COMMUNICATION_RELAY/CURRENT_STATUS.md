# Actuele status COMMUNICATION_RELAY

Project: PLSQL_TETOOLS. Datum: 2026-11-03.

| Onderdeel | Status |
|---|---|
| Centrale opslag | JPouwiel/TETOOLS/COMMUNICATION_RELAY, bereikbaar |
| GitHub-publicatie | Pull request #1 gemerged; schrijf- en terugleescontrole vastgelegd |
| Projectbrede index | MODULE_REGISTRY.md aanwezig |
| ADMIN_OBJECTS PM-001 revisie 004 | Bevroren; statische controles uitgevoerd; Oracle-runtime NOT_EXECUTED |
| Historische volledigheid | Niet volledig; ontbrekende bronnen staan in release-OPEN_POINTS.md |
| Retourtest tussen verschillende sessies | Nog niet uitgevoerd; lagere prioriteit |

Historische gebeurtenissen en eerdere toegangsproblemen staan in SESSIONS/REGIE/20261103.md. Gebruik dat verslag niet als actuele statusbron. Wijzigingen aan deze status en de module-index worden via branches en pull requests voorgesteld.

## Relay-functionaliteit

Sessieregistratie: SESSION_REGISTRY.json. Herkomst en wijzigingshistorie: CHANGE_REGISTER.json, aangevuld met module-registers en Git-commits. Gebruik RELAY_CONTRACT.md en tools/validate_relay.py. De eerste registratie is een conservatieve inventarisatie; niet alle bestaande chats zijn geïnventariseerd. De functionaliteit vereist dat elke sessie haar wijzigingen daadwerkelijk publiceert.

## ADMIN_LOGGER import

Bronimport en rapporten zijn via [PR #4](https://github.com/JPouwiel/TETOOLS/pull/4) gemerged en vanaf main teruggelezen (38 bestandshashes bevestigd). Canonieke modulemap: `../modules/ADMIN_LOGGER/`; de relay-index verwijst daarheen. Oracle-validatie en bronreview 20261015_500 zijn nog open.
