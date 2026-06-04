# scripts/stages/07-base.sh
set -euo pipefail
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/ui.sh"

run() {
  log "[base] Writing locale/timezone and user accounts"
  : "${MNT_ROOT:=/mnt/gentoo}"

  echo "$TIMEZONE" > "$MNT_ROOT/etc/timezone"
  chroot "$MNT_ROOT" emerge --config sys-libs/timezone-data >/dev/null 2>&1 || true

  # TODO: locale-gen / eselect locale set $LOCALE

  echo "$HOSTNAME" > "$MNT_ROOT/etc/conf.d/hostname"

  # root password
  chroot "$MNT_ROOT" bash -lc "echo 'root:${ROOT_PASSWORD:-changeme}' | chpasswd"

  # user
  chroot "$MNT_ROOT" useradd -m -G wheel,audio,video,portage -s /bin/bash "$USERNAME" || true
  chroot "$MNT_ROOT" bash -lc "echo '${USERNAME}:${USER_PASSWORD:-changeme}' | chpasswd"

  chroot "$MNT_ROOT" emerge --ask=n sys-apps/sudo >=app-admin/sudo-1.9 || true

  log "[base] Done"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then run; fi
