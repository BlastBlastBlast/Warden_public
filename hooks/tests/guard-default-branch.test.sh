#!/usr/bin/env bash
# Tests for hooks/guard-default-branch.sh. Run: bash hooks/tests/guard-default-branch.test.sh
# Exit 0 when every case passes.

set -uo pipefail

guard="$(cd "$(dirname "$0")/.." && pwd)/guard-default-branch.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

git_q() { git "$@" >/dev/null 2>&1; }

# Fixture: a repo on main, a worktree of it on a feature branch, and a plain directory.
repo="$tmp/repo"
wt="$tmp/repo-wt"
plain="$tmp/plain"
mkdir -p "$repo" "$plain"
git_q -C "$repo" init -b main
git_q -C "$repo" -c user.email=t@t -c user.name=t commit --allow-empty -m init
git_q -C "$repo" worktree add -b feature/x "$wt" main
touch "$repo/a.txt" "$wt/a.txt" "$plain/a.txt"

fail=0
check() { # check <name> <expected-exit> <json> [env...]
  local name="$1" want="$2" json="$3"; shift 3
  local got
  printf '%s' "$json" | env "$@" "$guard" >/dev/null 2>&1
  got=$?
  if [ "$got" = "$want" ]; then
    printf 'PASS  %s\n' "$name"
  else
    printf 'FAIL  %s (want %s, got %s)\n' "$name" "$want" "$got"
    fail=1
  fi
}

payload() { # payload <cwd> <tool> <key> <path>
  jq -nc --arg c "$1" --arg t "$2" --arg k "$3" --arg p "$4" \
    '{cwd:$c, tool_name:$t, tool_input:{($k):$p}}'
}

check "edit on main is blocked"                 2 "$(payload "$repo" Edit file_path "$repo/a.txt")"
check "edit on a branch is allowed"             0 "$(payload "$wt" Edit file_path "$wt/a.txt")"
check "new file in a new dir on main is blocked" 2 "$(payload "$repo" Write file_path "$repo/new/dir/b.txt")"
check "notebook on main is blocked"             2 "$(payload "$repo" NotebookEdit notebook_path "$repo/n.ipynb")"
check "no file path falls back to cwd"          2 "{\"cwd\":\"$repo\",\"tool_input\":{}}"
check "bypass variable allows"                  0 "$(payload "$repo" Edit file_path "$repo/a.txt")" CLAUDE_ALLOW_DEFAULT_BRANCH=1

# The file's repository decides, not the session's working directory.
check "file outside any repo, cwd on main"      0 "$(payload "$repo" Edit file_path "$plain/a.txt")"
check "file in branch worktree, cwd on main"    0 "$(payload "$repo" Edit file_path "$wt/a.txt")"
check "file on main, cwd in branch worktree"    2 "$(payload "$wt" Edit file_path "$repo/a.txt")"

exit "$fail"
