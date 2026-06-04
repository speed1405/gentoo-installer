#!/usr/bin/env bash
# scripts/stages/08-late-stage.sh — late-stage optional components
set -euo pipefail
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/ui.sh"

install_gpu_drivers() {
  local card="${1:-unknown}"
  log "[late] GPU driver path: $card"

  case "$card" in
    nvidia)
      chroot "$MNT_ROOT" emerge --ask=n --verbose x11-drivers/nvidia-drivers || true
      ;;
    amd|intel)
      chroot "$MNT_ROOT" emerge --ask=n --verbose x11-drivers/xf86-video-amdgpu x11-drivers/xf86-video-intel || true
      ;;
    *)
      chroot "$MNT_ROOT" emerge --ask=n --verbose x11-drivers/xf86-video-vesa || true
      ;;
  esac
}

run() {
  log "[late] Running late stage options"
  : "${MNT_ROOT:=/mnt/gentoo}"

  if [[ "${INSTALL_DESKTOP:-none}" != "none" ]]; then
    bash "$STAGES_DIR/11-desktop.sh"
  fi

  # Firmware prompt is handled in 09-verify.sh; here we expose the prompt for advanced users only
  if ui_yesno "GPU Drivers" "Do you want to install GPU drivers now?"; then
    local card
    card=$(ui_menu "GPU" "Select card type:" \
      "intel" "Intel" \
      "amd" "AMD" \
      "nvidia" "NVIDIA" \
      "other" "Other")
    install_gpu_drivers "$card"
  fi

  log "[late] Done"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then run; fi
