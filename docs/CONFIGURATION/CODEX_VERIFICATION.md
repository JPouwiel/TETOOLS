# Controle na inrichting
Start een nieuwe lokale chat vanuit PL/SQL TETOOLS nadat de checkout primair is.
Kopieer deze testopdracht:

```text
Voer uitsluitend een read-only configuratietest uit voor JPouwiel/TETOOLS.
Wijzig niets: geen sessieregistratie, commits, pushes, PR's of instellingen.
Rapporteer werkdirectory, Git-root, origin zonder credentials, branch en HEAD.
Lees AGENTS.md vanuit de Git-root en meld alle gebruikte instructiebestanden.
Lees COMMUNICATION_RELAY/START_HERE_TETOOLS_REGIE.md en RELAY_CONTRACT.md,
CURRENT_STATUS.md, PROJECT.md, MODULE_REGISTRY.md en beide JSON-registers.
Controleer de verplichte registratieprocedure en SUITE_IMPACT_SIGNAL.
Lees dezelfde bronnen via GitHub vanaf main en noteer de main-commit.
Vergelijk de lokale versie met GitHub; meld een afwijkende branch of commit.
Geef per controle GEVONDEN, NIET GEVONDEN of NIET GECONTROLEERD met bewijs.
Meld uitdrukkelijk dat deze diagnose door het schrijfverbod niet is geregistreerd.
Toon geen tokens of andere geheimen.
```

Geslaagd: de root is de bedoelde checkout, origin is TETOOLS, root-AGENTS.md en
relay zijn gelezen. Een bewuste werkbranch mag afwijken van main; verklaar dat.
Een geslaagde read-only test bewijst geen schrijfrechten of Oracle-runtime.
Een test vanuit de oude spiegel zegt niets over de configuratie van een nieuwe chat.

## Storingen
- Spiegelpad als root: projectmap opnieuw primair maken; daarna nieuwe chat.
- AGENTS.md ontbreekt: branch/root controleren; niet de spiegel aanpassen.
- Relay ontbreekt: controleer bestanden op main en of clone/update volledig is.
- GitHub leesbaar maar clone faalt: lokale authenticatie afzonderlijk herstellen.
- Register aanwezig maar geen sessie-entry: registratie is niet automatisch.
- PR open: branchpublicatie mogelijk, registratie op main nog niet bevestigd.

