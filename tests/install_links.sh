#!/usr/bin/env bash
# REQ-1.1, REQ-1.2, REQ-3.5. The dry run prints the plan and writes nothing.
. "$(dirname "$0")/lib/harness.sh"
harness_setup

out=$("$REPO_DIR/install.sh" --dry-run --skip-deps 2>&1)

assert_contains "$out" "would link: $HOME/.claude/CLAUDE.md -> $REPO_DIR/CLAUDE.md"
assert_contains "$out" "would link: $HOME/.claude/settings.json -> $REPO_DIR/settings.json"
assert_contains "$out" "would link: $HOME/.claude/skills -> $REPO_DIR/skills"
assert_contains "$out" "would link: $HOME/.claude/docs/references -> $REPO_DIR/docs/references"
assert_contains "$out" "would link: $HOME/.local/bin/warden-handoff -> $REPO_DIR/bin/warden-handoff"

assert_absent "$HOME/.claude/CLAUDE.md"
assert_absent "$HOME/.local/bin"

# REQ-1.5. The change records are not a surface.
case "$out" in
  *"docs/superpowers"*) fail "the dry run offers to link docs/superpowers" ;;
  *) pass "docs/superpowers is not linked" ;;
esac

harness_exit
