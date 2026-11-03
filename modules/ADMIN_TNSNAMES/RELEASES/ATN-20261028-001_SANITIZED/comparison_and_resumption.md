# ADMIN_TNSNAMES and ADMIN_OBJECTS — comparison and resumption

Status: comparative analysis and concept, not implementation. Oracle Database 19c. Source snapshot: see manifest.json. The user approved the analysis and explicitly authorised reading the same-project chat “Oracle tabelstructuur vergelijken”. No message was sent to that chat.

## Retrieved design context

Read through the chat tool: conversation 6ae1c678-2a98-83ed-99b0-c8895440f708. The accessible record contains five completed turns and states that no older page is available. The linked sandbox PDF/Markdown handover files were not retrieved; no claim is made that their contents were independently read. Use the actual user statements, not the earlier assistant's claim that a Library save succeeded, as design evidence.

The user agreed to distinguish the profile manifest from the object manifest. Store profile definitions with their name, subject, version and other metadata. Object manifests are mainly useful on a discrepancy and must be regenerable on demand. The earlier procedure interface was expressly outside implementation scope. The later user proposed ADMIN_TNSNAMES as context for the manifest design and possible improvements to both modules. Assistant proposals for ON_CHANGE history, an extra history table or a common utility package are not adopted user decisions.

## Result

The similarity is substantial at the design level and limited at the executable-code level. The reference/attribute/check/value separation in ADMIN_TNSNAMES is a useful predecessor to profile/property/normalisation/value separation. The current PROTO pipeline is not a lossless parser or canonical serialiser. It removes characters, operates on physical lines, filters unknown lines, does not keep parent instance identity in final PROTO rows, and aggregates without an explicit array order. The supplied current body also has compile and schema-contract blockers. These facts prevent direct reuse as a reliable object fingerprint engine.

ADMIN_OBJECTS currently obtains DDL and applies STANDARD_HASH(...,'MD5') at original body lines 1049–1050. This is a different implementation from the proposed metadata-profile generator. The source is the dated local body 20261012_001; deployed state is unknown. STANDARD_HASH does not accept a LOB expression. DBMS_METADATA output and formatting also do not automatically implement the user's profile equivalence rules.

## Mapping

| Concern | TNS source | Object-manifest application | Reuse decision |
|---|---|---|---|
| Documentation | ADMIN_TNSNAMES_REFERENCE | Profile meaning and source documentation | Reuse the principle; do not reuse TNS names or rows |
| Definitions | ATTRIBUTES: type, parent, sort, mandatory, multiplicity | Section/property ID, datatype, extractor, normalisation, significance | Extend the concept with immutable profile version and explicit policy |
| Rules | CHECKS: pattern/procedure, target and description | Approved typed extractor and normaliser IDs | Reuse controlled dispatch; do not execute arbitrary profile SQL |
| Instance values | ENTRIES with hierarchy definition IDs; PROTO key/value rows | Typed properties with stable identity and semantic position | Add instance identity where repeated nodes exist |
| Parsing | Text/line splitting and regex checks | Dictionary extraction | Keep domain-specific adapters; dictionary data does not require a TNS parser |
| Ordering | Input order and definition HIERARCHY_SORT | Profile section/property order plus semantic element key | Reuse explicit ordering principle; distinguish syntax order from meaning |
| Rendering | GENERATE_TEMPLATE prints examples | Human-readable object manifest | Keep separate from canonical bytes; both must use the same normalised records |
| Persistence | Registration, staging and audit | Ledger fingerprint plus selective diagnostic manifest | Do not share mutation/commit logic |
| Hashing | No canonical fingerprint path found in the main/PROTO packages | Versioned fingerprint over selected typed values | New contract required; no proven function to copy |

## Proposed common contract, for review

Domain extraction → complete typed records → domain validation → domain normalisation → explicit ordering → unambiguous UTF-8 byte encoding → SHA-256 and readable rendering.

The normalised record needs section ID, stable element key, semantic position where relevant, property ID, value type and value. TNS additionally requires instance node ID, parent node ID and sibling position for repeated ADDRESS/DESCRIPTION branches. Do not use a definition ID or a global sequence number as an instance position. Oracle dictionary extraction should retain quoted identifier case and relevant column/key positions. Do not uppercase arbitrary values or rewrite expression text using whitespace regexes.

A format header must identify profile, profile version, canonical format version and algorithm. Decide whether object owner/name belong to content identity or to the comparison envelope; deployment-equivalent objects in different schemas can otherwise produce unwanted differences. Define byte lengths after AL32UTF8 conversion, numeric/date encoding independent of NLS, NULL/missing/empty-LOB treatment, tie-breaking, duplicate rejection and unsupported-property handling. Oracle treats empty VARCHAR2 as NULL, so the illustrated abstract empty string cannot automatically become a distinct Oracle VARCHAR2 value.

## Ordering is domain-specific

| Case | Proposed rule | Reason |
|---|---|---|
| TNS addresses with LOAD_BALANCE=OFF | Preserve sibling order | Oracle tries addresses sequentially |
| LOAD_BALANCE=ON | Initially preserve order too; do not claim unordered equivalence | Random selection does not prove all descriptor reorderings or duplicate handling equivalent |
| Nested LOAD_BALANCE/defaults | Resolve only with node context and profile version | Oracle defaults differ for DESCRIPTION_LIST and DESCRIPTION/ADDRESS_LIST |
| Independent manifest properties | Sort by immutable section/property IDs | Dictionary retrieval order is not a contract |
| Table columns | Profile decides relevance; retain position if selected | Reordering can affect positional consumers |
| Composite key columns | Preserve key position | Key/index structure can depend on order |
| System-generated constraint names | Profile decides whether to ignore name; sort by semantic identity if ignored | Randomly assigned names should not silently define equivalence |

## Applied local checks

Seven illustrative byte-contract checks were executed and passed: irrelevant record input order, relevant position change, NULL versus literal NULL, unambiguous field boundaries, profile identity, UTF-8 byte length and a 50,000-character value. See canonical_examples_results.json for the actual hashes. These tests demonstrate proposed encoding principles only. They do not execute the supplied PL/SQL, establish TNS semantic equivalence, prove Oracle character conversion or validate an implemented manifest generator.

## Oracle acceptance matrix — not executed

1. Build every selected module component in an isolated Oracle 19c environment and capture USER_ERRORS and dependencies. Establish exact RU support for JSON_TRANSFORM and SQL_MACRO experimental syntax rather than assuming every 19c installation supports the same features.
2. TNS: equivalent multiline/single-line formatting must produce the same validated tree; unknown syntax must be rejected with location; round-trip repeated branches must retain parentage and address order. Change LOAD_BALANCE placement and swap sequential addresses; require an appropriate semantic difference.
3. Object manifest: shuffle irrelevant dictionary row order and require identical bytes; change a selected type, precision or key position and require different bytes. Include quoted identifiers, multibyte data, large LOBs and NLS changes.
4. Hashing: compare explicit AL32UTF8 bytes with an independent SHA-256 implementation. Do not truncate a CLOB to fit STANDARD_HASH. Review DBMS_CRYPTO grants and temporary-LOB cleanup.
5. Consistency: provoke DDL while extracting metadata. Incomplete or inconsistent extraction must produce a separate error, not a missing-object finding, accepted fingerprint or automatic approval.
6. Persistence: generation with and without diagnostic storage must produce identical canonical bytes/hash. A regenerated current manifest is not evidence of an earlier state after DDL changed.
7. Efficiency: measure one parse/extraction per input, bulk rule loading per profile/version, bounded dictionary queries, deterministic local sorting and LOB volume. Benchmark representative small/large descriptors and tables before sharing a utility. No timings have been measured here.

## Open decisions and next work

1. Confirm the TNS registration storage model: current hierarchy or a deliberate wide-table migration. Do not produce incompatible fixes for both models.
2. Define the supported TNS grammar and how comments, alias lists, suffixes and repeated branches are represented.
3. Define profile identity, immutable revisioning, content selectors, severity and the rule for expected-baseline approval. Keep evaluation policy outside a hash; a hash has no severity semantics.
4. Fix stable identity versus semantic position, case rules, NULL/missing/empty rules and numeric/date/Unicode byte representation.
5. Decide which object properties affect fingerprints, including column order, constraint names, storage and partitioning. Start with one simple table profile before expanding.
6. Confirm discrepancy-only diagnostic retention. Do not add an always-on manifest history table or ON_CHANGE policy based only on the earlier assistant proposal.
7. Inventory callers and preserve behaviour where documented. Define regression cases before moving public routines or consolidating shared code.
8. Only after the domain tests pass, identify a genuinely identical, small, pure serialisation/hash operation worth sharing. Keep extraction, TNS validation, object profiles, ledger mutations and transactions separate.

The comparison is now performed at source/design level. Production manifest procedures, schema changes, a shared package and Oracle runtime tests remain unimplemented; this matches the conceptual scope. All original sources remain unchanged.

## Primary technical references

- Oracle 19c local naming parameters: https://docs.oracle.com/en/database/oracle/oracle-database/19/netrf/local-naming-parameters-in-tns-ora-file.html
- Oracle 19c STANDARD_HASH: https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/STANDARD_HASH.html
- Oracle 19c DBMS_CRYPTO: https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_CRYPTO.html
- Oracle 19c JSON_ARRAYAGG: https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/JSON_ARRAYAGG.html
