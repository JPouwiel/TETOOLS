# Broncontrole voorafgaand aan implementatie 004

De vijf referentiebestanden in reference/ zijn samengesteld en gecontroleerd voordat 004-code is gegenereerd. De implementatiebuilder weigert verder te gaan als één van de 37 gehashte referentiebestanden gewijzigd is. De bronbestanden onder sources/ zijn niet gewijzigd. Revisie 003 in output/ is niet gewijzigd.

| Controle | Uitkomst / bewijsgrens |
|---|---|
| ZIP 003 identiteit | SHA-256 ac7b6d2bb084c87326eaf2cd9b5e8c49296759d73b743217a15ad9fe6dcde85d; gelijk aan de in review vastgelegde bron |
| ZIP 003 inhoud | 18 entries; alle 17 manifestentries op bytes en SHA-256 opnieuw geverifieerd |
| Catalogus | Setup 003 en contextoverdracht exact dezelfde 53 unieke labels in dezelfde volgorde |
| Historische bronnen | Alle 12 lokale bestanden uit het 003-manifest op SHA-256 gecontroleerd en meegeleverd; historie is geen actuele codebasis |
| Review-PDF | 12 pagina's rechtstreeks uitgelezen; B03/B04/B07 en bewijsgrenzen vergeleken met tekstcompanion |
| Regiechat | Zes recente turns, nextCursor null, hasMore false; langere retrievalsnapshot meegeleverd, geen volledige historie |
| D01-D18 | Tegen C §§1-10, actuele H28-H35, review §§4-9 en expliciete actuele gebruikersopdrachten gecontroleerd |
| R01-R16 | Herleid tot D-ID's en B03/B04/B07; runtime-eisen bewust niet als geslaagd aangemerkt |
| Open punten | OP-01..13 en M1..M6 niet stilzwijgend gesloten; HIST-01..03 en VAL-01 expliciet |
| Referentievoorbeeld | 9 records, 1228 bytes, digest 1A1E83B0450BC00A53E476D7D15FA8379EA0B07AEA999440931F7FA15BD34AF1 lokaal opnieuw gecodeerd |
| Oracle 19c primaire bronnen | O1-O6 online geraadpleegd; onderbouwen runtimebetekenis, niet de eigen ontwerpacceptatie |

Historische volledigheid is NIET aangetoond. Vooral oorspronkelijke woordelijke reviewrondes, volledige oudere regiegeschiedenis en de originele losse Pasted text.txt-upload ontbreken. Hashes bewijzen bestandsidentiteit en geen volledigheid van besluitvorming. Er is geen ontbrekend besluit ingevuld en geen bestaande voorstelstatus naar goedgekeurd omgezet.

De referentieregisters gebruiken compacte bronaliassen. SOURCE_INDEX.md vertaalt ze naar de exacte meegeleverde versie. Nadere implementatiekeuzes staan in DEVIATIONS.md. Alle Oracle-tests zijn bij oplevering NOT_EXECUTED.
