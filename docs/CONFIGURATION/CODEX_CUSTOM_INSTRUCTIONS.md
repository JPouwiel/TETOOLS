# Codex-instructies voor TETOOLS
De betrouwbaarste repositorygebonden ingang is het bestaande root-AGENTS.md.
Je hoeft geen globaal Codex-instructiebestand te maken voor dit ene project.
Als jouw app een afzonderlijk veld Codex Custom Instructions toont, voeg dan de
onderstaande voorwaardelijke tekst daar toe. Is dat veld afwezig, gebruik de
projectinstructies en root-AGENTS.md; verzin geen nieuwe instelling.

```text
Alleen binnen PL/SQL TETOOLS / JPouwiel/TETOOLS:
Controleer eerst werkdirectory, Git-root, remote, branch, HEAD en lokale wijzigingen.
Lees het root-AGENTS.md, het TETOOLS-startprotocol, het relay-contract en alle
daarin verplichte actuele registers. Noteer basiscommit en echte sessie-ID;
gebruik anders een expliciet als lokaal gegenereerd gemarkeerde UUID.
Werk uitsluitend binnen de opdracht, via branch en PR. Volg de relay-registratie.
Bij expliciete read-only diagnose: niets schrijven en die uitzondering rapporteren.
Respecteer Oracle 19c, bestaande architectuur en bevroren releases.
Onderbouw wijzigingen; geef commentaar bij complexe code en weeg efficiëntie mee.
Leg relevante bevindingen en mogelijke suite-impact vast volgens het contract.
Voer beschikbare toepasselijke controles uit en meld ontbrekend runtimebewijs.
Verifieer publicatie en na merge main. Claim geen succesvolle uitvoering op basis
van een plan of toolaanroep alleen. Lever open punten en overdracht op.
```

Globale AGENTS-instructies kunnen ook invloed hebben; een diepere directory kan
aanvullende regels hebben. Laat een nieuwe sessie alle werkelijk gebruikte paden
rapporteren. Zie [OpenAI AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md).

