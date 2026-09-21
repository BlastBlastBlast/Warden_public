#!/usr/bin/env bash
# REQ-4.1 to REQ-4.4. The uninstaller removes only its own links.
. "$(dirname "$0")/lib/harness.sh"
harness_setup

printf '{"theme":"dark"}\n' > "$HOME/.claude/settings.json"
original=$(cat "$HOME/.claude/settings.json")
printf 'mine\n' > "$HOME/.claude/my-notes.md"
mkdir -p "$HARNESS_TMP/elsewhere"
ln -s "$HARNESS_TMP/elsewhere" "$HOME/.claude/agents"

"$REPO_DIR/install.sh" --skip-deps >/dev/null 2>&1
out=$("$REPO_DIR/uninstall.sh" 2>&1)

# REQ-4.2
if [ -f "$HOME/.claude/settings.json" ] \
   && [ ! -L "$HOME/.claude/settings.json" ] \
   && [ "$(cat "$HOME/.claude/settings.json")" = "$original" ]; then
  pass "the original settings.json returned byte for byte"
else
  fail "the original settings.json did not return"
fi

# REQ-4.1 and REQ-4.3
assert_file "$HOME/.claude/my-notes.md"
if [ -L "$HOME/.claude/agents" ]; then
  pass "a link that points elsewhere survives"
else
  fail "the uninstaller removed a link it did not create"
fi

assert_absent "$HOME/.claude/CLAUDE.md"
assert_absent "$HOME/.claude/skills"
assert_absent "$HOME/.local/bin/warden-handoff"

# REQ-4.4
assert_contains "$out" "claude plugin marketplace remove"
assert_contains "$out" "rm -f \$HOME/bin/claude-context-monitor"

# REQ-4.2 with two backups: the newest wins.
harness_teardown
harness_setup
printf 'old\n' > "$HOME/.claude/CLAUDE.md.warden-backup-20200101T000000Z"
printf 'new\n' > "$HOME/.claude/CLAUDE.md.warden-backup-20990101T000000Z"
ln -s "$REPO_DIR/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
"$REPO_DIR/uninstall.sh" >/dev/null 2>&1
if [ "$(cat "$HOME/.claude/CLAUDE.md")" = "new" ]; then
  pass "the newest backup wins"
else
  fail "the uninstaller restored the wrong backup"
fi

harness_exit
