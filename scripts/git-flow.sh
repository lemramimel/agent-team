#!/usr/bin/env bash
# Deterministic git and PR operations with the team's rules built in. Costs no model tokens.
# Usage:
#   git-flow.sh branch <type/scope-description> [base]
#   git-flow.sh commit "<subject>" <path>...
#   git-flow.sh pr --title "<title>" --body-file <file> [--base <base>]
#   git-flow.sh merge <pr-number> --subject "<subject>"
#   git-flow.sh cleanup [branch]
#   git-flow.sh status
# Output is deliberately short.
set -u

BRANCH_RE='^(feat|fix|refactor|chore|ci|build|docs|test|perf|hotfix)/[a-z0-9]+(-[a-z0-9]+)*$'
ATTR_RE='co-authored-by|claude-session|generated with|noreply@anthropic\.com|🤖'
PROTECTED_RE='^(main|develop)$'

die() { echo "git-flow: $*" >&2; exit 1; }
cur() { git branch --show-current; }
has_attr() { printf '%s' "$1" | grep -Eiq "$ATTR_RE"; }

default_base() {
  if git show-ref --verify --quiet refs/remotes/origin/develop; then echo develop
  else git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##' || echo main
  fi
}

cmd_branch() {
  local name=${1:-}; local base=${2:-$(default_base)}
  [ -n "$name" ] || die "usage: branch <type/scope-description> [base]"
  printf '%s' "$name" | grep -Eq "$BRANCH_RE" || die "branch '$name' must match <type>/<scope>-<description> (lowercase, no accents; types: feat fix refactor chore ci build docs test perf hotfix)"
  git fetch -q origin || die "fetch failed"
  if [ "$(cur)" = "$base" ]; then
    git switch -q -c "$name" || die "cannot create $name"
  else
    git switch -q -c "$name" "origin/$base" || die "cannot create $name from origin/$base"
  fi
  git branch --unset-upstream 2>/dev/null || true
  echo "branch: $name (from $base)"
}

cmd_commit() {
  local subject=${1:-}; shift || true
  [ -n "$subject" ] && [ $# -gt 0 ] || die "usage: commit \"<subject>\" <path>..."
  printf '%s' "$(cur)" | grep -Eq "$PROTECTED_RE" && die "on '$(cur)': never commit on main or develop"
  [ "${#subject}" -le 72 ] || die "subject is ${#subject} chars (max 72)"
  has_attr "$subject" && die "no AI attribution in a commit message"
  local p
  for p in "$@"; do
    case "$p" in .|-A|--all|-a|'*') die "stage explicit paths only (got '$p')" ;; esac
  done
  git add -- "$@" || die "git add failed"
  git diff --cached --quiet && die "nothing staged for the given paths"
  git commit -q -m "$subject" || die "commit failed (hook?)"
  local left; left=$(git status --short | wc -l)
  echo "commit: $(git rev-parse --short HEAD) $subject | uncommitted left: $left"
}

cmd_pr() {
  local title="" body="" base=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --title) title=$2; shift ;;
      --body-file) body=$2; shift ;;
      --base) base=$2; shift ;;
      *) die "unknown option: $1" ;;
    esac; shift
  done
  [ -n "$title" ] && [ -f "$body" ] || die "usage: pr --title \"...\" --body-file <file> [--base <base>]"
  local b; b=$(cur)
  printf '%s' "$b" | grep -Eq "$PROTECTED_RE" && die "on '$b': open PRs from a feature branch"
  printf '%s' "$b" | grep -Eq "$BRANCH_RE" || die "branch '$b' does not follow the naming rule"
  has_attr "$title" && die "no AI attribution in the PR title"
  has_attr "$(cat "$body")" && die "no AI attribution in the PR body"
  [ "$(grep -c '^## ' "$body")" -ge 3 ] || die "PR body needs at least 3 '## ' sections (Contexte, Changements, Vérification, Limites)"
  [ -n "$base" ] || base=$(default_base)
  if [ "$base" = main ]; then
    printf '%s' "$b" | grep -Eq '^(hotfix/.+)$' || [ "$b" = develop ] || die "PRs into main come only from develop or hotfix/*"
  fi
  git push -q -u origin "$b" 2>&1 | grep -v '^remote:' >&2
  [ "${PIPESTATUS[0]}" -eq 0 ] || die "push failed"
  local url; url=$(gh pr create --base "$base" --head "$b" --title "$title" --body-file "$body") || die "gh pr create failed"
  echo "pr: $url"
}

cmd_merge() {
  local n=${1:-}; shift || true
  local subject=""
  while [ $# -gt 0 ]; do
    case "$1" in --subject) subject=$2; shift ;; *) die "unknown option: $1" ;; esac; shift
  done
  [ -n "$n" ] && [ -n "$subject" ] || die "usage: merge <pr-number> --subject \"<subject>\""
  has_attr "$subject" && die "no AI attribution in the merge message"
  local info state mergeable base head
  info=$(gh pr view "$n" --json state,mergeable,baseRefName,headRefName -q '.state+" "+.mergeable+" "+.baseRefName+" "+.headRefName') || die "cannot read PR #$n"
  read -r state mergeable base head <<<"$info"
  [ "$state" = OPEN ] || die "PR #$n is $state, not OPEN"
  [ "$mergeable" = MERGEABLE ] || die "PR #$n is $mergeable"
  local checks rc
  checks=$(gh pr checks "$n" 2>&1); rc=$?
  if [ $rc -ne 0 ] && ! printf '%s' "$checks" | grep -qi 'no checks reported'; then
    die "CI is not green on PR #$n:
$checks"
  fi
  gh pr merge "$n" --squash --subject "$subject" --body "" >/dev/null || die "merge failed"
  local i st=""
  for i in 1 2 3 4 5 6; do
    st=$(gh pr view "$n" --json state -q .state); [ "$st" = MERGED ] && break; sleep 3
  done
  [ "$st" = MERGED ] || die "PR #$n not MERGED after merge ($st)"
  git fetch -q origin
  local msg attrib gone
  msg=$(git log -1 --format=%B "origin/$base")
  attrib=$(printf '%s' "$msg" | grep -Eic "$ATTR_RE|claude|anthropic")
  gone=$(git ls-remote --heads origin "$head" | wc -l)
  echo "merged: #$n -> $base | subject: $(git log -1 --format=%s "origin/$base") | body empty: $([ -z "$(git log -1 --format=%b "origin/$base")" ] && echo yes || echo NO) | attribution hits: $attrib | remote branch deleted: $([ "$gone" -eq 0 ] && echo yes || echo NO)"
}

cmd_cleanup() {
  local b=${1:-$(cur)}; local base; base=$(default_base)
  [ -n "$b" ] || die "no branch given"
  printf '%s' "$b" | grep -Eq "$PROTECTED_RE" && die "refusing to clean '$b'"
  local merged; merged=$(gh pr list --head "$b" --state merged --json number -q length 2>/dev/null)
  [ "${merged:-0}" -ge 1 ] || die "no merged PR for '$b': not deleting it"
  local wt
  wt=$(git worktree list --porcelain | awk -v b="refs/heads/$b" '/^worktree /{p=$2} $1=="branch" && $2==b {print p}')
  if [ -n "$wt" ] && [ "$wt" != "$(git rev-parse --show-toplevel)" ]; then
    git worktree remove "$wt" || die "worktree $wt has changes: not removing"
  fi
  git switch -q "$base" || die "cannot switch to $base"
  git pull -q --ff-only || die "pull --ff-only failed"
  git branch -D "$b" >/dev/null 2>&1
  git fetch -q origin --prune
  echo "cleanup: on $base $(git rev-parse --short HEAD) | local branches: $(git branch --list | tr -d ' *' | tr '\n' ' ')| dirty: $(git status --short | wc -l) | == origin: $([ "$(git rev-parse "$base")" = "$(git rev-parse "origin/$base")" ] && echo yes || echo NO)"
}

cmd_status() {
  echo "branch: $(cur) | dirty: $(git status --short | wc -l) | worktrees: $(git worktree list | wc -l) | local: $(git branch --list | tr -d ' *' | tr '\n' ' ')"
}

sub=${1:-}; shift || true
case "$sub" in
  branch) cmd_branch "$@" ;;
  commit) cmd_commit "$@" ;;
  pr) cmd_pr "$@" ;;
  merge) cmd_merge "$@" ;;
  cleanup) cmd_cleanup "$@" ;;
  status) cmd_status ;;
  *) die "usage: git-flow.sh branch|commit|pr|merge|cleanup|status" ;;
esac
