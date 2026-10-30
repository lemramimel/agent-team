# Ticket trackers

The team is not tied to one tracker. Agents talk to a small, tracker-neutral contract; an adapter maps it onto Linear, Jira, ClickUp, GitHub Issues, plain markdown files, or your own system.

## Principle

```
Mira / Atlas / Gita  ->  skill `tracker`  ->  adapter (linear | jira | clickup | github-issues | markdown | custom)
        (what)             (contract)            (how, for one tool)
```

- Agents never call tracker tools directly. They go through the `tracker` skill, which reads `team/tracker.json` and loads one adapter file from `skills/tracker/adapters/`.
- The project chooses the adapter in `team/tracker.json`. Changing tracker means changing that file, not the agents.
- Adding a tracker means adding one adapter file (or just filling the `custom` mapping). No agent changes.

## The contract

Eight operations, all expressed on a canonical ticket.

| Operation | Purpose |
|---|---|
| `search(text)` | Find existing tickets (always before `create`, to avoid duplicates) |
| `get(id)` | Read a ticket: title, description, status, parent, labels, url |
| `create(ticket)` | Create a ticket from the canonical fields |
| `update(id, fields)` | Edit title, description, labels, assignee |
| `setStatus(id, status)` | Move to a canonical status |
| `comment(id, text)` | Add a comment |
| `link(id, prUrl)` | Attach a PR or branch to the ticket |
| `list(filter)` | List tickets by status, parent or label |

Canonical ticket: `id`, `title`, `type` (`epic`, `story`, `bug`), `description`, `status`, `parent`, `labels`, `assignee`, `url`.
Canonical statuses: `backlog`, `todo`, `in_progress`, `in_review`, `done`. `statuses` in the config maps each to the tracker's own name.
Description sections come from the project's ticket template (default: Context, To do, Out of scope, Acceptance criteria), written in the project's language.

## Who does what

| Member | Uses | When |
|---|---|---|
| Mira | `search`, `create`, `update`, `get` | Turn a request into a ticket, refine it |
| Atlas | `get`, `setStatus`, `comment`, `list` | Read the ticket before briefing, move it to `in_progress` when work starts, comment with the PR |
| Gita | `link` (via the PR title) | Put the ticket id in the PR title; never in the branch name |

Rules:
- A ticket is created only when the user asked for it or approved its text. The tracker is a shared, outward-facing system.
- Run `search` before `create`.
- If the tracker closes tickets itself on merge (`autoDone: true`), nobody sets `done`.
- If `adapter` is `markdown` or no config exists, tickets are files under `team/state/tickets/` and the workflow is unchanged.

## Configuration: `team/tracker.json`

```json
{
  "adapter": "linear",
  "idPattern": "BNJ-\\d+",
  "settings": { "team": "BNJ", "project": "CRM V1" },
  "statuses": {
    "backlog": "Backlog", "todo": "Todo", "in_progress": "In Progress",
    "in_review": "In Review", "done": "Done"
  },
  "types": { "epic": "epic", "story": "story", "bug": "bug" },
  "labels": ["risk:low", "risk:medium"],
  "autoDone": true
}
```

- `adapter`: `linear`, `jira`, `clickup`, `github-issues`, `markdown` or `custom`.
- `idPattern`: regex of a ticket id, used by Gita to find it and by the guard to validate PR titles.
- `settings`: free-form, read by the adapter (team, project, space, list, repo...).
- `statuses`, `types`, `labels`: map canonical names to the tracker's own.
- `autoDone`: the tracker closes the ticket on merge.

Validate with `scripts/check-tracker-config.sh team/tracker.json`.

## Your own tracker (`custom`)

Two ways, no plugin change needed.

1. **Expose it as an MCP server** with the eight operations, then map them in the config:

```json
{
  "adapter": "custom",
  "operations": {
    "search": "mcp__mytracker__search_tickets",
    "get": "mcp__mytracker__get_ticket",
    "create": "mcp__mytracker__create_ticket",
    "update": "mcp__mytracker__update_ticket",
    "setStatus": "mcp__mytracker__update_ticket",
    "comment": "mcp__mytracker__add_comment",
    "link": "mcp__mytracker__add_link",
    "list": "mcp__mytracker__list_tickets"
  },
  "notes": {
    "setStatus": "pass the status name in the `state` field"
  }
}
```

   `notes` holds any argument detail an agent needs for an operation.

2. **Keep it API-compatible with an existing tracker** (for example the same API shape as Linear's) and reuse that adapter by pointing its `settings` at your instance. Only do this if the API really is compatible.

If an operation is missing (no `link`, say), leave it out of `operations`: the skill falls back to the PR title and a comment, or skips it, and says so.

## Adding an adapter

Copy `skills/tracker/adapters/custom.md`, name it after the tool, fill in how each of the eight operations maps to that tool's MCP tools or CLI, then add the name to the allowed list in `scripts/check-tracker-config.sh`. Test it with the tracker scenarios in `team/evals/scenarios.md`.
