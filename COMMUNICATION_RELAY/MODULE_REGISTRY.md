# Projectbrede module-index

Project: PLSQL_TETOOLS. Deze index geldt voor alle modules binnen het project.

| Module | Registratiestatus | Pad |
|---|---|---|
| ADMIN_OBJECTS | Canonieke module-import; PM-001 004; Oracle-validatie open | [Module](../modules/ADMIN_OBJECTS/) / [historische relay-publicatie](MODULES/ADMIN_OBJECTS/) |
| ADMIN_LOGGER | Bronimport gemerged via PR #4; Oracle-validatie open | [Canonieke module](../modules/ADMIN_LOGGER/) / [relay-verwijzing](MODULES/ADMIN_LOGGER/) |

Nieuwe modules krijgen een eigen map onder MODULES en een entry in deze index. Releasegebonden besluiten blijven bij hun module; er wordt geen tweede centraal besluitenregister gekopieerd.

ADMIN_LOGGER-uitzondering: de gebruiker koos expliciet `modules/ADMIN_LOGGER` vanaf de repositoryroot. De relay bevat uitsluitend een verwijzing; module-inhoud blijft op het canonieke pad.

ADMIN_OBJECTS: op expliciete gebruikersopdracht is `modules/ADMIN_OBJECTS` het canonieke modulepad. De bestaande bevroren relay-release blijft behouden; beide publicaties gebruiken dezelfde ongewijzigde Git-tree. Gebruik de module-index en releasegebonden registers, geen afzonderlijke handmatig gesynchroniseerde besluitenlijsten.


ADMIN_TNSNAMES: proposed canonical import at [../modules/ADMIN_TNSNAMES/](../modules/ADMIN_TNSNAMES/), publication ATN-PUB-20261103-001, mixed source/main body 20260921_301; review pending, Oracle NOT_EXECUTED. Explicit user-selected repository-root module path; relay contains a pointer only.

ADMIN_SESSIONS: explicit user-selected canonical path [../modules/ADMIN_SESSIONS/](../modules/ADMIN_SESSIONS/), publication AS-PUB-20261103-001; supplied spec 20251216.301/body 20260921_300, historical review AS-20261014-001; technical proposals unapproved, Oracle NOT_EXECUTED. Relay pointer only.
