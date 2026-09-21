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

warden_say "summary: $WARDEN_MADE linked, $WARDEN_KEPT kept, $WARDEN_BACKED_UP backed up"
