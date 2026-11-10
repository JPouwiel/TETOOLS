"""Nine offline methods: 2 positive suites, 6 mutation rejections, 1 prefix analysis.

No Oracle execution or client-input experiments. Seven example values in the
prefix analysis re-inspect the same source; they are not seven runtime probes.
"""
import pathlib,unittest
from verify_static import check_entry,check_shared_gate
P=pathlib.Path(__file__).resolve().parent
class SourceGateTests(unittest.TestCase):
    def test_shared_denial(self):check_shared_gate((P/'scripts/00_safety_gate.sql').read_text())
    def test_every_entry(self):
        for f in (P/'scripts').glob('*.sql'):
            if f.name!='00_safety_gate.sql':
                with self.subTest(script=f.name):check_entry(f.read_text())
    def test_missing_gate_rejected(self):
        s=(P/'scripts/51_C01_caller_rollback.sql').read_text().replace('@@00_safety_gate.sql','')
        with self.assertRaises(AssertionError):check_entry(s)
    def test_dml_before_gate_rejected(self):
        s=(P/'scripts/30_T03_functional.sql').read_text().replace('@@00_safety_gate.sql','INSERT INTO arbitrary_table VALUES(1);\n@@00_safety_gate.sql')
        with self.assertRaises(AssertionError):check_entry(s)
    def test_unapproved_enable_rejected(self):
        s=(P/'scripts/00_safety_gate.sql').read_text().replace(":= 'NOT_GRANTED'",":= 'GRANTED'")
        with self.assertRaises(AssertionError):check_shared_gate(s)
    def test_prompt_before_denial_rejected(self):
        s=(P/'scripts/00_safety_gate.sql').read_text().replace("c_g09_status CONSTANT","x VARCHAR2(30):='&&EXECUTION_APPROVED';\n c_g09_status CONSTANT")
        with self.assertRaises(AssertionError):check_shared_gate(s)
    def test_null_unsafe_denial_rejected(self):
        s=(P/'scripts/00_safety_gate.sql').read_text().replace("c_g09_status IS NULL OR ",'')
        with self.assertRaises(AssertionError):check_shared_gate(s)
    def test_missing_os_policy_rejected(self):
        s=(P/'scripts/61_T06_guard_client_A.sql').read_text().replace('WHENEVER OSERROR EXIT FAILURE ROLLBACK','')
        with self.assertRaises(AssertionError):check_entry(s)
    def test_stale_approval_not_read_before_denial(self):
        first=(P/'scripts/00_safety_gate.sql').read_text().split('\n/\n',1)[0]
        for value in [None,'','NULL','NO','YES','UNVERIFIED','stale_previous_connection']:
            with self.subTest(request=value):
                # No supplied request has an input edge into the source-pinned first block.
                check_shared_gate(first+'\n/\n')
                self.assertNotIn('&&',first)
if __name__=='__main__':unittest.main(verbosity=2)
