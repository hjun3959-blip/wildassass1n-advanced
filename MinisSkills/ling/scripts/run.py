#!/usr/bin/env python3
import sys, json, pathlib
sys.path.insert(0, str(pathlib.Path(__file__).parent.parent))
try:
  mod = __import__(f"{pathlib.Path(__file__).parent.name}.SKILL", fromlist=["run"])
  print(json.dumps(mod.run({})))
except Exception as e:
  print(json.dumps({"error": str(e)}))
