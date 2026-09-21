#!/usr/bin/env bash
# REQ-6. The repository carries nothing that names one machine or one organization.
. "$(dirname "$0")/lib/harness.sh"

cd "$REPO_DIR" || exit 1

check_pattern() {
  local label="$1" pattern="$2" hits
  hits=$(git grep -I -l -E "$pattern" -- . \
    | grep -v '^docs/superpowers/changes/' \
    | grep -v '^tests/no_machine_content.sh$' \
    | grep -v '^plugins/superpowers/' || true)
  if [ -n "$hits" ]; then
    fail "$label found in: $(printf '%s' "$hits" | tr '\n' ' ')"
  else
    pass "no $label"
  fi
}

check_pattern "absolute home path" '/(Users|home)/[A-Za-z0-9._-]+'
check_pattern "orca hook block" '\.orca/agent-hooks/claude-hook|EncodedCommand JABQ'
check_pattern "sunstone marketplace" 'sunstone-plugins'

forbidden_files() {
  local f
  for f in RESTORE-shepherd.txt skills/synced; do
    if git ls-files --error-unmatch "$f" >/dev/null 2>&1; then
      fail "$f is tracked"
    else
      pass "$f is not tracked"
    fi
  done
}
forbidden_files

# REQ-6.6. assets/warden.png is the only allowed binary.
bins=""
while IFS= read -r f; do
  mime=$(file --mime-type -b -- "$f" 2>/dev/null)
  case "$mime" in
    application/x-mach-binary|application/x-executable|application/x-sharedlib)
      bins="$bins $f"
      ;;
  esac
done < <(git ls-files)
if [ -n "$bins" ]; then
  fail "compiled binary tracked:$bins"
else
  pass "no compiled binary tracked"
fi

harness_exit
