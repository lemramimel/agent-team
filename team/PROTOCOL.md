# Protocol

State lives in files under `team/state/` of the target project. Subagents share no context, so every handoff is a file.

## Brief (Atlas -> member), `team/state/briefs/<id>.md`
```
Goal:
Context (files to read):
Constraints:
Deliverable:
Done when (verifiable):
Do NOT touch:
```

## Report (member -> Atlas)
```
Done:
Proof (command + output tail):
Open points:
Risks:
```

## Definition of done
Tests, lint and build were run and the output is attached. No proof, no done.

## Commit rules (enforced by hooks)
- Short subject, 72 chars max. Body optional, 2 lines max.
- No Co-Authored-By, no Claude-Session, no "Generated with", no AI mention, in commits, PRs and merges.
- Only Gita commits, pushes, opens PRs and merges.

## Limits
- Review loop: 2 rounds max, then escalate to the user.
- Irreversible actions need the user's approval relayed by Atlas.
