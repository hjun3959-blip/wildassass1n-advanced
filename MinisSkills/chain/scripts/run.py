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
            import json
            print(json.dumps({"error": "unknown role"}))
            sys.exit(0)
    else:
        mod = __import__(f"{mod_name}.SKILL", fromlist=["run"])
    print(json.dumps(mod.run({"role": role})))
except Exception as e:
    print(json.dumps({"error": str(e)}))
