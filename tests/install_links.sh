#!/usr/bin/env bash
# REQ-1.1, REQ-1.2, REQ-3.5. The dry run prints the plan and writes nothing.
. "$(dirname "$0")/lib/harness.sh"
harness_setup

out=$("$REPO_DIR/install.sh" --dry-run --skip-deps --skip-plugin-hook 2>&1)

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

# A real install, into a directory that already holds a settings.json.
printf '{"theme":"dark"}\n' > "$HOME/.claude/settings.json"
"$REPO_DIR/install.sh" --skip-deps --skip-plugin-hook >/dev/null 2>&1

assert_link "$HOME/.claude/CLAUDE.md" "$REPO_DIR/CLAUDE.md"
assert_link "$HOME/.claude/settings.json" "$REPO_DIR/settings.json"
assert_link "$HOME/.claude/hooks" "$REPO_DIR/hooks"
assert_link "$HOME/.claude/output-styles" "$REPO_DIR/output-styles"
assert_link "$HOME/.claude/rules" "$REPO_DIR/rules"
assert_link "$HOME/.claude/skills" "$REPO_DIR/skills"
assert_link "$HOME/.claude/bin" "$REPO_DIR/bin"
assert_link "$HOME/.claude/docs/references" "$REPO_DIR/docs/references"
assert_link "$HOME/.claude/docs/decisions" "$REPO_DIR/docs/decisions"
assert_link "$HOME/.local/bin/warden-handoff" "$REPO_DIR/bin/warden-handoff"

# REQ-3.1. The displaced file survives under its backup name.
kept=$(ls "$HOME/.claude/"settings.json.warden-backup-* 2>/dev/null | head -1)
if [ -n "$kept" ] && grep -q dark "$kept"; then
  pass "the displaced settings.json survives at $kept"
else
  fail "the displaced settings.json was lost"
fi

harness_exit
