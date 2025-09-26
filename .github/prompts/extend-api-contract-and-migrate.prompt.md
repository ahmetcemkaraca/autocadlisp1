---
mode: agent
description: Evolve the API contract (e.g., v2), plan migrations, ensure backward compatibility or deprecation.
---
Input
- ${input:Contract changes and compatibility goals}

Context
- ../instructions/universal-agent.instructions.md
- ../instructions/developer.instructions.md
- docs/registry/endpoints.json
- docs/registry/schemas.json
- .mds/context/current-context.md

Tasks
1) Propose versioning strategy (URL/header/content negotiation) and deprecation timeline (base URL: https://api.archbuilder.app/v1)
2) Implement new/changed endpoints and schemas; add migrations where needed
3) Update registry JSONs and write contract tests
4) Provide rollback and coexistence steps
5) Refresh context and append session history; update `version.md` per 2-prompt cadence

Output
- Changed files, PowerShell commands, and test results

