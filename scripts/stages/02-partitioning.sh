# scripts/stages/02-partitioning.sh
set -euo pipefail
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/ui.sh"
source "$LIB_DIR/disk.sh"

run() {
  log "[partition] Creating partitions on $DISK"
  create_partitions "$DISK" "${EFI_SIZE:-512M}" "${SWAP_SIZE:-4G}" remaining
  log "[partition] Done"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then run; fi
