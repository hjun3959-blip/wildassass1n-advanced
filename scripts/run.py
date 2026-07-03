#!/usr/bin/env python3
import sys, json, pathlib
sys.path.insert(0, str(pathlib.Path(__file__).parent.parent))
from minis_skills.orchestrator import chain
print(json.dumps(chain({"role": "run"})))
