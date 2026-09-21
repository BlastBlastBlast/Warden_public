#!/usr/bin/env bash
# REQ-7. The vendored copy keeps its licence and states its provenance.
. "$(dirname "$0")/lib/harness.sh"

V="$REPO_DIR/plugins/superpowers"

assert_file "$V/LICENSE"
assert_file "$V/NOTICE.md"
assert_file "$V/.claude-plugin/plugin.json"
assert_file "$V/.claude-plugin/marketplace.json"
assert_absent "$V/.git"

# REQ-7.1
if grep -q 'Copyright (c) 2025 Jesse Vincent' "$V/LICENSE"; then
  pass "the licence names the copyright holder"
else
  fail "the licence lost its copyright line"
fi

# REQ-7.2
author=$(jq -r '.author.name' "$V/.claude-plugin/plugin.json")
if [ "$author" = "Jesse Vincent" ]; then
  pass "the plugin keeps its author"
else
  fail "the plugin author is '$author'"
fi

# REQ-7.3
name=$(jq -r '.name' "$V/.claude-plugin/plugin.json")
if [ "$name" = "superpowers" ]; then
  pass "the plugin keeps the name superpowers"
else
  fail "the plugin name is '$name'"
fi

market=$(jq -r '.name' "$V/.claude-plugin/marketplace.json")
if [ "$market" = "superpowers-dev" ]; then
  pass "the marketplace is superpowers-dev, which settings.json names"
else
  fail "the marketplace is '$market'"
fi

# REQ-7.4
notice=$(cat "$V/NOTICE.md")
assert_contains "$notice" "obra/superpowers"
assert_contains "$notice" "more_superpowers"
assert_contains "$notice" "Modified"

# The skills the setup depends on are present.
for s in brainstorming writing-specs writing-plans test-driven-development; do
  assert_file "$V/skills/$s/SKILL.md"
done

harness_exit
