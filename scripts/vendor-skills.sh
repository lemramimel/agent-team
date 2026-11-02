#!/usr/bin/env bash
# Third-party skills copied into this plugin (see THIRD_PARTY.md), pinned by commit in vendor/skills.lock.
#   vendor-skills.sh fetch [--force]   copy the locked markdown files (skips skills already present, which may be adapted)
#   vendor-skills.sh status            list upstream changes since the locked commits, for the files we use
# Only markdown is copied; upstream scripts are never fetched.
set -u
cd "$(dirname "$0")/.." || exit 1
LOCK=vendor/skills.lock
cmd=${1:-}; force=${2:-}
case "$cmd" in
  fetch)
    grep -v '^#' "$LOCK" | while IFS=$'\t' read -r name repo sha dir files; do
      if [ -d "skills/$name" ] && [ "$force" != "--force" ]; then echo "skip $name (present)"; continue; fi
      mkdir -p "skills/$name"
      for f in $files; do
        gh api -H "Accept: application/vnd.github.raw" "repos/$repo/contents/$dir/$f?ref=$sha" > "skills/$name/$f" 2>/dev/null \
          && echo "ok   $name/$f" || { echo "FAIL $name/$f" >&2; rm -f "skills/$name/$f"; }
      done
    done ;;
  status)
    grep -v '^#' "$LOCK" | while IFS=$'\t' read -r name repo sha dir files; do
      changed=$(gh api "repos/$repo/compare/$sha...HEAD" --jq '.files[].filename' 2>/dev/null | grep -F "$dir/" | tr '\n' ' ')
      [ -n "$changed" ] && echo "$name: upstream changed: $changed" || echo "$name: unchanged upstream"
    done ;;
  *) echo "usage: vendor-skills.sh fetch [--force] | status" >&2; exit 1 ;;
esac
