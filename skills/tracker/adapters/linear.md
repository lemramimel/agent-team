# Adapter: Linear

Uses the Linear MCP server (tools prefixed `mcp__linear-server__`, or the equivalent in your installation).
`settings`: `team` (key or name), `project` (optional).

| Operation | How |
|---|---|
| `search(text)` | `list_issues` with `team`, `query` |
| `get(id)` | `get_issue` |
| `create(ticket)` | `save_issue` with `title`, `team`, `description`, and optionally `project`, `parentId`, `labels`, `assignee` |
| `update(id, fields)` | `save_issue` with `id` and the changed fields |
| `setStatus(id, status)` | `save_issue` with `id` and `state` set to `statuses[status]` |
| `comment(id, text)` | `save_comment` |
| `link(id, prUrl)` | Linear links a PR automatically when the PR title or branch carries the id. Put the id in the PR title. Otherwise `create_attachment` |
| `list(filter)` | `list_issues` with `team`, `state`, `parentId`, `label` |

Notes:
- Pass descriptions as real Markdown with real newlines, not escaped `\n`.
- Linear suggests a branch name containing the user handle and the id. The project convention wins: do not use it if it breaks the naming rule. The id goes in the PR title.
- Epics and stories are modelled with `parentId` and labels as configured in `types` and `labels`.
- Typical `autoDone`: `true` when the GitHub integration is on (Done on merge).
