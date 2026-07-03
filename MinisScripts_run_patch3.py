import pathlib, textwrap, json, sys
base = pathlib.Path('MinisSkills')
# clean up temporary patch files
for f in list(base.rglob('*patch*.py')) + [base/'..' / 'MinisScripts_run_patch.py', base/'..' / 'MinisScripts_run_patch2.py']:
    try: f.unlink(); print('removed', f)
    except: pass
# rewrite run.py robust
tmpl = textwrap.dedent('''
    #!/usr/bin/env python3
    import sys, json, pathlib
    sys.path.insert(0, str(pathlib.Path(__file__).parent.parent))
    try:
        mod_name = pathlib.Path(__file__).parent.name
        if mod_name == "scripts":
            role = pathlib.Path(__file__).parent.parent.name
            if role == "assault":
                from MinisSkills.assault import SKILL as mod
            elif role == "ling":
                from MinisSkills.ling import SKILL as mod
            elif role == "chain":
                from MinisSkills.chain import SKILL as mod
            else:
                print(json.dumps({"error": "unknown role"}))
                sys.exit(0)
        else:
            mod = __import__(f"{mod_name}.SKILL", fromlist=["run"])
        print(json.dumps(mod.run({"role": role})))
    except Exception as e:
        print(json.dumps({"error": str(e)}))
    ''').strip() + '\n'
for role in ('assault','ling','chain'):
    p = base / role / 'scripts' / 'run.py'
    p.write_text(tmpl)
    print(f'cleaned {p}')
# evals: add assertion type examples if missing
ep = pathlib.Path('evals/evals.json')
data = json.loads(ep.read_text(encoding='utf-8'))
for ex in data.get('evals', []):
    if 'assertions' not in ex:
        ex['assertions'] = [{"type": "contains", "text": "status"}]
ep.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding='utf-8')
print('evals updated')
print('done')
