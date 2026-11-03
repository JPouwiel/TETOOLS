


-- ==============================================================================================================
--          ADMIN_OBJECTS_CONFIG
-- ==============================================================================================================
CREATE TABLE tetools.ADMIN_OBJECTS_CONFIG (
  conf_pk                              INTEGER GENERATED ALWAYS AS IDENTITY,
  conf_table                           VARCHAR2(255) NOT NULL         ,
  conf_name	                           VARCHAR2(255) NOT NULL         ,
  conf_value                           VARCHAR2(512) NOT NULL         ,
  CONSTRAINT ADMIN_OBJECTS_config_pk PRIMARY KEY (conf_name) ENABLE
)
TABLESPACE TETOOLS
PCTUSED    40
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          128K
            NEXT             128K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING
/

COMMENT ON TABLE  tetools.ADMIN_OBJECTS_config            IS 'Deze tabel bevat configuratiesleutels voor de admin_objects module.';
COMMENT ON COLUMN tetools.ADMIN_OBJECTS_config.conf_table IS 'Naam tabel waar configuratiesleutel voor geldt. Wildcardsleutel = ALL.';
COMMENT ON COLUMN tetools.ADMIN_OBJECTS_config.conf_name  IS 'Naam configuratiesleutel.';
COMMENT ON COLUMN tetools.ADMIN_OBJECTS_config.conf_value IS 'Waarde van configuratiesleutel.';



-- ==============================================================================================================
--          ADMIN_OBJECTS_LEDGER
-- ==============================================================================================================
CREATE TABLE TETOOLS.ADMIN_OBJECTS_LEDGER (
  LEDGER_ID                            INTEGER GENERATED ALWAYS AS IDENTITY                  ,
  MODULE                               VARCHAR2(128)                            NOT NULL     ,
  OBJECT_OWNER                         VARCHAR2(128)                            NOT NULL     ,
  OBJECT_NAME                          VARCHAR2(128)                            NOT NULL     ,
  OBJECT_TYPE                          VARCHAR2(23)                             NOT NULL     ,
  CREATED                              DATE                                     NOT NULL     ,
  MIN_DB_VERSION                       VARCHAR2(12)      DEFAULT '19.0'         NOT NULL     ,
  MAX_DB_VERSION                       VARCHAR2(12)      DEFAULT '99.9.99'      NOT NULL     ,
  MIN_APP_VERSION                      VARCHAR2(12)      DEFAULT '26.7'         NOT NULL     ,
  MAX_APP_VERSION                      VARCHAR2(12)      DEFAULT '99.9.99'      NOT NULL     ,
  LAST_CATALOGED                       DATE              DEFAULT SYSDATE                     ,
  RUNS_SINCE_LAST_CATALOGED            NUMBER            DEFAULT 0                           ,
  INITIAL_LOAD_BY                      VARCHAR2(128)     DEFAULT USER                        ,
  OBJECT_STATUS                        VARCHAR2(64)      DEFAULT 'PENDING'                   ,
  EVALUATION_STATUS                    VARCHAR2(64)      DEFAULT 'PENDING'                   ,
  EVALUATED_BY                         VARCHAR2(128)     DEFAULT USER                        ,
  FORCE_ACCEPTED                       CHAR(1)           DEFAULT 'N'                         ,
  EVALUATION_DATE                      DATE              DEFAULT SYSDATE                     ,
  REEVALUATED                          CHAR(1)           DEFAULT 'N'                         ,
  REEVALUATED_BY                       VARCHAR2(128)                                         ,
  REEVALUATION_DATE                    DATE                                                  ,
  PRIOR_EVALUATION_STATUS              VARCHAR2(64)                                          ,
  OBJECT_PRESENT                       CHAR(3)                                               ,
  MD5_HASH                             VARCHAR2(33)                                          ,
  OBJECT_SUBJECT                       VARCHAR2(255)                                         ,
  OBJECT_COMMENT                       VARCHAR2(4000)                                        ,
  CONSTRAINT admin_objects_ledger_pk              PRIMARY KEY (LEDGER_ID) ENABLE,
  CONSTRAINT admin_objects_ledger_row_uq1         UNIQUE (MODULE, OBJECT_OWNER, OBJECT_NAME, OBJECT_TYPE, MIN_DB_VERSION, MAX_DB_VERSION, MIN_APP_VERSION, MAX_APP_VERSION, OBJECT_STATUS, EVALUATION_STATUS) ENABLE,
  CONSTRAINT admin_monitor_ledger_objstatus_ck1   CHECK (OBJECT_STATUS IN ('CURRENT', 'ACTIVE', 'DEPRECATED', 'INACTIVE', 'FUTURE RELEASE', 'PENDING', 'ERROR')) ENABLE,
  CONSTRAINT admin_monitor_ledger_evalstatus_ck1  CHECK (EVALUATION_STATUS IN ('CURRENT', 'ACTIVE', 'DEPRECATED', 'INACTIVE', 'FUTURE RELEASE', 'PENDING', 'ERROR')) ENABLE,
  CONSTRAINT admin_monitor_ledger_revalstatus_ck2 CHECK (PRIOR_EVALUATION_STATUS IN ('CURRENT', 'ACTIVE', 'DEPRECATED', 'INACTIVE', 'FUTURE RELEASE', 'PENDING', 'ERROR')) ENABLE,
  CONSTRAINT admin_monitor_ledger_facc_ck1        CHECK (FORCE_ACCEPTED IN ('Y', 'N')) ENABLE,
  CONSTRAINT admin_monitor_ledger_reval_ck1       CHECK (REEVALUATED IN ('Y', 'N')) ENABLE
);


COMMENT ON TABLE  tetools.ADMIN_OBJECTS_LEDGER                           IS 'Deze tabel bevat de objecten in gebruik door de verschillende ADMIN modules.';
COMMENT ON COLUMN tetools.ADMIN_OBJECTS_LEDGER.MODULE                    IS 'Naam module waar de objecten bijhoren.';
COMMENT ON COLUMN tetools.ADMIN_OBJECTS_LEDGER.OBJECT_OWNER              IS 'Eigenaar object.';
COMMENT ON COLUMN tetools.ADMIN_OBJECTS_LEDGER.OBJECT_NAME               IS 'Naam object.';
COMMENT ON COLUMN tetools.ADMIN_OBJECTS_LEDGER.OBJECT_TYPE               IS 'Type object .';
COMMENT ON COLUMN tetools.ADMIN_OBJECTS_LEDGER.CREATED                   IS 'Datum waarop het record van het object gregistreerd is in deze tabel (niet aanmaakdatum van het object).';
COMMENT ON COLUMN tetools.ADMIN_OBJECTS_LEDGER.MIN_DB_VERSION            IS 'Minimum version van de database waarin dit object gebruikt kan worden.';
COMMENT ON COLUMN tetools.ADMIN_OBJECTS_LEDGER.MAX_DB_VERSION            IS 'Maximum version van de database waarin dit object gebruikt kan worden.';
COMMENT ON COLUMN tetools.ADMIN_OBJECTS_LEDGER.MIN_APP_VERSION           IS 'Minimum version van de module waarbij dit object gebruikt kan worden.';
COMMENT ON COLUMN tetools.ADMIN_OBJECTS_LEDGER.MAX_APP_VERSION           IS 'Maximum version van de module waarbij dit object gebruikt kan worden.';
COMMENT ON COLUMN tetools.ADMIN_OBJECTS_LEDGER.LAST_CATALOGED            IS 'Datum waarop dit object voor het laatst geinventariseerd is.';
COMMENT ON COLUMN tetools.ADMIN_OBJECTS_LEDGER.RUNS_SINCE_LAST_CATALOGED IS 'Aantal inventarisaties die gelopen hebben, en dit object genegeerd hebben.';
COMMENT ON COLUMN tetools.ADMIN_OBJECTS_LEDGER.INITIAL_LOAD_BY           IS 'Kolom bevat de oorsprong van de regel wanneer deze voor het eerst geladen wordt.';
COMMENT ON COLUMN tetools.ADMIN_OBJECTS_LEDGER.OBJECT_STATUS             IS 'Status van het object, dit kan CURRENT,ACTIVE,DEPRECATED,INACTIVE, FUTURE RELEASE, PENDING of ERROR zijn.';
COMMENT ON COLUMN tetools.ADMIN_OBJECTS_LEDGER.EVALUATION_STATUS         IS 'Status van de evaluatie, dit kan CURRENT,ACTIVE,DEPRECATED,INACTIVE, FUTURE RELEASE, PENDING of ERROR zijn.';
COMMENT ON COLUMN tetools.ADMIN_OBJECTS_LEDGER.EVALUATED_BY              IS 'Oorsprong van de evaluatie, dit kan een procedure of gebruiker zijn.';
COMMENT ON COLUMN tetools.ADMIN_OBJECTS_LEDGER.FORCE_ACCEPTED            IS 'Is de aanvaarding of verwerping van de registratie geforceerd dmv automatische verwerking';
COMMENT ON COLUMN tetools.ADMIN_OBJECTS_LEDGER.EVALUATION_DATE           IS 'Datum waarop de registratie is geevalueerd.';
COMMENT ON COLUMN tetools.ADMIN_OBJECTS_LEDGER.REEVALUATED               IS 'Is de registratie geherevalueerd, hiervoor wordt enkel de laatste gebeurtenis gebruikt.';
COMMENT ON COLUMN tetools.ADMIN_OBJECTS_LEDGER.REEVALUATED_BY            IS 'Oorsprong van de herevaluatie, dit kan een procedure of gebruiker zijn.';
COMMENT ON COLUMN tetools.ADMIN_OBJECTS_LEDGER.REEVALUATION_DATE         IS 'Datum waarop de registratie is geherevalueerd.';
COMMENT ON COLUMN tetools.ADMIN_OBJECTS_LEDGER.PRIOR_EVALUATION_STATUS   IS 'Vorige evaluatiestatus bij herevaluatie.';
COMMENT ON COLUMN tetools.ADMIN_OBJECTS_LEDGER.OBJECT_PRESENT            IS 'Geeft aan of het object bestaat voor deze registratie';
COMMENT ON COLUMN tetools.ADMIN_OBJECTS_LEDGER.MD5_HASH                  IS 'Geeft in geval van tabellen, views, en triggers de MD5 hash weer van de broncode tbv vergelijken.';
COMMENT ON COLUMN tetools.ADMIN_OBJECTS_LEDGER.OBJECT_SUBJECT            IS 'Onderwerp van dit object, wordt gebruikt voor het bepalen van de frequentie van de inventarisatie job.';
COMMENT ON COLUMN tetools.ADMIN_OBJECTS_LEDGER.OBJECT_COMMENT            IS 'Aanvullende informatie voor dit object, binnen de context van de module.';


CREATE OR REPLACE TRIGGER TETOOLS.ADMIN_OBJECTS_LEDGER_CUD_TRG
BEFORE UPDATE OR INSERT OR DELETE ON TETOOLS.ADMIN_OBJECTS_LEDGER
FOR EACH ROW
DECLARE
  --
  l_context                       VARCHAR2(128)    := $$PLSQL_UNIT    ;
  y                               INTEGER          := 0               ;
  v_batch                         BOOLEAN          := TRUE            ;
  v_cud                           CHAR(1)                                     ;  -- DML CAN BE: 'I'-INSERT, 'U'-UPDATE, 'D'-DELETE
  v_backup                        VARCHAR2(4000)                              ;
  v_curr_app_version              TETOOLS.ADMIN_MONITOR_CONFIG.conf_value%TYPE;
  v_cur_db_version                CDB_REGISTRY.version_full%TYPE              ;
  v_com_db_ver                    VARCHAR2(24)                                ;
  v_com_app_ver                   VARCHAR2(24)                                ;
  v_val_db_ver                    VARCHAR2(24)                                ;
  v_val_app_ver                   VARCHAR2(24)                                ;
  sql_monobj_delete               VARCHAR2(4000)   := 'DELETE FROM TETOOLS.ADMIN_MONITOR_OBJECTS WHERE ledger_id = :1';
  --
BEGIN
  --
  SELECT conf_value INTO v_curr_app_version FROM TETOOLS.ADMIN_MONITOR_CONFIG WHERE conf_name = 'ADMIN_MONITOR_VERSION';
  SELECT MAX(version_full) INTO v_cur_db_version FROM CDB_REGISTRY;
  --
  IF    INSERTING  THEN
    v_cud := 'C';
	--
	tetools.admin_logger.log_debug (l_context, 'TRG_ADMIN_OBJECTS_LEDGER_CUD INSERT LEDGER_ID: '||:NEW.ledger_id);
	--
	y     := 32 ;
  ELSIF UPDATING   THEN
    v_cud := 'U';
	--
    v_com_db_ver  := ADMIN_OBJECTS.VERSION_COMPARE_FUNC( :NEW.min_db_version,  :OLD.min_db_version  );
    v_com_app_ver := ADMIN_OBJECTS.VERSION_COMPARE_FUNC( :NEW.min_app_version, :OLD.min_app_version );
    v_val_db_ver  := ADMIN_OBJECTS.VERSION_VALIDATE_FUNC( v_cur_db_version,   :NEW.min_db_version,  :NEW.max_db_version  );
    v_val_app_ver := ADMIN_OBJECTS.VERSION_VALIDATE_FUNC( v_curr_app_version, :NEW.min_app_version, :NEW.max_app_version );
	--
	IF    v_val_db_ver = 'INACTIVE' OR v_val_app_ver = 'INACTIVE' THEN
	  IF :NEW.status <> 'INACTIVE' THEN
        :NEW.status := 'INACTIVE';
      END IF;
    ELSIF v_val_db_ver = 'FUTURE RELEASE' OR v_val_app_ver = 'FUTURE RELEASE' THEN
      IF :NEW.status <> 'FUTURE RELEASE' THEN
        :NEW.status := 'FUTURE RELEASE';
      END IF;
	ELSIF v_val_db_ver = 'ACTIVE' AND v_val_app_ver = 'ACTIVE' THEN
	  IF :OLD.status <> 'DEPRECATED' AND :NEW.status <> 'DEPRECATED' THEN
	    :NEW.status := 'PENDING';
	  END IF;
    END IF;
	--
	IF  ( UPDATING( 'MIN_DB_VERSION' ) )  THEN
	  y := y + 1;
      --
      tetools.admin_logger.log_debug (l_context, 'TRG_ADMIN_OBJECTS_LEDGER_CUD UPDATE LEDGER_ID: '||:NEW.ledger_id||'; MIN_DB_VERSION:  '||:NEW.min_db_version);
      --
	END IF;
	IF  ( UPDATING( 'MAX_DB_VERSION' ) )  THEN
	  y := y + 2;
	  --
      tetools.admin_logger.log_debug (l_context, 'TRG_ADMIN_OBJECTS_LEDGER_CUD UPDATE LEDGER_ID: '||:NEW.ledger_id||'; MAX_DB_VERSION:  '||:NEW.max_db_version);
	  --
	END IF;
	IF  ( UPDATING( 'MIN_APP_VERSION' ) ) THEN
	  y := y + 4;
	  --
      tetools.admin_logger.log_debug (l_context, 'TRG_ADMIN_OBJECTS_LEDGER_CUD UPDATE LEDGER_ID: '||:NEW.ledger_id||'; MIN_APP_VERSION:  '||:NEW.min_app_version);
	  --
	END IF;
	IF  ( UPDATING( 'MAX_APP_VERSION' ) ) THEN
	  y := y + 8;
	  --
      tetools.admin_logger.log_debug (l_context, 'TRG_ADMIN_OBJECTS_LEDGER_CUD UPDATE LEDGER_ID: '||:NEW.ledger_id||'; MAX_APP_VERSION:  '||:NEW.max_app_version);
	  --
	END IF;
	IF  ( UPDATING( 'STATUS' ) ) THEN
	  y := y + 16;
	  --
	    tetools.admin_logger.log_debug (l_context, 'TRG_ADMIN_OBJECTS_LEDGER_CUD UPDATE LEDGER_ID: '||:NEW.ledger_id||'; STATUS:  '||:NEW.status||'; curr_db_ver: '||v_cur_db_version||'; curr_app_ver: '||v_curr_app_version);
	  --
	END IF;
	--
  ELSIF DELETING   THEN
    v_cud := 'D';
	--
	FOR x IN ( SELECT COUNT(*) cnt FROM dual WHERE EXISTS ( SELECT 1 FROM CDB_TABLES WHERE table_name = 'ADMIN_MONITOR_OBJECTS' ) )
    LOOP
      IF ( x.cnt = 1 )      THEN
        EXECUTE IMMEDIATE sql_monobj_delete USING IN :OLD.ledger_id;
	    --COMMIT;  /* ORA-04092: cannot COMMIT in a trigger */
	    tetools.admin_logger.log_debug (l_context, 'TRG_ADMIN_OBJECTS_LEDGER_CUD DELETE ADMIN_MONITOR_OBJECTS.LEDGER_ID: '||:OLD.ledger_id);
      END IF;
    END LOOP;
	--
	tetools.admin_logger.log_debug (l_context, 'TRG_ADMIN_OBJECTS_LEDGER_CUD DELETE LEDGER_ID: '||:OLD.ledger_id);
	--
	y     := 64;
  END IF;
  --
  tetools.admin_logger.log_debug (l_context, 'TRG_ADMIN_OBJECTS_LEDGER_CUD CUD LEDGER_ID: '||:OLD.ledger_id||'; y: '||TO_CHAR(y));
  y       := 0;
END;
/

















