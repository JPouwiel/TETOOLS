-- READ-ONLY INSPECTION. Run as the module owner in the selected test environment.
-- This script does not compile/install the module and does not prove runtime success.
-- Capture results with the client of your choice. VERSION_FULL identifies the RU.
SELECT banner_full FROM v$version;
SELECT object_name, object_type, status
FROM user_objects WHERE object_name LIKE 'ADMIN_TNSNAMES%'
ORDER BY object_type, object_name;
SELECT name, type, line, position, attribute, text
FROM user_errors WHERE name LIKE 'ADMIN_TNSNAMES%'
ORDER BY name, type, sequence;
SELECT name, type, referenced_owner, referenced_name, referenced_type
FROM user_dependencies WHERE name LIKE 'ADMIN_TNSNAMES%'
ORDER BY name, type, referenced_owner, referenced_name;
SELECT table_name, column_id, column_name, data_type, data_length, nullable
FROM user_tab_columns
WHERE table_name IN ('ADMIN_TNSNAMES_BASE','ADMIN_TNSNAMES_CHECKS',
 'ADMIN_TNSNAMES_PROTO_ENTRIES','TEMP_TNSNAMES_PROTO_ENTRIES')
ORDER BY table_name, column_id;
SELECT table_name, temporary, duration FROM user_tables
WHERE table_name = 'TEMP_TNSNAMES_PROTO_ENTRIES';
-- A V$VERSION access error indicates missing inspection privileges; request the
-- version from an authorised DBA. It is not evidence of a module defect.
