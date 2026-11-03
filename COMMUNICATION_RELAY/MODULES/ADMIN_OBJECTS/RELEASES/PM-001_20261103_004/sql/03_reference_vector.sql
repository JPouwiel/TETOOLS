-- EXECUTION ROLE: AO4_POC_<suffix> in the target disposable Oracle 19c test PDB.
-- DBA preparation (user/default tablespace/quota/direct grants) must finish first.
-- Exact full 003 CAN-001 reference vector, executed on Oracle by 03_tests.sql.
declare m clob;b blob;expected_ blob;h raw(32);r raw(32767);begin
 m:=q'~
{
 "profile_code": "TABLE_CORE",
 "profile_version": 2,
 "canonical_version": "CAN-001-DRAFT-1",
 "coverage": "BOUNDED_PROFILE",
 "source": {
  "fixture": true,
  "table_name": "AO3_EXAMPLE",
  "con_id": 3,
  "owner": "ILLUSTRATIVE_ONLY"
 },
 "records": [
  {
   "component": "TABLE",
   "source_identity": "AO3_EXAMPLE",
   "fields": [
    {
     "id": 1,
     "property": "TABLE_KIND",
     "tag": 2,
     "value": "HEAP"
    }
   ]
  },
  {
   "component": "COLUMN",
   "source_identity": "ID",
   "fields": [
    {
     "id": 1,
     "property": "COLUMN_NAME",
     "tag": 2,
     "value": "ID"
    },
    {
     "id": 2,
     "property": "COLUMN_ID",
     "tag": 3,
     "value": "1"
    },
    {
     "id": 3,
     "property": "DATA_TYPE",
     "tag": 2,
     "value": "NUMBER"
    },
    {
     "id": 4,
     "property": "DATA_PRECISION",
     "tag": 3,
     "value": "10"
    },
    {
     "id": 5,
     "property": "DATA_SCALE",
     "tag": 3,
     "value": "0"
    },
    {
     "id": 6,
     "property": "CHAR_LENGTH",
     "tag": 1,
     "value": null
    },
    {
     "id": 7,
     "property": "CHAR_USED",
     "tag": 1,
     "value": null
    },
    {
     "id": 8,
     "property": "DATA_LENGTH",
     "tag": 1,
     "value": null
    },
    {
     "id": 9,
     "property": "NULLABLE",
     "tag": 2,
     "value": "N"
    },
    {
     "id": 10,
     "property": "COLLATION",
     "tag": 0,
     "value": null
    }
   ]
  },
  {
   "component": "COLUMN",
   "source_identity": "AMOUNT",
   "fields": [
    {
     "id": 1,
     "property": "COLUMN_NAME",
     "tag": 2,
     "value": "AMOUNT"
    },
    {
     "id": 2,
     "property": "COLUMN_ID",
     "tag": 3,
     "value": "3"
    },
    {
     "id": 3,
     "property": "DATA_TYPE",
     "tag": 2,
     "value": "NUMBER"
    },
    {
     "id": 4,
     "property": "DATA_PRECISION",
     "tag": 0,
     "value": null
    },
    {
     "id": 5,
     "property": "DATA_SCALE",
     "tag": 0,
     "value": null
    },
    {
     "id": 6,
     "property": "CHAR_LENGTH",
     "tag": 1,
     "value": null
    },
    {
     "id": 7,
     "property": "CHAR_USED",
     "tag": 1,
     "value": null
    },
    {
     "id": 8,
     "property": "DATA_LENGTH",
     "tag": 1,
     "value": null
    },
    {
     "id": 9,
     "property": "NULLABLE",
     "tag": 2,
     "value": "Y"
    },
    {
     "id": 10,
     "property": "COLLATION",
     "tag": 0,
     "value": null
    }
   ]
  },
  {
   "component": "COLUMN",
   "source_identity": "MESSAGE",
   "fields": [
    {
     "id": 1,
     "property": "COLUMN_NAME",
     "tag": 2,
     "value": "MESSAGE"
    },
    {
     "id": 2,
     "property": "COLUMN_ID",
     "tag": 3,
     "value": "2"
    },
    {
     "id": 3,
     "property": "DATA_TYPE",
     "tag": 2,
     "value": "VARCHAR2"
    },
    {
     "id": 4,
     "property": "DATA_PRECISION",
     "tag": 1,
     "value": null
    },
    {
     "id": 5,
     "property": "DATA_SCALE",
     "tag": 1,
     "value": null
    },
    {
     "id": 6,
     "property": "CHAR_LENGTH",
     "tag": 3,
     "value": "40"
    },
    {
     "id": 7,
     "property": "CHAR_USED",
     "tag": 2,
     "value": "C"
    },
    {
     "id": 8,
     "property": "DATA_LENGTH",
     "tag": 1,
     "value": null
    },
    {
     "id": 9,
     "property": "NULLABLE",
     "tag": 2,
     "value": "Y"
    },
    {
     "id": 10,
     "property": "COLLATION",
     "tag": 2,
     "value": "USING_NLS_COMP"
    }
   ]
  },
  {
   "component": "CONSTRAINTS",
   "source_identity": "AO3_EXAMPLE_PK",
   "fields": [
    {
     "id": 1,
     "property": "CONSTRAINT_NAME",
     "tag": 2,
     "value": "AO3_EXAMPLE_PK"
    },
    {
     "id": 2,
     "property": "CONSTRAINT_TYPE",
     "tag": 2,
     "value": "P"
    },
    {
     "id": 3,
     "property": "STATUS",
     "tag": 2,
     "value": "ENABLED"
    },
    {
     "id": 4,
     "property": "DEFERRABLE",
     "tag": 2,
     "value": "NOT DEFERRABLE"
    },
    {
     "id": 5,
     "property": "DEFERRED",
     "tag": 2,
     "value": "IMMEDIATE"
    },
    {
     "id": 6,
     "property": "VALIDATED",
     "tag": 2,
     "value": "VALIDATED"
    },
    {
     "id": 7,
     "property": "RELY",
     "tag": 1,
     "value": null
    },
    {
     "id": 8,
     "property": "ORDERED_COLUMNS_HEX",
     "tag": 2,
     "value": "02000000024944"
    },
    {
     "id": 9,
     "property": "CHECK_TEXT",
     "tag": 1,
     "value": null
    }
   ]
  },
  {
   "component": "CONSTRAINTS",
   "source_identity": "SYS_C_EXAMPLE",
   "fields": [
    {
     "id": 1,
     "property": "CONSTRAINT_NAME",
     "tag": 1,
     "value": null
    },
    {
     "id": 2,
     "property": "CONSTRAINT_TYPE",
     "tag": 2,
     "value": "C"
    },
    {
     "id": 3,
     "property": "STATUS",
     "tag": 2,
     "value": "ENABLED"
    },
    {
     "id": 4,
     "property": "DEFERRABLE",
     "tag": 2,
     "value": "NOT DEFERRABLE"
    },
    {
     "id": 5,
     "property": "DEFERRED",
     "tag": 2,
     "value": "IMMEDIATE"
    },
    {
     "id": 6,
     "property": "VALIDATED",
     "tag": 2,
     "value": "VALIDATED"
    },
    {
     "id": 7,
     "property": "RELY",
     "tag": 1,
     "value": null
    },
    {
     "id": 8,
     "property": "ORDERED_COLUMNS_HEX",
     "tag": 2,
     "value": "02000000024944"
    },
    {
     "id": 9,
     "property": "CHECK_TEXT",
     "tag": 2,
     "value": "\"ID\" IS NOT NULL"
    }
   ]
  },
  {
   "component": "CONSTRAINTS",
   "source_identity": "AO3_EXAMPLE_CK",
   "fields": [
    {
     "id": 1,
     "property": "CONSTRAINT_NAME",
     "tag": 2,
     "value": "AO3_EXAMPLE_CK"
    },
    {
     "id": 2,
     "property": "CONSTRAINT_TYPE",
     "tag": 2,
     "value": "C"
    },
    {
     "id": 3,
     "property": "STATUS",
     "tag": 2,
     "value": "ENABLED"
    },
    {
     "id": 4,
     "property": "DEFERRABLE",
     "tag": 2,
     "value": "NOT DEFERRABLE"
    },
    {
     "id": 5,
     "property": "DEFERRED",
     "tag": 2,
     "value": "IMMEDIATE"
    },
    {
     "id": 6,
     "property": "VALIDATED",
     "tag": 2,
     "value": "VALIDATED"
    },
    {
     "id": 7,
     "property": "RELY",
     "tag": 1,
     "value": null
    },
    {
     "id": 8,
     "property": "ORDERED_COLUMNS_HEX",
     "tag": 2,
     "value": "0200000006414D4F554E54"
    },
    {
     "id": 9,
     "property": "CHECK_TEXT",
     "tag": 2,
     "value": "amount>=0"
    }
   ]
  },
  {
   "component": "INDEX",
   "source_identity": "AO3_EXAMPLE_PK",
   "fields": [
    {
     "id": 1,
     "property": "INDEX_NAME",
     "tag": 2,
     "value": "AO3_EXAMPLE_PK"
    },
    {
     "id": 2,
     "property": "INDEX_TYPE",
     "tag": 2,
     "value": "NORMAL"
    },
    {
     "id": 3,
     "property": "UNIQUENESS",
     "tag": 2,
     "value": "UNIQUE"
    },
    {
     "id": 4,
     "property": "STATUS",
     "tag": 2,
     "value": "VALID"
    },
    {
     "id": 5,
     "property": "VISIBILITY",
     "tag": 2,
     "value": "VISIBLE"
    },
    {
     "id": 6,
     "property": "COMPRESSION",
     "tag": 2,
     "value": "DISABLED"
    },
    {
     "id": 7,
     "property": "PREFIX_LENGTH",
     "tag": 1,
     "value": null
    },
    {
     "id": 8,
     "property": "ORDERED_COLUMNS_DIRECTIONS_HEX",
     "tag": 2,
     "value": "020000000249440200000003415343"
    }
   ]
  },
  {
   "component": "INDEX",
   "source_identity": "AO3_EXAMPLE_IX",
   "fields": [
    {
     "id": 1,
     "property": "INDEX_NAME",
     "tag": 2,
     "value": "AO3_EXAMPLE_IX"
    },
    {
     "id": 2,
     "property": "INDEX_TYPE",
     "tag": 2,
     "value": "NORMAL"
    },
    {
     "id": 3,
     "property": "UNIQUENESS",
     "tag": 2,
     "value": "NONUNIQUE"
    },
    {
     "id": 4,
     "property": "STATUS",
     "tag": 2,
     "value": "VALID"
    },
    {
     "id": 5,
     "property": "VISIBILITY",
     "tag": 2,
     "value": "VISIBLE"
    },
    {
     "id": 6,
     "property": "COMPRESSION",
     "tag": 2,
     "value": "DISABLED"
    },
    {
     "id": 7,
     "property": "PREFIX_LENGTH",
     "tag": 1,
     "value": null
    },
    {
     "id": 8,
     "property": "ORDERED_COLUMNS_DIRECTIONS_HEX",
     "tag": 2,
     "value": "02000000074D4553534147450200000003415343"
    }
   ]
  }
 ],
 "sha256": "1A1E83B0450BC00A53E476D7D15FA8379EA0B07AEA999440931F7FA15BD34AF1"
}
~';
 ao4_poc.serialize_manifest(m,b,h);dbms_lob.createtemporary(expected_,true);
 r:=hextoraw('414F330000000001020000000A5441424C455F434F5245030000000132020000000F43414E2D3030312D44524146542D31020000000653484132353600000009100000000D0000000102000000044845415011000000670000000102000000024944000000020300000001310000000302000000064E554D4245520000000403000000023130000000050300000001300000000601000000000000000701000000000000000801000000000000000902000000014E0000000A00000000001100000068000000010200000006414D4F554E54000000020300000001330000000302000000064E554D424552000000040000000000000000050000000000000000060100000000000000070100000000000000080100000000000000090200000001590000000A0000000000110000007C0000000102000000074D455353414745000000020300000001320000000302000000085641524348415232000000040100000000000000050100000000000000060300000002343000000007020000000143000000080100000000000000090200000001590000000A020000000E5553494E475F4E4C535F434F4D50120000009500000001020000000E414F335F4558414D504C455F504B00000002020000000150000000030200000007454E41424C454400000004020000000E4E4F542044454645525241424C45000000050200000009494D4D45444941544500000006020000000956414C49444154454400000007010000000000000008020000000E3032303030303030303234393434000000090100000000120000009700000001010000000000000002020000000143000000030200000007454E41424C454400000004020000000E4E4F542044454645525241424C45000000050200000009494D4D45444941544500000006020000000956414C49444154454400000007010000000000000008020000000E303230303030303030323439343400000009020000001022494422204953204E4F54204E554C4C12000000A600000001020000000E414F335F4558414D504C455F434B00000002020000000143000000030200000007454E41424C454400000004020000000E4E4F542044454645525241424C45000000050200000009494D4D45444941544500000006020000000956414C49444154454400000007010000000000000008020000001630323030303030303036343134443446353534453534000000090200000009616D6F756E743E3D30130000009400000001020000000E414F335F4558414D504C455F504B0000000202000000064E4F524D414C000000030200000006554E4951554500000004020000000556414C494400000005020000000756495349424C4500000006020000000844495341424C454400000007010000000000000008020000001E30323030303030303032343934343032303030303030303334313533343313000000A100000001020000000E414F335F4558414D504C455F49580000000202000000064E4F524D414C0000000302000000094E4F4E554E4951554500000004020000000556414C494400000005020000000756495349424C4500000006020000000844495341424C454400000007010000000000000008020000002830323030303030303037344434353533353334313437343530323030303030303033343135333433');
 dbms_lob.writeappend(expected_,utl_raw.length(r),r);
 if dbms_lob.compare(b,expected_)<>0 or rawtohex(h)<>'1A1E83B0450BC00A53E476D7D15FA8379EA0B07AEA999440931F7FA15BD34AF1' then
   raise_application_error(-20450,'Full CAN-001 reference differs');end if;
 dbms_lob.freetemporary(m);dbms_lob.freetemporary(b);dbms_lob.freetemporary(expected_);
 dbms_output.put_line('PASS T63_FULL_FIXED_VECTOR');
exception when others then
 if dbms_lob.istemporary(m)=1 then dbms_lob.freetemporary(m);end if;
 if dbms_lob.istemporary(b)=1 then dbms_lob.freetemporary(b);end if;
 if dbms_lob.istemporary(expected_)=1 then dbms_lob.freetemporary(expected_);end if;raise;
end;
/
