#!/usr/bin/env bash
# Validate team/tracker.json. Usage: check-tracker-config.sh [path]
set -u
file=${1:-team/tracker.json}
fail() { echo "tracker config: $1" >&2; exit 1; }

[ -f "$file" ] || fail "$file not found"
jq -e . "$file" >/dev/null 2>&1 || fail "not valid JSON"

adapter=$(jq -r '.adapter // empty' "$file")
case "$adapter" in
  linear|jira|clickup|github-issues|markdown|custom) ;;
  *) fail "adapter must be one of linear, jira, clickup, github-issues, markdown, custom (got '${adapter}')" ;;
esac

pattern=$(jq -r '.idPattern // empty' "$file")
if [ "$adapter" != "markdown" ]; then
  [ -n "$pattern" ] || fail "idPattern is required"
  printf '' | grep -Eq "$pattern" 2>/dev/null; [ $? -le 1 ] || fail "idPattern is not a valid regex"
fi

for s in backlog todo in_progress in_review done; do
  jq -e --arg s "$s" '.statuses[$s] | strings | length > 0' "$file" >/dev/null 2>&1 \
    || [ "$adapter" = "markdown" ] || fail "statuses.$s is missing"
done

if [ "$adapter" = "custom" ]; then
  for op in get create setStatus; do
    jq -e --arg o "$op" '.operations[$o] | strings | length > 0' "$file" >/dev/null 2>&1 \
      || fail "custom adapter needs operations.$op (search, update, comment, link, list are optional)"
  done
fi

echo "tracker config OK ($adapter)"
