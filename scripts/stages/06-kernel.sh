#!/usr/bin/env bash
# scripts/stages/06-kernel.sh — kernel, initramfs, and bootloader (GRUB + systemd-boot)
set -euo pipefail
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/ui.sh"

run() {
  log "[kernel] Kernel, initramfs, and bootloader"
  : "${MNT_ROOT:=/mnt/gentoo}"

  mkdir -p "$MNT_ROOT/etc/portage/package.accept_keywords"
  cat > "$MNT_ROOT/etc/portage/package.accept_keywords/kernel" <<'EOF'
sys-kernel/gentoo-sources
sys-kernel/genkernel
sys-boot/grub
sys-boot/systemd-boot
EOF

  chroot "$MNT_ROOT" emerge --ask=n --verbose sys-kernel/gentoo-sources sys-boot/grub sys-boot/systemd-boot || die "emerge kernel/bootloader failed"

  local kver
  kver=$(chroot "$MNT_ROOT" eselect kernel list 2>/dev/null | awk 'NR==2{print $NF}' | sed 's/linux-//') || true
  if [[ -z "$kver" ]]; then
    kver=$(ls "$MNT_ROOT/usr/src/" | head -n1 | sed 's/linux-//') || true
  fi
  if [[ -n "$kver" ]]; then
    chroot "$MNT_ROOT" bash -lc "cd /usr/src/linux-${kver} && make -j\$(nproc) && make modules_install && make install"
  fi

  chroot "$MNT_ROOT" emerge --ask=n sys-kernel/dracut sys-kernel/genkernel || true
  if [[ -x "$MNT_ROOT/usr/bin/dracut" ]]; then
    chroot "$MNT_ROOT" dracut --kver "$kver" /boot/initramfs-"$kver".img || true
  else
    chroot "$MNT_ROOT" genkernel --install initramfs --kernel-ver="$kver" || true
  fi

  case "${BOOTLOADER:-grub}" in
    grub)
      if [[ "$SETUP_UEFI" -eq 1 ]]; then
        mount "$EFI_DEV" "$MNT_ROOT/boot" || true
        chroot "$MNT_ROOT" grub-install --target=x86_64-efi --efi-directory=/boot || die "grub-install failed"
      else
        chroot "$MNT_ROOT" grub-install "$DISK" || die "grub-install failed"
      fi
      chroot "$MNT_ROOT" grub-mkconfig -o /boot/grub/grub.cfg || true
      ;;
    systemd-boot)
      if [[ "$SETUP_UEFI" -ne 1 ]]; then
        die "systemd-boot requires UEFI"
      fi
      mount "$EFI_DEV" "$MNT_ROOT/boot" || true
      bootctl --root="$MNT_ROOT" install || die "bootctl install failed"
      cat > "$MNT_ROOT/boot/loader/entries/gentoo.conf" <<EOF
title   Gentoo
linux   /vmlinuz
initrd  /initramfs-${kver}.img
options root=${ROOT_DEV} ro
EOF
      ;;
    *)
      die "Unsupported bootloader: ${BOOTLOADER:-grub}"
      ;;
  esac

  log "[kernel] Done"
}
