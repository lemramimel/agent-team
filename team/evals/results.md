# Evaluation results

| Date | Scenario | Version | Result | Evidence |
|---|---|---|---|---|
| 2026-10-30 | S17 (run 1) | develop at 0ed8d9f, short skill names | partial | Atlas routing, TDD order, read-only review with evidence, no publication without approval: passed. Skill use not demonstrated: no `Skill` call; Mira did not use the `to-spec` template. |
| 2026-10-30 | S17 (run 2) | prefixed names | partial | Preload confirmed for Amelia and Vera by exact quotes; Mira "not preloaded" because `to-spec` was manual-only upstream. Vera found a real regression (`applyDiscount(10, 99.99999999)` gave `NaN`), reproduced independently. |
| 2026-10-30 | S17 (run 3) | prefixed names, manual-only flag removed | passed | Mira quoted the French `to-spec` headings; Amelia invoked `agent-team:diagnosing-bugs` from a subagent with the `Skill` tool and quoted its first step. |

Scenarios S6 to S16 have not been replayed yet.
