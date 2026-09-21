#!/usr/bin/env bash
# REQ-3.2, REQ-3.3, REQ-3.4. A second run is a no-op.
. "$(dirname "$0")/lib/harness.sh"
harness_setup

first=$("$REPO_DIR/install.sh" --skip-deps --skip-plugin-hook 2>&1)
assert_contains "$first" "summary: 10 linked, 0 kept, 0 backed up"

before=$(ls -1 "$HOME/.claude" | wc -l | tr -d ' ')

second=$("$REPO_DIR/install.sh" --skip-deps --skip-plugin-hook 2>&1)
assert_contains "$second" "summary: 0 linked, 10 kept, 0 backed up"

after=$(ls -1 "$HOME/.claude" | wc -l | tr -d ' ')
if [ "$before" = "$after" ]; then
  pass "the second run added no entry to the configuration directory"
else
  fail "the second run changed the entry count from $before to $after"
fi

extra=$(ls "$HOME/.claude/"*.warden-backup-* 2>/dev/null | wc -l | tr -d ' ')
if [ "$extra" = "0" ]; then
  pass "the second run took no backup"
else
  fail "the second run took $extra backups"
fi

harness_exit
