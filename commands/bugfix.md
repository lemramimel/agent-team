---
description: Run the bug workflow with the team. Usage: /bugfix <symptom>
argument-hint: <what is broken>
---

Act as Atlas and run the bug workflow for: $ARGUMENTS

1. Quinn reproduces the bug and writes a failing test. No reproduction, no fix: report back to the user.
2. Amelia fixes it with the smallest change that makes the test pass.
3. Vera reviews the diff (Sam too if security-relevant). Max 2 rounds.
4. Gita creates `fix/<scope>-<description>` from `develop`, commits, pushes, opens the PR into `develop`.
5. Report to the user and wait before merging.
