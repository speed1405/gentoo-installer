#!/usr/bin/env bash
# scripts/stages/07-base.sh
set -euo pipefail
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/ui.sh"

run() {
  log "[base] Writing locale/timezone and user accounts"
  : "${MNT_ROOT:=/mnt/gentoo}"

  echo "$TIMEZONE" > "$MNT_ROOT/etc/timezone"
  chroot "$MNT_ROOT" emerge --config sys-libs/timezone-data >/dev/null 2>&1 || die "timezone-data configure failed"

  # Generate locale and set system default
  {
    echo "${LOCALE:-en_US.UTF-8} UTF-8"
    echo "en_US ISO-8859-1"
  } > "$MNT_ROOT/etc/locale.gen"
  chroot "$MNT_ROOT" locale-gen || die "locale-gen failed"
  chroot "$MNT_ROOT" bash -lc "eselect locale set ${LOCALE:-en_US.utf8}" || die "eselect locale failed"

  # LANG env
  cat > "$MNT_ROOT/etc/env.d/02locale" <<EOF
LANG="${LANG:-en_US.UTF-8}"
EOF

  echo "$HOSTNAME" > "$MNT_ROOT/etc/conf.d/hostname"

  # root password
  chroot "$MNT_ROOT" bash -lc "echo 'root:${ROOT_PASSWORD:-changeme}' | chpasswd" || die "root password set failed"

  # user
  chroot "$MNT_ROOT" useradd -m -G wheel,audio,video,portage -s /bin/bash "$USERNAME" || die "useradd failed"
  chroot "$MNT_ROOT" bash -lc "echo '${USERNAME}:${USER_PASSWORD:-changeme}' | chpasswd" || die "user password set failed"

  chroot "$MNT_ROOT" emerge --ask=n sys-apps/sudo >=app-admin/sudo-1.9 || die "sudo install failed"

  log "[base] Done"
}
