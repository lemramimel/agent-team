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
if [ "$n" -ge "$min_files" ] || [ "$l" -ge "$min_lines" ]; then
  state=ready
  [ "$built" = yes ] && msg="graph already built: use \`graphify query\`, keep it current with \`graphify update .\`" || msg="not built yet: propose enabling graphify to the user once"
else
  state=dormant; msg="below the thresholds: do not use graphify yet"
fi
echo "graphify: $state | $n source files, $l lines (thresholds: $min_files files or $min_lines lines) | built: $built | $msg"
