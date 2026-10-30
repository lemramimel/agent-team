#!/usr/bin/env bash
# Install the commit-msg and pre-push hooks into the current repository.
set -eu
root=$(git rev-parse --show-toplevel)
dir="$(cd "$(dirname "$0")" && pwd)"
install -m 0755 "$dir/commit-msg" "$root/.git/hooks/commit-msg"
install -m 0755 "$dir/pre-push" "$root/.git/hooks/pre-push"
echo "commit-msg and pre-push hooks installed in $root/.git/hooks"
