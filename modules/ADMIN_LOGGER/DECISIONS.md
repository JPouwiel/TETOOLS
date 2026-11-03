# ADMIN_LOGGER decisions and requirements

## LOG-DEC-01 - Central suite repository / module location

Status: user requested on 2026-11-03 in the current ADMIN_LOGGER conversation.
Source: "Wil jij de laatste versie en data toevoegen aan de repository
jpouwiel/TETOOLS/modules/ADMIN_LOGGER". The exact thread ID is not exposed.
Implementation must follow the repository branch/PR contract. A monorepo is the
recommended storage arrangement; independent deployment/versioning is retained.

## LOG-REQ-01 - Preserve external temporary configuration control

Source: user explanation in this conversation on 2026-10-14.
The public backup/restore contract of session_details_revert is intentional.
No internal call does not establish dead code. Do not remove that API merely
because a static package-local call count is zero.

## LOG-REQ-02 - Oracle and evidence scope

Oracle Database 19c EE. Preserve uploaded behavior unless a functional change is
explicitly accepted. Mark assumptions and design choices. New source uploads,
historical findings and proposed replacements are distinct baselines.
No compile/runtime/performance success without actual Oracle evidence.

## LOG-REQ-03 - Report presentation

Source: reporting agreements in this conversation, including the copied prompt.
Use standalone STE-inspired HTML, fixed finding IDs, source-line references,
footnotes, search/filters, cross-links between analysis/deepening/solutions,
and honest old/new/add/delete marking. Public overloads require signature-level
classification; side effects must be considered before declaring code unused.
