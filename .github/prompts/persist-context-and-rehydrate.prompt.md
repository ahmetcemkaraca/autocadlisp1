---
mode: agent
description: Summarize the current work, persist context, and rehydrate for a fresh session.
---
Input
- ${input:Short description of what was done}

Context
- docs/registry/ (identifiers.json, endpoints.json, schemas.json)
- .mds/context/current-context.md
- .mds/context/history/

Tasks
1) Write a concise session summary under `.mds/context/history/NNNN.md`
2) Refresh `.mds/context/current-context.md` with snapshots from registry
3) Provide short guidance for the next session on how to rehydrate and proceed
4) If this is prompt 2 of the cadence, append `version.md` with a dated summary

Output
- Updated context files and next-step checklist

