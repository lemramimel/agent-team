# agent-team

A named software team for Claude Code, packaged as a plugin. Talk to Atlas (CEO); he delegates to Mira, Winston, Amelia, Quinn, Vera and Gita. Any member can be called directly.

See `team/ROSTER.md` and `team/PROTOCOL.md`.

## Use in a project
1. Load the plugin: `claude --plugin-dir ~/Documents/GitHub/agent-team`
2. Run `/team-init` once in the project.
3. Start with `claude --agent atlas`, or call a member: `/ask quinn <request>`.

## Commit policy
Short messages, never any AI attribution. Enforced twice: a `PreToolUse` hook (`scripts/guard-git.sh`) blocks offending `git`/`gh` commands, and a git `commit-msg` hook strips trailers and rejects long subjects.
