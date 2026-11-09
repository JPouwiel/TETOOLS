# ADMIN_LOGGER — LDR-02: twee DDL-installatieblokkers

**Status:** PROPOSED_ONLY / NO_SOURCE_CHANGE / Oracle NOT_EXECUTED. Canonieke bron: [TABLE](../../src/20261015_500/TABLE/TAB_TETOOLS_ADMIN_LOGGER__20261015_202.sql), blob `240b6516fcfd7e9a99ae7d47bb18433f77a8686f`. Baseline `20261015_500`. Dit is een concept, niet een opdracht tot uitvoering.

## RAC-A-010 (P1) — index vóór tabel

**Exacte plaats:** regels **86–91** maken `tetools.admin_logger_position_uk` op `tetools.admin_logger_log`; de doeltabel wordt pas op **108–126** aangemaakt. De index `admin_logger_active_batch_uk` op CONFIG (83–84) staat wel na zijn tabel (54–81).

**Faalconditie:** schone TETOOLS-schema-installatie zonder bestaande LOG-tabel, uitvoering op volgorde. De index kan niet worden aangemaakt voordat zijn tabel bestaat (verwachte object-not-found fout, exacte Oracle foutcode NOT_EXECUTED). Een client die na fout doorgaat kan een LOG-tabel zonder de beoogde unieke batchpositie-index achterlaten.

**Minimaal voorstel:** verplaats de bestaande indexstatement inclusief `/` van 86–91 naar direct **na** LOG-tabelterminator regel 126; behoud naam, drie CASE-expressies en UNIQUE. Alternatief: aparte index-installatiefase na alle CREATE TABLE statements; groter wijzigingsoppervlak.

**Impact:** DDL-volgorde, geen beoogde runtime/API-wijziging. Schone installatie testen met fail-fast SQL-client, controle USER_INDEXES en USER_IND_EXPRESSIONS, en negatieve test op dubbele niet-NULL batchpositie. Een bestaande tabel kan het defect maskeren; bestaande data kan duplicaten bevatten. Geen scriptblind heruitvoeren in bestaand schema.

**Rollback:** disposable testschema herstellen via snapshot of goedgekeurde reverse-order DDL; bestaande database vereist voorafgaande back-up en afzonderlijk migratieplan. Oracle DDL commit impliciet; SQL ROLLBACK volstaat niet.

## RAC-A-011 (P1) — ontbrekende komma

**Exacte plaats:** TABLE regel **163** `config_snapshot CLOB`, onmiddellijk gevolgd door regel **164** `CONSTRAINT admin_logger_incident_pk PRIMARY KEY (incident_id) ENABLE` zonder scheidingskomma; volledige CREATE TABLE regels **141–167**.

**Faalconditie:** uitvoeren van deze CREATE TABLE statement als geschreven; parser kan de kolomdefinitie en tabelconstraint niet scheiden. Exacte ORA-code NOT_EXECUTED. De afhankelijke incident/repair-diagnostiek in BODY 553–628 kan daarna falen.

**Minimaal voorstel:** één komma na `config_snapshot CLOB`; laat kolommen, constraint en semantiek intact. Alternatief: aparte ALTER TABLE ADD CONSTRAINT, met meer installatiestappen en fouttoestanden. Verifieer USER_CONSTRAINTS/USER_CONS_COLUMNS en insert/PK-negatieve test. De naam `admin_logger_incident_context_ck` controleert feitelijk `status`; hernoemen is **buiten scope**.

**Rollback:** geen automatische DROP in bestaand schema. Alleen disposable schema herstellen of afzonderlijk goedgekeurde migratie/herstelactie.

## Niet-toegepaste conceptdiff

```diff
--- a/TABLE/TAB_TETOOLS_ADMIN_LOGGER__20261015_202.sql
+++ b/TABLE/TAB_TETOOLS_ADMIN_LOGGER__20261015_202.sql
@@ remove before CREATE TABLE admin_logger_log (old lines 86-91)
-CREATE UNIQUE INDEX tetools.admin_logger_position_uk ON tetools.admin_logger_log (
-  CASE WHEN logbatch_id>0 AND log_lines>0 THEN logsession_id END,
-  CASE WHEN logbatch_id>0 AND log_lines>0 THEN logbatch_id END,
-  CASE WHEN logbatch_id>0 AND log_lines>0 THEN log_lines END
-)
-/
@@ insert immediately after log CREATE TABLE terminator (old line 126)
+CREATE UNIQUE INDEX tetools.admin_logger_position_uk ON tetools.admin_logger_log (
+  CASE WHEN logbatch_id>0 AND log_lines>0 THEN logsession_id END,
+  CASE WHEN logbatch_id>0 AND log_lines>0 THEN logbatch_id END,
+  CASE WHEN logbatch_id>0 AND log_lines>0 THEN log_lines END
+)
+/
@@ incident table (old line 163)
-  config_snapshot    CLOB
+  config_snapshot    CLOB,
   CONSTRAINT admin_logger_incident_pk PRIMARY KEY (incident_id) ENABLE,
```

**Legenda:** `-` = oorspronkelijke regel op oude locatie; `+` = concepttoevoeging/verplaatsing. Geen sourcebestand gewijzigd. Bij latere implementatie behoud van oorspronkelijke CRLF en exacte SQL-client slash-terminators verifiëren.

**Pilotbeoordeling:** beide blokkades zijn als één kleine zelfstandige DDL-scriptcorrectie geschikt, **onder voorwaarde** van een nieuw niet-bevroren ontwikkelrevisiepakket, clean-install harness, aparte goedkeuring en testomgeving. Dit verhelpt niet de overige RAC-bevindingen en verleent geen RAC_READY of releaseautorisatie. Zie [RAC rapport A](20261105__PLSQL__TETOOLS_ADMIN_LOGGER__RAC_analyse_A_20261015_500_STE_033.html), secties RAC-A-010/011.
