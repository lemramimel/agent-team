# Companions: skills and MCP servers around the team

agent-team ships its own agents, skills and hooks. Some capabilities are better borrowed than rebuilt. This page says what is bundled, what is recommended, and what was deliberately left out. Verified against each project's own page on 2026-10-30; check them again before relying on a claim.

## Bundled

| What | Where | Used by |
|---|---|---|
| Context7 MCP server (up-to-date library docs) | `.mcp.json`, remote server `https://mcp.context7.com/mcp` | Amelia, Iris, Winston, Vera, Ned, Quinn |
| `ui-craft`: UI design and build procedure | `skills/ui-craft/` | Iris |
| `prior-art`: find how others solved it on GitHub | `skills/prior-art/` | Winston, Amelia, Iris |
| `visual-qa`: Playwright verification | `skills/visual-qa/` | Quinn |

## Recommended (installed separately)

### `impeccable` (UI design review and polish)
- Source: `pbakaus/impeccable`, Apache-2.0. Started from Anthropic's `frontend-design` skill and extends it with commands: steering (`bolder`, `quieter`, `typeset`, `layout`, `animate`...), review (`critique`, `audit`), finishing (`polish`, `harden`, `clarify`, `adapt`), planning (`shape`, `init`).
- Install: `/plugin marketplace add pbakaus/impeccable` then install from `/plugin`, or `npx impeccable install` in the project.
- Why: Iris uses `shape`, `critique` and `polish` as design passes on top of `ui-craft`.
- Not bundled: it is a large skill with its own hook and subagents, and it is maintained upstream. Install it rather than copying it.

### `frontend-design` (lightweight alternative)
- Source: Anthropic's `anthropics/skills` repository. Framework-agnostic, about 1,400 words: pick a design direction first, plan, then build, then self-critique.
- Install: `npx skills add https://github.com/anthropics/skills --skill frontend-design`.
- Use it if you want a small skill instead of `impeccable`. `impeccable` descends from it, so installing both is redundant.

### Context7 API key (optional)
The server works without a key; a key raises rate limits. Do not commit a key. If you set one, use an environment variable.

## Optional, measure first

### `graphify` (knowledge graph of a codebase)
- What it is, per its own skill and project rules: it turns code and documents into a persistent graph and answers `graphify query`, `path` and `explain` with a small scoped subgraph, usually much smaller than raw grep output; `graphify update .` keeps the code part current without model cost (AST only).
- Where it should help: a large existing codebase, where agents otherwise grep and read many files to find their way. Little to gain on a new repository with little code.
- **Activated by size, not from the start.** `scripts/graphify-gate.sh` (no model tokens) counts tracked source files and lines and says `dormant` or `ready`. Starting thresholds, an estimate to calibrate: 200 source files or 20,000 lines (`GRAPHIFY_MIN_FILES`, `GRAPHIFY_MIN_LINES`). Measured: bnj-crm has 759 files and 130,000 lines (ready); reecon and agent-team have no source files yet (dormant). Atlas runs the gate at the start of a mission and proposes enabling graphify once when the project crosses the threshold and records the answer (`methods-check.sh decide graphify enabled|declined|later`, stored in `team/methods.json` next to the BMAD one); the gate prints it, so a `declined` is never asked again. The graph file is large (10 MB on bnj-crm): agents query it, never read it.
- Not adopted by default: no measurement exists yet. To decide, take 5 real questions about a large repo, answer them with and without it, and compare tokens and correctness in `team/state/usage.md`.

## Left out on purpose

- **Obsidian**: a note-taking app. For agents it is only markdown files, so it saves no tokens by itself. What saves tokens is structure: a `## Résumé`, a section list and an index, which we do with plain markdown. The folder `team/state/` can still be opened in Obsidian later for human reading if you like.

- **`taste-skill`** (`Leonxlnx/taste-skill` and several homonymous repositories): another style engine. Guides on these tools advise picking one style engine, not stacking them, and `impeccable` already fills that slot. Several unrelated repositories share the name, which makes it hard to pin one.
- **`caveman`** (`JuliusBrussee/caveman`): shortens the model's replies to save output tokens. The project's own page says a plain "answer concisely" captured most of the gain, that the rules add about 1,160 input tokens, and that it does not measure reasoning quality. It also starts automatically in subagents and compresses review findings to one line each, which risks losing the context a review needs. Our protocol already requires short reports. Revisit only if output cost becomes a measured problem.

## Privacy
Context7 is a remote service run by Upstash. The library names and questions the agents send to it leave your machine. Do not put secrets or proprietary code in a documentation query. To avoid the service, remove `.mcp.json`; the agents then fall back to their own knowledge and the web.

## Who uses what, and why

| Member | Context7 | Reason |
|---|---|---|
| Amelia | yes | Check an API before using it, instead of guessing |
| Iris | yes | UI libraries and frameworks change quickly |
| Winston | yes | Verify versions and capabilities before recommending a stack |
| Vera | yes | Catch invented or deprecated API usage in a diff |
| Ned | yes | CI and tooling syntax |
| Quinn | yes | Test framework API |
| Mira, Atlas, Sally, Gita, Sam | no | No library API to check |
