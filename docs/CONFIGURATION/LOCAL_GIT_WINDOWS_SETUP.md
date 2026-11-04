# Lokale Git-checkout op Windows
## 1. Voorbereiden
Open Windows PowerShell. Gebruik een eigen werkmap, buiten de ChatGPT-projectspiegel.
Onderstaande locatie is een voorstel, geen aangetroffen checkout.

```powershell
git --version
```

Als Git niet wordt herkend: installeer Git voor Windows via https://git-scm.com/install/windows
en open PowerShell opnieuw. Gebruik de gebruikelijke HTTPS/Git Credential Manager-
aanmelding als Git daarom vraagt. Meld je zelf aan; plaats geen token in een URL.
De GitHub-plugin in ChatGPT verzorgt deze lokale authenticatie niet.

## 2. Nieuwe checkout
Voer regel voor regel uit. Stop bij een fout; ga dan niet door met volgende regels.

```powershell
$tetoolsParent = Join-Path $env:USERPROFILE 'GitHub'
$tetoolsRepo = Join-Path $tetoolsParent 'TETOOLS'
New-Item -ItemType Directory -Force -Path $tetoolsParent
Test-Path -LiteralPath $tetoolsRepo
```

Is de laatste uitkomst True? Clone daar niet overheen. Controleer eerst of dit de
bedoelde bestaande checkout is met stap 3. Gebruik anders een andere lege locatie.
Bij False:

```powershell
git clone --branch main https://github.com/JPouwiel/TETOOLS.git $tetoolsRepo
Set-Location -LiteralPath $tetoolsRepo
```

Clone maakt een lokale kopie; deze opdracht publiceert niets naar GitHub. [Git clone]
(https://git-scm.com/docs/git-clone).

## 3. Controle
```powershell
Get-Location
git rev-parse --show-toplevel
git remote get-url origin
git branch --show-current
git rev-parse HEAD
git status --short
Test-Path -LiteralPath '.\AGENTS.md'
Test-Path -LiteralPath '.\COMMUNICATION_RELAY\RELAY_CONTRACT.md'
Get-Content -LiteralPath '.\AGENTS.md'
```

Verwacht: root eindigt op GitHub/TETOOLS, origin is JPouwiel/TETOOLS, branch main,
status leeg en beide Test-Path-resultaten True. Een SSH-remote naar dezelfde
repository is ook geldig als die bewust is ingericht. Noteer HEAD; de actuele
main-SHA kan afwijken van de inventarisatiebasis.

Bij 'not a git repository': controleer de map, maak geen git init in de spiegel.
Bij 'Repository not found': controleer account en toegang tot JPouwiel/TETOOLS.
Bij lokale wijzigingen: beoordeel ze voordat je branch of bestanden vervangt.

## 4. Latere updates
Alleen vanuit een schone checkout, en na controle dat main de juiste branch is:

```powershell
git switch main
git pull --ff-only origin main
```

Een fout bij --ff-only vraagt onderzoek naar de lokale historie; forceer geen reset.
Selecteer daarna de checkout als primaire map volgens het projecthoofdstuk.

