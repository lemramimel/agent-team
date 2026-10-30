#!/usr/bin/env bash
# Checks that skills and agents never contain instructions that break the team's rules.
# Exit 1 with the offending lines if anything is found. Usage: vendor-check.sh [dir...]  (default: skills agents)
set -u
cd "$(dirname "$0")/.." || exit 1
dirs=("$@"); [ ${#dirs[@]} -gt 0 ] || dirs=(skills agents)
bad=0
check() { # label, regex
  local out; out=$(grep -rnIE "$2" "${dirs[@]}" 2>/dev/null | grep -viE 'never|jamais|do not|don.t|forbidden|interdit|no AI|not allowed|must not|refuse|blocked|rule|règle')
  [ -n "$out" ] && { echo "== $1"; printf '%s\n' "$out" | head -n 12; bad=1; }
}
check "AI attribution"            'Co-Authored-By|Generated with|noreply@anthropic|🤖'
check "git add all"               'git add (\.|-A|--all)( |$)'
check "push to protected branch"  'git push[^|;&]*(origin )?(main|develop|master)\b'
check "force push / hard reset"   'git push[^|;&]*(--force|-f )|git reset --hard'
check "auto merge"                'gh pr merge'
check "remote script execution"   'curl[^|;&]*\|[^|;&]*(sh|bash)|wget[^|;&]*\|[^|;&]*(sh|bash)'
[ "$bad" -eq 0 ] && echo "vendor-check: clean ($(find "${dirs[@]}" -name '*.md' | wc -l) markdown files scanned)" || exit 1
