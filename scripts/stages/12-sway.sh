#!/usr/bin/env bash
# scripts/stages/12-sway.sh — sway Wayland preset
set -euo pipefail
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/ui.sh"

install_sway() {
  chroot "$MNT_ROOT" emerge --ask=n --verbose \
    x11-wm/sway \
    x11-misc/waybar \
    x11-misc/fuzzel \
    x11-misc/feh \
    x11-misc/xtrlock \
    >=media-fonts/terminus-font \
    || die "Failed to emerge sway preset"

  chroot "$MNT_ROOT" bash -lc "eselect font enable ter-* || true"

  local user_home
  user_home=$(eval echo "~${USERNAME:-user}")

  local cfg_src="$INSTALLER_DIR/desktop/sway-config.tar.gz"
  local cfg_dest="${user_home}/.config/sway"

  if [[ -f "$cfg_src" ]]; then
    chroot "$MNT_ROOT" mkdir -p "$cfg_dest"
    tmpdir=$(mktemp -d)
    tar xzf "$cfg_src" -C "$tmpdir"
    find "$tmpdir" -mindepth 1 -maxdepth 1 -exec cp -a {} "$MNT_ROOT${cfg_dest}/" \;
    chroot "$MNT_ROOT" chown -R "${USERNAME:-user}:${USERNAME:-user}" "$cfg_dest"
    rm -rf "$tmpdir"
  else
    chroot "$MNT_ROOT" bash -lc "mkdir -p ${cfg_dest}"
    chroot "$MNT_ROOT" bash -lc "cat > ${cfg_dest}/config <<'EOF'
# Autostart
exec_always --no-startup-id feh --bg-scale ${user_home}/Pictures/wallpaper.jpg || true
EOF"
  fi

  # .xinitrc fallback still exists for X11-capable setups
  chroot "$MNT_ROOT" bash -lc "cat > ${user_home}/.xinitrc <<'EOF'
#!/bin/sh
exec sway
EOF"
  chroot "$MNT_ROOT" bash -lc "chmod +x ${user_home}/.xinitrc"
}

run() {
  log "[sway] Installing sway preset"
  : "${MNT_ROOT:=/mnt/gentoo}"
  : "${USERNAME:=user}"
  install_sway

  chroot "$MNT_ROOT" systemctl enable elogind || true
  chroot "$MNT_ROOT" systemctl enable seatd || true

  log "[sway] sway preset installed"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then run; fi
