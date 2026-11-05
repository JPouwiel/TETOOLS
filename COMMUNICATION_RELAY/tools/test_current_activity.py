"""Activity lifecycle, compatibility and actual-file integration tests."""
import copy
import datetime as dt
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

from session_retention_review import assess, render, validate_activity

ROOT = Path(__file__).resolve().parents[1]
DAY = dt.date(2026, 11, 5)

def entry():
    return dict(session_id='test', status='ACTIVE', retention_status='REVIEW',
                source_reference='https://github.com/JPouwiel/TETOOLS/issues/23',
                recorded_by='test', last_confirmed_at='2026-11-05',
                deliverables=['evidence'], open_dependencies=[],
                current_activity=dict(task_reference='REGIE-ACTIVITY-20261105-001',
                                      summary='Implement | task\nnext step', state='WORKING'))

def registry(s):
    return dict(project='PLSQL_TETOOLS', schema_version=1, sessions=[s])

class ActivityTests(unittest.TestCase):
    def test_old_entries_absent_or_null_remain_valid(self):
        for null in (False, True):
            s = entry()
            if null:
                s['current_activity'] = None
            else:
                del s['current_activity']
            self.assertEqual(assess(registry(s), DAY)[0]['recommendation'], 'REVIEW')

    def test_work_wait_block_resume_clear_and_new_task(self):
        s = entry()
        for state in ('WORKING', 'WAITING', 'BLOCKED', 'WORKING'):
            s['current_activity']['state'] = state
            s['current_activity']['summary'] = 'Await reply' if state == 'WAITING' else 'Task'
            s['open_dependencies'] = ['user reply'] if state == 'WAITING' else []
            self.assertEqual(assess(registry(s), DAY)[0]['recommendation'], 'KEEP')
        s['deliverables'].append('completed task evidence')
        del s['current_activity']
        s['status'] = 'COMPLETED'
        self.assertIsNone(assess(registry(s), DAY)[0]['current_activity'])
        self.assertIn('completed task evidence', s['deliverables'])
        s['status'] = 'ACTIVE'
        s['current_activity'] = entry()['current_activity']
        validate_activity(s)

    def test_terminal_states_require_clear(self):
        for state in ('COMPLETED', 'CLOSED', 'ARCHIVED'):
            s = entry()
            s['status'] = state
            with self.subTest(state=state), self.assertRaises(ValueError):
                validate_activity(s)

    def test_malformed_objects_rejected(self):
        for value in ('text', [], {}, {'summary': 'task'}, 12):
            s = entry()
            s['current_activity'] = value
            with self.subTest(value=value), self.assertRaises(ValueError):
                validate_activity(s)

    def test_invalid_and_extra_fields_rejected(self):
        for key, value in (('summary', ''), ('summary', '  '), ('summary', 1),
                           ('task_reference', None), ('task_reference', ''),
                           ('state', 'DONE'), ('state', None), ('state', {}),
                           ('started_at', '2026-11-05')):
            s = entry()
            s['current_activity'][key] = value
            with self.subTest(key=key, value=value), self.assertRaises(ValueError):
                validate_activity(s)

    def test_confirmation_and_recorder_required(self):
        for key, value in (('last_confirmed_at', None), ('last_confirmed_at', 'invalid'),
                           ('last_confirmed_at', '2026-02-30'), ('recorded_by', '')):
            s = entry()
            s[key] = value
            with self.subTest(key=key), self.assertRaises(ValueError):
                validate_activity(s)

    def test_activity_cannot_be_eligible_for_deletion(self):
        s = entry()
        s['retention_status'] = 'ELIGIBLE_FOR_DELETION'
        with self.assertRaises(ValueError):
            assess(registry(s), DAY)

    def test_stale_activity_is_not_deleted_or_inferred_inactive(self):
        s = entry()
        s['last_confirmed_at'] = '2020-01-01'
        original = copy.deepcopy(s)
        row = assess(registry(s), DAY)[0]
        self.assertEqual(row['recommendation'], 'KEEP')
        self.assertTrue(any('review hint only' in x for x in row['reasons']))
        self.assertEqual(s, original)

    def test_report_shows_activity_and_escapes_table_content(self):
        rows = assess(registry(entry()), DAY)
        text = render(rows, DAY)
        self.assertIn('WORKING: Implement \\| task next step', text)
        self.assertIn('REGIE-ACTIVITY-20261105-001', text)
        self.assertIn('2026-11-05', text)
        self.assertIn('not live chat presence', text)

    def test_actual_registry_cli_is_read_only_and_repeatable(self):
        path = ROOT / 'SESSION_REGISTRY.json'
        before = path.read_bytes()
        cmd = [sys.executable, str(ROOT / 'tools/session_retention_review.py'),
               '--registry', str(path), '--as-of', DAY.isoformat()]
        a = subprocess.run(cmd, check=True, capture_output=True).stdout
        b = subprocess.run(cmd, check=True, capture_output=True).stdout
        self.assertEqual(a, b)
        self.assertEqual(before, path.read_bytes())
        data = json.loads(before)
        rows = assess(data, DAY)
        self.assertEqual(len(rows), len(data['sessions']))
        self.assertTrue(all(r['recommendation'] != 'ELIGIBLE_FOR_DELETION' for r in rows))

    def test_real_validator_rejects_invalid_activity_and_accepts_legacy_ledger(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / 'tools').mkdir()
            for name in ('validate_relay.py', 'session_retention_review.py'):
                (root / 'tools' / name).write_bytes((ROOT / 'tools' / name).read_bytes())
            for name in ('PROJECT.md', 'CURRENT_STATUS.md', 'MODULE_REGISTRY.md', 'RELAY_CONTRACT.md',
                         'CHANGE_REGISTER.json', 'SESSION_REGISTRY.json'):
                (root / name).write_bytes((ROOT / name).read_bytes())
            cmd = [sys.executable, str(root / 'tools/validate_relay.py')]
            good = subprocess.run(cmd, capture_output=True)
            self.assertEqual(good.returncode, 0, good.stdout.decode())
            data = json.loads((root / 'SESSION_REGISTRY.json').read_text(encoding='utf-8'))
            data['sessions'][0]['current_activity'] = entry()['current_activity']
            (root / 'SESSION_REGISTRY.json').write_text(json.dumps(data), encoding='utf-8')
            bad = subprocess.run(cmd, capture_output=True)
            self.assertNotEqual(bad.returncode, 0)
            self.assertIn(b'must clear current_activity', bad.stdout)
            del data['sessions'][0]['current_activity']
            (root / 'SESSION_REGISTRY.json').write_text(json.dumps(data), encoding='utf-8')
            ledger = json.loads((root / 'CHANGE_REGISTER.json').read_text(encoding='utf-8'))
            ledger['records'].append(dict(change_id='BAD-APPROVAL', status='APPROVED',
                source_reference='test', origin_session='test', recorded_by_session='test',
                recorded_at='2026-11-05'))
            (root / 'CHANGE_REGISTER.json').write_text(json.dumps(ledger), encoding='utf-8')
            bad = subprocess.run(cmd, capture_output=True)
            self.assertNotEqual(bad.returncode, 0)
            self.assertIn(b'missing approval provenance', bad.stdout)

if __name__ == '__main__':
    unittest.main()
