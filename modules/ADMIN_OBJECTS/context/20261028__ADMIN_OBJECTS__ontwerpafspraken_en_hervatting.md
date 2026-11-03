# ADMIN_OBJECTS — ontwerpafspraken en hervatting

Vastgelegd: 28 oktober 2026. Scope: Oracle RDBMS 19c.
Status: functionele ontwerpverkenning; geen implementatieopdracht.

## Afsluiting

De gebruiker heeft gevraagd deze chat af te ronden en op te slaan omdat hij afsluit. Dit document bewaart de ontwerpafspraken en open punten voor hervatting. Het is geen letterlijke export van de volledige chat. Er zijn geen bronbestanden gewijzigd, geen databasewijzigingen uitgevoerd en geen nieuwe Oracle-tests uitgevoerd.

## Projectgrenzen

- Zonder expliciete toestemming geen context, bestanden, afspraken of resultaten tussen verschillende projecten mengen.
- ADMIN_OBJECTS blijft het onderwerp van deze chat.
- ADMIN_MONITOR is volgens de gebruiker nog niet aangeleverd voor analyse binnen dit project. Een afzonderlijke chat en upload moeten nog volgen. Niet beweren dat die module al is geanalyseerd.
- Details van monitoring-query's dienen alleen als context voor de registratieverantwoordelijkheid van ADMIN_OBJECTS. De inhoudelijke monitoringwerking hoort bij ADMIN_MONITOR.
- Alle bestanden onder sources/ zijn uitsluitend referentiemateriaal en blijven ongewijzigd.

## Bestaande analyse

Bron ADMIN_OBJECTS: ADMIN_OBJECTS.zip, oorspronkelijke locatie C:/Users/jeroen/Downloads/ADMIN_OBJECTS.zip.
Belangrijkste bronversies: BODY20261012_001, SPEC20261008_001, DDL20261001_003.

Rapporten van 14 oktober 2026, relatief aan dit document:

- [Analyse](ADMIN_OBJECTS_20261014/01_analysis.html)
- [Verdieping](ADMIN_OBJECTS_20261014/02_detail.html)
- [Oplossingen en ontwikkelconcept](ADMIN_OBJECTS_20261014/03_solutions.html)
- [Rapportenset ZIP](ADMIN_OBJECTS_20261014_reportset.zip)
- [Bronmanifest](ADMIN_OBJECTS_20261014/manifest.json)
- [Verificatiestatus](ADMIN_OBJECTS_20261014/validation.json)

De rapportenset bevat 26 bevindingen. Bronregels, koppelingen en browserfuncties zijn gecontroleerd. Oracle-compilatie en uitvoering zijn niet uitgevoerd. De codeconcepten zijn geen geïnstalleerde vervanging.

Let op: de verdere uitleg van de gebruiker in deze chat verfijnt de statusbetekenissen en het gewenste ontwerp. De rapporten van 14 oktober zijn hierop nog niet herzien. Een eerdere algemene refactoringaanbeveling is niet automatisch een definitief besluit: voortbouwen op de bestaande ledger is nu het uitgangspunt voor verdere ontwerpuitwerking.

## Doel en verantwoordelijkheden

ADMIN_OBJECTS inventariseert fysieke objecten binnen het afgesproken schema/eigendom en de naamgevingsscope. Modules en aanverwante componenten registreren hun benodigde objecten, privileges, afhankelijkheden en lifecycle-/versie-informatie.

De catalogus moet ook kunnen rapporteren over:

- bestaande, niet of onvolledig geregistreerde objecten;
- geregistreerde objecten die ontbreken;
- objecten die aantoonbaar afwijken;
- toepasbaarheid bij de geïnstalleerde module- en databaseversies;
- benodigde beheerbeoordeling en blokkades voor uitvoering.

Afgeleide informatie mag geen uitvoering mogelijk maken. Ontbrekende eigenschappen blijven onbekend; de inventarisatie verzint geen goedgekeurde lifecycleinformatie.

## Registratie en inventarisatie

Registraties worden doorgaans door een beheerder geladen via installatiescripts. Een onvolledige installatie-aanlevering met ontbrekende verplichte lifecycleinformatie of vereiste beheer-/verwijderstatements wordt afgewezen en niet gedeeltelijk als componentregistratie opgeslagen.

De laadactie en afwijzingsreden worden wel gelogd. Een modulespecifieke applicatielog is een mogelijke bestemming; gebruik het gedeelde loggingmechanisme. De concrete bestemming is nog niet besloten.

Periodieke inventarisatie ontdekt onder meer niet correct opgeruimde of geregistreerde objecten en rapporteert die voor beheerafhandeling. Een onvolledige inventarisatiebevinding mag als PENDING worden opgenomen en later worden aangevuld en beoordeeld. Dit is een andere route dan het accepteren van een onvolledig installatiepakket.

Acceptatiecriteria kunnen verschillen per componentsoort, onderwerp of categorie. De concrete regels en eventuele geldige 'niet van toepassing'-verklaringen zijn nog niet vastgesteld. Er is dus geen algemene uitzondering toegestaan voor ontbrekende verplichte statements.

## Componenten en versies

- Per module bestaat één geïnstalleerde versie; moduleversies bestaan niet naast elkaar.
- Of meerdere versies van fysieke objecten zoals tabellen naast elkaar mogen bestaan, staat open. Namespace-, naamgevings- en migratie-impact zijn nog niet geanalyseerd. Geen versiegebonden objectnamen als besloten ontwerp presenteren.
- Monitoring-queryversies kunnen wel naast elkaar bestaan.
- Module-, database-, query- en logtabelversies hebben eigen betekenis en toepassingsbereiken.
- De geselecteerde CURRENT-versie hoeft niet de hoogste versie te zijn.

Gebruikersvoorbeeld: module 25.07 en database 19.32 passen bij modulebereik 21–27 en databasebereik 19.01–21.03. Bij databasebereik 12.01–19.20 mag dezelfde query niet draaien. Dit zijn functionele voorbeelden van de gebruiker, geen geverifieerde geïnstalleerde Oracle-versies.

Monitoringcontext, uitsluitend ter toelichting: een definitie kan statements bevatten voor monitoring, logtabelcreatie, consolidatie, retentie, registratie en gecontroleerde verwijdering. De inhoudelijke uitwerking blijft bij ADMIN_MONITOR.

## Betekenis OBJECT_STATUS volgens de gebruiker

| Status | Betekenis |
|---|---|
| ACTIVE | Bruikbaar binnen de voorwaarden, maar niet de gekozen/in gebruik zijnde versie. |
| CURRENT | De versie die actief in gebruik is; niet noodzakelijk de hoogste versie. |
| INACTIVE | Expliciet buiten gebruik gesteld, bijvoorbeeld vanwege een bug; mag niet meer draaien. |
| FUTURE RELEASE | Vereist nieuwere module-/databaseversies. ADMIN_OBJECTS mag dit automatisch vaststellen en rapporteren. |
| DEPRECATED | Te oud/achterhaald voor de huidige module-/databaseversies. ADMIN_OBJECTS mag dit automatisch vaststellen en rapporteren. |
| PENDING | Door inventarisatie gevonden registratie die verwerkt en beoordeeld moet worden. |
| ERROR | Fouttoestand, bijvoorbeeld ontbrekende vereiste objecten of Oracle INVALID. Kan door ADMIN_OBJECTS of beheerder worden gezet; wordt gerapporteerd. |

Deze betekenissen vervangen eerdere onjuiste interpretaties waarin INACTIVE uitsluitend 'boven maximumversie' betekende. De bestaande versievalidatielogica moet later aan dit functionele contract worden getoetst.

## Laatste voorstel van de gebruiker: evaluatiestatus

De gebruiker stelt voor OBJECT_STATUS te behouden en EVALUATION_STATUS plus de relevante vorige evaluatiestatus te beperken tot:

- ACCEPTED
- REJECTED
- PENDING

Dit geeft de beheerder een veto ongeacht OBJECT_STATUS. De assistent heeft dit als heldere ontwerprichting onderschreven. De bijbehorende DDL-constraints en code zijn nog niet aangepast.

Conceptuele uitvoeringsregel uit de laatste reactie:

- CURRENT + ACCEPTED: uitvoering toegestaan zolang de voorwaarden gelden.
- CURRENT + PENDING/REJECTED: uitvoering geblokkeerd.
- Andere OBJECT_STATUS: niet geselecteerd/toegestaan voor uitvoering.
- ACCEPTED maakt ACTIVE niet automatisch CURRENT en heft ERROR/INACTIVE/ongeschiktheid niet op.

CURRENT als 'aangewezen voor gebruik', ook tussen periodieke uitvoeringen, is de interpretatie van de assistent en verdient bevestiging in het functionele ontwerp. Gebruikstelemetrie is geen bewezen bestaande voorziening.

## Inventarisatie, wijzigingen en evaluatie

De gebruiker bepaalt:

- Bestaande beoordeelde registraties worden opnieuw getoetst, ook als ze CURRENT zijn.
- Bij een relevante wijziging, zoals een bijgewerkte versie of een ontbrekend object, gaat EVALUATION_STATUS naar PENDING.
- Een registratie waarvan EVALUATION_STATUS al PENDING is, wordt in volgende inventarisatierondes niet opnieuw ter overweging meegenomen.
- Hierdoor kan tijdelijk geen CURRENT én uitvoerbare query bestaan. Dit is een geaccepteerde uitkomst.

De laatste assistentreactie stelt aanvullend voor, nog niet afzonderlijk door de gebruiker bevestigd:

- PENDING overslaan voor heroverweging, maar fysieke waarnemingen en rapportage actueel houden zonder de open beoordeling te overschrijven.
- Geen automatische vervangende CURRENT-versie kiezen om continuïteit te forceren.
- REJECTED niet door een gewone inventarisatie opheffen; heropening vereist een expliciete aanleiding/handeling.
- Een expliciete INACTIVE-beslissing wegens een bug niet opheffen uitsluitend omdat versiebereiken passen.

## Herevaluatie en geschiedenis

De gebruiker accepteert dat de ledger slechts de laatste evaluatie-/herevaluatiegegevens bewaart. Bij volgende herevaluaties schuiven de gegevens door. Volledige historie hoeft niet in de ledger of een aparte historietabel te staan.

De logging bewaart verdere historie zolang die niet geschoond is. Na schoning mag de oorspronkelijke aanleiding niet meer volledig herleidbaar zijn. Voor de reden achter een status kan in de relevante logtabel worden gekeken.

De exacte veldmutaties voor EVALUATED_*, REEVALUATED_*, PRIOR_EVALUATION_STATUS en de vlag REEVALUATED moeten nog in de overgangsmatrix worden vastgelegd. Geen afgewerkte technische semantiek voor die velden veronderstellen.

## Open punten voor hervatting

1. Maak een overgangsmatrix voor OBJECT_STATUS en EVALUATION_STATUS: aanleiding, voorwaarden, bevoegde actor, resultaat, blokkade, herevaluatievelden en logging.
2. Definieer welke wijzigingen beoordeling ongeldig maken. Specifiek: vereist iedere module-/database-update PENDING, of alleen een wijziging die de beoordeelde voorwaarden raakt?
3. Bevestig of inventarisatie waarnemingen van PENDING-registraties mag blijven actualiseren, terwijl de beoordeling wordt overgeslagen.
4. Leg vast hoe CURRENT wordt geselecteerd en hoe INACTIVE/REJECTED expliciet worden heropend; vermijd automatische vervanging van beheerbeslissingen.
5. Definieer afwijkingsbewijs en inventarisatievolledigheid: een mislukte scan is geen bewijs dat een object ontbreekt.
6. Leg de minimale registratiecriteria en eventuele validatieprofielen vast; monitoringinhoudelijke criteria volgen later in de eigen context.
7. Onderzoek pas afzonderlijk of fysieke objectversies naast elkaar mogen bestaan en wat dit betekent voor naamgeving, identiteit en afhankelijkheden.

## Eerstvolgende werkstap

Vervolg met de functionele overgangsmatrix op basis van deze afspraken. Bespreek open beleidskeuzes voordat definitieve DDL en packagewijzigingen worden uitgewerkt. Geen complete refactoring of implementatie is met deze afsluiting goedgekeurd.
