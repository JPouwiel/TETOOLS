# TETOOLS — opdrachten, terugkoppeling en overdracht

Werkwijze volgens [Issue #119](https://github.com/JPouwiel/TETOOLS/issues/119). Voor de oorspronkelijke handmatige overdrachtsprocedure van 4 november 2026, zie [de vorige versie](https://github.com/JPouwiel/TETOOLS/blob/cfde9e92cb0f18ac227df3833760cc12090b6835/COMMUNICATION_RELAY/MANUAL_HANDOFF.md). Bestaande overdrachts-ID’s en verwijzingen blijven bruikbaar.

## Eén taakissue

Gebruik een bestaand issue voor dezelfde opdracht. Maak alleen voor een nieuwe afgebakende opdracht een issue. Vermeld:

- Planreferentie en mijlpaal, eigenaar en ontvangende sessierol.
- Gevraagde actie, bevoegdheid, bronversie, scope en afhankelijkheden.
- Verwacht resultaat, toetsbare succescriteria, bewijs en controles.
- Stoppunt en eventuele opvolger. Benoem het einde van een taakreeks.

De ontvanger leest het issue en de relevante bronnen, controleert mandaat en startvoorwaarden, en bevestigt ontvangst op het issue. Bij een voorganger binnen dezelfde mijlpaal volstaat diens gereedmelding als die de benodigde versie, criteria en controles aantoont. Zie het [relaycontract](RELAY_CONTRACT.md).

## Korte berichten

Vul de verwijzingen in. Regie stuurt het bericht rechtstreeks naar de bestaande sessie wanneer die bereikbaar is en de gebruiker daarvoor autorisatie heeft gegeven. Anders is hetzelfde bericht kopieerbaar. Een chatbericht verwijst naar het issue, waar het werk en bewijs staan.

**Opdracht**  
Lees [taakissue]. Voer [actie] uit als [rol] binnen de scope en stop bij het afgesproken criterium.

**Terugkoppeling**  
Beoordeel [resultaat of PR met versie] bij [taakissue]. Leg [beslispunt] daar vast.

**Gereedmelding en overdracht**  
[Taakissue]: [gereed, wachtend of geblokkeerd]. Resultaat [link], criteria en controles [bewijs], restwerk [eigenaar en link].

## Resultaat en afmelding

De uitvoerder plaatst de inhoudelijke terugkoppeling en afmelding op het bestaande taakissue. Meld per criterium de uitkomst, bewijs en bronversie, plus afwijkingen en restwerk. Reviewcommentaar over code kan op de PR staan met een verwijzing vanuit het taakissue. De ontvanger bevestigt eigenaarschap van overgedragen restwerk op het issue. Leg bij sessieafmelding ook de eigen lifecycle, bewaring en bewijsverwijzingen vast in SESSION_REGISTRY volgens het relaycontract. Gebruik [REGIE_HANDOFF.md](REGIE_HANDOFF.md) voor opvolging van de centrale regie.

## Wanneer de overdracht hapert

Leg een onbereikbare of onbevestigde ontvanger vast als TARGET_SESSION_UNAVAILABLE of TARGET_SESSION_UNVERIFIED. Kies een bestaande geschikte ontvanger of laat de taak wachten. Als GitHub onbereikbaar is, bewaar het concrete pakket met ISSUE_NOT_CREATED of BLOCKED en publiceer zodra toegang beschikbaar is. Een onvoltooide overdracht blijft open. Het doorgeven van een bericht draagt geen extra mandaat over. Onderzoek naar automatische activering staat apart bij Issue #119.
