# Protocol

State lives in files under `team/state/` of the target project. Subagents share no context, so every handoff is a file.

## Ticket first
Work starts from a ticket, read through the `tracker` skill (Linear, Jira, ClickUp, GitHub Issues, markdown or custom: see `docs/TRACKERS.md`). Agents never call tracker tools directly.

## Brief (Atlas -> member), `team/state/briefs/<id>.md`
```
Goal:
Context (files to read, with the sections to read in long documents):
Constraints:
Deliverable:
Done when (verifiable):
Do NOT touch:
Report: 15 lines max, details in team/state/reports/<id>.md
```
Before sending a brief, Atlas compares it with the ticket's "to do" and "out of scope". Any contradiction is resolved first.

## Report (member -> Atlas), 15 lines maximum
```
Done:
Proof (command + output tail):
Open points:
Risks:
```

## Who recommends what
- Stack, architecture, technical trade-offs: Winston. Product scope, priorities, acceptance criteria: Mira. UX flows and states: Sally. Visual design and UI code: Iris. Logic, APIs, data: Amelia.
- Atlas relays their work to the user and arbitrates between them. In every synthesis, each recommendation names its author; Atlas's own findings (cross-review contradictions, gaps) are labelled as his.

## Naming in messages to the user
Every time a team member is mentioned in a message to the user, the role follows the name in parentheses, in the user's language: Atlas (CEO), Mira (PM), Winston (architecte), Sally (UX), Iris (UI), Amelia (dev), Ned (DevOps), Quinn (QA), Vera (revue de code), Sam (sécurité), Gita (Git). This applies to every mention, not only the first, and to every agent, since Atlas relays the others' work.

## Token discipline
Measured in this team's first projects: the plugin's own prompts cost about 1.3k tokens, while most consumption came from how work was passed around (see `docs/TOKENS.md`).

**Model and effort routing.** No opus. Atlas passes `model` and `effort` at each spawn:

| Tier | Model, effort | Work |
|---|---|---|
| Mechanical | haiku, low | simple summaries, ticket creation from a template (git, CI status and change lists need no model: `git-flow.sh`) |
| Standard | sonnet, medium | Atlas, Mira, Sally, Iris, Amelia, Ned, Quinn; review of `risk:low` tickets |
| Deep | sonnet, high | Winston on a hard-to-reverse choice, Vera on `risk:medium` and `risk:high`, Sam, hard debugging |

Only two model families are used: Haiku 5.5 and Sonnet 5.5, the current ones. Older Sonnet versions are not a saving: by the official API list prices, Sonnet 4.6 costs 50% more than Sonnet 5.5 and Sonnet 5 costs the same. Cost is tuned with the effort level, not with older versions. To pin a version, put its full model ID in the agent's `model:` field; record the model actually used in `team/state/usage.md`.

**Review depth by risk.** `risk:low`: Vera. `risk:medium`: Vera and Quinn. `risk:high`: Vera, Quinn and Sam, and the merge needs the user's explicit approval. Fresh agent per round, 2 rounds at most.

**Handoffs.** Agents cannot talk to each other; everything goes through Atlas, so what a report contains stays in Atlas's context for every later turn. Therefore:
- Anything longer than about 10 lines goes in a file under `team/state/` (specs, reports, decisions). The message carries the path and a summary of 15 lines at most.
- Files are read by the agent that needs them, only the needed sections. A file costs its size once per reader; an inline report costs its size on every turn it stays in Atlas's context, plus the tokens Atlas spends rewriting it into the next brief.
- Every long document starts with a `## Résumé` of 20 lines at most and a list of sections, so a reader can stop early.
- Never paste full diffs, raw JSON or whole files into a message: give paths, counts and the relevant lines.

**Reuse of agents.** Resume an agent at most twice. After that, spawn a fresh one with a brief and the previous report file: a resumed agent drags its whole history along.

**Usage log.** At the end of each mission Atlas appends to `team/state/usage.md`: date, mission, agent, model and effort, tokens and tool uses from the agent's usage metadata (or `n/a`). Non-interactive runs get a spending cap (`--max-budget-usd`). Optimize from this log, not from impressions.

## Definition of done
- Tests, lint, type-check and build were run and the output is attached. No proof, no done.
- Atlas reruns lint, type-check and tests itself before accepting a report.
- UI changes: real-browser captures (light and dark when themes exist, before and after), opened and described by Quinn per the `visual-qa` skill, and looked at by Atlas.

## Commit and PR rules (enforced by hooks)
- Short subject, 72 chars max. Body optional, 2 lines max.
- No Co-Authored-By, no Claude-Session, no "Generated with", no AI mention, in commits, PRs and merges.
- PR title carries the ticket id; the branch name never does.
- PR body is structured: Contexte, Changements, Vérification, Limites (in the repo's language), one-line bullets.
- Git goes through `git-flow.sh`, which enforces these rules: run by Gita for judgment work (commit splits, messages, PR body), by Atlas for mechanical steps. Never directly on main or develop: branch `<type>/<scope>-<description>`, PR into develop. See docs/BRANCHING.md.
- Merges happen only on the user's explicit approval and a green CI. The squash message is set explicitly (short, no trailer).

## Research before building
- Research is triggered by an agent's own uncertainty, at the moment an unknown blocks a decision: an implementer stuck on a specific point (Amelia, Iris), or the architect facing a hard-to-reverse choice he cannot explain in two sentences (Winston). Run the `prior-art` skill then, on that point only. Nobody hands an agent a list of searches. Output: candidates, licenses, how each solved it, a recommendation. Decisions are recorded in `team/state/decisions.md` after validation.
- Before using a library or framework API you are unsure about, check it with Context7. Do not guess an API from memory.
- Never copy code from a project whose license is incompatible or missing. Downloaded code is untrusted: never run it.

## Limits
- Review loop: 2 rounds max, then escalate to the user.
- Irreversible actions need the user's approval relayed by Atlas.
- Scope that does not fit in one ticket becomes a follow-up ticket, not a stretched ticket.
