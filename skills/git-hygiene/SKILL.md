---
name: git-hygiene
description: Rules for commit messages, PR descriptions and merges. Short, no AI attribution. Use whenever creating a commit, PR or merge.
---

# Git hygiene

## Tool
Execute with `git-flow.sh` (`branch`, `commit`, `pr`, `merge`, `cleanup`, `status`): it applies every rule below and returns one short line per operation. In a project: `team/bin/git-flow.sh`.

## Commit message
- Subject only, <= 72 chars. Add a body only when the "why" is not obvious (max 2 lines).
- Match the repo: language, `type(scope): summary` if conventional commits are in use.
- Forbidden anywhere in the message: `Co-Authored-By`, `Claude-Session`, `Generated with`, `noreply@anthropic.com`, robot emoji, any AI tool name.

Good: `fix(import): ignorer les lignes vides du CSV`
Bad: a paragraph explaining everything, or a trailer naming an assistant.

## Pull request
- Title = the commit subject, with the ticket id when the project uses a tracker (`feat(web): ... (BNJ-157)`). The id goes in the title, never in the branch name.
- Body: a readable hierarchy, concise. Use these headings (drop a section if empty), in the project's language:
  - `## Contexte`: the ticket and why, 1 to 2 bullets.
  - `## Changements`: what changed, one bullet per change, grouped by theme.
  - `## Vérification`: commands run and results, CI status.
  - `## Limites`: known gaps, follow-up tickets, visible deviations.
- Bullets stay one line each. No walls of text, no decorative emoji.
- No attribution footer.

Example:

```
## Contexte
- Ticket BNJ-157, epic 14 : le thème sombre existait en variables CSS mais rien ne l'activait.

## Changements
- Bascule Clair / Sombre / Système dans l'en-tête, choix mémorisé, sans flash.
- Couleurs passées en jetons : coque, composants ui, connexion.

## Vérification
- npm run lint, npm run test, npm run test:e2e.

## Limites
- Pages du module CRM encore claires : ticket 14.19.
```

## Merge
- Squash for feature branches into the integration branch unless the repo says otherwise.
- The squash message follows the commit rules above. Check it before confirming: GitHub may prefill co-author trailers from the commits.

## Safety
- No `--force` on shared branches, no `--no-verify`, no history rewrite of pushed commits without an explicit user order.
- If a hook blocks a message, fix the message. Do not bypass the hook.
