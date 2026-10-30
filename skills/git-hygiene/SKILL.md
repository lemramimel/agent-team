---
name: git-hygiene
description: Rules for commit messages, PR descriptions and merges. Short, no AI attribution. Use whenever creating a commit, PR or merge.
---

# Git hygiene

## Commit message
- Subject only, <= 72 chars. Add a body only when the "why" is not obvious (max 2 lines).
- Match the repo: language, `type(scope): summary` if conventional commits are in use.
- Forbidden anywhere in the message: `Co-Authored-By`, `Claude-Session`, `Generated with`, `noreply@anthropic.com`, robot emoji, any AI tool name.

Good: `fix(import): ignorer les lignes vides du CSV`
Bad: a paragraph explaining everything, or a trailer naming an assistant.

## Pull request
- Title = the commit subject.
- Body: what / why / how to verify, 3 to 5 lines total.
- No attribution footer.

## Merge
- Squash for feature branches into the integration branch unless the repo says otherwise.
- The squash message follows the commit rules above. Check it before confirming: GitHub may prefill co-author trailers from the commits.

## Safety
- No `--force` on shared branches, no `--no-verify`, no history rewrite of pushed commits without an explicit user order.
- If a hook blocks a message, fix the message. Do not bypass the hook.
