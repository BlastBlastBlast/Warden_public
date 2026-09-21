#!/usr/bin/env bash
# Every test sources this. It gives each test its own HOME and its own PATH.

TESTS_DIR=$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
REPO_DIR=$(cd -P "$TESTS_DIR/.." && pwd)

FAILURES=0

harness_setup() {
  HARNESS_TMP=$(mktemp -d "${TMPDIR:-/tmp}/warden-test.XXXXXX")
  export HOME="$HARNESS_TMP/home"
  mkdir -p "$HOME/.claude"
  export WARDEN_STUB_LOG="$HARNESS_TMP/stub.log"
  : > "$WARDEN_STUB_LOG"
  export PATH="$TESTS_DIR/stubs:$PATH"
  unset CLAUDE_CONFIG_DIR
}

harness_teardown() {
  [ -n "${HARNESS_TMP:-}" ] && rm -rf "$HARNESS_TMP"
}

fail() {
  printf '  FAIL %s\n' "$*"
  FAILURES=$((FAILURES + 1))
}

pass() {
  printf '  ok   %s\n' "$*"
}

assert_link() {
  local link="$1" target="$2"
  if [ -L "$link" ] && [ "$(readlink "$link")" = "$target" ]; then
    pass "$link -> $target"
  else
    fail "$link should link to $target, found '$(readlink "$link" 2>/dev/null)'"
  fi
}

assert_file() {
  [ -f "$1" ] && pass "file $1 exists" || fail "file $1 is missing"
}

assert_absent() {
  [ -e "$1" ] && fail "$1 should not exist" || pass "$1 is absent"
}

assert_contains() {
  local haystack="$1" needle="$2"
  case "$haystack" in
    *"$needle"*) pass "output holds '$needle'" ;;
    *) fail "output does not hold '$needle'" ;;
  esac
}

harness_exit() {
  harness_teardown
  [ "$FAILURES" -eq 0 ] || exit 1
  exit 0
}
