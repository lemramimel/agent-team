# Adapter: custom (your own tracker, or any tool without a dedicated adapter)

Driven entirely by `team/tracker.json`, so no plugin change is needed.

```json
{
  "adapter": "custom",
  "idPattern": "ABC-\\d+",
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
  "notes": { "setStatus": "send the status name in the `state` field" },
  "statuses": { "backlog": "Backlog", "todo": "Todo", "in_progress": "In Progress", "in_review": "In Review", "done": "Done" },
  "autoDone": false
}
```

## How to run an operation

1. Look up `operations.<op>` in the config. The value is the name of an MCP tool, or a shell command template prefixed with `cmd:` (for example `cmd:mytracker ticket get {id}`).
2. Read `notes.<op>` if present: it carries argument details.
3. Call the tool or command with the canonical fields, translating statuses, types and labels through the config maps.
4. If the tool's schema is unknown, load it first (search the connected tools), then call it.
5. If `operations.<op>` is missing, use the fallback and tell the user:
   - `link`: put the id in the PR title, and add the PR URL as a comment if `comment` exists;
   - `setStatus`: ask the user to move the ticket;
   - `search`: use `list` and filter by title;
   - any other: report that the operation is unavailable.

## Making your own tracker agent-friendly

A tracker works well with the team when it offers these eight operations through an MCP server, accepts Markdown descriptions, returns the ticket URL on create, and lets `setStatus` take a status name. See `docs/TRACKERS.md`.
