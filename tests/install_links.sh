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

# I-1 regression. A dry run over an existing settings.json announces the
# rename. The old preview reimplemented the loop, so it printed "would link"
# and closed with a summary of zero: the single most alarming thing the
# installer does was invisible.
harness_teardown
harness_setup

printf '{"theme":"dark"}\n' > "$HOME/.claude/settings.json"
out=$("$REPO_DIR/install.sh" --dry-run --skip-deps --skip-plugin-hook 2>&1)

assert_contains "$out" \
  "would backup: $HOME/.claude/settings.json -> $HOME/.claude/settings.json.warden-backup-"
assert_contains "$out" "summary: would link 10, keep 0, back up 1"

# And it still writes nothing.
if [ ! -L "$HOME/.claude/settings.json" ] \
   && [ "$(cat "$HOME/.claude/settings.json")" = '{"theme":"dark"}' ]; then
  pass "the dry run left settings.json untouched"
else
  fail "the dry run touched settings.json"
fi
moved=$(ls "$HOME/.claude/"settings.json.warden-backup-* 2>/dev/null | wc -l | tr -d ' ')
if [ "$moved" = "0" ]; then
  pass "the dry run renamed nothing"
else
  fail "the dry run took $moved backups"
fi
assert_absent "$HOME/.claude/docs"
assert_absent "$HOME/.local/bin"
assert_absent "$HOME/.warden-backups"

harness_exit
