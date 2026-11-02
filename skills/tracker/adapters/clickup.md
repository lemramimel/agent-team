# Adapter: ClickUp

Uses whichever ClickUp connection is available: a ClickUp MCP server or the ClickUp API through the project's tooling. Discover the tools first (search the connected tools for "clickup") and tell the user which one you use.
`settings`: `listId` (where tickets are created), optionally `spaceId`, `workspaceId`.

| Operation | How |
|---|---|
| `search(text)` | Search tasks in the workspace or list by text |
| `get(id)` | Get task by id (ClickUp ids are short strings; custom task ids if enabled) |
| `create(ticket)` | Create a task in `listId` with name = title, description (Markdown if supported), tags = labels, parent for subtasks |
| `update(id, fields)` | Update the task |
| `setStatus(id, status)` | Set the status to `statuses[status]`; statuses are defined per list, so check the list's statuses first |
| `comment(id, text)` | Add task comment |
| `link(id, prUrl)` | Put the task id in the PR title (ClickUp's GitHub integration links on the id). Otherwise add the PR URL as a comment |
| `list(filter)` | List tasks of the list filtered by status, tag or parent |

Notes:
- ClickUp has no epic/story types: model them with a parent task, a tag, or a custom field, as set in `types`.
- Typical `autoDone`: depends on the automation configured; default `false`.
