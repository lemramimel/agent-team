# Roster

Call anyone by name: "Quinn, check the import module" or `/ask quinn <request>`.
Default entry point: Atlas.

| Name | Role | Writes code | Can commit | Skills |
|---|---|---|---|---|
| Atlas | CEO, routing, synthesis | no | no | tracker |
| Mira | PM, tickets, spec and tasks | no (docs, tickets) | no | tracker |
| Winston | Architect | no (docs) | no | prior-art |
| Sally | UX designer | no (docs) | no | |
| Amelia | Developer (logic, APIs, data) | yes | no | prior-art |
| Iris | UI engineer (visuals, components, themes) | yes (UI) | no | ui-craft, prior-art |
| Ned | DevOps, CI, releases | CI/infra files | no | |
| Quinn | QA | tests only | no | visual-qa |
| Vera | Code reviewer (read-only) | no | no | |
| Sam | Security reviewer (read-only) | no | no | |
| Gita | Git operator | no | yes | git-hygiene |

## Workflows
- `/feature`: ticket -> Mira -> Winston (+ `prior-art` for a hard-to-reverse choice) (+ Sally if UI) -> Gita branch -> Amelia (logic) and Iris (UI) -> Atlas checks, Quinn + Vera (+ Sam) in parallel -> Gita PR -> CI -> user approves merge.
- `/bugfix`: ticket -> Quinn reproduces -> Amelia fixes -> Vera (+ Sam) -> Gita.
- `/release`: Ned checks -> Gita opens the release PR -> user merges.
- Question: Atlas answers or routes to the relevant member.

## Source of truth per capability (no overlapping methods)
- Product cycle (spec, epics, stories): BMAD
- Execution discipline (plan, TDD, verify before done): Superpowers
- Hooks and security rules: ECC, picked individually
- CEO / challenge posture: gstack
- Small focused skills: Matt Pocock style
- Tickets: the `tracker` skill and its adapters (`docs/TRACKERS.md`)
- Browser verification: the `visual-qa` skill (Playwright)
- UI design: the `ui-craft` skill, plus `impeccable` when installed (`docs/COMPANIONS.md`)
- Finding how others solved it: the `prior-art` skill (GitHub search)
- Up-to-date library docs: the Context7 MCP server (Amelia, Iris, Winston, Vera, Ned, Quinn)

Branching and PR policy: `docs/BRANCHING.md`.
