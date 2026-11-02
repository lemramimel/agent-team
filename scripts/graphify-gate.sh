#!/usr/bin/env bash
# Tells whether a project is big enough for graphify to be worth using. Costs no model tokens.
# Thresholds are a starting estimate, to calibrate by measurement (see docs/COMPANIONS.md).
# Usage: graphify-gate.sh [dir]   (env: GRAPHIFY_MIN_FILES=200, GRAPHIFY_MIN_LINES=20000)
set -u
dir=${1:-.}
min_files=${GRAPHIFY_MIN_FILES:-200}
min_lines=${GRAPHIFY_MIN_LINES:-20000}
cd "$dir" || { echo "graphify-gate: cannot enter $dir" >&2; exit 1; }
files=$(git ls-files 2>/dev/null | grep -E '\.(ts|tsx|js|jsx|mjs|py|go|rs|java|kt|rb|php|cs|css|scss|html|prisma|sql)$' | grep -vE 'package-lock|\.d\.ts$')
n=$(printf '%s\n' "$files" | grep -c .)
l=$(printf '%s\n' "$files" | xargs -r cat 2>/dev/null | wc -l)
built=no; [ -f graphify-out/graph.json ] && built=yes
decision=not-asked; [ -f team/methods.json ] && decision=$(jq -r '.graphify // "not-asked"' team/methods.json 2>/dev/null || echo not-asked)
if [ "$n" -ge "$min_files" ] || [ "$l" -ge "$min_lines" ]; then
  state=ready
  if [ "$built" = yes ]; then msg="graph already built: use \`graphify query\`, keep it current with \`graphify update .\`"
  else case "$decision" in
    declined) msg="not built; the user declined: do not propose it again" ;;
    enabled)  msg="not built yet; the user chose to enable it: build it with the graphify skill" ;;
    later)    msg="not built yet; the user said later: propose again once at most per mission" ;;
    *)        msg="not built yet: propose enabling graphify to the user once, then record the answer with methods-check.sh decide graphify enabled|declined|later" ;;
  esac; fi
else
  state=dormant; msg="below the thresholds: do not use graphify yet"
fi
echo "graphify: $state | $n source files, $l lines (thresholds: $min_files files or $min_lines lines) | built: $built | decision: $decision | $msg"
