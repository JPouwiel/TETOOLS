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


## LOG-DEC-OPTION-C-20261110-001 - existing option-C decision, publication proposal (10 November 2026)

**Source decision:** already approved by the user; independently verified choice in predecessor TETOOLS__REGIE chat `6ae9e9eb-6400-83eb-859c-580027d25466`, turn `a80bab7e-1a33-48aa-bd9a-dfaec4dc6627`, followed by explicit processing assent `b94ebd42-7693-4c31-81cb-4d901f0b493e`. [Central receipt](https://github.com/JPouwiel/TETOOLS/issues/104#issuecomment-6764122808) and [central proposal assessment](https://github.com/JPouwiel/TETOOLS/issues/104#issuecomment-6764414199) are secondary traceable confirmations. No fabricated message permalink; exact turn IDs are retained.

**Publication status:** PROPOSED / NOT_MERGED / MAIN_READBACK_PENDING. Central relay reference `REGIE-LOGGER-OPTION-C-PUBLICATION-20261110-001` records the administrative proposal, not a new decision or advance APPROVED/IMPLEMENTED-publication claim. Recorded by existing executor `01a1c472-55b9-7281-882f-53425c5c8937` under [work package C](https://github.com/JPouwiel/TETOOLS/issues/104#issuecomment-6765310902); this executor is not central or module regie.

| Separate phase | Existing approved scope / authority boundary |
|---|---|
| F1 STATIC_TEST_PREPARATION | PR102 is only static test preparation. Independent full-head review plus separate central scope/mergegate assessment are required; no automatic merge or Oracle validation. |
| F2 EXECUTION_PREPARATION | Required fixtures, procedures, regression/consumers/027, privileges and recovery preparation with reviewed relevant G01-G08 evidence; no runtime authorization. |
| F3 ORACLE_RAC_VALIDATION | Actual Oracle19c EE / three-node RAC validation only after separate explicit G09 and required DBA acceptances; evidence must be genuinely executed. |
| F4 MODULE_RAC_ACCEPTANCE | Required separately authorized source corrections, regression/retest, risk handling and explicit central final module/RAC_READY decision; no derivation from an earlier phase. |

The full [module matrix](docs/reports/ADMIN_LOGGER_OPTION_C_ACCEPTANCE_MATRIX_20261110.md) is preserved byte-for-byte from PR109 head `9a80050352585cf2aed5b957022478fffbda0bbb`, blob `99fadc9f43329fbb39bc34b1699860aa209bbae4`. It remains a documentation/co-ordination proposal accepted as such by central comment6764414199, not approval of concrete functional norms, numeric performance/RTO limits, fixtures, grant identities or implementation. No competing decision register is introduced.

LGR4-04/05/10/11, eleven dependencies and C02-C06 remain BLOCKED pending evidence. G01-G08 remain open; G09 NOT_GRANTED. Existing module-regie ADMIN_LOGGER-REGIE-20261104-01 owns technical work with DBA/security/consumers; current TETOOLS__REGIE owns central decisions and mergegate. LOGGER-RAC-20261105-001/Issue55 and historical reviews/FAILs are preserved. No code/tests/frozen/public API/datatype/grant changes, no merge or Oracle execution. [Publication comparison and remaining central review questions](../../COMMUNICATION_RELAY/reviews/LOGGER_OPTION_C_PUBLICATION_20261110.md).
