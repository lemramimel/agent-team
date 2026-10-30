# agent-team

A named software team for [Claude Code](https://claude.com/claude-code), packaged as a plugin. You talk to **Atlas** (the CEO); he qualifies the request, writes briefs and delegates to specialists. Any member can also be called directly by name.

## The team

| Name | Role |
|---|---|
| **Atlas** | CEO. Single entry point: routes, delegates, verifies evidence, reports |
| **Mira** | Product manager: tickets, specs, acceptance criteria, task split |
| **Winston** | Architect: design, trade-offs, decision records |
| **Sally** | UX designer: flows, screen states, accessibility |
| **Amelia** | Developer: logic, APIs and data, one task from a brief, test-first |
| **Iris** | UI engineer: components, layout, themes, accessibility, from Sally's UX note |
| **Ned** | DevOps: CI, Docker, release mechanics |
| **Quinn** | QA: tests, edge cases, regressions, real-browser checks (Playwright) |
| **Vera** | Code reviewer, read-only by design |
| **Sam** | Security reviewer, read-only by design |
| **Gita** | Git operator: the only one who commits, pushes, opens PRs |

Details and workflows: [`team/ROSTER.md`](team/ROSTER.md). Handoff formats and definition of done: [`team/PROTOCOL.md`](team/PROTOCOL.md).

## Design principles
- **Agent = role and authority, skill = method.** Methods can change without rewriting the team.
- **Files are the shared memory.** Subagents share no context, so every handoff is a file under `team/state/`.
- **Separation of powers.** Whoever writes code does not approve it; reviewers have no edit tools.
- **Guardrails are code, not prompts.** Hooks enforce the rules, so they cannot be forgotten.
- **Flat delegation.** Claude Code subagents cannot spawn subagents, so Atlas dispatches; managers return plans.

## Install

From the marketplace in this repository (one step, Claude Code 2.1.275 or later):
```
/plugin install agent-team --marketplace lemramimel/agent-team
```

Or from a local clone:
```bash
git clone https://github.com/lemramimel/agent-team ~/agent-team
claude --plugin-dir ~/agent-team --agent atlas
```

Requires `git`, `gh` (authenticated) and `jq`. A handy alias: `alias team='claude --plugin-dir ~/agent-team --agent atlas'`.

## Use
| Command | What it does |
|---|---|
| `/new-project <name> [--public\|--private]` | Create a GitHub repo with `main` + `develop`, both protected, hooks installed |
| `/team-init` | Set up an existing project: state folders, git hooks, protection, no-attribution setting |
| `/feature <description>` | Full feature workflow |
| `/bugfix <symptom>` | Reproduce, fix, review |
| `/release <version>` | Release PR `develop` -> `main` |
| `/ask <name> <request>` | Talk directly to one member |

## Naming
Whenever a team member is mentioned to the user, the role follows the name: Atlas (CEO), Gita (Git), Winston (architecte)... The labels are in [`team/ROSTER.md`](team/ROSTER.md).

## Tickets: any tracker
Agents talk to a tracker-neutral contract (search, get, create, update, setStatus, comment, link, list) through the `tracker` skill. A per-project `team/tracker.json` picks the adapter: **Linear, Jira, ClickUp, GitHub Issues, plain markdown files, or a custom tracker** whose operations you map yourself (for example your own Linear exposed as an MCP server). Changing tracker never touches the agents. See [`docs/TRACKERS.md`](docs/TRACKERS.md); validate a config with `scripts/check-tracker-config.sh`.

## Design, research and docs
- **Iris** builds the visual layer with the `ui-craft` skill, and uses `impeccable` (shape, critique, polish) when installed.
- **`prior-art`**: before building something unclear or commonly solved, Winston, Amelia or Iris search GitHub for how mature projects did it, with license and safety rules.
- **Context7** (bundled MCP server): agents check real library docs instead of guessing APIs.
- What is bundled, recommended or left out, and why: [`docs/COMPANIONS.md`](docs/COMPANIONS.md).

## Visual QA
The `visual-qa` skill makes Quinn verify UI changes in a real browser with Playwright: before/after captures, light and dark themes, every picture opened and described. It uses the project's own Playwright setup.

## Git policy (enforced, not suggested)
- Never commit, merge or push directly on `main` or `develop`; always a PR.
- Branch names: `<type>/<scope>-<short-description>`, lowercase, no accents.
- PR titles carry the ticket id (never the branch name); PR bodies are structured (Contexte, Changements, Vérification, Limites).
- Short commit subjects (72 chars max). **No AI attribution**: no `Co-Authored-By`, no `Generated with`, no session trailers, in commits, PRs or merges.
- Enforced in three layers: an agent-side `PreToolUse` hook, local `commit-msg` / `pre-push` git hooks, and GitHub branch protection.

Full table: [`docs/BRANCHING.md`](docs/BRANCHING.md).

## Privacy
The bundled Context7 MCP server is a remote service run by Upstash. Library names and documentation questions sent by the agents leave your machine; do not put secrets or proprietary code in a documentation query. To opt out, remove `.mcp.json`. Details in [`docs/COMPANIONS.md`](docs/COMPANIONS.md#privacy).

## Evaluation
[`team/evals/scenarios.md`](team/evals/scenarios.md) lists replayable scenarios (feature, bug, adversarial guardrail prompts, direct calls, missing proof). Replay after every prompt or hook change.

## Layout
```
agents/      one file per team member
commands/    slash commands (workflows, /ask, /new-project, /team-init)
skills/      reusable methods (git-hygiene, tracker + adapters, visual-qa, ui-craft, prior-art)
hooks/       hooks.json registering the PreToolUse guard
.mcp.json    Context7 MCP server
scripts/     guard-git.sh, commit-msg, pre-push, protect-branches.sh, new-project.sh
team/        roster, protocol, state templates, evals
docs/        branching policy, ticket trackers
```

## Status
v0.2: tested end to end on one real ticket (dark mode, web app): ticket, branch, implementation, review, QA, PR, merge. Findings from that run are folded into the agents and skills.

## License
MIT
