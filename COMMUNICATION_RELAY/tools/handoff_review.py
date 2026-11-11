"""Read-only checks of optional HANDOVER.handoff_assessment; Python 3.8+."""
import argparse
import datetime as dt
import json
from pathlib import Path
import re

CAPACITY = {'ONBEKEND', 'AANDACHT', 'OVERDRACHT_AANBEVOLEN', 'LIMIET_BEREIKT'}
READINESS = {'ONVOLLEDIG', 'VOORBEREID', 'GEPUBLICEERD', 'OVERGENOMEN'}
KINDS = {'PLATFORMMELDING', 'METING', 'GEBRUIKERSMELDING', 'HEURISTIEK', 'ONBEKEND'}
LIMIT_KINDS = {'GESPREK', 'ABONNEMENT', 'CONTEXT', 'ONBEKEND'}


def text(value):
    return isinstance(value, str) and bool(value.strip())


def exact(obj, fields):
    if not isinstance(obj, dict) or set(obj) != set(fields.split()):
        raise ValueError('Expected exactly: ' + fields)


def date(value):
    if not isinstance(value, str) or not re.fullmatch(r'\d{4}-\d{2}-\d{2}', value):
        raise ValueError('Expected assessment date YYYY-MM-DD')
    dt.date.fromisoformat(value)


def validate_assessment(a, session_ids):
    """Validate declared evidence, never certify its truth, authority or live presence."""
    exact(a, 'capacity readiness')
    for name, states in (('capacity', CAPACITY), ('readiness', READINESS)):
        b = a[name]
        fields = 'state meaning rationale assessed_at assessed_by evidence_kind evidence_refs'
        if name == 'capacity' and 'limit_kind' in b:
            fields += ' limit_kind'
        if name == 'readiness':
            fields += ' package_ref publication receipt transfer'
        exact(b, fields)
        if not isinstance(b['state'], str) or b['state'] not in states:
            raise ValueError('Invalid ' + name + ' state')
        if any(not text(b[k]) for k in ('meaning', 'rationale', 'assessed_by')):
            raise ValueError('Missing assessment meaning/rationale/actor')
        date(b['assessed_at'])
        if b['assessed_by'] not in session_ids:
            raise ValueError('Assessment actor is not registered')
        if not isinstance(b['evidence_kind'], str) or b['evidence_kind'] not in KINDS:
            raise ValueError('Invalid evidence kind')
        refs = b['evidence_refs']
        if not isinstance(refs, list) or any(not text(x) for x in refs):
            raise ValueError('Invalid evidence references')
        if b['evidence_kind'] != 'ONBEKEND' and not refs:
            raise ValueError('Evidence kind requires source references')
    c, r = a['capacity'], a['readiness']
    # Preserve immutable legacy unknown assessments; missing kind conveys no warning.
    limit_kind = c.get('limit_kind', 'ONBEKEND')
    if not isinstance(limit_kind, str) or limit_kind not in LIMIT_KINDS:
        raise ValueError('Invalid limit_kind')
    if 'limit_kind' not in c and (c['state'] != 'ONBEKEND' or c['evidence_kind'] != 'ONBEKEND'):
        raise ValueError('Legacy assessment without limit_kind must remain wholly unknown')
    if c['state'] == 'LIMIET_BEREIKT' and limit_kind != 'GESPREK':
        raise ValueError('Reached conversation limit requires limit_kind GESPREK')
    if c['state'] == 'OVERDRACHT_AANBEVOLEN' and limit_kind in {'ABONNEMENT', 'CONTEXT'}:
        raise ValueError('Subscription or context alone cannot recommend conversation succession')
    if c['evidence_kind'] == 'ONBEKEND' and c['state'] != 'ONBEKEND':
        raise ValueError('Unknown evidence cannot establish a capacity warning')
    if c['state'] == 'LIMIET_BEREIKT' and c['evidence_kind'] not in {'PLATFORMMELDING', 'GEBRUIKERSMELDING'}:
        raise ValueError('Reached limit needs a platform or explicit user report')
    # No fields for remaining tokens, percentages, message counts or deadlines.
    # Prose is reviewed by a person: numeric facts in source references remain legitimate.
    if r['state'] != 'ONVOLLEDIG' and not text(r['package_ref']):
        raise ValueError('Prepared handoff requires a durable package reference')
    if r['package_ref'] is not None and not text(r['package_ref']):
        raise ValueError('Invalid package reference')
    p, receipt, transfer = r['publication'], r['receipt'], r['transfer']
    if p is not None:
        exact(p, 'commit pr_head evidence_ref')
        if any(not isinstance(p[k], str) or not re.fullmatch('[0-9a-f]{40}', p[k]) for k in ('commit', 'pr_head')) or not text(p['evidence_ref']):
            raise ValueError('Publication requires exact commit, PR head and readback evidence')
    if r['state'] in {'GEPUBLICEERD', 'OVERGENOMEN'} and p is None:
        raise ValueError('Published state requires verified main readback evidence')
    if receipt is not None:
        exact(receipt, 'session_id received_at evidence_ref independent_source_check')
        date(receipt['received_at'])
        if receipt['session_id'] not in session_ids or not text(receipt['evidence_ref']) or receipt['independent_source_check'] is not True:
            raise ValueError('Receipt requires registered receiver and independent source check')
    if transfer is not None:
        exact(transfer, 'from_session to_session effective_at designation_ref predecessor_available')
        if any(transfer[k] not in session_ids for k in ('from_session', 'to_session')) or transfer['from_session'] == transfer['to_session']:
            raise ValueError('Transfer requires distinct registered identities')
        try:
            stamp = dt.datetime.fromisoformat(transfer['effective_at'].replace('Z', '+00:00'))
            if stamp.tzinfo is None:
                raise ValueError('timezone required')
        except (AttributeError, TypeError, ValueError):
            raise ValueError('Transfer requires timestamp with timezone')
        if not text(transfer['designation_ref']) or type(transfer['predecessor_available']) is not bool:
            raise ValueError('Explicit designation and predecessor availability required')
    if r['state'] == 'OVERGENOMEN':
        if receipt is None or transfer is None or receipt['session_id'] != transfer['to_session']:
            raise ValueError('Takeover requires receiver receipt and explicit designation')
        if receipt['received_at'] > r['assessed_at']:
            raise ValueError('Takeover assessment cannot precede receiver receipt')
        # Compare the calendar day in the explicit effective_at timezone, not host UTC.
        if stamp.date() > dt.date.fromisoformat(r['assessed_at']):
            raise ValueError('A future effective date is not an established takeover')


def validate_registry(ledger, sessions):
    ids = {s['session_id'] for s in sessions['sessions']}
    count = 0
    for record in ledger['records']:
        if 'handoff_assessment' in record:
            if record.get('record_type') != 'HANDOVER':
                raise ValueError('handoff_assessment belongs only to HANDOVER records')
            try:
                validate_assessment(record['handoff_assessment'], ids)
            except (ValueError, TypeError, KeyError) as exc:
                raise ValueError(str(record.get('change_id')) + ': ' + str(exc))
            count += 1
    return count


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args()
    try:
        ledger, sessions = (json.loads((args.root / (name + '.json')).read_text(encoding='utf-8'))
                            for name in ('CHANGE_REGISTER', 'SESSION_REGISTRY'))
        print('PASS: handoff assessments checked:', validate_registry(ledger, sessions))
    except (OSError, ValueError, TypeError, KeyError) as exc:
        parser.exit(1, 'FAIL: ' + str(exc) + '\n')


if __name__ == '__main__':
    main()
