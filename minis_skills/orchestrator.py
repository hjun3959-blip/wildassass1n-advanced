import importlib, json, pathlib, sys
def chain(payload):
    results = []
    for role in ["assault","ling","chain"]:
        try:
            mod = importlib.import_module(f"minis_skills.{role}.skill")
            r = mod.run(payload, role)
            results.append(r)
        except Exception as e:
            results.append({"role": role, "error": str(e)})
    return {"chain": "done", "steps": results}
if __name__ == "__main__":
    print(json.dumps(chain({})))
