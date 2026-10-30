---
description: Set up the team in an existing project (state folders, git hooks, branch protection, no-attribution setting)
---

In the current project:
1. Create `team/state/briefs/`, `team/state/specs/` and an empty `team/state/decisions.md` if missing.
2. Install the git hooks (commit-msg, pre-push): run `${CLAUDE_PLUGIN_ROOT}/scripts/install-git-hooks.sh`.
3. Ensure `.claude/settings.json` disables Claude Code's own attribution: `"attribution": { "commit": "", "pr": "" }` and `"includeCoAuthoredBy": false`. Merge, do not overwrite existing keys.
4. If the repo is on GitHub and has no `develop` branch, ask the user, then create it from `main`, make it the default branch, and run `${CLAUDE_PLUGIN_ROOT}/scripts/protect-branches.sh`. Never push to `main` or `develop` directly for this: `develop` is created by the user-approved bootstrap only.
5. Tell the user to run `claude --agent atlas` (or set `"agent": "atlas"` in settings) to make Atlas the entry point.
