# Least-privilege / direct-grant matrix — proposed, DBA validation required

| Principal | Privilege / object | Purpose | Gate |
|---|---|---|---|
| Disposable owner TETOOLS | CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE PROCEDURE; quota on dedicated tablespace | DDL-only clean installation | DBA to authorize |
| TETOOLS package owner | direct SELECT on SYS.V_$SESSION; any other SYS.V_$* or DBA views actually referenced in PKB | AUTHID DEFINER compile/runtime | Derive exact list by static dependency scan + DBA review; roles insufficient |
| DBA observation principal | read-only access to USER_OBJECTS/USER_ERRORS/USER_INDEXES/USER_CONSTRAINTS in owner; GV_$INSTANCE/GV_$SESSION, DBA_REGISTRY_SQLPATCH as needed | T02/T07 evidence | direct minimum grants, verify CONTAINER_DATA visibility |
| Consumer test principal | EXECUTE on TETOOLS.ADMIN_LOGGER only | positive API | no object DML by default |
| Negative test principal | CREATE SESSION; no EXECUTE on package, no direct table DML, no ALTER/DROP | privilege denial | must be separate principal |
| DBA recovery principal | tightly scoped authorized teardown/restore rights | T08/90_cleanup | not granted to consumers |
| DBA test operator | ability to inspect locks/metrics (licensed features only after approval) | T06/T07 | DBA/security confirmation |

Avoid SELECT ANY DICTIONARY, ANY TABLE, DBA role or broad privileges as a shortcut. `AUTHID DEFINER` confirmed in source SPEC; effective privileges and external dependencies **UNVERIFIED**. DBA must inventory actual package references before a grant request. Negative tests must not accidentally run under owner or SYS.
