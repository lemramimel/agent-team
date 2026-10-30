# agent-team

A named software team for [Claude Code](https://claude.com/claude-code), packaged as a plugin. You talk to **Atlas** (the CEO); he qualifies the request, writes briefs and delegates to specialists. Any member can also be called directly by name.

## The team

| Name | Role |
|---|---|
| **Atlas** | CEO. Single entry point: routes, delegates, verifies evidence, reports |
| **Mira** | Product manager: specs, acceptance criteria, task split |
| **Winston** | Architect: design, trade-offs, decision records |
| **Sally** | UX designer: flows, screen states, accessibility |
| **Amelia** | Developer: implements one task from a brief, test-first |
| **Ned** | DevOps: CI, Docker, release mechanics |
| **Quinn** | QA: tests, edge cases, regressions |
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
```bash
git clone https://github.com/lemramimel/agent-team ~/agent-team
claude --plugin-dir ~/agent-team --agent atlas
```
Requires `git`, `gh` (authenticated) and `jq`.

## Use
| Command | What it does |
|---|---|
| `/new-project <name> [--public\|--private]` | Create a GitHub repo with `main` + `develop`, both protected, hooks installed |
| `/team-init` | Set up an existing project: state folders, git hooks, protection, no-attribution setting |
| `/feature <description>` | Full feature workflow |
| `/bugfix <symptom>` | Reproduce, fix, review |
| `/release <version>` | Release PR `develop` -> `main` |
| `/ask <name> <request>` | Talk directly to one member |

## Git policy (enforced, not suggested)
- Never commit, merge or push directly on `main` or `develop`; always a PR.
- Branch names: `<type>/<scope>-<short-description>`, lowercase, no accents.
- Short commit subjects (72 chars max). **No AI attribution**: no `Co-Authored-By`, no `Generated with`, no session trailers, in commits, PRs or merges.
- Enforced in three layers: an agent-side `PreToolUse` hook, local `commit-msg` / `pre-push` git hooks, and GitHub branch protection.

Full table: [`docs/BRANCHING.md`](docs/BRANCHING.md).

## Evaluation
[`team/evals/scenarios.md`](team/evals/scenarios.md) lists replayable scenarios (feature, bug, adversarial guardrail prompts, direct calls, missing proof). Replay after every prompt or hook change.

## Layout
```
agents/      one file per team member
commands/    slash commands (workflows, /ask, /new-project, /team-init)
skills/      reusable methods (git-hygiene)
hooks/       hooks.json registering the PreToolUse guard
scripts/     guard-git.sh, commit-msg, pre-push, protect-branches.sh, new-project.sh
team/        roster, protocol, state templates, evals
docs/        branching policy
```

## Status
v0.1: skeleton and guardrails. Not yet battle-tested on a real ticket.

## License
MIT
