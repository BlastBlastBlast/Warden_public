#!/usr/bin/env bash
# REQ-3.6. The installer archives the whole configuration directory first.
. "$(dirname "$0")/lib/harness.sh"
harness_setup

# Seed a configuration directory that looks used.
mkdir -p "$HOME/.claude/projects/some-project" "$HOME/.claude/agents"
printf '{"theme":"dark"}\n' > "$HOME/.claude/settings.json"
printf 'my notes\n' > "$HOME/.claude/agents/notes.md"
ln -s /etc/hosts "$HOME/.claude/a-link"
printf 'big cache\n' > "$HOME/.claude/projects/some-project/history.jsonl"

out=$("$REPO_DIR/install.sh" --skip-deps 2>&1)

archive=$(printf '%s\n' "$out" | sed -n 's/^archive: //p' | tail -1)
if [ -z "$archive" ]; then
  fail "the installer printed no archive path"
  harness_exit
fi
pass "the installer printed an archive path"
assert_file "$archive"

listing=$(tar tzf "$archive")

case "$listing" in
  *"agents/notes.md"*) pass "the archive holds agents/notes.md" ;;
  *) fail "the archive is missing agents/notes.md" ;;
esac

case "$listing" in
  *"settings.json"*) pass "the archive holds the old settings.json" ;;
  *) fail "the archive is missing settings.json" ;;
esac

# REQ-3.6.2
case "$listing" in
  *"projects/"*) fail "the archive holds the excluded projects directory" ;;
  *) pass "the archive excludes projects/" ;;
esac

# REQ-3.6.3: a link is stored as a link, not as the file it points at.
restore="$HARNESS_TMP/restore"
mkdir -p "$restore"
tar xzf "$archive" -C "$restore"
if [ -L "$restore/.claude/a-link" ]; then
  pass "the archive stores a symbolic link as a link"
else
  fail "the archive followed a symbolic link"
fi

# REQ-3.6.1: the archive sits outside the configuration directory.
case "$archive" in
  "$HOME/.warden-backups/"*) pass "the archive sits in ~/.warden-backups" ;;
  *) fail "the archive is at $archive" ;;
esac

harness_exit
