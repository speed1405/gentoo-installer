#!/usr/bin/env bash
# scripts/stages/04-stage3.sh
set -euo pipefail
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/ui.sh"

run() {
  log "[stage3] Setting up install root and extracting Stage3"
  : "${MNT_ROOT:=/mnt/gentoo}"

  mkdir -p "$MNT_ROOT"
  mount "$ROOT_DEV" "$MNT_ROOT"

  mkdir -p "$MNT_ROOT/boot"
  mount "$EFI_DEV" "$MNT_ROOT/boot"

  mkdir -p "$MNT_ROOT/etc" "$MNT_ROOT/var" "$MNT_ROOT/run"
  mount -t proc proc "$MNT_ROOT/proc"
  mount --rbind /sys "$MNT_ROOT/sys"
  mount --make-rslave "$MNT_ROOT/sys"
  mount --rbind /dev "$MNT_ROOT/dev"
  mount --make-rslave "$MNT_ROOT/dev"
  mount -t tmpfs shm "$MNT_ROOT/run/shm"

  cp --dereference /etc/resolv.conf "$MNT_ROOT/etc/"

  if [[ -f install.stage3 ]]; then
    log "[stage3] Using local tarball"
    tar xpvf install.stage3 -C "$MNT_ROOT" --xattrs --xattrs-include='*'
  else
    local url="${STAGE3_URL}"
    if [[ -z "${url}" ]]; then
      url="https://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-openrc/"
    fi
    log "[stage3] Downloading stage3 from $url"
    curl -fL "$url" | tar xpvf - -C "$MNT_ROOT" --xattrs --xattrs-include='*'
  fi

  log "[stage3] Done"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then run; fi
