# PM-001 revisie 003 - cumulatief reviewrapport

3 november 2026 | Project PL/SQL TETOOLS | Oracle Database 19c EE CDB/PDB


## 1. Oordeel en afbakening

Het pakket verwerkt de inhoudelijke besluiten uit de beschikbare aanvullende regieoverdracht grotendeels correct en traceerbaar. Het is een cumulatief ontwerp- en PoC-pakket, geen aantoonbaar volledig historisch dossier en geen op Oracle 19c gevalideerde implementatie. De concrete profielregels en CAN-001 blijven terecht voorstellen. M1-M6 zijn opgenomen als opleveringen met resterende besluiten; zij zijn niet allemaal afgerond.

De belangrijkste uitvoeringshiaten zijn de uitsluitend synthetische preflightbevindingen, de beperkte scheiding tussen extractie en normalisatie, en het ontbreken van werkelijk Oracle-testbewijs. Dit zijn beperkingen voor acceptatie van de PoC; zij bewijzen niet dat besluiten uit het document zijn verdwenen. Er is geen samengestelde installatiefingerprint aangetroffen in de actuele code.

De genoemde 52-itemcatalogus telt in de beschikbare regieoverdracht feitelijk 53 unieke labels. Alle 53 staan exact en in dezelfde volgorde in de setup. Er ontbreekt dus geen aantoonbaar 52e item; het aantal in de vraag is tegenstrijdig met de beschikbare lijst. Er is geen label verwijderd of samengevoegd.

Historische volledigheid kan uitsluitend worden getoetst tegen beschikbare regiecontext. De opgehaalde regiechat biedt vijf recente turns, waaronder de aanvullende overdracht van 3 november, zonder cursor naar oudere turns. Die overdracht is een reconstructieve samenvatting door de eerdere assistent, geen woordelijk verslag van alle oorspronkelijke gebruikersbesluiten. Dat begrenst ook uitspraken over acceptatie en afwijzing. De originele complete reviewrondes 01/02 zijn daarmee niet onafhankelijk herbeoordeeld.

Er zijn geen automatische wijzigingen aan archief, SQL, HTML of gesynchroniseerde bronnen uitgevoerd. SQL is uitsluitend statisch gelezen. Er is geen Oracle-verbinding gebruikt.


## 2. Bronnen, methode en statuslegenda

Beoordeeld is het lokale ZIP-bestand met dezelfde naam als de opgegeven /mnt/data-verwijzing. Het bestand uit de bijlage van de regiechat is bytegelijk aan deze lokale kopie: SHA-256 AC7B6D2BB084C87326EAF2CD9B5E8C49296759D73B743217A15AD9FE6DCDE85D. Het ZIP bevat 18 bestanden. Het manifest somt 17 bestanden op; het manifest zelf is daarbij logisch uitgezonderd.

Per eis is gecontroleerd op vindbaarheid, betekenis, status, samenhang tussen actuele hoofdstukken 28-35 en historische hoofdstukken 01-27, en aansluiting op de losse SQL/JSON-bestanden. Sectieverwijzingen H/PM-001-xx zijn stabiele HTML-sectie-ID's; regelnummers bij SQL verwijzen naar de uitgepakte originele bestanden, geteld vanaf 1. Bestandsaliassen hieronder staan steeds voor exact één volledige bestandsnaam.

Aanwezig: inhoud aantoonbaar opgenomen binnen de expliciete scope. Deels: inhoud of uitvoering slechts gedeeltelijk ingevuld. Ontbreekt: vereist bewijs of onderdeel niet gevonden in het begrensde corpus. Tegenstrijdig: concrete uitspraken of aantallen zijn niet verenigbaar zonder correctie of nadere uitleg. Deze statussen zeggen niet automatisch dat een ontwerp is goedgekeurd of een test geslaagd.

Besluit: als geaccepteerd/afgewezen vastgelegd in de beschikbare overdracht. Voorstel: concrete invulling die nog beoordeling vraagt. Voornemen: later uit te voeren onderzoek, ontwerp of implementatie. Testclaim: uitspraak over uitgevoerde verificatie; afzonderlijk gecontroleerd waar lokaal reproduceerbaar. Kleur draagt in dit rapport geen betekenis. Er wordt geen vervangende PL/SQL-code opgeleverd.


## 3. Bestandsregister

H = 20261103__PLSQL__TETOOLS_ADMIN_OBJECTS__ontwerp_profielmanifest_003.html

C = 20261103__PLSQL__TETOOLS_ADMIN_OBJECTS__contextoverdracht_003.txt

P = 20261103__PLSQL__TETOOLS_ADMIN_OBJECTS__cumulatief_overzicht_003.pdf

S0 = 20261103__PLSQL__TETOOLS_ADMIN_OBJECTS__00_privileges_003.sql

S1 = 20261103__PLSQL__TETOOLS_ADMIN_OBJECTS__01_setup_003.sql

S2 = 20261103__PLSQL__TETOOLS_ADMIN_OBJECTS__02_package_003.sql

S3 = 20261103__PLSQL__TETOOLS_ADMIN_OBJECTS__03_tests_003.sql

S4 = 20261103__PLSQL__TETOOLS_ADMIN_OBJECTS__04_cleanup_003.sql

V = 20261103__PLSQL__TETOOLS_ADMIN_OBJECTS__CAN001_testvectoren_003.json

B = 20261103__PLSQL__TETOOLS_ADMIN_OBJECTS__canonieke_bytes_voorbeeld_003.txt

J = 20261103__PLSQL__TETOOLS_ADMIN_OBJECTS__objectmanifest_voorbeeld_003.json

K = 20261103__PLSQL__TETOOLS_ADMIN_OBJECTS__pakbon_voorbeeld_003.json

E = 20261103__PLSQL__TETOOLS_ADMIN_OBJECTS__exception_voorbeeld_003.json

L = 20261103__PLSQL__TETOOLS_ADMIN_OBJECTS__verify_log_003.py

R = 20261103__PLSQL__TETOOLS_ADMIN_OBJECTS__README_003.txt

Overige bestanden: manifest.json, validation.json en README.txt (bytegelijk aan R). Alle verwijzingen betreffen het beoordeelde ZIP, tenzij expliciet als lokale historische bron of externe Oracle-bron gemarkeerd.


## 4. Systematische dekkingsmatrix

De matrix onderscheidt documentdekking van uitvoeringsdekking. Een open punt mag volledig aanwezig zijn zonder inhoudelijk opgelost te zijn.


| Onderdeel | Status | Aard | Vindplaats | Beoordeling |

|---|---|---|---|---|

| Catalogus 52 versus 53 | Tegenstrijdig | Besluitlijst aanwezig | C §1; H/29; S1:13-65 | 53 unieke labels; exact dezelfde lijst in regieoverdracht en setup. Alleen het opgegeven aantal 52 wijkt af. |

| Recognized-only / unknown | Aanwezig | Besluit + begrensde demonstratie | H/29; S2:19-23; S3:31-32,81-84 | UNDEFINED is bekend; een niet-gemapt label wordt UNKNOWN. Geen installatiebrede automatische inventarisatie. |

| PROFILE_CODE / CANONICAL_VERSION | Aanwezig | Naamgeving besloten; invulling voorstel | H/28,30,32; S1:69-73; S2:226-228 | Profielversie en canonical versie expliciet. TABLE_CORE/2 is geen stilzwijgend goedgekeurde productiespecificatie. |

| Concrete TABLE_CORE-regels | Aanwezig | Voorstel | H/30; S2:139-216 | Kolommen, P/U/C-constraints en NORMAL-indexes met veld-ID, toepasselijkheid, NULL/N/A en uitsluitingen. Geen volledige DDL-gelijkheid. |

| OP-13 bronvoorkeur | Aanwezig | Besluit + PoC-contract | H/31; S0; S2:82-89,139-222 | CDB + GV_$INSTANCE; expliciete DBA + GV_$INSTANCE-route. Handmatige bronkeuze, geen automatische fallback. |

| OP-13 bewijs CDB/DBA-equivalentie | Ontbreekt | Voornemen / test nog uit te voeren | R stap 6; H/34-35; validation.json/not_executed | Automatische tests gebruiken CDB. Geen Oracle-uitvoer van beide routes beschikbaar. |

| CAN-001 exact byteprotocol | Aanwezig | Principe besloten; protocol voorstel | H/32; S2:25-61,91-136,216-221 | Header, tags, framing, uint32, UTF-8, sortering, multipliciteit en foutgrenzen expliciet. |

| CAN-001 testvectoren | Aanwezig | Referentietest; geen Oracle-claim | V; B; J; H/32-33 | Vier vaste value-frames en één volledig voorbeeld. Bytes en SHA-256 lokaal opnieuw gecontroleerd. |

| Geen samengestelde installatiefingerprint | Aanwezig | Afwijzingsbesluit | C §3/8; H/28,30,34; S2:255-282 | Individuele TABLE/INDEX/CONSTRAINTS-waarnemingen per release. TABLE bevat componentrecords, geen hash over installatiehashes. |

| DATA_LENGTH historisch onderzoek | Deels | Open onderzoek + hypothese | H/30, onderdeel DATA_LENGTH investigation; C §3 | Eerdere revisies noemen de omissie en datatypekeuze; oorspronkelijke goedgekeurde reden niet aangetoond. Open status correct behouden. |

| PM-001-08 manifest | Aanwezig | Concept besloten; techniek voorstel | H/28,33; J; S3:46-53 | Volledig getypeerd synthetisch voorbeeld en spoolcode. Een echt Oracle-manifest ontbreekt terecht als testbewijs. |

| PM-001-11 scheiding verantwoordelijkheden | Deels | Architectuurbesluit aanwezig | H/28,35; S2:62-236,237-290 | Opslagcoördinator apart; extractie en normalisatie zijn nog verweven in calculate. Geen zelfstandig extractiecontract als code-interface. |

| PM-001-12 betrouwbaarheid | Aanwezig | Besluit + open criteria | H/12,28,31,34; C §2/3 | Opnieuw berekenen bij onvoldoende vertrouwen; criteria blijven open. Geen werkende cache/freshness-gate in deze PoC. |

| Pakbon en installerregistratie | Deels | Besluit + voorbeeld | H/33; K; S1:67-73; S3:77-80 | Aanbod, individuele hash en releasekoppeling aanwezig. Werkelijke installatie-uitvoering, volledige objectversieregistratie en resultaatrapportage zijn geen afgewerkte workflow. |

| Exception reference | Aanwezig | Voorbeeld + toekomstig beleid | H/33; E; K/requested_exception_refs | Scope, autorisator, vervaldatum, profiel, fingerprint en evidence-ref. APPROVED_EXAMPLE_ONLY is geen echte goedkeuring. |

| Preflight binnen PoC | Deels | Besluit; alleen demonstratie | H/34; S1:74-77; S3:81-84 | Structuur voor classificatie en acties aanwezig; twee ingevoegde rijen zijn synthetisch. Automatische vertaling van extractiefouten ontbreekt expliciet. |

| Latere uitvoeringsmodi | Aanwezig | Voornemen, geen implementatie | C §7; H/34 | RECOMMENDED, FORCE_ALL, SELECTIVE beschreven als later ontwerp. Technische onuitvoerbaarheid blijft een blokkade. |

| M1-M6 en OP-koppeling | Aanwezig | Geaccepteerde planning + open werk | C §8; H/23,28,34 | Alle zes inclusief M4-correctie en OP-01..13. Aanwezigheid is geen mijlpaalacceptatie. |

| Oracle 19c PoC-bestanden | Aanwezig | Codevoorstel, nog niet bewezen uitvoerbaar | S0-S4; L; R; H/35 | Privilegesjabloon, lege-schema-setup, package, tests en cleanup beschikbaar. Geen succesvolle Oracle-compilatie claimen. |

| Bronverwijzingen | Deels | Bronverantwoording | H/25-26,30-31,35; manifest.json/sources | Oracle 19c-links en historische bronhashes aanwezig. Geen integraal zelfstandig origineel regiedossier; lokale onderzoekspaden zijn niet alle meegeleverd. |

| Testclaims en beperkingen | Aanwezig | Expliciet begrensde claims | validation.json; H/34-35; P | Referentiechecks onderscheiden van Oracle-compilatie/runtime en performance. Deze review bevestigt alleen de hieronder opnieuw uitgevoerde subset. |

| Cumulatieve consistentie | Deels | Voorrangsregel aanwezig | H/28 versus H/01-27; P openingspagina | Oude USER_-, TABLE_CORE/1- en POC_TLV_1-voorstellen blijven zichtbaar als historie. Lees 28-35 eerst; geen tweede actuele implementatiereeks aannemen. |


## 5. Reviewrondes 01 en 02: volledige aansluiting

Reviewronde 01 A/03: aanwezig in H/28 en H/31; geen oorspronkelijke CREATE/ALTER-reconstructie, OP-13 bepaalt actuele metadataherkomst. B/04: aanwezig in H/28 en H/30; namen akkoord, regels als voorstel. C/05: aanwezig in H/29 en H/33; getypeerde evaluatiewaarden plus diagnostische identiteiten. D/06: deels in H/30; normalizers en NUMBER/FLOAT behandeld, historische DATA_LENGTH-redenering open. E/07: aanwezig als voorstel in H/30/32; vaste AO3_RULES_1-code en profielversies, geen dynamische normalizer-engine.

F/08: aanwezig in H/33 en J; concreet volledig referentievoorbeeld, geen Oracle-waarneming. G/09: aanwezig in H/32 en S0; binair voorstel en DBMS_CRYPTO-grant. H/11: besluit aanwezig in H/28/35; technische scheiding deels, zie bevinding B03. I/12: aanwezig in H/12/28/31; vertrouwen vereist, precieze criteria open. J/13: aanwezig in H/33 met K en E; operationele installatieregistratie deels, zie B05.

Reviewronde 02 §03: aanwezig H/29, catalogus en herkenning/evaluatie gescheiden. §04: aanwezig H/30, concrete regels als voorstel. §05: aanwezig H/33 en S2:255-282, individuele objectwaarnemingen per release; geen installatiehash. §06: deels H/30, onderzoek uitgevoerd voor beschikbare revisies, oorspronkelijke reden niet gevonden. §07: aanwezig H/32, expliciet byteformaat. §08: aanwezig H/28/33, conceptakkoord onderscheiden van technische invulling. §09: aanwezig H/32, framing/tags/lengtes/NULL/N/A/sortering/overflow.

§11: besluit aanwezig, uitvoering deels H/35 en S2. §12: aanwezig H/28/31/34, herberekening en open vertrouwenscriteria. §13: deels H/33 en S1/S3, pakbon/exception uitgewerkt, installerworkflow nog beperkt. §15: deels H/34, classificatie slechts synthetisch; modi later. §19: aanwezig H/28/34, lifecycle uitgesteld. §21: aanwezig H/29-31/34, beperkte heap/constraints/index-PoC, efficiëntie besproken zonder benchmarkclaim. §22: aanwezig H/28/34, testprioriteiten later gezamenlijk; huidige checks voorlopig. §23: aanwezig H/34, concrete M1-M6 met open besluiten. §24: aanwezig H/28 en historische banners; vervallen voorstellen krijgen geen voorrang.

De latere correcties zijn herkenbaar verwerkt: samengestelde installatiefingerprint afgewezen; DATA_LENGTH historisch open; CAN-001 concrete invulling nog voorstel; M4 zonder installatiehash; OP-13 voorkeur CDB/GV met DBA/GV alternatief; volledige aangeleverde catalogus behouden. Deze aansluiting is getoetst tegen C en de leesbare chat-overdracht, niet tegen ontbrekende oorspronkelijke transcripties.


## 6. Cumulatieve bevindingen en aanbevolen afhandeling

B01 - Catalogusaantal: tegenstrijdig aantal, hoge zekerheid. De vraag spreekt van 52; C §1 bevat 53 unieke labels en S1:13-65 registreert precies die 53. H/28-29 en validation.json noemen 53. Advies: bevestig de noemer 53 bij de volgende regiebespreking; verwijder geen item om aan 52 te voldoen. Het archief is intern consistent op dit punt.

B02 - Historisch dossier: deels, hoge zekerheid. H/28 bewaart reviewuitkomsten, maar de chatretrieval en C bieden geen woordelijke oorspronkelijke reviews. H/30 verwijst bovendien naar work/build_pm001.py:76 en work/pm002/document.py:22; deze onderzoeksscripts staan niet in het ZIP. De lokale historische revisies zijn wel beschikbaar en hun 12 manifesthashes zijn in deze review gecontroleerd. Advies: voeg later originele regieteksten en bronartefacten of een expliciete bewijsindex toe wanneer historische volledigheid vereist is. Een hash bewijst bestandsidentiteit, niet de volledigheid van besluitvorming.

B03 - Architectuur: deels gerealiseerd, hoge zekerheid. S2:237-290 is een aparte opslagcoördinator. calculate (S2:62-236) voert dictionaryqueries uit en normaliseert/serialiseert direct dezelfde lokale waarden. De architectuurkeuze is als besloten vastgelegd; de bewering dat alle drie verantwoordelijkheden al zelfstandig testbaar gescheiden zijn, zou te sterk zijn. H/35 nuanceert dit zelf. Advies: leg bij M3 vast welke minimale interface-scheiding moet worden aangetoond. Dit rapport doet geen refactoringvoorstel of codewijziging.

B04 - Preflight: deels gerealiseerd, hoge zekerheid. S3:81-84 schrijft alleen ILLUSTRATIVE_VIEW en ILLUSTRATIVE_UNKNOWN. Bij unsupported metadata werpt calculate een fout; het slaat geen actuele componentbevinding op. H/34 zegt expliciet dat de automatische vertaler ontbreekt. Daarmee is het registratie- en classificatieconcept aanwezig, maar nog geen preflight die echte gevallen systematisch beoordeelt en vastlegt. Advies: benoem dit als resterende PoC-oplevering en toets een echte unsupported-case met opgeslagen reden en aanbevolen actie. Volledige uitvoeringsmodi blijven later werk.

B05 - Pakbon, versies en resultaten: deels, hoge zekerheid. K scheidt aangeboden gegevens en exceptionverzoek. E is een apart autorisatievoorbeeld. S1:67-73 koppelt waarnemingen aan release_id, maar AO3_FP heeft geen aparte object_version-kolom; versie-informatie kan alleen via het vrije aangeboden CLOB worden aangeleverd. S3 registreert TEST_OBSERVATION met SESSION_USER, geen werkelijk installatieresultaat. Dat past bij een beperkte demonstratie, maar bewijst niet de volledige M4-registratieketen. Advies: bevestig later het sleutel-/versiecontract en de scheiding aanbod, preflight, autorisatie en feitelijke uitvoering.

B06 - OP-13 fallback en testbaarheid: aanwezig als expliciete route, onbewezen op Oracle. S2 accepteert alleen CDB of DBA; er is geen automatische bronselectie. S3:22 gebruikt steeds CDB. R stap 6 vraagt handmatige vergelijking als beide grantsets bestaan. Dat is consistent met een gecontroleerd alternatief en vermijdt dat een privilegeprobleem als afwezig object wordt uitgelegd. Advies: maak bij M3 de twee-routevergelijking concreet reproduceerbaar en bewaar beide profieltupels, bytes en hashes. Een automatisch fallbackmechanisme is niet uit de beschikbare besluittekst af te leiden als verplichte implementatie.

B07 - Logverificatie heeft beperkte bewijskracht, hoge zekerheid. L/check_log controleert fouttekst, één eindmarker, canonieke bytes en manifesthash. Het verifieert niet iedere afzonderlijke PASS-regel en vraagt geen opgeslagen rijaantallen of inhoud uit AO3_FP op. S3 roept store_observations aan, maar bevat geen expliciete assertions op alle opgeslagen kindhashes of rollbackgedrag. De omschrijving 'complete SQL test sequence' betekent dus hoogstens dat de eindmarker aanwezig is, niet onafhankelijke dekking van alle resultaten. Advies: rapporteer de checker als byte-/digestcontrole plus eindmarker; voeg voor M3 afzonderlijk opslag- en foutpadbewijs toe. Synthetische logs zijn geen Oracle-testbewijs.

B08 - Historische en actuele voorschriften: deels leesrisico, geen aangetoonde actuele inhoudelijke tegenspraak. H/01-27 bevat oude keuzes zoals USER_-bronnen en POC_TLV_1, plus oorspronkelijke installatie- en lifecyclevoorstellen. H/28 en banners geven 28-35 expliciet voorrang. Dit maakt het dossier cumulatief, maar losse zoektreffers kunnen achterhaalde code tonen. P is een overzicht van de actuele hoofdstukken en bevat niet ieder oud detail of alle SQL. Advies: citeer altijd revisie én sectie en gebruik uitsluitend de S0-S4-set van 003. De PDF is geen zelfstandig vervangend integraal dossier.


## 7. Oracle 19c: correctheid en praktische grenzen

OP-13 is technisch passend begrensd: de CDB-route filtert huidige CON_ID, eigenaar en tabel; DBA leest de huidige container. GV_$INSTANCE levert uitsluitend runtimeherkomst en wordt niet in de objecthash opgenomen. Oracle beschrijft dat CDB-zichtbaarheid afhankelijk is van container, privileges en CONTAINER_DATA; binnen een PDB betreft zij de overeenkomstige lokale DBA-zichtbaarheid. Een leeg resultaat mag dus geen bewijs van wereldwijde afwezigheid worden [O1].

DATA_LENGTH is bytes, DATA_PRECISION is decimaal voor NUMBER en binair voor FLOAT [O2]. Het voorstel om voor CHAR-semantiek DATA_LENGTH als N/A te behandelen is een eigen profielkeuze, geen Oracle-voorschrift en geen bewezen historische reden voor de omissie. De code bewaart NUMBER/FLOAT-precisie en schaal apart (S2:156-164); zij converteert FLOAT-precisie niet ten onrechte naar een decimale precisie.

Het hashpad gebruikt een BLOB met DBMS_CRYPTO.HASH_SH256 en expliciete AL32UTF8-omzetting; dat sluit aan bij de Oracle-packagebeschrijving [O3]. Het eigen byteprotocol blijft een TETOOLS-voorstel. UTL_RAW.COMPARE retourneert een eerste verschilpositie en is geen gewone negatieve/positieve sorteerfunctie [O4]. S2:24-35 behandelt dit met bytewaarden en een prefixlengtevergelijking. De lokale referentie-encoder gebruikt unsigned bytesortering; Oracle-runtimegedrag van deze implementatie is niet getest.

AUTHID DEFINER maakt directe objectprivileges relevant; gewone sessierollen leveren niet vanzelf de vereiste rechten binnen de stored unit [O5]. S0 documenteert een DBA-sjabloon en package/view-grants. De actuele runbookinstructie is een nieuw leeg wegwerpschema in de doel-PDB. Root/multi-PDB-extractie is niet geïmplementeerd, ook al noemt een broncommentaar lokaal rootgebruik. Volg de beperktere runbookscope bij toetsing.

Efficiëntie is zichtbaar meegewogen: scans per componentverzameling in plaats van per property, één verzameling voor tabel- en kindwaarnemingen, gesorteerde begrensde records, BLOB-hashing, en savepoint voor atomische opslag binnen de callertransactie. Grenzen zijn 8.000 UTF-8-bytes per veld, 16.000 per record, 1.000 records en 1.000.000 bytes totaal. Dit zijn ontwerpgrenzen, geen gemeten capaciteit of productieschaalgarantie. Meerdere read-committed queries leveren niet vanzelf een atomair metadatasnapshot; de DDL-vrije periode blijft een expliciete PoC-voorwaarde (H/31).

Er is op basis van deze statische review geen bewezen Oracle-compilatiefout vastgesteld. Evenmin is compilatie of uitvoerbaarheid bewezen. Voor acceptatie ontbreken minimaal compilatie-uitvoer, database/RU-identiteit, grantsbewijs, werkelijke byte-/digestvergelijking, CDB/DBA-equivalentie, datatypevarianten, lange CHECK-waarden, generated-name-gevallen, foutpaden en opslag/rollbackbewijs (H/34).


## 8. Opnieuw uitgevoerde verificatie en bewijsgrenzen

Uitgevoerd in deze review: ZIP-identiteit vergeleken met regiebijlage; 18 entries geteld; alle 17 manifestbestanden op lengte en SHA-256 gecontroleerd zonder afwijking; alle 12 beschikbare historische bronbestanden uit manifest.json/sources op SHA-256 gecontroleerd zonder afwijking; 53 unieke cataloguslabels vergeleken tussen C en S1 zonder verschil; vier referentieframes en hun SHA-256 herberekend; J opnieuw gecodeerd en exact vergeleken met B; volledige hash gelijk aan J.

Volledig referentievoorbeeld: 9 records, 1.228 bytes, SHA-256 1A1E83B0450BC00A53E476D7D15FA8379EA0B07AEA999440931F7FA15BD34AF1. De herberekening gebruikt de meegeleverde Python-encoder en de standaard SHA-256-implementatie. Zij is een reproduceerbare consistentiecheck van de artefacten, geen onafhankelijk ontworpen vervangend protocol en geen Oracle-waarneming.

Het meegeleverde PDF-overzicht heeft 17 pagina's. De tekst bevat de relevante actuele besluiten, protocolgrenzen, mijlpalen en beperkingen. Voor exacte code en volledige voorbeelden blijft H plus de losse bestanden leidend. De eerdere UI-/offline-/printclaims in validation.json zijn in deze review niet opnieuw als browserfunctionaliteit getest; zij blijven overgenomen claims uit de oplevering. De nieuw opgeleverde review-PDF is wel gerenderd en visueel nagekeken.

Niet uitgevoerd: Oracle-compilatie, SQL/PLSQL-runtime, privileges in een echte PDB, echte preflight, installeruitvoering, autorisatieverificatie, performancebenchmark of reconstructie van ontbrekende historische turns. Geen daarvan mag uit de geslaagde lokale hash- en referentiechecks worden afgeleid.


## 9. Mijlpalen en resterende beslissingen

M1 - Profielcontract: catalogus en begrensde regels aanwezig als voorstel. OP-02 (scope, datatypekeuze, DATA_LENGTH) en OP-13 (productie-extractie/consistentie) blijven te besluiten. Geen volledige generieke profielengine opgeleverd.

M2 - Canoniek formaat: concreet CAN-001-DRAFT-1 en testvectoren aanwezig. OP-01, OP-03 en OP-12 vragen acceptatie van wireformat, portable identiteit, hashpad en grenzen. Testbare referentiebytes betekenen geen protocollaire goedkeuring.

M3 - PoC: scripts en individuele waarnemingen aanwezig, Oracle-bewijs ontbreekt. Extractie/normalisatie-interface, echte bevindingregistratie, datatype-/unsupported-dekking en opslag/foutpaden verdienen expliciete acceptatiecriteria.

M4 - Installatiemanifest: JSON-aanbod en releasegekoppelde individuele fingerprints aanwezig; geen samengestelde installatiehash. Objectversies, installatie-identiteit, fysieke opslag en werkelijke uitvoering/resultaten blijven uit te werken.

M5 - Preflight: structuren en synthetische classificaties aanwezig; echte automatische beoordeling deels. OP-04 tot en met OP-08 betreffen versie-/hashprecedentie, vertrouwde gelijkheid, actualiteit, pakbonopslag en uitzonderingsbeleid. FORCE_ALL/SELECTIVE/RECOMMENDED blijven toekomstig ontwerp.

M6 - Lifecycle: uitgesteld. OP-09 tot en met OP-11 omvatten historie/retentie, meerdere waarnemingen/concurrency en evaluatieovergangen. PM-001-19 is niet door PoC-code beslist. Eerdere status-/ledgercontext is referentie, geen nieuwe implementatieacceptatie.

Aanbevolen regiebesluit: accepteer het pakket als grotendeels volledig verwerkte samenvatting van de beschikbare besluiten en als technisch PoC-voorstel met expliciete open punten. Accepteer het nog niet als historisch sluitend besluitenarchief, afgeronde preflight of bewezen Oracle 19c-implementatie. Dit advies wijzigt geen besluitstatus in het bronpakket.


## Bijlage A. Exact gecontroleerde catalogus

Bron C §1; implementatie S1:13-65; documentatie H/29. Alle onderstaande 53 labels zijn expliciet geregistreerd met default_status RECOGNIZED_ONLY. Alleen TABLE, CONSTRAINTS en INDEX hebben in deze PoC evaluatielogica; COLUMN is een intern recordtype. Er is geen automatische extractor voor de andere 50 cataloguslabels.

01. CLUSTER
02. CONSTRAINTS
03. CONSUMER GROUP
04. CONTEXT
05. CREDENTIAL
06. DATABASE LINK
07. DESTINATION
08. DIRECTORY
09. EDITION
10. EVALUATION CONTEXT
11. FUNCTION
12. INDEX
13. INDEX PARTITION
14. INDEXTYPE
15. JAVA CLASS
16. JAVA DATA
17. JAVA RESOURCE
18. JAVA SOURCE
19. JOB
20. JOB CLASS
21. LIBRARY
22. LOB
23. LOB PARTITION
24. MATERIALIZED VIEW
25. OPERATOR
26. PACKAGE
27. PACKAGE BODY
28. PRIVILEGES
29. PROCEDURE
30. PROFILES
31. PROGRAM
32. QUEUE
33. RESOURCE PLAN
34. ROLES
35. RULE
36. RULE SET
37. SCHEDULE
38. SCHEDULER GROUP
39. SEQUENCE
40. SYNONYM
41. TABLE
42. TABLESPACES
43. TABLE PARTITION
44. TABLE SUBPARTITION
45. TRIGGER
46. TYPE
47. TYPE BODY
48. UNDEFINED
49. UNIFIED AUDIT POLICY
50. USERS
51. VIEW
52. WINDOW
53. XML SCHEMA


## Bijlage B. Externe bronnen en herleidbaarheid

Oracle Database 19c, officiële documentatie; geraadpleegd 3 november 2026. De bronnen onderbouwen Oracle-semantiek, niet de TETOOLS-beleidskeuzes.

[O1] CDB_* Views
https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/cdb_-views.html

[O2] ALL_TAB_COLS
https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/ALL_TAB_COLS.html

[O3] DBMS_CRYPTO
https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_CRYPTO.html

[O4] UTL_RAW - COMPARE
https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/UTL_RAW.html

[O5] Invoker's Rights and Definer's Rights
https://docs.oracle.com/en/database/oracle/oracle-database/19/lnpls/invokers-rights-and-definers-rights-authid-property.html

Regiecontext: chat Oracle tabelstructuur vergelijken, 6ae1c678-2a98-83ed-99b0-c8895440f708; vijf recente turns opgehaald, aanvullende overdracht in assistentbericht 7e364385-b98d-41e6-ac14-e6c737f2f9e9. Geen oudere cursor beschikbaar. Lokale historische bronbestanden zijn aangeduid in manifest.json/sources. Het rapport is een cumulatieve beoordeling op de peildatum, geen uitspraak dat onbeschikbare oudere keuzes ontbreken of bestaan.