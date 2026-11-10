"""Reproduce task111 baseline/new-tool/preservation gates. Write only requested evidence.

Requires Python3.12 and tools/requirements-acceptance.txt; run from repository root.
Temporary baseline copies are disposable; source registries are read-only.
"""
import argparse
import io
import json
from importlib.metadata import version
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import zipfile
from jsonschema import Draft202012Validator


def git(*args):
    return subprocess.check_output(['git', *args])


def run(root, *args):
    p = subprocess.run([sys.executable, *args], cwd=root, capture_output=True, text=True)
    return dict(exit_code=p.returncode, stdout=p.stdout, stderr=p.stderr)


def load(path):
    return json.loads(path.read_text(encoding='utf-8'))


def inspect(root, baseline):
    relay = root / 'COMMUNICATION_RELAY'
    result = {}
    for name in ('SESSION_REGISTRY', 'CHANGE_REGISTER'):
        schema = load(relay / 'schemas' / (name + '.schema.json'))
        Draft202012Validator.check_schema(schema)
        result[name + '_schema'] = [dict(path=list(e.absolute_path), message=e.message)
            for e in Draft202012Validator(schema).iter_errors(load(relay / (name + '.json')))]
    result['stdlib'] = run(root, 'COMMUNICATION_RELAY/tools/validate_relay.py')
    result['tests'] = run(root, '-m', 'unittest', 'discover', '-s', 'COMMUNICATION_RELAY/tools', '-p', 'test_*.py', '-v')
    result['acceptance'] = run(root, 'COMMUNICATION_RELAY/tools/validate_acceptance.py', '--baseline-ledger', str(baseline))
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline', required=True, help='Independently reviewed main commit')
    parser.add_argument('--prior-proposal', required=True, help='Original proposal head to retain as history')
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    root = Path.cwd()
    relay = root / 'COMMUNICATION_RELAY'
    assert version('jsonschema') == '4.26.0'
    source_bytes = [(relay / (x + '.json')).read_bytes() for x in ('SESSION_REGISTRY', 'CHANGE_REGISTER')]
    with tempfile.TemporaryDirectory(prefix='handoff111-rev002-') as folder:
        old = Path(folder)
        zipfile.ZipFile(io.BytesIO(git('archive', '--format=zip', args.baseline, 'COMMUNICATION_RELAY'))).extractall(old)
        ledger = old / 'COMMUNICATION_RELAY/CHANGE_REGISTER.json'
        old_sessions = load(old / 'COMMUNICATION_RELAY/SESSION_REGISTRY.json')['sessions']
        old_records = load(ledger)['records']
        historical = inspect(old, ledger)
        assert historical['stdlib']['exit_code'] == 1
        assert 'REGIE-LOGGER-READINESS-20261109' in historical['stdlib']['stdout']
        assert len(historical['CHANGE_REGISTER_schema']) == 1
        assert 'FAILED (failures=1)' in historical['tests']['stderr']
        for directory in ('tools', 'schemas'):
            for path in (relay / directory).glob('*'):
                if path.is_file() and path.suffix in ('.py', '.json'):
                    shutil.copyfile(path, old / 'COMMUNICATION_RELAY' / directory / path.name)
        upgraded_baseline = inspect(old, ledger)
        proposal = inspect(root, ledger)
        for result in (upgraded_baseline, proposal):
            assert not result['SESSION_REGISTRY_schema'] and not result['CHANGE_REGISTER_schema']
            for key in ('stdlib', 'tests', 'acceptance'):
                assert result[key]['exit_code'] == 0, (key, result[key])
        handoff = run(root, 'COMMUNICATION_RELAY/tools/handoff_review.py')
        retention = run(root, 'COMMUNICATION_RELAY/tools/session_retention_review.py', '--as-of', '2026-11-10')
        assert handoff['exit_code'] == retention['exit_code'] == 0
        new_s = load(relay / 'SESSION_REGISTRY.json')['sessions']
        new_c = load(relay / 'CHANGE_REGISTER.json')['records']
        prior = json.loads(git('show', args.prior_proposal + ':COMMUNICATION_RELAY/CHANGE_REGISTER.json'))['records']
        assert old_sessions == new_s[:len(old_sessions)]
        assert old_records == new_c[:len(old_records)]
        assert prior == new_c[:len(prior)]
        assert len({s['session_id'] for s in new_s}) == len(new_s)
        assert len({c['change_id'] for c in new_c}) == len(new_c)
        for name in ('REGIE_HANDOFF_20261110.md', 'REGIE_HANDOFF_20261110_EVIDENCE.json'):
            path = 'COMMUNICATION_RELAY/reports/' + name
            assert git('hash-object', '--path=' + path, path).strip() == git('rev-parse', args.prior_proposal + ':' + path).strip()
        paths = set(git('diff', '--name-only', args.baseline).decode().splitlines())
        paths.update(git('ls-files', '--others', '--exclude-standard', 'COMMUNICATION_RELAY').decode().splitlines())
        assert all(p.startswith('COMMUNICATION_RELAY/') and '/RELEASES/' not in p for p in paths), paths
        material = {p: git('hash-object', '--path=' + p, p).decode().strip() for p in sorted(paths)
                    if '/tools/' in p or '/schemas/' in p or p.endswith(('SESSION_REGISTRY.json', 'CHANGE_REGISTER.json'))}
        assert source_bytes == [(relay / (x + '.json')).read_bytes() for x in ('SESSION_REGISTRY', 'CHANGE_REGISTER')]
        evidence = dict(baseline=args.baseline, prior_proposal=args.prior_proposal,
            python=sys.version, jsonschema=version('jsonschema'), historical=historical,
            baseline_with_new_tools=upgraded_baseline, proposal=proposal, handoff=handoff,
            retention=retention, tested_git_blobs=material,
            preservation=dict(main_sessions=len(old_sessions), main_records=len(old_records),
                prior_proposal_records=len(prior), all_exact=True, unique_ids=True,
                original_fail_reports_exact=True, only_relay_changes=True, registries_read_only=True),
            publication='Not asserted here; actual exact-head merge/main-readback proof belongs in PR112/Issue111 afterward')
        output = json.dumps(evidence, ensure_ascii=False, indent=2) + '\n'
        if args.output:
            args.output.write_text(output, encoding='utf-8')
        else:
            print(output)
        print('PASS: historical failure retained; upgraded baseline and proposal all gates PASS; histories/read-only PASS')


if __name__ == '__main__':
    main()
