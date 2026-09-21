#!/usr/bin/env bash
# Helpers shared by install.sh and uninstall.sh. Source this, do not execute it.

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
    warden_say "would $desc"
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

WARDEN_EXCLUDES="projects sessions shell-snapshots paste-cache file-history telemetry cache"

# warden_archive_config <config_dir> <archive_dir>
# Prints the archive path. REQ-3.6.
warden_archive_config() {
  local cfg="$1" dest="$2" stamp out parent base ex args n
  stamp=$(warden_stamp)
  out="$dest/claude-$stamp.tar.gz"
  mkdir -p "$dest" || return 1
  # REQ-3.6.5. Never overwrite an existing archive: two archives can land in
  # the same second, since archiving a small configuration directory takes
  # milliseconds.
  n=2
  while [ -e "$out" ]; do
    out="$dest/claude-$stamp-$n.tar.gz"
    n=$((n + 1))
  done
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
WARDEN_ANNOUNCED_DIRS=""

# warden_link <target> <link_path>
# Every write goes through warden_run, so the same code path serves the real
# run and the dry run. REQ-3.5: the preview prints the rename too.
warden_link() {
  local target="$1" link="$2" backup dir
  dir=$(dirname "$link")
  if [ ! -d "$dir" ]; then
    # Under --dry-run the directory is never created, so announce it once.
    case " $WARDEN_ANNOUNCED_DIRS " in
      *" $dir "*) ;;
      *) warden_run "mkdir: $dir" mkdir -p "$dir" || return 1
         WARDEN_ANNOUNCED_DIRS="$WARDEN_ANNOUNCED_DIRS $dir" ;;
    esac
  fi
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
