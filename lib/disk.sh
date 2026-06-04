#!/usr/bin/env bash
# lib/disk.sh — disk + partition helpers

require_root() {
  [[ $EUID -eq 0 ]] || die "This must be run as root."
}

list_disks() {
  local -a disks=()
  if command -v lsblk >/dev/null 2>&1; then
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      disks+=("$line")
    done < <(lsblk -dno NAME,SIZE,TYPE,MODEL | grep -E 'disk|TYPE.*disk')
  fi
  echo "${disks[@]}"
}

select_disk() {
  require_root
  ui_header "Disk Selection\nThis installer will wipe the selected disk."
  local disks_out
  disks_out=$(list_disks)
  [[ -z "$disks_out" ]] && die "No disks found."

  local -a menu_items=()
  local i=0
  while IFS= read -r line; do
    local name size model
    read -r name size model <<<"$line"
    local dev="/dev/$name"
    menu_items+=("$dev" "$model (${size})")
    ((i++))
  done <<<"$disks_out"

  local disk
  disk=$(ui_radiolist "Select Target Disk" "Choose the disk to install to:" "${menu_items[@]}")
  [[ -z "$disk" ]] && die "No disk selected."
  echo "$disk"
}

wipe_disk() {
  local disk="$1"
  ui_yesno "Confirm Wipe" "THIS WILL ERASE ALL DATA ON:\n\n$disk\n\nType YES to confirm." || die "User cancelled disk wipe."
  wipefs -a "$disk" || die "Failed to wipe $disk"
  log "Wiped disk $disk"
}

create_partitions() {
  local disk="$1"
  local efi_size="${2:-512M}"
  local swap_size="${3:-4G}"
  local root_rest="${4:-remaining}"

  require_root

  if [[ "$disk" == *"nvme"* ]]; then
    local part1="${disk}p1"
    local part2="${disk}p2"
    local part3="${disk}p3"
  else
    local part1="${disk}1"
    local part2="${disk}2"
    local part3="${disk}3"
  fi

  # Wipe and create GPT
  wipe_disk "$disk"
  parted -s "$disk" mklabel gpt

  # EFI System Partition
  parted -s "$disk" mkpart ESP fat32 1MiB "${efi_size}"
  parted -s "$disk" set 1 esp on
  parted -s "$disk" set 1 boot on

  # Swap
  local swap_end
  swap_end=$(numfmt --from=iec="${swap_size}" 2>/dev/null || echo 4294967296)
  if [[ "$root_rest" == "remaining" ]]; then
    parted -s "$disk" mkpart primary linux-swap "${efi_size}" "$(($(numfmt --from=iec="${swap_size}" 2>/dev/null || echo 4294967296) / 1024 / 1024))MiB"
  else
    parted -s "$disk" mkpart primary linux-swap "${efi_size}" "$(($(numfmt --from=iec="${swap_size}" 2>/dev/null || echo 4294967296) / 1024 / 1024))MiB"
  fi
  parted -s "$disk" set 2 swap on

  # Root — remaining space
  if [[ "$root_rest" == "remaining" ]]; then
    parted -s "$disk" mkpart primary ext4 100%
  else
    parted -s "$disk" mkpart primary ext4 "$(($(numfmt --from=iec="${swap_size}" 2>/dev/null || echo 4294967296) / 1024 / 1024))MiB" 100%
  fi

  log "Partitions created on $disk"
}

mkfs_partitions() {
  local efi_dev="$1"
  local swap_dev="$2"
  local root_dev="$3"
  local fs_type="${4:-ext4}"

  require_root

  mkfs.vfat -F32 "$efi_dev" || die "Failed to format ESP"
  mkswap "$swap_dev" || die "Failed to init swap"
  swapon "$swap_dev" || true

  case "$fs_type" in
    ext4) mkfs.ext4 -F "$root_dev" ;;
    xfs)  mkfs.xfs -f "$root_dev" ;;
    btrfs) mkfs.btrfs -f "$root_dev" ;;
    f2fs) mkfs.f2fs "$root_dev" ;;
    *) die "Unknown filesystem: $fs_type" ;;
  esac

  log "Filesystems created on $efi_dev / $swap_dev / $root_dev"
}
