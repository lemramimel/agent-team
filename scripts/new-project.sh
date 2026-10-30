#!/usr/bin/env bash
# Bootstrap a project: GitHub repo with main (production) and develop (default),
# both protected, hooks installed. This is the only sanctioned direct push to main.
# Usage: new-project.sh <name> [--public|--private] [--dir <parent-dir>]
set -eu

name=${1:?usage: new-project.sh <name> [--public|--private] [--dir <parent>]}
shift
visibility=--private
parent=$PWD
while [ $# -gt 0 ]; do
  case "$1" in
    --public|--private) visibility=$1 ;;
    --dir) parent=$2; shift ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

dir="$parent/$name"
[ -e "$dir" ] && { echo "$dir already exists" >&2; exit 1; }
here="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$dir" && cd "$dir"
git init -q -b main
printf '# %s\n' "$name" > README.md
git add README.md
git commit -q -m "chore: initialisation"

gh repo create "$name" "$visibility" --source . --remote origin --push >/dev/null
git switch -q -c develop
git push -q -u origin develop
gh repo edit --default-branch develop >/dev/null

"$here/protect-branches.sh"
"$here/install-git-hooks.sh"

echo "ready: $dir (main = production, develop = default). Work on <type>/<scope>-<description> branches and open PRs into develop."
