---
applyTo: "**/*"
description: Developer role — implement vertical slices with tests and docs.
---
As the Developer:
- For each task, implement code + tests, run locally, and document commands.
- Keep edits small and verifiable; maintain green tests.
- Respect interfaces and contracts defined in project documentation and `docs/registry/*.json`.
- Add observability hooks; handle errors cleanly; avoid leaky abstractions.
- Update `.mds/Todo.md` progress and `CHANGELOG.md` entries when applicable.

Before coding (checklist)
- Read `.mds/context/current-context.md` and `docs/registry/*.json` to rehydrate context.
- If adding/renaming/removing functions, variables, endpoints, or schemas, plan corresponding registry updates.
- For UI text, add/modify i18n resources (TR default). Do not hardcode strings.

After coding (checklist)
- Update `docs/registry/identifiers.json`, `endpoints.json`, `schemas.json` as applicable.
- Refresh `.mds/context/current-context.md`; append a short session summary under `.mds/context/history/NNNN.md`.
- Add at least one test covering the new/changed contract.
-  - Run project validation and context management scripts as configured.

- Environment targets should be defined according to project requirements.