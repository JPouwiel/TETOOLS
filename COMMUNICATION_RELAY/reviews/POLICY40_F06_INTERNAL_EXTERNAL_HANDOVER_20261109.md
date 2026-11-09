# Punt 40 F06 — interne acceptatie versus externe DBA-overdracht

Datum 2026-11-09. Status ANALYSIS / PROPOSED INTERPRETATION; nog niet door gebruiker goedgekeurd. Eigenaar TETOOLS__REGIE. Bron: huidige projectchat 'Laten we F06 starten'; exacte thread-URL UNVERIFIED.

## Reeds APPROVED besluiten

4: interne achtvoudige testcategoriebeoordeling met bewijs en risicogestuurde uitvoering (zie goedgekeurde F02-interpretatie). 37: risicogestuurde acceptatie en release. 38: TETOOLS intern verantwoordelijk voor architectuur, ontwikkeling, acceptatie en release; externe DBA bevoegd om installatie binnen eigen beheerbeleid te weigeren, geen ontwerpautoriteit. 39: verplichte externe overdrachtsset uitsluitend items 1,2,3,5,6,8: release-ID/versie, scripts, privileges, migratie, impact, herstel. Andere interne controles blijven intern relevant.

## Interpretatievoorstel

- Externe overdrachtsset omvat zes verplichte onderwerpen, niet automatisch alle interne bewijsdocumenten. Voor inhoudelijk niet-toepasselijke onderdelen is een gemotiveerde N/A voorgesteld, niet stilzwijgend weglaten.
- Interne test-, review-, beveiligings-, RAC- en acceptatieverplichtingen blijven onverminderd bestaan; een beperking van externe bijlagen verandert geen interne releasegate.
- Interne releaseacceptatie en externe installatieacceptatie zijn afzonderlijke besluiten door afzonderlijke bevoegde partijen. Externe DBA kan installatie weigeren conform eigen beheerbeleid; interne TETOOLS-governance kan installatie niet afdwingen.
- Een aanvullende specifieke externe vraag kan extra documentatie noodzakelijk maken voor die concrete installatie, maar verandert niet zonder expliciete goedkeuring de generieke zesdelige minimale overdrachtsnorm.
- F05 goedgekeurde voorwaardelijke vrijgave zonder bewezen RAC-readiness blijft onder centraal afwijkingsmandaat en verplicht tot zichtbare vermelding van beperkingen en ontbrekende RAC-validatie in impact/risicocommunicatie.

## Nog te besluiten

Gebruiker: akkoord met interpretatie inclusief gemotiveerde N/A en expliciete scheiding tussen interne acceptatie en externe installatie? Dit is geen technische implementatieopdracht. F06 status PROPOSED totdat expliciet goedgekeurd.

Geen Oracle-test, broncode- of frozen-releasewijziging uitgevoerd.
