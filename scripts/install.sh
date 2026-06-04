#!/usr/bin/env bash
# scripts/install.sh — Gentoo Installer Entrypoint

set -euo pipefail

INSTALLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIB_DIR="$INSTALLER_DIR/lib"
STAGES_DIR="$INSTALLER_DIR/scripts/stages"
CONFIG_FILE="${INSTALLER_DIR}/config/install.conf"
LOG_FILE="/var/log/gentoo-install.log"
STATUS_FILE="/tmp/gentoo-install.status"
LOCK_FILE="/tmp/gentoo-install.lock"
export INSTALLER_DIR LIB_DIR STAGES_DIR CONFIG_FILE LOG_FILE STATUS_FILE LOCK_FILE

mkdir -p "$(dirname "$LOG_FILE")" "$(dirname "$STATUS_FILE")" "$(dirname "$LOCK_FILE")"

# Load libraries
for lib in "$LIB_DIR"/*.sh; do
  source "$lib"
done

cleanup() {
  rm -f "$LOCK_FILE"
}
trap cleanup EXIT

main() {
  parse_args "$@"
  load_config
  check_lockfile || die "Another instance is running. Remove $LOCK_FILE if this is stale."
  create_lockfile

  log "=== Gentoo Installer Started ==="
  log "Mode: $MODE"
  log "Config: $CONFIG_FILE"

  case "$MODE" in
    guided)   run_guided ;;
    auto)     run_auto ;;
    dry-run)  run_dry_run ;;
    *)        die "Unknown mode: $MODE" ;;
  esac

  log "=== Gentoo Installer Finished ==="
}

main "$@"
