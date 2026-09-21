#!/bin/bash
# PreToolUse on Bash: deny a shell command that reads a secret or environment file.
#
# settings.json already denies these paths to the Read tool, and Claude Code extends some of
# those denials to Bash — but only for a known set of commands. Measured 2026-09-14 against
# 2.1.270: `cat .env` is blocked, `head -1 .env` returns the secret in plaintext. This hook
# closes that, and expresses the one thing a glob cannot — that `.env.example` and friends are
# documentation and stay readable.
#
# Listing a file is not reading it, and writing one is guard-secrets.sh's job. Only commands
# that put file contents in front of the model are matched, and only in the same |;& segment
# as the path, so a secret path named in an unrelated stage of a pipeline does not false-positive.
set -uo pipefail
command -v jq >/dev/null 2>&1 || exit 0
source "$(dirname "${BASH_SOURCE[0]}")/lib/guardrails.sh"

payload=$(cat)
cmd=$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0
[ -n "$cmd" ] || exit 0

# Commands that print, decode, or load file contents. Deliberately excludes ls/stat/file
# (metadata only), wc (counts only), and cp/mv/scp/rsync (moving a file does not reveal it,
# and `cp .env.example .env` is ordinary scaffolding).
READERS='cat|bat|head|tail|less|more|nl|tac|rev|od|xxd|hexdump|strings|base64|dd|tr|cut|paste|sed|awk|gawk|grep|egrep|fgrep|rg|ag|ack|jq|yq|source|python|python3|node|ruby|perl|php|openssl|gpg|ssh-keygen'

# Paths that hold credentials. Mirrors the Read deny list in settings.json.
SECRETS='(^|[^[:alnum:]_.-])\.env($|[^[:alnum:]_-])|\.env\.[[:alnum:]_.-]+|[^[:alnum:]_-]id_(rsa|dsa|ecdsa|ed25519)($|[^[:alnum:]_-])|\.(pem|p12|pfx)($|[^[:alnum:]_-])|[^[:alnum:]_-][^[:space:]]*\.key($|[^[:alnum:]_-])|\.ssh/|(^|/)secrets?/|(^|[^[:alnum:]_.-])\.netrc($|[^[:alnum:]_-])'

# Templates document which variables exist and carry no values. Fixtures carry fake ones.
ALLOWED='\.env\.(example|sample|template|dist|defaults)|/(fixtures|testdata)/|\.example($|[^[:alnum:]_-])|\.sample($|[^[:alnum:]_-])'

# Split on pipeline and list separators so a path in one stage cannot arm a reader in another.
segments=$(printf '%s' "$cmd" | tr '|;&\n' '\n\n\n\n')

while IFS= read -r seg; do
  [ -n "$seg" ] || continue
  printf '%s' "$seg" | grep -Eq "$SECRETS" || continue

  # Strip the parts that are explicitly fine, then re-test: a segment naming only
  # .env.example has nothing left to object to.
  stripped=$(printf '%s' "$seg" | sed -E "s#[^[:space:]]*($ALLOWED)[^[:space:]]*##g")
  printf '%s' "$stripped" | grep -Eq "$SECRETS" || continue

  # A reader command, a bare `.` source, or a `< path` redirect, which reads with no command
  # named at all. `<<` is a heredoc writing a file, not a read, so it is excluded.
  if printf '%s' "$stripped" | grep -Eq "(^|[^[:alnum:]_.-])($READERS)($|[^[:alnum:]_-])" ||
     printf '%s' "$stripped" | grep -Eq '(^|[^[:alnum:]_.-])\.[[:space:]]' ||
     printf '%s' "$stripped" | grep -Eq '(^|[^<])<[[:space:]]*[^[:space:]<&-]'; then
    guardrails_decide deny \
"This command reads a credential or environment file. Secret values do not belong in the transcript.
Read the variable names from a committed .env.example instead, or ask me to check the value and tell you
what you need. If this file is a template or fixture, give it an .example or .sample suffix, or move it
under a fixtures directory, where this check does not apply."
  fi
done <<< "$segments"

exit 0
