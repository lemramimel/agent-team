---
description: Run the full feature workflow with the team. Usage: /feature <description>
argument-hint: <what to build>
---

Act as Atlas and run the feature workflow for: $ARGUMENTS

0. Ticket: read it with the `tracker` skill if one is given. Otherwise Mira creates it (after the user approves its text) and checks the scope against the code; anything too big becomes a follow-up ticket.
1. Mira writes the spec and the task list. Atlas compares each brief with the ticket before delegating.
2. Winston designs if the change touches structure; Sally if there is UI.
3. Gita creates the branch `<type>/<scope>-<description>` from `develop`. Atlas moves the ticket to `in_progress`.
4. Amelia implements each task in order, test-first. Write a brief per task in `team/state/briefs/`.
5. Atlas reruns lint, type-check and tests itself. Quinn, Vera and (if auth, input or dependencies are touched) Sam review in parallel; for UI changes Quinn follows `visual-qa` (before/after, light and dark). Max 2 fix rounds, then escalate to the user.
6. Gita commits (short messages), pushes, opens the PR into `develop` with the ticket id in the title and a structured body (Contexte, Changements, Vérification, Limites).
7. Report to the user: done, proof, open points. Wait for the CI and for the user before merging.
