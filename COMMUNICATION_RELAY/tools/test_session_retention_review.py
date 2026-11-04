"""Regression tests: run python3 -m unittest discover -s COMMUNICATION_RELAY/tools -p 'test_session_retention_review.py'."""
import datetime as dt
import unittest
from session_retention_review import assess, render

def entry(**kw):
    s = dict(session_id="s1", role="REGIE", module=None, status="COMPLETED",
             retention_status="REVIEW", last_confirmed_at="2026-11-01",
             source_reference="some.md", deliverables=["artifact"], open_dependencies=[])
    s.update(kw)
    return s

class ReviewTests(unittest.TestCase):
    def test_conservative_even_without_open_dependencies(self):
        rows = assess(dict(project="PLSQL_TETOOLS", sessions=[entry()]), dt.date(2026, 11, 4))
        self.assertEqual(rows[0]["recommendation"], "REVIEW")
        self.assertIn("Independent preservation/dependency verification required", rows[0]["reasons"])

    def test_keep_never_overridden(self):
        rows = assess(dict(project="PLSQL_TETOOLS", sessions=[entry(retention_status="KEEP")]), dt.date(2026, 11, 4))
        self.assertEqual(rows[0]["recommendation"], "KEEP")

    def test_old_confirmation_not_deletion(self):
        rows = assess(dict(project="PLSQL_TETOOLS", sessions=[entry(last_confirmed_at="2020-01-01")]), dt.date(2026, 11, 4))
        self.assertEqual(rows[0]["recommendation"], "REVIEW")
        self.assertTrue(any("30 days" in x for x in rows[0]["reasons"]))

    def test_duplicate_id_fails(self):
        with self.assertRaises(ValueError):
            assess(dict(project="PLSQL_TETOOLS", sessions=[entry(), entry()]), dt.date(2026, 11, 4))

    def test_report_has_safety_steps(self):
        rows = assess(dict(project="PLSQL_TETOOLS", sessions=[entry()]), dt.date(2026, 11, 4))
        self.assertIn("explicit owner authorization", render(rows, dt.date(2026, 11, 4)))

if __name__ == "__main__":
    unittest.main()
