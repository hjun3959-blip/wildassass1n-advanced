---
name: chain-executor
description: >
  Chain multi-step restricted-access flows across engines with event triggers.
compatibility: Python 3.10+
---
# Chain Executor

## Overview
Coordinate steps: assault -> ling -> finalize

## runnable
# test
# label: chain
# input: payload
# output: aggregated result
import json, time
def chain(payload):
    results = []
    for engine in ["gpt4o", "claude3", "ling-1"]:
        results.append({"engine": engine, "status": "ok", "at": time.time()})
    return {"chain": "done", "steps": results}

if __name__ == "__main__":
    print(json.dumps(chain({})))
