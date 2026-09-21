#!/usr/bin/env bash
# REQ-6. The repository carries nothing that names one machine or one organization.
. "$(dirname "$0")/lib/harness.sh"

cd "$REPO_DIR" || exit 1

check_pattern() {
  local label="$1" pattern="$2" hits
  # The only exclusion is this file, which must hold the patterns it hunts.
  # Nothing else is exempt: the change records under docs/superpowers/changes/
  # used to be, and three machine paths lived there unseen by the test and by
  # the pre-commit hook.
  hits=$(git grep -I -l -E "$pattern" -- . \
    | grep -v '^tests/no_machine_content.sh$' || true)
  if [ -n "$hits" ]; then
    fail "$label found in: $(printf '%s' "$hits" | tr '\n' ' ')"
  else
    pass "no $label"
  fi
}

check_pattern "absolute home path" '/(Users|home)/[A-Za-z0-9._-]+'
check_pattern "orca hook block" '\.orca/agent-hooks/claude-hook|EncodedCommand JABQ'
# REQ-6.3 forbids the marketplace, not the word. The spec states the
# requirement and the plan quotes this test, so the pattern matches the shapes
# a registration takes and leaves a prose mention alone: a settings.json key,
# an enabledPlugins entry, a marketplace-add command with or without the
# owning organization, and a github source repo. Ruling F37: the org-qualified
# add is the shape install.sh:88 uses for diagram-design, so it is the shape a
# real registration would take.
check_pattern "sunstone marketplace" '"sunstone-plugins"|@sunstone-plugins|marketplace add [^ ]*sunstone-plugins|/sunstone-plugins"'

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
