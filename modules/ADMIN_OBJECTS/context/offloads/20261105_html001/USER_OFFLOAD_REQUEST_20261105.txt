# TETOOLS — Universele sessie-offload naar GitHub

**Project:** PL/SQL TETOOLS  
**Repository:** `JPouwiel/TETOOLS`  
**Doel:** alle relevante, nog niet veiliggestelde informatie uit deze sessie duurzaam overdragen aan GitHub, zodat deze ChatGPT-sessie na verificatie eventueel kan worden verwijderd.

## 1. Identificatie en projectprotocol

Identificeer de eigen sessie, module, rol en werkzaamheden aan de hand van de gespreksinhoud.

Lees eerst de actuele bestanden:

- `COMMUNICATION_RELAY/START_HERE_TETOOLS_REGIE.md`
- `COMMUNICATION_RELAY/RELAY_CONTRACT.md`
- `COMMUNICATION_RELAY/CURRENT_STATUS.md`
- `COMMUNICATION_RELAY/SESSION_REGISTRY.json`
- `COMMUNICATION_RELAY/CHANGE_REGISTER.json`
- De relevante modulebestanden en eventueel `AGENTS.md`.

Volg de bestaande projectgovernance. Het geldende relay-contract en modulespecifieke voorschriften hebben voorrang.

Als deze sessie nog niet geregistreerd is, maak uitsluitend een correcte, herleidbare registratie volgens het relay-contract. Verzin geen ChatGPT-thread-ID.

## 2. Inhoudelijke inventarisatie

Controleer de volledige beschikbare gespreksinhoud en relevante bijlagen.

Inventariseer:

- Oorspronkelijke doelstellingen, eisen en randvoorwaarden.
- Goedgekeurde besluiten en afgewezen voorstellen.
- Technische analyses, bevindingen en onderbouwingen.
- Broncode, scripts, tests en opgeleverde documenten.
- Versies, revisies, datums en hun onderlinge relaties.
- Openstaande werkzaamheden, bugs en afhankelijkheden.
- Nog niet gepubliceerde informatie die nodig is voor voortzetting van de ontwikkeling.

Maak expliciet onderscheid tussen:

**GEVERIFIEERD**, **GOEDGEKEURD**, **VOORGESTELD**, **VERWORPEN** en **ONBEKEND**.

Presenteer aannames nooit als feiten.

## 3. Vergelijking met GitHub

Controleer welke informatie al aanwezig is in de repository.

Voorkom dubbele publicaties en tegenstrijdige versies.

Gebruik de bestaande module-indeling en registers. Bepaal de juiste opslaglocatie op basis van het type informatie en de geldende repositoryconventies.

Behoud oorspronkelijke versienummers, revisies en datums. Gebruik de huidige datum uitsluitend voor nieuwe overdrachtsregistraties.

Overschrijf geen historische bronbestanden, eerdere besluiten of bevroren releases.

Leg relaties tussen oorspronkelijke bronnen, revisies, opvolgende versies en relevante GitHub-issues vast.

## 4. Publicatie

Publiceer uitsluitend ontbrekende of noodzakelijke aanvullingen.

Volg de voorgeschreven GitHub-workflow:

1. Maak een toepasselijke branch.
2. Voeg informatie toe aan de bestaande, juiste module- of relay-bestanden.
3. Registreer relevante besluiten, wijzigingen en open punten.
4. Maak een pull request met een controleerbare omschrijving.
5. Controleer de wijzigingen op juistheid, volledigheid en modulescope.
6. Merge uitsluitend wanneer de geldende bevoegdheden en vereiste goedkeuringen dat toestaan.
7. Lees na de merge de gepubliceerde bestanden opnieuw vanaf `main`.

Vraag alleen mijn tussenkomst wanneer een noodzakelijke bevoegdheid, inhoudelijke beslissing of technische toegang ontbreekt.

**Voer geen nieuwe inhoudelijke ontwikkelwijzigingen uit.** Deze opdracht betreft uitsluitend inventarisatie, documentatie, behoud van bestaande resultaten en overdracht.

## 5. Overdracht en bewaarbeoordeling

Controleer of de sessie na publicatie nog unieke informatie bevat die niet in GitHub is veiliggesteld.

Leg eventuele resterende afhankelijkheden vast bij de juiste module of centrale regie.

Beoordeel vervolgens de bewaarbehoefte van deze chat volgens `RELAY_CONTRACT.md`:

- `KEEP` — deze chat moet voorlopig behouden blijven.
- `REVIEW` — aanvullende verificatie of overdracht noodzakelijk.
- `ELIGIBLE_FOR_DELETION` — alle noodzakelijke context is aantoonbaar veiliggesteld en de chat is niet meer nodig voor lopende werkzaamheden.

Een openstaand ontwikkelpunt betekent niet automatisch dat de oorspronkelijke chat behouden moet blijven, mits de overdracht volledig en verifieerbaar is.

Wijzig de bewaarbeoordeling alleen op basis van controleerbaar bewijs.

Verwijder de ChatGPT-chat niet zelf.

## 6. Eindrapportage

Geef uitsluitend een beknopt overzicht met:

| Onderdeel | Resultaat |
|---|---|
| Sessie | Naam, module en geverifieerde identificatie |
| Offload | Volledig / Gedeeltelijk / Niet uitgevoerd |
| GitHub | PR, mergecommit en belangrijkste opslaglocaties |
| Versiebehoud | Gecontroleerd / Niet gecontroleerd |
| Openstaande punten | Aantal en korte omschrijving |
| Bewaarstatus | KEEP / REVIEW / ELIGIBLE_FOR_DELETION |
| Chat verwijderen | JA / NEE / NOG NIET |

Vermeld bij `NEE` of `NOG NIET` maximaal drie concrete blokkades.

**Acceptatiecriterium:** een succesvolle offload vereist dat de relevante informatie daadwerkelijk op GitHub `main` staat, correct is geordend, historische versies behouden zijn en de publicatie is teruggelezen.

Claim geen geslaagde publicatie, merge, verificatie of verwijderbaarheid zonder bewijs.

Werk zelfstandig en rond alle uitvoerbare stappen af zonder tussentijdse bevestigingsvragen.