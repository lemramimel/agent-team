# Adapter: GitHub Issues

Uses the `gh` CLI, already authenticated.
`settings`: `repo` (`owner/name`, default: the current repository).

| Operation | How |
|---|---|
| `search(text)` | `gh issue list --search "<text>" --state all` |
| `get(id)` | `gh issue view <number> --json number,title,body,state,labels,url` |
| `create(ticket)` | `gh issue create --title ... --body-file ... --label ...` |
| `update(id, fields)` | `gh issue edit <number> ...` |
| `setStatus(id, status)` | `in_progress`, `in_review`: set a label from `statuses`; `done`: `gh issue close`; reopening: `gh issue reopen` |
| `comment(id, text)` | `gh issue comment <number> --body ...` |
| `link(id, prUrl)` | Put `(#<number>)` in the PR title, and `Closes #<number>` only if the user wants auto-close on merge |
| `list(filter)` | `gh issue list --state ... --label ...` |

Notes:
- Ticket ids are `#123`; set `idPattern` accordingly (for example `#\\d+`).
- Epics: use a parent issue with a task list, or a label from `types`.
- If a GitHub Project board is used for statuses, `setStatus` needs `gh project item-edit`; configure the field ids in `settings`.
- Typical `autoDone`: `true` when `Closes #n` is used in the PR.
