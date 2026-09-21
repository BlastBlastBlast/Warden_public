#!/usr/bin/env bash
# REQ-4.1 to REQ-4.4. The uninstaller removes only its own links.
. "$(dirname "$0")/lib/harness.sh"
harness_setup

printf '{"theme":"dark"}\n' > "$HOME/.claude/settings.json"
original=$(cat "$HOME/.claude/settings.json")

"$REPO_DIR/install.sh" --skip-deps >/dev/null 2>&1

# Replace links at surface paths with foreign content to test the guard clause
# skills: regular file (exercises the [ -L "$link" ] check)
rm -f "$HOME/.claude/skills"
printf 'my-skills\n' > "$HOME/.claude/skills"

# hooks: external symlink (exercises the case "$target" in "$REPO"/*)
rm -f "$HOME/.claude/hooks"
mkdir -p "$HARNESS_TMP/external-hooks"
ln -sf "$HARNESS_TMP/external-hooks" "$HOME/.claude/hooks"

out=$("$REPO_DIR/uninstall.sh" 2>&1)

# REQ-4.2
if [ -f "$HOME/.claude/settings.json" ] \
   && [ ! -L "$HOME/.claude/settings.json" ] \
   && [ "$(cat "$HOME/.claude/settings.json")" = "$original" ]; then
  pass "the original settings.json returned byte for byte"
else
  fail "the original settings.json did not return"
fi

# REQ-4.1: a regular file at a surface path survives (not a link)
if [ -f "$HOME/.claude/skills" ] \
   && [ ! -L "$HOME/.claude/skills" ] \
   && [ "$(cat "$HOME/.claude/skills")" = "my-skills" ]; then
  pass "a regular file at a surface path survives"
else
  fail "the uninstaller removed a regular file"
fi

# REQ-4.3: a link pointing outside the repository survives
if [ -L "$HOME/.claude/hooks" ] \
   && [ "$(readlink "$HOME/.claude/hooks")" = "$HARNESS_TMP/external-hooks" ]; then
  pass "a link that points outside the repository survives"
else
  fail "the uninstaller removed a link pointing elsewhere"
fi

assert_absent "$HOME/.claude/CLAUDE.md"
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
