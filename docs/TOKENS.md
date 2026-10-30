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

## Cost of aggregating skills
Measured with `claude plugin details agent-team`: always-on cost 1,319 tokens before the copied skills, 2,789 after 21 copied skills (about 70 tokens each). Four of them (`handoff`, `retro`, `to-spec`, `to-tickets`) are manual-only upstream and add nothing until used. Each agent preloads only its core skills; the others load on demand. Installing a whole method would have been far heavier: ECC alone has 314 skills.

## Model versions
By the official API list prices (cached 2026-10-06; a subscription's usage limit may weight models differently, unverified): Haiku 5.5 $0.10 / $0.50 per million tokens (input / output), Sonnet 5.5 and Sonnet 5 $2 / $10, Sonnet 4.6 $3 / $15, Opus 5.5 $4 / $20. Older Sonnet versions are therefore not a saving. The levers are Haiku 5.5 for mechanical work and the effort level on Sonnet 5.5.

## What `/livrer-ticket` does better, and what we took from it
A fixed pipeline with stop rules, one review agent instead of three, tests written before the code, git without an agent, no relaying of reports. Our visual QA in a real browser costs more but found real defects that a code review cannot see, so it stays for UI changes. `commands/feature.md` now follows a fixed pipeline with review depth sized by the ticket's risk.

## Files or inline handoffs?
Agents cannot talk to each other; everything passes through Atlas.
- **Inline** costs the report's size on every later turn it stays in Atlas's context, plus the output tokens Atlas spends rewriting it into the next brief. Output tokens are the most expensive kind.
- **A file** costs its size once per reader, and nothing for agents that do not read it. It also persists across sessions.
- **Rule of thumb:** longer than about 10 lines, or needed by more than one agent or in more than one turn: file. Otherwise inline.
- **Where files lose:** every reader reads the whole file each time, or files grow without structure. Hence the `## Résumé`, the section list, and briefs that say which sections to read.

## Graph and note tools
See `docs/COMPANIONS.md`: `graphify` is worth measuring on a large existing codebase; Obsidian brings no token saving.
