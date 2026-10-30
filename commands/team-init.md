---
description: Set up the team in the current project (state folders, git hook, no-attribution setting)
---

In the current project:
1. Create `team/state/briefs/`, `team/state/specs/` and an empty `team/state/decisions.md` if missing. Add `team/state/briefs/` to `.gitignore` if the user wants briefs untracked (ask once).
2. Install the commit-msg hook: run `${CLAUDE_PLUGIN_ROOT}/scripts/install-git-hooks.sh`.
3. Ensure `.claude/settings.json` disables Claude Code's own attribution: `"attribution": { "commit": "", "pr": "" }` and `"includeCoAuthoredBy": false`. Merge, do not overwrite existing keys.
4. Tell the user to run `claude --agent atlas` (or set `"agent": "atlas"` in settings) to make Atlas the default entry point.
