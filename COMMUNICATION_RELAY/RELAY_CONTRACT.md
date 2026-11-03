# COMMUNICATION_RELAY — gebruikscontract v1

Project: PLSQL_TETOOLS. Scope: projectbreed; module-inhoud blijft bij de module. Canonieke actuele status: CURRENT_STATUS.md. Module-index: MODULE_REGISTRY.md. Sessieregister: SESSION_REGISTRY.json. Historie van afspraken/besluiten/open punten: module-DECISIONS.md, REQUIREMENTS.md en OPEN_POINTS.md, met CHANGE_REGISTER.json voor mutaties en Git PR/commits voor bewijs.

## Sessies

Bij eerste gebruik registreert een sessie een uniek session_id, role, module, subject, revision, status, retention_status, source_reference en recorded_by. Gebruik echte thread-ID waar beschikbaar; verzin er geen. Statuswaarden: REGISTERED, ACTIVE, BLOCKED, COMPLETED, CLOSED, ARCHIVED. Alleen de sessie zelf of een aantoonbaar gemachtigde reviewer mag ACTIVE claimen. COMPLETED is een werkstatus, geen bewijs dat de chat is beëindigd. CLOSED vereist vastgelegde opleveringen, bronverwijzingen en overdracht van open afhankelijkheden. ARCHIVED is een registratie, niet het wissen van de chat.

Bewaarstatus: KEEP, REVIEW, ELIGIBLE_FOR_DELETION. De laatste waarde mag uitsluitend na verificatie van unieke context, bronnen, besluiten, open punten, resultaat, afhankelijke sessies en herleidbare Git-opslag; het is een advies, nooit een automatische verwijderactie. Bij onzekerheid KEEP. Een ontbrekende heartbeat is geen bewijs van beëindiging. Registraties worden niet automatisch bijgewerkt vanuit ChatGPT; iedere sessie moet zelf schrijven en teruglezen.

## Besluiten, afspraken en open punten

Voor elke inhoudelijke mutatie registreer: uniek ID, record_type, project, module, onderwerp, bronverwijzing naar oorspronkelijk gesprek/document en waar mogelijk exact bericht, origin_session, recorded_by_session, approval_actor, status, datum, revisie, supersedes en commit/PR. Onderscheid PROPOSED, APPROVED, REJECTED, SUPERSEDED en CLOSED; een advies is nooit automatisch een goedgekeurd besluit. De oorspronkelijke tekst blijft in de bron behouden; ontbrekende bron wordt expliciet UNVERIFIED genoemd. Voeg een change-record toe en werk het relevante module-register bij in dezelfde PR. Bij correctie niet het historische spoor wissen: registreer opvolging/supersedes.

## Transactie / verificatie

1. Lees CURRENT_STATUS, MODULE_REGISTRY, SESSION_REGISTRY en de relevante module-baseline; noteer basiscommit.
2. Wijzig in een branch; voeg sessie-ID, oorspronkelijke bron, wijziging, status en bewijs toe in PR.
3. Werk sessieregister en eventuele module-registers bij; voorkom dubbele actuele besluitenregisters.
4. Lees na merge de bestanden en PR terug; alleen dan status IMPLEMENTED/APPROVED registreren.
5. Bij afmelding: registreer resultaat, open afhankelijkheden en bewaarbeoordeling; sluit pas af na terugleescontrole.

Geen wachtwoorden, tokens of persoonlijke geheimen in de repository. Git-auteur identificeert een GitHub-account, niet noodzakelijk de uitvoerende ChatGPT-sessie; daarom beide identiteiten apart registreren. Automatische chat-export, automatische sessiedetectie en feitelijke chatverwijdering zijn geen functies van deze relay.

## Controlecriteria

- JSON is parseerbaar, IDs uniek, statuswaarden geldig, alle bronpaden controleerbaar.
- Geen status CLOSED zonder overdrachtsverwijzingen en retention_status.
- Geen ELIGIBLE_FOR_DELETION bij open dependencies of ontbrekende historie.
- Bevroren releases blijven ongewijzigd.
- Projectbrede index mag niet impliciet een andere projectscope importeren.

## Suite-impact signalering en escalatie (REGIE-20261103-003)

Elke module-regiesessie mag een bevinding met **mogelijke** suitebrede impact aanmelden bij TETOOLS__REGIE via COMMUNICATION_RELAY. Bewezen impact is geen voorwaarde voor aanmelding. De centrale regie beoordeelt of een suitebrede architectuurregel, gemeenschappelijke oplossing, extra onderzoek of geen centrale actie nodig is. De module-regie behoudt eigenaarschap van bronanalyse en module-implementatie.

Registreer de melding in CHANGE_REGISTER.json met uniek change_id, record_type `SUITE_IMPACT_SIGNAL`, origin_module, origin_session, source_reference, subject, observed_facts, potential_cross_module_impact, affected_modules (of UNKNOWN), status `PROPOSED`, recorded_at, recorded_by_session en artifact_refs. Vermeld aannames expliciet; leg geen oplossing of impact als vastgesteld feit vast zonder bewijs. Verwijs in het relevante module-register naar het centrale signalerings-ID. Voeg bij beoordeling een opvolgend change-record toe met disposition (SUITE_STANDARD, SHARED_SOLUTION, INVESTIGATE, MODULE_ONLY of REJECTED), onderbouwing en eventuele supersedes; behoud het oorspronkelijke record.

Signalering is **geen automatische notificatie of chatsynchronisatie**. TETOOLS__REGIE moet bij aanvang en bij statuscontrole open SUITE_IMPACT_SIGNAL-records uitlezen. De indienende sessie moet de GitHub-commit/PR teruglezen en kan de centrale regie expliciet op de melding wijzen. Geen modulebesluit wordt stilzwijgend vervangen.
