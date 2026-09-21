#!/usr/bin/env bash
# REQ-4.5. A restore from the archive returns the configuration, not the history.
. "$(dirname "$0")/lib/harness.sh"
harness_setup

printf 'before\n' > "$HOME/.claude/settings.json"
printf 'keep me\n' > "$HOME/.claude/my-notes.md"
mkdir -p "$HOME/.claude/projects/p1"
printf 'transcript\n' > "$HOME/.claude/projects/p1/history.jsonl"

out=$("$REPO_DIR/install.sh" --skip-deps 2>&1)
archive=$(printf '%s\n' "$out" | sed -n 's/^archive: //p' | tail -1)

# Change something after the install, so the restore has work to do.
rm -f "$HOME/.claude/my-notes.md"

"$REPO_DIR/uninstall.sh" --from-archive "$archive" >/dev/null 2>&1

# REQ-4.5
if [ ! -L "$HOME/.claude/settings.json" ] \
   && [ "$(cat "$HOME/.claude/settings.json")" = "before" ]; then
  pass "the archived settings.json returned"
else
  fail "the archived settings.json did not return"
fi
assert_file "$HOME/.claude/my-notes.md"

# REQ-4.5.3. The excluded directory survives.
assert_file "$HOME/.claude/projects/p1/history.jsonl"

# REQ-4.5.2. The restore archived the current state first.
count=$(ls -1 "$HOME/.warden-backups" | wc -l | tr -d ' ')
if [ "$count" -ge 2 ]; then
  pass "the restore archived the current state first"
else
  fail "the restore took no archive, found $count"
fi

# REQ-4.5.1. With no path, the uninstaller lists the archives.
listing=$("$REPO_DIR/uninstall.sh" --from-archive 2>&1)
assert_contains "$listing" ".warden-backups/claude-"

harness_exit
