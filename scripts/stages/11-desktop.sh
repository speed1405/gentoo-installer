# scripts/stages/11-desktop.sh — dwm + polybar preset
set -euo pipefail
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/ui.sh"

install_dwm() {
  chroot "$MNT_ROOT" emerge --ask=n --verbose \
    x11-wm/dwm \
    x11-misc/dmenu \
    x11-misc/polybar \
    x11-misc/feh \
    x11-misc/xtrlock \
    >=x11-terms/st-0.8.4-r1 \
    >=media-fonts/terminus-font \
    || true

  chroot "$MNT_ROOT" bash -lc "eselect font enable ter-* || true"

  # Defaults user config
  local cfg_src="$INSTALLER_DIR/desktop/dwm-config.tar.gz"
  local cfg_dest="/home/${USERNAME:-user}/.dwm"

  if [[ -f "$cfg_src" ]]; then
    chroot "$MNT_ROOT" mkdir -p "$cfg_dest"
    chroot "$MNT_ROOT" tar xzf "$cfg_src" -C "$cfg_dest" 2>/dev/null || true
    chroot "$MNT_ROOT" chown -R "${USERNAME:-user}:${USERNAME:-user}" "$cfg_dest"
  else
    # Fallback: basic autostart and xinitrc
    chroot "$MNT_ROOT" bash -lc "mkdir -p /home/${USERNAME:-user}/.dwm"
    chroot "$MNT_ROOT" bash -lc "cat > /home/${USERNAME:-user}/.dwm/autostart.sh <<'EOF'\n#!/bin/sh\nfeh --bg-scale /home/${USERNAME:-user}/Pictures/wallpaper.jpg || true\nEOF"
    chroot "$MNT_ROOT" bash -lc "chmod +x /home/${USERNAME:-user}/.dwm/autostart.sh"
  fi

  # .xinitrc if missing
  chroot "$MNT_ROOT" bash -lc "cat > /home/${USERNAME:-user}/.xinitrc <<'EOF'\n#!/bin/sh\nxrdb -merge ~/.Xresources\nexec dwm\nEOF"
  chroot "$MNT_ROOT" bash -lc "chmod +x /home/${USERNAME:-user}/.xinitrc"
}

run() {
  log "[desktop] Installing dwm + polybar preset"
  : "${MNT_ROOT:=/mnt/gentoo}"
  : "${USERNAME:=user}"
  install_dwm

  chroot "$MNT_ROOT" systemctl enable elogind || true
  chroot "$MNT_ROOT" systemctl enable seatd || true

  log "[desktop] dwm preset installed; rebuild with 'make clean install' when editing config.h"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then run; fi
