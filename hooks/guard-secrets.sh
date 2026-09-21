#!/bin/bash
# REQ-5. PreToolUse on Write|Edit: deny a write that carries a high-confidence secret shape.
# Three shapes only. A scanner that matches everything matches ordinary strings too.
set -uo pipefail
command -v jq >/dev/null 2>&1 || exit 0
source "$(dirname "${BASH_SOURCE[0]}")/lib/guardrails.sh"

payload=$(cat)
file=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty')

# REQ-5.3: a fixture carries fake credentials by design.
case "$file" in
  */tests/fixtures/*|*/test/fixtures/*|*/fixtures/*|*/testdata/*|*.example|*.example.*|*/examples/*|*.sample|*.sample.*)
    exit 0 ;;
esac

# Write sends content, Edit sends new_string.
content=$(printf '%s' "$payload" | jq -r '[.tool_input.content, .tool_input.new_string] | map(select(. != null)) | join("\n")')
[ -n "$content" ] || exit 0

shape=""
if printf '%s' "$content" | grep -Eq -- '-----BEGIN [A-Z ]*PRIVATE KEY-----'; then
  shape="a private key header"
elif printf '%s' "$content" | grep -Eq '\b(AKIA|ASIA)[0-9A-Z]{16}\b'; then
  shape="an AWS access key identifier"
elif printf '%s' "$content" | grep -Eiq 'bearer[[:space:]]+[A-Za-z0-9._~+/-]{32,}'; then
  shape="a bearer token of 32 characters or more"
fi

[ -n "$shape" ] || exit 0

# REQ-5.2: name the shape, never the value.
guardrails_decide deny \
"This write contains $shape. Credentials do not belong in the working tree.
Put the value in the environment or a secret store and reference it by name. If this is test data, move
the file under a fixtures or testdata directory, where this check does not apply."
