# PM-001 revisie 004 - afwijkingen en implementatiekeuzes

Basis: reference/manifest.json v1. Geen gebruikersbesluit gewijzigd. Onderstaande keuzes zijn PoC-uitwerkingen, geen nieuwe productieacceptatie. D06/D17 en OP-01..13 blijven open waar dat in de basis staat.

| ID | Relatie | Keuze / wijziging tegenover 003 | Reden en gevolgen |
|---|---|---|---|
| K01 | D07; R02-R05 | Eén package AO4_POC met publieke extract_metadata, normalize_metadata, serialize_manifest, calculate, store_observations | B03 gericht refactoren; bestaande veldregels en wireformat behouden; geen vier packages nodig |
| K02 | D01; R01/R12 | Nieuwe AO4_-objectnamen en verplichte AO4_POC_<suffix>-schemanaam | Geen botsing met 003; geen migratie of productie-upgrade; behoud 003 bytegelijk |
| K03 | D07; R02/R03 | METADATA_V1 met acht benoemde queryslots, gescheiden NUMBER-/tekstcellen | Getypeerd onafhankelijk testcontract; geen impliciete NLS-getalconversie; positional mapping expliciet in DESIGN.html |
| K04 | D06/D07 | Volledige framing/sortering/hashing naar serializer; ordered-column HEX-grammatica blijft in normalisatie | Exacte 003-profielwaarden behouden; gedeelde value_frame is een pure encoderhelper; geen dictionaryquery vanuit normalisatie |
| K05 | D12; R06/R07 | AO4_FINDING krijgt identity-ID, release-FK, bron/container/tijd, fase, werkelijke foutcode/-tekst, actual type en optionele digest | Echte bevindingen opvraagbaar; success is bounded-profile, geen volledige DDL-gelijkheid; geen autonome commit |
| K06 | D02/D12 | UNKNOWN-test verwerkt een werkelijk aangeboden onbekend label bij de bestaande AO4_V | Oracle 19c levert niet voorspelbaar een onbekend dictionarytype; geen fictieve objectidentiteit. Catalogus blijft exact 53 labels |
| K07 | D08; R06 | USER_OBJECTS alleen voor lokale identiteitscontrole van niet-geëvalueerde objecten en cleanup | Noodzakelijke PoC-hulpbron, geen profielmetadata of vervanging van CDB/DBA. Geen extractors voor overige 50 labels |
| K08 | D12; R06 | INDEX/CONSTRAINTS-preflight resolveert de parent via gekozen CDB/DBA-route; bounded parentextractie moet slagen | Geen claim dat een kind onafhankelijk van unsupported parentshape volledig ondersteund is |
| K09 | D01/D15 | Root en non-CDB expliciet geweigerd; CON_ID >=3 | Verduidelijkt de al beperkte runbookscope; geen stilzwijgende rootondersteuning uit oud broncommentaar |
| K10 | D15; R09-R11 | 63 T-assertions, rowassertions, 3 P-, 2 D- en 1 C-assertion; volledige vector en onafhankelijke bytecontrole | B07; geen enkelvoudige eindmarker als bewijs. DBA-handoff voor echte privilegefout nodig |
| K11 | D15; R06 | Extra lege-schemafixture-, LONG-, datatype- en unsupported-shapetabellen, uitsluitend AO4 | Tests representeren echte metadata; alle fixtures op vaste cleanupallowlist |
| K12 | D15 | Fail-closed bij ontbrekende shape-flags; serializer valideert niet-gehele tags, null canonical version, profiel/veldorde/bounds | Robuustere foutafhandeling zonder wijziging van geldige 003-canonical bytes |
| K13 | D18; R13 | REGIE_RETRIEVAL_20261103.json als aanvullende ongewijzigde retrievalsnapshot buiten bevroren referentiemanifest | Langere weergave van dezelfde zes recente turns; geen oudere cursor of nieuwe besluitbasis; oorspronkelijke reviewrondes blijven HIST-01 |
| K16 | D15; R11 | Cleanup verwijdert AO4_SHAPE voor AO4_T | Concrete leesreviewbevinding: een falende FK-rejectassertion kan een verwijzende SHAPE-tabel achterlaten. Volgorde voorkomt ORA-02449 zonder cascade; statisch op afhankelijkheid gecontroleerd, Oracle nog niet uitgevoerd |
| K15 | D15; R04 | Oracle 19c JSON-type-documentatie aanvullend technisch gecontroleerd; expliciete JSON-null/STRING-validatie | Geen besluitenbasis uitgebreid; voorkomt impliciete GET_STRING-conversie; exacte geldige 003-bytes behouden |
| K14 | D18; R13 | Rootmanifest voor volledige oplevering naast reference/manifest.json; rootregisters bytegelijk aan referentie | Manifestzelfhash via SHA256SUMS, geen circulaire selfhash; bronpakket en resultaat afzonderlijk reproduceerbaar |

Geen afdoening van B05 als volledige installerworkflow: objectversies, accepted baselines, autorisatie en werkelijke installatie blijven open. Geen installatiehash en geen uitvoeringsmodi toegevoegd. Code legt alleen testobservaties en preflight vast.

Als een volgende sessie deze basis inhoudelijk wil wijzigen: nieuwe versie van de referentie maken, bron en motivering registreren en de betreffende eisen/testverwachtingen opnieuw beoordelen. De huidige bronhistorie niet overschrijven.
