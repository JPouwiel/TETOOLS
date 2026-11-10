# TETOOLS — ontwikkel en implementeer verbeterde regieoverdracht

**Project:** PLSQL_TETOOLS  
**Repository:** JPouwiel/TETOOLS  
**Opdrachtgever:** gebruiker, via huidige TETOOLS__REGIE  
**Centrale regiesessie:** `01a1c4f4-e7eb-7f51-ab89-2fe51f09bc62`  
**Overdrachtsbaseline:** PR #110, mergecommit `b7e035b00bfc115e815b52e8e388a002f0edfeae`. Lees de actuele main-versie; deze baseline kan inmiddels zijn opgevolgd.

## Doel en autorisatie

Ontwikkel en implementeer binnen COMMUNICATION_RELAY een kleine, controleerbare uitbreiding voor:

1. Tijdige voorbereiding van regieoverdracht tussen sessies.
2. Een expliciet onzekere indicatie van mogelijke sessielengteproblemen.
3. Aantoonbare overdrachtsgereedheid en behoud van context, eigenaarschap en bewijskwaliteit.

Deze gebruikersopdracht autoriseert onderzoek, ontwerp, implementatie, relevante tests en publicatie via branch/PR/merge/main-teruglezing binnen onderstaande scope. Nieuwe projectbrede architectuurbesluiten of afwijkingen van bestaand beleid vereisen afzonderlijke centrale goedkeuring. Werk daarvoor eerst een concreet voorstel uit; behandel deze opdracht niet als goedkeuring van iedere ontwerpkeuze.

Geen modulebroncode, Oracle-uitvoering, frozen releases, chatverwijdering, chatarchivering of hernoeming van chats.

## Start en sessiehergebruik

Lees op actuele main AGENTS.md, START_HERE_TETOOLS_REGIE.md, RELAY_CONTRACT.md, CURRENT_STATUS.md, SESSION_REGISTRY.json, CHANGE_REGISTER.json en de relevante handoff-, activity-, retention-, schema-, validator- en testbestanden.

Lees ook:
- COMMUNICATION_RELAY/SESSIONS/REGIE/20261110_SUCCESSION.md
- PR #110 inclusief het daadwerkelijke merge-/terugleesbewijs.

Controleer bestaande opdrachten, issues en PR’s voordat je werk begint. Hergebruik een passende bestaande uitvoeringssessie en eigen registratie. Neem de identiteit of regierol van de opdrachtgever niet over. Gebruik een echte platform-ID indien beschikbaar; markeer een eventueel lokaal gegenereerde identiteit expliciet.

Registreer deze opdracht via de bestaande relaywerkwijze. Hergebruik een passend taakissue als dat bestaat; maak anders één taakissue voor deze afgebakende opdracht. Geef geen dubbele opdrachten uit en activeer geen andere sessies zonder autorisatie.

## Functionele eisen

### A. Twee afzonderlijke beoordelingen

Onderscheid:

**Capaciteitssignaal**
- ONBEKEND
- AANDACHT
- OVERDRACHT_AANBEVOLEN
- LIMIET_BEREIKT

**Overdrachtsgereedheid**
- ONVOLLEDIG
- VOORBEREID
- GEPUBLICEERD
- OVERGENOMEN

Dit zijn voorgestelde begrippen. Controleer hun aansluiting op bestaande conventies en motiveer eventuele aanpassingen.

Leg per beoordeling minimaal de betekenis, onderbouwing, beoordelingsdatum en beoordelende sessie vast. Maak onderscheid tussen platformmelding, meting, gebruikersmelding en heuristische inschatting.

Geen verzonnen resterende tokens, percentages, aantallen berichten of einddatum. ONBEKEND is een geldige uitkomst. Een heuristiek is geen platformgarantie. Onderscheid ChatGPT-gesprekslimieten, modelcontext en Codex-contextcompressie; verifieer relevante productclaims met actuele officiële documentatie.

Importeer geen inhoud uit het andere project of de chat __AI_MEAUK. Een specifieke methode daaruit geldt niet als geverifieerde projectbron.

### B. Overdrachtsprocedure

Beschrijf en ondersteun:

1. Vastlegging na belangrijke besluiten en afgeronde opdrachten.
2. Beoordeling bij hervatting, faseovergangen en omvangrijke werkzaamheden.
3. Vroege voorbereiding van een compacte, kopieerbare hervattingsinstructie.
4. Publicatie van het overdrachtspakket via de bestaande GitHub-werkwijze.
5. Zelfstandige broncontrole en expliciete ontvangst door de opvolger.
6. Een traceerbaar overdrachtsmoment van centrale verantwoordelijkheid.
7. Een noodroute wanneer de voorganger niet meer kan reageren.

Geen achtergrondbewaking, automatische chatsynchronisatie of automatische activering suggereren.

### C. Integriteitswaarborgen

Borg expliciet:

- Platform-ID is de blijvende identiteit; titel is een herkenningslabel.
- Hernoemen, app-archivering, relay-lifecycle en bewaarbeoordeling blijven afzonderlijk.
- Eén aangewezen centrale regie; heropening van een voorganger herstelt diens regiebevoegdheid niet automatisch.
- Lopende uitvoerders behouden opdrachten en eigenaarschap; geen automatische annulering of herstart.
- Overdracht bevat scope, bevoegdheden, open opdrachten, eigenaren, goedkeuringen, blokkades, resultaatlocaties en eerstvolgende acties.
- Controleerbare peildatum, commits en PR-heads; controleer veranderingen tijdens de overdracht.
- Scheiding tussen voorstellen, gebruikersgoedkeuringen, formele registratie en geverifieerde publicatie.
- Essentiële bijlagen duurzaam bereikbaar; chatgebonden downloadlinks alleen zijn onvoldoende.
- Regieovername bewijst geen volledige historische archivering.
- Onzekerheid of ontbrekende context blijft zichtbaar; geen automatische CLOSED- of verwijderbaarstatus.

## Implementatiegrenzen

Gebruik bestaande canonieke registers en hulpmiddelen. Vermijd een tweede actuele administratie, nieuwe dienst of dashboard.

Wijzig de bestaande betekenis en toegestane structuur van current_activity niet stilzwijgend. Motiveer waar de nieuwe informatie wordt opgeslagen en houd bestaande registraties achterwaarts compatibel.

Wijzig andermans sessie-entry uitsluitend met aantoonbare machtiging. Bewaar bestaande change-records en besluitgeschiedenis.

Onderzoek de bekende ASSESSED-afwijking tussen CHANGE_REGISTER en validator/schema. Rapporteer of deze de nieuwe controles blokkeert. Herschrijf historische statussen niet stilzwijgend en verruim toegestane waarden niet uitsluitend om controles groen te krijgen. Een inhoudelijke status-/contractcorrectie vraagt een afzonderlijk gemotiveerd centraal besluit.

## Verificatie en oplevering

Lever:

- Een gemotiveerd ontwerp en overzicht van geraakte bestanden.
- Geïmplementeerde protocol-, voorbeeld-, schema- en hulpmiddelwijzigingen waar nodig.
- Betekenisvolle tests voor onder andere onbekende capaciteit, ongefundeerde schattingen, oude entries zonder nieuwe gegevens, ontbrekende ontvangst en onverwachte uitval van de voorganger.
- Vergelijking van baseline- en voorstelvalidatie; bestaande en nieuwe fouten afzonderlijk.
- Bewijs dat bestaande sessies, besluiten en frozen releases behouden blijven.
- Een praktische doorloop van geplande én gedwongen overdracht, zonder echte chats te sluiten of te verwijderen.

Publiceer via gecontroleerde branch en PR. Controleer vóór merge de actuele main, geraakte entries en exacte PR-head. Merge uitsluitend wanneer vereiste goedkeuringen en controles aantoonbaar zijn vervuld. Lees na merge alle gewijzigde bestanden exact terug op main.

Rapporteer geverifieerde resultaten, niet-uitgevoerde controles met reden, open afhankelijkheden en vereiste besluiten. Bij blokkade: lever een concreet reviewbaar voorstel op en claim geen implementatie op main.

Werk eigen sessie- en taakregistratie bij. Lever een kopieerbare eindterugmelding voor TETOOLS__REGIE met issue, PR, commits, verificatiebewijs, beperkingen en resterende acties. Claim geen ontvangst door de centrale regie voordat die bevestigd is.