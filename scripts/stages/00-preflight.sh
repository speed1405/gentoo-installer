#!/usr/bin/env bash
# scripts/stages/00-preflight.sh
set -euo pipefail
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/ui.sh"
source "$LIB_DIR/disk.sh"

export DRY_RUN=${DRY_RUN:-0}
export DISABLE_UI=${DISABLE_UI:-0}

preflight() {
  log "[preflight] Starting preflight checks"

  local issues=0

  # Root check
  if [[ $EUID -ne 0 ]]; then
    log "Must run as root"
    ((issues++))
  fi

  # Required commands
  local cmd_ok=0
  for cmd in bash dialog parted gptfdisk network-archive; do
    # network-archive is a placeholder for curl/wget + tar
    if ! command -v "$cmd" >/dev/null 2>&1; then
      log "Missing required tool: $cmd"
      ((issues++))
    fi
  done

  # UEFI/BIOS
  if [[ -d /sys/firmware/efi ]]; then
    log "[preflight] UEFI detected"
    SETUP_UEFI=1
  else
    log "[preflight] BIOS mode detected"
    SETUP_UEFI=0
  fi

  # Disk space check on live root
  local avail_mb
  avail_mb=$(df -m / | tail -1 | awk '{print $4}')
  if (( avail_mb < 4096 )); then
    log "Low disk space in live root: ${avail_mb} MB"
    ((issues++))
  fi

  if (( issues > 0 )); then
    ui_die "Preflight found $issues issues. Check $LOG_FILE for details."
  fi

  ui_success "Preflight passed: $(( issues )) issues"
  log "[preflight] Passed"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  preflight
fi
