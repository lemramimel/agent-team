---
description: Set up the team in an existing project (state folders, git hooks, branch protection, no-attribution setting)
---

In the current project:
1. Create `team/state/briefs/`, `team/state/specs/` and an empty `team/state/decisions.md` if missing.
2. Install the git hooks (commit-msg, pre-push): run `${CLAUDE_PLUGIN_ROOT}/scripts/install-git-hooks.sh`.
3. Ensure `.claude/settings.json` disables Claude Code's own attribution: `"attribution": { "commit": "", "pr": "" }` and `"includeCoAuthoredBy": false`. Merge, do not overwrite existing keys.
4. If the repo is on GitHub and has no `develop` branch, ask the user, then create it from `main`, make it the default branch, and run `${CLAUDE_PLUGIN_ROOT}/scripts/protect-branches.sh`. Never push to `main` or `develop` directly for this: `develop` is created by the user-approved bootstrap only.
5. Ticket tracker: ask which one the project uses (Linear, Jira, ClickUp, GitHub Issues, a custom one, or none). Write `team/tracker.json` from `${CLAUDE_PLUGIN_ROOT}/team/tracker.example.json` (or the `custom` template in `skills/tracker/adapters/custom.md`), fill in the project's id pattern, settings and status names, then run `${CLAUDE_PLUGIN_ROOT}/scripts/check-tracker-config.sh team/tracker.json`. With no tracker, skip the file: tickets are markdown files under `team/state/tickets/`.
6. Helpers: create `team/bin/git-flow.sh` and `team/bin/graphify-gate.sh`, two-line wrappers that run the plugin's scripts by absolute path (`exec "${CLAUDE_PLUGIN_ROOT}/scripts/<script>" "$@"`, with the path resolved now), and make them executable. Re-run `/team-init` if the plugin moves.
7. Companions: check whether `impeccable` (or `frontend-design`) is installed for UI work, and mention `docs/COMPANIONS.md` of the plugin if not. Context7 comes with the plugin; remind the user that documentation queries go to a remote service (see the Privacy section of the README).
8. Tell the user to run `claude --agent atlas` (or set `"agent": "atlas"` in settings) to make Atlas the entry point.
