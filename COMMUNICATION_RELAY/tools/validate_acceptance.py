#!/usr/bin/env python3
"""Schema and append-only acceptance gate; no network or mutation.

Install tools/requirements-acceptance.txt separately. The existing stdlib
validator remains independently usable. Baseline must be the reviewed main ledger.
"""
import argparse
import json
from pathlib import Path
import subprocess
import sys


def append_only(before, after):
    """Exact record-prefix equality, ignoring JSON object key order only."""
    old, new = before['records'], after['records']
    if len(new) < len(old) or old != new[:len(old)]:
        raise ValueError('Historical records changed, removed or reordered; append a successor instead')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--baseline-ledger', type=Path, required=True)
    args = parser.parse_args()
    try:
        from jsonschema import Draft202012Validator
    except ImportError:
        parser.error('Install tools/requirements-acceptance.txt before running this additional gate')
    for name in ('SESSION_REGISTRY', 'CHANGE_REGISTER'):
        schema = json.loads((args.root / 'schemas' / (name + '.schema.json')).read_text(encoding='utf-8'))
        Draft202012Validator.check_schema(schema)
        data = json.loads((args.root / (name + '.json')).read_text(encoding='utf-8'))
        Draft202012Validator(schema).validate(data)
    append_only(json.loads(args.baseline_ledger.read_text(encoding='utf-8')),
                json.loads((args.root / 'CHANGE_REGISTER.json').read_text(encoding='utf-8')))
    subprocess.run([sys.executable, str(args.root / 'tools' / 'validate_relay.py')], check=True)
    print('PASS: JSON Schema 2020-12 and append-only baseline comparison')


if __name__ == '__main__':
    main()
