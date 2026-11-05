# ADMIN_OBJECTS — open punten

Leidende PoC-lijst: [revisie 004 OPEN_POINTS.md](releases/PM-001_20261103_004/OPEN_POINTS.md). De import sluit geen inhoudelijk punt uit die lijst.

Belangrijk: OP-01 CAN-001-acceptatie, OP-02 profielkeuzes/DATA_LENGTH, OP-03 identiteit, OP-04–OP-08 installatie/baseline/freshness/pakbon/autorisatie, OP-09–OP-11 historie/concurrency/lifecycle, OP-12 grenzen, OP-13 extractie, HIST-01–HIST-03 en VAL-01 Oracle-runtimebewijs. M4-01 volledige productie-installer blijft open.

Algemene ontwerpverkenning: [open punten voor hervatting](context/20261028__ADMIN_OBJECTS__ontwerpafspraken_en_hervatting.md#open-punten-voor-hervatting). Dat zijn beleids-/ontwerpvragen buiten de begrensde PoC; geen nieuwe implementatieopdracht.

REGIE noemt daarnaast een volledige retourtest tussen verschillende sessies. De onderhavige sessie leest bestaande regie-informatie en publiceert een import, maar presenteert dat niet als een gecoördineerde DEV/REVIEW-retourtest of Oracle-test. Bewaar oorspronkelijke chats bij onzekerheid.

## Overgedragen context van de oorspronkelijke HTML-001-sessie

De [sessieoverdracht](context/offloads/20261105_html001/SESSION_HANDOFF.md#open-punten-en-overdracht-van-eigenaarschap) koppelt de twaalf historische HTML-OPs aan de bestaande release-004 OPs. De gebruiker heeft in die documentatiesessie geen antwoorden op de twaalf punten gegeven. Deze offload sluit geen OP, HIST- of VAL-punt en wijzigt geen eigenaarschap van inhoudelijke ontwikkeling. Afhandeling kan vanuit GitHub plaatsvinden; de persoonlijke bewaarbeoordeling van de bron-REGIE- en implementatiesessies blijft afzonderlijk.

## Sessieoverdracht revisie 002 (2026-11-05)

- **PM002-ID-01 — ONBEKEND:** werkelijke thread-ID en onafhankelijke koppeling aan de daadwerkelijk te verwijderen chat niet betrouwbaar beschikbaar. Relay-ID `f21b235f-2680-4490-8bd4-adf5c60dda65` is expliciet lokaal gegenereerd. Bewaarstatus KEEP volgens onzekerheidsregel; geen chatverwijdering uitgevoerd. [Context en bewijs](context/session_offloads/f21b235f-2680-4490-8bd4-adf5c60dda65/20261105/SESSION_CONTEXT.md). De overgedragen moduleontwikkelpunten blijven bij release 004 en vereisen deze chat niet automatisch.
