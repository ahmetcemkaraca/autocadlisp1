---
mode: agent
description: Detect policy conflicts (instructions vs. user rules), propose resolutions, and record the decision.
---
Input
- ${input:Observed conflict(s) and context}

Context
- ../instructions/universal-agent.instructions.md
- All role instructions in ../instructions/
- .mds/context/current-context.md

Tasks
1) Identify conflicting statements and quote exact lines
2) Propose 2–3 resolution options; select a recommended path
3) Write a short decision note into `.mds/context/history/NNNN.md`
4) If approved, update the relevant instruction files without breaking existing rules

Output
- Conflict list, alternatives, recommended path, and updated files list

