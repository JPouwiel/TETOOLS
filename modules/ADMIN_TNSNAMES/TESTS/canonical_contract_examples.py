from pathlib import Path
OUT=Path(__file__).resolve().parent
import hashlib,json
# Illustrative byte-contract tests only: this does not execute Oracle or parse TNS.
def atom(value):
 if value is None:return b'N;'
 b=value.encode('utf-8');return b'S'+str(len(b)).encode('ascii')+b':'+b
def canonical(rows,profile='EXAMPLE_V1'):
 return atom(profile)+b''.join(atom(x) for row in sorted(rows,key=lambda r:(int(r[0]),r[1],int(r[2]),int(r[3]))) for x in row)
base=[('10','COL_A','1','10','STRING','A'),('10','COL_A','1','20','TYPE','NUMBER'),('10','COL_B','2','10','STRING','B')]
cases=[]
def check(name,a,b,equal):
 actual=a==b;assert actual==equal;cases.append(dict(name=name,expected_equal=equal,observed_equal=actual,passed=True,sha256_a=hashlib.sha256(a).hexdigest(),sha256_b=hashlib.sha256(b).hexdigest()))
check('Unordered input records',canonical(base),canonical(base[::-1]),True)
other=[tuple('3' if i==2 and r[1]=='COL_A' else v for i,v in enumerate(r)) for r in base]
check('Relevant element position',canonical(base),canonical(other),False)
check('NULL versus literal NULL',atom(None),atom('NULL'),False)
check('Unambiguous field boundaries',atom('A')+atom('BC'),atom('AB')+atom('C'),False)
check('Profile identity',canonical(base),canonical(base,'EXAMPLE_V2'),False)
check('UTF-8 byte length',atom('é'),b'S2:'+bytes([195,169]),True)
check('Large value',atom('x'*50000),atom('x'*49999+'y'),False)
(OUT/'canonical_examples_results.json').write_text(json.dumps({'scope':'Executed local illustrative Python byte-contract tests; not module code and not Oracle/TNS tests','cases':cases},indent=2),encoding='utf-8')

print("PASS: seven illustrative byte-contract tests; no Oracle or module execution")
