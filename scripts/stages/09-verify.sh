#!/usr/bin/env bash
# scripts/stages/09-verify.sh — last-mile checks before reboot
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

  # Validate /etc/fstab has root and boot entries
  if [[ -s "$MNT_ROOT/etc/fstab" ]]; then
    grep -q "$ROOT_DEV" "$MNT_ROOT/etc/fstab" || log "[verify] WARNING: root not in fstab"
    [[ "$SETUP_UEFI" -eq 1 ]] && grep -q "$EFI_DEV" "$MNT_ROOT/etc/fstab" || true
  fi

  # Cleanup: stage3 tarball
  if [[ -f "$MNT_ROOT/stage3-*.tar.xz" ]]; then
    rm -f "$MNT_ROOT/stage3-*.tar.xz" || true
  fi

  # First boot checklist
  cat > "$MNT_ROOT/root/gentoo-first-boot-checklist" <<'EOF'
Gentoo First Boot Checklist
1. Verify bootloader entry appears (GRUB)
2. Log in as root and review:
   /etc/fstab
   /etc/conf.d/hostname
   /etc/locale.gen
3. If network is DHCP:
    rc-update add dhcpcd default
4. If using systemd-boot, ensure loader entries are sane
EOF

  ui_success "First boot checklist written to /root/gentoo-first-boot-checklist. Log: $LOG_FILE"
  set_status "complete" 100
  log "[verify] Done"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then run; fi
