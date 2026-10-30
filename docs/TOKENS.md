# Tokens: what costs, what to do

## Measured on the first real projects
Counts come from the usage metadata of agent results. They are token counts, not a bill: they probably include re-read context.

| Source | Observation |
|---|---|
| Plugin prompts | About 1.3k tokens always on for the whole plugin; 300 to 1,300 per agent or skill when invoked (`claude plugin details agent-team`). Not the problem. |
| Git operations through an agent | About 20 runs of 35k to 41k tokens each, roughly 0.8M tokens, for operations of about 5 commands. Most of that is the base context of a subagent, not the work. |
| Implementation and review agents | 75k to 110k tokens per pass; one agent resumed three times carried its whole history. |
| Atlas missions | Four non-interactive runs, each spawning Mira and Winston, who re-read specs of 20 to 36 KB every round. |
| Main conversation | Re-read at every turn: long summaries and raw tool output stay in it. |

Unverified: the exact split of a subagent's base cost (system prompt, CLAUDE.md, skills list, connected tools). Measure with `team/state/usage.md`.

## What the team does about it
1. **Git without a model.** `scripts/git-flow.sh` does branch, commit, PR, merge and cleanup with all the rules built in and a one-line result. Agents are only for judgment (commit splits, messages, PR body).
2. **Routing.** No opus. Haiku for mechanical work, Sonnet at medium effort for standard work, Sonnet at high effort for deep work (architecture choices, review of risky tickets, security). Table in `team/PROTOCOL.md`.
3. **Short reports.** 15 lines at most, details in `team/state/reports/`.
4. **Resume at most twice.** Then a fresh agent with a brief and the last report.
5. **Documents with a summary.** `## Résumé` of 20 lines at most first, section list, briefs name the sections to read.
6. **Measure.** `team/state/usage.md` per mission, and `--max-budget-usd` on non-interactive runs.

## Files or inline handoffs?
Agents cannot talk to each other; everything passes through Atlas.
- **Inline** costs the report's size on every later turn it stays in Atlas's context, plus the output tokens Atlas spends rewriting it into the next brief. Output tokens are the most expensive kind.
- **A file** costs its size once per reader, and nothing for agents that do not read it. It also persists across sessions.
- **Rule of thumb:** longer than about 10 lines, or needed by more than one agent or in more than one turn: file. Otherwise inline.
- **Where files lose:** every reader reads the whole file each time, or files grow without structure. Hence the `## Résumé`, the section list, and briefs that say which sections to read.

## Graph and note tools
See `docs/COMPANIONS.md`: `graphify` is worth measuring on a large existing codebase; Obsidian brings no token saving.
