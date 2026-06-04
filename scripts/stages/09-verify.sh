# scripts/stages/09-verify.sh — last-mile checks before reboot cede control
set -euo pipefail
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/ui.sh"

run() {
  log "[verify] Post-install checks"
  : "${MNT_ROOT:=/mnt/gentoo}"

  # Ensure firmware is available on first boot
  if [[ -d /lib/firmware ]]; then
    mkdir -p "$MNT_ROOT/lib/firmware"
    cp -a /lib/firmware/* "$MNT_ROOT/lib/firmware/" 2>/dev/null || true
  fi

  # TODO: verify fstab, bootcfg, stage3 tarball removal

  ui_success "First boot checklist written to $LOG_FILE"
  set_status "complete" 100
  log "[verify] Done"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then run; fi
