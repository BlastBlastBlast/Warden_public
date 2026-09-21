# Warden Public Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan slice-by-slice. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a public repository that installs a complete Claude Code setup on a new computer with one command, and that can put the computer back.

**Architecture:** The repository holds the instruction surfaces as plain files. `install.sh` archives the existing Claude configuration directory, then symlinks each surface into it, then installs three external dependencies through the `claude` CLI and a GitHub release download. `uninstall.sh` reverses both layers. Every behaviour has a shell test that runs against a temporary `HOME` with stubbed `claude` and `curl`, so the suite needs no network and changes no real file.

**Tech Stack:** Bash 3.2 (the macOS system bash), `jq`, `curl`, `tar`, `shasum` or `sha256sum`, the `claude` CLI, and `git`.

**Spec:** `docs/superpowers/changes/2026-09-warden-public/spec.md`

## Global Constraints

- The repository is public. No tracked file holds an absolute path that names a user account (REQ-6.1).
- The repository holds no compiled binary. `assets/warden.png` is the one binary asset (REQ-6.6).
- Target platforms are macOS and Linux. Windows is a non-goal.
- The shell is Bash 3.2. No associative arrays, no `mapfile`, no `${var^^}`.
- The Claude configuration directory is always `${CLAUDE_CONFIG_DIR:-$HOME/.claude}`. No script writes `~/.claude` literally.
- The archive directory is always `$HOME/.warden-backups`.
- Backup names use `.warden-backup-<UTC timestamp>`, where the timestamp format is `%Y%m%dT%H%M%SZ`.
- The vendored plugin keeps the name `superpowers` (REQ-7.3).
- Every commit message uses a conventional prefix: `feat:`, `fix:`, `refactor:`, `chore:`, `docs:`.
- All work happens on the branch `feature/bootstrap-public-install`.

---

## File Structure

**Created by this plan:**

| Path | Responsibility |
|---|---|
| `lib/warden-common.sh` | Shell helpers both scripts source: logging, path resolution, timestamp, backup, archive. |
| `install.sh` | Archive, link the surfaces, install the dependencies, report. |
| `uninstall.sh` | Remove the links, restore the per-path backups, or restore a whole archive. |
| `INSTALL.md` | The written procedure Claude follows, with the consent point. |
| `README.md` | Every table REQ-8 demands. |
| `LICENSE` | MIT, for the files in this repository. |
| `.githooks/pre-commit` | Runs `tests/no_machine_content.sh` before a commit. |
| `tests/lib/harness.sh` | Temporary `HOME`, `PATH` stubs, assertion helpers. |
| `tests/stubs/claude` | Records its arguments to `$WARDEN_STUB_LOG`. |
| `tests/stubs/curl` | Serves canned release JSON and a canned archive. |
| `tests/run.sh` | Runs every `tests/*_*.sh` and exits non-zero on any failure. |
| `tests/no_machine_content.sh` | REQ-6 proof. |
| `tests/install_links.sh` | REQ-1 proof. |
| `tests/install_snapshot.sh` | REQ-3.6 proof. |
| `tests/install_idempotent.sh` | REQ-3.2 to REQ-3.4 proof. |
| `tests/install_deps.sh` | REQ-2 proof. |
| `tests/uninstall_restores.sh` | REQ-4.1 to REQ-4.4 proof. |
| `tests/uninstall_from_archive.sh` | REQ-4.5 proof. |
| `tests/vendored_license.sh` | REQ-7 proof. |
| `tests/readme_sections.sh` | REQ-8 proof. |

**Copied from `~/dev/Warden` and then edited:**

| Path | Change |
|---|---|
| `settings.json` | Drop every Orca hook group. Drop the `superpowers-dev` marketplace entry. Repoint `statusLine` and the `SessionStart` hook at the Claude configuration directory. |
| `CLAUDE.md`, `rules/`, `output-styles/`, `hooks/`, `docs/references/`, `docs/decisions/`, `bin/` | Copied without change. |
| `skills/` | Copied without `skills/synced/`. |

**Not copied:** `RESTORE-shepherd.txt`, `skills/synced/`, `.DS_Store`, `.git/`.

---

### Slice 1: `./install.sh --dry-run` prints the link plan, and the scrub test passes

**Satisfies:** REQ-1.1, REQ-1.2, REQ-3.5, REQ-6, REQ-9.1, REQ-9.3

**Demonstrate with:**

```bash
cd ~/dev/Warden_public && ./install.sh --dry-run && ./tests/run.sh
```

**Risk:** The scrub test is the only thing standing between a private path and a public repository. If it greps the wrong set of files, or passes on an empty file list, a leak ships. It gets three tests: a clean tree passes, a seeded machine path fails, a seeded `.orca` string fails. The dry-run printer carries no risk beyond wrong output, so it gets one test.

**Model:** standard tier — this slice copies files from another repository and edits JSON by hand.

**Files:**
- Create: `lib/warden-common.sh`, `install.sh`, `tests/lib/harness.sh`, `tests/run.sh`, `tests/no_machine_content.sh`, `tests/install_links.sh`, `.gitignore`
- Copy: `CLAUDE.md`, `settings.json`, `hooks/`, `output-styles/`, `rules/`, `skills/`, `docs/references/`, `docs/decisions/`, `bin/`

**Interfaces:**
- Produces: `lib/warden-common.sh` defines `warden_repo_root`, `warden_config_dir`, `warden_stamp`, `warden_say`, `warden_run`. Later slices source this file.
- Produces: `install.sh` accepts `--dry-run`, `--skip-deps`, `--skip-plugin-hook`, and `-h`.
- Produces: `tests/lib/harness.sh` defines `harness_setup`, `harness_teardown`, `assert_link`, `assert_file`, `assert_absent`, `assert_contains`, `fail`, `pass`.

- [ ] **Step 1: Copy the surfaces from `~/dev/Warden`**

```bash
cd ~/dev/Warden_public
SRC=~/dev/Warden
cp "$SRC/CLAUDE.md" .
cp "$SRC/settings.json" .
cp -R "$SRC/hooks" "$SRC/output-styles" "$SRC/rules" "$SRC/bin" .
mkdir -p docs
cp -R "$SRC/docs/references" "$SRC/docs/decisions" docs/
rsync -a --exclude 'synced' --exclude '.DS_Store' "$SRC/skills/" skills/
find . -name .DS_Store -delete
chmod +x bin/* hooks/*.sh
```

- [ ] **Step 2: Write `.gitignore`**

```
.DS_Store
*.warden-backup-*
tests/tmp/
```

- [ ] **Step 3: Edit `settings.json`**

Apply exactly these four changes. Leave `attribution`, `outputStyle`, `permissions`, `env` and `enabledPlugins` as they are.

1. Replace the `_comment` value with:
   `"Source of truth: the Warden_public repository, symlinked to the Claude configuration directory."`
2. In `hooks`, delete every hook group whose command contains `.orca/agent-hooks`. That removes the third `PreToolUse` group, the second `PostToolUse` group, and the whole of `Stop`, `StopFailure`, `SubagentStart`, `SubagentStop`, `TeammateIdle`, `PostToolUseFailure`, `PermissionRequest` and `PostCompact`. It also removes the second `SessionStart` group.
3. Change the remaining `SessionStart` command from `$HOME/dev/Warden/bin/warden-handoff hook` to `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/bin/warden-handoff hook`.
4. Change `statusLine.command` from `$HOME/dev/Warden/bin/warden-statusline` to `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/bin/warden-statusline`.
5. In `extraKnownMarketplaces`, delete the `superpowers-dev` key. Keep `diagram-design`.

Verify the result parses and holds no machine path:

```bash
jq -e . settings.json >/dev/null && ! grep -q '/Users/' settings.json && echo OK
```

- [ ] **Step 4: Write `lib/warden-common.sh`**

```bash
#!/usr/bin/env bash
# Helpers shared by install.sh and uninstall.sh. Source this, do not execute it.

# The directory that holds install.sh, resolved through any symlink. REQ-1.1.
warden_repo_root() {
  local src="${BASH_SOURCE[1]}" dir
  while [ -L "$src" ]; do
    dir=$(cd -P "$(dirname "$src")" && pwd)
    src=$(readlink "$src")
    case "$src" in /*) ;; *) src="$dir/$src" ;; esac
  done
  cd -P "$(dirname "$src")" && pwd
}

# REQ-1.2. Never write ~/.claude literally.
warden_config_dir() {
  printf '%s' "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
}

warden_backup_dir() {
  printf '%s' "$HOME/.warden-backups"
}

warden_stamp() {
  date -u +%Y%m%dT%H%M%SZ
}

warden_say() {
  printf '%s\n' "$*"
}

warden_die() {
  printf 'warden: %s\n' "$*" >&2
  exit 1
}

# warden_run <description> <command...>
# Honours WARDEN_DRY_RUN. REQ-3.5.
warden_run() {
  local desc="$1"; shift
  if [ "${WARDEN_DRY_RUN:-0}" = "1" ]; then
    warden_say "would: $desc"
    return 0
  fi
  warden_say "$desc"
  "$@"
}

# The surfaces install.sh links into the Claude configuration directory.
# REQ-1.5 keeps docs/superpowers out by linking docs as a whole is wrong, so
# each surface is named one by one.
WARDEN_SURFACES="CLAUDE.md settings.json hooks output-styles rules skills bin"
WARDEN_DOC_SURFACES="references decisions"
```

- [ ] **Step 5: Write `install.sh` with dry-run and linking not yet implemented**

```bash
#!/usr/bin/env bash
# Install the Warden Claude Code setup on this computer.
#
#   ./install.sh              archive, link, install dependencies
#   ./install.sh --dry-run    print every action, write nothing
#   ./install.sh --skip-deps  archive and link only
set -uo pipefail

SELF_DIR=$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)
. "$SELF_DIR/lib/warden-common.sh"

REPO="$SELF_DIR"
CFG=$(warden_config_dir)
WARDEN_DRY_RUN=0
SKIP_DEPS=0

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) WARDEN_DRY_RUN=1 ;;
    --skip-deps) SKIP_DEPS=1 ;;
    -h|--help)
      sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) warden_die "unknown option: $1" ;;
  esac
  shift
done
export WARDEN_DRY_RUN

warden_say "repository: $REPO"
warden_say "claude config: $CFG"

for name in $WARDEN_SURFACES; do
  warden_say "would link: $CFG/$name -> $REPO/$name"
done
for name in $WARDEN_DOC_SURFACES; do
  warden_say "would link: $CFG/docs/$name -> $REPO/docs/$name"
done
warden_say "would link: $HOME/.local/bin/warden-handoff -> $REPO/bin/warden-handoff"
```

- [ ] **Step 6: Write `tests/lib/harness.sh`**

```bash
#!/usr/bin/env bash
# Every test sources this. It gives each test its own HOME and its own PATH.

TESTS_DIR=$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
REPO_DIR=$(cd -P "$TESTS_DIR/.." && pwd)

FAILURES=0

harness_setup() {
  HARNESS_TMP=$(mktemp -d "${TMPDIR:-/tmp}/warden-test.XXXXXX")
  export HOME="$HARNESS_TMP/home"
  mkdir -p "$HOME/.claude"
  export WARDEN_STUB_LOG="$HARNESS_TMP/stub.log"
  : > "$WARDEN_STUB_LOG"
  export PATH="$TESTS_DIR/stubs:$PATH"
  unset CLAUDE_CONFIG_DIR
}

harness_teardown() {
  [ -n "${HARNESS_TMP:-}" ] && rm -rf "$HARNESS_TMP"
}

fail() {
  printf '  FAIL %s\n' "$*"
  FAILURES=$((FAILURES + 1))
}

pass() {
  printf '  ok   %s\n' "$*"
}

assert_link() {
  local link="$1" target="$2"
  if [ -L "$link" ] && [ "$(readlink "$link")" = "$target" ]; then
    pass "$link -> $target"
  else
    fail "$link should link to $target, found '$(readlink "$link" 2>/dev/null)'"
  fi
}

assert_file() {
  [ -f "$1" ] && pass "file $1 exists" || fail "file $1 is missing"
}

assert_absent() {
  [ -e "$1" ] && fail "$1 should not exist" || pass "$1 is absent"
}

assert_contains() {
  local haystack="$1" needle="$2"
  case "$haystack" in
    *"$needle"*) pass "output holds '$needle'" ;;
    *) fail "output does not hold '$needle'" ;;
  esac
}

harness_exit() {
  harness_teardown
  [ "$FAILURES" -eq 0 ] || exit 1
  exit 0
}
```

- [ ] **Step 7: Write `tests/no_machine_content.sh`**

```bash
#!/usr/bin/env bash
# REQ-6. The repository carries nothing that names one machine or one organization.
. "$(dirname "$0")/lib/harness.sh"

cd "$REPO_DIR" || exit 1

check_pattern() {
  local label="$1" pattern="$2" hits
  hits=$(git ls-files -z \
    | xargs -0 grep -I -l -E "$pattern" 2>/dev/null \
    | grep -v '^docs/superpowers/changes/' \
    | grep -v '^tests/no_machine_content.sh$' || true)
  if [ -n "$hits" ]; then
    fail "$label found in: $(printf '%s' "$hits" | tr '\n' ' ')"
  else
    pass "no $label"
  fi
}

check_pattern "absolute home path" '/(Users|home)/[A-Za-z0-9._-]+'
check_pattern "orca hook reference" '\.orca/agent-hooks'
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
bins=$(git ls-files -z | xargs -0 file --mime-type \
  | grep -E ':[[:space:]]*application/(x-mach-binary|x-executable|x-sharedlib)' || true)
if [ -n "$bins" ]; then
  fail "compiled binary tracked: $bins"
else
  pass "no compiled binary tracked"
fi

harness_exit
```

- [ ] **Step 8: Write `tests/install_links.sh` covering the dry run only**

```bash
#!/usr/bin/env bash
# REQ-1.1, REQ-1.2, REQ-3.5. The dry run prints the plan and writes nothing.
. "$(dirname "$0")/lib/harness.sh"
harness_setup

out=$("$REPO_DIR/install.sh" --dry-run --skip-deps 2>&1)

assert_contains "$out" "would link: $HOME/.claude/CLAUDE.md -> $REPO_DIR/CLAUDE.md"
assert_contains "$out" "would link: $HOME/.claude/settings.json -> $REPO_DIR/settings.json"
assert_contains "$out" "would link: $HOME/.claude/skills -> $REPO_DIR/skills"
assert_contains "$out" "would link: $HOME/.claude/docs/references -> $REPO_DIR/docs/references"
assert_contains "$out" "would link: $HOME/.local/bin/warden-handoff -> $REPO_DIR/bin/warden-handoff"

assert_absent "$HOME/.claude/CLAUDE.md"
assert_absent "$HOME/.local/bin"

# REQ-1.5. The change records are not a surface.
case "$out" in
  *"docs/superpowers"*) fail "the dry run offers to link docs/superpowers" ;;
  *) pass "docs/superpowers is not linked" ;;
esac

harness_exit
```

- [ ] **Step 9: Write `tests/run.sh`**

```bash
#!/usr/bin/env bash
# Run every test. Exit non-zero when any test fails. REQ-9.3.
set -uo pipefail
TESTS_DIR=$(cd -P "$(dirname "$0")" && pwd)

total=0
failed=0
for t in "$TESTS_DIR"/*_*.sh; do
  name=$(basename "$t")
  total=$((total + 1))
  printf '%s\n' "$name"
  if bash "$t"; then
    :
  else
    failed=$((failed + 1))
  fi
done

printf '\n%d tests, %d failed\n' "$total" "$failed"
[ "$failed" -eq 0 ]
```

- [ ] **Step 10: Make the scripts executable and run the suite to see it fail**

```bash
chmod +x install.sh tests/run.sh tests/*_*.sh
./tests/run.sh
```

Expected: `install_links.sh` passes. `no_machine_content.sh` fails, because nothing is committed yet and `git ls-files` returns nothing, so the binary check and the forbidden-file checks pass but nothing is scanned. Commit first, then re-run.

- [ ] **Step 11: Commit the surfaces, then run the suite again**

```bash
git add -A
git commit -m "feat: carry the scrubbed instruction surfaces and a test harness"
./tests/run.sh
```

Expected: `2 tests, 0 failed`.

- [ ] **Step 12: Prove the scrub test can fail**

```bash
printf '# /Users/<name>/dev/x\n' >> rules/instruction-files.md
git add rules/instruction-files.md
bash tests/no_machine_content.sh; echo "exit=$?"
git checkout rules/instruction-files.md
```

Expected: `FAIL absolute home path found in: rules/instruction-files.md` and `exit=1`.

- [ ] **Step 13: Demonstrate the slice**

```bash
./install.sh --dry-run --skip-deps && ./tests/run.sh
```

Expected: the dry run lists ten links and writes nothing. The suite prints `2 tests, 0 failed`.

- [ ] **Step 14: Commit**

```bash
git add -A
git commit -m "feat: print the install plan with --dry-run"
```

---

### Slice 2: `./install.sh --skip-deps` archives the configuration, then links every surface

**Satisfies:** REQ-1.3, REQ-1.4, REQ-1.6, REQ-3.1, REQ-3.6

**Demonstrate with:**

```bash
cd ~/dev/Warden_public && bash tests/install_snapshot.sh && bash tests/install_links.sh
```

**Risk:** This slice writes to the person's real configuration directory. Two failures cost the most. First, an archive that silently omits a file leaves no way back, so the archive gets four assertions: it exists, it holds a seeded file, it stores a symlink as a link, and it holds no excluded directory. Second, replacing a real file without a backup destroys work, so the link step gets an assertion that the displaced file survives under its backup name. `tar` flag behaviour differs between BSD and GNU, which is where a silent omission would come from.

**Model:** standard tier — the archive logic must work on both BSD `tar` and GNU `tar`.

**Files:**
- Modify: `lib/warden-common.sh` (add `warden_archive_config`, `warden_backup_path`, `warden_link`)
- Modify: `install.sh` (replace the dry-run printer with real work)
- Modify: `tests/install_links.sh` (add the real-install case)
- Create: `tests/install_snapshot.sh`

**Interfaces:**
- Consumes: `warden_repo_root`, `warden_config_dir`, `warden_stamp`, `warden_run`, `warden_say`, `warden_die` from Slice 1.
- Produces: `warden_archive_config <config_dir> <archive_dir>` prints the archive path on stdout and returns non-zero on failure.
- Produces: `warden_backup_path <path>` prints `<path>.warden-backup-<stamp>`.
- Produces: `warden_link <target> <link_path>` creates one link, backs up what it displaces, and increments `WARDEN_MADE`, `WARDEN_KEPT` or `WARDEN_BACKED_UP`.

- [ ] **Step 1: Write the failing archive test**

Create `tests/install_snapshot.sh`:

```bash
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
```

- [ ] **Step 2: Run it to see it fail**

```bash
bash tests/install_snapshot.sh; echo "exit=$?"
```

Expected: `FAIL the installer printed no archive path` and `exit=1`.

- [ ] **Step 3: Add the archive and link helpers to `lib/warden-common.sh`**

Append:

```bash
WARDEN_EXCLUDES="projects sessions shell-snapshots paste-cache file-history telemetry cache"

# warden_archive_config <config_dir> <archive_dir>
# Prints the archive path. REQ-3.6.
warden_archive_config() {
  local cfg="$1" dest="$2" stamp out parent base ex args
  stamp=$(warden_stamp)
  out="$dest/claude-$stamp.tar.gz"
  mkdir -p "$dest" || return 1
  parent=$(dirname "$cfg")
  base=$(basename "$cfg")
  args=""
  for ex in $WARDEN_EXCLUDES; do
    args="$args --exclude=$base/$ex"
  done
  # No -h and no -L: tar stores a symbolic link as a link by default on both
  # BSD tar and GNU tar. REQ-3.6.3.
  # shellcheck disable=SC2086
  tar czf "$out" -C "$parent" $args "$base" || return 1
  printf '%s' "$out"
}

warden_backup_path() {
  printf '%s.warden-backup-%s' "$1" "$(warden_stamp)"
}

WARDEN_MADE=0
WARDEN_KEPT=0
WARDEN_BACKED_UP=0

# warden_link <target> <link_path>
warden_link() {
  local target="$1" link="$2" backup
  mkdir -p "$(dirname "$link")"
  if [ -L "$link" ] && [ "$(readlink "$link")" = "$target" ]; then
    warden_say "keep: $link"
    WARDEN_KEPT=$((WARDEN_KEPT + 1))
    return 0
  fi
  if [ -e "$link" ] || [ -L "$link" ]; then
    backup=$(warden_backup_path "$link")
    warden_run "backup: $link -> $backup" mv "$link" "$backup" || return 1
    WARDEN_BACKED_UP=$((WARDEN_BACKED_UP + 1))
  fi
  warden_run "link: $link -> $target" ln -s "$target" "$link" || return 1
  WARDEN_MADE=$((WARDEN_MADE + 1))
}
```

- [ ] **Step 4: Replace the printer in `install.sh` with real work**

Delete the four `warden_say "would link: ..."` loops from Slice 1 and put this in their place:

```bash
# REQ-3.6.6. No change without an archive.
if [ "$WARDEN_DRY_RUN" = "1" ]; then
  warden_say "would archive: $CFG -> $(warden_backup_dir)/claude-<stamp>.tar.gz"
else
  mkdir -p "$CFG"
  ARCHIVE=$(warden_archive_config "$CFG" "$(warden_backup_dir)") \
    || warden_die "could not archive $CFG"
  warden_say "archive: $ARCHIVE"
fi

if [ "$WARDEN_DRY_RUN" = "1" ]; then
  for name in $WARDEN_SURFACES; do
    warden_say "would link: $CFG/$name -> $REPO/$name"
  done
  for name in $WARDEN_DOC_SURFACES; do
    warden_say "would link: $CFG/docs/$name -> $REPO/docs/$name"
  done
  warden_say "would link: $HOME/.local/bin/warden-handoff -> $REPO/bin/warden-handoff"
else
  for name in $WARDEN_SURFACES; do
    warden_link "$REPO/$name" "$CFG/$name" || warden_die "could not link $name"
  done
  for name in $WARDEN_DOC_SURFACES; do
    warden_link "$REPO/docs/$name" "$CFG/docs/$name" || warden_die "could not link docs/$name"
  done
  warden_link "$REPO/bin/warden-handoff" "$HOME/.local/bin/warden-handoff" \
    || warden_die "could not link warden-handoff"
fi
```

- [ ] **Step 5: Run the archive test to see it pass**

```bash
bash tests/install_snapshot.sh; echo "exit=$?"
```

Expected: every line starts with `ok` and `exit=0`.

- [ ] **Step 6: Add the real-install case to `tests/install_links.sh`**

Append before `harness_exit`:

```bash
# A real install, into a directory that already holds a settings.json.
printf '{"theme":"dark"}\n' > "$HOME/.claude/settings.json"
"$REPO_DIR/install.sh" --skip-deps >/dev/null 2>&1

assert_link "$HOME/.claude/CLAUDE.md" "$REPO_DIR/CLAUDE.md"
assert_link "$HOME/.claude/settings.json" "$REPO_DIR/settings.json"
assert_link "$HOME/.claude/hooks" "$REPO_DIR/hooks"
assert_link "$HOME/.claude/output-styles" "$REPO_DIR/output-styles"
assert_link "$HOME/.claude/rules" "$REPO_DIR/rules"
assert_link "$HOME/.claude/skills" "$REPO_DIR/skills"
assert_link "$HOME/.claude/bin" "$REPO_DIR/bin"
assert_link "$HOME/.claude/docs/references" "$REPO_DIR/docs/references"
assert_link "$HOME/.claude/docs/decisions" "$REPO_DIR/docs/decisions"
assert_link "$HOME/.local/bin/warden-handoff" "$REPO_DIR/bin/warden-handoff"

# REQ-3.1. The displaced file survives under its backup name.
kept=$(ls "$HOME/.claude/"settings.json.warden-backup-* 2>/dev/null | head -1)
if [ -n "$kept" ] && grep -q dark "$kept"; then
  pass "the displaced settings.json survives at $kept"
else
  fail "the displaced settings.json was lost"
fi
```

- [ ] **Step 7: Run the link test**

```bash
bash tests/install_links.sh; echo "exit=$?"
```

Expected: `exit=0`.

- [ ] **Step 8: Demonstrate the slice**

```bash
./tests/run.sh
```

Expected: `3 tests, 0 failed`.

- [ ] **Step 9: Commit**

```bash
git add -A
git commit -m "feat: archive the config directory, then link every surface"
```

---

### Slice 3: Running the installer a second time changes nothing

**Satisfies:** REQ-3.2, REQ-3.3, REQ-3.4

**Demonstrate with:**

```bash
cd ~/dev/Warden_public && bash tests/install_idempotent.sh
```

**Risk:** A second run that backs up the links it made on the first run fills the configuration directory with junk and hides the real backup. That is the whole risk, and one test covers it: run twice, assert the second run reports zero new links, zero backups, and creates no second backup file.

**Model:** cheap tier — the files, the test and the code are all stated here.

**Files:**
- Modify: `install.sh` (add the summary)
- Create: `tests/install_idempotent.sh`

**Interfaces:**
- Consumes: `WARDEN_MADE`, `WARDEN_KEPT`, `WARDEN_BACKED_UP` from Slice 2.
- Produces: a final line of the exact form `summary: N linked, N kept, N backed up`.

- [ ] **Step 1: Write the failing test**

```bash
#!/usr/bin/env bash
# REQ-3.2, REQ-3.3, REQ-3.4. A second run is a no-op.
. "$(dirname "$0")/lib/harness.sh"
harness_setup

first=$("$REPO_DIR/install.sh" --skip-deps 2>&1)
assert_contains "$first" "summary: 10 linked, 0 kept, 0 backed up"

before=$(ls -1 "$HOME/.claude" | wc -l | tr -d ' ')

second=$("$REPO_DIR/install.sh" --skip-deps 2>&1)
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
```

- [ ] **Step 2: Run it to see it fail**

```bash
bash tests/install_idempotent.sh; echo "exit=$?"
```

Expected: `FAIL output does not hold 'summary: 10 linked, 0 kept, 0 backed up'` and `exit=1`.

- [ ] **Step 3: Add the summary to the end of `install.sh`**

```bash
warden_say "summary: $WARDEN_MADE linked, $WARDEN_KEPT kept, $WARDEN_BACKED_UP backed up"
```

- [ ] **Step 4: Run the test to see it pass**

```bash
bash tests/install_idempotent.sh; echo "exit=$?"
```

Expected: `exit=0`. If the first count is not 10, correct the expected number in the test to match `WARDEN_SURFACES` plus `WARDEN_DOC_SURFACES` plus one, rather than changing the installer.

- [ ] **Step 5: Demonstrate the slice**

```bash
./tests/run.sh
```

Expected: `4 tests, 0 failed`.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: report a summary and make a second run a no-op"
```

---

### Slice 4: `./install.sh` installs the three dependencies

**Satisfies:** REQ-2

**Demonstrate with:**

```bash
cd ~/dev/Warden_public && bash tests/install_deps.sh
```

**Risk:** This slice reaches the network and writes executables into `$HOME/bin`. Three failures carry real cost. An unverified download puts an unknown binary on the person's `PATH`, so the checksum step is mandatory and gets its own assertion. A wrong architecture puts a binary that cannot run on the person's `PATH`, so the unsupported case gets a test that asserts a non-zero exit. A missing prerequisite discovered halfway through leaves the machine half-installed, so the prerequisite check runs before the archive and gets a test.

**Model:** standard tier — the slice writes two stub programs and an architecture map.

**Files:**
- Modify: `install.sh` (add `check_prereqs`, `install_plugins`, `install_monitor`)
- Create: `tests/stubs/claude`, `tests/stubs/curl`, `tests/install_deps.sh`

**Interfaces:**
- Consumes: `warden_die`, `warden_say`, `warden_run` from Slice 1.
- Produces: `install.sh` reads `WARDEN_MONITOR_REPO` (default `stigsb/claude-context-monitor`) and `WARDEN_OS`/`WARDEN_ARCH` overrides, so a test can force an unsupported platform.
- Produces: the stubs append one line per call to `$WARDEN_STUB_LOG`, in the form `claude <args>` or `curl <args>`.

- [ ] **Step 1: Write `tests/stubs/claude`**

```bash
#!/usr/bin/env bash
printf 'claude %s\n' "$*" >> "$WARDEN_STUB_LOG"
exit 0
```

- [ ] **Step 2: Write `tests/stubs/curl`**

The stub serves two things: the release JSON, and the tarball. It builds the tarball on the fly so the repository stores no binary.

```bash
#!/usr/bin/env bash
# Canned replies for the two URLs install.sh fetches.
printf 'curl %s\n' "$*" >> "$WARDEN_STUB_LOG"

url=""
out=""
prev=""
for a in "$@"; do
  case "$prev" in -o) out="$a" ;; esac
  case "$a" in https://*) url="$a" ;; esac
  prev="$a"
done

emit() { if [ -n "$out" ]; then cat > "$out"; else cat; fi; }

case "$url" in
  *api.github.com/repos/*/releases/latest)
    emit <<'JSON'
{"tag_name":"v1.1.0","assets":[
 {"name":"claude-context-monitor_1.1.0_darwin_arm64.tar.gz",
  "browser_download_url":"https://example.invalid/claude-context-monitor_1.1.0_darwin_arm64.tar.gz"},
 {"name":"claude-context-monitor_1.1.0_linux_amd64.tar.gz",
  "browser_download_url":"https://example.invalid/claude-context-monitor_1.1.0_linux_amd64.tar.gz"},
 {"name":"checksums.txt",
  "browser_download_url":"https://example.invalid/checksums.txt"}]}
JSON
    ;;
  *checksums.txt)
    stage="${WARDEN_STUB_STAGE:?stub stage not set}"
    ( cd "$stage" && shasum -a 256 ./*.tar.gz | sed 's|\./||' ) | emit
    ;;
  *.tar.gz)
    stage="${WARDEN_STUB_STAGE:?stub stage not set}"
    name=$(basename "$url")
    cat "$stage/$name" | emit
    ;;
  *)
    exit 22
    ;;
esac
exit 0
```

- [ ] **Step 3: Write the failing test**

```bash
#!/usr/bin/env bash
# REQ-2. The installer registers the marketplaces and installs the monitor.
. "$(dirname "$0")/lib/harness.sh"
harness_setup

# Build the tarball the curl stub will serve. Two fake executables, one README.
export WARDEN_STUB_STAGE="$HARNESS_TMP/stage"
mkdir -p "$WARDEN_STUB_STAGE/payload"
printf '#!/bin/sh\necho monitor\n' > "$WARDEN_STUB_STAGE/payload/claude-context-monitor"
printf '#!/bin/sh\necho statusline\n' > "$WARDEN_STUB_STAGE/payload/claude-statusline"
printf 'readme\n' > "$WARDEN_STUB_STAGE/payload/README.md"
chmod +x "$WARDEN_STUB_STAGE/payload/"claude-*
( cd "$WARDEN_STUB_STAGE/payload" \
  && tar czf "$WARDEN_STUB_STAGE/claude-context-monitor_1.1.0_darwin_arm64.tar.gz" . )
cp "$WARDEN_STUB_STAGE/claude-context-monitor_1.1.0_darwin_arm64.tar.gz" \
   "$WARDEN_STUB_STAGE/claude-context-monitor_1.1.0_linux_amd64.tar.gz"

WARDEN_OS=darwin WARDEN_ARCH=arm64 "$REPO_DIR/install.sh" >/dev/null 2>&1
log=$(cat "$WARDEN_STUB_LOG")

# REQ-2.1
assert_contains "$log" "claude plugin marketplace add $REPO_DIR/plugins/superpowers"
# REQ-2.2
assert_contains "$log" "claude plugin marketplace add cathrynlavery/diagram-design"
# REQ-2.4
assert_file "$HOME/bin/claude-context-monitor"
assert_file "$HOME/bin/claude-statusline"
if [ -x "$HOME/bin/claude-statusline" ]; then
  pass "claude-statusline is executable"
else
  fail "claude-statusline is not executable"
fi

# REQ-2.5. An unsupported architecture stops the installer.
harness_teardown
harness_setup
export WARDEN_STUB_STAGE="$HARNESS_TMP/stage"
mkdir -p "$WARDEN_STUB_STAGE"
out=$(WARDEN_OS=plan9 WARDEN_ARCH=sparc "$REPO_DIR/install.sh" 2>&1)
status=$?
if [ "$status" -ne 0 ]; then
  pass "an unsupported platform exits non-zero"
else
  fail "an unsupported platform exited 0"
fi
assert_contains "$out" "no release asset for plan9/sparc"
assert_absent "$HOME/bin/claude-statusline"

# REQ-2.6. A missing prerequisite stops the installer before it archives.
harness_teardown
harness_setup
export WARDEN_STUB_STAGE="$HARNESS_TMP/stage"
mkdir -p "$WARDEN_STUB_STAGE"
mkdir -p "$HARNESS_TMP/emptybin"
out=$(PATH="$HARNESS_TMP/emptybin:/usr/bin:/bin" "$REPO_DIR/install.sh" 2>&1)
status=$?
if [ "$status" -ne 0 ]; then
  pass "a missing prerequisite exits non-zero"
else
  fail "a missing prerequisite exited 0"
fi
assert_contains "$out" "missing prerequisite: claude"
assert_absent "$HOME/.warden-backups"

harness_exit
```

- [ ] **Step 4: Run it to see it fail**

```bash
bash tests/install_deps.sh; echo "exit=$?"
```

Expected: `FAIL output does not hold 'claude plugin marketplace add ...'` and `exit=1`.

- [ ] **Step 5: Add the prerequisite check to `install.sh`, above the archive step**

```bash
check_prereqs() {
  local need missing
  missing=""
  for need in git jq curl tar claude; do
    command -v "$need" >/dev/null 2>&1 || missing="$missing $need"
  done
  command -v shasum >/dev/null 2>&1 || command -v sha256sum >/dev/null 2>&1 \
    || missing="$missing shasum"
  if [ -n "$missing" ]; then
    for need in $missing; do
      printf 'warden: missing prerequisite: %s\n' "$need" >&2
    done
    exit 1
  fi
}
[ "$SKIP_DEPS" = "1" ] || check_prereqs
```

- [ ] **Step 6: Add the plugin step to `install.sh`, after the linking step**

```bash
install_plugins() {
  warden_run "register the vendored superpowers marketplace" \
    claude plugin marketplace add "$REPO/plugins/superpowers"
  warden_run "register the diagram-design marketplace" \
    claude plugin marketplace add cathrynlavery/diagram-design
}
```

- [ ] **Step 7: Add the monitor step to `install.sh`**

```bash
WARDEN_MONITOR_REPO="${WARDEN_MONITOR_REPO:-stigsb/claude-context-monitor}"

sha256_of() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    sha256sum "$1" | awk '{print $1}'
  fi
}

install_monitor() {
  local os arch api json asset_url sums_url tmp name want got
  os="${WARDEN_OS:-$(uname -s | tr 'A-Z' 'a-z')}"
  case "${WARDEN_ARCH:-$(uname -m)}" in
    arm64|aarch64) arch=arm64 ;;
    x86_64|amd64)  arch=amd64 ;;
    *)             arch="${WARDEN_ARCH:-$(uname -m)}" ;;
  esac

  api="https://api.github.com/repos/$WARDEN_MONITOR_REPO/releases/latest"
  tmp=$(mktemp -d "${TMPDIR:-/tmp}/warden-monitor.XXXXXX") || return 1
  curl -fsSL -o "$tmp/release.json" "$api" || { rm -rf "$tmp"; return 1; }

  asset_url=$(jq -r --arg s "_${os}_${arch}.tar.gz" \
    '.assets[] | select(.name | endswith($s)) | .browser_download_url' \
    "$tmp/release.json" | head -1)
  if [ -z "$asset_url" ] || [ "$asset_url" = "null" ]; then
    rm -rf "$tmp"
    warden_die "no release asset for $os/$arch in $WARDEN_MONITOR_REPO"
  fi
  name=$(basename "$asset_url")

  sums_url=$(jq -r '.assets[] | select(.name == "checksums.txt") | .browser_download_url' \
    "$tmp/release.json" | head -1)
  [ -n "$sums_url" ] && [ "$sums_url" != "null" ] \
    || { rm -rf "$tmp"; warden_die "the release has no checksums.txt"; }

  curl -fsSL -o "$tmp/$name" "$asset_url" || { rm -rf "$tmp"; warden_die "download failed"; }
  curl -fsSL -o "$tmp/checksums.txt" "$sums_url" \
    || { rm -rf "$tmp"; warden_die "checksum download failed"; }

  want=$(awk -v n="$name" '$2 == n || $2 == "*" n {print $1}' "$tmp/checksums.txt" | head -1)
  got=$(sha256_of "$tmp/$name")
  if [ -z "$want" ] || [ "$want" != "$got" ]; then
    rm -rf "$tmp"
    warden_die "checksum mismatch for $name"
  fi
  warden_say "checksum ok: $name"

  mkdir -p "$tmp/x" "$HOME/bin"
  tar xzf "$tmp/$name" -C "$tmp/x" || { rm -rf "$tmp"; warden_die "unpack failed"; }
  for name in claude-context-monitor claude-statusline; do
    found=$(find "$tmp/x" -name "$name" -type f | head -1)
    [ -n "$found" ] || { rm -rf "$tmp"; warden_die "$name is not in the archive"; }
    warden_run "install: $HOME/bin/$name" install -m 0755 "$found" "$HOME/bin/$name"
  done
  rm -rf "$tmp"
}
```

Call both at the end of `install.sh`, before the summary:

```bash
if [ "$SKIP_DEPS" = "1" ]; then
  warden_say "skipping the dependencies"
else
  install_plugins
  install_monitor
fi
```

- [ ] **Step 8: Run the test to see it pass**

```bash
bash tests/install_deps.sh; echo "exit=$?"
```

Expected: `exit=0`.

- [ ] **Step 9: Demonstrate the slice**

```bash
./tests/run.sh
```

Expected: `5 tests, 0 failed`.

- [ ] **Step 10: Commit**

```bash
git add -A
git commit -m "feat: install the marketplaces and the verified context monitor"
```

---

### Slice 5: `./uninstall.sh` removes the links and restores what they displaced

**Satisfies:** REQ-4.1, REQ-4.2, REQ-4.3, REQ-4.4

**Demonstrate with:**

```bash
cd ~/dev/Warden_public && bash tests/uninstall_restores.sh
```

**Risk:** An uninstaller that removes a file it did not create destroys the person's own work. That is the worst failure in the whole repository, and it gets two assertions: a foreign file in the configuration directory survives, and a link that points somewhere else survives. Restoring the wrong backup is the second risk, and the newest-wins rule gets a test with two backups of different ages.

**Model:** cheap tier — the files, the test and the code are all stated here.

**Files:**
- Create: `uninstall.sh`, `tests/uninstall_restores.sh`

**Interfaces:**
- Consumes: `warden_repo_root`, `warden_config_dir`, `warden_say`, `warden_die`, `WARDEN_SURFACES`, `WARDEN_DOC_SURFACES` from Slice 1.
- Produces: `uninstall.sh` accepts `--dry-run` and `--from-archive <path>`. Slice 6 adds the second flag.

- [ ] **Step 1: Write the failing test**

```bash
#!/usr/bin/env bash
# REQ-4.1 to REQ-4.4. The uninstaller removes only its own links.
. "$(dirname "$0")/lib/harness.sh"
harness_setup

printf '{"theme":"dark"}\n' > "$HOME/.claude/settings.json"
original=$(cat "$HOME/.claude/settings.json")
printf 'mine\n' > "$HOME/.claude/my-notes.md"
mkdir -p "$HARNESS_TMP/elsewhere"
ln -s "$HARNESS_TMP/elsewhere" "$HOME/.claude/agents"

"$REPO_DIR/install.sh" --skip-deps >/dev/null 2>&1
out=$("$REPO_DIR/uninstall.sh" 2>&1)

# REQ-4.2
if [ -f "$HOME/.claude/settings.json" ] \
   && [ ! -L "$HOME/.claude/settings.json" ] \
   && [ "$(cat "$HOME/.claude/settings.json")" = "$original" ]; then
  pass "the original settings.json returned byte for byte"
else
  fail "the original settings.json did not return"
fi

# REQ-4.1 and REQ-4.3
assert_file "$HOME/.claude/my-notes.md"
if [ -L "$HOME/.claude/agents" ]; then
  pass "a link that points elsewhere survives"
else
  fail "the uninstaller removed a link it did not create"
fi

assert_absent "$HOME/.claude/CLAUDE.md"
assert_absent "$HOME/.claude/skills"
assert_absent "$HOME/.local/bin/warden-handoff"

# REQ-4.4
assert_contains "$out" "claude plugin marketplace remove"
assert_contains "$out" "rm -f \$HOME/bin/claude-context-monitor"

# REQ-4.2 with two backups: the newest wins.
harness_teardown
harness_setup
printf 'old\n' > "$HOME/.claude/CLAUDE.md.warden-backup-20200101T000000Z"
printf 'new\n' > "$HOME/.claude/CLAUDE.md.warden-backup-20990101T000000Z"
ln -s "$REPO_DIR/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
"$REPO_DIR/uninstall.sh" >/dev/null 2>&1
if [ "$(cat "$HOME/.claude/CLAUDE.md")" = "new" ]; then
  pass "the newest backup wins"
else
  fail "the uninstaller restored the wrong backup"
fi

harness_exit
```

- [ ] **Step 2: Run it to see it fail**

```bash
bash tests/uninstall_restores.sh; echo "exit=$?"
```

Expected: `bash: uninstall.sh: No such file or directory` and `exit=1`.

- [ ] **Step 3: Write `uninstall.sh`**

```bash
#!/usr/bin/env bash
# Remove the Warden links and put back what they displaced.
#
#   ./uninstall.sh              remove the links, restore the backups
#   ./uninstall.sh --dry-run    print every action, write nothing
set -uo pipefail

SELF_DIR=$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)
. "$SELF_DIR/lib/warden-common.sh"

REPO="$SELF_DIR"
CFG=$(warden_config_dir)
WARDEN_DRY_RUN=0

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) WARDEN_DRY_RUN=1 ;;
    -h|--help) sed -n '2,6p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) warden_die "unknown option: $1" ;;
  esac
  shift
done
export WARDEN_DRY_RUN

# unlink_one <link_path>
# Removes the link only when it points into this repository. REQ-4.1, REQ-4.3.
unlink_one() {
  local link="$1" target newest
  [ -L "$link" ] || { warden_say "skip: $link is not a Warden link"; return 0; }
  target=$(readlink "$link")
  case "$target" in
    "$REPO"/*) ;;
    *) warden_say "skip: $link points at $target"; return 0 ;;
  esac
  warden_run "unlink: $link" rm -f "$link" || return 1
  # REQ-4.2. The newest backup wins, and the names sort by time.
  newest=$(ls -1 "$link".warden-backup-* 2>/dev/null | sort | tail -1)
  if [ -n "$newest" ]; then
    warden_run "restore: $newest -> $link" mv "$newest" "$link"
  fi
}

for name in $WARDEN_SURFACES; do
  unlink_one "$CFG/$name"
done
for name in $WARDEN_DOC_SURFACES; do
  unlink_one "$CFG/docs/$name"
done
unlink_one "$HOME/.local/bin/warden-handoff"

# REQ-4.4. The person decides about the plugins and the binaries.
cat <<'EOF'

The plugins and the monitor binaries are still installed. To remove them:

  claude plugin marketplace remove superpowers-dev
  claude plugin marketplace remove diagram-design
  rm -f $HOME/bin/claude-context-monitor $HOME/bin/claude-statusline
EOF
```

- [ ] **Step 4: Run the test to see it pass**

```bash
chmod +x uninstall.sh
bash tests/uninstall_restores.sh; echo "exit=$?"
```

Expected: `exit=0`.

- [ ] **Step 5: Demonstrate the slice**

```bash
./tests/run.sh
```

Expected: `6 tests, 0 failed`.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: add an uninstaller that restores the displaced files"
```

---

### Slice 6: `./uninstall.sh --from-archive` restores the whole configuration directory

**Satisfies:** REQ-4.5

**Demonstrate with:**

```bash
cd ~/dev/Warden_public && bash tests/uninstall_from_archive.sh
```

**Risk:** A restore replaces a directory. If it removes the excluded directories before unpacking, the person loses every project transcript, which the archive never held. That is the one failure that cannot be undone, and it gets a direct assertion: `projects/` survives a restore. A restore that does not archive the current state first turns one mistake into two, so that gets an assertion too.

**Model:** cheap tier — the files, the test and the code are all stated here.

**Files:**
- Modify: `uninstall.sh`
- Create: `tests/uninstall_from_archive.sh`

**Interfaces:**
- Consumes: `warden_archive_config`, `warden_backup_dir`, `WARDEN_EXCLUDES` from Slice 2.
- Produces: `uninstall.sh --from-archive <path>` and `uninstall.sh --from-archive` with no path, which lists the archives.

- [ ] **Step 1: Write the failing test**

```bash
#!/usr/bin/env bash
# REQ-4.5. A restore from the archive returns the configuration, not the history.
. "$(dirname "$0")/lib/harness.sh"
harness_setup

printf 'before\n' > "$HOME/.claude/settings.json"
printf 'keep me\n' > "$HOME/.claude/my-notes.md"
mkdir -p "$HOME/.claude/projects/p1"
printf 'transcript\n' > "$HOME/.claude/projects/p1/history.jsonl"

out=$("$REPO_DIR/install.sh" --skip-deps 2>&1)
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

harness_exit
```

- [ ] **Step 2: Run it to see it fail**

```bash
bash tests/uninstall_from_archive.sh; echo "exit=$?"
```

Expected: `FAIL the archived settings.json did not return` and `exit=1`.

- [ ] **Step 3: Add the flag to `uninstall.sh`**

Replace the option loop with:

```bash
FROM_ARCHIVE=""
WANT_ARCHIVE=0

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) WARDEN_DRY_RUN=1 ;;
    --from-archive)
      WANT_ARCHIVE=1
      case "${2:-}" in
        ""|--*) ;;
        *) FROM_ARCHIVE="$2"; shift ;;
      esac ;;
    -h|--help) sed -n '2,6p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) warden_die "unknown option: $1" ;;
  esac
  shift
done
export WARDEN_DRY_RUN
```

Then add, before the per-link loop:

```bash
restore_from_archive() {
  local archive="$1" parent base ex tmp
  [ -f "$archive" ] || warden_die "no such archive: $archive"
  # REQ-4.5.2
  warden_say "archiving the current state first"
  warden_say "archive: $(warden_archive_config "$CFG" "$(warden_backup_dir)")"

  # REQ-4.5.3. Remove only what the archive can put back.
  for entry in "$CFG"/* "$CFG"/.[!.]*; do
    [ -e "$entry" ] || continue
    base=$(basename "$entry")
    skip=0
    for ex in $WARDEN_EXCLUDES; do
      [ "$base" = "$ex" ] && skip=1
    done
    [ "$skip" = "1" ] && continue
    warden_run "remove: $entry" rm -rf "$entry"
  done

  parent=$(dirname "$CFG")
  warden_run "restore: $archive -> $CFG" tar xzf "$archive" -C "$parent"
  warden_say "restored from $archive"
}

if [ "$WANT_ARCHIVE" = "1" ]; then
  if [ -z "$FROM_ARCHIVE" ]; then
    warden_say "archives under $(warden_backup_dir):"
    ls -1t "$(warden_backup_dir)"/claude-*.tar.gz 2>/dev/null | head -10 \
      || warden_say "  none"
    exit 0
  fi
  restore_from_archive "$FROM_ARCHIVE"
  exit 0
fi
```

- [ ] **Step 4: Run the test to see it pass**

```bash
bash tests/uninstall_from_archive.sh; echo "exit=$?"
```

Expected: `exit=0`.

- [ ] **Step 5: Demonstrate the slice**

```bash
./tests/run.sh
```

Expected: `7 tests, 0 failed`.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: restore the whole configuration directory from an archive"
```

---

### Slice 7: The vendored superpowers plugin, with its licence and its notice

**Satisfies:** REQ-7

**Demonstrate with:**

```bash
cd ~/dev/Warden_public && bash tests/vendored_license.sh && ls plugins/superpowers/skills | head
```

**Risk:** Publishing someone else's MIT code without the licence is a licence violation, and it is invisible until someone complains. The test asserts the licence file matches upstream byte for byte, that the copyright line names Jesse Vincent, and that `NOTICE.md` names both repositories. A stray `.git` directory inside the vendored copy would confuse `git add`, so that gets an assertion too.

**Model:** cheap tier — the files, the test and the code are all stated here.

**Files:**
- Create: `plugins/superpowers/` (copied), `plugins/superpowers/NOTICE.md`, `tests/vendored_license.sh`

**Interfaces:**
- Produces: `plugins/superpowers/.claude-plugin/marketplace.json` names the marketplace `superpowers-dev`, which is what `settings.json` already names in `enabledPlugins`.

- [ ] **Step 1: Copy the fork, without its git history**

```bash
cd ~/dev/Warden_public
mkdir -p plugins
rsync -a --exclude '.git' --exclude '.DS_Store' ~/dev/superpowers2/ plugins/superpowers/
find plugins/superpowers -name .DS_Store -delete
test ! -d plugins/superpowers/.git && echo "no git directory: ok"
```

- [ ] **Step 2: Write `plugins/superpowers/NOTICE.md`**

```markdown
# Notice

This directory holds a vendored copy of the Superpowers plugin.

- **Origin:** [obra/superpowers](https://github.com/obra/superpowers) by Jesse Vincent, MIT.
- **Upstream of this copy:** [BlastBlastBlast/more_superpowers](https://github.com/BlastBlastBlast/more_superpowers).
- **Modified:** yes. The copy carries changes that are not in `obra/superpowers`.

`LICENSE` is the upstream MIT licence, unchanged. The plugin keeps the name `superpowers`,
because every skill reference in this setup reads `superpowers:<skill>`.

To refresh this copy, pull `more_superpowers` and copy it here again, without its `.git`
directory.
```

- [ ] **Step 3: Write the failing test**

```bash
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
```

- [ ] **Step 4: Run the test**

```bash
bash tests/vendored_license.sh; echo "exit=$?"
```

Expected: `exit=0`. If `assert_absent "$V/.git"` fails, the `rsync` exclude did not take. Remove the directory and re-run.

- [ ] **Step 5: Check the vendored copy holds no machine path**

```bash
git add -A
bash tests/no_machine_content.sh; echo "exit=$?"
```

Expected: `exit=0`. If a vendored file names a home directory, that file is a test fixture inside the plugin. Add its path to the exclusion list in `tests/no_machine_content.sh` with a comment naming the reason, and re-run.

- [ ] **Step 6: Demonstrate the slice**

```bash
./tests/run.sh
```

Expected: `8 tests, 0 failed`.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "feat: vendor the superpowers plugin with its licence and notice"
```

---

### Slice 8: The README, and a pre-commit hook that keeps the repository clean

**Satisfies:** REQ-8, ruling C1-a

**Demonstrate with:**

```bash
cd ~/dev/Warden_public && bash tests/readme_sections.sh && git config core.hooksPath
```

**Risk:** The README is the only thing a stranger reads before running a script that rewrites their configuration directory. A missing platform warning costs them a broken machine. The pre-commit hook is the guard the C1 ruling bought, and a hook that is present but not wired is worse than no hook, because it looks like protection. The test asserts both the hook file and the `core.hooksPath` setting the installer writes.

**Model:** standard tier — the README is prose written from the repository's own contents.

**Files:**
- Create: `README.md`, `LICENSE`, `.githooks/pre-commit`, `tests/readme_sections.sh`
- Modify: `install.sh` (offer to set `core.hooksPath`)

**Interfaces:**
- Consumes: nothing new.
- Produces: `install.sh --skip-plugin-hook` skips the git hook step, for a person who installs from a directory that is not a git checkout.

- [ ] **Step 1: Write `LICENSE`**

Standard MIT, `Copyright (c) 2026 Lars`. The vendored plugin keeps its own `LICENSE`, which this file does not replace.

- [ ] **Step 2: Write `.githooks/pre-commit`**

```bash
#!/usr/bin/env bash
# Refuse a commit that would publish a machine path or a private marketplace.
repo=$(git rev-parse --show-toplevel)
if ! bash "$repo/tests/no_machine_content.sh"; then
  printf '\nCommit refused. The scrub check failed. Fix the files above.\n' >&2
  exit 1
fi
```

- [ ] **Step 3: Write `README.md`**

The file starts with the image, above the first heading, and holds these headings in this order.

````markdown
<p align="center">
  <img src="assets/warden.png" alt="A knight in full plate armour and a great helm, drawn in black and bone white against a red ground, with red eyes behind the visor." width="640">
</p>

# Warden

A complete Claude Code setup in one folder. Clone it, run one command, and a new computer
behaves like the old one.

## Install

```bash
git clone https://github.com/BlastBlastBlast/Warden_public.git
cd Warden_public
./install.sh --dry-run    # see what it would do
./install.sh              # do it
```

The installer supports macOS and Linux. Windows is not supported: the hooks and the tools are
bash scripts.

Claude can run the install for you. Open Claude Code in the clone and say "install this".
Claude reads `INSTALL.md`, tells you every path it will write to, and waits for your consent.

## What the installer does to your computer

| Path | What happens |
|---|---|
| `$HOME/.warden-backups/claude-<stamp>.tar.gz` | Your whole Claude configuration directory, archived before the first change. |
| `${CLAUDE_CONFIG_DIR:-$HOME/.claude}` | Ten symbolic links into this repository. Anything displaced is renamed, never removed. |
| `$HOME/.local/bin/warden-handoff` | A link to the handoff tool. |
| `$HOME/bin` | The two context-monitor binaries, checksum-verified. |

## Reverting

```bash
./uninstall.sh                      # remove the links, put back what they displaced
./uninstall.sh --from-archive       # list the archives
./uninstall.sh --from-archive <path>   # restore the whole directory from one
```

A restore returns your configuration. It leaves `projects/`, `sessions/` and the other caches
alone, because the archive never held them.

## Layout

| Path | Links to | Holds |
|---|---|---|
| `CLAUDE.md` | the config directory | Always-on instructions, under 60 lines |
| `settings.json` | the config directory | Attribution, permissions, wired hooks, subagent caps |
| `hooks/` | the config directory | Two wired secret guards, one unwired branch guard |
| `output-styles/` | the config directory | `plain-technical`, the writing discipline |
| `rules/` | the config directory | `instruction-files.md`, path-scoped |
| `skills/` | the config directory | Skills the superpowers plugin does not cover |
| `docs/references/` | the config directory | Reference files the rules load |
| `docs/decisions/` | the config directory | Why this setup is shaped the way it is |
| `bin/` | the config directory | `warden-handoff`, `warden-statusline` |
| `plugins/superpowers/` | not linked | The vendored method plugin |

## Wired hooks

| Hook | Event | Blocks |
|---|---|---|
| `guard-secrets.sh` | PreToolUse Write, Edit | A write carrying a private-key header, an AWS key id, or a 32-character bearer token. Skips fixtures and `*.example`. |
| `guard-secrets-read.sh` | PreToolUse Bash | A shell command that puts a secret file in front of the model. Excludes `ls`, `wc`, `cp`, and `.env.example`. |
| `claude-context-monitor` | PostToolUse | Nothing. It warns at 35 percent context remaining and goes critical at 25 percent. |
| `warden-handoff hook` | SessionStart | Nothing. It offers a waiting handoff after `/clear`, once. |

`hooks/guard-default-branch.sh` ships but is not wired. It denies edits on the default branch.

## Skills

| Skill | Fires when |
|---|---|
| `crit` | You review code, a plan, or a page with inline comments. |
| `crit-cli` | An agent authors or replies to crit comments. |
| `design-taste-frontend` | You build a landing page, a marketing site, or a portfolio. |
| `eli5` | You ask for a dead-simple picture explainer. |
| `emil-design-eng` | You build product UI: dashboards, tables, forms, wizards. |
| `handoff` | You end a session and want to continue in a fresh one. |
| `model-update` | A new Claude model ships, or you evaluate the setup against one. |
| `review-animations` | You review motion and transitions. |
| `source-authority` | You are about to state a version, a flag, or a default from memory. |

## Status line

Two lines:

```
Opus 5 │ Warden ⎇ main
5h 7% · 4h24m   7d 41% · 2d5h
```

Line one is `claude-statusline` from `stigsb/claude-context-monitor`. Line two is ours: plan
usage from the `rate_limits` payload, dim under 50 percent, yellow from 50, red from 80. Line
two is absent when Claude Code sends no rate limit.

## Tools this setup draws on

| Tool | What it does | Installed |
|---|---|---|
| [obra/superpowers](https://github.com/obra/superpowers) | Gives an agent skills that fire on their own, for planning, test-first work and debugging. | Yes, as a vendored fork |
| [cathrynlavery/diagram-design](https://github.com/cathrynlavery/diagram-design) | Draws a figure to a named visual type, and holds the drawing to that type's rules. | Yes |
| [stigsb/claude-context-monitor](https://github.com/stigsb/claude-context-monitor) | Shows how much context window remains, to the person and to the agent. | Yes |
| [github/spec-kit](https://github.com/github/spec-kit) | Starts a change from a written specification, then builds the code to match it. | No |
| [danyuchn/asd-ste100-skill](https://github.com/danyuchn/asd-ste100-skill) | Rewrites English to ASD-STE100, and lints a document against the standard. | No |
| [Graphify-Labs/graphify](https://github.com/Graphify-Labs/graphify) | Turns a codebase and its documents into a knowledge graph an agent can query. | No |
| [stablyai/orca](https://github.com/stablyai/orca) | Runs several coding agents at once, each one in its own worktree. | No |
| [manaflow-ai/cmux](https://github.com/manaflow-ai/cmux) | Holds several agent sessions in one macOS terminal, with vertical tabs and notifications. | No |
| [firecrawl/pdf-inspector](https://github.com/firecrawl/pdf-inspector) | Tells a scanned PDF from a text PDF, then extracts the text as Markdown. | No |
| [anthropics/claude-plugins-community](https://github.com/anthropics/claude-plugins-community) | A community marketplace of Claude Code plugins. | No |

## Licence

The files in this repository are MIT. `plugins/superpowers/` is a vendored copy of
`obra/superpowers` by Jesse Vincent, also MIT. See `plugins/superpowers/NOTICE.md`.
````

- [ ] **Step 4: Write the failing test**

```bash
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
```

- [ ] **Step 5: Run the test**

```bash
bash tests/readme_sections.sh; echo "exit=$?"
```

Expected: `exit=0`. If a skill directory is missing from the table, add the row rather than relaxing the test.

- [ ] **Step 6: Add the git hook step to `install.sh`**

Before the summary line:

```bash
install_git_hook() {
  [ -d "$REPO/.git" ] || { warden_say "skip: the repository is not a git checkout"; return 0; }
  local current
  current=$(git -C "$REPO" config --get core.hooksPath 2>/dev/null)
  [ "$current" = ".githooks" ] && { warden_say "keep: core.hooksPath is .githooks"; return 0; }
  warden_run "set core.hooksPath to .githooks" \
    git -C "$REPO" config core.hooksPath .githooks
}
[ "${SKIP_PLUGIN_HOOK:-0}" = "1" ] || install_git_hook
```

Add the flag to the option loop:

```bash
    --skip-plugin-hook) SKIP_PLUGIN_HOOK=1 ;;
```

and `SKIP_PLUGIN_HOOK=0` beside the other defaults.

- [ ] **Step 7: Wire the hook in this checkout and prove it blocks**

```bash
chmod +x .githooks/pre-commit
git config core.hooksPath .githooks
printf '\n<!-- /Users/<name>/x -->\n' >> README.md
git add README.md
git commit -m "chore: this should fail"; echo "exit=$?"
git checkout README.md
```

Expected: `Commit refused. The scrub check failed.` and a non-zero exit.

- [ ] **Step 8: Demonstrate the slice**

```bash
./tests/run.sh && git config core.hooksPath
```

Expected: `9 tests, 0 failed` and `.githooks`.

- [ ] **Step 9: Commit**

```bash
git add -A
git commit -m "docs: add the README, the licence and the scrub pre-commit hook"
```

---

### Slice 9: `INSTALL.md`, the procedure Claude follows

**Satisfies:** REQ-5

**Demonstrate with:**

```bash
cd ~/dev/Warden_public && cat INSTALL.md
```

Then, in a Claude Code session opened in the clone, say "install this" and watch Claude stop at the consent point.

**Risk:** This file tells an agent to modify the person's computer. The failure that matters is an agent that starts writing before the person agrees. REQ-5.2 is the whole point of the file, and the demonstration is a real run that stops. The file is prose, so there is no unit test. A test that greps for headings would pass on a file that says the wrong thing.

**Model:** standard tier — the file is prose that must be unambiguous to an agent.

**Files:**
- Create: `INSTALL.md`

**Interfaces:**
- Consumes: `install.sh` and its flags from Slices 1 to 8.

- [ ] **Step 1: Write `INSTALL.md`**

```markdown
# Installing Warden, with Claude

Claude: follow this file exactly. Do not improvise the steps.

## Step 1. Read the situation

Run these and read the output.

```bash
uname -s; uname -m
ls -la "${CLAUDE_CONFIG_DIR:-$HOME/.claude}" 2>/dev/null | head -40
./install.sh --dry-run
```

## Step 2. Tell the person what will change, then stop

Say all of this, in your own words, before you write anything:

1. The installer archives their whole Claude configuration directory to
   `$HOME/.warden-backups/claude-<timestamp>.tar.gz`. Name the exact directory.
2. It replaces these paths with links into this repository. List every path the dry run
   printed.
3. Anything it displaces is renamed to `<name>.warden-backup-<timestamp>`, not removed.
4. It registers two plugin marketplaces through the `claude` CLI.
5. It downloads two binaries from `stigsb/claude-context-monitor` into `$HOME/bin`, and checks
   them against the release checksums.
6. `./uninstall.sh` reverses all of it.

Then ask: "Shall I run it?"

**Stop here. Write nothing until the person agrees.** A question is not consent. A "sounds
interesting" is not consent.

## Step 3. Run the installer

Do not reproduce the install steps by hand. One implementation carries the behaviour.

```bash
./install.sh
```

## Step 4. Check the result, and report

Run these:

```bash
ls -la "${CLAUDE_CONFIG_DIR:-$HOME/.claude}" | grep -- '->'
ls -la "$HOME/bin"
ls -la "$HOME/.warden-backups"
```

Report what you see. If a check fails, say which one and show the output.

**Do not correct a failed check.** Report it. The person decides what to do next. A repair
made without their knowledge is the failure this step exists to prevent.

## Step 5. Tell them what to do next

- Start a new Claude Code session, so the new `settings.json` loads.
- The status line should show two lines.
- `./uninstall.sh` is the way back, and `$HOME/.warden-backups` holds the archive.
```

- [ ] **Step 2: Check the file against REQ-5**

Read `INSTALL.md` against these four, and fix anything that fails:

- REQ-5.1: Step 2 names every path before any change. Yes, items 1 to 5.
- REQ-5.2: Step 2 ends with an explicit stop. Yes.
- REQ-5.3: Step 3 runs `install.sh` and forbids reproducing the steps. Yes.
- REQ-5.4: Step 4 says to report a failed check rather than to correct it. Yes.

- [ ] **Step 3: Run the controlled-language check**

```bash
python3 ~/dev/superpowers2/skills/asd-ste100/scripts/ste-lint.py INSTALL.md
```

Expected: zero hard violations. Fix any that appear.

- [ ] **Step 4: Demonstrate the slice**

Open a Claude Code session in the clone and say "install this". Expected: Claude reads
`INSTALL.md`, prints the dry run, lists every path, and stops to ask.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "docs: add the Claude-driven install procedure"
```

- [ ] **Step 6: Run the whole suite one last time**

```bash
./tests/run.sh
```

Expected: `9 tests, 0 failed`.

---

## Risks, worst first

1. **A private path reaches the public repository.** `settings.json` is symlinked into the
   configuration directory, and Claude Code writes to that file by itself. The C1-a ruling puts
   a pre-commit hook in the way, and Slice 8 proves the hook blocks. The residual risk is a
   person who clones the repository and never runs the installer, so `core.hooksPath` is never
   set. The README does not currently warn about that. Accept it, or add a line to the README
   during Slice 8.

2. **The uninstaller removes a file it did not create.** `unlink_one` only removes a link whose
   target starts with the repository path. Slice 5 asserts a foreign file and a foreign link
   both survive. The residual risk is a person who moved the repository after installing, which
   leaves a dangling link the uninstaller then skips rather than cleans.

3. **The archive silently omits something.** `tar` differs between BSD and GNU. Slice 2 asserts
   the archive holds a seeded file, stores a link as a link, and excludes `projects/`. The
   residual risk is a file type neither the test nor the author thought of, such as a socket.

4. **The vendored plugin drifts from `more_superpowers`.** Nothing detects it. The refresh is a
   manual copy, documented in `NOTICE.md`. A stale copy is a correctness problem, not a safety
   one.

5. **The monitor release changes its asset naming.** `install_monitor` matches on the suffix
   `_<os>_<arch>.tar.gz`. A rename upstream breaks the match, and REQ-2.5 turns that into a
   clean stop rather than a wrong binary.

## What I ruled out

- **Vendoring the monitor binaries.** They are 4.2 MB of Mach-O per platform, and six platforms
  ship. The repository would carry 25 MB of binaries that go stale on every release.
- **A git submodule for the superpowers fork.** A submodule needs a second clone step and a
  public `more_superpowers` at clone time. A vendored copy works from the tarball GitHub serves
  for a release.
- **Generating `settings.json` from a template.** That is option C1-b, which Lars ruled against.
  It would make a repository edit stop being live.
- **`bats` for the test suite.** It is one more thing to install before the tests run. Plain
  bash with four assertion helpers covers what these tests assert.
- **Testing the hooks themselves.** `guard-secrets.sh` and `guard-secrets-read.sh` come from
  `~/dev/Warden` unchanged. Testing them is a separate change against that repository.

## Self-review

- **Spec coverage.** REQ-1 Slice 1 and 2. REQ-2 Slice 4. REQ-3 Slice 1, 2 and 3. REQ-4 Slice 5
  and 6. REQ-5 Slice 9. REQ-6 Slice 1. REQ-7 Slice 7. REQ-8 Slice 8. REQ-9 Slice 1, extended by
  every later slice. No gap.
- **Vertical check.** Every slice title names something a person can watch: a dry run, a link,
  a second run that does nothing, a download, a restore, a licence check, a README, a stop.
- **Slice one check.** Slice 1 ends in `./install.sh --dry-run` printing the whole plan. The
  shape of the change is visible in the first slice.
- **Placeholder scan.** No TBD, no "add error handling", no "similar to Slice N". Every code
  step carries the code.
- **Type consistency.** `warden_link`, `warden_archive_config`, `warden_backup_path`,
  `unlink_one`, `restore_from_archive`, `install_plugins`, `install_monitor`,
  `install_git_hook`, `check_prereqs`, `sha256_of` are each defined once and used with the same
  name afterwards. `WARDEN_SURFACES`, `WARDEN_DOC_SURFACES` and `WARDEN_EXCLUDES` are defined in
  `lib/warden-common.sh` and read in both scripts.
- **Test sizing.** Nine test files, twelve risks named across nine slices. The counts track the
  risks, not the files: `install_deps.sh` carries three cases because the download has three
  ways to hurt someone, and `vendored_license.sh` carries a licence assertion rather than one
  assertion per vendored file.
