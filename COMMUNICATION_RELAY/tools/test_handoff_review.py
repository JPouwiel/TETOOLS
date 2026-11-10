"""Synthetic planned/emergency succession; no actual chat or lifecycle changes."""
import copy
import json
from pathlib import Path
import subprocess
import sys
import unittest
from handoff_review import validate_assessment, validate_registry

ROOT = Path(__file__).resolve().parents[1]


def assessment():
    common = dict(meaning='Explicitly unknown', rationale='No platform telemetry available',
                  assessed_at='2026-11-10', assessed_by='old', evidence_kind='ONBEKEND', evidence_refs=[])
    return dict(capacity=dict(common, state='ONBEKEND'), readiness=dict(common,
        state='ONVOLLEDIG', package_ref=None, publication=None, receipt=None, transfer=None))


def published(a):
    r = a['readiness']
    r.update(state='GEPUBLICEERD', package_ref='SESSIONS/REGIE/synthetic.md',
             publication=dict(commit='a'*40, pr_head='b'*40, evidence_ref='synthetic:readback'))


def takeover(a, available):
    published(a)
    a['readiness'].update(state='OVERGENOMEN',
        receipt=dict(session_id='new', received_at='2026-11-10', evidence_ref='synthetic:receiver', independent_source_check=True),
        transfer=dict(from_session='old', to_session='new', effective_at='2026-11-10T12:00:00+01:00',
                      designation_ref='synthetic:owner-designation', predecessor_available=available))


class HandoffTests(unittest.TestCase):
    def check(self, a):
        validate_assessment(a, {'old', 'new'})

    def test_unknown_capacity_is_valid(self):
        self.check(assessment())

    def test_prognosis_fields_are_rejected(self):
        for field in ('remaining_tokens', 'percentage', 'remaining_messages', 'end_date'):
            a = assessment()
            a['capacity'][field] = 42
            with self.subTest(field=field), self.assertRaises(ValueError):
                self.check(a)

    def test_no_limit_inferred_from_heuristic_or_measurement(self):
        for kind in ('HEURISTIEK', 'METING', 'ONBEKEND'):
            a = assessment()
            a['capacity'].update(state='LIMIET_BEREIKT', evidence_kind=kind, evidence_refs=['synthetic:source'])
            with self.subTest(kind=kind), self.assertRaises(ValueError):
                self.check(a)

    def test_user_report_keeps_source_classification(self):
        a = assessment()
        a['capacity'].update(state='LIMIET_BEREIKT', evidence_kind='GEBRUIKERSMELDING', evidence_refs=['synthetic:user-report'])
        self.check(a)

    def test_preparation_does_not_require_capacity_warning(self):
        a = assessment()
        a['readiness'].update(state='VOORBEREID', package_ref='synthetic:package')
        self.check(a)

    def test_published_without_main_proof_fails(self):
        a = assessment()
        published(a)
        a['readiness']['publication'] = None
        with self.assertRaises(ValueError):
            self.check(a)

    def test_missing_receipt_fails(self):
        a = assessment()
        takeover(a, True)
        a['readiness']['receipt'] = None
        with self.assertRaises(ValueError):
            self.check(a)

    def test_emergency_requires_designation_and_independent_receipt(self):
        a = assessment()
        takeover(a, False)
        for field in ('designation_ref',):
            bad = copy.deepcopy(a)
            bad['readiness']['transfer'][field] = ''
            with self.assertRaises(ValueError):
                self.check(bad)
        a['readiness']['receipt']['independent_source_check'] = False
        with self.assertRaises(ValueError):
            self.check(a)

    def test_planned_and_emergency_walkthrough_preserve_input(self):
        for available in (True, False):
            a = assessment()
            self.check(a)
            a['readiness'].update(state='VOORBEREID', package_ref='synthetic:package')
            self.check(a)
            published(a)
            self.check(a)
            takeover(a, available)
            before = copy.deepcopy(a)
            self.check(a)
            self.assertEqual(a, before)

    def test_old_entries_untouched(self):
        ledger = {'records': [{'record_type': 'HANDOVER', 'change_id': 'legacy'}]}
        before = copy.deepcopy(ledger)
        self.assertEqual(validate_registry(ledger, {'sessions': []}), 0)
        self.assertEqual(ledger, before)

    def test_unregistered_actor_bad_date_and_extra_fields_fail(self):
        for key, value in [('assessed_by', 'invented'), ('assessed_at', '2026-02-30'), ('extra', True)]:
            a = assessment()
            a['capacity'][key] = value
            with self.subTest(key=key), self.assertRaises(ValueError):
                self.check(a)

    def test_receiver_cannot_be_predecessor(self):
        a = assessment()
        takeover(a, True)
        a['readiness']['transfer']['to_session'] = 'old'
        with self.assertRaises(ValueError):
            self.check(a)

    def test_publication_receipt_and_timezone_are_not_optional_at_takeover(self):
        for target, key, value in [('publication', 'pr_head', 'short'),
                                   ('publication', 'evidence_ref', ''),
                                   ('receipt', 'session_id', 'unregistered'),
                                   ('receipt', 'evidence_ref', ''),
                                   ('transfer', 'effective_at', '2026-11-10T12:00:00'),
                                   ('transfer', 'predecessor_available', 'unknown')]:
            a = assessment()
            takeover(a, False)
            a['readiness'][target][key] = value
            with self.subTest(target=target, key=key), self.assertRaises(ValueError):
                self.check(a)

    def test_receipt_after_assessment_is_not_valid_evidence(self):
        a = assessment()
        takeover(a, True)
        a['readiness']['receipt']['received_at'] = '2026-11-11'
        with self.assertRaises(ValueError):
            self.check(a)

    def test_warning_requires_attributable_source(self):
        a = assessment()
        a['capacity'].update(state='AANDACHT', evidence_kind='HEURISTIEK')
        with self.assertRaises(ValueError):
            self.check(a)
        a['capacity']['evidence_refs'] = ['synthetic:observed-loss-of-context']
        self.check(a)

    def test_real_registry_cli_is_read_only(self):
        paths = [ROOT / (x + '.json') for x in ('SESSION_REGISTRY', 'CHANGE_REGISTER')]
        before = [x.read_bytes() for x in paths]
        result = subprocess.run([sys.executable, str(ROOT / 'tools/handoff_review.py')], capture_output=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(before, [x.read_bytes() for x in paths])

    def test_schema_agrees_with_example_and_rejects_forecast(self):
        from jsonschema import Draft202012Validator
        schema = json.loads((ROOT / 'schemas/CHANGE_REGISTER.schema.json').read_text(encoding='utf-8'))
        validator = Draft202012Validator(schema)
        record = dict(change_id='synthetic', record_type='HANDOVER', subject='test', status='PROPOSED',
                      source_reference='synthetic', origin_session='old', recorded_by_session='old',
                      recorded_at='2026-11-10', handoff_assessment=assessment())
        ledger = dict(schema_version=1, project='PLSQL_TETOOLS', records=[record])
        validator.validate(ledger)
        record['handoff_assessment']['capacity']['remaining_tokens'] = 100
        self.assertTrue(list(validator.iter_errors(ledger)))
