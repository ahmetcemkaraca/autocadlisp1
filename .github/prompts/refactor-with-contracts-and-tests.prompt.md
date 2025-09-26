---
mode: agent
description: Refactor code while honoring public contracts; keep registry and tests in sync.
---
Input
- ${input:Refactor goals and constraints}

Context
- ../instructions/developer.instructions.md
- docs/registry/ (identifiers.json, endpoints.json, schemas.json)
- .mds/context/current-context.md

Tasks
1) Identify stable public contracts; mark anything internal as safe-to-change
2) Perform refactor in small steps; keep tests green
3) Update registry entries for changed exports/contracts
4) Add/adjust tests to lock behavior and prevent regressions
5) Refresh context files; update `version.md` per cadence if applicable

Output
- Changed files and tests, commands (PowerShell)

