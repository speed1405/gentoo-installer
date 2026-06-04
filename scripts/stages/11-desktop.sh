#!/usr/bin/env bash
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
    || die "Failed to emerge dwm preset"

  chroot "$MNT_ROOT" bash -lc "eselect font enable ter-* || true"

  local user_home
  user_home=$(eval echo "~${USERNAME:-user}")

  local cfg_src="$INSTALLER_DIR/desktop/dwm-config.tar.gz"
  local cfg_dest="${user_home}/.dwm"

  if [[ -f "$cfg_src" ]]; then
    chroot "$MNT_ROOT" mkdir -p "$cfg_dest"
    # Write files directly rather than relying on tar destination semantics
    tmpdir=$(mktemp -d)
    tar xzf "$cfg_src" -C "$tmpdir"
    find "$tmpdir" -mindepth 1 -maxdepth 1 -exec cp -a {} "$MNT_ROOT${cfg_dest}/" \;
    chroot "$MNT_ROOT" chown -R "${USERNAME:-user}:${USERNAME:-user}" "$cfg_dest"
    rm -rf "$tmpdir"
  else
    # Fallback: basic autostart and xinitrc
    chroot "$MNT_ROOT" bash -lc "mkdir -p ${cfg_dest}"
    chroot "$MNT_ROOT" bash -lc "cat > ${user_home}/.dwm/autostart.sh <<'EOF'
#!/bin/sh
feh --bg-scale ${user_home}/Pictures/wallpaper.jpg || true
EOF"
    chroot "$MNT_ROOT" bash -lc "chmod +x ${user_home}/.dwm/autostart.sh"
  fi

  # .xinitrc
  chroot "$MNT_ROOT" bash -lc "cat > ${user_home}/.xinitrc <<'EOF'
#!/bin/sh
xrdb -merge ~/.Xresources
exec dwm
EOF"
  chroot "$MNT_ROOT" bash -lc "chmod +x ${user_home}/.xinitrc"
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
