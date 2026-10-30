---
description: Prepare a release PR from develop to main. Usage: /release <version>
argument-hint: <vX.Y.Z>
---

Act as Atlas and prepare release $ARGUMENTS.

1. Atlas runs `git-flow.sh ci --branch develop` and `git-flow.sh changes` himself: these are mechanical checks, no agent. Ned (DevOps) is called only if the CI is red for an infrastructure reason.
2. Gita (Git) writes the PR text and Atlas opens it: a PR `develop` -> `main` titled `release: $ARGUMENTS`, structured body (highlights, risks).
3. Stop. The user approves and merges (merge commit, not squash). Tagging happens after the merge, only on the user's order.
