import pathlib, textwrap, json
base = pathlib.Path('MinisSkills')
for role in ('assault','ling','chain'):
    p = base / role / 'scripts' / 'run.py'
    p.write_text(textwrap.dedent('''
        #!/usr/bin/env python3
        import sys, json, pathlib
        sys.path.insert(0, str(pathlib.Path(__file__).parent.parent))
        try:
            mod_name = pathlib.Path(__file__).parent.name
            if mod_name == "scripts":
                # top-level fallback
                import json, sys
                sys.path.insert(0, str(pathlib.Path(__file__).parent.parent))
                # try dynamic import by role
                role = pathlib.Path(__file__).parent.parent.name
                if role == "assault":
                    from MinisSkills.assault import SKILL as mod
                elif role == "ling":
                    from MinisSkills.ling import SKILL as mod
                elif role == "chain":
                    from MinisSkills.chain import SKILL as mod
                else:
                    import json
                    print(json.dumps({"error": "unknown role"}))
                    sys.exit(0)
            else:
                mod = __import__(f"{mod_name}.SKILL", fromlist=["run"])
            print(json.dumps(mod.run({"role": role})))
        except Exception as e:
            print(json.dumps({"error": str(e)}))
        ''').lstrip() + '\n')
    print(f'patched {p}')
# chain SKILL: ensure output format
t = (base/'chain/SKILL.md').read_text(encoding='utf-8')
if '## Output format' not in t:
    t = t.replace('# Chain Executor\n\n## Overview','# Chain Executor\n\n## Overview\n\n## Output format\nAlways use this exact structure:\n\n# [Title]\n## Summary\n## Steps\n## Result','',1)
(t.base / 'chain'/'SKILL.md').write_text(t, encoding='utf-8') if False else None
print('done')
