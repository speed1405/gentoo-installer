#!/usr/bin/env bash
# scripts/stages/13-xfce4.sh — xfce4 preset (stub for now)
set -euo pipefail
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/ui.sh"

run() {
  log "[xfce4] Xfce4 preset selected; not yet implemented"
  ui_success "Xfce4 desktop is planned but not implemented yet"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then run; fi
