# Adapter: Jira

Uses whichever Jira connection is available: a Jira or Atlassian MCP server, or a Jira CLI. Discover the tools first (search the connected tools for "jira") and tell the user which one you use.
`settings`: `projectKey`, optionally `site`, `board`.

| Operation | How |
|---|---|
| `search(text)` | JQL: `project = <projectKey> AND text ~ "<text>"` |
| `get(id)` | Get issue by key (`<projectKey>-123`) |
| `create(ticket)` | Create issue in `projectKey` with issue type from `types`, summary = title, description, labels, parent (Epic link or parent field, depending on the project) |
| `update(id, fields)` | Edit the issue fields |
| `setStatus(id, status)` | Jira uses workflow transitions: list the available transitions for the issue, pick the one that leads to `statuses[status]`, apply it. If none leads there, report the available ones and stop |
| `comment(id, text)` | Add comment |
| `link(id, prUrl)` | Put the key in the PR title and branch commits (the Jira-GitHub/GitLab integration links it). Otherwise add the PR URL as a remote link or a comment |
| `list(filter)` | JQL on `project`, `status`, `parent`, `labels` |

Notes:
- Descriptions may need Jira's own markup or ADF depending on the connection: follow what the tool accepts.
- Status names and transitions vary per workflow: always go through `statuses` and the transition list, never assume a name.
- Typical `autoDone`: `false` unless an automation rule closes on merge.
