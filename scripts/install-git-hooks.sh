#!/usr/bin/env bash
# Install the commit-msg hook into the current repository.
set -eu
root=$(git rev-parse --show-toplevel)
src="$(cd "$(dirname "$0")" && pwd)/commit-msg"
install -m 0755 "$src" "$root/.git/hooks/commit-msg"
echo "commit-msg hook installed in $root/.git/hooks"
