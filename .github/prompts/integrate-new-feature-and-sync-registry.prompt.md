---
mode: agent
description: Add a new feature end-to-end (WPF Desktop + FastAPI) and sync registry and tests.
---
Input
- ${input:Feature description and constraints}

Context
- ../instructions/universal-agent.instructions.md
- ../instructions/developer.instructions.md
- docs/registry/ (identifiers.json, endpoints.json, schemas.json)
- .mds/context/current-context.md

Tasks
1) Identify affected modules/endpoints/schemas and plan coherent integration points
2) Implement the feature end-to-end respecting existing contracts
3) Update registry JSONs (identifiers/endpoints/schemas)
4) Add/adjust tests for changed contracts and flows
5) Refresh `.mds/context/current-context.md` and append history entry (update `version.md` per cadence)

Output
- Changed files, commands (PowerShell), and test results

