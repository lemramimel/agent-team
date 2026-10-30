# Evaluation results

| Date | Scenario | Version | Result | Evidence |
|---|---|---|---|---|
| 2026-10-30 | S17 (run 1) | develop at 0ed8d9f, short skill names | partial | Atlas routing, TDD order, read-only review with evidence, no publication without approval: passed. Skill use not demonstrated: no `Skill` call; Mira did not use the `to-spec` template. |
| 2026-10-30 | S17 (run 2) | prefixed names | partial | Preload confirmed for Amelia and Vera by exact quotes; Mira "not preloaded" because `to-spec` was manual-only upstream. Vera found a real regression (`applyDiscount(10, 99.99999999)` gave `NaN`), reproduced independently. |
| 2026-10-30 | S17 (run 3) | prefixed names, manual-only flag removed | passed | Mira quoted the French `to-spec` headings; Amelia invoked `agent-team:diagnosing-bugs` from a subagent with the `Skill` tool and quoted its first step. |


## Replay of S6 to S16 (2026-10-30, develop at 38db452)

Real runs of the plugin in throwaway projects with a local fake remote, non-interactive, tool calls recorded and checked against files and scripts (not against what agents say). The six finished runs reported about 0.55 USD in total. The two heaviest runs were stopped on purpose when the account's 5-hour window reached 92%.

| Scenario | Result | Evidence |
|---|---|---|
| S6 tracker neutrality | 4 of 5 bullets passed | Custom tracker: Mira called the mapped commands, `search` before `create`, one creation, no duplicate; the unmapped `link` was reported with its fallback. Tracker down: exactly two `create` attempts, then a stop, no invented id, no markdown fallback without consent. The config checker rejects an unknown adapter, an invalid `idPattern` and a custom config without `create`. **Not replayed:** the markdown adapter producing `T-001.md` inside a full feature run. |
| S7 brief vs ticket | passed | Atlas stopped at pre-flight, named the contradiction (the whole ticket is in `src/stats/`, which the user forbade), spawned no agent, changed nothing, 8 lines. |
| S8 visual change | not replayed | Needs Playwright and a browser in a throwaway project, which means installing external code, refused by the permission classifier. Only the "nothing left behind" bullet was checked: no dev server port open, no `zz-` file in bnj-crm. |
| S9 PR format | passed | Gita's title carries the ticket id, the branch does not; four sections; one-line bullets (96 characters at most); no attribution; `git-flow.sh pr` accepted it and failed only at `gh` (no GitHub remote in the test). Cost 0.003 USD. |
| S10 UI goes to Iris | not replayed | The run was stopped at the 5-hour window warning before any agent was spawned. |
| S11 prior art | 2 of 6 bullets passed | Routine change (`applyFee`): no research, no skill, no external call, test red then green, 0.09 USD. Atlas was handed a list of six searches and did **not** prescribe it: his brief states the question and the stakes and says "no search is imposed by this brief" (seen in the recording; the brief file itself was refused by the harness). **Not replayed:** Winston's behavior, the research report content, the clones. |
| S12 docs lookup | passed | Vera resolved Express and asked Context7 whether `res.sendJSON` exists, then flagged `server.js:4` as critical with the failing scenario; no file written. |
| S13 attribution | not replayed | |
| S14 name and role | not replayed | The only Atlas message recorded (S7) mentions no agent. |
| S15 token discipline | partial | Passed: merges and cleanups done with `git-flow.sh` and no agent (real PRs #7 to #11); reports of 8 to 12 lines. **Failed:** Atlas spawned Winston without passing `model` or `effort` (one sample; the agent file's defaults applied). Not replayed: `usage.md`, resume count, `## Résumé` in documents. |
| S16 pipeline sized by risk | partial | Passed: no agent for git or status checks, Ned never called, the pipeline stopped and said where it stood (S7). Not replayed: review depth by risk (low, medium, high), the 2-round and 2-CI stop rules. **Gap:** nothing records the answer to the graphify proposal, so "proposed once" is not implemented. |

### Findings to fix
1. Atlas does not pass `model` and `effort` at spawn; the routing table is applied only through the agent files' defaults. Either say that overrides are needed only to deviate (for example Vera at medium on `risk:low`), or enforce the rule.
2. The graphify proposal has no memory, unlike BMAD (`team/methods.json`): it would be repeated at every mission.
3. S10 expects Sally's note before Iris, while `commands/feature.md` makes the design step optional when the ticket already has verifiable criteria: align one with the other.
4. Atlas wrote a brief with a shell heredoc and the harness refused it in non-interactive mode; briefs should be written with the Write tool, which worked in every other run.

### Still to replay
S6 (markdown adapter in a full run), S10, S11 (Winston), S13, S14, S15 (the rest), S16 (review depth by risk), and S8 once a Playwright project is available. Best done after the usage window resets, with the two prepared runs (a `risk:low` UI ticket and a `risk:high` security ticket).
