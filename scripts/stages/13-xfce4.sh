#!/usr/bin/env bash
# scripts/stages/13-xfce4.sh — xfce4 desktop preset
set -euo pipefail
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/ui.sh"

install_xfce4() {
  chroot "$MNT_ROOT" emerge --ask=n --verbose \
    xfce-base/xfce4-meta \
    x11-misc/lightdm \
    x11-misc/lightdm-gtk-greeter \
    >=media-fonts/terminus-font \
    || die "Failed to emerge xfce4 preset"

  chroot "$MNT_ROOT" bash -lc "eselect font enable ter-* || true"

  local user_home
  user_home=$(eval echo "~${USERNAME:-user}")

  local cfg_src="$INSTALLER_DIR/desktop/xfce4-config.tar.gz"
  local cfg_dest="${user_home}/.config/xfce4"

  if [[ -f "$cfg_src" ]]; then
    chroot "$MNT_ROOT" mkdir -p "$cfg_dest"
    tmpdir=$(mktemp -d)
    tar xzf "$cfg_src" -C "$tmpdir"
    find "$tmpdir" -mindepth 1 -maxdepth 1 -exec cp -a {} "$MNT_ROOT${cfg_dest}/" \;
    chroot "$MNT_ROOT" chown -R "${USERNAME:-user}:${USERNAME:-user}" "$cfg_dest"
    rm -rf "$tmpdir"
  else
    chroot "$MNT_ROOT" bash -lc "mkdir -p ${cfg_dest}"
    chroot "$MNT_ROOT" bash -lc "cat > ${cfg_dest}/xfce4-session.rc <<'TXT'
# Beginner-friendly default: prefer modern look
# Change later in Settings > Session and Startup
TXT"
  fi

  # enable display manager
  chroot "$MNT_ROOT" systemctl enable lightdm || true
}

run() {
  log "[xfce4] Installing xfce4 preset"
  : "${MNT_ROOT:=/mnt/gentoo}"
  : "${USERNAME:=user}"
  install_xfce4

  log "[xfce4] xfce4 preset installed"
}
