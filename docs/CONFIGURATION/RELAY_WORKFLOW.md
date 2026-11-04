# Dagelijkse TETOOLS-werkwijze
Het [actuele contract](../../COMMUNICATION_RELAY/RELAY_CONTRACT.md) is leidend.
Deze samenvatting verandert het contract niet.

## Start
Lees de verplichte main-bronnen, relevante modulebaseline en open suite-signalen.
Noteer basiscommit, rol, onderwerp, module en bron. Gebruik de echte sessie-ID;
als die niet beschikbaar is, genereer een UUID en label die als lokale sleutel.
Voeg via branch en PR een SESSION_REGISTRY-entry toe met session_id, role, module,
subject, revision, status, retention_status KEEP, registered_at, last_confirmed_at,
source_reference, recorded_by, deliverables en open_dependencies.
Alleen de eigen sessie of gemachtigde reviewer claimt ACTIVE.
Na merge teruglezen op main; een open PR is nog geen bevestigde registratie.

## Tijdens het werk
Leg inhoudelijke mutaties herleidbaar vast met een uniek change_id, record_type,
project, module, subject, bron, origin_session, recorded_by_session, approval_actor,
approved_by waar de validator dat vereist, status, datum, revision, supersedes en
artifact_refs. Registreer de PR in het auditspoor. Bewaar historische records.
Gebruik PROPOSED voor voorstellen; registreer IMPLEMENTED pas na merge/readback.
Voeg geen tweede actueel modulebesluitenregister toe onder docs.

Voor mogelijke suite-impact: CHANGE_REGISTER-record SUITE_IMPACT_SIGNAL met
origin_module, origin_session, bron, observed_facts, potential_cross_module_impact,
affected_modules of UNKNOWN, status PROPOSED, datum, recorder en artifact_refs.
Verwijs vanuit het module-register naar dit ID. Centrale regie leest deze signalen;
de relay verstuurt geen automatische notificatie. De bronmodule blijft eigenaar.

## Validatie en afronding
```powershell
python .\COMMUNICATION_RELAY\tools\validate_relay.py
```

Gebruik een beschikbare Python 3-installatie; dit commando is een structurele
registercontrole, geen volledige inhoudelijke validatie. Controleer ook bronpaden,
diff en ongewijzigde bevroren releases. Sluit af met resultaat, opleveringen,
teststatus, open afhankelijkheden en last_confirmed_at. CLOSED vereist een
overdracht en closed_at. Houd KEEP bij open punten of onzekere historie.
Verwijder geen chats. Bij afwezige toegang: NOT_REGISTERED melden en voorstel maken.

## Open punten van deze documentatieset
- PR-review en eventuele merge; daarna main-terugleescontrole en opvolgend bewijs.
- Windows-stappen moeten door een nieuwe lokale sessie worden beproefd.
- Persoonlijke instellingen en primaire map worden door deze documentatieopdracht
  niet gewijzigd. Oracle-tests zijn niet van toepassing op deze documentatie.
- Bibliotheekopslag wordt afzonderlijk gerapporteerd en is geen Git-synchronisatie.

