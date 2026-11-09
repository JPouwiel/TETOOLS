# TETOOLS — beleidsbesluiten 13–39, vervolg op goedgekeurde 1–12

Datum: 2026-11-09. Project: PL/SQL TETOOLS, Oracle 19c Enterprise. Status: APPROVED op basis van expliciete gebruikersantwoorden in deze projectconversatie; technische uitvoering NOT_AUTHORIZED / NOT_EXECUTED. De exacte bericht-URL's zijn niet beschikbaar (UNVERIFIED). Bron: gebruikersgesprek 2026-11-09, cumulatief PDF revisie 051 (lokaal gesprek; PDF nog niet als GitHub-blob gepubliceerd). Deze tekst consolideert de inhoud en is geen bewijs van implementatie.

De goedgekeurde besluiten 1–12 staan reeds in [TETOOLS_DEVELOPMENT_STANDARD.md](../../TETOOLS_DEVELOPMENT_STANDARD.md) en worden niet gedupliceerd.

## Besluit 13 — REGIE-POLICY-20261109-13

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Vier readinessniveaus: build, functioneel, RAC-ready, technische release; echte RAC niet aangetoond; synthetische toets slechts voorlopig.

## Besluit 14 — REGIE-POLICY-20261109-14

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Synthetische RAC-testmatrix verplicht; ontbreken echte RAC blokkeert ontwikkeling niet, wel definitieve RAC-claim.

## Besluit 15 — REGIE-POLICY-20261109-15

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Risicoklassen BLOCKER, REQUIRES_MITIGATION, DEFERRED_VALIDATION en ACCEPTED_LIMITATION.

## Besluit 16 — REGIE-POLICY-20261109-16

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Samenhangende wijzigingen per revisiepakket, individuele traceerbaarheid behouden.

## Besluit 17 — REGIE-POLICY-20261109-17

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Afhankelijkheidsgedreven volgorde; RAC- en funderingscorrecties eerst, bruikbaarheid behouden.

## Besluit 18 — REGIE-POLICY-20261109-18

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Regressie- en herstelmaatregelen per pakket; risicoproportionele uitzondering bij aantoonbaar laag risico; onomkeerbare DB-ingrepen apart goedkeuren.

## Besluit 19 — REGIE-POLICY-20261109-19

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Module-regie mag vereenvoudigde toetsen voor laag risico goedkeuren; middel/hoog/suite-impact naar centrale regie.

## Besluit 20 — REGIE-POLICY-20261109-20

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Kritieke bestaande defecten verhelpen; overige expliciet registreren en risicogestuurd uitstellen.

## Besluit 21 — REGIE-POLICY-20261109-21

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Mensgerichte, suitebrede functionele API; interne consolidatie mogelijk.

## Besluit 22 — REGIE-POLICY-20261109-22

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Publieke API standaard achterwaarts compatibel; breaking changes alleen met afzonderlijk goedgekeurde migratie.

## Besluit 23 — REGIE-POLICY-20261109-23

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Transactie- en exceptioncontract: ADMIN_LOGGER bezit eigen transacties; autonome log-, diagnostische, sessie- en configuratieoperaties; samenhangende beheerwijzigingen atomair in één autonome transactie; diagnostiek na beheerrollback zelfstandig bewaren. Fallback via exception-API zonder recursieve opslag. log_runtime best-effort voor incidentele registratieproblemen maar sessiebrede fout mag onderbreken; log_info/log_warning interne foutafhandeling; log_error/log_debug/log_*_force verplichte gebruiker- én applicatieterugmelding. Aanroeper mag exception lokaal afhandelen of hoger doorgeven; niet stilzwijgend negeren. Foutklassen registratie, sessiebreed, diagnostische fallback. Zes acceptatiecriteria: aanroepertransactie intact; atomaire beheerwijzigingen; duurzame diagnostiek; juiste foutclassificatie; runtime onderscheid; geen recursieve fallback. Technisch NOT_EXECUTED.

## Besluit 24 — REGIE-POLICY-20261109-24

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Foutisolatie voor niet-kritieke ondersteuning; kritieke fouten niet stilzwijgend wegvangen; zie aangescherpt besluit 23.

## Besluit 25 — REGIE-POLICY-20261109-25

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Prioriteit configuratie: centraal, sessie, per-aanroep, volgens expliciet contract.

## Besluit 26 — REGIE-POLICY-20261109-26

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Fysieke Oracle-sessie INST_ID/SID/SERIAL# onderscheiden van logische LOGSESSION_ID; RAC-bewust.

## Besluit 27 — REGIE-POLICY-20261109-27

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Minimale expliciete locking; integriteit voorop, geen onnodige seriële bottlenecks.

## Besluit 28 — REGIE-POLICY-20261109-28

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Performance risicogestuurd onderzoeken en benchmarken bij onderbouwd vermoeden, niet pas na bewezen incident.

## Besluit 29 — REGIE-POLICY-20261109-29

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Pragmatische testautomatisering; utPLSQL slechts onderzoeksoptie, geen installatie aangenomen.

## Besluit 30 — REGIE-POLICY-20261109-30

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Least privilege, gecontroleerde publieke API en afzonderlijke functionele autorisatielaag.

## Besluit 31 — REGIE-POLICY-20261109-31

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Database-identiteit, functionele eindgebruiker en applicatie-/sessiecontext onderscheiden; alleen betrouwbaar vastgestelde identiteit gebruiken.

## Besluit 32 — REGIE-POLICY-20261109-32

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

ADMIN_LOGGER voor operationele logging en diagnostiek; audit als afzonderlijke verantwoordelijkheid, exacte scope nader onderzoeken.

## Besluit 33 — REGIE-POLICY-20261109-33

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Onafhankelijke moduleversies met suite-compatibiliteitsmanifest en reproduceerbare installatiescripts.

## Besluit 34 — REGIE-POLICY-20261109-34

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Schema-evolutie met databehoud; bij breaking upgrade relevante gegevens migreren, geen onbeperkte verouderde compatibiliteitslast.

## Besluit 35 — REGIE-POLICY-20261109-35

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Self-governing: periodieke controle van eigen databaseobjecten tegen vastgestelde baseline en afwijkingen rapporteren/herstel adviseren. Geen autonome herinstallatie, vervanging of reparatie van databaseobjecten. Veilig herstel van eigen tijdelijke interne runtimegegevens toegestaan onder controleerbare voorwaarden; geen algemene machtiging voor willekeurige datamutaties. Technische mechanismen nog te toetsen. 35-OPEN-01 en 35-OPEN-02 beleidsmatig CLOSED.

## Besluit 36 — REGIE-POLICY-20261109-36

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Functionele documentatie inline PL/SQL, procedure-helpparameter en package-help; Confluence voor architectuur, GitHub voor techniek.

## Besluit 37 — REGIE-POLICY-20261109-37

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Risicogestuurde acceptatie/release; onderscheid intern versus extern installeren; frozen releases ongewijzigd.

## Besluit 38 — REGIE-POLICY-20261109-38

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

TETOOLS intern verantwoordelijk voor architectuur, ontwikkeling, interne acceptatie en release; externe DBA kan installatie volgens eigen beleid blokkeren, niet zelfstandig ontwerp bepalen.

## Besluit 39 — REGIE-POLICY-20261109-39

**Status:** APPROVED (beleid); technische toets: NOT_EXECUTED.

Externe release-overdracht verplicht uitsluitend punten 1,2,3,5,6,8: release-ID/versie, scripts, privileges, migratie, impact en herstel. Andere interne controles blijven waar relevant bestaan.

## Punt 40 — niet goedgekeurd

Consolidatie/consistentiecontrole van het totale beleidskader is de **volgende opdracht**. Status PENDING, niet stilzwijgend goedgekeurd. Geen modulecode, frozen release of Oracle-object gewijzigd.

## Herkomst en afbakening

Deze registratie is gebaseerd op de in de lopende chat bevestigde besluiten. Het gaat om een beleidsmatige consolidatie; concrete publieke API-signatures, foutcodes, herstelalgoritmen en Oracle/RAC-validatie blijven bij de bevoegde module-regie. Bij een verschil tussen deze samenvatting en een later geverifieerde oorspronkelijke gebruikersuitspraak moet een opvolgend correctierecord worden gepubliceerd; historische records blijven bewaard.
