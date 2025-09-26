---
mode: agent
description: Write an ordered plan with a vertical-slice strategy and update `.mds/Todo.md`.
---
Input
- ${input:User value targeted in the first slice}

Context
- ../instructions/developer.instructions.md
- .mds/Todo.md (create/update)
 - docs/registry/ (identifiers.json, endpoints.json, schemas.json)
 - .mds/context/current-context.md

Tasks
1) Bootstrap, architecture docs, CI/Lint/Test setup (align with Python 3.12 + WPF)
2) Vertical slice 1 (Desktop UI + FastAPI + DB) tasks and tests
3) Observability and error boundaries
4) Packaging/deployment and rollback steps
5) DOD and readiness checklist
6) Create/update `.mds/Todo.md`
 7) Add registry update checkpoints and context rehydration steps to the plan (2-prompt cadence for `version.md`)

Output
- Task list and estimated risks

Coaching and Alternatives
- Protect risky/secret-bearing steps with a feature flag; if needed defer with mock/contract tests.
- Propose 2–3 alternative task orders for faster delivery (e.g., “API contract + mock → UI → real integration”).
