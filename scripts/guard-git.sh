#!/usr/bin/env bash
# PreToolUse guard for Bash: blocks commit / PR commands that carry AI attribution
# or an overlong message. Exit 2 = block, stderr is shown to the agent.
set -u

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)
[ -z "$cmd" ] && exit 0

# Only inspect commands that write history or PR text.
printf '%s' "$cmd" | grep -Eq 'git +(commit|merge|tag)|gh +(pr|issue) +(create|edit|merge|comment)' || exit 0

if printf '%s' "$cmd" | grep -Eiq 'co-authored-by|claude-session|generated with|noreply@anthropic\.com|claude code'; then
  echo "Blocked: no AI attribution in commits or PRs (no Co-Authored-By, no 'Generated with', no Claude-Session). Rewrite the message without it." >&2
  exit 2
fi

# Best-effort length check on the first -m of a git commit (subject <= 72 chars).
if printf '%s' "$cmd" | grep -Eq 'git +commit'; then
  subject=$(printf '%s' "$cmd" | sed -nE "s/.*(-m|--message)[ =]+[\"']([^\"'\\n]*).*/\2/p" | head -n1)
  if [ -n "$subject" ] && [ "${#subject}" -gt 72 ]; then
    echo "Blocked: commit subject is ${#subject} chars (max 72). Make it short." >&2
    exit 2
  fi
fi

exit 0
