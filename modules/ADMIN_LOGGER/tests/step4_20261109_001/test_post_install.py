"""Offline source/relational metadata regressions for LGR4-RR-01.

SQLite in memory evaluates the extracted SELECT after removing PL/SQL INTO.
This tests the supplied metadata model only, not Oracle syntax/runtime, real
ALL_OBJECTS contents, SQLPlus/SQLcl behavior or G09 authorization.
"""
import pathlib,re,sqlite3,unittest
from verify_static import post_install_parent_query

P=pathlib.Path(__file__).resolve().parent
# Independent fixture contract: do not derive expected rows from the query.
PARENTS=[('ADMIN_LOGGER_SESSIONS','TABLE'),('ADMIN_LOGGER_CONFIG','TABLE'),
         ('ADMIN_LOGGER_LOG','TABLE'),('ADMIN_LOGGER_INCIDENT','TABLE'),
         ('ADMIN_LOGGER_GUARD','TABLE'),('ADMIN_LOGGER_LOGBATCH_SEQ','SEQUENCE')]

def count(rows,query):
    with sqlite3.connect(':memory:') as db:
        db.execute('CREATE TABLE ALL_OBJECTS (owner TEXT,object_name TEXT,object_type TEXT,subobject_name TEXT,status TEXT)')
        db.executemany('INSERT INTO ALL_OBJECTS VALUES (?,?,?,?,?)',rows)
        return db.execute(query).fetchone()[0]

def parents():return [('TETOOLS',name,kind,None,'VALID') for name,kind in PARENTS]
def partitions(n=3):
    return [('TETOOLS',PARENTS[i%3][0],'TABLE PARTITION','P'+str(i),'VALID') for i in range(n)]

class PostInstallParentTests(unittest.TestCase):
    def setUp(self):
        self.source=(P/'scripts/00_post_install.sql').read_text(encoding='utf-8')
        self.query=post_install_parent_query(self.source)
    def test_exact_six_parents(self):self.assertEqual(count(parents(),self.query),6)
    def test_extra_partitions_do_not_reject_valid_parents(self):
        for n in (3,50):
            with self.subTest(partitions=n):self.assertEqual(count(parents()+partitions(n),self.query),6)
    def test_partitions_cannot_replace_missing_parent(self):
        self.assertEqual(count(parents()[1:]+partitions(),self.query),5)
    def test_same_name_wrong_type_cannot_replace_parent(self):
        for i in range(6):
            rows=parents();owner,name,kind,sub,status=rows[i]
            rows[i]=(owner,name,'SEQUENCE' if kind=='TABLE' else 'TABLE',sub,status)
            with self.subTest(parent=name):self.assertEqual(count(rows+partitions(),self.query),5)
    def test_invalid_or_other_owner_parent_not_accepted(self):
        for position,value in ((0,'OTHER_OWNER'),(4,'INVALID')):
            rows=parents();row=list(rows[0]);row[position]=value;rows[0]=tuple(row)
            with self.subTest(field=position):self.assertEqual(count(rows+partitions(),self.query),5)
    def test_null_subobject_filter_required_even_with_parent_type(self):
        # Defensive metadata counterexample: type filtering alone is insufficient
        # evidence for the required top-level contract.
        rows=parents()+[('TETOOLS',PARENTS[0][0],'TABLE','P_EXTRA','VALID')]
        self.assertEqual(count(rows,self.query),6)
        mutant=re.sub(r'\s+AND subobject_name IS NULL','',self.source,flags=re.I)
        with self.assertRaises(AssertionError):post_install_parent_query(mutant)
    def test_name_only_legacy_predicate_is_rejected(self):
        legacy="SELECT COUNT(*) FROM ALL_OBJECTS WHERE owner='TETOOLS' AND object_name IN ("+','.join("'"+n+"'" for n,_ in PARENTS)+") AND status='VALID';"
        self.assertEqual(count(parents()+partitions(),legacy),9)
        # The old predicate can also falsely accept 5 parents plus 1 partition.
        self.assertEqual(count(parents()[1:]+partitions(1),legacy),6)
        legacy_source=legacy.replace('COUNT(*)','COUNT(*) INTO l_count')+'\nIF l_count <> 6 THEN'
        with self.assertRaises(AssertionError):post_install_parent_query(legacy_source)
    def test_wrong_expected_pair_is_rejected(self):
        mutant=self.source.replace("('ADMIN_LOGGER_GUARD','TABLE')","('ADMIN_LOGGER_GUARD','SEQUENCE')")
        with self.assertRaises(AssertionError):post_install_parent_query(mutant)

if __name__=='__main__':unittest.main(verbosity=2)
