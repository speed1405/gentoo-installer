# scripts/stages/01-disk.sh — disk selection
set -euo pipefail
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/ui.sh"
source "$LIB_DIR/disk.sh"

run() {
  log "[disk] Selecting target disk"
  DISK=$(select_disk)
  log "[disk] Selected $DISK"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then run; fi
