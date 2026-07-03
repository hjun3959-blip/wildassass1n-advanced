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
            raise ValueError("unknown role")
    else:
        mod = __import__(f"{mod_name}.SKILL", fromlist=["run"])
    result = mod.run({"role": role})
    if not isinstance(result, dict):
        raise TypeError("run must return dict")
    print(json.dumps(result))
except Exception as e:
    print(json.dumps({"error": str(e)}))

