"""Meaningful regression checks for immutable ledger history."""
import copy
import unittest
from validate_acceptance import append_only


class AppendOnlyTests(unittest.TestCase):
    def setUp(self):
        self.old = {'records': [{'change_id': 'A', 'note': 'original'}, {'change_id': 'B'}]}

    def test_append_successor_preserves_original(self):
        new = copy.deepcopy(self.old)
        new['records'].append({'change_id': 'C', 'supersedes': 'A'})
        append_only(self.old, new)

    def test_mutation_removal_and_reorder_fail(self):
        for mode in ('mutation', 'removal', 'reorder'):
            new = copy.deepcopy(self.old)
            if mode == 'mutation':
                new['records'][0]['note'] = 'rewritten'
            elif mode == 'removal':
                new['records'].pop()
            else:
                new['records'].reverse()
            with self.subTest(mode=mode), self.assertRaises(ValueError):
                append_only(self.old, new)

    def test_object_key_order_is_immaterial(self):
        append_only(self.old, {'records': [{'note': 'original', 'change_id': 'A'}, {'change_id': 'B'}]})
