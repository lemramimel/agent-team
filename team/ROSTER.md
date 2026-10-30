# Roster

Call anyone by name: "Quinn, check the import module" or `/ask quinn <request>`.
Default entry point: Atlas.

| Name | Role | Writes code | Can commit |
|---|---|---|---|
| Atlas | CEO, routing, synthesis | no | no |
| Mira | PM, spec and tasks | no (docs) | no |
| Winston | Architect | no (docs) | no |
| Amelia | Developer | yes | no |
| Quinn | QA | tests only | no |
| Vera | Reviewer (read-only) | no | no |
| Gita | Git operator | no | yes |

## Workflows
- Feature: Mira -> Winston -> Amelia -> Quinn + Vera (parallel) -> Gita -> Atlas reports.
- Bug: Quinn reproduces -> Amelia fixes -> Vera reviews -> Gita.
- Question: Atlas answers or routes to the relevant member.

## Source of truth per capability (no overlapping methods)
- Product cycle (spec, epics, stories): BMAD
- Execution discipline (plan, TDD, verify before done): Superpowers
- Hooks and security rules: ECC, picked individually
- CEO / challenge posture: gstack
- Small focused skills: Matt Pocock style

Planned next: Sam (security), Sally (UX), Ned (CI/DevOps).
