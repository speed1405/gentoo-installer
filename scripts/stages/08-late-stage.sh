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

prompt_desktop() {
  local choice
  choice=$(ui_menu "Desktop" "Choose a desktop setup:" \
    "none" "None (skip)" \
    "dwm" "dwm + polybar (minimal)" \
    "sway" "Sway Wayland" \
    "xfce4" "Xfce4" \
    "gnome" "GNOME (heavy)" \
    "kde" "KDE Plasma (heavy)") || true
  echo "${choice:-${INSTALL_DESKTOP:-none}}"
}

run() {
  log "[late] Running late stage options"
  : "${MNT_ROOT:=/mnt/gentoo}"

  if [[ "${INSTALL_DESKTOP:-}" == "none" || -z "${INSTALL_DESKTOP:-}" ]]; then
    DESKTOP_CHOICE=$(prompt_desktop)
    export DESKTOP_CHOICE
    case "$DESKTOP_CHOICE" in
      dwm|sway|xfce4|gnome|kde)
        INSTALL_DESKTOP="$DESKTOP_CHOICE"
        export INSTALL_DESKTOP
        ;;
      *)
        log "[late] Skipping desktop install by user choice"
        ;;
    esac
  fi

  if [[ "${INSTALL_DESKTOP:-none}" != "none" ]]; then
    log "[late] Installing desktop preset: $INSTALL_DESKTOP"
    case "$INSTALL_DESKTOP" in
      dwm) bash "$STAGES_DIR/11-desktop.sh" ;;
      sway) bash "$STAGES_DIR/12-sway.sh" ;;
      xfce4) bash "$STAGES_DIR/13-xfce4.sh" ;;
      *) log "[late] $INSTALL_DESKTOP preset not implemented yet" ;;
    esac
  fi

  if ui_yesno "GPU Drivers" "Do you want to install GPU drivers now?"; then
    local card
    card=$(ui_menu "GPU" "Select card type:" \
      "intel" "Intel" \
      "amd" "AMD" \
      "nvidia" "NVIDIA" \
      "other" "Other") || true
    install_gpu_drivers "${card:-other}"
  fi

  log "[late] Done"
}
