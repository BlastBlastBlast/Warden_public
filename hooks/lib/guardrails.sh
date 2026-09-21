#!/bin/bash
# Shared helpers for the build-stage guardrail hooks.
# Source this, do not execute it.

# Print the project's guardrails config path, or nothing when it does not exist.
guardrails_config() {
  local dir="${CLAUDE_PROJECT_DIR:-$PWD}"
  [ -f "$dir/.claude/guardrails.json" ] && printf '%s' "$dir/.claude/guardrails.json"
}

# guardrails_globs <key> — print one glob per line from the config, or nothing.
guardrails_globs() {
  local cfg
  cfg=$(guardrails_config) || return 0
  [ -n "$cfg" ] || return 0
  jq -r --arg k "$1" '.[$k] // [] | .[]' "$cfg" 2>/dev/null
}

# path_matches_glob <path> <glob>
# Bash extglob cannot express "**", so translate the glob to a regex.
path_matches_glob() {
  local path="$1" glob="$2" rx
  rx=$(printf '%s' "$glob" | python3 -c '
import re, sys
g = sys.stdin.read().strip()
out, i = "", 0
while i < len(g):
    c = g[i]
    if g.startswith("**/", i):
        out += "(?:.*/)?"; i += 3
    elif g.startswith("**", i):
        out += ".*"; i += 2
    elif c == "*":
        out += "[^/]*"; i += 1
    elif c == "?":
        out += "[^/]"; i += 1
    else:
        out += re.escape(c); i += 1
    continue
print(out)
')
  [ -n "$rx" ] || return 1
  printf '%s' "$path" | grep -Eq "(^|/)${rx}$"
}

# Print the relative path of a file inside the project, or the path unchanged.
guardrails_relpath() {
  local dir="${CLAUDE_PROJECT_DIR:-$PWD}" p="$1"
  printf '%s' "${p#"$dir"/}"
}

# Emit a PreToolUse decision and exit 0. Claude Code reads the JSON on stdout.
guardrails_decide() {
  jq -nc --arg d "$1" --arg r "$2" \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:$d,permissionDecisionReason:$r}}'
  exit 0
}
