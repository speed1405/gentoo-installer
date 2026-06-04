# scripts/stages/05-portage.sh
set -euo pipefail
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/ui.sh"

run() {
  log "[portage] Configuring make.conf and syncing"
  : "${MNT_ROOT:=/mnt/gentoo}"

  mkdir -p "$MNT_ROOT/etc/portage"
  cat > "$MNT_ROOT/etc/portage/make.conf" <<EOF
COMMON_FLAGS="${COMMON_FLAGS:-"-O2 -march=native -pipe"}"
CFLAGS="\${COMMON_FLAGS}"
CXXFLAGS="\${COMMON_FLAGS}"
MAKEOPTS="-j\$(nproc)"
ACCEPT_LICENSE="${ACCEPT_LICENSE:-*}"
EOF

  if [[ -n "${BINHOST_MIRROR:-}" ]]; then
    echo 'FETCHCOMMAND="curl -L -O"' >> "$MNT_ROOT/etc/portage/make.conf"
  fi

  chroot "$MNT_ROOT" emerge --sync || true
  log "[portage] Done"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then run; fi
