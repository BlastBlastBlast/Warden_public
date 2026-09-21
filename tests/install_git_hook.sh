#!/usr/bin/env bash
# REQ-8, ruling C1-a. The installer wires the scrub pre-commit hook, and only
# when it is safe to.
. "$(dirname "$0")/lib/harness.sh"
harness_setup

# The hook this repository ships is present and runnable.
if [ -x "$REPO_DIR/.githooks/pre-commit" ]; then
  pass "$REPO_DIR/.githooks/pre-commit exists and is executable"
else
  fail "$REPO_DIR/.githooks/pre-commit is missing or not executable"
fi

# build_scratch_repo <name>
# A throwaway git repository with just enough of the installer to run
# install_git_hook: install.sh and the lib/ it sources. Never the real
# checkout: install.sh resolves $REPO to its own location on disk, so running
# it against a scratch copy is the only way to test core.hooksPath without
# touching this checkout's own git config.
build_scratch_repo() {
  local dir="$HARNESS_TMP/$1"
  mkdir -p "$dir/lib"
  cp "$REPO_DIR/install.sh" "$dir/install.sh"
  cp "$REPO_DIR/lib/warden-common.sh" "$dir/lib/warden-common.sh"
  chmod +x "$dir/install.sh"
  git -C "$dir" init -q
  printf '%s' "$dir"
}

# A default run wires the hook.
scratch_a=$(build_scratch_repo scratch-a)
"$scratch_a/install.sh" --skip-deps >/dev/null 2>&1
hooks_path=$(git -C "$scratch_a" config --get core.hooksPath 2>/dev/null)
if [ "$hooks_path" = ".githooks" ]; then
  pass "a default run sets core.hooksPath to .githooks in a scratch checkout"
else
  fail "a default run left core.hooksPath at '$hooks_path'"
fi

# --skip-plugin-hook leaves it unset.
harness_teardown
harness_setup
scratch_b=$(build_scratch_repo scratch-b)
"$scratch_b/install.sh" --skip-deps --skip-plugin-hook >/dev/null 2>&1
hooks_path=$(git -C "$scratch_b" config --get core.hooksPath 2>/dev/null)
if [ -z "$hooks_path" ]; then
  pass "--skip-plugin-hook leaves core.hooksPath unset"
else
  fail "--skip-plugin-hook set core.hooksPath to '$hooks_path'"
fi

# F24. A hooksPath someone set on purpose, to something other than
# .githooks, is never silently replaced.
harness_teardown
harness_setup
scratch_c=$(build_scratch_repo scratch-c)
git -C "$scratch_c" config core.hooksPath custom-hooks
out=$("$scratch_c/install.sh" --skip-deps 2>&1)
hooks_path=$(git -C "$scratch_c" config --get core.hooksPath 2>/dev/null)
if [ "$hooks_path" = "custom-hooks" ]; then
  pass "an existing custom core.hooksPath survives the install"
else
  fail "the install overwrote a custom core.hooksPath: found '$hooks_path'"
fi
assert_contains "$out" "core.hooksPath is already set to custom-hooks"

harness_exit
