# AGENTS.md gebruiken en veilig bewerken
AGENTS.md is UTF-8-tekst met Markdown-koppen en lijsten. Een gewone editor volstaat.
Het bestand bestaat al in de root van JPouwiel/TETOOLS; maak geen tweede actuele
kopie onder docs en overschrijf het bestaande bestand niet met het oude chatvoorstel.

## Exacte inhoud bekijken
Open https://github.com/JPouwiel/TETOOLS/blob/main/AGENTS.md.
Klik op Raw om de exacte actuele tekst te lezen of op te slaan.
Via clone komt die tekst automatisch in de lokale repositoryroot.
De inventarisatie noteert de gelezen blob-SHA; de actuele tekst op main is leidend.

## Een wijziging voorstellen, alleen bij een afzonderlijke inhoudelijke opdracht
1. Werk in de echte checkout en controleer git status.
2. Maak een eigen branch vanaf bijgewerkte main.
3. Open het bestaande AGENTS.md in Kladblok of een teksteditor.
4. Bewaar als UTF-8 met exact de naam AGENTS.md, zonder .txt.
   Zet in Verkenner Beeld > Weergeven > Bestandsnaamextensies aan ter controle.
5. Controleer de diff; open een PR en werk de relay bij waar nodig.
6. Controleer na de merge opnieuw main en start een nieuwe sessie.

Als het bestand onverwacht ontbreekt: controleer branch en repository eerst.
Alleen in een gecontroleerde nieuwe branch kan je via GitHub Add file > Create
new file een root-AGENTS.md voorstellen. Voor deze bestaande repository is dat
niet nodig. Kopieer het spiegelbestand niet naar de checkout: het bevat regels
voor een ander type werkmap.

Codeblokken in deze documentatie zijn monospace; de PDF gebruikt Courier New 11.
De app bepaalt het font van Markdown. Er is geen kleurlegenda nodig omdat kleuren
geen inhoudelijke betekenis hebben.

