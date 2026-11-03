-- drop table    tetools.admin_tnsnames_entries;
-- drop table    tetools.admin_tnsnames_base;
-- drop table    tetools.admin_tnsnames_checks;
-- drop table    tetools.admin_tnsnames_svn;
-- drop table    tetools.admin_tnsnames_meta;
-- drop table    tetools.admin_tnsnames_attributes;
-- drop table    tetools.admin_tnsnames_reference;
-- drop table    tetools.admin_tnsnames_prefs;
-- drop trigger  tetools.trg_admin_tnsnames_entries_cud;
-- drop trigger  tetools.trg_admin_tnsnames_reference_cud;
-- drop sequence tetools.admin_tnsnames_base_tnsid_seq;
-- drop sequence tetools.admin_tnsnames_svn_svnid_seq;


CREATE TABLE tetools.admin_tnsnames_base
( BASE_PK                               INTEGER GENERATED ALWAYS AS IDENTITY,
  TNS_ID                                INTEGER                     NOT NULL,
  CONSTRAINT admin_tnsnames_base_pk PRIMARY KEY (BASE_PK) ENABLE,
  CONSTRAINT admin_tnsnames_base_tns_id UNIQUE (TNS_ID) ENABLE
);

COMMENT ON TABLE tetools.admin_tnsnames_base IS 'UNIEKE BASIS REGISTRATIE VAN DE TNS IDs';
COMMENT ON COLUMN tetools.admin_tnsnames_base.BASE_PK IS 'TECHNISCHE SLEUTEL VOOR DE TABEL';
COMMENT ON COLUMN tetools.admin_tnsnames_base.TNS_ID IS 'UNIEKE ID GEGENEREERD DOOR tetools.admin_tnsnames_tnsid_seq, DOORGAANS AFKOMSTIG UIT SEQUENCE tetools.admin_tnsnames_tnsid_seq';

CREATE SEQUENCE tetools.admin_tnsnames_tnsid_seq
  START WITH     2047
  MINVALUE       2047
  INCREMENT BY   1
  ORDER;

SELECT tetools.admin_tnsnames_tnsid_seq.nextval FROM dual;


CREATE TABLE tetools.admin_tnsnames_reference (     
  REFERENCE_PK                          INTEGER GENERATED ALWAYS AS IDENTITY,
  REFERENCE_NAME	                    VARCHAR2(128)               NOT NULL,
  PURPOSE                               VARCHAR2(2048),
  DESCRIPTION                           VARCHAR2(2048),
  OPT_VALUES                            VARCHAR2(1024),
  DEFAULT_VALUE                         VARCHAR2(1024),
  MIN_VALUE                             VARCHAR2(1024),
  MAX_VALUE                             VARCHAR2(1024),
  EXAMPLE                               VARCHAR2(4000),
  LSNR_VERSION                          VARCHAR2(4),
  STATUS                                CHAR(1)         DEFAULT 'S', 
  CONSTRAINT admin_tnsnames_reference_pk PRIMARY KEY (REFERENCE_PK) ENABLE,
  CONSTRAINT admin_tnsnames_reference_ren unique (REFERENCE_NAME) ENABLE,
  CONSTRAINT admin_tnsnames_reference_sta CHECK ((MANDATORY = 'Y' AND STATUS IN ('S','D') ) OR (STATUS = 'O' AND MANDATORY = 'N')) ENABLE
);

COMMENT ON TABLE tetools.admin_tnsnames_reference IS 'DEZE TABEL BEVAT ALLE GEDOCUMENTEERDE EN ONDERSTEUNDE ATTRIBUTEN VOOR DE VERSCHILLENDE VERSIES VAN SQLNET EN LISTENERS, OOK ATTRIBUTEN VOOR DEZE APPLICATIE';
COMMENT ON COLUMN tetools.admin_tnsnames_reference.REFERENCE_PK IS 'TECHNISCHE SLEUTEL VOOR DE TABEL';
COMMENT ON COLUMN tetools.admin_tnsnames_reference.REFERENCE_NAME IS 'ATTRIBUUT NAAM';
COMMENT ON COLUMN tetools.admin_tnsnames_reference.PURPOSE IS 'DOEL VAN DE ATTRIBUUT';
COMMENT ON COLUMN tetools.admin_tnsnames_reference.DESCRIPTION IS 'OMSCHRIJVING VAN DE ATTRIBUUT';
COMMENT ON COLUMN tetools.admin_tnsnames_reference.OPT_VALUES IS 'GEACCEPTEERDE WAARDEN VOOR DE ATTRIBUUT';
COMMENT ON COLUMN tetools.admin_tnsnames_reference.DEFAULT_VALUE IS 'STANDAARD WAARDE VAN DE ATTRIBUUT WANNEER VAN TOEPASSING, ANDERS NULL';
COMMENT ON COLUMN tetools.admin_tnsnames_reference.MIN_VALUE IS 'MINIMALE GEACCEPTEERDE WAARDE VOOR DE ATTRIBUUT WANNEER MOGELIJKE WAARDEN IN EEN BEREIK LIGGEN';
COMMENT ON COLUMN tetools.admin_tnsnames_reference.MAX_VALUE IS 'MAXIMALE GEACCEPTEERDE WAARDE VOOR DE ATTRIBUUT WANNEER MOGELIJKE WAARDEN IN EEN BEREIK LIGGEN';
COMMENT ON COLUMN tetools.admin_tnsnames_reference.EXAMPLE IS 'VOORBEELD VAN GEBRUIK VAN HET ATTRIBUUT';
COMMENT ON COLUMN tetools.admin_tnsnames_reference.LSNR_VERSION IS 'HOOGSTE OF LAAGSTE ONDERSTEUNDE VERSIE SQLNET OF LISTENER, AFHANKELIJK VAN DE GEBRUIKTE VERSIE BINNEN UWV. WANNEER ONDERSTEUND, WORDT DE DAN ACTIEVE VERSIE BINNEN UWV GEBRUIKT';
COMMENT ON COLUMN tetools.admin_tnsnames_reference.STATUS IS 'STATUS CAN BE: S -SUPPORTED, O -OBSOLETE, D -DEPRECATED';

-- --select 'INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('''||
-- --REFERENCE_NAME||
-- --''','||CASE WHEN PURPOSE IS NULL THEN 'NULL' ELSE ''''||PURPOSE||'''' END||
-- --', '||CASE WHEN DESCRIPTION IS NULL THEN 'NULL' ELSE ''''||DESCRIPTION||'''' END||
-- --', '||CASE WHEN OPT_VALUES IS NULL THEN 'NULL' ELSE ''''||OPT_VALUES||'''' END||
-- --', '||CASE WHEN DEFAULT_VALUE IS NULL THEN 'NULL' ELSE ''''||DEFAULT_VALUE||'''' END||
-- --', '||CASE WHEN MIN_VALUE IS NULL THEN 'NULL' ELSE ''''||MIN_VALUE||'''' END||
-- --', '||CASE WHEN MAX_VALUE IS NULL THEN 'NULL' ELSE ''''||MAX_VALUE||'''' END||
-- --', '||CASE WHEN EXAMPLE IS NULL THEN 'NULL' ELSE ''''||EXAMPLE||'''' END||
-- --', '||CASE WHEN LSNR_VERSION IS NULL THEN 'NULL' ELSE ''''||LSNR_VERSION||'''' END||
-- --');' from tetools.admin_tnsnames_reference order by REFERENCE_PK asc;

--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('TNS_ID', 'Technical identifier for TNS entries', NULL, NULL, NULL, NULL, NULL, '{ P | A | T | D }', '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('PHASE','To designate in which environment the target database is located', NULL, NULL, NULL, NULL, NULL, '{ P | A | T | D }', '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('TARGET_ENV','To designate the environments where this alias needs to be available', NULL, NULL, NULL, NULL, NULL, '{ PRD | ACC | TST | DEV | DTA }', '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('DATE_VALID_FROM','To specify from which date this tns_alias needs to be included in the generated tnsnames.ora file', NULL, NULL, NULL, NULL, NULL, '2025-10-25', '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('DATE_VALID_TILL','To specify till which date this tns_alias needs to be included in the generated tnsnames.ora file', NULL, NULL, NULL, NULL, NULL, '2032-01-17', '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('ENTRY_DESCRIPTION','To provide a succint description regarding the tns entry', NULL, NULL, NULL, NULL, NULL, NULL, '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('NET_SERVICE_NAME',NULL, 'Commonly known as the TNS_ALIAS', NULL, NULL, NULL, NULL, '<alias_name1>,<alias_name2>,...=... ', '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('DESCRIPTION_LIST','To define a list of connect descriptors for a particular net service name.', 'The DESCRIPTION_LIST parameter of the tnsnames.ora file defines a list of connect descriptors for a particular net service name.', NULL, NULL, NULL, NULL, 'net_service_name=
--(DESCRIPTION_LIST=
-- (DESCRIPTION=
--  (ADDRESS=...)
--  (CONNECT_DATA=(SERVICE_NAME=sales.example.com)))
-- (DESCRIPTION=', '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('DESCRIPTION','To specify a container for a connect descriptor.', 'Use the tnsnames.ora file DESCRIPTION parameter to specify connect descriptor containers.', NULL, NULL, NULL, NULL, 'net_service_name=
--(DESCRIPTION=
--  (ADDRESS=...)
--  (CONNECT_DATA=(SERVICE_NAME=sales.us.example.com)))', '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('TRANSPORT_CONNECT_TIMEOUT','To specify the transport connect timeout duration in ms or msec (milliseconds), sec (seconds), or min (minutes) for a client to establish an Oracle Net connection to Oracle Database.', 'Use the tnsnames.ora parameter TRANSPORT_CONNECT_TIMEOUT to specify the transport connect timeout duration, in milliseconds, seconds, or minutes.', NULL, NULL, NULL, NULL, 'net_service_name =
--  (DESCRIPTION=
--    (TRANSPORT_CONNECT_TIMEOUT=10 ms)
--    (ADDRESS_LIST=
--      (ADDRESS=(PROTOCOL=tcp)(HOST=sales1-svr)(PORT=1521))
--      (ADDRESS=(PROTOCOL=tcp)(HOST=sales2-svr)(PORT=1521)))
--    (CONNECT_DATA=
--      (SERVICE_NAME=sales.us.example.com)))', '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('CONNECT_TIMEOUT','To specify the timeout duration in ms or msec (milliseconds), sec (seconds), or min (minutes) for a client to establish an Oracle Net connection to Oracle Database.', 'Use the tnsnames.ora parameter CONNECT_TIMEOUT to specify the amount of time, in milliseconds, seconds, or minutes, in which clients must establish Oracle Net connections to database instances.', NULL, NULL, NULL, NULL, 'net_service_name=
-- (DESCRIPTION=
--  (CONNECT_TIMEOUT=10 ms)(RETRY_COUNT=3)
--  (ADDRESS_LIST=
--   (ADDRESS=(PROTOCOL=tcp)(HOST=sales1-svr)(PORT=1521))
--   (ADDRESS=(PROTOCOL=tcp)(HOST=sales2-svr)(PORT=1521)))
--  (CONNECT_DATA=
--   (SERVICE_NAME=sales.us.example.com)))', '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('RETRY_DELAY','To specify the delay between subsequent retries for a connection in units of ms or msec (milliseconds), sec (seconds), or min (minutes). This parameter works in conjunction with the RETRY_COUNT parameter.', 'Use the tnsnames.ora parameter RETRY_DELAY to specify the delay between connection retries.', NULL, NULL, NULL, NULL, 'net_service_name=
--(DESCRIPTION_LIST=
--  (DESCRIPTION=
--   (CONNECT_TIMEOUT=10)(RETRY_COUNT=3)(RETRY_DELAY=800ms)
--   (ADDRESS_LIST=
--    (ADDRESS=(PROTOCOL=tcp)(HOST=myhost1)(PORT=1521))
--    (ADDRESS=(PROTOCOL=tcp)(HOST=myhost2)(PORT=1521)))
--   (CONNECT_DATA=(SERVICE_NAME=example1.com)))
--  (DESCRIPTION=
--   (CONNECT_TIMEOUT=60)(RETRY_COUNT=1)(RETRY_DELAY=5sec)
--   (ADDRESS_LIST=
--    (ADDRESS=(PROTOCOL=tcp)(HOST=myhost3)(PORT=1521))
--    (ADDRESS=(PROTOCOL=tcp)(HOST=myhost4)(PORT=1521)))
--   (CONNECT_DATA=(SERVICE_NAME=example2.com))))', '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('RETRY_COUNT','To specify the number of times an ADDRESS list is traversed before the connection attempt is terminated.', 'Use the tnsnames.ora parameter RETRY_COUNT to specify the number of times an ADDRESS list is traversed before terminating the connection attempt.', NULL, NULL, NULL, NULL, 'net_service_name=
--(DESCRIPTION_LIST=
-- (DESCRIPTION=
--  (CONNECT_TIMEOUT=10)(RETRY_COUNT=3)
--  (ADDRESS_LIST=
--   (ADDRESS=(PROTOCOL=tcp)(HOST=sales1a-svr)(PORT=1521))
--   (ADDRESS=(PROTOCOL=tcp)(HOST=sales1b-svr)(PORT=1521)))
--  (CONNECT_DATA=(SERVICE_NAME=sales1.example.com)))
-- (DESCRIPTION=
--  (CONNECT_TIMEOUT=60)(RETRY_COUNT=1)
--  (ADDRESS_LIST=
--   (ADDRESS=(PROTOCOL=tcp)(HOST=sales2a-svr)(PORT=1521))
--   (ADDRESS=(PROTOCOL=tcp)(HOST=sales2b-svr)(PORT=1521)))
--  (CONNECT_DATA=(SERVICE_NAME=sales2.us.example.com))))', '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('FAILOVER','To enable or disable connect-time failover for multiple protocol addresses.', 'Use the FAILOVER parameter to enable or disable connect-time failover for multiple protocol addresses.', 'yes,on,true,no,off,false', 'on for the DESCRIPTION_LIST, DESCRIPTION, and ADDRESS_LIST parameters', NULL, NULL, 'net_service_name=
-- (DESCRIPTION=
--  (FAILOVER=on)
--  (ADDRESS_LIST=
--    (ADDRESS=(PROTOCOL=tcp)(HOST=sales1-svr)(PORT=1521))
--    (ADDRESS=(PROTOCOL=tcp)(HOST=sales2-svr)(PORT=1521)))
--  (CONNECT_DATA=(SERVICE_NAME=sales.us.example.com)))', '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('LOAD_BALANCE','To enable or disable client load balancing for multiple protocol addresses.', 'Use the LOAD_BALANCE parameter to enable or disable client load balancing for multiple protocol addresses.', 'yes,on,true,no,off,false', 'on for DESCRIPTION_LIST', NULL, NULL, 'net_service_name=
-- (DESCRIPTION=
--  (LOAD_BALANCE=on)
--  (ADDRESS_LIST=
--    (ADDRESS=(PROTOCOL=tcp)(HOST=sales1-svr)(PORT=1521))
--    (ADDRESS=(PROTOCOL=tcp)(HOST=sales2-svr)(PORT=1521)))
--  (CONNECT_DATA=(SERVICE_NAME=sales.us.example.com))', '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('ADDRESS_LIST','To define a list of protocol addresses.', 'The ADDRESS_LIST networking parameter specifies the number of protocol addresses.', NULL, NULL, NULL, NULL, 'net_service_name=
-- (DESCRIPTION=
--  (ADDRESS_LIST=
--   (ADDRESS=(PROTOCOL=tcp)(HOST=sales1-svr)(PORT=1521))
--   (ADDRESS=(PROTOCOL=tcp)(HOST=sales2-svr)(PORT=1521)))
--  (CONNECT_DATA=(SERVICE_NAME=sales.us.example.com)))', '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('CONNECT_DATA','To define the service to which you want to connect, such as SERVICE_NAME.', 'Use the CONNECT_DATA parameter to define the connection service.', NULL, NULL, NULL, NULL, 'net_service_name=
-- (DESCRIPTION=
--  (ADDRESS_LIST=
--    (ADDRESS=(PROTOCOL=tcp)(HOST=sales1-svr)(PORT=1521))
--    (ADDRESS=(PROTOCOL=tcp)(HOST=sales2-svr)(PORT=1521)))
--  (CONNECT_DATA=
--    (SERVICE_NAME=sales.us.example.com)))', '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('ADDRESS','To specify one listener protocol address.', 'The tnsnames.ora parameter ADDRESS specifies protocol addresses with the ADDRESS_LIST for multiple addresses or with the DESCRIPTION parameter for one listener.', NULL, NULL, NULL, NULL, 'net_service_name=
--(DESCRIPTION=
-- (ADDRESS=(PROTOCOL=tcp)(HOST=sales-svr)(PORT=1521))
-- (CONNECT_DATA=(SERVICE_NAME=sales.us.example.com))', '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('PROTOCOL',NULL, 'The listener and Oracle Connection Manager are identified by protocol addresses.', 'IPC,Named Pipes,SDP,TCP,TCPS,Exadirect,WS', 'TCP', NULL, NULL, '(PROTOCOL=tcp)', '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('HOST',NULL, NULL, NULL, NULL, NULL, NULL, '(HOST=sales1-svr)', '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('PORT',NULL, 'The port the listener will listen on.', NULL, '1521', '1', '65535', '(PORT=1521)', '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('SERVICE_NAME','To identify the Oracle Database database service to access.', NULL, NULL, NULL, NULL, NULL, 'net_service_name=
-- (DESCRIPTION=
--   (ADDRESS_LIST=
--     (ADDRESS=...)
--     (ADDRESS=...))
--   (CONNECT_DATA=
--     (SERVICE_NAME=sales.us.example.com)))', '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('SID',NULL, 'To identify the database instance to access.', NULL, NULL, NULL, NULL, '(CONNECT_DATA=(SERVER=dedicated)(SID=<instance_name>)', '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('FAILOVER_MODE','Specifies the failover node by its net service name. A separate net service name must be created for the failover node. ', NULL, 'BACKUP (net service name), TYPE (SESSION,SELECT,NONE), METHOD (BASIC,PRECONNECT), TRANSACTION, RETRIES, DELAY', NULL, NULL, NULL, NULL, '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('BACKUP','To instruct Oracle Net to fail over to a different listener if the first listener fails during run time.', NULL, 'BACKUP (net service name), TYPE (SESSION,SELECT,NONE), METHOD (BASIC,PRECONNECT), TRANSACTION, RETRIES, DELAY', NULL, NULL, NULL, NULL, '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('TYPE','Specifies the type of failover. Three types of Oracle Net failover functionality are available by default to Oracle Call Interface (OCI) applications: ', NULL, 'SESSION: Fails over the session. For example, if a users connection is lost, then a new session is automatically created for the user on the backup. This type of failover does not attempt to recover selects.
--    SELECT: Allows users with open cursors to continue fetching them after failure. However, this mode involves overhead on the client side in normal select operations.
--    NONE: This is the default, in which no failover functionality is used. This can also be explicitly specified to prevent failover from happening.', NULL, NULL, NULL, NULL, '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('METHOD','Specifies how fast failover is to occur from the primary node to the backup node:', NULL, 'BASIC: Establishes connections at failover time. This option requires almost no work on the backup database server until failover time.
--    PRECONNECT: Pre-establishes connections. This provides faster failover but requires that the backup instance be able to support all connections from every supported instance.', NULL, NULL, NULL, NULL, '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('TRANSACTION','Allows the database to complete the current database transaction following a recoverable error.', NULL, 'This parameter is used with the COMMIT_OUTCOME=TRUE parameter.', NULL, NULL, NULL, NULL, '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('RETRIES','Specifies the number of times to attempt to connect after a failover.', NULL, 'If DELAY is specified, then RETRIES defaults to five retry attempts.', NULL, NULL, NULL, NULL, '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('DELAY','Specifies the amount of time in seconds to wait between connect attempts.', NULL, 'If RETRIES is specified, then DELAY defaults to one second.', NULL, NULL, NULL, NULL, '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('GLOBAL_NAME','To identify the Oracle Rdb database.', NULL, NULL, NULL, NULL, NULL, 'net_service_name=
-- (DESCRIPTION=
--   (ADDRESS_LIST=
--    (ADDRESS=...)
--    (ADDRESS=...))
--   (CONNECT_DATA=
--    (SERVICE_NAME=generic)
--    (RDB_DATABASE=[.mf]mf_personal.rdb)
--    (GLOBAL_NAME=alpha5)))', '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('INSTANCE_NAME','To identify the database instance to access.', NULL, NULL, NULL, NULL, NULL, 'net_service_name=
-- (DESCRIPTION=
--   (ADDRESS_LIST=
--     (ADDRESS=...)
--     (ADDRESS=...))
--   (CONNECT_DATA=
--     (SERVICE_NAME=sales.us.example.com)
--     (INSTANCE_NAME=sales1)))', '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('SERVER','To direct the listener to connect the client to a specific type of service handler.', NULL, 'dedicated,shared,pooled', NULL, NULL, NULL, 'net_service_name=
-- (DESCRIPTION=
--   (ADDRESS_LIST=
--     (ADDRESS=...)
--     (ADDRESS=...))
--   (CONNECT_DATA=
--    (SERVICE_NAME=sales.us.example.com)
--    (SERVER=dedicated)))', '19c');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('CLOSING_BRACKET','To designate whether an element has been closed', NULL, '{ ) }', ')', NULL, NULL, '    (CONNECT_DATA =
--      (SERVICE_NAME = PEURES)
--    )', 'ALL');
--INSERT INTO tetools.admin_tnsnames_reference (REFERENCE_NAME, PURPOSE, DESCRIPTION, OPT_VALUES, DEFAULT_VALUE, MIN_VALUE, MAX_VALUE, EXAMPLE, LSNR_VERSION) VALUES ('OPENING_BRACKET','To designate whether an element has been opened', NULL, '{ ( }', '(', NULL, NULL, '    (CONNECT_DATA =
--      (SERVICE_NAME = PEURES)
--    )', 'ALL');



CREATE TABLE tetools.admin_tnsnames_attributes (     
  ATTR_PK                               INTEGER GENERATED ALWAYS AS IDENTITY,
  REFERENCE_NAME	                    VARCHAR2(128)               NOT NULL,
  ATTRIBUTE_NAME	                    VARCHAR2(128)               NOT NULL,
  LEAF_MEMBER                           CHAR(1)         DEFAULT 'Y' NOT NULL,
  DATA_TYPE                             VARCHAR2(7)                 NOT NULL,
  HIERARCHY_PARENT_ID                   INTEGER                     NOT NULL,
  HIERARCHY_CHILD_ID                    INTEGER                     NOT NULL,
  HIERARCHY_SORT                        INTEGER                     NOT NULL,
  MANDATORY                             CHAR(1)         DEFAULT 'Y' NOT NULL,
  GT_ONE_OCC                            CHAR(1)         DEFAULT 'Y' NOT NULL,
  VALIDATED                             CHAR(1)         DEFAULT 'N' NOT NULL,
  LAST_VALIDATION_DATE                  DATE                            NULL,
  CONSTRAINT admin_tnsnames_attributes_pk PRIMARY KEY (ATTR_PK) ENABLE,
  CONSTRAINT admin_tnsnames_attributes_attribute_name unique (ATTRIBUTE_NAME) ENABLE,
  CONSTRAINT admin_tnsnames_attributes_hierarchy_child_id unique (HIERARCHY_CHILD_ID) ENABLE,
  CONSTRAINT admin_tnsnames_attributes_lme CHECK (LEAF_MEMBER IN ('Y','N')) ENABLE,  
  CONSTRAINT admin_tnsnames_attributes_man CHECK (MANDATORY IN ('Y','N')) ENABLE,
  CONSTRAINT admin_tnsnames_attributes_gto CHECK (GT_ONE_OCC IN ('Y','N')) ENABLE,
  CONSTRAINT admin_tnsnames_attributes_reference_hierarchy_child_id FOREIGN KEY (REFERENCE_NAME) REFERENCES tetools.admin_tnsnames_reference (REFERENCE_NAME) DEFERRABLE INITIALLY IMMEDIATE ENABLE,
  CONSTRAINT admin_tnsnames_attributes_val CHECK (VALIDATED IN ('Y','N')) ENABLE
);

COMMENT ON TABLE tetools.admin_tnsnames_attributes IS 'DEZE TABEL BEVAT DE VERSCHILLENDE ATTRIBUTEN VOOR DE TNS ENTRIES, EN BEVAT GEGEVENS OVER HOE HET ATTRIBUUT IS OPGEBOUWD, OF DEZE MEER DAN EENS GEBRIUKT WORDT EN OF EN WANNEER DEZE IS GEVALIDEERD';
COMMENT ON COLUMN tetools.admin_tnsnames_attributes.ATTR_PK IS 'TECHNISCHE SLEUTEL VOOR DE TABEL';
COMMENT ON COLUMN tetools.admin_tnsnames_attributes.REFERENCE_NAME IS 'NAAM VAN DE REFERENTIE ATTRIBUUT';
COMMENT ON COLUMN tetools.admin_tnsnames_attributes.ATTRIBUTE_NAME IS 'NAAM VAN HET GEBRUIKTE ATTRIBUUT, DEZE KAN AFWIJKEN DOORDAT DEZE MEER DAN EENS KAN VOORKOMEN';
COMMENT ON COLUMN tetools.admin_tnsnames_attributes.LEAF_MEMBER IS 'BEVAT HET ATTRIBUUT ONDERLIGGENDE ATTRIBUTEN OF EEN WAARDE';
COMMENT ON COLUMN tetools.admin_tnsnames_attributes.DATA_TYPE IS 'HET DATATYPE VAN HET ATTRIBUUT: CIJFERS, TEXT, ANDERS';
COMMENT ON COLUMN tetools.admin_tnsnames_attributes.HIERARCHY_PARENT_ID IS 'ONDER WELK ATTRIBUUT KOMT DIT ATTRIBUUT TE HANGEN';
COMMENT ON COLUMN tetools.admin_tnsnames_attributes.HIERARCHY_CHILD_ID IS 'HEEFT HET ATTRIBUUT ONDERLIGGENDE ATTRIBUTEN (LEAF-MEMBERS)';
COMMENT ON COLUMN tetools.admin_tnsnames_attributes.HIERARCHY_SORT IS 'WLKE PLEK IN DE SORTERING NEEMT DIT ATTRIBUUT IN';
COMMENT ON COLUMN tetools.admin_tnsnames_attributes.MANDATORY IS 'IS HET ATTRIBUUT VEREIST';
COMMENT ON COLUMN tetools.admin_tnsnames_attributes.GT_ONE_OCC IS 'KAN HET ATTRIBUUT MEER DAN EENS VOORKOMEN: ZOALS ADDRESS';
COMMENT ON COLUMN tetools.admin_tnsnames_attributes.VALIDATED IS 'IS HET ATTRIBUUT GEVALIDEERD';
COMMENT ON COLUMN tetools.admin_tnsnames_attributes.LAST_VALIDATION_DATE IS 'WANNEER IS HET ATTRIBUUT VOOR HET LAATST GEVALIDEERD';

-- --select 'INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('''||REFERENCE_NAME||''', '''||ATTRIBUTE_NAME||''', '''||LEAF_MEMBER||''', '''||DATA_TYPE||''', '||HIERARCHY_PARENT_ID||', '||HIERARCHY_CHILD_ID||', '||HIERARCHY_SORT||', '''||MANDATORY||''', '''||GT_ONE_OCC||''');' from tetools.admin_tnsnames_attributes order by attr_pk asc;
--
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('PHASE', 'PHASE', 'Y', 'META', 9999, 9998, 1, 'Y', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('TARGET_ENV', 'TARGET_ENV', 'Y', 'META', 9999, 9997, 1, 'Y', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('DATE_VALID_FROM', 'DATE_VALID_FROM', 'Y', 'META', 9999, 9996, 1, 'Y', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('DATE_VALID_TILL', 'DATE_VALID_TILL', 'Y', 'META', 9999, 9995, 1, 'Y', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('ENTRY_DESCRIPTION', 'ENTRY_DESCRIPTION', 'Y', 'STRING', 0, 1, 1, 'N', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('NET_SERVICE_NAME', 'NET_SERVICE_NAME', 'N', 'STRING', 0, 2, 1, 'Y', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('DESCRIPTION_LIST', 'DESCRIPTION_LIST', 'N', 'STRING', 2, 3, 1, 'Y', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('DESCRIPTION', 'DESCRIPTION', 'N', 'STRING', 3, 4, 1, 'Y', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('TRANSPORT_CONNECT_TIMEOUT', 'TRANSPORT_CONNECT_TIMEOUT', 'Y', 'STRING', 4, 5, 1, 'N', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('CONNECT_TIMEOUT', 'CONNECT_TIMEOUT', 'Y', 'STRING', 4, 6, 2, 'N', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('RETRY_DELAY', 'RETRY_DELAY', 'Y', 'STRING', 4, 7, 3, 'N', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('RETRY_COUNT', 'RETRY_COUNT', 'Y', 'INTEGER', 4, 8, 4, 'N', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('FAILOVER', 'FAILOVER', 'Y', 'STRING', 4, 9, 5, 'N', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('LOAD_BALANCE', 'LOAD_BALANCE', 'Y', 'STRING', 4, 10, 6, 'N', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('ADDRESS_LIST', 'ADDRESS_LIST', 'N', 'STRING', 4, 11, 7, 'Y', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('ADDRESS', 'ADDRESS_1', 'N', 'STRING', 11, 13, 1, 'Y', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('PROTOCOL', 'PROTOCOL_1', 'Y', 'STRING', 13, 15, 1, 'Y', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('HOST', 'HOST_1', 'Y', 'STRING', 13, 16, 2, 'Y', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('PORT', 'PORT_1', 'Y', 'INTEGER', 13, 17, 3, 'Y', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('ADDRESS', 'ADDRESS_2', 'N', 'STRING', 11, 113, 1, 'N', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('PROTOCOL', 'PROTOCOL_2', 'Y', 'STRING', 113, 115, 1, 'N', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('HOST', 'HOST_2', 'Y', 'STRING', 113, 116, 2, 'N', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('PORT', 'PORT_2', 'Y', 'INTEGER', 113, 117, 3, 'N', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('CONNECT_DATA', 'CONNECT_DATA', 'N', 'STRING', 4, 12, 8, 'Y', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('SERVICE_NAME', 'SERVICE_NAME', 'Y', 'STRING', 12, 18, 1, 'N', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('SID', 'SID', 'Y', 'STRING', 12, 19, 2, 'N', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('GLOBAL_NAME', 'GLOBAL_NAME', 'Y', 'STRING', 12, 20, 3, 'N', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('INSTANCE_NAME', 'INSTANCE_NAME', 'Y', 'STRING', 12, 21, 4, 'N', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('SERVER', 'SERVER', 'Y', 'STRING', 12, 22, 5, 'N', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('FAILOVER_MODE', 'FAILOVER_MODE', 'N', 'STRING', 12, 23, 6, 'N', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('BACKUP', 'BACKUP', 'Y', 'STRING', 23, 24, 1, 'N', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('TYPE', 'TYPE', 'Y', 'STRING', 23, 25, 2, 'N', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('METHOD', 'METHOD', 'Y', 'STRING', 23, 26, 3, 'N', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('TRANSACTION', 'TRANSACTION', 'Y', 'STRING', 23, 27, 4, 'N', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('RETRIES', 'RETRIES', 'Y', 'STRING', 23, 28, 5, 'N', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('DELAY', 'DELAY', 'Y', 'STRING', 23, 29, 6, 'N', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('OPENING_BRACKET', 'OPENING_BRACKET', 'Y', 'STRING', 9999, 9994, 6, 'N', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('CLOSING_BRACKET', 'CLOSING_BRACKET', 'Y', 'STRING', 9999, 9993, 6, 'N', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('ADDRESS', 'ADDRESS_3', 'N', 'STRING', 11, 213, 1, 'N', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('PROTOCOL', 'PROTOCOL_3', 'Y', 'STRING', 213, 215, 1, 'N', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('HOST', 'HOST_3', 'Y', 'STRING', 213, 216, 2, 'N', 'Y');
--INSERT INTO tetools.admin_tnsnames_attributes (REFERENCE_NAME, ATTRIBUTE_NAME, LEAF_MEMBER, DATA_TYPE, HIERARCHY_PARENT_ID, HIERARCHY_CHILD_ID, HIERARCHY_SORT, MANDATORY, GT_ONE_OCC) VALUES ('PORT', 'PORT_3', 'Y', 'INTEGER', 213, 217, 3, 'N', 'Y');


CREATE TABLE tetools.admin_tnsnames_entries
( TNS_ENTRY_PK                          INTEGER GENERATED ALWAYS AS IDENTITY,
  TNS_ID                                INTEGER                     NOT NULL,
  TNS_ATTR                              VARCHAR2(128)               NOT NULL,
  HIERARCHY_CHILD_ID                    INTEGER                     NOT NULL,
  VALIDATED                             CHAR(1)         DEFAULT 'N' NOT NULL,
  TNS_ATTR_VALUE                        VARCHAR2(2048)                  NULL,
  LAST_VALIDATION_DATE                  DATE                            NULL,
  CONSTRAINT admin_tnsnames_entries_pk PRIMARY KEY (TNS_ENTRY_PK) ENABLE,
  CONSTRAINT admin_tnsnames_entries_base_tns_id FOREIGN KEY (TNS_ID) REFERENCES tetools.admin_tnsnames_base (TNS_ID) ENABLE,
  CONSTRAINT admin_tnsnames_entries_attributes_hierarchy_child_id FOREIGN KEY (HIERARCHY_CHILD_ID) REFERENCES tetools.admin_tnsnames_attributes (HIERARCHY_CHILD_ID) ENABLE,
  CONSTRAINT admin_tnsnames_entries_val CHECK (VALIDATED IN ('Y','N')) ENABLE
);

COMMENT ON TABLE tetools.admin_tnsnames_entries IS 'DEZE TABEL BEVAT DE DEFINITIEVE REGISTRATIES VOOR DE TNS ENTRIES.';
COMMENT ON COLUMN tetools.admin_tnsnames_entries.TNS_ENTRY_PK IS 'TECHNISCHE SLEUTEL VOOR DE TABEL';
COMMENT ON COLUMN tetools.admin_tnsnames_entries.TNS_ID IS 'DIT ID IS AFKOMSTIG UIT DE tetools.admin_tnsnames_base REGISTRATIE';
COMMENT ON COLUMN tetools.admin_tnsnames_entries.TNS_ATTR IS 'NAAM VAN HET ATTRIBUUT';
COMMENT ON COLUMN tetools.admin_tnsnames_entries.HIERARCHY_CHILD_ID IS 'HIERARCHISCH ID';
COMMENT ON COLUMN tetools.admin_tnsnames_entries.VALIDATED IS 'IS HET ATTRIBUUT GEVALIDEERD';
COMMENT ON COLUMN tetools.admin_tnsnames_entries.TNS_ATTR_VALUE IS 'ATTRIBUUT WAARDE, WANNEER VAN TOEPASSING';
COMMENT ON COLUMN tetools.admin_tnsnames_entries.LAST_VALIDATION_DATE IS 'WANNEER IS HET ATTRIBUUT VOOR HET LAATST GEVALIDEERD';

-- --select 'INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES ('||TNS_ID||', '''||TNS_ATTR||''', '||HIERARCHY_CHILD_ID||', '''||'Y'||''', '||CASE WHEN TNS_ATTR_VALUE IS NULL THEN 'NULL' ELSE ''''||TNS_ATTR_VALUE||'''' END||', '''||to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')||''');' from tetools.admin_tnsnames_entries order by TNS_ENTRY_PK asc;

--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2068, 'ENTRY_DESCRIPTION', 1, 'Y', '# Standard simple tns registration', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2068, 'NET_SERVICE_NAME', 2, 'Y', 'tjimdb', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2068, 'DESCRIPTION_LIST', 3, 'Y', NULL, '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2068, 'DESCRIPTION', 4, 'Y', NULL, '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2068, 'ADDRESS_LIST', 11, 'Y', NULL, '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2068, 'CONNECT_DATA', 12, 'Y', NULL, '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2068, 'ADDRESS', 13, 'Y', NULL, '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2068, 'PROTOCOL', 15, 'Y', 'TCP', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2068, 'HOST', 16, 'Y', '192.0.2.10', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2068, 'SID', 19, 'Y', 'tjimi1', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2068, 'PORT', 17, 'Y', '1521', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2068, 'SERVER', 22, 'Y', 'DEDICATED', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2068, 'PHASE', 9998, 'Y', 'T', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2068, 'TARGET_ENV', 9997, 'Y', 'TST', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2068, 'DATE_VALID_FROM', 9996, 'Y', '2024-10-17', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2068, 'DATE_VALID_END', 9995, 'Y', '9999-12-31', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2069, 'ENTRY_DESCRIPTION', 1, 'Y', '# Failover registration with multiple addresses', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2069, 'NET_SERVICE_NAME', 2, 'Y', 'PLZVDB01', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2069, 'DESCRIPTION_LIST', 3, 'Y', NULL, '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2069, 'DESCRIPTION', 4, 'Y', NULL, '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2069, 'TRANSPORT_CONNECT_TIMEOUT', 5, 'Y', '5', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2069, 'CONNECT_TIMEOUT', 6, 'Y', '5', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2069, 'RETRY_DELAY', 7, 'Y', '10', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2069, 'RETRY_COUNT', 8, 'Y', '2', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2069, 'FAILOVER', 9, 'Y', NULL, '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2069, 'LOAD_BALANCE', 10, 'Y', 'OFF', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2069, 'ADDRESS_LIST', 11, 'Y', NULL, '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2069, 'CONNECT_DATA', 12, 'Y', NULL, '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2069, 'ADDRESS', 13, 'Y', NULL, '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2069, 'PROTOCOL', 15, 'Y', 'TCP', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2069, 'HOST', 16, 'Y', 'example.invalid', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2069, 'SERVICE_NAME', 18, 'Y', 'PLZVDB01_PR', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2069, 'PORT', 17, 'Y', '1521', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2069, 'ADDRESS', 113, 'Y', NULL, '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2069, 'PROTOCOL', 115, 'Y', 'TCP', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2069, 'HOST', 116, 'Y', 'example.invalid', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2069, 'PORT', 117, 'Y', '1521', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2069, 'PHASE', 9998, 'Y', 'P', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2069, 'TARGET_ENV', 9997, 'Y', 'PRD', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2069, 'DATE_VALID_FROM', 9996, 'Y', '2024-10-24', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2069, 'DATE_VALID_END', 9995, 'Y', '9999-12-31', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2070, 'NET_SERVICE_NAME', 2, 'Y', 'PEURES', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2070, 'DESCRIPTION_LIST', 3, 'Y', NULL, '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2070, 'DESCRIPTION', 4, 'Y', NULL, '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2070, 'ADDRESS_LIST', 11, 'Y', NULL, '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2070, 'CONNECT_DATA', 12, 'Y', NULL, '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2070, 'ADDRESS', 13, 'Y', NULL, '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2070, 'PROTOCOL', 15, 'Y', 'TCP', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2070, 'HOST', 16, 'Y', 'example.invalid', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2070, 'PORT', 17, 'Y', '1526', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2070, 'SID', 19, 'Y', 'PEURES', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2070, 'PHASE', 9998, 'Y', 'P', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2070, 'TARGET_ENV', 9997, 'Y', 'PRD', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2070, 'DATE_VALID_FROM', 9996, 'Y', '2000-01-01', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2070, 'DATE_VALID_END', 9995, 'Y', '2026-03-26', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2067, 'NET_SERVICE_NAME', 2, 'Y', 'pjim', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2067, 'DESCRIPTION_LIST', 3, 'Y', NULL, '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2067, 'DESCRIPTION', 4, 'Y', NULL, '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2067, 'ADDRESS_LIST', 11, 'Y', NULL, '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2067, 'CONNECT_DATA', 12, 'Y', NULL, '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2067, 'ADDRESS', 13, 'Y', NULL, '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2067, 'PROTOCOL', 15, 'Y', 'TCP', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2067, 'HOST', 16, 'Y', 'example.invalid', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2067, 'PORT', 17, 'Y', '1526', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2067, 'SID', 19, 'Y', 'pjim', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2067, 'PHASE', 9998, 'Y', 'P', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2067, 'TARGET_ENV', 9997, 'Y', 'PRD', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2067, 'DATE_VALID_FROM', 9996, 'Y', '2000-01-01', '2025-02-05 13:50:03');
--INSERT INTO tetools.admin_tnsnames_entries (TNS_ID, TNS_ATTR, HIERARCHY_CHILD_ID, VALIDATED, TNS_ATTR_VALUE, LAST_VALIDATION_DATE) VALUES (2067, 'DATE_VALID_END', 9995, 'Y', '2026-03-08', '2025-02-05 13:50:03');




CREATE TABLE tetools.admin_tnsnames_checks
( CHECK_PK                              INTEGER GENERATED ALWAYS AS IDENTITY,
  CHECK_NAME                            VARCHAR2(2048)              NOT NULL,
  CHECK_STATEMENT                       VARCHAR2(4000)              NOT NULL,
  GT_ONE_OCC                            CHAR(1)                     NOT NULL,
  CHECK_TARGET                          VARCHAR2(32)                NOT NULL,
  TNS_ATTR                              VARCHAR2(128)                   NULL,
  CHECK_TYPE                            VARCHAR2(32)                    NULL,
  CHECK_DESCRIPTION                     VARCHAR2(2048)                  NULL,
  CONSTRAINT admin_tnsnames_check_pk PRIMARY KEY (CHECK_PK) ENABLE,
  --ONDERSTAAND CONSTRAINT IS LEUK BEDACHT MAAR MAAKT HET GEBRUIK ALLEEN MAAR MOEILIJKER, EN LEVERT WAARSCHIJNLIJK NIET EENS EEN VOORDEEL OP
  --CONSTRAINT admin_tnsnames_checks_attributes_attribute_name FOREIGN KEY (TNS_ATTR) REFERENCES tetools.admin_tnsnames_attributes (ATTRIBUTE_NAME) ENABLE,
  CONSTRAINT admin_tnsnames_checks_gto CHECK (GT_ONE_OCC IN ('Y','N')) ENABLE,
  CONSTRAINT admin_tnsnames_checks_ctg CHECK (CHECK_TARGET IN ('ATTRIBUTE','VALUE','OTHER')) ENABLE
);

COMMENT ON TABLE tetools.admin_tnsnames_checks IS 'DEZE TABLE BEVAT DE (REGULAR EXPRESSION) CONTROLE STATEMENTS';
COMMENT ON COLUMN tetools.admin_tnsnames_checks.CHECK_PK IS 'TECHNISCHE SLEUTEL VOOR DE TABEL';
COMMENT ON COLUMN tetools.admin_tnsnames_checks.CHECK_NAME IS 'CONTROLE NAAM';
COMMENT ON COLUMN tetools.admin_tnsnames_checks.CHECK_STATEMENT IS '(REGULAR EXPRESSION/PROCEDURE) CONTROLE STATEMENT'; 
COMMENT ON COLUMN tetools.admin_tnsnames_checks.GT_ONE_OCC IS 'KAN HET ATTRIBUUT MEER DAN EENS VOORKOMEN: ZOALS ADDRESS';
COMMENT ON COLUMN tetools.admin_tnsnames_checks.TNS_ATTR IS 'REFEREERT NAAR admin_tnsnames_attributes.ATTRIBUUTNAAM';
COMMENT ON COLUMN tetools.admin_tnsnames_checks.CHECK_TARGET IS 'AANDUIDING OF DIT DE CONTROLE VOOR HET ATTRIBUUT ZELF IS OF VOOR DE WAARDE VAN HET ATTRIBUUT';
COMMENT ON COLUMN tetools.admin_tnsnames_checks.CHECK_TYPE IS 'WAT IS DE OPMAAK VAN DE CONTROLE: ZOALS REGEX OF PROCEDURE';
COMMENT ON COLUMN tetools.admin_tnsnames_checks.CHECK_DESCRIPTION IS 'CONTROLE OMSCHRIJVING';

-- --select 'INSERT INTO tetools.admin_tnsnames_checks (CHECK_NAME, CHECK_STATEMENT, GT_ONE_OCC, TNS_ATTR, CHECK_TARGET, CHECK_TYPE, CHECK_DESCRIPTION) VALUES ('''||TNS_ATTR||''', '''||TNS_ATTR_CHECK||''', '''||TNS_ATTR_STATEMENT||''', '''||GT_ONE_OCC||''', '''||TNS_ATTR_CHECK_TYPE||''', '''||TNS_ATTR_DESCRIPTION||''');' from tetools.admin_tnsnames_checks order by CHECK_PK asc;

--INSERT INTO tetools.admin_tnsnames_checks (CHECK_NAME, CHECK_STATEMENT, GT_ONE_OCC, TNS_ATTR, CHECK_TARGET, CHECK_TYPE, CHECK_DESCRIPTION) VALUES ('IS_NUMBER', '^([0-9]*)$', 'Y', 'TNS_ID', 'VALUE', 'REGEX', 'Check if value is numeral');
--INSERT INTO tetools.admin_tnsnames_checks (CHECK_NAME, CHECK_STATEMENT, GT_ONE_OCC, TNS_ATTR, CHECK_TARGET, CHECK_TYPE, CHECK_DESCRIPTION) VALUES ('OPENING_BRACKET', '^([[:space:])]*)[(]{1}$', 'Y', 'OPENING_BRACKET', 'ATTRIBUTE', 'REGEX', 'Check if line contains only an opening bracket');
--INSERT INTO tetools.admin_tnsnames_checks (CHECK_NAME, CHECK_STATEMENT, GT_ONE_OCC, TNS_ATTR, CHECK_TARGET, CHECK_TYPE, CHECK_DESCRIPTION) VALUES ('CLOSING_BRACKET', '^([[:space:])]*)[(]{1}$', 'Y', 'CLOSING_BRACKET', 'ATTRIBUTE', 'REGEX', 'Check if line contains only an closing bracket');
--INSERT INTO tetools.admin_tnsnames_checks (CHECK_NAME, CHECK_STATEMENT, GT_ONE_OCC, TNS_ATTR, CHECK_TARGET, CHECK_TYPE, CHECK_DESCRIPTION) VALUES ('COMMENT', '^([[:space:])]*)?#{1}.*', 'Y', 'ENTRY_DESCRIPTIONT','ATTRIBUTE', 'REGEX', 'Check if line starts with a comment marker, e.g.: #');
--INSERT INTO tetools.admin_tnsnames_checks (CHECK_NAME, CHECK_STATEMENT, GT_ONE_OCC, TNS_ATTR, CHECK_TARGET, CHECK_TYPE, CHECK_DESCRIPTION) VALUES ('NODE_OR_LEAF', '^\s*[(]?\w+(\s)?=([[:space:])]+)?([)]?)*$', 'Y', 'ADDRESS, CONNECT_DATA, etc.','ATTRIBUTE', 'REGEX', 'Check if the attribute is a node or leaf-member');
--INSERT INTO tetools.admin_tnsnames_checks (CHECK_NAME, CHECK_STATEMENT, GT_ONE_OCC, TNS_ATTR, CHECK_TARGET, CHECK_TYPE, CHECK_DESCRIPTION) VALUES ('PROTOCOL', '^\s*[(]?\w+(\d{1})?(\s)?=[[:space:]]?(tcp|tcps|ws)([)])?(\s)*$', 'Y', 'PROTOCOL','ATTRIBUTE', 'REGEX', '');
--INSERT INTO tetools.admin_tnsnames_checks (CHECK_NAME, CHECK_STATEMENT, GT_ONE_OCC, TNS_ATTR, CHECK_TARGET, CHECK_TYPE, CHECK_DESCRIPTION) VALUES ('STRING_ATTRIBUTES', '^\s*[(]?\w+(\s)?=[[:space:]]?(\d+[[:space:]]?(ms|msec|sec|min)?|ON|OFF|TRUE|FALSE)([)])?([[:space:]]?)*$', 'Y', 'TRANSPORT_CONNECT_TIMEOUT, FAILOVER, etc.', 'VALUE', 'REGEX', 'Check if the attribute has a string as value');
--INSERT INTO tetools.admin_tnsnames_checks (CHECK_NAME, CHECK_STATEMENT, GT_ONE_OCC, TNS_ATTR, CHECK_TARGET, CHECK_TYPE, CHECK_DESCRIPTION) VALUES ('DATE_ATTRIBUTES', '^\s*[(]?\w+(\d{1})?(\s)?=[[:space:]]?.*(sysdate|(9999|20[0-9]{2})-(1[0-2]|0[0-9])-(0[1-9]|[1-2][0-9]|3[0-1])).*([)])?.*$', 'Y', 'DATE_VALID_FROM, DATE_VALID_TILL', 'VALUE', 'REGEX', 'Check if value is numeral');
--INSERT INTO tetools.admin_tnsnames_checks (CHECK_NAME, CHECK_STATEMENT, GT_ONE_OCC, TNS_ATTR, CHECK_TARGET, CHECK_TYPE, CHECK_DESCRIPTION) VALUES ('NUMERAL_ATTRIBUTES', '^\s*[(]?\w+(\d{1})?(\s)*=(\s)*((\w+([.-]*\w+)*)*|([1-9]{1}|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.(([0-9]{1}|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){2}([1-9]{1}|[0-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5]))?(\s)*([)])?(\s)*$', 'Y', 'PORT, RETRY_COUNT', 'VALUE', 'REGEX', 'Check if value is numeral');
--INSERT INTO tetools.admin_tnsnames_checks (CHECK_NAME, CHECK_STATEMENT, GT_ONE_OCC, TNS_ATTR, CHECK_TARGET, CHECK_TYPE, CHECK_DESCRIPTION) VALUES ('PHASE', 'tetools.admin_tnsnames.phase_checker', 'N', 'PHASE', 'VALUE', 'packaged procedure', 'This packaged procedure validates the given FQDN against the approved domains');
--INSERT INTO tetools.admin_tnsnames_checks (CHECK_NAME, CHECK_STATEMENT, GT_ONE_OCC, TNS_ATTR, CHECK_TARGET, CHECK_TYPE, CHECK_DESCRIPTION) VALUES ('PORT', 'tetools.admin_tnsnames.port_checker', 'N', 'PORT', 'VALUE', 'packaged procedure', 'This packaged procedure validates the given port if its numeral, default, and if its less than 10k');
--INSERT INTO tetools.admin_tnsnames_checks (CHECK_NAME, CHECK_STATEMENT, GT_ONE_OCC, TNS_ATTR, CHECK_TARGET, CHECK_TYPE, CHECK_DESCRIPTION) VALUES ('HOST', 'tetools.admin_tnsnames.ipaddress_checker', 'Y', 'HOST', 'VALUE', 'packaged procedure', 'This packaged procedure validates the given hostname (if its just numeral and periods) if its a valid IP address');
--INSERT INTO tetools.admin_tnsnames_checks (CHECK_NAME, CHECK_STATEMENT, GT_ONE_OCC, TNS_ATTR, CHECK_TARGET, CHECK_TYPE, CHECK_DESCRIPTION) VALUES ('HOST', 'tetools.admin_tnsnames.isfqdn', 'Y', 'HOST', 'VALUE', 'packaged procedure', 'This packaged procedure validates if the given hostname is a fqdn and adheres to standard naming conventions');
--INSERT INTO tetools.admin_tnsnames_checks (CHECK_NAME, CHECK_STATEMENT, GT_ONE_OCC, TNS_ATTR, CHECK_TARGET, CHECK_TYPE, CHECK_DESCRIPTION) VALUES ('HOST', 'tetools.admin_tnsnames.eval_hostname', 'Y', 'HOST', 'VALUE', 'packaged procedure', 'This packaged procedure calls other packaged procedures to validate the given hostname or ip-address');



CREATE TABLE tetools.admin_tnsnames_prefs (
  PREF_PK                               INTEGER GENERATED ALWAYS AS IDENTITY,
  PREF_TABLE                            VARCHAR2(255) NOT NULL,
  PREF_NAME	                            VARCHAR2(255) NOT NULL,
  PREF_VALUE	                        VARCHAR2(255) NOT NULL,
  CONSTRAINT admin_tnsnames_prefs_pk PRIMARY KEY (pref_pk) ENABLE
);

COMMENT ON TABLE tetools.admin_tnsnames_prefs IS 'IN DEZE TABEL STAAN VERSCHILLENDE CONFIGURATIESLEUTELS';
COMMENT ON COLUMN tetools.admin_tnsnames_prefs.PREF_PK IS 'TECHNISCHE SLEUTEL VOOR DE TABEL';
COMMENT ON COLUMN tetools.admin_tnsnames_prefs.PREF_TABLE IS 'HEEFT DE CONFIGURATIE INVLOED OP EEN SPECIFIEKE TABEL OF ALLEMAAL';
COMMENT ON COLUMN tetools.admin_tnsnames_prefs.PREF_NAME IS 'CONFIGURATIESLEUTEL NAAM';
COMMENT ON COLUMN tetools.admin_tnsnames_prefs.PREF_VALUE IS 'CONFIGURATIESLEUTEL WAARDE';

-- --select 'INSERT INTO tetools.admin_tnsnames_prefs (PREF_TABLE, PREF_NAME, PREF_VALUE) VALUES ('''||PREF_TABLE||''', '''||PREF_NAME||''', '''||PREF_VALUE||''');' from tetools.admin_tnsnames_prefs order by PREF_PK asc;

--INSERT INTO tetools.admin_tnsnames_prefs (PREF_TABLE, PREF_NAME, PREF_VALUE) VALUES ('ALL', 'P_DOMAIN', 'example.invalid');
--INSERT INTO tetools.admin_tnsnames_prefs (PREF_TABLE, PREF_NAME, PREF_VALUE) VALUES ('ALL', 'MAINTENANCE_MODE', 'DISABLED');
--INSERT INTO tetools.admin_tnsnames_prefs (PREF_TABLE, PREF_NAME, PREF_VALUE) VALUES ('ALL', 'O_DOMAIN', 'example.invalid');
--INSERT INTO tetools.admin_tnsnames_prefs (PREF_TABLE, PREF_NAME, PREF_VALUE) VALUES ('ALL', 'A_DOMAIN', 'example.invalid');
--INSERT INTO tetools.admin_tnsnames_prefs (PREF_TABLE, PREF_NAME, PREF_VALUE) VALUES ('ALL', 'CONTRIBUTOR_ROLE', 'POLISPLUS_FB_ROLE');
--INSERT INTO tetools.admin_tnsnames_prefs (PREF_TABLE, PREF_NAME, PREF_VALUE) VALUES ('ALL', 'AVAILABLE_DIVISIONS', '{"AVAILABLE_DIVISIONS":" ALL, GEGEVENSDIENSTEN"}');
--INSERT INTO tetools.admin_tnsnames_prefs (PREF_TABLE, PREF_NAME, PREF_VALUE) VALUES ('ALL', 'CHECK_MD5', 'NO');
--INSERT INTO tetools.admin_tnsnames_prefs (PREF_TABLE, PREF_NAME, PREF_VALUE) VALUES ('ALL', 'ADMINISTRATOR_ROLE', 'TET_ROLE');
--INSERT INTO tetools.admin_tnsnames_prefs (PREF_TABLE, PREF_NAME, PREF_VALUE) VALUES ('ALL', 'T_DOMAIN', 'example.invalid');
--INSERT INTO tetools.admin_tnsnames_prefs (PREF_TABLE, PREF_NAME, PREF_VALUE) VALUES ('ALL', 'PREFERRED_DIVISIONS', 'GEGEVENSDIENSTEN');

CREATE TABLE tetools.admin_tnsnames_meta (
  META_ID	                              INTEGER GENERATED ALWAYS AS IDENTITY,
  SVN_ID                        	      NUMBER                      NOT NULL,
  USER_ID                                 NUMBER                      NOT NULL,
  USERNAME                                VARCHAR2(128)               NOT NULL,
  ISADMIN                                 CHAR(1)                     NOT NULL,
  ISCONTRIBUTOR                           CHAR(1)                     NOT NULL,
  USER_ROLES                              VARCHAR2(2048)              NOT NULL,
  CALLED_FROM                             VARCHAR2(256)               NOT NULL,
  CONSTRAINT admin_tnsnames_meta_pk PRIMARY KEY (META_ID) ENABLE,
  CONSTRAINT admin_tnsnames_base_si UNIQUE (SVN_ID) ENABLE,
  CONSTRAINT admin_tnsnames_meta_ur CHECK (USER_ROLES IS JSON) ENABLE,
  CONSTRAINT admin_tnsnames_meta_ia CHECK (ISADMIN IN ('Y','N')) ENABLE,
  CONSTRAINT admin_tnsnames_meta_ic CHECK (ISCONTRIBUTOR IN ('Y','N')) ENABLE
);

COMMENT ON TABLE tetools.admin_tnsnames_meta IS 'DEZE TABEL BEVAT DE GEGEVENS VAN DE GEBRUIKER TEN TIJDE VAN DE WIJZIGINGEN GEMAAKT DOOR BETREFFENDE GEBRUIKER';
COMMENT ON COLUMN tetools.admin_tnsnames_meta.META_ID IS 'TECHNISCHE SLEUTEL VOOR DE TABEL';
COMMENT ON COLUMN tetools.admin_tnsnames_meta.SVN_ID IS 'SYSTEM VERSION NUMBER, TECHNISCHE SLEUTEL VOOR admin_tnsnames_svn';
COMMENT ON COLUMN tetools.admin_tnsnames_meta.USER_ID IS 'USERID VAN DE GEBRUIKER';
COMMENT ON COLUMN tetools.admin_tnsnames_meta.USERNAME IS 'USERNAME VAN DE GEBRUIKER';
COMMENT ON COLUMN tetools.admin_tnsnames_meta.ISADMIN IS 'WAS DE GEBRUIKER ADMIN OP MOMENT VAN WIJZIGING';
COMMENT ON COLUMN tetools.admin_tnsnames_meta.ISCONTRIBUTOR IS 'WAS DE GEBRUIKER CONTRIBUTOR TEN TIJDE VAN DE WIJZIGING';
COMMENT ON COLUMN tetools.admin_tnsnames_meta.USER_ROLES IS 'DE ROLLEN TOEGEWEZEN AAN DE GEBRUIKER TEN TIJDE VAN DE WIJZIGING';
COMMENT ON COLUMN tetools.admin_tnsnames_meta.CALLED_FROM IS 'BESCHRIJVING HOE DE WIJZIGING AANGEROEPEN IS';


CREATE TABLE tetools.admin_tnsnames_svn (
  SVN_PK                                INTEGER GENERATED ALWAYS AS IDENTITY,
  SVN_ID                                INTEGER                     NOT NULL,
  SVN_DATE                              DATE                        NOT NULL,
  DML                                   CHAR(1)                     NOT NULL,  -- DML CAN BE: 'C'-CREATE, 'U'-UPDATE, 'D'-DELETE
  INVOKING_USER                         VARCHAR2(128)               NOT NULL,
  BASE_TABLE                            VARCHAR2(255)               NOT NULL,
  BASE_PK                               INTEGER,
  BASE_ATTR                             VARCHAR2(128),
  OLD_VALUE                             VARCHAR2(2048),
  NEW_VALUE                             VARCHAR2(2048),
  BACKUP_RECORD                         VARCHAR2(4000),
  CONSTRAINT admin_tnsnames_svn_pk  PRIMARY KEY (SVN_PK) ENABLE,
  CONSTRAINT admin_tnsnames_meta_si FOREIGN KEY (SVN_ID) REFERENCES tetools.admin_tnsnames_meta (SVN_ID) ENABLE,
  CONSTRAINT admin_tnsnames_svn_dml CHECK (DML IN ('C','U','D')) ENABLE,  
  CONSTRAINT admin_tnsnames_svn_bck CHECK (BACKUP_RECORD IS JSON)
);

COMMENT ON TABLE tetools.admin_tnsnames_svn IS 'DEZE TABEL BEVAT DE GEMAAKTE WIJZIGINGEN T.O.V. HET TNSNAMES REGISTRATIE PAKKET';
COMMENT ON COLUMN tetools.admin_tnsnames_svn.SVN_PK IS 'TECHNISCHE SLEUTEL VOOR DE TABEL';
COMMENT ON COLUMN tetools.admin_tnsnames_svn.SVN_ID IS 'DIT IS _DE_ SYSTEM VERSION NUMBER';
COMMENT ON COLUMN tetools.admin_tnsnames_svn.SVN_DATE IS 'DATUM WAAROP DE WIJZIGING IS DOORGEVOERD';
COMMENT ON COLUMN tetools.admin_tnsnames_svn.DML IS 'WELK TYPE DML BETREFT DE WIJZGING';
COMMENT ON COLUMN tetools.admin_tnsnames_svn.INVOKING_USER IS 'USERNAME VAN DE GEBRUIKER DIE DE WIJZIGING HEEFT DOORGEVOERD';
COMMENT ON COLUMN tetools.admin_tnsnames_svn.BASE_TABLE IS 'TABEL WAAROP DE WIJZIGINGEN VAN TOEPASSING WAREN';
COMMENT ON COLUMN tetools.admin_tnsnames_svn.BASE_PK IS 'TECHNISCHE SLEUTEL VAN DE BASE TABEL';
COMMENT ON COLUMN tetools.admin_tnsnames_svn.BASE_ATTR IS 'ATTRIBUUT NAAM VAN DE BETREFFENDE WIJZIGING';
COMMENT ON COLUMN tetools.admin_tnsnames_svn.OLD_VALUE IS 'OUDE WAARDE VAN DE GEWIJZIGDE ATTRIBUUT (WANNEER VAN TOEPASSING)';
COMMENT ON COLUMN tetools.admin_tnsnames_svn.NEW_VALUE IS 'NIEUWE WAARDE VAN DE GEWIJZIGDE ATTRIBUUT (WANNEER VAN TOEPASSING)';
COMMENT ON COLUMN tetools.admin_tnsnames_svn.BACKUP_RECORD IS 'BACKUP STRING VAN DE TOTALE WIJZIGING (WANNEER VAN TOEPASSING)';


CREATE SEQUENCE tetools.admin_tnsnames_svn_svnid_seq
  START WITH     2047
  MINVALUE       2047
  INCREMENT BY   1
  ORDER;

SELECT tetools.admin_tnsnames_svn_svnid_seq.nextval FROM dual;


CREATE OR REPLACE TRIGGER TETOOLS.ADMIN_TNSNAMES_ENTRIES_CUD_TRG
AFTER UPDATE OR INSERT OR DELETE ON TETOOLS.ADMIN_TNSNAMES_ENTRIES
FOR EACH ROW
DECLARE
  y                               INTEGER           := 0;
  v_tname                         VARCHAR2(48)      := 'ADMIN_TNSNAMES_ENTRIES';
  v_this_object                   VARCHAR2(128);
  v_svn_date                      DATE              := sysdate;
  v_svn_pk                        INTEGER           := 0;
  v_svn_id                        INTEGER           := 0;
  v_tns_id                        INTEGER           := 0;
  v_username                      VARCHAR2(128);
  v_userid                        NUMBER;
  v_cud                           CHAR(1);  -- DML CAN BE: 'I'-INSERT, 'U'-UPDATE, 'D'-DELETE
  v_inv_roles                     VARCHAR2(2000);
  v_backup                        VARCHAR2(4000);
  v_isinvusr_adm                  CHAR(1);
  v_isinvusr_con                  CHAR(1);
  --
  PROCEDURE ECHO( STRING IN VARCHAR2, PAD IN VARCHAR2)
  AS
  BEGIN
    DBMS_OUTPUT.PUT_LINE( '  !' || RPAD( STRING, 97, PAD) || '!!');
  END ECHO;
  --
BEGIN
 --
  tetools.admin_tnsnames.who_called(v_this_object);
  --
	SELECT user INTO v_username FROM dual;
	SELECT user_id INTO v_userid FROM dba_users WHERE username = v_username;
	--
	compare_roles(v_inv_roles, v_isinvusr_adm, v_isinvusr_con);
  --
  tetools.admin_tnsnames_audit.max_svn(v_svn_id);
	--
	INSERT INTO TETOOLS.admin_tnsnames_meta (SVN_ID,
                                           USER_ID,
                                           USERNAME,
                                           ISADMIN,
                                           ISCONTRIBUTOR,
                                           USER_ROLES,
                                           CALLED_FROM) VALUES (v_svn_id,
                                                                v_userid,
                                                                v_username,
                                                                v_isinvusr_adm,
                                                                v_isinvusr_con,
                                                                JSON_OBJECT('INVOKING_USER_ROLES' VALUE v_inv_roles),
                                                                v_this_object);
	--
  IF INSERTING   THEN 
    v_cud := 'C';
    INSERT INTO tetools.admin_tnsnames_base (TNS_ID) VALUES (tetools.admin_tnsnames_base_tnsid_seq.nextval) RETURNING TNS_ID INTO v_tns_id;
    INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, NEW_VALUE) VALUES (v_svn_id, SYSDATE, v_cud, USER, v_tname, :NEW.TNS_ID,:NEW.TNS_ATTR, :NEW.TNS_ATTR_VALUE) RETURNING SVN_ID INTO v_svn_id;
    y := 16;
    --
  ELSIF UPDATING THEN
    v_cud := 'U';
    --
    IF ( UPDATING( 'TNS_ID' ) ) THEN
      IF :NEW.TNS_ID IS NOT NULL AND :NEW.TNS_ID <> :OLD.TNS_ID THEN
        tetools.admin_tnsnames_audit.check_val(v_svn_id, v_cud, v_tname, NVL(:OLD.TNS_ID, :NEW.TNS_ID), 'TNS_ID', :OLD.TNS_ID, NVL(:NEW.TNS_ID, NULL));
        y := y + 1;
      END IF;
    END IF;
    IF ( UPDATING( 'TNS_ATTR' ) ) THEN
      IF :NEW.TNS_ATTR IS NOT NULL AND :NEW.TNS_ATTR <> :OLD.TNS_ATTR THEN
        tetools.admin_tnsnames_audit.check_val(v_svn_id, v_cud, v_tname, NVL(:OLD.TNS_ID, :NEW.TNS_ID), 'TNS_ATTR', :OLD.TNS_ATTR, NVL(:NEW.TNS_ATTR, NULL));
        y := y + 2;
      END IF;
    END IF;
    IF ( UPDATING( 'HIERARCHY_CHILD_ID' ) ) THEN
      IF :NEW.HIERARCHY_CHILD_ID IS NOT NULL AND :NEW.HIERARCHY_CHILD_ID <> :OLD.HIERARCHY_CHILD_ID THEN
        tetools.admin_tnsnames_audit.check_val(v_svn_id, v_cud, v_tname,NVL(:OLD.TNS_ID, :NEW.TNS_ID), 'HIERARCHY_CHILD_ID', :OLD.HIERARCHY_CHILD_ID, NVL(:NEW.HIERARCHY_CHILD_ID, NULL));
        y := y + 4;
      END IF;
    END IF;
    IF ( UPDATING( 'TNS_ATTR_VALUE' ) ) THEN
      IF :NEW.TNS_ATTR_VALUE IS NOT NULL AND :NEW.TNS_ATTR_VALUE <> :OLD.TNS_ATTR_VALUE THEN
        tetools.admin_tnsnames_audit.check_val(v_svn_id, v_cud, v_tname, NVL(:OLD.TNS_ID, :NEW.TNS_ID), 'TNS_ATTR_VALUE', :OLD.TNS_ATTR_VALUE, NVL(:NEW.TNS_ATTR_VALUE, NULL));
        y := y + 8;
      END IF;
    END IF;
    --
  ELSIF DELETING THEN
    v_cud := 'D';
    --
    INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, OLD_VALUE) VALUES ( v_svn_id, SYSDATE, v_cud, USER, v_tname, NVL(:OLD.TNS_ID, :NEW.TNS_ID), UPPER(:OLD.TNS_ATTR), UPPER(:OLD.TNS_ATTR_VALUE)||' DELETED' );
    --
    y := 32;
    --
  END IF;
  --
  IF y = 1 THEN
   --
   DBMS_OUTPUT.PUT_LINE(chr(13)||chr(10));
   --
    ECHO( '!', '!');
    ECHO( '!', ' ');
    ECHO( '!! WARNING !!   TET - TRG_ADMIN_TNSNAMES_ENTRIES_CUD', ' ');
    ECHO( '!', ' ');
    ECHO( '!  On a functional level the requested update has the effect of a deletion.', ' ');
    ECHO( '!  The TNS_ID was altered, effectively removing the old registration.', ' ');
    ECHO( '!', ' ');
    ECHO( '!', '!');
  ELSIF y = 4 THEN
   --
   DBMS_OUTPUT.PUT_LINE(chr(13)||chr(10));
   --
    ECHO( '!', '!');
    ECHO( '!', ' ');
    ECHO( '!! WARNING !!   TET - TRG_ADMIN_TNSNAMES_ENTRIES_CUD', ' ');
    ECHO( '!', ' ');
    ECHO( '!  On a functional level the requested update has changed the dependency on the reference attributes.', ' ');
    ECHO( '!  The HIERARCHY_CHILD_ID was altered, effectively rearranging hierarchy of the attribute.', ' ');
    ECHO( '!  Be careful: The changes may behave differently than expected.', ' ');
    ECHO( '!  VERIFY YOUR UPDATES!!', ' ');
    ECHO( '!', ' ');
    ECHO( '!', '!');
  END IF;
  --
  y := 0; v_svn_id := 0;
END;
/


CREATE OR REPLACE TRIGGER TETOOLS.ADMIN_TNSNAMES_REFERENCE_CUD_TRG
AFTER UPDATE OR INSERT OR DELETE ON TETOOLS.ADMIN_TNSNAMES_REFERENCE
FOR EACH ROW
DECLARE
  y                               INTEGER           := 0;
  v_tname                         VARCHAR2(48)      := 'ADMIN_TNSNAMES_REFERENCE';
  v_this_object                   VARCHAR2(128);
  v_svn_date                      DATE              := sysdate;
  v_svn_pk                        INTEGER           := 0;
  v_svn_id                        INTEGER           := 0;
  v_attr_pk                       INTEGER           := 0;
  v_username                      VARCHAR2(128);
  v_new_reference_name            VARCHAR2(128);
  v_old_reference_name            VARCHAR2(128);
  v_defer_constraints             VARCHAR2(4000)    := 'SET CONSTRAINT admin_tnsnames_attributes_reference_hierarchy_child_id DEFERRED';
  v_immediate_constraints         VARCHAR2(4000)    := 'SET CONSTRAINT admin_tnsnames_attributes_reference_hierarchy_child_id IMMEDIATE';
  v_userid                        NUMBER;
  v_cud                           CHAR(1);  -- DML CAN BE: 'I'-INSERT, 'U'-UPDATE, 'D'-DELETE
  v_inv_roles                     VARCHAR2(2000);
  v_backup                        VARCHAR2(4000);
  v_isinvusr_adm                  CHAR(1);
  v_isinvusr_con                  CHAR(1);
  --
  PROCEDURE ECHO( STRING IN VARCHAR2, PAD IN VARCHAR2)
  AS
  BEGIN
    DBMS_OUTPUT.PUT_LINE( '  !' || RPAD( STRING, 97, PAD) || '!!');
  END ECHO;
  --
  --PRAGMA AUTONOMOUS_TRANSACTION;  
  --
BEGIN
 --
  tetools.admin_tnsnames.who_called(v_this_object);
  --
	SELECT user INTO v_username FROM dual;
	SELECT user_id INTO v_userid FROM dba_users WHERE username = v_username;
	--
	compare_roles(v_inv_roles, v_isinvusr_adm, v_isinvusr_con);
  --
  tetools.admin_tnsnames_audit.max_svn(v_svn_id);
	--
	INSERT INTO TETOOLS.admin_tnsnames_meta (SVN_ID,
                                           USER_ID,
                                           USERNAME,
                                           ISADMIN,
                                           ISCONTRIBUTOR,
                                           USER_ROLES,
                                           CALLED_FROM) VALUES (v_svn_id,
                                                                v_userid,
                                                                v_username,
                                                                v_isinvusr_adm,
                                                                v_isinvusr_con,
                                                                JSON_OBJECT('INVOKING_USER_ROLES' VALUE v_inv_roles),
                                                                v_this_object);
	--
  IF INSERTING   THEN 
    v_cud := 'C';
    --
    INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, NEW_VALUE) VALUES (v_svn_id, SYSDATE, v_cud, USER, v_tname, :NEW.REFERENCE_PK, 'REFERENCE_NAME', :NEW.REFERENCE_NAME);
    --
    IF :NEW.PURPOSE IS NOT NULL THEN
      INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, NEW_VALUE) VALUES (v_svn_id, SYSDATE, v_cud, USER, v_tname, :NEW.REFERENCE_PK, 'PURPOSE', :NEW.PURPOSE);
    END IF;
    IF :NEW.DESCRIPTION IS NOT NULL THEN
      INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, NEW_VALUE) VALUES (v_svn_id, SYSDATE, v_cud, USER, v_tname, :NEW.REFERENCE_PK, 'DESCRIPTION', :NEW.DESCRIPTION);
    END IF;
    IF :NEW.OPT_VALUES IS NOT NULL THEN
      INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, NEW_VALUE) VALUES (v_svn_id, SYSDATE, v_cud, USER, v_tname, :NEW.REFERENCE_PK, 'OPT_VALUES', :NEW.OPT_VALUES);
    END IF;
    IF :NEW.DEFAULT_VALUE IS NOT NULL THEN
      INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, NEW_VALUE) VALUES (v_svn_id, SYSDATE, v_cud, USER, v_tname, :NEW.REFERENCE_PK, 'DEFAULT_VALUE', :NEW.DEFAULT_VALUE);
    END IF;
    IF :NEW.MIN_VALUE IS NOT NULL THEN
      INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, NEW_VALUE) VALUES (v_svn_id, SYSDATE, v_cud, USER, v_tname, :NEW.REFERENCE_PK, 'MIN_VALUE', :NEW.MIN_VALUE);
    END IF;
    IF :NEW.MAX_VALUE IS NOT NULL THEN
      INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, NEW_VALUE) VALUES (v_svn_id, SYSDATE, v_cud, USER, v_tname, :NEW.REFERENCE_PK, 'MAX_VALUE', :NEW.MAX_VALUE);
    END IF;
    IF :NEW.EXAMPLE IS NOT NULL THEN
      INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, NEW_VALUE) VALUES (v_svn_id, SYSDATE, v_cud, USER, v_tname, :NEW.REFERENCE_PK, 'EXAMPLE', :NEW.EXAMPLE);
    END IF;
    --
    y := 256;
    --
  ELSIF UPDATING THEN
    v_cud := 'U';
    --
    IF ( UPDATING( 'REFERENCE_NAME' ) ) THEN
      IF :NEW.REFERENCE_NAME IS NOT NULL AND :NEW.REFERENCE_NAME <> :OLD.REFERENCE_NAME THEN
        --
        v_old_reference_name := :OLD.REFERENCE_NAME;
        v_new_reference_name := :NEW.REFERENCE_NAME;
        SELECT attr_pk INTO v_attr_pk FROM tetools.admin_tnsnames_attributes WHERE reference_name = v_old_reference_name;
        --
        EXECUTE IMMEDIATE v_defer_constraints;
        --
        tetools.admin_tnsnames_audit.check_val(v_svn_id, v_cud, v_tname, NVL(:OLD.REFERENCE_PK, :NEW.REFERENCE_PK), 'REFERENCE_NAME', :OLD.REFERENCE_NAME, NVL(:NEW.REFERENCE_NAME, NULL));
        UPDATE ADMIN_TNSNAMES_ATTRIBUTES SET reference_name = v_new_reference_name WHERE attr_pk = v_attr_pk;
        --
        EXECUTE IMMEDIATE v_immediate_constraints;
        --
        y := y + 1;
      END IF;
    END IF;
    IF ( UPDATING( 'PURPOSE' ) ) THEN
      IF :NEW.PURPOSE IS NOT NULL AND :NEW.PURPOSE <> :OLD.PURPOSE THEN
        tetools.admin_tnsnames_audit.check_val(v_svn_id, v_cud, v_tname, NVL(:OLD.REFERENCE_PK, :NEW.REFERENCE_PK), 'PURPOSE', :OLD.PURPOSE, NVL(:NEW.PURPOSE, NULL));
        y := y + 2;
      END IF;
    END IF;
    IF ( UPDATING( 'DESCRIPTION' ) ) THEN
      IF :NEW.DESCRIPTION IS NOT NULL AND :NEW.DESCRIPTION <> :OLD.DESCRIPTION THEN
        tetools.admin_tnsnames_audit.check_val(v_svn_id, v_cud, v_tname,NVL(:OLD.REFERENCE_PK, :NEW.REFERENCE_PK), 'DESCRIPTION', :OLD.DESCRIPTION, NVL(:NEW.DESCRIPTION, NULL));
        y := y + 4;
      END IF;
    END IF;
    IF ( UPDATING( 'OPT_VALUES' ) ) THEN
      IF :NEW.OPT_VALUES IS NOT NULL AND :NEW.OPT_VALUES <> :OLD.OPT_VALUES THEN
        tetools.admin_tnsnames_audit.check_val(v_svn_id, v_cud, v_tname, NVL(:OLD.REFERENCE_PK, :NEW.REFERENCE_PK), 'OPT_VALUES', :OLD.OPT_VALUES, NVL(:NEW.OPT_VALUES, NULL));
        y := y + 8;
      END IF;
    END IF;
    IF ( UPDATING( 'DEFAULT_VALUE' ) ) THEN
      IF :NEW.DEFAULT_VALUE IS NOT NULL AND :NEW.DEFAULT_VALUE <> :OLD.DEFAULT_VALUE THEN
        tetools.admin_tnsnames_audit.check_val(v_svn_id, v_cud, v_tname, NVL(:OLD.REFERENCE_PK, :NEW.REFERENCE_PK), 'DEFAULT_VALUE', :OLD.DEFAULT_VALUE, NVL(:NEW.DEFAULT_VALUE, NULL));
        y := y + 16;
      END IF;
    END IF;
    IF ( UPDATING( 'MIN_VALUE' ) ) THEN
      IF :NEW.MIN_VALUE IS NOT NULL AND :NEW.MIN_VALUE <> :OLD.MIN_VALUE THEN
        tetools.admin_tnsnames_audit.check_val(v_svn_id, v_cud, v_tname, NVL(:OLD.REFERENCE_PK, :NEW.REFERENCE_PK), 'MIN_VALUE', :OLD.MIN_VALUE, NVL(:NEW.MIN_VALUE, NULL));
        y := y + 32;
      END IF;
    END IF;
    IF ( UPDATING( 'MAX_VALUE' ) ) THEN
      IF :NEW.MAX_VALUE IS NOT NULL AND :NEW.MAX_VALUE <> :OLD.MAX_VALUE THEN
        tetools.admin_tnsnames_audit.check_val(v_svn_id, v_cud, v_tname,NVL(:OLD.REFERENCE_PK, :NEW.REFERENCE_PK), 'MAX_VALUE', :OLD.MAX_VALUE, NVL(:NEW.MAX_VALUE, NULL));
        y := y + 64;
      END IF;
    END IF;
    IF ( UPDATING( 'EXAMPLE' ) ) THEN
      IF :NEW.EXAMPLE IS NOT NULL AND :NEW.EXAMPLE <> :OLD.EXAMPLE THEN
        tetools.admin_tnsnames_audit.check_val(v_svn_id, v_cud, v_tname, NVL(:OLD.REFERENCE_PK, :NEW.REFERENCE_PK), 'EXAMPLE', :OLD.EXAMPLE, NVL(:NEW.EXAMPLE, NULL));
        y := y + 128;
      END IF;
    END IF;
    --
  ELSIF DELETING THEN
    v_cud := 'D';
    --
    INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, OLD_VALUE) VALUES ( v_svn_id, SYSDATE, v_cud, USER, v_tname, NVL(:OLD.REFERENCE_PK, :NEW.REFERENCE_PK), :OLD.REFERENCE_NAME, 'DELETED');
    --
    y := 512;
    --
  END IF;
  --
  IF y = 1 THEN
   --
   DBMS_OUTPUT.PUT_LINE(chr(13)||chr(10));
   --
    ECHO( '!', '!');
    ECHO( '!', ' ');
    ECHO( '!! WARNING !!   TET - TRG_ADMIN_TNSNAMES_REFERENCE_CUD', ' ');
    ECHO( '!', ' ');
    ECHO( '!  On a functional level the requested update has the effect of a deletion.', ' ');
    ECHO( '!  The REFERENCE_NAME was altered, effectively removing the old registration.', ' ');
    ECHO( '!', ' ');
    ECHO( '!', '!');
  END IF;
  --
  y := 0; v_svn_id := 0;
END;
/


CREATE OR REPLACE TRIGGER TETOOLS.ADMIN_TNSNAMES_ATTRIBUTES_CUD_TRG
AFTER UPDATE OR INSERT OR DELETE ON TETOOLS.ADMIN_TNSNAMES_ATTRIBUTES
FOR EACH ROW
DECLARE
  y                               INTEGER           := 0;
  v_tname                         VARCHAR2(48)      := 'ADMIN_TNSNAMES_ATTRIBUTES';
  v_this_object                   VARCHAR2(128);
  v_svn_date                      DATE              := sysdate;
  v_svn_pk                        INTEGER           := 0;
  v_svn_id                        INTEGER           := 0;
  v_username                      VARCHAR2(128);
  v_userid                        NUMBER;
  v_cud                           CHAR(1);  -- DML CAN BE: 'I'-INSERT, 'U'-UPDATE, 'D'-DELETE
  v_inv_roles                     VARCHAR2(2000);
  v_backup                        VARCHAR2(4000);
  v_isinvusr_adm                  CHAR(1);
  v_isinvusr_con                  CHAR(1);
  --
  PROCEDURE ECHO( STRING IN VARCHAR2, PAD IN VARCHAR2)
  AS
  BEGIN
    DBMS_OUTPUT.PUT_LINE( '  !' || RPAD( STRING, 97, PAD) || '!!');
  END ECHO;
  --
BEGIN
 --
  tetools.admin_tnsnames.who_called(v_this_object);
  --
	SELECT user INTO v_username FROM dual;
	SELECT user_id INTO v_userid FROM dba_users WHERE username = v_username;
	--
	compare_roles(v_inv_roles, v_isinvusr_adm, v_isinvusr_con);
  --
  tetools.admin_tnsnames_audit.max_svn(v_svn_id);
	--
	INSERT INTO TETOOLS.admin_tnsnames_meta (SVN_ID,
                                           USER_ID,
                                           USERNAME,
                                           ISADMIN,
                                           ISCONTRIBUTOR,
                                           USER_ROLES,
                                           CALLED_FROM) VALUES (v_svn_id,
                                                                v_userid,
                                                                v_username,
                                                                v_isinvusr_adm,
                                                                v_isinvusr_con,
                                                                JSON_OBJECT('INVOKING_USER_ROLES' VALUE v_inv_roles),
                                                                v_this_object);
	--
  IF INSERTING   THEN 
    v_cud := 'C';
    --
    INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, NEW_VALUE) VALUES (v_svn_id, SYSDATE, v_cud, USER, v_tname, :NEW.ATTR_PK, 'REFERENCE_NAME', 'CREATED');
    --
    IF :NEW.ATTRIBUTE_NAME IS NOT NULL THEN
      INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, NEW_VALUE) VALUES (v_svn_id, SYSDATE, v_cud, USER, v_tname, :NEW.ATTR_PK, 'ATTRIBUTE_NAME', :NEW.ATTRIBUTE_NAME);
    END IF;
    IF :NEW.LEAF_MEMBER IS NOT NULL THEN
      INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, NEW_VALUE) VALUES (v_svn_id, SYSDATE, v_cud, USER, v_tname, :NEW.ATTR_PK, 'LEAF_MEMBER', :NEW.LEAF_MEMBER);
    END IF;
    IF :NEW.DATA_TYPE IS NOT NULL THEN
      INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, NEW_VALUE) VALUES (v_svn_id, SYSDATE, v_cud, USER, v_tname, :NEW.ATTR_PK, 'DATA_TYPE', :NEW.DATA_TYPE);
    END IF;
    IF :NEW.HIERARCHY_PARENT_ID IS NOT NULL THEN
      INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, NEW_VALUE) VALUES (v_svn_id, SYSDATE, v_cud, USER, v_tname, :NEW.ATTR_PK, 'HIERARCHY_PARENT_ID', :NEW.HIERARCHY_PARENT_ID);
    END IF;
    IF :NEW.HIERARCHY_CHILD_ID IS NOT NULL THEN
      INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, NEW_VALUE) VALUES (v_svn_id, SYSDATE, v_cud, USER, v_tname, :NEW.ATTR_PK, 'HIERARCHY_CHILD_ID', :NEW.HIERARCHY_CHILD_ID);
    END IF;
    IF :NEW.HIERARCHY_SORT IS NOT NULL THEN
      INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, NEW_VALUE) VALUES (v_svn_id, SYSDATE, v_cud, USER, v_tname, :NEW.ATTR_PK, 'HIERARCHY_SORT', :NEW.HIERARCHY_SORT);
    END IF;
    IF :NEW.MANDATORY IS NOT NULL THEN
      INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, NEW_VALUE) VALUES (v_svn_id, SYSDATE, v_cud, USER, v_tname, :NEW.ATTR_PK, 'MANDATORY', :NEW.MANDATORY);
    END IF;
    IF :NEW.GT_ONE_OCC IS NOT NULL THEN
      INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, NEW_VALUE) VALUES (v_svn_id, SYSDATE, v_cud, USER, v_tname, :NEW.ATTR_PK, 'GT_ONE_OCC', :NEW.GT_ONE_OCC);
    END IF;
    IF :NEW.STATUS IS NOT NULL THEN
      INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, NEW_VALUE) VALUES (v_svn_id, SYSDATE, v_cud, USER, v_tname, :NEW.ATTR_PK, 'STATUS', :NEW.STATUS);
    END IF;
    --
    y := 256;
    --
  ELSIF UPDATING THEN
    v_cud := 'U';
    --
    IF ( UPDATING( 'REFERENCE_NAME' ) ) THEN
      IF :NEW.REFERENCE_NAME IS NOT NULL AND :NEW.REFERENCE_NAME <> :OLD.REFERENCE_NAME THEN
        tetools.admin_tnsnames_audit.check_val(v_svn_id, v_cud, v_tname, NVL(:OLD.ATTR_PK, :NEW.ATTR_PK), 'REFERENCE_NAME', :OLD.REFERENCE_NAME, NVL(:NEW.REFERENCE_NAME, NULL));
        y := y + 1;
      END IF;
    END IF;
    IF ( UPDATING( 'ATTRIBUTE_NAME' ) ) THEN
      IF :NEW.ATTRIBUTE_NAME IS NOT NULL AND :NEW.ATTRIBUTE_NAME <> :OLD.ATTRIBUTE_NAME THEN
        tetools.admin_tnsnames_audit.check_val(v_svn_id, v_cud, v_tname, NVL(:OLD.ATTR_PK, :NEW.ATTR_PK), 'ATTRIBUTE_NAME', :OLD.ATTRIBUTE_NAME, NVL(:NEW.ATTRIBUTE_NAME, NULL));
        y := y + 2;
      END IF;
    END IF;
    IF ( UPDATING( 'LEAF_MEMBER' ) ) THEN
      IF :NEW.LEAF_MEMBER IS NOT NULL AND :NEW.LEAF_MEMBER <> :OLD.LEAF_MEMBER THEN
        tetools.admin_tnsnames_audit.check_val(v_svn_id, v_cud, v_tname,NVL(:OLD.ATTR_PK, :NEW.ATTR_PK), 'LEAF_MEMBER', :OLD.LEAF_MEMBER, NVL(:NEW.LEAF_MEMBER, NULL));
        y := y + 4;
      END IF;
    END IF;
    IF ( UPDATING( 'DATA_TYPE' ) ) THEN
      IF :NEW.DATA_TYPE IS NOT NULL AND :NEW.DATA_TYPE <> :OLD.DATA_TYPE THEN
        tetools.admin_tnsnames_audit.check_val(v_svn_id, v_cud, v_tname, NVL(:OLD.ATTR_PK, :NEW.ATTR_PK), 'DATA_TYPE', :OLD.DATA_TYPE, NVL(:NEW.DATA_TYPE, NULL));
        y := y + 8;
      END IF;
    END IF;
    IF ( UPDATING( 'HIERARCHY_PARENT_ID' ) ) THEN
      IF :NEW.HIERARCHY_PARENT_ID IS NOT NULL AND :NEW.HIERARCHY_PARENT_ID <> :OLD.HIERARCHY_PARENT_ID THEN
        tetools.admin_tnsnames_audit.check_val(v_svn_id, v_cud, v_tname, NVL(:OLD.ATTR_PK, :NEW.ATTR_PK), 'HIERARCHY_PARENT_ID', :OLD.HIERARCHY_PARENT_ID, NVL(:NEW.HIERARCHY_PARENT_ID, NULL));
        y := y + 16;
      END IF;
    END IF;
    IF ( UPDATING( 'HIERARCHY_CHILD_ID' ) ) THEN
      IF :NEW.HIERARCHY_CHILD_ID IS NOT NULL AND :NEW.HIERARCHY_CHILD_ID <> :OLD.HIERARCHY_CHILD_ID THEN
        tetools.admin_tnsnames_audit.check_val(v_svn_id, v_cud, v_tname, NVL(:OLD.ATTR_PK, :NEW.ATTR_PK), 'HIERARCHY_CHILD_ID', :OLD.HIERARCHY_CHILD_ID, NVL(:NEW.HIERARCHY_CHILD_ID, NULL));
        y := y + 32;
      END IF;
    END IF;
    IF ( UPDATING( 'HIERARCHY_SORT' ) ) THEN
      IF :NEW.HIERARCHY_SORT IS NOT NULL AND :NEW.HIERARCHY_SORT <> :OLD.HIERARCHY_SORT THEN
        tetools.admin_tnsnames_audit.check_val(v_svn_id, v_cud, v_tname,NVL(:OLD.ATTR_PK, :NEW.ATTR_PK), 'HIERARCHY_SORT', :OLD.HIERARCHY_SORT, NVL(:NEW.HIERARCHY_SORT, NULL));
        y := y + 64;
      END IF;
    END IF;
    IF ( UPDATING( 'MANDATORY' ) ) THEN
      IF :NEW.MANDATORY IS NOT NULL AND :NEW.MANDATORY <> :OLD.MANDATORY THEN
        tetools.admin_tnsnames_audit.check_val(v_svn_id, v_cud, v_tname, NVL(:OLD.ATTR_PK, :NEW.ATTR_PK), 'MANDATORY', :OLD.MANDATORY, NVL(:NEW.MANDATORY, NULL));
        y := y + 128;
      END IF;
    END IF;
    IF ( UPDATING( 'GT_ONE_OCC' ) ) THEN
      IF :NEW.GT_ONE_OCC IS NOT NULL AND :NEW.GT_ONE_OCC <> :OLD.GT_ONE_OCC THEN
        tetools.admin_tnsnames_audit.check_val(v_svn_id, v_cud, v_tname, NVL(:OLD.ATTR_PK, :NEW.ATTR_PK), 'GT_ONE_OCC', :OLD.GT_ONE_OCC, NVL(:NEW.GT_ONE_OCC, NULL));
        y := y + 128;
      END IF;
    END IF;
    --
  ELSIF DELETING THEN
    v_cud := 'D';
    --
    INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, OLD_VALUE) VALUES ( v_svn_id, SYSDATE, v_cud, USER, v_tname, NVL(:OLD.ATTR_PK, :NEW.ATTR_PK), :OLD.REFERENCE_NAME, 'DELETED');
    --
    y := 512;
    --
  END IF;
  --
  IF y = 1 THEN
   --
   DBMS_OUTPUT.PUT_LINE(chr(13)||chr(10));
   --
    ECHO( '!', '!');
    ECHO( '!', ' ');
    ECHO( '!! WARNING !!   TET - TRG_ADMIN_TNSNAMES_ATTRIBUTES_CUD', ' ');
    ECHO( '!', ' ');
    ECHO( '!  On a functional level the requested update has the effect of a deletion.', ' ');
    ECHO( '!  The REFERENCE_NAME was altered, effectively removing the old registration.', ' ');
    ECHO( '!', ' ');
    ECHO( '!', '!');
  END IF;
  --
  y := 0; v_svn_id := 0;
END;
/


CREATE OR REPLACE TRIGGER TETOOLS.ADMIN_TNSNAMES_CHECKS_CUD_TRG
AFTER UPDATE OR INSERT OR DELETE ON TETOOLS.ADMIN_TNSNAMES_CHECKS
FOR EACH ROW
DECLARE
  y                               INTEGER           := 0;
  v_tname                         VARCHAR2(48)      := 'ADMIN_TNSNAMES_CHECKS';
  v_this_object                   VARCHAR2(128);
  v_svn_date                      DATE              := sysdate;
  v_svn_pk                        INTEGER           := 0;
  v_svn_id                        INTEGER           := 0;
  v_username                      VARCHAR2(128);
  v_userid                        NUMBER;
  v_cud                           CHAR(1);  -- DML CAN BE: 'I'-INSERT, 'U'-UPDATE, 'D'-DELETE
  v_inv_roles                     VARCHAR2(2000);
  v_backup                        VARCHAR2(4000);
  v_isinvusr_adm                  CHAR(1);
  v_isinvusr_con                  CHAR(1);
  --
  PROCEDURE ECHO( STRING IN VARCHAR2, PAD IN VARCHAR2)
  AS
  BEGIN
    DBMS_OUTPUT.PUT_LINE( '  !' || RPAD( STRING, 97, PAD) || '!!');
  END ECHO;
  --
BEGIN
 --
  tetools.admin_tnsnames.who_called(v_this_object);
  --
	SELECT user INTO v_username FROM dual;
	SELECT user_id INTO v_userid FROM dba_users WHERE username = v_username;
	--
	compare_roles(v_inv_roles, v_isinvusr_adm, v_isinvusr_con);
  --
  tetools.admin_tnsnames_audit.max_svn(v_svn_id);
	--
	INSERT INTO TETOOLS.admin_tnsnames_meta (SVN_ID,
                                           USER_ID,
                                           USERNAME,
                                           ISADMIN,
                                           ISCONTRIBUTOR,
                                           USER_ROLES,
                                           CALLED_FROM) VALUES (v_svn_id,
                                                                v_userid,
                                                                v_username,
                                                                v_isinvusr_adm,
                                                                v_isinvusr_con,
                                                                JSON_OBJECT('INVOKING_USER_ROLES' VALUE v_inv_roles),
                                                                v_this_object);
	--
  IF INSERTING   THEN 
    v_cud := 'C';
    --
    INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, NEW_VALUE) VALUES (v_svn_id, SYSDATE, v_cud, USER, v_tname, :NEW.CHECK_PK, 'ATTRIBUTE_CHECK', 'CREATED');
    --
    IF :NEW.TNS_ATTR IS NOT NULL THEN
      INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, NEW_VALUE) VALUES (v_svn_id, SYSDATE, v_cud, USER, v_tname, :NEW.CHECK_PK, 'ATTRIBUTE_NAME', :NEW.TNS_ATTR);
    END IF;
    IF :NEW.HIERARCHY_CHILD_ID IS NOT NULL THEN
      INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, NEW_VALUE) VALUES (v_svn_id, SYSDATE, v_cud, USER, v_tname, :NEW.CHECK_PK, 'HIERARCHY_CHILD_ID', :NEW.HIERARCHY_CHILD_ID);
    END IF;
    IF :NEW.TNS_ATTR_CHECK IS NOT NULL THEN
      INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, NEW_VALUE) VALUES (v_svn_id, SYSDATE, v_cud, USER, v_tname, :NEW.CHECK_PK, 'TNS_ATTR_CHECK', :NEW.TNS_ATTR_CHECK);
    END IF;
    --
    y := 256;
    --
  ELSIF UPDATING THEN
    v_cud := 'U';
    --
    IF ( UPDATING( 'TNS_ATTR' ) ) THEN
      IF :NEW.TNS_ATTR IS NOT NULL AND :NEW.TNS_ATTR <> :OLD.TNS_ATTR THEN
        tetools.admin_tnsnames_audit.check_val(v_svn_id, v_cud, v_tname, NVL(:OLD.CHECK_PK, :NEW.CHECK_PK), 'ATTRIBUTE_CHECK', :OLD.TNS_ATTR, NVL(:NEW.TNS_ATTR, NULL));
        y := y + 1;
      END IF;
    END IF;
    IF ( UPDATING( 'HIERARCHY_CHILD_ID' ) ) THEN
      IF :NEW.HIERARCHY_CHILD_ID IS NOT NULL AND :NEW.HIERARCHY_CHILD_ID <> :OLD.HIERARCHY_CHILD_ID THEN
        tetools.admin_tnsnames_audit.check_val(v_svn_id, v_cud, v_tname, NVL(:OLD.CHECK_PK, :NEW.CHECK_PK), 'HIERARCHY_CHILD_ID', :OLD.HIERARCHY_CHILD_ID, NVL(:NEW.HIERARCHY_CHILD_ID, NULL));
        y := y + 2;
      END IF;
    END IF;
    IF ( UPDATING( 'TNS_ATTR_CHECK' ) ) THEN
      IF :NEW.TNS_ATTR_CHECK IS NOT NULL AND :NEW.TNS_ATTR_CHECK <> :OLD.TNS_ATTR_CHECK THEN
        tetools.admin_tnsnames_audit.check_val(v_svn_id, v_cud, v_tname,NVL(:OLD.CHECK_PK, :NEW.CHECK_PK), 'TNS_ATTR_CHECK', :OLD.TNS_ATTR_CHECK, NVL(:NEW.TNS_ATTR_CHECK, NULL));
        y := y + 4;
      END IF;
    END IF;
    --
  ELSIF DELETING THEN
    v_cud := 'D';
    --
    INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, OLD_VALUE) VALUES ( v_svn_id, SYSDATE, v_cud, USER, v_tname, NVL(:OLD.CHECK_PK, :NEW.CHECK_PK), :OLD.TNS_ATTR_CHECK, 'DELETED');
    --
    y := 512;
    --
  END IF;
  --
  IF y = 1 THEN
   --
   DBMS_OUTPUT.PUT_LINE(chr(13)||chr(10));
   --
    ECHO( '!', '!');
    ECHO( '!', ' ');
    ECHO( '!! WARNING !!   TET - TRG_ADMIN_TNSNAMES_CHECKS_CUD', ' ');
    ECHO( '!', ' ');
    ECHO( '!  On a functional level the requested update has the effect of a deletion.', ' ');
    ECHO( '!  The TNS_ATTR was altered, effectively removing the old registration.', ' ');
    ECHO( '!', ' ');
    ECHO( '!', '!');
  END IF;
  --
  y := 0; v_svn_id := 0;
END;
/

/* COMPARE_ROLES ERROR STACK: ORA-04091: table TETOOLS.ADMIN_TNSNAMES_PREFS is mutating, trigger/function may not see it  */
/* Totdat een betere manier is gevonden om de controles te doen, tegen dezelfde tabel aan, levert onderstaande trigger niks op. *
-- CREATE OR REPLACE TRIGGER TETOOLS.TRG_ADMIN_TNSNAMES_PREFS_CUD
-- AFTER UPDATE OR INSERT OR DELETE ON TETOOLS.ADMIN_TNSNAMES_PREFS
-- FOR EACH ROW
-- DECLARE
--   y                               INTEGER           := 0;
--   v_tname                         VARCHAR2(48)      := 'ADMIN_TNSNAMES_PREFS';
--   v_this_object                   VARCHAR2(128);
--   v_svn_date                      DATE              := sysdate;
--   v_svn_pk                        INTEGER           := 0;
--   v_svn_id                        INTEGER           := 0;
--   v_username                      VARCHAR2(128);
--   v_userid                        NUMBER;
--   v_cud                           CHAR(1);  -- DML CAN BE: 'I'-INSERT, 'U'-UPDATE, 'D'-DELETE
--   v_inv_roles                     VARCHAR2(2000);
--   v_backup                        VARCHAR2(4000);
--   v_isinvusr_adm                  CHAR(1);
--   v_isinvusr_con                  CHAR(1);
--   --
--   PROCEDURE ECHO( STRING IN VARCHAR2, PAD IN VARCHAR2)
--   AS
--   BEGIN
--     DBMS_OUTPUT.PUT_LINE( '  !' || RPAD( STRING, 97, PAD) || '!!');
--   END ECHO;
--   --
-- BEGIN
--  --
--   tetools.admin_tnsnames.who_called(v_this_object);
--   --
-- 	SELECT user INTO v_username FROM dual;
-- 	SELECT user_id INTO v_userid FROM dba_users WHERE username = v_username;
-- 	--
-- 	compare_roles(v_inv_roles, v_isinvusr_adm, v_isinvusr_con);
--   --
--   tetools.admin_tnsnames_audit.max_svn(v_svn_id);
-- 	--
-- 	INSERT INTO TETOOLS.admin_tnsnames_meta (SVN_ID,
--                                            USER_ID,
--                                            USERNAME,
--                                            ISADMIN,
--                                            ISCONTRIBUTOR,
--                                            USER_ROLES,
--                                            CALLED_FROM) VALUES (v_svn_id,
--                                                                 v_userid,
--                                                                 v_username,
--                                                                 v_isinvusr_adm,
--                                                                 v_isinvusr_con,
--                                                                 JSON_OBJECT('INVOKING_USER_ROLES' VALUE v_inv_roles),
--                                                                 v_this_object);
-- 	--
--   IF INSERTING   THEN 
--     v_cud := 'C';
--     --
--     INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, NEW_VALUE) VALUES (v_svn_id, SYSDATE, v_cud, USER, v_tname, :NEW.PREF_PK, 'PREFERENCE', 'CREATED');
--     --
--     IF :NEW.PREF_TABLE IS NOT NULL THEN
--       INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, NEW_VALUE) VALUES (v_svn_id, SYSDATE, v_cud, USER, v_tname, :NEW.PREF_PK, 'PREF_TABLE', :NEW.PREF_TABLE);
--     END IF;
--     IF :NEW.PREF_NAME IS NOT NULL THEN
--       INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, NEW_VALUE) VALUES (v_svn_id, SYSDATE, v_cud, USER, v_tname, :NEW.PREF_PK, 'PREF_NAME', :NEW.PREF_NAME);
--     END IF;
--     IF :NEW.PREF_VALUE IS NOT NULL THEN
--       INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, NEW_VALUE) VALUES (v_svn_id, SYSDATE, v_cud, USER, v_tname, :NEW.PREF_PK, 'PREF_VALUE', :NEW.PREF_VALUE);
--     END IF;
--     --
--     y := 256;
--     --
--   ELSIF UPDATING THEN
--     v_cud := 'U';
--     --
--     IF ( UPDATING( 'PREF_TABLE' ) ) THEN
--       IF :NEW.PREF_TABLE IS NOT NULL AND :NEW.PREF_TABLE <> :OLD.PREF_TABLE THEN
--         tetools.admin_tnsnames_audit.check_val(v_svn_id, v_cud, v_tname, NVL(:OLD.PREF_PK, :NEW.PREF_PK), 'PREF_TABLE', :OLD.PREF_TABLE, NVL(:NEW.PREF_TABLE, NULL));
--         y := y + 1;
--       END IF;
--     END IF;
--     IF ( UPDATING( 'PREF_NAME' ) ) THEN
--       IF :NEW.PREF_NAME IS NOT NULL AND :NEW.PREF_NAME <> :OLD.PREF_NAME THEN
--         tetools.admin_tnsnames_audit.check_val(v_svn_id, v_cud, v_tname, NVL(:OLD.PREF_PK, :NEW.PREF_PK), 'PREF_NAME', :OLD.PREF_NAME, NVL(:NEW.PREF_NAME, NULL));
--         y := y + 2;
--       END IF;
--     END IF;
--     IF ( UPDATING( 'PREF_VALUE' ) ) THEN
--       IF :NEW.PREF_VALUE IS NOT NULL AND :NEW.PREF_VALUE <> :OLD.PREF_VALUE THEN
--         tetools.admin_tnsnames_audit.check_val(v_svn_id, v_cud, v_tname,NVL(:OLD.PREF_PK, :NEW.PREF_PK), 'PREF_VALUE', :OLD.PREF_VALUE, NVL(:NEW.PREF_VALUE, NULL));
--         y := y + 4;
--       END IF;
--     END IF;
--     --
--   ELSIF DELETING THEN
--     v_cud := 'D';
--     --
--     INSERT INTO tetools.admin_tnsnames_svn (SVN_ID, SVN_DATE, DML, INVOKING_USER, BASE_TABLE, BASE_PK, BASE_ATTR, OLD_VALUE) VALUES ( v_svn_id, SYSDATE, v_cud, USER, v_tname, NVL(:OLD.PREF_PK, :NEW.PREF_PK), :OLD.PREF_NAME, 'DELETED');
--     --
--     y := 512;
--     --
--   END IF;
--   --
--   IF y = 1 THEN
--    --
--    DBMS_OUTPUT.PUT_LINE(chr(13)||chr(10));
--    --
--     ECHO( '!', '!');
--     ECHO( '!', ' ');
--     ECHO( '!! WARNING !!   TET - TRG_ADMIN_TNSNAMES_PREFS_CUD', ' ');
--     ECHO( '!', ' ');
--     ECHO( '!  On a functional level the requested update has the effect of a deletion.', ' ');
--     ECHO( '!  The TNS_ID was altered, effectively removing the old registration.', ' ');
--     ECHO( '!', ' ');
--     ECHO( '!', '!');
--   END IF;
--   --
--   y := 0; v_svn_id := 0;
-- END;
-- /













CREATE TABLE tetools.admin_tnsnames_demo (
  DEMO_ID                        INTEGER GENERATED ALWAYS AS IDENTITY,
  DEMO_KEY                       VARCHAR(32),
  DEMO_VALUE                     VARCHAR(128),
  CONSTRAINT admin_tnsnames_demo_pk PRIMARY KEY (DEMO_ID) ENABLE
);

INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', '20.30.40');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', '30.40');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', '10.20.30.40.55');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', '192.0.2.10');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', '192.0.2.10');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', '192.0.2.10');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', '192.0.2.10');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', '192.0.2.10');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', '192.0.2.10');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', '1781.0.14.209');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'a.b.c.d');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', '192.0.2.10');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', '192.0.2.10');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'host-demo');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'host-demo.nm0116');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'host-demo!16');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'host-demo');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'https://example.com');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'http://www.example.com');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'http://example.com');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'https://example.com');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'www.example.com');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.com');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'www1.example.com');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'www.example1.com');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'host-demo');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'host-demo');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'host-demo');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'host-demo');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'host-demo');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'host-demo');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'host-demo');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'host-demo');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('HOST_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('DOMAIN_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('DOMAIN_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('DOMAIN_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('DOMAIN_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('DOMAIN_NAME', 'example.invalid');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('SERVICE_NAME', 'maandag_7');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('SERVICE_NAME', 'maandag_12');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('SERVICE_NAME', 'maandag_14');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('SERVICE_NAME', 'maandag_15');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('SERVICE_NAME', 'maandag_18');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('SERVICE_NAME', 'maandag_20');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('SERVICE_NAME', 'maandag_21');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('SERVICE_NAME', 'maandag_24');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('SERVICE_NAME', 'maandag_33');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('SERVICE_NAME', 'maandag_39');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('SERVICE_NAME', 'maandag_40');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('TNS_ALIAS', 'PEURES');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('TNS_ALIAS', 'pjim');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('TNS_ALIAS', 'P31WDO');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('TNS_ALIAS', 'PWVK');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('TNS_ALIAS', 'PPVA');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('TNS_ALIAS', 'P11WBSB');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('TNS_ALIAS', 'P11EDV');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('TNS_ALIAS', 'P11SOA');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('TNS_ALIAS', 'PUZSQDB01');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('TNS_ALIAS', 'PCBSDB01');
INSERT INTO TETOOLS.ADMIN_TNSNAMES_DEMO (demo_key, demo_value) VALUES ('TNS_ALIAS', 'PSONC');
COMMIT;




