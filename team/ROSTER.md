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

## Labels used when mentioning a member
Atlas (CEO), Mira (PM), Winston (architecte), Sally (UX), Iris (UI), Amelia (dev), Ned (DevOps), Quinn (QA), Vera (revue de code), Sam (sécurité), Gita (Git).

## Workflows
- `/feature`: ticket -> Mira -> Winston (+ `prior-art` for a hard-to-reverse choice) (+ Sally if UI) -> Gita branch -> Amelia (logic) and Iris (UI) -> Atlas checks, Quinn + Vera (+ Sam) in parallel -> Gita PR -> CI -> user approves merge.
- `/bugfix`: ticket -> Quinn reproduces -> Amelia fixes -> Vera (+ Sam) -> Gita.
- `/release`: Ned checks -> Gita opens the release PR -> user merges.
- Question: Atlas answers or routes to the relevant member.

## Methods
Each agent aggregates the real skills of BMAD, superpowers, ECC and Matt Pocock (gstack is not used); which skill for which case, and why, is in `docs/METHODS.md`. Copied skills are listed in `THIRD_PARTY.md`.

Branching and PR policy: `docs/BRANCHING.md`.
