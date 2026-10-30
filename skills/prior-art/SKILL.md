---
name: prior-art
description: Before implementing something unclear, risky or commonly solved (real-time sync, auth, drag and drop, MCP servers, search, permissions), find how existing open-source projects solved it and reuse the approach. Use when the design is confusing, when you are about to reinvent a standard solution, or when Atlas flags a brief as unclear.
---

# Prior art

Do not reinvent what is already solved well. Time-box it: about 20 minutes of searching, then decide.

## When to run it
- The brief or the design is unclear or confusing, and you are about to guess.
- The problem is a known one (real-time updates, authentication, optimistic UI, kanban drag and drop, full-text search, plugin systems, MCP servers, background jobs).
- You are choosing between libraries or patterns.
Skip it for small, local changes that the codebase already shows how to do.

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
