# scripts/stages/06-kernel.sh
set -euo pipefail
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/ui.sh"

run() {
  log "[kernel] Installing kernel and bootloader"
  : "${MNT_ROOT:=/mnt/gentoo}"

  # Dummy kernel package install
  cat > "$MNT_ROOT/etc/portage/package.accept_keywords/kernel" <<'EOF'
sys-kernel/gentoo-sources
sys-kernel/genkernel
sys-boot/grub
EOF

  chroot "$MNT_ROOT" emerge --ask=n --verbose sys-kernel/gentoo-sources sys-boot/grub || true

  # TODO: mount binfmt if needed, run 'make', initramfs, grub-install, grub-mkconfig

  log "[kernel] Done"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then run; fi
