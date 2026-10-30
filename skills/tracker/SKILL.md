---
name: tracker
description: Read, create and update tickets in whichever tracker the project uses (Linear, Jira, ClickUp, GitHub Issues, markdown files, or a custom one). Use whenever a task involves a ticket: reading its scope, creating one, moving its status, commenting. Never call tracker tools directly.
---

# Tracker

Single entry point to the project's ticket tracker. The contract and the rules are in `docs/TRACKERS.md` of the agent-team plugin; this file is the procedure.

## Procedure

1. Read `team/tracker.json` in the project. If it does not exist, use the `markdown` adapter (tickets as files in `team/state/tickets/`) and tell the user once that no tracker is configured.
2. Load the adapter file `adapters/<adapter>.md` from this skill's folder. For `custom`, use the `operations` mapping of the config.
3. Do the requested operation (`search`, `get`, `create`, `update`, `setStatus`, `comment`, `link`, `list`) with the adapter's instructions. Translate statuses, types and labels through the config maps.
4. Return the canonical result: `id`, `title`, `status`, `url`, plus what was changed.

## Rules

- `search` before `create`, to avoid duplicates. If a close match exists, show it and ask.
- Create or edit a ticket only when the user asked for it or approved its text.
- Write the description with the project's sections and language. Default sections: Context, To do, Out of scope, Acceptance criteria. Acceptance criteria must be verifiable.
- Never put the ticket id in a branch name. It goes in the PR title.
- If `autoDone` is true, do not set `done`: the tracker does it on merge.
- If an operation is not available in this tracker, say so and use the fallback in the adapter file. Do not invent one silently.
- Never print tokens or secrets. Credentials come from the tool's own connection or environment variables.
- Tool names differ between installations. If a tool named in an adapter is not available, search for the equivalent tool in the connected tools, and tell the user which one you used.
