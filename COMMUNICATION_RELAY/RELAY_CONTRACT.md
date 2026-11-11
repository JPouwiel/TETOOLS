# COMMUNICATION_RELAY — gebruikscontract v1

> Centrale aanvulling revisie002: [REGIE_HANDOFF.md](REGIE_HANDOFF.md), Issue #111 /
> besluit6769485682. Capaciteit en gereedheid afzonderlijk in optionele HANDOVER-gegevens;
> normatief na geverifieerde PR112-merge/main-teruglezing (bewijs achteraf in PR/Issue).
> current_activity en bestaand mandaat blijven gelijk; oorspronkelijke PROPOSED-historie behouden.

Project: PLSQL_TETOOLS. Scope: projectbreed; module-inhoud blijft bij de module. Canonieke actuele status: CURRENT_STATUS.md. Module-index: MODULE_REGISTRY.md. Sessieregister: SESSION_REGISTRY.json. Historie van afspraken/besluiten/open punten: module-DECISIONS.md, REQUIREMENTS.md en OPEN_POINTS.md, met CHANGE_REGISTER.json voor mutaties en Git PR/commits voor bewijs.

## Taakcyclus en mijlpalen — Issue #119

Per actieve regielijn is er maximaal één Regie-, één Work- en één Codex-sessie. Hergebruik een geschikte bestaande sessie. Een lege plek mag leeg blijven. Regie kiest één inhoudelijk werkpakket tegelijk per regielijn en legt nieuwe bevindingen vast voor prioritering. Parallel werk kan binnen een mijlpaal als de afhankelijkheden en beschikbare bezetting dat toelaten. De auteur beoordeelt eigen werk niet als onafhankelijke reviewer.

Het bestaande taakissue bevat de planreferentie, mijlpaal, eigenaar, bevoegdheid, verwacht resultaat, toetsbare succescriteria, bewijs, afhankelijkheden, afgesproken controles en stoppunt. Gebruik vóór vaststelling van het suiteprojectplan Issue #119 als planreferentie voor de goedgekeurde invoeringsdelen. Standaard volgt op één uitvoeringsronde hoogstens één gerichte correctieronde. Daarna stelt de uitvoerder het resultaat veilig en legt hij het resterende beslispunt op het issue vast. Een expliciet overeengekomen opdracht kan een ander stoppunt hebben.

Ontvangst, voortgang bij betekenisvolle wijzigingen, resultaat en taakafmelding staan op hetzelfde issue. De uitvoerder meldt per criterium de uitkomst, versie en bewijslink. Bij een volledige gereedmelding gelden de vooraf afgesproken controles als voldoende voor voortgang. Verplichte review, mergevoorwaarden, bronverificatie en uitvoeringsautorisatie blijven van toepassing. De opvolger controleert alleen de eigen startvoorwaarden: gereedmelding, benodigde versie en relevante afhankelijkheden. Een eindtaak heeft geen opvolger.

De regie legt per mijlpaal het doel, de parallelle en opeenvolgende taken, het einde van elke reeks en de afsluitcriteria vast. Bij afsluiting beoordeelt de regie alle taakstatussen en bewijslinks, uitzonderingen en overgedragen restwerk. Voer de afgesproken integratie- of acceptatiecontrole uit. Hergebruik geldig bewijs uit de taakissues. Leg de afsluiting en eventueel overgedragen restwerk vast in GitHub. Zie [beheerprocedure](OPERATIONS.md) en [overdrachtsberichten](MANUAL_HANDOFF.md).

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

### Beoordelingsstatus ASSESSED — centrale contractcorrectie B, 10 november 2026

**ASSESSED** is uitsluitend geldig bij record_type
**REVIEW** en betekent: beoordeling vastgelegd; geen goedkeuring, implementatie,
testacceptatie of uitvoeringsautorisatie. DECISION, HANDOVER en ieder ander recordtype
mogen deze status niet gebruiken. Alle overige statusregels blijven gelden.
Bron: [centraal besluit B](https://github.com/JPouwiel/TETOOLS/issues/111#issuecomment-6769485682),
opvolgrecord REGIE-HANDOFF-CONTRACT-20261110-001. De oorspronkelijke
REGIE-LOGGER-READINESS-20261109 blijft exact behouden en wordt niet ongeldig verklaard.

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

## Handmatige overdracht tussen sessies (2026-11-04)

Gebruik [MANUAL_HANDOFF.md](MANUAL_HANDOFF.md). Hergebruik het taakissue en stuur een kort bericht met de link, gevraagde handeling en rol. Regie kan het bericht rechtstreeks sturen aan de bestaande sessie als daarvoor autorisatie en toegang bestaan. Anders kan de gebruiker hetzelfde bericht doorgeven. Ontvangst en resultaat worden in het issue vastgelegd. Het issue verwijst naar formele besluitregistraties. Automatische activering valt buiten deze procedure.

## Sessiebeoordeling en opruimadvies — optie A (goedgekeurd 2026-11-04)

Gebruik [SESSION_RETENTION_REVIEW.md](SESSION_RETENTION_REVIEW.md) en de read-only tool `tools/session_retention_review.py` voor een inventarisatie van geregistreerde sessies. De tool toont lifecycle, retention-status, open afhankelijkheden en redenen voor nadere beoordeling. De tool kan niet zelfstandig vaststellen of een ChatGPT-chat bestaat, of unieke context volledig is veiliggesteld, of een chat verwijderd is. Verouderde tijdstempels zijn alleen een onderzoekssignaal. Er worden geen automatische verwijderadviezen of acties uitgevoerd; expliciete toestemming en afzonderlijke verificatie blijven vereist. De huidige betekenis van `current_activity` en `SESSION_REGISTRY.json` blijft ongewijzigd.

## Actuele taak - REGIE-ACTIVITY-20261105-001

Een sessie mag optioneel precies een `current_activity` object vastleggen met uitsluitend
`task_reference` (Issue-URL of bestaand change-ID), `summary` (korte niet-lege taakomschrijving)
en `state` (`WORKING`, `WAITING`, `BLOCKED`). Afwezig of null betekent geen verklaarde taak;
het bewijst geen inactiviteit of einde van een chat. Schema_version blijft 1: bestaande entries blijven geldig.

Het taakissue toont de actuele voortgang. Bij taakstart en betekenisvolle overgangen kan de uitvoerder de optionele sessieverklaring bijwerken. Bundel de registerwijziging waar mogelijk met de resultaat-PR. Bevestig bij iedere registerwijziging de bestaande `last_confirmed_at` en `recorded_by`.
Dit zijn de datum van de laatste handmatige sessiebevestiging en de schrijver, geen heartbeat
of afzonderlijke taakstartdatum. Git/PR levert de wijzigingshistorie. Een andere sessie wijzigt
dit alleen met aantoonbare machtiging en bronverwijzing in de PR. Geen automatische updates.

`WORKING` is verklaarde uitvoering; `WAITING` is wachten op gebruikersantwoord of externe
afhankelijkheid; `BLOCKED` is niet kunnen doorgaan. Leg de reden/volgende actie vast in summary
en open_dependencies. Taakstatus en bestaande sessielifecycle blijven afzonderlijk; WAITING
sluit de sessie niet. Bij afronding of annulering: leg resultaat, deliverables en resterende
afhankelijkheden vast en verwijder current_activity in dezelfde wijziging (null is ook geldig).
COMPLETED, CLOSED en ARCHIVED mogen geen actuele taak hebben. CLOSED behoudt alle bestaande overdrachtseisen.

Oude bevestigingen blijven zichtbaar als laatste verklaring, nooit als live status. De bestaande
30-dagenhint in retention review blijft uitsluitend een onderzoekssignaal. Activiteit wordt niet
automatisch gewist bij ouderdom. Een verklaarde taak blokkeert ELIGIBLE_FOR_DELETION; de review
adviseert KEEP zolang deze taak bestaat. Geen taak geeft geen recht op opruimen.

Publicatie: lees de actuele main-versie; wijzig alleen de eigen entry op een branch; valideer;
review de PR-diff; controleer vlak voor merge dat de basis en geraakte entries niet zijn veranderd.
Bij gelijktijdige wijzigingen: opnieuw vanaf actuele main samenvoegen en opnieuw toetsen;
overschrijf nooit andermans entry met een oude volledige kopie. Merge uitsluitend het gecontroleerde
PR-head en lees de gewijzigde entry op main terug. De lokale validator controleert inhoud,
geen schrijversidentiteit of GitHub-rechten. Geen nieuwe infrastructuur of achtergronddienst.

Uitvoerbaar voorbeeld en verificatie: [CURRENT_ACTIVITY.md](CURRENT_ACTIVITY.md).
Dit besluit vervangt uitsluitend de onderzoeksstatus van REGIE-ACTIVITY-20261104-001;
de historische oorspronkelijke signalen en retentionbesluiten blijven bewaard.

## Verplichte taakafronding, regieoverdracht en sessiehergebruik — REGIE-HANDOFF-20261105-001

Bij afronding van **iedere** uitvoeringsopdracht (Work, Codex, import of module-uitvoering) stelt de uitvoerende sessie de relevante, nog niet duurzaam vastgelegde resultaten veilig in de **bestaande** canonieke module- en relaybestanden. Behoud originele bronversies, revisies, datums, besluitstatussen en verwijzingen; voeg geen dubbele actuele registers toe en wijzig geen bevroren releases. Documenteer geverifieerde resultaten, niet-uitgevoerde tests, besluiten met goedkeuring, open punten en opvolgende eigenaar. Publiceer via branch/PR/merge en lees de gewijzigde bestanden terug op main; bij ontbrekende toegang rapporteer BLOCKED en draag een concreet publicatiepakket over, zonder publicatie te claimen.

Na geverifieerde publicatie draagt de uitvoerende sessie het **eigenaarschap van resterend modulewerk terug aan de bestaande module-regie**. De module-regie bevestigt ontvangst via de bestaande GitHub Issue of modulebron; bij niet-bevestigde ontvangst blijft de overdracht open. Alleen mogelijke moduleoverstijgende impact gaat via het bestaande SUITE_IMPACT_SIGNAL naar TETOOLS__REGIE. Een open technisch ontwikkelpunt kan bij de opvolgende regie blijven zonder de oude uitvoeringschat als eigenaar aan te houden, mits overdracht en contextbehoud zijn geverifieerd.

Werk sessieregistratie en eventuele current_activity bij volgens het bestaande lifecycle-contract; beoordeel retention apart op basis van bewijs. Geen automatische vrijgave bij taakafronding. **Herbruik eerst een geschikte bestaande sessie**; de regie gebruikt een kort bericht met de link naar het bestaande taakissue. Start een nieuwe Work/Codex-sessie uitsluitend als geen bruikbare bestaande sessie beschikbaar is of de bestaande sessie technisch ontoereikend is; leg de reden kort vast in de bestaande taakbron. Deze regels vereisen geen nieuwe velden, diensten, dashboards of aparte beheerprocedure.
