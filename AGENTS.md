# AGENTS.md — PL/SQL TETOOLS

## Project identity

- Project: PLSQL_TETOOLS
- Repository: JPouwiel/TETOOLS
- Platform: Oracle Database 19c Enterprise
- Governance: TETOOLS__REGIE
- Modules: ADMIN_* packages and supporting database objects

## Mandatory COMMUNICATION_RELAY

Before starting project work:

1. Read `COMMUNICATION_RELAY/START_HERE_TETOOLS_REGIE.md`.
2. Read `COMMUNICATION_RELAY/RELAY_CONTRACT.md`.
3. Read `COMMUNICATION_RELAY/CURRENT_STATUS.md`.
4. Read the relevant module status, decisions and open points.
5. Check open suite-impact signals in `COMMUNICATION_RELAY/CHANGE_REGISTER.json`.
6. Register the session according to the relay contract when authorized GitHub access is available.

Follow the relay contract throughout the task.

Do not assume automatic synchronization between ChatGPT, Codex or other sessions.

## Scope and authority

- Work only within the explicitly approved task scope.
- Treat approved suite-wide architecture decisions as the default baseline.
- Respect module-specific decisions and documented exceptions.
- Do not approve new architecture decisions independently.
- Do not modify frozen releases without explicit authorization.
- Do not import information from unrelated projects.

## Oracle 19c development

- Target Oracle Database 19c Enterprise unless explicitly instructed otherwise.
- Consider the documented RAC target architecture where relevant.
- Prioritize correctness, compatibility, concurrency safety and efficiency.
- Preserve existing behavior unless a functional change is approved.
- Explain significant SQL/PLSQL changes and relevant trade-offs.
- Reuse existing routines and variables where appropriate.
- Clearly identify changes to public interfaces, datatypes, grants or database objects.

## Suite-impact signaling

When a finding may affect multiple ADMIN_* modules:

1. Document the originating module and evidence.
2. Identify possible cross-module consequences.
3. Distinguish verified facts from assumptions.
4. Register a `SUITE_IMPACT_SIGNAL` according to the relay contract.
5. Refer the matter to TETOOLS__REGIE for architectural assessment.

Confirmed impact is not required before raising a signal.

The originating module retains responsibility for its technical investigation.

## Changes and verification

- Inspect the existing source and repository state before editing.
- Use the branch and pull-request workflow defined by the relay contract.
- Keep source changes separate from unrelated refactoring.
- Run relevant validation and tests when the required environment is available.
- Never claim Oracle compilation or runtime validation without actual execution.
- Report tests that were not executed and explain why.
- Verify GitHub commits, merges and published files before claiming completion.

## Completion and handover

Before finishing:

1. Record relevant results, decisions and unresolved issues.
2. Update relay records as required.
3. Record test and verification status.
4. Identify remaining dependencies and required approvals.
5. Verify published changes against the repository.
6. Report incomplete operations explicitly.

If GitHub access is unavailable, report the limitation and prepare the pending relay updates without claiming publication.

## Source of truth

This file is a repository entry point, not a replacement for the relay contract.

For detailed procedures, registration formats, lifecycle rules and verification requirements, use the current documents under `COMMUNICATION_RELAY/`.

If instructions conflict or the required source is missing, report the conflict before making consequential changes.
