#!/usr/bin/env python3
import re, ast, json, pathlib, sys
SKILLS_DIR = pathlib.Path('.')
def check(p):
    try: txt = p.read_text(encoding='utf-8')
    except: return {'file': str(p), 'ok': False, 'error': 'read_error'}
    txt = re.sub(r'^---.*?^---', '', txt, flags=re.S|re.M)
    for m in re.finditer(r'```(?:\s*)python\n([\s\S]*?)\n```', txt):
        b = re.sub(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]+', '', m.group(1))
        b=b.translate(_chm())
        half=[]
        for ch in b:
            o=ord(ch)
            if 0xFF01<=o<=0xFF5E: half.append(chr(o-0xFEE0))
            else: half.append(ch)
        b=''.join(half)+'\n'
        if not b.strip(): continue
        try: ast.parse(b)
        except SyntaxError as e: return {'file':str(p),'ok':False,'notes':[f'{e.msg}:{e.lineno or"?"}']}
    return {'file':str(p),'ok':True,'notes':[]}
files = sorted(SKILLS_DIR.rglob('SKILL.md'))
results=[check(p) for p in files]
ok_cnt=sum(1 for r in results if r.get('ok'))
report={'total':len(results),'ok':ok_cnt,'failed':len(results)-ok_cnt,'details':results}
pathlib.Path('ci_check_report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2))
fails=[r['file'] for r in results if not r.get('ok')]
if fails:
    print(f'FAIL: {ok_cnt}/{len(results)}')
    for f in fails[:10]: print(' -',f)
else:
    print(f'PASS: {ok_cnt}/{len(results)}')
print('report->ci_check_report.json')
sys.exit(0 if not fails else 1)
