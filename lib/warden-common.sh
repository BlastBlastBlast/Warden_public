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
