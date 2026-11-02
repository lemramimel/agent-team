#!/usr/bin/env bash
# Detects whether BMAD is usable in a project and remembers the user's answer. Costs no model tokens.
#   methods-check.sh [dir]                              one status line
#   methods-check.sh decide bmad <installed|declined|later> [dir]      remember the answer in team/methods.json
#   methods-check.sh decide graphify <enabled|declined|later> [dir]   same file, other key
# It never installs anything: installing a method is the user's decision and command.
set -u
if [ "${1:-}" = "decide" ]; then
  case "${2:-}:${3:-}" in
    bmad:installed|bmad:declined|bmad:later|graphify:enabled|graphify:declined|graphify:later) ;;
    *) echo "usage: methods-check.sh decide bmad installed|declined|later | decide graphify enabled|declined|later [dir]" >&2; exit 1 ;;
  esac
  dir=${4:-.}; mkdir -p "$dir/team"; f="$dir/team/methods.json"
  [ -f "$f" ] && jq empty "$f" 2>/dev/null || echo '{}' > "$f"
  jq --arg k "$2" --arg v "$3" --arg d "$(date +%F)" '.[$k] = $v | .decidedOn = $d' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  echo "methods: $2 decision recorded: $3"; exit 0
fi
dir=${1:-.}
cd "$dir" || { echo "methods-check: cannot enter $dir" >&2; exit 1; }
yn() { [ "$1" = 1 ] && echo yes || echo no; }
has_skill() { [ -e ".claude/skills/$1/SKILL.md" ] || [ -e ".agents/skills/$1/SKILL.md" ]; }
n=$(ls -d .claude/skills/bmad* .agents/skills/bmad* 2>/dev/null | xargs -r -n1 basename | sort -u | wc -l)
b=0; r=0; p=0
has_skill bmad-build && b=1; has_skill bmad-retrospective && r=1; has_skill bmad-prd && p=1
rt=0; [ -d _bmad/scripts ] && rt=1
uvok=0; command -v uv >/dev/null 2>&1 && uvok=1
decision=not-asked; [ -f team/methods.json ] && decision=$(jq -r '.bmad // "not-asked"' team/methods.json 2>/dev/null || echo not-asked)
if [ "$rt" = 1 ] && [ "$b" = 1 ]; then state=installed
elif [ "$n" -gt 0 ] && [ "$rt" = 0 ]; then state=broken
else state=absent; fi
case "$state:$decision" in
  installed:*) action="use bmad-build, bmad-retrospective, bmad-prd where docs/METHODS.md says so" ;;
  broken:*)    action="skills present but _bmad/ missing: tell the user to ask the bmad skill to run 'bmad setup'" ;;
  absent:declined) action="do not ask again; use the fallback skills" ;;
  absent:*)    action="propose BMAD once (see docs/METHODS.md), then record the answer with 'decide'" ;;
esac
echo "methods: bmad=$state ($n skills; build=$(yn $b) retro=$(yn $r) prd=$(yn $p); _bmad=$(yn $rt); uv=$(yn $uvok)) | decision=$decision | action: $action"
