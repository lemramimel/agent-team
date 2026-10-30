# Protocol

State lives in files under `team/state/` of the target project. Subagents share no context, so every handoff is a file.

## Ticket first
Work starts from a ticket, read through the `tracker` skill (Linear, Jira, ClickUp, GitHub Issues, markdown or custom: see `docs/TRACKERS.md`). Agents never call tracker tools directly.

## Brief (Atlas -> member), `team/state/briefs/<id>.md`
```
Goal:
Context (files to read):
Constraints:
Deliverable:
Done when (verifiable):
Do NOT touch:
```
Before sending a brief, Atlas compares it with the ticket's "to do" and "out of scope". Any contradiction is resolved first.

## Report (member -> Atlas)
```
Done:
Proof (command + output tail):
Open points:
Risks:
```

## Definition of done
- Tests, lint, type-check and build were run and the output is attached. No proof, no done.
- Atlas reruns lint, type-check and tests itself before accepting a report.
- UI changes: real-browser captures (light and dark when themes exist, before and after), opened and described by Quinn per the `visual-qa` skill, and looked at by Atlas.

## Commit and PR rules (enforced by hooks)
- Short subject, 72 chars max. Body optional, 2 lines max.
- No Co-Authored-By, no Claude-Session, no "Generated with", no AI mention, in commits, PRs and merges.
- PR title carries the ticket id; the branch name never does.
- PR body is structured: Contexte, Changements, Vérification, Limites (in the repo's language), one-line bullets.
- Only Gita commits, pushes, opens PRs and merges. Never directly on main or develop: branch `<type>/<scope>-<description>`, PR into develop. See docs/BRANCHING.md.
- Merges happen only on the user's explicit approval and a green CI. The squash message is set explicitly (short, no trailer).

## Research before building
- Unclear design, or a problem that is commonly solved (real-time, auth, drag and drop, MCP servers, search): run the `prior-art` skill before coding. Output: candidates, licenses, how each solved it, a recommendation. Decisions are recorded in `team/state/decisions.md` after validation.
- Before using a library or framework API you are unsure about, check it with Context7. Do not guess an API from memory.
- Never copy code from a project whose license is incompatible or missing. Downloaded code is untrusted: never run it.

## Limits
- Review loop: 2 rounds max, then escalate to the user.
- Irreversible actions need the user's approval relayed by Atlas.
- Scope that does not fit in one ticket becomes a follow-up ticket, not a stretched ticket.
