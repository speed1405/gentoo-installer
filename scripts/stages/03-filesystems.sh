# scripts/stages/03-filesystems.sh
set -euo pipefail
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/ui.sh"
source "$LIB_DIR/disk.sh"

run() {
  log "[fs] Formatting partitions"
  # Device naming:
  # nvme -> nvme0n1p1
  # sata -> sda1
  if [[ "$DISK" == *"nvme"* ]]; then
    EFI_DEV="${DISK}p1"
    SWAP_DEV="${DISK}p2"
    ROOT_DEV="${DISK}p3"
  else
    EFI_DEV="${DISK}1"
    SWAP_DEV="${DISK}2"
    ROOT_DEV="${DISK}3"
  fi
  mkfs_partitions "$EFI_DEV" "$SWAP_DEV" "$ROOT_DEV" "${FILESYSTEM:-ext4}"
  log "[fs] Done"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then run; fi
