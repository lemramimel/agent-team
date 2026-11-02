# Adapter: markdown (no external tracker)

Tickets are files in the project: `team/state/tickets/<ID>.md`. This is the default when no `team/tracker.json` exists. IDs are `T-001`, `T-002`... (next number = highest existing + 1).

File format:

```
---
id: T-001
title: ...
type: story
status: backlog
parent: T-000
labels: [risk:low]
assignee: ...
---

## Context
## To do
## Out of scope
## Acceptance criteria
```

| Operation | How |
|---|---|
| `search(text)` | grep titles and bodies in `team/state/tickets/` |
| `get(id)` | read the file |
| `create(ticket)` | create the next numbered file |
| `update(id, fields)` | edit the front matter or the body |
| `setStatus(id, status)` | edit `status` in the front matter |
| `comment(id, text)` | append a dated bullet under a `## Comments` section |
| `link(id, prUrl)` | append the PR URL under `## Links`; put the id in the PR title |
| `list(filter)` | scan front matter |

`autoDone` is always `false`: Atlas sets `done` after the merge.
