# Source status and installation limits

SNAPSHOT retains the package specifications, package bodies, DDL, view and
experimental FUNCTION/SQL files from the reviewed input, with documented
privacy redactions. Regular ADMIN_TNSNAMES and PROTO are distinct components.
FUNCTION and SQL contain experiments, examples and DML; do not run them as
installers. TABLE contains DDL and samples, not a verified installation flow.

No complete installation driver, privilege script or safe cleanup script was
available in this session. None is invented in this import. Missing dependencies
include SLICE_CLOB/staging/audit contracts. See ATN-001 through ATN-005 and
ATN-027 for build/contract blockers, and the remaining findings for runtime risk.
Resolve the storage model, dependencies and public access boundaries before
preparing installation, least-privilege grants, migration and cleanup scripts.
Never install this snapshot in production as-is.
