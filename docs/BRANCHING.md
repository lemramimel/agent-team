# Branching and PR policy

## Branches
- `main`: production. Receives only release PRs from `develop` (merge commit) and `hotfix/*` PRs.
- `develop`: integration, default branch. Receives feature PRs (squash merge).
- One short-lived branch per ticket, created from `develop`, deleted after merge.

## Naming
`<type>/<scope>-<short-description>`: lowercase, digits and hyphens, no accents.
Types: `feat fix refactor chore ci build docs test perf hotfix`.
Examples: `feat/crm-export-csv`, `fix/import-empty-lines`, `hotfix/login-timeout`.
The ticket id goes in the PR title or description, not in the branch name.

## Rules and where they are enforced

| Rule | Agent hook (`guard-git.sh`) | Local git hook | GitHub protection |
|---|---|---|---|
| No commit / merge on main or develop | yes | | |
| No direct push to main or develop | yes | `pre-push` | yes |
| No force push, no `--all`, no `--mirror` | yes | | yes |
| Branch name format | yes | | |
| PR into main only from develop or hotfix/* | yes | | |
| Short subject, no AI attribution | yes | `commit-msg` | |
| Branch deleted after merge | | | `delete_branch_on_merge` |

Server-side protection also applies to admins, so a PR is always required. The only direct push is the first commit of a new repo, done by `scripts/new-project.sh`.

## Merge mode
`git-flow.sh merge` squashes feature PRs into `develop` and uses a merge commit for release PRs into `main`. The merge-commit path is not yet tested on a real release.

## New project
`/new-project <name> [--public|--private]` creates the repo with `main` and `develop`, sets `develop` as default, protects both, installs the hooks.
For an existing repo, run `/team-init`.
