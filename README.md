# WildAssass1n Advanced

## Overview
This repository contains modular skill definitions (`MinisSkills/`) for controlled security research and testing.

## Structure
```
MinisSkills/
├── assault/          # Restricted-access/process skills
│   ├── SKILL.md
│   └── scripts/run.py
├── ling/             # Ling-model-specific skills
│   ├── SKILL.md
│   └── scripts/run.py
├── chain/            # Multi-step orchestrator
│   ├── SKILL.md
│   └── scripts/run.py
├── evals/            # Test cases (evals.json)
├── references/       # Optional reference docs
└── assets/           # Templates / icons
```

## Usage
```bash
# Run a skill
python3 MinisSkills/assault/scripts/run.py
python3 MinisSkills/ling/scripts/run.py
python3 MinisSkills/chain/scripts/run.py
```

## Notes
- Skills use neutral, research-oriented terminology.
- All code depends only on Python standard library.
- Evals follow the `evals/evals.json` schema.
