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
