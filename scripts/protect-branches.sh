#!/usr/bin/env bash
# Server-side protection for main and develop: PR required, no force push,
# no deletion, applies to admins too. Usage: protect-branches.sh [owner/repo]
set -eu
repo=${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}

for b in main develop; do
  gh api -X PUT "repos/$repo/branches/$b/protection" --input - >/dev/null <<'JSON'
{
  "required_status_checks": null,
  "enforce_admins": true,
  "required_pull_request_reviews": { "required_approving_review_count": 0 },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
JSON
  echo "protected: $repo@$b"
done

# Feature branches are deleted after merge.
gh api -X PATCH "repos/$repo" -F delete_branch_on_merge=true >/dev/null
