#!/usr/bin/env bash
# scripts/stages/12-sway.sh — sway Wayland preset (stub for now)
set -euo pipefail
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/ui.sh"

run() {
  log "[sway] Sway preset selected; not yet implemented"
  ui_success "Sway desktop is planned but not implemented yet"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then run; fi
