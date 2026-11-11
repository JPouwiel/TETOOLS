# Regieoverdracht — centraal beoordeelde revisie 002

Taak [#111](https://github.com/JPouwiel/TETOOLS/issues/111). Centrale inhoudelijke goedkeuring
onder voorwaarden A1/A2/A3 en contractcorrectie B: [besluit6769485682](https://github.com/JPouwiel/TETOOLS/issues/111#issuecomment-6769485682).
Deze revisie voert die voorwaarden uit. Normatief na gecontroleerde merge en exacte
main-teruglezing; feitelijk publicatiebewijs wordt achteraf in PR112/Issue111 vastgelegd.
De vroegere PROPOSED-registratie en revisie001 blijven historisch bewijs, geen actuele norm.
RELAY_CONTRACT, MANUAL_HANDOFF en OPERATIONS blijven voor hun overige scope leidend.

## Ontwerp en gegevenslocatie

Gebruik een optioneel `handoff_assessment` in een nieuw `HANDOVER`-record van het bestaande
CHANGE_REGISTER. Geen tweede actuele administratie: een nieuw oordeel is een opvolgrecord
met `supersedes`, nooit een overschreven eerdere beoordeling. Lees opvolging in bronvolgorde,
per overdracht/onderwerp; een nieuwe beoordeling van een andere overdracht vervangt niets.
Recordstatus PROPOSED/APPROVED/etc. houdt zijn bestaande betekenis en is onafhankelijk van
de twee beoordelingen. Voorstellen zijn geen benoeming of bewijs van publicatie.

Motivatie: dit is gedateerd bewijs van een overdracht, geen actuele uitvoeringsopdracht.
SESSION_REGISTRY en zijn schema blijven functioneel gelijk; `current_activity` blijft exact
task_reference/summary/state. De uitbreiding bewaart legacy HANDOVER-records zonder gegevens.
Het CHANGE_REGISTER-schema controleert alleen nieuwe optionele gegevens. Het read-only
hulpmiddel controleert relaties met geregistreerde actoren; geen nieuwe dienst/dashboard.
De statische voorbeeldgegevens staan in tools/test_handoff_review.py en zijn geen echte sessies.

## Twee onafhankelijke beoordelingen

| Capaciteit | Betekenis |
|---|---|
| ONBEKEND | Geen onderbouwde uitspraak over resterende gespreksruimte. Geldige standaard. |
| AANDACHT | Concreet signaal vraagt extra contextvastlegging; geen limietprognose. |
| OVERDRACHT_AANBEVOLEN | Beoordelaar adviseert overdracht met bron en reden; geen platformgarantie. |
| LIMIET_BEREIKT | Expliciete platformmelding of als zodanig herkenbare gebruikersmelding; geen heuristische gevolgtrekking. |

| Gereedheid | Vereist bewijs |
|---|---|
| ONVOLLEDIG | Hiaten/blokkades benoemd, geen gereedheidsclaim. |
| VOORBEREID | Compact hervattingspakket duurzaam op branch beschikbaar; essentiële bronnen bereikbaar. |
| GEPUBLICEERD | Pakket op main, exact gecontroleerde PR-head, mergecommit en werkelijke terugleesverwijzing. Ontvangst mag nog ontbreken. |
| OVERGENOMEN | Tevens zelfstandige broncontrole en expliciete ontvangst opvolger plus bevoegde aanwijzing en exact overdrachtsmoment met tijdzone. |

Elk nieuw capaciteitsoordeel bevat tevens strikt `limit_kind`: GESPREK, ABONNEMENT,
CONTEXT of ONBEKEND. LIMIET_BEREIKT betekent uitsluitend een gesprekslimiet: GESPREK
met expliciete platform-/gebruikersbron. ABONNEMENT en CONTEXT mogen uitsluitend ONBEKEND
of AANDACHT verklaren: een quotaonderbreking of compactie alleen bewijst geen volle chat en
rechtvaardigt zelfstandig geen OVERDRACHT_AANBEVOLEN. Herstart na quotaherstel kan in dezelfde
sessie; er wordt geen quota, resetmoment of resterende gesprekstijd voorspeld.
Voor behoud van het oorspronkelijke onveranderde PROPOSED-record zijn oudere beoordelingen
zonder limit_kind uitsluitend geldig bij state=ONBEKEND én evidence_kind=ONBEKEND; er wordt
geen waarschuwing uit afgeleid. Nieuwe beoordelingen schrijven het veld altijd expliciet.

Elk oordeel bevat `state`, `meaning`, `rationale`, `assessed_at` (YYYY-MM-DD), `assessed_by`
(geregistreerde sessie), `evidence_kind` en `evidence_refs`. Bronsoorten: PLATFORMMELDING,
METING, GEBRUIKERSMELDING, HEURISTIEK, ONBEKEND. Een meting noemt methode, datum, bereik
en beperkingen in de onderbouwing/bron; geen extrapolatie naar resterende capaciteit.
Een gebruikersmelding wordt niet opgewaardeerd tot zelf waargenomen platformbewijs.
HEURISTIEK noemt concreet waargenomen verschijnsel en onzekerheid; geen vaste berichtdrempel.
Gereedheid voegt package_ref en optionele publication, receipt, transfer toe (zie schema).
De datum is een momentopname, geen heartbeat, houdbaarheidsduur of achtergrondbewaking.

Geen resterende tokens, percentages, berichtaantallen of einddatums voorspellen. De strikte
structuur biedt daarvoor geen velden. Menselijke bronreview blijft vereist: validators kunnen
ongefundeerde claims in vrije tekst of onjuiste bronverwijzingen niet waarheidsgetrouw toetsen.
Een technisch geldig object bewijst geen ontvangst, toestemming of actuele GitHub-publicatie.

## Productclaims en onzekerheid — geraadpleegd 10 november 2026

De [officiële Codex App Server-documentatie](https://learn.chatgpt.com/docs/app-server)
beschrijft een contextCompaction-gebeurtenis binnen dezelfde thread. Dat is geen overdracht
van verantwoordelijkheid en geen bewijs van een bereikte ChatGPT-gesprekslimiet.
De [officiële API-documentatie](https://developers.openai.com/api/docs/guides/compaction)
beschrijft compactie van context. Een modelcontextvenster betreft beschikbare invoercontext;
het biedt geen betrouwbare teller van resterende ChatGPT-gespreksruimte. API-instellingen
zijn niet zonder meer ChatGPT-producteigenschappen. De geraadpleegde bronnen geven geen
betrouwbare algemene voorspeller van het einde van deze chat: capaciteit blijft ONBEKEND.
Een concrete ChatGPT-limietmelding wordt alleen vastgelegd met haar werkelijke bron;
geen universeel maximum afleiden uit modelcontext, compacties of chatlengte.
De [officiële gebruiksdocumentatie](https://learn.chatgpt.com/docs/pricing) beschrijft
abonnementsgebruik; dit geeft geen resterende gesprekslengte aan. Een gebruikersmelding
van een abonnementslimiet is bewijssoort GEBRUIKERSMELDING, limit_kind ABONNEMENT,
hoogstens AANDACHT. De bron wordt niet omgezet in een zelf waargenomen platformmelding.

## Werkwijze bij geplande overdracht

1. Leg na belangrijke besluiten en afgeronde opdrachten resultaat, originele bronnen,
   goedkeuring, tests en resterende eigenaar vast in de canonieke registers. Herbeoordeel
   bij hervatting, faseovergang en vóór omvangrijk werk; werk geen andere sessies stilzwijgend bij.
2. Bereid vroeg in hetzelfde taakissue één compacte kopieerbare hervattingsinstructie voor.
   Verwijs naar een gedateerd pakket onder SESSIONS/REGIE met scope, mandaat, één aangewezen
   centrale regie, open opdrachten met eigenaren, goedkeuringen, blockers, resultaatlocaties,
   eerstvolgende acties en expliciete contextgaten. Essentiële bijlagen in duurzame repo-opslag;
   uitsluitend chat-downloadlinks zijn onvoldoende. Benoem welke bronnen niet zijn bewaard.
3. Noteer peildatum met tijdzone, main-SHA en exacte heads van relevante open PR's. Publiceer
   pakket/oordeel via branch/PR. Controleer vóór merge main, geraakte entries en exacte PR-head;
   bij verandering opnieuw vergelijken en toetsen. Na merge alle gewijzigde bestanden exact
   teruglezen. Voeg daarna pas opvolgend publicatiebewijs toe. Geen circulaire eigen-commitclaim.
4. Opvolger leest issue, main en bronnen zelfstandig en vergelijkt veranderingen sinds peildatum
   (main en relevante PR-heads). Leg veranderingen/ontbrekende stukken vast; bij materiële
   hiaten geen OVERGENOMEN. Opvolger bevestigt met eigen blijvende identiteit ontvangst,
   gelezen commit/PR-heads, begrepen scope, resterende eigenaren en contextbeperkingen.
   Ook het effectieve overdrachtsmoment moet op of vóór de beoordelingsdatum vallen,
   vergeleken als kalenderdatum in de expliciete tijdzone van effective_at. Een toekomstig
   aanwijzingsmoment mag onder GEPUBLICEERD worden vastgelegd, nog niet als OVERGENOMEN.
5. Bevoegde gebruiker/centrale regie wijst één opvolger aan; registreer bron van mandaat en
   overdrachtsmoment met tijdzone in een opvolgend HANDOVER-record. Vanaf dat moment bezit
   die opvolger de centrale verantwoordelijkheid. Twee historische ACTIVE-entries bewijzen
   geen dubbel mandaat; de expliciete aanwijzing en opvolgingshistorie zijn leidend.
6. Lopende uitvoerders houden hun opdracht en eigenaarschap. Geen automatische annulering,
   herstart of nieuwe opdracht. Een heropende voorganger krijgt geen regiebevoegdheid terug
   zonder nieuwe expliciete aanwijzing. Lees vóór verdere uitvoering het actuele mandaat.

## Noodroute bij uitval voorganger

Wacht niet op een onmogelijke voorgangerbevestiging. De bevoegde gebruiker wijst een bestaande
geschikte opvolger aan; leg de bron en waargenomen onbereikbaarheid vast zonder succesvolle
afronding of lifecyclewijziging te claimen. Opvolger reconstrueert uit actuele main, taakissues,
PR's en duurzame resultaten; vergelijkt nieuwe commits/heads, noemt ontbrekende context en
houdt onzekere besluiten/open opdrachten open. Onafhankelijke opvolgerontvangst, expliciet
mandaat en overdrachtsmoment blijven vereist voor OVERGENOMEN. Zonder die bronnen blijft
gereedheid ONVOLLEDIG/VOORBEREID/GEPUBLICEERD volgens werkelijk bewijs. Bij GitHub-uitval:
BLOCKED/NOT_REGISTERED volgens bestaand contract en een concreet kopieerbaar pakket;
geen fictieve publicatie of proxy-ontvangst. KEEP bij onzekerheid; geen automatische CLOSED.

Platform-ID blijft identiteit; titel is alleen herkenningslabel. App-hernoemen/archivering,
relay-lifecycle en retention blijven afzonderlijk en worden hier niet uitgevoerd. Overname
bewijst geen volledige historische archivering. Een opvolger mag eigen ontbrekende kennis
niet als afgehandeld besluit vastleggen. Geen automatische notificatie, chatsynchronisatie,
achtergrondmonitor of automatische activering. Regie verwijst met een kort bericht naar het taakissue. Ontvangst en afmelding worden daar vastgelegd volgens [MANUAL_HANDOFF.md](MANUAL_HANDOFF.md).

## Uitvoering en toetsing

Vanaf repositoryroot:

```sh
python COMMUNICATION_RELAY/tools/handoff_review.py
python -m unittest discover -s COMMUNICATION_RELAY/tools -p 'test_handoff_review.py' -v
python COMMUNICATION_RELAY/tools/validate_acceptance.py --baseline-ledger baseline.json
```

Gebruik de voorgeschreven aparte Python-omgeving met jsonschema==4.26.0 voor de schemagate.
baseline.json moet rechtstreeks uit de gelezen main-SHA komen. Een groene aanvullende
handoffcontrole maakt de bestaande totaalvalidator niet groen. Stop merge bij FAIL conform
OPERATIONS. De centraal goedgekeurde correctie B staat ASSESSED uitsluitend voor REVIEW
toe; de oorspronkelijke historie blijft gelijk. Andere recordtypes/ongekende statussen
blijven ongeldig. Zie reports/REGIE_HANDOFF_20261110_REV002.md voor actuele controles;
reports/REGIE_HANDOFF_20261110.md blijft het oorspronkelijke FAIL-rapport.
