#!/usr/bin/env bash
# REQ-4.5. A restore from the archive returns the configuration, not the history.
. "$(dirname "$0")/lib/harness.sh"
harness_setup

printf 'before\n' > "$HOME/.claude/settings.json"
printf 'keep me\n' > "$HOME/.claude/my-notes.md"
mkdir -p "$HOME/.claude/projects/p1"
printf 'transcript\n' > "$HOME/.claude/projects/p1/history.jsonl"

out=$("$REPO_DIR/install.sh" --skip-deps --skip-plugin-hook 2>&1)
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

checksum_of() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    sha256sum "$1" | awk '{print $1}'
  fi
}

# F18 regression. --dry-run writes nothing: not a new archive, not a
# changed one, not a real restore.
harness_teardown
harness_setup

printf 'before\n' > "$HOME/.claude/settings.json"
printf 'dry run should not touch this\n' > "$HOME/.claude/dryrun-marker.txt"

out=$("$REPO_DIR/install.sh" --skip-deps --skip-plugin-hook 2>&1)
archive=$(printf '%s\n' "$out" | sed -n 's/^archive: //p' | tail -1)

before_count=$(ls -1 "$HOME/.warden-backups" | wc -l | tr -d ' ')
before_sum=$(checksum_of "$archive")

"$REPO_DIR/uninstall.sh" --dry-run --from-archive "$archive" >/dev/null 2>&1

after_count=$(ls -1 "$HOME/.warden-backups" | wc -l | tr -d ' ')
after_sum=$(checksum_of "$archive")

if [ "$before_count" = "$after_count" ]; then
  pass "dry-run left the archive directory file count at $after_count"
else
  fail "dry-run changed the archive directory file count: $before_count -> $after_count"
fi

if [ "$before_sum" = "$after_sum" ]; then
  pass "dry-run left the archive checksum unchanged"
else
  fail "dry-run changed the archive checksum"
fi

# A real restore would have removed this (not a surface, not excluded).
assert_file "$HOME/.claude/dryrun-marker.txt"

# F17 regression. A safety archive that fails to write must stop the
# restore before anything is deleted.
harness_teardown
harness_setup

printf 'before\n' > "$HOME/.claude/settings.json"
mkdir -p "$HOME/.claude/projects/p1"
printf 'transcript\n' > "$HOME/.claude/projects/p1/history.jsonl"

out=$("$REPO_DIR/install.sh" --skip-deps --skip-plugin-hook 2>&1)
archive=$(printf '%s\n' "$out" | sed -n 's/^archive: //p' | tail -1)

# Something the deletion loop would remove, so a wrongly-continued restore
# is visible.
printf 'still here\n' > "$HOME/.claude/should-survive-a-failed-restore.txt"

if [ "$(id -u)" = "0" ]; then
  pass "skipped under root: chmod cannot force an archive failure"
else
  chmod 555 "$HOME/.warden-backups"
  out=$("$REPO_DIR/uninstall.sh" --from-archive "$archive" 2>&1)
  rc=$?
  # Put the permission back before any assertion can fail and skip past it,
  # and long before harness_teardown's rm -rf runs.
  chmod 755 "$HOME/.warden-backups"

  if [ "$rc" -ne 0 ]; then
    pass "the restore exited non-zero when the safety archive failed"
  else
    fail "the restore exited 0 when the safety archive failed"
  fi

  # Assert the message, not just the exit code: uninstall.sh has other
  # non-zero paths ("no such archive", "unknown option"), and a bare
  # rc-ne-0 check would pass even if a different guard fired instead.
  assert_contains "$out" "could not archive"
  assert_contains "$out" "before restoring"

  assert_file "$HOME/.claude/should-survive-a-failed-restore.txt"
  if [ -L "$HOME/.claude/settings.json" ]; then
    pass "the settings.json link survived the failed restore"
  else
    fail "the settings.json link did not survive the failed restore"
  fi
fi

harness_exit
