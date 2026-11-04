# Open work

| ID | Open point | Evidence / next action |
|---|---|---|
| LOG-OPEN-01 | Review uploaded source 20261015_500 | The earlier requested analysis was blocked by environment failure; no completed report for this baseline was found in this conversation. Perform a new source review. |
| LOG-OPEN-02 | Oracle verification | Confirm target 19c release update, container, direct privileges, compilation and functional test results. No new Oracle run took place during import. |
| LOG-OPEN-03 | Installation reference 003 | Review report 030 and correct the installer through an agreed code change. Do not enable its commented DDL without resolving template and privilege defects. |
| LOG-OPEN-04 | Proposals versus uploaded source | Compare proposal 027 against 20261015_500 before accepting any change. Preserve external backup/restore behavior. |
| LOG-OPEN-05 | Suite dependency and release map | Determine actual ADMIN_LOGGER public consumers, required versions and per-module installation/test order. Shared Git storage does not decide these automatically. |

No open point is silently closed by importing files into Git.

## KT-03 relay-test (2026-11-04)

`LOGGER-KT03-20261104-001` is een **uitsluitend hypothetische testsignalering**, status PROPOSED. Er is geen defect vastgesteld. De mogelijke invloed van RAC instance-context op sessiecorrelatie is slechts een testsituatie. Dit is geen inhoudelijk open moduledefect en geen goedgekeurd architectuurbesluit. Bron: ADMIN_LOGGER__REGIE, gebruiker gaf afzonderlijk toestemming voor KT-03 op 2026-11-04.

## RELAY activity tracking — central review pending (2026-11-04)

- **Signal ID:** `LOGGER-RELAY-ACTIVITY-20261104-001` in `COMMUNICATION_RELAY/CHANGE_REGISTER.json` (`SUITE_IMPACT_SIGNAL`, `PROPOSED`).
- **Origin:** `ADMIN_LOGGER-REGIE-20261104-01`; user request for one shared session activity view, not separate RAC dashboards.
- **Central decision required:** meaning, lifecycle and schema of `current_activity` for all registered sessions. No suite-wide session registry or field semantics changed by this signal.
- **Handoff:** governed by `COMMUNICATION_RELAY/MANUAL_HANDOFF.md`; central review requested from `TETOOLS__REGIE`.
