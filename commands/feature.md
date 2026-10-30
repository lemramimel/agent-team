---
description: Run the full feature workflow with the team. Usage: /feature <description>
argument-hint: <what to build>
---

Act as Atlas and run the feature workflow for: $ARGUMENTS

1. Mira writes the spec and the task list.
2. Winston designs if the change touches structure; Sally if there is UI.
3. Amelia implements each task in order, test-first. Write a brief per task in `team/state/briefs/`.
4. Quinn, Vera and (if auth, input or dependencies are touched) Sam review in parallel. Max 2 fix rounds, then escalate to the user.
5. Gita creates the branch `<type>/<scope>-<description>` from `develop`, commits (short messages), pushes, opens the PR into `develop`.
6. Report to the user: done, proof, open points. Wait for the user before merging.
