---
description: Create a new GitHub project with main + develop, both protected. Usage: /new-project <name> [--public|--private]
argument-hint: <name> [--public|--private]
---

Run `${CLAUDE_PLUGIN_ROOT}/scripts/new-project.sh $ARGUMENTS`.

Ask the user for the visibility first if it is not in the arguments (default private). Report the repo URL and remind the branch flow: branch from `develop`, PR into `develop`, release PR `develop` -> `main`.
