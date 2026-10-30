# Methods: what the agents aggregate

agent-team does not invent its own methods. Each agent is a role that calls the real skills of several methods (BMAD, superpowers, ECC, gstack, Matt Pocock), picked by comparison: for every case, the best skill, read in full, not chosen by reputation. Where a gap remained, a skill of our own fills it.

Verified 2026-10-30 by reading the skills at the pinned commits (see `vendor/skills.lock`). Sizes are bytes / 4. Licenses: all MIT (BMAD: MIT, (c) BMad Code LLC).

## How skills are delivered
- **Copied into this plugin** (21 skills, `THIRD_PARTY.md`): self-contained markdown, pinned by commit, scanned by `scripts/vendor-check.sh`. No upstream script is copied.
- **Used as a dependency when present**: BMAD skills need the project's `_bmad/` folder, `uv` and BMAD scripts, so they cannot be copied. Agents use them in a project where BMAD is installed (`bmad-build`, `bmad-retrospective`, `bmad-prd`) and fall back to the skills below elsewhere.
- **Not used**: gstack (see below).
- **Ours**: only where nothing else covers the case.

## The pick for each case

| Case | Pick | From | Why it won |
|---|---|---|---|
| Frame a vague idea | `grilling` | Matt Pocock | 0.5k tokens, no dependency, one question at a time with a recommended answer |
| Spec from a discussion | `to-spec` | Matt Pocock | short template; publication adapted (see below). Full PRD with BMAD: `bmad-prd` |
| Split into tickets | `to-tickets` | Matt Pocock | vertical slices, blocking edges, the user approves the split |
| Publish and manage tickets | `tracker` | ours | only one neutral across Linear, Jira, ClickUp, GitHub Issues and a custom tracker; `bmad-ticket` has no ClickUp, ~70k tokens, needs `_bmad/` |
| Architecture decisions | `architecture-decision-records` | ECC | full ADR format with a filter to avoid pointless ADRs |
| Module and domain design | `codebase-design`, `domain-modeling` | Matt Pocock | short, precise vocabulary; glossary |
| Prior art and up-to-date docs | `prior-art` (ours), `documentation-lookup` | ours, ECC | only prior-art has an action budget, a license rule and "never run downloaded code" |
| TDD | `test-driven-development` | superpowers | red-green-refactor, test must fail for the right reason, guards against excuses |
| Build a ticket | `bmad-build` | BMAD | only one covering plan, build, review and a local commit; stops without pushing (read in `step-03`, `step-05`); dependency |
| Plan | `writing-plans` | superpowers | tasks with files, signatures and expected command output |
| Debug | `diagnosing-bugs` | Matt Pocock | deterministic reproduction before any hypothesis |
| Verify before "done" | `verification-before-completion` | superpowers | no claim without a command run, including sub-agent reports |
| Review a diff | `requesting-code-review` | superpowers | read-only, short, three severities, one agent; hardened with a pre-report gate |
| Handle review findings | `receiving-code-review` | superpowers | only dedicated candidate: verify before implementing |
| Security review | `security-review` + Sam | ECC | agent plus checklists; read-only |
| Real-browser QA, before/after, light/dark | `visual-qa` | ours | uses the project's Playwright; the others need a binary, an MCP or are generic |
| UI design | `ui-craft` + `frontend-design-direction` | ours, ECC | short plan and tokens, plus a verifiable state table |
| Accessibility | `accessibility` | ECC | WCAG 2.2 checklist (mobile parts removed) |
| Flow bugs between handlers and store | `click-path-audit` | ECC | covers what states tables do not |
| Git, PR, merge | `git-hygiene`, `git-flow.sh` | ours | enforce our rules in code; nothing else does |
| PR body | `pr-description` | Matt Pocock | mapped onto our four sections |
| Parallel work | `dispatching-parallel-agents` | superpowers | short and sharp |
| Mission retro | `retro` (Matt Pocock); `bmad-retrospective` for a BMAD epic | | |
| Token discipline | `docs/TOKENS.md` | ours | measured on our own projects; `handoff` (Matt Pocock) to relay context |

## Not used, and why
- **gstack, entirely.** Its skills need compiled binaries and a shared preamble with telemetry. `ship` writes a `Co-Authored-By: Claude` trailer and a "Generated with Claude Code" line and pushes without asking; `land-and-deploy` pushes to the base branch on rollback; `review` edits code itself. The browser binary alone is a 229 MB repository plus a build and a Chromium download.
- **ECC `git-workflow`**: pushes to `main`, uses `git add .`, names branches `feature/...`.
- **superpowers `finishing-a-development-branch`**: offers a local merge into the base branch. Its worktree cleanup is covered by `git-flow.sh cleanup`.
- **Matt Pocock `implement-spec`**: opens a draft PR without asking. **`git-guardrails-claude-code`**: its hook blocks every `git push`, including `git-flow.sh pr`.
- **BMAD `bmad-review`**: no severity, demands at least 10 findings (an incentive to invent), needs `_bmad/`. Its sibling `bmad-code-review` has the best triage, which inspired our pre-report gate, but is heavy and not self-contained.
- **ECC `tdd-workflow`**: needs an ECC script and imposes 80% coverage. **`hexagonal-architecture`**: imposes one architecture, against a modular monolith.

## What every skill must respect (checked by `scripts/vendor-check.sh`)
No AI attribution; no commit, merge or push on `main` or `develop`; no push, merge or deploy without the user's approval; no `git add .`; no forced push or hard reset; no remote script execution.

## Adding or replacing a skill
Read it in full; compare it with the current pick on coverage, precision, size, self-containment, rule conflicts and license; copy it only if it wins. Add a line to `vendor/skills.lock`, run `scripts/vendor-skills.sh fetch`, adapt, add the entry to `THIRD_PARTY.md`, run `scripts/vendor-check.sh`.

## When BMAD is absent: one proposal, never an installation
`scripts/methods-check.sh` (no model tokens) says whether BMAD is usable in the project: `installed`, `absent` or `broken` (skills present but no `_bmad/`). When it is `absent` and the user has not answered yet, Atlas proposes BMAD **once**, records the answer (`methods-check.sh decide bmad installed|declined|later`, stored in `team/methods.json`) and never asks again unless the answer is `later`. Agents never install a method: the installer is interactive and modifies the repository, so the user runs it and the result goes through a PR.

What to tell the user:
- **What BMAD adds here:** `bmad-build` (plan, build, review and a local commit in one loop), `bmad-retrospective` (epic retros with sourced findings), `bmad-prd` (full PRDs). Without BMAD, the copied skills (TDD, plans, verification, review) cover the same ground piece by piece.
- **Cost:** BMAD needs the project's `_bmad/` runtime (about 900 KB in bnj-crm) and `uv`. The selective install below adds about 510 tokens of skill descriptions to every session and subagent (estimated from the descriptions in BMAD's repository); the full install of 31 to 33 skills adds about 2,100.
- **Prerequisites** (BMAD docs): Node.js 20.12+, Python 3.10+, `uv`, git.
- **Command, selective install** (7 skills; composed from BMAD's install page for v7 and from reading its setup script, **never executed here**): `npx skills add bmad-code-org/BMAD-METHOD --skill bmad --skill bmod-core-tools --skill bmod-method --skill bmad-agent-po --skill bmad-build --skill bmad-retrospective --skill bmad-prd`, then ask the `bmad` skill to run `bmad setup`, which installs the runtime under `_bmad/`. The full install is the same command with `--skill '*'`.
  - `bmad` ships the shared scripts (`resolve_config.py`, `render_skill.py`, `memlog.py`, `resolve_customization.py`) that `bmad setup` places in `_bmad/scripts/`.
  - **`bmad-agent-po` is required**: it declares `scripts/tickets.py`, and `bmad setup` places a module's scripts in `_bmad/method/scripts/` only from the skills of that module that are installed. `bmad-build` and `bmad-retrospective` call that script. Without this skill they fail at their first call.
- **Warnings from BMAD itself:** v7 is a preview alpha whose install path changes often (the stable line is v6.12, installed with `npx bmad-method install`). Its skills run Python scripts from `_bmad/scripts/` with `uv run`, customization files under `_bmad/custom/` can add steps the skills run, and some skills read text written by others (tickets, PR diffs), which security scanners flag as a prompt-injection risk. Install only if you accept that.
- **Our recommendation:** yes for a project that will carry many tickets and epics (like bnj-crm); no for a small project.

What is established, by reading BMAD's repository (commit `61e01f82`, 2026-10-18): the three skills are not self-contained, they call `{project-root}/_bmad/scripts/` and `_bmad/method/scripts/tickets.py`, and the seven skills above are what `bmad setup` needs to place those scripts. What is **not** established: that the install and `bmad setup` really run end to end on this machine. Running the installer was refused by the permission classifier (it executes code downloaded from npm), and I did not work around that.

## Verified on real runs (scenario S17, 2026-10-30)
- Skills of this plugin are referenced as `agent-team:<name>` in agent frontmatter and prompts. Preloaded skills reached the agents: Amelia, Vera and Mira each quoted text that only exists in their preloaded skill (`test-driven-development`, `requesting-code-review`, `to-spec`), without reading any file. Whether short names would also have resolved was not tested.
- A skill upstream flagged manual-only (`disable-model-invocation: true`) is not loadable by an agent: `to-spec` and `to-tickets` had that flag and Mira reported "not preloaded" until it was removed.
- A subagent invoked a non-preloaded skill by name with the `Skill` tool (`agent-team:diagnosing-bugs`) and quoted its first step exactly.
- Real bugs were found with evidence: Vera caught a defect that Amelia's fix introduced, which was reproduced independently.

## Not verified
Single runs, on a tiny Node project. `bmad-build` was not exercised (the test project has no BMAD). Annex files and scripts of some upstream skills were not read in full (they are not copied). The quality of the skills in real use, as opposed to their loading, is not measured.
