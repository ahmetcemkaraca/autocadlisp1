---
mode: agent
description: Code, test, and deliver the first vertical slice (WPF Desktop + FastAPI + DB) with runnable commands.
---
Input
- ${input:Initial feature and acceptance criteria}

Context
- ../instructions/developer.instructions.md
 - ../instructions/universal-agent.instructions.md
 - docs/registry/ (identifiers.json, endpoints.json, schemas.json)
 - .mds/context/current-context.md

Tasks
1) Scaffold required projects (WPF desktop, FastAPI service)
2) Implement the feature end-to-end (UI form, validation, API, data persistence)
3) Add unit/integration/e2e tests (at least 1–2)
4) Provide run and test commands (Windows PowerShell compatible)
5) Update `.env.example` and README
 6) Update registry files (identifiers/endpoints/schemas) and refresh `.mds/context/current-context.md`; append a session entry under `.mds/context/history/`

Output
- Changed files, commands, and expected outputs

Coaching and Alternatives
- If the requested solution is unsafe or painful to maintain, offer 2–3 safer alternatives (e.g., staged rollout, mocks behind interfaces); briefly justify and mark the recommended path.
- “Teach” mode: add 1–2 sentence callouts at critical steps (why this library, why this validation schema, etc.).
