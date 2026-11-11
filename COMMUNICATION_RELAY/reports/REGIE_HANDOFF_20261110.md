# Verbeterde regieoverdracht — ontwerp, implementatie en verificatie

10 november 2026; uitvoerder bestaande Codex-thread `01a1a59b-e2cf-7d10-9a9f-29e6312a2ae3`.
Taak [#111](https://github.com/JPouwiel/TETOOLS/issues/111). **BRANCH_PROPOSAL / MERGE_BLOCKED**.
Geen implementatie, sessieregistratie of ontvangst op main geclaimd.

## Bronnen en bevoegdheid

Gebruikersopdracht duurzaam opgenomen in [opdrachtbron](../SESSIONS/CODEX/20261110_HANDOFF_REQUEST.md).
Werkelijke thread-ID vastgesteld via list_threads en read_thread; dezelfde huidige beurt bevat
de bijlage en de oorspronkelijke configuratiecontrole als chatpreview. Geen nieuwe chat,
uitvoerder of centrale rol aangemaakt. Centrale regie blijft `01a1c4f4-e7eb-7f51-ab89-2fe51f09bc62`.
User message `01a1c504-cd7b-7942-a00c-59837c6108c4`, turn `01a1c504-ca8a-7030-aab6-b7de92479fac`;
geen verzonnen publieke bericht-URL.

Actuele main na fetch: `b7e035b00bfc115e815b52e8e388a002f0edfeae`. PR110 merged bevestigd
via GitHub; feitelijk terugleesbewijs comment6764869737 gelezen. Overdrachtsbestand
SESSIONS/REGIE/20261110_SUCCESSION.md zelfstandig gelezen. Open issues30/55/104 en
PR102/107/108/109 onderzocht: andere scope; geen dubbele taak. Alle 38 sessies en 119
change-records gelezen voor passende eigen registratie, mandaten en opvolgende signalen.
RAC-signalen hebben bestaande INVESTIGATE-opvolging; geen nieuw moduleonderzoek gestart.
Andermans entries blijven exact intact.

## Ontwerp en geraakte bestanden

REGIE_HANDOFF.md motiveert twee onafhankelijke beoordelingen, bronklassen en gegevenslocatie.
Nederlandse voorgestelde waarden behouden omdat ze bestaande lifecycle-/taskstatussen niet
hergebruiken. Nieuwe informatie is optioneel HANDOVER-bewijs in CHANGE_REGISTER; geen tweede
actueel register en geen uitbreiding van current_activity. Oude entries hoeven niet gemigreerd.

| Bestanden | Wijziging |
|---|---|
| REGIE_HANDOFF.md | Procedure, geplande/noodoverdracht, bronnen, bewijsgrenzen en integriteitsregels |
| START_HERE_TETOOLS_REGIE.md, RELAY_CONTRACT.md | Herkenbare verwijzing naar PROPOSED-uitbreiding; bestaande norm behouden |
| schemas/CHANGE_REGISTER.schema.json | Optioneel strikt handoff_assessment; uitsluitend HANDOVER |
| tools/handoff_review.py | Read-only structuur-/relatiecontrole, geen voorspeller of beslisser |
| tools/test_handoff_review.py | 17 nieuwe methoden inclusief synthetische geplande/gedwongen doorloop |
| tools/validate_acceptance.py | Aanvullende handoffcontrole in bestaande schemagate |
| SESSION_REGISTRY.json | Alleen nieuwe eigen entry met echte platform-ID, KEEP, blokkades |
| CHANGE_REGISTER.json | Eén nieuw PROPOSED HANDOVER-record; geen echte regieovername |
| SESSIONS/CODEX/20261110_HANDOFF_REQUEST.md | Duurzaam bewaarde geautoriseerde opdracht |
| Dit rapport en REGIE_HANDOFF_20261110_EVIDENCE.json | Resultaten en volledige afzonderlijke foutuitvoer |

## Werkelijke controles

Python3.12.14, jsonschema **4.26.0** in aparte omgeving; geen dependencywijziging in project.
Exacte baseline onafhankelijk via git archive uit bovenstaande SHA; geen zelfvergelijking.

| Controle | Baseline | Voorstel |
|---|---|---|
| Stdlib-validator | FAIL: alleen REGIE-LOGGER-READINESS-20261109 invalid change status | Dezelfde fout, geen nieuwe |
| SESSION_REGISTRY-schema | PASS | PASS |
| CHANGE_REGISTER-schema | FAIL: records[115].status ASSESSED | Dezelfde fout, geen nieuwe |
| Volledige unittests | 18/19 PASS, één bestaande integratiefout | 35/36 PASS, dezelfde integratiefout |
| Nieuwe handofftests afzonderlijk | Niet aanwezig | 17/17 PASS |
| Read-only handoff-CLI | Niet aanwezig | PASS: één voorstelbeoordeling |
| Volledige acceptatiegate | Bestaande schemablokkade | FAIL op dezelfde ASSESSED-schemablokkade |
| Oude sessies/change-prefix | 38 sessies /119 records | Alle exact gelijk, volgorde behouden; IDs uniek |

Het bestaande integratiegeval verwacht een volledig geldige baseline, maar die faalt op
ASSESSED. Beide toegestane-statuslijsten missen deze historische waarde. Dit blokkeert
de totaalcontrole en volgens OPERATIONS.md de merge; nieuwe controles zijn afzonderlijk
uitvoerbaar. Geen historische status herschreven, schemawaarde toegevoegd of test afgezwakt.
De huidige opdracht geeft geen zelfstandig mandaat voor een inhoudelijke statuscorrectie.

De eerste lokale bewijsruns waren onvolledig door tijdelijke-maprechten en een encodingfout
in het verificatiehulpmiddel. De behoudscontrole wees gewijzigde tekens af; alle bestaande
registerinhoud is uit baseline hersteld en de volledige controle daarna opnieuw uitgevoerd.
Alleen de geslaagde laatste behoudscontrole geldt als bewijs. Geen foutieve versie gepubliceerd.

## Praktische dry-runs

De test `test_planned_and_emergency_walkthrough_preserve_input` doorloopt tweemaal
ONVOLLEDIG → VOORBEREID → GEPUBLICEERD → OVERGENOMEN met synthetische bronverwijzingen,
onderscheiden bestaande fixture-identiteiten old/new, exact commit/head, ontvangst en mandaat.
Gepland: predecessor_available=true. Gedwongen: false, zonder voorgangerontvangst te eisen;
bevoegde aanwijzing en zelfstandige opvolgerontvangst blijven verplicht. Het hulpmiddel
wijzigt de invoer niet. Negatieve tests wijzen ontbrekende ontvangst/aanwijzing, gefingeerde
prognosevelden, ongeldige datums, ontbrekende bron/head/tijdzone en zelfopvolging af.
Legacy HANDOVER zonder beoordeling blijft geldig; ONBEKEND blokkeert voorbereiding niet.
Dit zijn offline procedure-/dataproeven, geen echte opvolgeracceptatie of platformlimietmeting.

Geen Oracle/runtime, echte chatoverdracht, accountlimietmeting of centrale eindontvangst
uitgevoerd: buiten scope of afhankelijk van onafhankelijke ontvanger. Geen automatische
archivering/sluiting; beide beoordelingen veranderen lifecycle en retention nooit.

## Vereiste centrale besluiten en vervolg

1. TETOOLS__REGIE beoordeelt concrete gegevenslocatie, betekenis en bewijsvereisten als
   voorgestelde protocoluitbreiding. Deze opdracht autoriseert bouw, geen algemene
   beleidsgoedkeuring; geen PROPOSED-record tot APPROVED opgewaardeerd.
2. Laat de bevoegde centrale regie de ASSESSED-afwijking inhoudelijk beoordelen. Een
   opvolgrecord alleen maakt het ongeldige historische record niet schemageldig; expliciete
   gemotiveerde status-/contractdisposition is nodig. Geen generieke bypass toevoegen.
3. Na vervulde gates: actuele main/geraakte entries en exacte PR-head opnieuw vergelijken,
   tests herhalen voor gewijzigde basis, PR gecontroleerd mergen en alle gewijzigde bestanden
   exact vanaf main teruglezen. Pas daarna implementatie-/registratiebewijs vastleggen.
4. Bestaande centrale regie bevestigt echte ontvangst in Issue111; die wordt hier niet namens
   haar geregistreerd. Eigen branch-entry BLOCKED/KEEP met current_activity BLOCKED zolang
   publicatievoorwaarden open zijn; geen CLOSED of verwijderadvies.

PR-URL, exacte gepubliceerde head en branch-terugleesbewijs worden na werkelijke publicatie
in Issue111/PR toegevoegd. Main-publicatie blijft pending; dit rapport claimt geen toekomstig bewijs.
