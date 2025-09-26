---
mode: agent
description: Plan → implement → test → ship a vertical slice for ArchBuilder.AI (WPF Desktop + FastAPI + Revit alignment). Registry/context first.
---
Input
- ${input:Write your user-facing goal in one paragraph}

Context
- Guide: ../instructions/universal-agent.instructions.md
- Roles: ../instructions/architect.instructions.md, ../instructions/developer.instructions.md, ../instructions/qa.instructions.md, ../instructions/security.instructions.md, ../instructions/devops.instructions.md, ../instructions/ux-ui-design.instructions.md
- Registry: docs/registry/ (identifiers.json, endpoints.json, schemas.json)
- Context: .mds/context/current-context.md

Goals
1) Analysis: scope, risks, open questions (short)
2) Tasks: update `.mds/Todo.md` with ordered tasks (vertical slice)
3) Implementation: first slice (Desktop UI + API + DB) + tests
4) Run: local run/test commands (PowerShell)
5) Ship: minimal deployment notes (Docker + FastAPI; desktop packaging TBD)
6) Quality gates: lint+tests green; fast fixes on failures
7) Next steps: short list of follow-ups
 8) Keep registry and context in sync at each step

Rules
- Ask questions only if truly blocking; otherwise make reasonable, reversible assumptions.
- Proceed in order: Plan → Validate → Code → Test → Ship.
- No secrets in code; document with `.env.example` and use env vars.
- Update registry JSONs and context files whenever contracts/identifiers change; refuse to proceed if registry is stale.

Output Format
- Sections: Analysis → Task updates → Code changes → Commands → Test/Smoke results → Deploy steps → Next TODO
- List changed files; put commands on separate lines.

Edge Cases
- If the repo is empty: scaffold WPF + FastAPI skeletons and add one vertical slice.
- If external services are missing: mock behind an interface and include explicit setup instructions.
