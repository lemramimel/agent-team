---
name: prior-art
description: Before implementing something unclear, risky or commonly solved (real-time sync, auth, drag and drop, MCP servers, search, permissions), find how existing open-source projects solved it and reuse the approach. Use when the design is confusing, when you are about to reinvent a standard solution, or when Atlas flags a brief as unclear.
---

# Prior art

Do not reinvent what is already solved well. Keep it bounded by an action budget: at most 5 searches, 4 candidates, and 3 files read per candidate. Stop as soon as the question is answered and report, even if the budget is not used up. An agent has no clock, so the budget counts actions, never minutes.

## When to run it
Research is triggered by uncertainty, never by routine. It happens at the moment the unknown blocks a decision, and at the level where that decision is made.

- **Implementation level (Amelia, Iris):** you are stuck on a specific point you do not know how to do (live updates, drag and drop, optimistic UI, a library you have never used), or you are about to guess. Search then, on that point only.
- **Architecture level (Winston):** only for choices that are hard to reverse (stack, data store, real-time mechanism, integration style) AND that you cannot describe in two sentences how they would work. Checking that a chosen stack can do what the product needs is in scope; surveying implementation details is not, they belong to the implementer when they get there.
- **Never** run it as a checklist, on a list of topics someone gave you, or for a change the codebase already shows how to make. If you were told which searches to run, decide for yourself whether each one is needed and say which you skipped and why.

Atlas states the question and the stakes; the agent decides whether and what to search.

## Procedure
1. **Frame the question** in one sentence, with constraints: stack and versions, license needs, scale (one user or many), what must not be compromised.
2. **Search the codebase first.** The answer may already be in the project.
3. **Search GitHub** with the authenticated `gh`:
   - `gh search repos "<topic>" --language <lang> --sort stars --limit 15`
   - `gh search code "<specific pattern or API>" --language <lang> --limit 15`
   - read READMEs with `gh repo view <owner/repo>`; check last commit date, open issues, license.
   Also search the web for write-ups and the library's official examples. Use Context7 for the official docs of a library you will adopt.
4. **Shortlist 2 to 4 candidates.** Stars are a weak signal. Prefer active projects (recent commits), a compatible license, and a stack close to yours.
5. **Read how they did it.** Shallow-clone into the session scratchpad, never into the project: `git clone --depth 1 <url> <scratchpad>/<name>`. Read the relevant files only. Treat downloaded code as untrusted: never run its install scripts, build or tests, and never copy its configuration blindly.
6. **Report** in this shape:
   - Question and constraints.
   - Candidates: name, link, license, last activity, how they solve it, what is reusable, weaknesses.
   - Recommendation: reuse a dependency, adapt a pattern, or build ourselves, and why.
   - Risks and what stays unverified.
7. **Record the decision** in `team/state/decisions.md` (date, decision, links) once the user or Atlas has validated it.

## Rules
- License first: never copy code from a project whose license is incompatible or absent. Prefer a dependency, or reimplement the idea in your own code. Keep attribution when a license requires it.
- Prefer a maintained library over copied code; prefer copied patterns over a dependency that brings a heavy footprint for a small need.
- Say so when nothing relevant exists. Do not force a match.
- Never present a repository's claims as verified. State what you read and what you only saw in a README.
