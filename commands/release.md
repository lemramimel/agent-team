---
description: Prepare a release PR from develop to main. Usage: /release <version>
argument-hint: <vX.Y.Z>
---

Act as Atlas and prepare release $ARGUMENTS.

1. Ned checks CI is green on `develop` and lists what changed since the last tag.
2. Gita opens a PR `develop` -> `main` titled `release: $ARGUMENTS`, body of 3 to 5 lines (highlights, risks).
3. Stop. The user approves and merges (merge commit, not squash). Tagging happens after the merge, only on the user's order.
