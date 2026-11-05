# Inventarisatie en bronnen
## Vastgesteld op 4 november 2026
Bronchat: TETOOLS__REGIE, ID 6ae9e9eb-6400-83eb-859c-580027d25466.
De beschikbaar gestelde threadweergave bevat vijf bewaarde gespreksturns en meldt
geen oudere pagina. Dat bewijst geen volledige export van alle oorspronkelijke chats.
Gelezen main-basis: 844208c31ad98b7ba646ada5b58539c599f665b5.

- Chatturn d10b680b-06ff-419c-a487-b428cb61677f: afzonderlijke ChatGPT- en
  Codex-instructies; hier beperkt tot TETOOLS in plaats van alle ontwikkelprojecten.
- Chatturn 4f056d3f-79fb-4618-9a87-267dd14e801a: uitleg Markdown en voorstel AGENTS.md.
  Dat voorstel is inmiddels ingehaald door het aanwezige repositorybestand.
- Chatturn 28e44e37-2dbc-4bc4-a9c8-9e3a257293db: eerste diagnose van ontbrekende relay.
- Chatturn 518d7b54-0057-4069-9adc-4a2231d2d621: diagnose spiegel versus checkout;
  primaire-mapprocedure en read-only test.
- Chatturn 17c4d70c-065b-46b8-b022-61293159f9df: verzoek bibliotheek/GitHub;
  voorgestelde docs/CONFIGURATION-structuur.

Lokaal is sources/TETOOLS.ADMIN_LOGGER.zip de enige gesynchroniseerde bronfile.
Geen afzonderlijke configuratiehandleiding aangetroffen in sources/.
Het lokale root-AGENTS.md bevat spiegelregels en projectnormen; .git ontbreekt in
de huidige spiegelroot. Dit bestand is geen aantoonbaar verouderde GitHub-versie.
De persoonlijke bibliotheekmap PLSQL is op 4 november 2026 geopend:
https://chatgpt.com/library/d/6ac491ebe49c819186ec0e9b97914339?tab=folders
De zichtbare root bevat vijf modulemappen en vier overdrachtsbestanden (MD/PDF).
Het bestand 20261028__PLSQL__TETOOLS_ADMIN_OBJECTS__codex_overdracht_007.md
is gelezen: het bevat moduleontwerp en een Codex-analyseopdracht, geen
installatie- of projectconfiguratiehandleiding. De fingerprint-overdracht is
modulecontext en valt buiten deze configuratieset. De modulemappen zijn niet
uitputtend onderzocht op verborgen of anders benoemde handleidingen.
De handleidingen uit de bronchat vormen daarom de aantoonbare configuratiebasis.

## Canonieke repositorybronnen
Gebruik onderstaande paden op de genoemde basiscommit; voor nieuwe werkzaamheden
lees je opnieuw main en noteer je de dan actuele SHA.
- [AGENTS.md](../../AGENTS.md): blob 5cb3bc7de6dd6cbe4f07a5cd17143c2b9b0c5fd8.
- [Startprotocol](../../COMMUNICATION_RELAY/START_HERE_TETOOLS_REGIE.md):
  blob 29317953ba0f44b6a17a91df767287e97bfd66f4.
- [Relay-contract](../../COMMUNICATION_RELAY/RELAY_CONTRACT.md):
  blob d2d129d2510c2b8fa1d793d2fb98f6cfb2d5b4e7.
- [Actuele status](../../COMMUNICATION_RELAY/CURRENT_STATUS.md).
- [Project](../../COMMUNICATION_RELAY/PROJECT.md).
- [Module-index](../../COMMUNICATION_RELAY/MODULE_REGISTRY.md).
- [Sessies](../../COMMUNICATION_RELAY/SESSION_REGISTRY.json).
- [Wijzigingen](../../COMMUNICATION_RELAY/CHANGE_REGISTER.json).

## Externe primaire bronnen
Geraadpleegd 4 november 2026. Schermnamen kunnen per appversie verschillen.
- [OpenAI: Projects and chats](https://learn.chatgpt.com/docs/projects):
  primaire lokale map voor nieuwe chats, Git en instructiedetectie.
- [OpenAI: AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md):
  globale en directorygebonden instructies; diepere instructies kunnen specifieker zijn.
- [Git: clone](https://git-scm.com/docs/git-clone): een nieuwe lokale repository
  met remote-tracking branches; geen wijziging van een bestaande projectspiegel.
- [Git voor Windows](https://git-scm.com/install/windows): installatiebron.
- [GitHub: lokaal klonen](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository):
  clone en toegang tot private repositories.

## Correcties op eerdere uitleg
De afzonderlijke rollen zijn werkafspraken, geen exclusieve productmogelijkheden.
Custom instructions garanderen geen toegang of registratie. Een configuratietest
mag expliciet read-only blijven; een gewone werksessie volgt het relay-contract.
Geen noodzaak om AGENTS.md opnieuw aan te maken: het staat al op main via PR #16.
De oude generieke verwijzing START_HERE.md wordt voor TETOOLS vervangen door
START_HERE_TETOOLS_REGIE.md. Er is geen nieuw governancebesluit in deze documentatie.

