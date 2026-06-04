#!/usr/bin/env bash
# scripts/stages/10-desktop-stub.sh — placeholder expected by the guided workflow
set -euo pipefail
source "$LIB_DIR/logging.sh"

run() {
  log "[stage] 10-desktop-stub executed (no-op)"
  set_status "desktop_stub" 90
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then run; fi
