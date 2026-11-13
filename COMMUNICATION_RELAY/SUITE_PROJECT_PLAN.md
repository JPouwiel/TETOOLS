# TETOOLS suiteprojectplan

Eigenaar TETOOLS__REGIE. Voortgang en beslissingen staan op de gekoppelde issues. [Issue #119](https://github.com/JPouwiel/TETOOLS/issues/119)

## Scope en eindresultaat

Eén technisch geaccepteerde suite-release voor Oracle Database 19c Enterprise op drie RAC-nodes, met compatibele moduleversies en overdracht aan beheer. Productie-uitrol heeft een afzonderlijk besluit. Ontwikkelprioriteit volgens de [module-index](MODULE_REGISTRY.md): ADMIN_LOGGER, ADMIN_OBJECTS, ADMIN_MONITOR, ADMIN_SESSIONS, ADMIN_TNSNAMES. Voor opname van ADMIN_MONITOR in de eerste gezamenlijke release zijn broninventarisatie en scopebevestiging nodig. De installatievolgorde volgt uit de aangetoonde afhankelijkheden.

Behoud geldige publieke contracten en gewenste werking. Defectcorrecties en afwijkingen volgen de [ontwikkelstandaard](policy/TETOOLS_DEVELOPMENT_STANDARD.md). Voor de release gelden de [goedgekeurde eindcriteria](https://github.com/JPouwiel/TETOOLS/issues/119#issuecomment-6790734978), waaronder reproduceerbare installatie of migratie, functioneel en technisch testbewijs, representatieve RAC-validatie, geverifieerd herstel en centrale releaseacceptatie.

## Mijlpalen

| ID | Eigenaar | Afsluitcriterium | Startvoorwaarde |
|---|---|---|---|
| M1 Bronbaseline en afhankelijkheden | Module-regies en TETOOLS__REGIE | Bronversies, eigenaren, publieke contracten, aanroepers en onderlinge afhankelijkheden vastgelegd. Scopebesluit voor ADMIN_MONITOR herleidbaar. | Goedgekeurde suitescope. |
| M2 Ontwerp en voorbereiding | Module-regies en TETOOLS__REGIE | Per pakket een beoordeeld ontwerp en toetsbare criteria. Leg per testcase vast welk voorbereidingsbewijs nodig is. | Relevante M1-baseline per pakket. |
| M3 Implementatie en installatie | Module-regies en uitvoerders, DBA voor installatie | Goedgekeurde wijzigingen in herleidbare revisies. Installatie of migratie en compilatie van de gekozen versies aangetoond. | Goedgekeurd ontwerp voor implementatie. Afzonderlijke vrijgave voor Oracle-uitvoering. |
| M4 Modulevalidatie en suite-integratie | Module-regies, DBA/security/herstel en centrale regie | Testbewijs volgens de acht categorieën, inclusief werkelijke koppelingen, representatieve drie-node RAC en herstel. Compatibele versies en restrisico's vastgelegd. | Reproduceerbare installatie, doelomgeving en passende uitvoeringsvrijgave. |
| M5 Technische release en overdracht | TETOOLS__REGIE, module-regies en beheer | Centrale acceptatie, exacte versies, scripts, rechten, migratie, impact en herstel overgedragen. Hier eindigt de reeks. | Moduleacceptaties en suitebewijs uit M4. |

## Eerste uitvoeringsvolgorde

1. **M1-LOGGER / M2-LOGGER-B — eerste inhoudelijke pakket.** ADMIN_LOGGER__REGIE gebruikt het gepubliceerde F2-dossier om D02 en D03 uit te werken tot een besluitrijp functioneel contract en concreet correctieontwerp. Begin bij compatibiliteitsbaseline en RESTORE-identiteit, weigering en veilige herinitialisatie. Leg de kleinste zinvolle codewijziging, gevolgen voor bestaande aanroepers, verwachte uitkomsten en resterende beslisvragen vast. D04 en D11 leveren gericht input waar zij dit ontwerp raken. Stoppunt is één voorstel in #104 met beslisbare scope. TETOOLS__REGIE beoordeelt het voorstel vóór een implementatieopdracht. [F2-beoordeling](https://github.com/JPouwiel/TETOOLS/issues/104#issuecomment-6796817880).
2. **M3-LOGGER — eerste ontwikkelronde.** Na ontwerpgoedkeuring voert een bestaande LOGGER-uitvoerder de afgebakende wijziging uit met passende statische controles en onafhankelijke review waar vereist. De startvoorwaarde voor dit werk is het goedgekeurde ontwerp. Werkelijke installatie en Oracle-tests volgen hun uitvoeringsvoorwaarden.
3. **M3/M4-LOGGER — operationele PoC.** F1 en het F2-dossier staan op main. ADMIN_LOGGER__REGIE stelt een concrete single-instance testset voor. Gebruik bestaande G01/G02-informatie. Vraag aanvullend bewijs voor de geselecteerde tests. G03-rechten en observatie/herstel volgen uit die tests. G09 blijft een afzonderlijk besluit. De PoC levert bewijs voor de gekozen omgeving. Representatieve RAC-validatie blijft een apart doel. [Checklist en voortgang](https://github.com/JPouwiel/TETOOLS/issues/104#issuecomment-6851219873).

| Plan-ID | Ander gekoppeld werk | Eerstvolgende actie en afhankelijkheid |
|---|---|---|
| M2-LOGGER-A | Onafhankelijke F1-review | Afgerond. [PR #102](https://github.com/JPouwiel/TETOOLS/pull/102) gemerged en teruggelezen. |
| M2-LOGGER-C | Formele optie-C-publicatie | TETOOLS__REGIE beoordeelt het bestaande [voorstel #113](https://github.com/JPouwiel/TETOOLS/pull/113). |
| M2-RAC-SUITE | Suitevragen over identiteit, container en gelijktijdigheid | TETOOLS__REGIE verzamelt gericht bewijs van de betrokken modules en DBA. Koppel uitkomsten aan werk dat ervan afhankelijk is. [#55](https://github.com/JPouwiel/TETOOLS/issues/55). |
| M2-TESTOMGEVING | Herbruikbare testomgeving | TETOOLS__REGIE plant apart een eigenaar en oplevering voor inrichting, accounts, data, bewijsopvang en reset. Gereed zodra een volgende run vanuit een bekende uitgangssituatie herhaalbaar is. Alleen concrete voorzieningen die een gekozen test vereist, zijn afhankelijkheden van die test. |
| M1-OBJECTS | PM-001 revisie 004 | ADMIN_OBJECTS__REGIE gebruikt de bestaande [openpunten](../modules/ADMIN_OBJECTS/OPEN_POINTS.md) en brengt de LOGGER-koppeling in kaart. Volgt in ontwikkelprioriteit op LOGGER. |
| M1-OVERIG | Overige modules | TETOOLS__REGIE verifieert bronstatus en eigenaarschap in de vastgestelde prioriteitsvolgorde. |

## Sturing

Ieder uitvoeringsissue vermeldt plan-ID, eigenaar, verwacht resultaat, succescriteria, afhankelijkheden en stoppunt. Een opvolger controleert de relevante gereedmelding, versie en startvoorwaarden. Bij het sluiten van een mijlpaal beoordeelt de regie alle taakstatussen, afwijkingen, overgedragen restpunten en afgesproken integratiecontroles. Gebruik bestaande sessies en beperk gelijktijdig inhoudelijk werk per regielijn volgens het [relaycontract](RELAY_CONTRACT.md).

Bronnen [mijlpaalvoorstel](https://github.com/JPouwiel/TETOOLS/issues/119#issuecomment-6790852653) en [afbakening PoC en testomgeving](https://github.com/JPouwiel/TETOOLS/issues/119#issuecomment-6851219231).
