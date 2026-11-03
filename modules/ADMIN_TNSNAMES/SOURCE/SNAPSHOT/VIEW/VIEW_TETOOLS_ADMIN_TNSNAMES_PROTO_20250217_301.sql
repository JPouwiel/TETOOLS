CREATE OR REPLACE VIEW tetools.admin_tnsnames_proto_checks
AS
SELECT q2.proto_tns_id
     , q2.order_id
     , q2.REF_ATTR
     , q2.TNS_ATTR
     , q2.TNS_ATTR_VALUE
     , q1.TNS_ATTR_CHECK
     , q1.TNS_ATTR_CHECK_TYPE
     , q1.GT_ONE_OCC
     , q1.TNS_ATTR_STATEMENT
     , q2.proto_tns_entry_line
  FROM (
         (SELECT TNS_ATTR, TNS_ATTR_CHECK, TNS_ATTR_STATEMENT, GT_ONE_OCC, TNS_ATTR_CHECK_TYPE
            FROM ADMIN_TNSNAMES_CHECKS
           WHERE TNS_ATTR_CHECK = 'ATTRIBUTE') q1
          INNER JOIN
         (WITH cte AS (
            SELECT PROTO_TNS_ID, proto_tns_order_line AS "ORDER_ID"
                 , CASE
                     WHEN admin_tnsnames_attr_proto_vald(proto_tns_entry_line, '^([[:space:])]*)?#{1}.*').tns_attr_status  = 'VALIDATED'                                                     THEN 'ENTRY_DESCRIPTION'
                     WHEN admin_tnsnames_attr_proto_vald(proto_tns_entry_line, '^([[:space:])]*)?\w+(\s)?=([[:space:])]+)?$').tns_attr_status  = 'VALIDATED' AND proto_tns_order_line <= 2   THEN 'NET_SERVICE_NAME'
                     WHEN regexp_replace(LTRIM(regexp_substr(TRIM(BOTH ' ' FROM proto_tns_entry_line), '^([[:space:](]*)\w+'), '(' ), '[_]{1}[1-9]{1}$', '') IS NOT NULL                     THEN regexp_replace(LTRIM(regexp_substr(TRIM(BOTH ' ' FROM proto_tns_entry_line), '^([[:space:](]*)\w+'), '(' ), '[_]{1}[1-9]{1}$', '')
                     ELSE 'INVALID_ATTRIBUTE'
                   END REF_ATTR
                 , CASE
                     WHEN admin_tnsnames_attr_proto_vald(proto_tns_entry_line, '^([[:space:])]*)?#{1}.*').tns_attr_status  = 'VALIDATED'                                                     THEN 'ENTRY_DESCRIPTION'
                     WHEN admin_tnsnames_attr_proto_vald(proto_tns_entry_line, '^([[:space:])]*)?\w+(\s)?=([[:space:])]+)?$').tns_attr_status  = 'VALIDATED' AND proto_tns_order_line <= 2   THEN 'NET_SERVICE_NAME'
                     WHEN regexp_replace(LTRIM(regexp_substr(TRIM(BOTH ' ' FROM proto_tns_entry_line), '^([[:space:](]*)\w+'), '(' ), '[_]{1}[1-9]{1}$', '') IS NOT NULL                     THEN LTRIM(regexp_substr(TRIM(BOTH ' ' FROM proto_tns_entry_line), '^([[:space:](]*)\w+'), '(' )
                     ELSE 'INVALID_ATTRIBUTE'
                   END TNS_ATTR
                ,  CASE
                     -- ENTRY DESCRIPTION 
                     WHEN admin_tnsnames_attr_proto_vald(TRIM(BOTH ' ' FROM proto_tns_entry_line), '^([[:space:])]*)?#{1}.*').tns_attr_status  = 'VALIDATED'                                                                                                               THEN admin_tnsnames_attr_proto_vald(TRIM(BOTH ' ' FROM proto_tns_entry_line), '^([[:space:])]*)?#{1}.*').tns_attr_name
                     -- DESCRIPTION  / DESCRIPTION_LIST 
                     WHEN admin_tnsnames_attr_proto_vald(TRIM(BOTH ' ' FROM proto_tns_entry_line), '^([[:space:])]*)?\w+(\s)?=([[:space:])]+)?$').tns_attr_status  = 'VALIDATED'  AND proto_tns_order_line <= 2                                                            THEN admin_tnsnames_attr_proto_vald(TRIM(BOTH ' ' FROM proto_tns_entry_line), '^([[:space:])]*)?\w+(\s)?=([[:space:])]+)?$').tns_attr_name
                     -- DATE_VALID_FROM / DATE_VALID_TILL
                     WHEN admin_tnsnames_attr_proto_vald(TRIM(BOTH ' ' FROM proto_tns_entry_line), '^\s*[(]?\w+(\d{1})?(\s)?=[[:space:]]?(sysdate|(9999|20[0-9]{2})-(1[0-2]|0[0-9])-(0[1-9]|[1-2][0-9]|3[0-1]))([)])?*$').tns_attr_status  = 'VALIDATED'                   THEN regexp_substr(TRIM(BOTH ' ' FROM proto_tns_entry_line ), '(sysdate|(9999|20[0-9]{2})-(1[0-2]|0[0-9])-(0[1-9]|[1-2][0-9]|3[0-1]))')
                     -- NON-LEAF MEMBERS
                     WHEN admin_tnsnames_attr_proto_vald(TRIM(BOTH ' ' FROM proto_tns_entry_line), '^\s*[(]?\w+(\s)?=([[:space:])]+)?([)]?)*$').tns_attr_status  = 'VALIDATED'                                                                                             THEN 'NULL' --REGEXP_REPLACE(proto_tns_entry_line, '\s*[(]?\w+(\s)?=([[:space:])]+)?', '', 1)
                     -- ATRRIBUTES WITH DIGIT VALUES, e.g.: PORT/RETRY_DELAY/
                     WHEN admin_tnsnames_attr_proto_vald(TRIM(BOTH ' ' FROM proto_tns_entry_line), '^\s*[(]?\w+(\s)?=[[:space:]]?(\d+[[:space:]]?(ms|msec|sec|min)?|ON|OFF|TRUE|FALSE|tcp|tcps|ws|shared|dedicated)([)])?([[:space:]]?)*$').tns_attr_status  = 'VALIDATED' THEN regexp_replace(regexp_replace(TRIM(BOTH ' ' FROM proto_tns_entry_line ), '^([[:space:]]+)?([(])?\w+([[:space:]])+=([[:space:]])+','',1,1,'i'),'([[:space:]]+)?([)])?*$','',1,1,'i')
                     -- IP-ADDRESS
                     WHEN admin_tnsnames_attr_proto_vald(proto_tns_entry_line, '^\s*[(]?\w+(\d{1})?(\s)*=(\s)*(([1-9]{1}|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.(([0-9]{1}|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){2}([1-9]{1}|[0-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5]))?(\s)*([)])?(\s)*$').tns_attr_status  = 'VALIDATED'
                          THEN regexp_replace(regexp_replace(TRIM(BOTH ' ' FROM proto_tns_entry_line ), '^([[:space:]]+)?([(])?\w+([[:space:]])+=([[:space:]])+','',1,1,'i'),'([[:space:]]+)?([)])?*$','',1,1,'i')
                     -- HOSTNAME / PHASE / TARGET_ENV 
                     WHEN admin_tnsnames_attr_proto_vald(proto_tns_entry_line, '^\s*[(]?\w+(\d{1})?(\s)*=(\s)*((\w+|\w+([.-]*example.invalid)*)*)?(\s)*([)])?(\s)*$').tns_attr_status  = 'VALIDATED'
                          THEN regexp_replace(regexp_replace(TRIM(BOTH ' ' FROM proto_tns_entry_line ), '^([[:space:]]+)?([(])?\w+([[:space:]])+=([[:space:]])+','',1,1,'i'),'([[:space:]]+)?([)])?*$','',1,1,'i')
                     -- CLOSING_BRACKET
                     WHEN admin_tnsnames_attr_proto_vald(TRIM(BOTH ' ' FROM proto_tns_entry_line), '^[)]{1}$').tns_attr_status  = 'VALIDATED'                                                                                                                              THEN 'NULL'
                     -- OPENING_BRACKET
                     WHEN admin_tnsnames_attr_proto_vald(TRIM(BOTH ' ' FROM proto_tns_entry_line), '^[(]{1}$').tns_attr_status  = 'VALIDATED'                                                                                                                              THEN 'NULL'
                     WHEN admin_tnsnames_attr_proto_vald(TRIM(BOTH ' ' FROM proto_tns_entry_line), '^\s*[(]?\w+(\d{1})?(\s)?=[[:space:]]?.*(sysdate|(9999|20[0-9]{2})-(1[0-2]|0[0-9])-(0[1-9]|[1-2][0-9]|3[0-1])).*([)])?.*$').tns_attr_status  = 'VALIDATED'              THEN
                     --DATES
                     REGEXP_REPLACE(REGEXP_SUBSTR(proto_tns_entry_line, '[^=]+$'), '[[:space:]),]', '')
                     ELSE 'UNMATCHED_VALUE'
                   END TNS_ATTR_VALUE
                 , proto_tns_entry_line
              FROM TEMP_TNSNAMES_PROTO_ENTRIES ttpe
          )
          SELECT PROTO_TNS_ID, ORDER_ID, REF_ATTR, TNS_ATTR, TNS_ATTR_VALUE, proto_tns_entry_line
            FROM cte
           WHERE REF_ATTR <> 'INVALID_ATTRIBUTE') q2
           ON q1.TNS_ATTR = q2.REF_ATTR
       )
ORDER BY q2.proto_tns_id, q2.order_id
;
