#!/usr/bin/env bash
# PreToolUse hook. Refuses a file edit while HEAD is the repository's default branch.
# Install: ~/.claude/hooks/guard-default-branch.sh  (chmod +x)
# Bypass for one session: CLAUDE_ALLOW_DEFAULT_BRANCH=1 claude
#
# Exit 0 = allow. Exit 2 = block, and stderr becomes the reason Claude reads.

set -uo pipefail

[ "${CLAUDE_ALLOW_DEFAULT_BRANCH:-0}" = "1" ] && exit 0

input=$(cat)
if command -v jq >/dev/null 2>&1; then
  cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)
  [ -n "${cwd:-}" ] && cd "$cwd" 2>/dev/null
  # The edited file's repository decides, not the session's. Walk up to the nearest existing
  # directory, because a Write can target a file in a directory that does not exist yet.
  target=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' 2>/dev/null)
  if [ -n "${target:-}" ]; then
    dir=$(dirname "$target")
    while [ ! -d "$dir" ] && [ "$dir" != "/" ] && [ "$dir" != "." ]; do dir=$(dirname "$dir"); done
    cd "$dir" 2>/dev/null
  fi
fi

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) || exit 0
[ -n "$branch" ] || exit 0

# The default branch is whatever origin/HEAD points at. Fall back to the usual names.
default=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
default=${default#origin/}
if [ -z "$default" ]; then
  for candidate in main master trunk; do
    if git show-ref --verify --quiet "refs/heads/$candidate"; then
      default=$candidate
      break
    fi
  done
fi

[ -n "$default" ] || exit 0
[ "$branch" = "$default" ] || exit 0

cat >&2 <<MSG
Blocked: you are on "$branch", the default branch. Branch before you edit.

  git switch -c <feature|fix|refactor|chore>/<kebab-case-slug>

Then repeat the edit. The user can bypass with CLAUDE_ALLOW_DEFAULT_BRANCH=1.
MSG
exit 2
