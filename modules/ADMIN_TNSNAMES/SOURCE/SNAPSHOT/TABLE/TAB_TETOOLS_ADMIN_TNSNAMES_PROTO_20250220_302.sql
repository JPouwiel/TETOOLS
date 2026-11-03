CREATE TABLE tetools.admin_tnsnames_proto_entries
( PROTO_ENTRY_PK                        INTEGER GENERATED ALWAYS AS IDENTITY,
  PROTO_TNS_ID                          INTEGER                     NOT NULL,
  TNS_ATTR                              VARCHAR2(32)                NOT NULL,
  TNS_ATTR_VALUE                        VARCHAR2(2048)              NOT NULL,
  USER_ID                               NUMBER                      NOT NULL,
  USERNAME                              VARCHAR2(128)               NOT NULL,
  ISADMIN                               CHAR(1)                     NOT NULL,
  ISCONTRIBUTOR                         CHAR(1)                     NOT NULL,
  USER_ROLES                            VARCHAR2(2048)              NOT NULL,
  CALLED_FROM                           VARCHAR2(256)               NOT NULL,
  INTAKE_LINE_SYNTAX_VALIDATED          CHAR(1)         DEFAULT 'N' NOT NULL,
  INTAKE_LINE_VALUE_VALIDATED           CHAR(1)         DEFAULT 'N' NOT NULL,
  INTAKE_ENTRY_ACCEPTED                 CHAR(1)         DEFAULT 'N' NOT NULL,
  REGISTRATION_LINE_SYNTAX_VALIDATED    CHAR(1)         DEFAULT 'N' NOT NULL,
  REGISTRATION_LINE_VALUE_VALIDATED     CHAR(1)         DEFAULT 'N' NOT NULL,
  REGISTRATION_ENTRY_ACCEPTED           CHAR(1)         DEFAULT 'N' NOT NULL,
  REGISTRATION_ENTRY_PROCESS_DATE       DATE                            NULL,
  LAST_INTAKE_VALIDATION_DATE           DATE                            NULL,
  LAST_REGISTRATION_VALIDATION_DATE     DATE                            NULL,
  CONSTRAINT admin_tnsnames_proto_entries_pk PRIMARY KEY (PROTO_ENTRY_PK) ENABLE,
  CONSTRAINT admin_tnsnames_proto_entries_attributes_tns_attr FOREIGN KEY (TNS_ATTR) REFERENCES tetools.admin_tnsnames_attributes (ATTRIBUTE_NAME) ENABLE,
  CONSTRAINT admin_tnsnames_proto_entries_urls CHECK (USER_ROLES IS JSON) ENABLE,
  CONSTRAINT admin_tnsnames_proto_entries_iadm CHECK (ISADMIN IN ('Y','N')) ENABLE,
  CONSTRAINT admin_tnsnames_proto_entries_icon CHECK (ISCONTRIBUTOR IN ('Y','N')) ENABLE,
  CONSTRAINT admin_tnsnames_proto_entries_ilsv CHECK (INTAKE_LINE_SYNTAX_VALIDATED IN ('Y','N')) ENABLE,
  CONSTRAINT admin_tnsnames_proto_entries_ilvv CHECK (INTAKE_LINE_VALUE_VALIDATED IN ('Y','N')) ENABLE,
  CONSTRAINT admin_tnsnames_proto_entries_ieac CHECK (INTAKE_ENTRY_ACCEPTED IN ('Y','N')) ENABLE,
  CONSTRAINT admin_tnsnames_proto_entries_rlsv CHECK (REGISTRATION_LINE_SYNTAX_VALIDATED IN ('Y','N')) ENABLE,
  CONSTRAINT admin_tnsnames_proto_entries_rlvv CHECK (REGISTRATION_LINE_VALUE_VALIDATED IN ('Y','N')) ENABLE,
  CONSTRAINT admin_tnsnames_proto_entries_reac CHECK (REGISTRATION_ENTRY_ACCEPTED IN ('Y','N')) ENABLE
);

COMMENT ON TABLE tetools.admin_tnsnames_proto_entries IS 'UNIEKE BASIS REGISTRATIE VAN DE PROTO TNS IDs';
COMMENT ON COLUMN tetools.admin_tnsnames_proto_entries.PROTO_ENTRY_PK IS 'TECHNISCHE SLEUTEL VOOR DE TABEL';
COMMENT ON COLUMN tetools.admin_tnsnames_proto_entries.PROTO_TNS_ID IS 'UNIEKE ID GEGENEREERD DOOR tetools.admin_tnsnames_proto_entries_prototnsid_seq';
COMMENT ON COLUMN tetools.admin_tnsnames_proto_entries.TNS_ATTR IS 'TNS ATTRIBUUT ZOALS GEGEVEN DOOR GEBRUIKER';
COMMENT ON COLUMN tetools.admin_tnsnames_proto_entries.TNS_ATTR_VALUE IS 'TNS ATTRIBUUT WAARDE ZOALS GEGEVEN DOOR GEBRUIKER';
COMMENT ON COLUMN tetools.admin_tnsnames_proto_entries.USER_ID IS 'USER ID VAN DE AANROEPENDE GEBRUIKER';
COMMENT ON COLUMN tetools.admin_tnsnames_proto_entries.USERNAME IS 'USERNAME VAN DE AANROEPENDE GEBRUIKER';
COMMENT ON COLUMN tetools.admin_tnsnames_proto_entries.ISADMIN IS 'WAS DE GEBRUIKER ADMIN OP MOMENT VAN AANROEPEN';
COMMENT ON COLUMN tetools.admin_tnsnames_proto_entries.ISCONTRIBUTOR IS 'WAS DE GEBRUIKER CONTRIBUTOR TEN TIJDE VAN AANROEPEN';
COMMENT ON COLUMN tetools.admin_tnsnames_proto_entries.USER_ROLES IS 'DE ROLLEN TOEGEWEZEN AAN DE GEBRUIKER TEN TIJDE VAN AANROEPEN';
COMMENT ON COLUMN tetools.admin_tnsnames_proto_entries.CALLED_FROM IS 'BESCHRIJVING HOE DE WIJZIGING AANGEROEPEN IS';
COMMENT ON COLUMN tetools.admin_tnsnames_proto_entries.INTAKE_LINE_SYNTAX_VALIDATED IS 'IS DE PROTO ATTRIBUUTNAAM REGEL GEVALIDEERD VIA REGULAR EXPRESSION';
COMMENT ON COLUMN tetools.admin_tnsnames_proto_entries.INTAKE_LINE_VALUE_VALIDATED IS 'IS DE WAARDE VAN HET PROTO ATTRIBUUT REGEL GEVORMD CONFORM DE NAAMGEVING, LET OP DIT IS GEEN INHOUDELIJKE CONTROLE!';
COMMENT ON COLUMN tetools.admin_tnsnames_proto_entries.INTAKE_ENTRY_ACCEPTED IS 'DE ACCEPTATIE VAN DE PROTO TNS ENTRY GELDT VOOR DE GEHELE ENTRY, DUS NIET OP REGELNIVEAU';
COMMENT ON COLUMN tetools.admin_tnsnames_proto_entries.REGISTRATION_LINE_SYNTAX_VALIDATED IS 'DE VLAG OF DE REGISTRATION ENTRY REGEL GEVALIDEERD IS';
COMMENT ON COLUMN tetools.admin_tnsnames_proto_entries.REGISTRATION_LINE_VALUE_VALIDATED IS 'DE VLAG OF DE REGISTRATION ENTRY REGEL GEVALIDEERD IS';
COMMENT ON COLUMN tetools.admin_tnsnames_proto_entries.REGISTRATION_ENTRY_ACCEPTED IS 'DE ACCEPTATIE VAN DE REGISTRATION TNS ENTRY GELDT VOOR DE GEHELE ENTRY, DUS NIET OP REGELNIVEAU';
COMMENT ON COLUMN tetools.admin_tnsnames_proto_entries.REGISTRATION_ENTRY_PROCESS_DATE IS 'DE DATUM WAAROP DE REGISTRATION ENTRY VOOR HET LAATST VERWERKT IS, GELDT VOOR DE GEHELE ENTRY, DUS NIET OP REGELNIVEAU';
COMMENT ON COLUMN tetools.admin_tnsnames_proto_entries.LAST_INTAKE_VALIDATION_DATE IS 'DE DATUM WAAROP DE PROTO ENTRY REGEL VOOR HET LAATST GEVALIDEERD IS';
COMMENT ON COLUMN tetools.admin_tnsnames_proto_entries.LAST_REGISTRATION_VALIDATION_DATE IS 'DE DATUM WAAROP DE REGISTRATION ENTRY REGEL VOOR HET LAATST GEVALIDEERD IS';


CREATE SEQUENCE tetools.admin_tnsnames_proto_entries_prototnsid_seq
  START WITH     2047
  MINVALUE       2047
  INCREMENT BY   1
  ORDER;


--CREATE OR REPLACE TYPE tetools.admin_tnsnames_attr_proto_type
--AS object
--( tns_attr_name   VARCHAR2(64),
--  tns_attr_status VARCHAR2(64)
--);
--/
