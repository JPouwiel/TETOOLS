# TETOOLS — startprotocol voor nieuwe sessies (2026-11-03)

**Project:** PL/SQL TETOOLS, Oracle Database 19c Enterprise, beoogd 3-node RAC. **Centrale chat:** TETOOLS__REGIE. **Duurzame registratie:** COMMUNICATION_RELAY in deze repository.

> **Nieuwe sessie:** lees dit protocol, registreer jezelf daadwerkelijk in GitHub en leg relevante afspraken, besluiten en open punten vast. Een chatprompt of Markdown-bestand registreert je niet automatisch. Claim geen succes zonder verificatie op main.

## Verantwoordelijkheden

- TETOOLS__REGIE: projectbrede architectuur, standaarden, afhankelijkheden en goedgekeurde besluiten.
- ADMIN_OBJECTS__REGIE / ADMIN_LOGGER__REGIE: modulegebonden ontwerp, fouten en uitvoering.
- Work/Codex: technische uitvoering binnen expliciet afgesproken scope.
- COMMUNICATION_RELAY: duurzame GitHub-registratie; geen automatische transcript-export.

## Verplichte startprocedure

1. Controleer GitHub-toegang tot JPouwiel/TETOOLS. Lees op main: COMMUNICATION_RELAY/PROJECT.md, CURRENT_STATUS.md, MODULE_REGISTRY.md, RELAY_CONTRACT.md, SESSION_REGISTRY.json, CHANGE_REGISTER.json en relevante module-registers. Noteer de gelezen commit-SHA.
2. Bepaal rol, module, onderwerp, startdatum en bronverwijzing. Gebruik de echte sessie-ID als beschikbaar, anders een als lokaal gegenereerd gemarkeerde UUID. Verzin geen thread-ID.
3. Registreer via branch en PR in SESSION_REGISTRY.json: session_id, role, module, subject, revision, status REGISTERED/ACTIVE, retention_status KEEP, registered_at, last_confirmed_at, source_reference, recorded_by, deliverables en open_dependencies.
4. Merge volgens repositoryworkflow, lees de entry terug op main en rapporteer de PR/commit. Zonder toegang: meld NOT_REGISTERED en de blokkade; claim geen registratie.

## Besluiten en historie

Leg relevante goedgekeurde afspraken en besluiten, eisen en open punten vast in het passende project- of module-register. Gebruik CHANGE_REGISTER.json voor de herleidbare wijziging en Git PR/commits als audit trail. Registreer uniek ID, type, status, module, oorspronkelijke bron, origin_session, recorded_by_session, goedkeurende actor, datum, impact, afhankelijkheden en supersedes. Onderscheid voorstel, aanname, observatie, testresultaat en besluit. Niet-geverifieerde bronnen krijgen UNVERIFIED. Geen stilzwijgende overschrijving van historische besluiten. Niet elk chatbericht wordt automatisch gelogd.

## Afmelding en bewaring

Werk bij afronding SESSION_REGISTRY.json bij met COMPLETED, BLOCKED of CLOSED, resultaat, deliverables, open_dependencies en last_confirmed_at. CLOSED vereist een aantoonbare overdracht en closed_at. Retention is afzonderlijk KEEP, REVIEW of ELIGIBLE_FOR_DELETION; bij onzekerheid of open afhankelijkheden KEEP. Verwijder geen chats automatisch. Merge en controleer de status opnieuw op main. Onverwacht beëindigde chats kunnen niet gegarandeerd afmelden.

## Eerste projectbrede architectuurpunt

De gebruiker heeft op 2026-11-03 de doelomgeving **Oracle 19c Enterprise met drie RAC-nodes** aangegeven. Beheer dit als projectbrede randvoorwaarde in TETOOLS__REGIE. Onderzoek effecten op instance-/sessie-identiteit, CDB/PDB-context, dictionaryrechten, concurrency, logging en deployment; presenteer deze effecten niet als al gevalideerde feiten.

Het PM-001-issue in ADMIN_OBJECTS blijft modulegebonden: extract_metadata gebruikt SEARCH_CONDITION in de CDB-route; volgens de gebruiker is in de doelomgeving alleen SEARCH_CONDITION_VC beschikbaar. Houd rekening met afkapping van lange CHECK-expressies. De fix is niet gevalideerd en moet in ADMIN_OBJECTS__REGIE worden behandeld.

## Werknormen

Oracle 19c is standaard; wijzig bevroren releases niet; gebruik branches/PR's/merge/terugleescontrole; markeer aannames en niet-uitgevoerde tests; vermijd ANY-privileges en geheimen in Git; onderscheid Git-auteur van sessie-oorsprong. Scope uitsluitend TETOOLS.

## Eerste antwoord van nieuwe sessie

Meld gelezen main-commit, sessie-ID en rol, registratiebewijs (PR/commit), relevante open punten en scope van de opdracht. Als GitHub niet bereikbaar is: meld de blokkade en lever een handmatig registreerbaar voorstel.

## Bronnen

- [COMMUNICATION_RELAY](https://github.com/JPouwiel/TETOOLS/tree/main/COMMUNICATION_RELAY)
- [RELAY_CONTRACT](https://github.com/JPouwiel/TETOOLS/blob/main/COMMUNICATION_RELAY/RELAY_CONTRACT.md)
- [SESSION_REGISTRY](https://github.com/JPouwiel/TETOOLS/blob/main/COMMUNICATION_RELAY/SESSION_REGISTRY.json)
- [CHANGE_REGISTER](https://github.com/JPouwiel/TETOOLS/blob/main/COMMUNICATION_RELAY/CHANGE_REGISTER.json)

## Overdracht tussen sessies (2026-11-04)

Lees [MANUAL_HANDOFF.md](MANUAL_HANDOFF.md). Bij een verzoek aan een andere sessie: maak een GitHub Issue, controleer de URL en lever een volledig ingevuld kopieerbaar bericht. Als ontvanger: lees het Issue en de bronverwijzingen zelfstandig en registreer uitkomst en bewijs. De gebruiker is uitsluitend transporteur, geen impliciete goedkeurder. Zonder toegang: gebruik de expliciete fallback. Geen automatische sessieactivatie.
