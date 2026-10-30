#!/usr/bin/env bash
# PreToolUse guard for Bash. Exit 2 = block (stderr is shown to the agent).
# Enforces: no AI attribution, short commit subjects, PR-only flow on main/develop,
# branch naming, release PR rules.
set -u

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)
[ -z "$cmd" ] && exit 0

PROTECTED='^(main|develop)$'
BRANCH_RE='^(feat|fix|refactor|chore|ci|build|docs|test|perf|hotfix)/[a-z0-9]+(-[a-z0-9]+)*$'

block() { echo "Blocked: $1" >&2; exit 2; }

has() { printf '%s' "$cmd" | grep -Eq "$1"; }

branch=""
[ -n "$cwd" ] && branch=$(git -C "$cwd" branch --show-current 2>/dev/null)

# --- 1. AI attribution and message length ---------------------------------
if has 'git +(commit|merge|tag)|gh +(pr|issue) +(create|edit|merge|comment)'; then
  if printf '%s' "$cmd" | grep -Eiq 'co-authored-by|claude-session|generated with|noreply@anthropic\.com|claude code'; then
    block "no AI attribution in commits or PRs (no Co-Authored-By, no 'Generated with', no Claude-Session). Rewrite the message without it."
  fi
fi

if has 'git +commit'; then
  subject=$(printf '%s' "$cmd" | sed -nE "s/.*(-m|--message)[ =]+[\"']([^\"'\\n]*).*/\2/p" | head -n1)
  if [ -n "$subject" ] && [ "${#subject}" -gt 72 ]; then
    block "commit subject is ${#subject} chars (max 72). Make it short."
  fi
fi

# --- 2. No local history writes on main / develop --------------------------
if has 'git +(commit|merge|rebase|cherry-pick|revert|am)( |$)'; then
  creates_branch=0
  has 'git +(checkout +-[bB]|switch +(-c|-C|--create))' && creates_branch=1
  if [ "$creates_branch" -eq 0 ] && printf '%s' "$branch" | grep -Eq "$PROTECTED"; then
    block "you are on '$branch'. Never commit or merge directly on main/develop. Create a branch (type/scope-description) and open a PR."
  fi
fi

# --- 3. No direct push to main / develop, no force push ---------------------
if has 'git +push'; then
  if has 'git +push[^;&|]*( --force( |$)| -f( |$)| --mirror| --all)'; then
    block "no force/mirror/all push. Use --force-with-lease on your own feature branch only."
  fi
  push_args=$(printf '%s' "$cmd" | sed -nE 's/.*git +push(.*)/\1/p' | head -n1)
  push_args=${push_args%%[;&|]*}
  read -ra words <<<"$push_args"
  pos=()
  for w in "${words[@]:-}"; do
    case "$w" in -*|"") ;; *) pos+=("$w") ;; esac
  done
  if [ "${#pos[@]}" -ge 2 ]; then
    dst=${pos[1]##*:}; dst=${dst#+}; dst=${dst#refs/heads/}
    [ "$dst" = "HEAD" ] && dst=$branch
    printf '%s' "$dst" | grep -Eq "$PROTECTED" && block "direct push to '$dst' is forbidden. Push a branch and open a PR."
    case "${pos[1]}" in :*) block "remote branch deletion is forbidden from the agent." ;; esac
  else
    printf '%s' "$branch" | grep -Eq "$PROTECTED" && block "direct push from '$branch' is forbidden. Work on a branch and open a PR."
  fi
fi

# --- 4. Branch naming --------------------------------------------------------
if has 'git +(checkout +-[bB]|switch +(-c|-C|--create))|git +worktree +add +-b'; then
  name=$(printf '%s' "$cmd" | sed -nE 's/.*(checkout +-[bB]|switch +(-c|-C|--create)|worktree +add +-b) +([^ ;&|]+).*/\3/p' | head -n1)
  if [ -n "$name" ] && ! printf '%s' "$name" | grep -Eq "$BRANCH_RE"; then
    block "branch '$name' does not match <type>/<scope>-<short-description> (lowercase, no accents). Types: feat fix refactor chore ci build docs test perf hotfix."
  fi
fi

# --- 5. PR targets ------------------------------------------------------------
if has 'gh +pr +create'; then
  base=$(printf '%s' "$cmd" | sed -nE 's/.*(--base|-B)[ =]+([^ ;&|]+).*/\2/p' | head -n1)
  head=$(printf '%s' "$cmd" | sed -nE 's/.*(--head|-H)[ =]+([^ ;&|]+).*/\2/p' | head -n1)
  [ -z "$head" ] && head=$branch
  if [ "$base" = "main" ] && ! printf '%s' "$head" | grep -Eq '^(develop|hotfix/.+)$'; then
    block "PRs into main come only from develop (release) or hotfix/*. Target develop instead."
  fi
  if printf '%s' "$head" | grep -Eq "$PROTECTED" && [ "$head" = "main" ]; then
    block "never open a PR from main."
  fi
fi

exit 0
