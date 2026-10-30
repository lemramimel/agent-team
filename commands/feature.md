---
description: Run the full feature pipeline with the team. Usage: /feature <ticket id or description>
argument-hint: <ticket id | what to build>
---

Act as Atlas and run this pipeline for: $ARGUMENTS

The steps are fixed. Work that needs no judgment is done by scripts, not by agents (`team/bin/git-flow.sh`, `team/bin/graphify-gate.sh`).

## Pre-flight (no agent)
1. Read the ticket with the `tracker` skill. None given: Mira writes it, after the user approves its text.
2. Note the ticket's risk label: `risk:low`, `risk:medium` or `risk:high` (default `risk:medium`). It sets the review depth below.
3. `git-flow.sh status` must show a clean tree; the repo's auth must work.
4. Run `graphify-gate.sh`. If it says `ready` and the graph is not built, propose enabling graphify to the user once; if built, agents use `graphify query` instead of broad searches. If `dormant`, ignore graphify.
5. Compare the plan against the ticket's "to do" and "out of scope": any contradiction is resolved before delegating.
6. `git-flow.sh branch <type>/<scope>-<description>`; move the ticket to `in_progress`.

## Steps
1. **Design, only if needed.** Skip when the ticket already has verifiable acceptance criteria and does not touch structure. Otherwise Mira (spec), Winston (a hard-to-reverse choice only, he may run `prior-art`), Sally (if UI).
2. **Tests first.** For logic (`risk:medium` and above): Quinn writes failing tests from the acceptance criteria, tests only, and checks they fail for the right reason. For `risk:low`: Amelia writes them herself.
3. **Build.** Amelia (logic, APIs, data) and Iris (visual layer, from Sally's note) make the tests pass without changing their expectations. If an expectation looks wrong, stop and ask.
4. **Checks by Atlas himself.** Lint, type-check, tests, build, using the project's commands. Never trust a report without this.
5. **Review, sized by risk, a fresh agent each round, 2 rounds at most:**
   - `risk:low`: Vera only.
   - `risk:medium`: Vera and Quinn. For UI changes, Quinn follows `visual-qa` (before/after, light and dark).
   - `risk:high`: Vera, Quinn and Sam. The merge is never done without the user's explicit approval.
6. **Deliver.** `git-flow.sh commit` for each logical commit (Gita (Git) for the split and the messages when it is not trivial), then `git-flow.sh pr` with the ticket id in the title and a structured body.
7. **CI.** `git-flow.sh ci`. One fix attempt, then stop.
8. **Report to the user**, then wait. Merge only on the user's approval: `git-flow.sh merge`, then `git-flow.sh cleanup`. Record the mission in `team/state/usage.md`.

## Stop and hand back, saying exactly where things stand, when
- the ticket is ambiguous or contradictory;
- a review finding needs a product or architecture decision;
- blocking findings remain after 2 review rounds;
- the CI fails twice, or fails for a reason unrelated to the diff;
- the merge is refused (protection, conflict, approval);
- a file outside the ticket's scope must change.
