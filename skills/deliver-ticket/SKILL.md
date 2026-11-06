---
name: deliver-ticket
description: Deliver one ticket end to end in a single session, without the agent team: branch, tests first, code, fresh-agent review, fixes, PR, CI, squash merge, cleanup. The call itself authorizes the merge for this ticket, except for risk:high or when there is no CI. Use only when the user names it (/deliver-ticket <ticket>). For the team pipeline with named agents, use /feature.
disable-model-invocation: true
argument-hint: "<ticket id> [--no-merge]"
---

# Deliver a ticket

Solo mode of `/feature`: one session, one ticket, no named agents. The tracker, git and PR rules are not redefined here, they come from `agent-team:tracker`, `agent-team:git-hygiene` and `git-flow.sh` (`team/bin/git-flow.sh` in a project). Never call `gh` for a branch, commit, PR or merge when `git-flow.sh` does it.

**What the call authorizes, for this ticket only:** create the branch, start review subagents, push, open the PR, squash-merge into the base branch, delete the ticket's branches. Never `main`, never a tag, never `--force`, never edit `team/tracker.json`.

**Merge is suspended** (stop after step 7 and hand over the PR link plus the `git-flow.sh merge` command) when any of these holds: `--no-merge` is given, the ticket is `risk:high`, the repo has no CI workflow on pull requests. Say which one in the report. `risk:high` and missing CI cannot be overridden by an argument.

## Project settings

Read them, never guess them, never ask what a file already says:
- Tracker: `team/tracker.json` (adapter, id pattern, status map, `autoDone`).
- Language, branch base and conventions: the project's `CLAUDE.md` and `docs/BRANCHING.md` when they exist; otherwise the repo's recent history.
- Decisions to respect: `team/state/decisions.md` when it exists.
- Commands for test, lint, type-check, build: the project's `package.json` or equivalent. Run what exists.
- Build method: `methods-check.sh`. BMAD `installed` → `bmad-build` (pass `review=none`, step 5 replaces it) and `bmad-review` for the review. Otherwise `agent-team:test-driven-development` for the build and `agent-team:requesting-code-review` for the review.

## Stop rules

Stop, say exactly where things stand (branch, commit, PR), never work around:
- the ticket is ambiguous or contradicts a decision;
- a prerequisite written in the ticket is not met, or a dependency is not closed;
- a test written first looks wrong (never align it on the code: ask);
- a review finding needs a product or architecture decision;
- two fix rounds were not enough to clear blocking findings;
- CI fails twice, or the failure has nothing to do with the diff;
- merge is refused (protection, conflict, approval required);
- a file outside the ticket's scope must change.

## Steps

1. **Pre-flight.** Read the ticket with `agent-team:tracker`: scope, "out of scope", acceptance criteria, risk, dependencies. Closed ticket → stop. `git-flow.sh status` shows a clean tree, the base branch is up to date, the forge auth works.
2. **Branch and status.** `git-flow.sh branch <type>/<scope>-<description>` (reuse the ticket's existing branch if there is one). Move the ticket to `in_progress`.
3. **Red.** From the acceptance criteria, not from existing code, write one test per criterion plus the obvious edge cases. Run them: each must fail for the right reason (behavior missing, not an import or syntax error). A test that already passes proves nothing: fix or drop it. Commit them alone. Skip for a documentation or configuration ticket, and say so.
4. **Green, then refactor.** Make the tests pass without changing their expectations. Then refactor with tests still green. Run the project's test, lint, type-check and build commands. Check each acceptance criterion against a proof (test, command, observation); keep the proofs for the PR.
5. **Review.** A fresh subagent that does not have your context, on the diff against the base, with the ticket's scope and criteria in its prompt. Ask it in particular: does each criterion have a meaningful test; were the expectations of the tests written first weakened (compare their commits); does anything leave the scope or contradict a decision; does a sensitive area leak a secret. It changes nothing, commits nothing, pushes nothing, and returns findings by severity with file:line and a fix.
6. **Fixes.** Verify each blocking or important finding in the code (it can be wrong; if you drop it, say why). Fix with a commit each, re-run checks, then review again with a new subagent on the full diff. Two rounds at most.
7. **PR and CI.** `git-flow.sh pr` (title with the ticket id, body with Contexte, Changements, Vérification with each criterion and its proof, Limites with what review dropped or deferred), move the ticket to `in_review`, then `git-flow.sh ci`. One fix attempt, then stop.
8. **Merge and cleanup**, unless suspended: `git-flow.sh merge <pr> --subject "<title>"`, then `git-flow.sh cleanup`. Check the ticket is closed or set it to `done` yourself unless `autoDone` is true.
9. **Report** in three lines: what was delivered, the PR link, the review outcome (fixed, dropped, deferred). If merge was suspended, say why and give the command.
