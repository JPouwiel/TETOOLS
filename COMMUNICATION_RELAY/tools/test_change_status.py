"""Approved ASSESSED means a recorded REVIEW, never a decision or execution grant."""
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from jsonschema import Draft202012Validator

ROOT = Path(__file__).resolve().parents[1]


def record(kind, status):
    return dict(change_id='synthetic', record_type=kind, subject='Synthetic status check',
                status=status, source_reference='synthetic:test', origin_session='synthetic',
                recorded_by_session='synthetic', recorded_at='2026-11-10')


class ChangeStatusTests(unittest.TestCase):
    def check_both(self, kind, status, accepted):
        data = dict(schema_version=1, project='PLSQL_TETOOLS', records=[record(kind, status)])
        schema = json.loads((ROOT / 'schemas/CHANGE_REGISTER.schema.json').read_text(encoding='utf-8'))
        self.assertEqual(not list(Draft202012Validator(schema).iter_errors(data)), accepted)
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            (root / 'tools').mkdir()
            for name in ('validate_relay.py', 'session_retention_review.py'):
                (root / 'tools' / name).write_bytes((ROOT / 'tools' / name).read_bytes())
            for name in ('PROJECT.md', 'CURRENT_STATUS.md', 'MODULE_REGISTRY.md',
                         'RELAY_CONTRACT.md', 'SESSION_REGISTRY.json'):
                (root / name).write_bytes((ROOT / name).read_bytes())
            (root / 'CHANGE_REGISTER.json').write_text(json.dumps(data), encoding='utf-8')
            result = subprocess.run([sys.executable, str(root / 'tools/validate_relay.py')], capture_output=True)
            self.assertEqual(result.returncode == 0, accepted, result.stdout)

    def test_assessed_review_is_valid_without_approval_or_implementation(self):
        self.check_both('REVIEW', 'ASSESSED', True)

    def test_assessed_other_types_are_rejected(self):
        for kind in ('DECISION', 'HANDOVER', 'SUITE_IMPACT_SIGNAL', 'OTHER', '', None):
            with self.subTest(kind=kind):
                self.check_both(kind, 'ASSESSED', False)

    def test_unknown_status_remains_invalid_even_for_review(self):
        for kind in ('REVIEW', 'DECISION', 'HANDOVER'):
            with self.subTest(kind=kind):
                self.check_both(kind, 'UNKNOWN_STATUS', False)
