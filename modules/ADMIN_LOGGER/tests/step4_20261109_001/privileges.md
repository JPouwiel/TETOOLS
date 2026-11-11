# Concrete dependencies and separate security principals

STATIC_SOURCE_INVENTORY only; actual grants/RU/PDB/container visibility UNVERIFIED. No grants executed or authorized. [dependencies.json](dependencies.json) records every detected package/view reference with BODY line numbers, including dynamic SQL; dependency absence from USER_DEPENDENCIES does not excuse dynamic objects. Preserve least privilege; no SELECT ANY DICTIONARY/ANY TABLE or DBA shortcut.

| Referenced object | Proposed capability to verify | Evidence / status |
|---|---|---|
| SYS.V_$SESSION (V$SESSION synonym) | Owner direct SELECT for definer compile/runtime | BODY181,195 and purge; DBA_TAB_PRIVS plus real PDB visibility; UNVERIFIED |
| SYS.DBA_SOURCE | Owner direct SELECT (or actual effective permitted object grant) for help/banner/version cursor | BODY265,364,448; no blanket dictionary role; UNVERIFIED |
| SYS.DBMS_DEBUG_JDWP | Effective EXECUTE including CURRENT_SESSION_SERIAL; confirm public/direct grant and target RU availability | BODY170; do not grant DEBUG CONNECT/ANY SESSION just for serial lookup; UNVERIFIED |
| SYS.DBMS_APPLICATION_INFO | EXECUTE READ/SET_MODULE/CLIENT_INFO; effective public/direct grant | Enumerated BODY refs; UNVERIFIED |
| SYS.DBMS_LOB | EXECUTE CLOB manipulation/compare | Enumerated BODY refs; UNVERIFIED |
| SYS.DBMS_OUTPUT | EXECUTE output buffering | Enumerated BODY refs; UNVERIFIED |
| SYS.DBMS_UTILITY | EXECUTE FORMAT_ERROR_STACK/BACKTRACE/CALL_STACK | Enumerated BODY refs; UNVERIFIED |
| SYS.DBMS_RANDOM | EXECUTE STRING | BODY106; UNVERIFIED |
| SYS.UTL_CALL_STACK | EXECUTE dynamic depth/subprogram access | Enumerated BODY refs; UNVERIFIED |
| Owner tables/sequence/package | Owner compile/DML + sequence rights in isolated owner | Source objects6 + PKS/PKB; no source change |
| GV_$SESSION/GV_$INSTANCE | Explicit observer SELECT with approved PDB/instance scope | Separate DBA observer; exact3 nodes; UNVERIFIED |
| DBA_OBJECTS/ERRORS/CONSTRAINTS/INDEXES/SOURCE/TAB_PRIVS/SYS_PRIVS/REGISTRY_SQLPATCH | Scoped observer metadata and RU evidence | OWNER filters and minimal object grants; not USER_* under another principal |

Owner installation needs CREATE SESSION/TABLE/SEQUENCE/PROCEDURE and quota on approved dedicated tablespace. Object-DDL approval is separate from possessing privileges. Partitioning availability/licensing and exact19c EE options must be DBA-confirmed.

| Role | Exact principal / permitted operations | Negative boundary |
|---|---|---|
| OWNER | TETOOLS; isolated source install/test fixtures under separate operation GO | Not a production owner/PDB |
| POSITIVE | UNVERIFIED distinct EXECUTE-only consumer | No direct table DML; maintenance through public package separately tested |
| NEGATIVE | UNVERIFIED distinct CREATE SESSION-only principal | No EXECUTE, table DML, ALTER/DROP or inherited broad roles |
| OBSERVER | UNVERIFIED distinct read-only account | No test-state changes; use DBA_/ALL_ with OWNER='TETOOLS' |
| RECOVERY | UNVERIFIED separately scoped DBA | No consumer use; destructive recovery only separate GO |

Each future authorization artifact pins the actual SESSION_USER and operation; CURRENT_SCHEMA alone does not establish identity. Scope cannot be granted by editing a private DEFINE or reusing another client's variables. Current shared gate denies every principal, including owner, because G09 NOT_GRANTED. procedures.md#security defines the positive/negative/maintenance experiment and missing wrappers/approvals. Effective public grants may satisfy standard package execution; confirm them rather than indiscriminately adding grants. Roles alone are insufficient for definer compilation requirements.
