#!/usr/bin/env bash
# REQ-8. The README describes every part of the setup.
. "$(dirname "$0")/lib/harness.sh"

R=$(cat "$REPO_DIR/README.md")

for h in "## Install" "## What the installer does to your computer" "## Reverting" \
         "## Layout" "## Wired hooks" "## Skills" "## Status line" \
         "## Tools this setup draws on" "## Licence"; do
  assert_contains "$R" "$h"
done

# REQ-8.7. The image is above the first heading.
first_image_line=$(grep -n 'assets/warden.png' "$REPO_DIR/README.md" | head -1 | cut -d: -f1)
first_heading_line=$(grep -n '^# ' "$REPO_DIR/README.md" | head -1 | cut -d: -f1)
if [ -n "$first_image_line" ] && [ "$first_image_line" -lt "$first_heading_line" ]; then
  pass "the image sits above the first heading"
else
  fail "the image is not above the first heading"
fi
if grep -q 'alt="A knight' "$REPO_DIR/README.md"; then
  pass "the image has alt text"
else
  fail "the image has no alt text"
fi

# REQ-8.4. All ten tools are listed.
for t in obra/superpowers github/spec-kit danyuchn/asd-ste100-skill \
         cathrynlavery/diagram-design Graphify-Labs/graphify stablyai/orca \
         manaflow-ai/cmux stigsb/claude-context-monitor firecrawl/pdf-inspector \
         anthropics/claude-plugins-community; do
  assert_contains "$R" "$t"
done

# REQ-8.5
assert_contains "$R" "Windows is not supported"

# REQ-8.8
assert_contains "$R" "--from-archive"
assert_contains "$R" ".warden-backups"

# The skill table names every directory under skills/.
for d in "$REPO_DIR"/skills/*/; do
  s=$(basename "$d")
  assert_contains "$R" "\`$s\`"
done

harness_exit
