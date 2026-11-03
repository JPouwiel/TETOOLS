# PL/SQL TETOOLS

Centrale projectadministratie, voorbereid op 3 november 2026.

Scope: Oracle Database 19c EE. Actieve module: ADMIN_OBJECTS, PM-001.
GitHub-doel: JPouwiel/TETOOLS, map COMMUNICATION_RELAY, door de gebruiker
gekozen. Deze projectmap is via de GitHub-connector gepubliceerd.
De connector bevestigt identiteit JPouwiel en toegang tot TETOOLS met
admin/push/pull-rechten. De aanvankelijke 404 is na appconfiguratie opgelost.

Lees manifest.json voor actuele revisies en SESSIONS/REGIE/20261103.md voor
de controleerbare stand. MODULES/ADMIN_OBJECTS/RELEASES bevat uitsluitend
bevroren opleveringen; werk niet rechtstreeks in een gepubliceerde release.

Eén werkwijze voor regie, ontwikkeling, review en test:

1. Lees de actuele release, besluiten, eisen en open punten; noteer de basiscommit.
2. Werk op een eigen branch. Verwijs in de commit/PR naar module, revisie,
   besluit/eis, bron en testbewijs. Markeer voorstellen en ontbrekend bewijs.
3. Review en beantwoording vinden plaats in dezelfde PR. Verwerk antwoorden
   als commits; bij een inhoudelijk besluit ook het besluitenregister bijwerken.
4. Leg een bevroren release met individueel bestandsmanifest vast. Bewaar de
   eerdere release. Runtimebewijs krijgt omgevingsidentiteit en een eigen pad.

Geen aparte overdrachtsprocedure: repositorylocatie plus basiscommit en
opdracht volstaan zodra de inhoud en toegang werkelijk geverifieerd zijn.
Iedere sessie controleert haar eigen toegang; toegang uit deze sessie bewijst
geen toegang vanuit alle andere sessies. Beveiligde credentials horen niet in Git.

Bestandschecksums zijn integriteitsbewijs. Dit zijn geen samengestelde
installatiehashes voor Oracle-objecten.

## Actuele projectbrede navigatie

- CURRENT_STATUS.md is de actuele operationele status.
- MODULE_REGISTRY.md registreert de modules van het project.
- SESSIONS/REGIE/20261103.md is historische verantwoording, geen actuele status.
- De module ADMIN_OBJECTS in het bestaande manifest is de focus van de eerste publicatie; de relay is projectbreed.

## Sessies en herkomst

Lees RELAY_CONTRACT.md voor de verplichte werkwijze. SESSION_REGISTRY.json registreert sessies en bewaarbeoordelingen; CHANGE_REGISTER.json legt wijzigingen aan afspraken, besluiten en open punten herleidbaar vast. Gebruik tools/validate_relay.py voor structurele validatie. Registratie is expliciet, niet automatisch.
