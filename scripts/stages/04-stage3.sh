# scripts/stages/04-stage3.sh
set -euo pipefail
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/ui.sh"

run() {
  log "[stage3] Mounting and extracting Stage3"
  if [[ ! -v MNT_ROOT ]]; then MNT_ROOT="/mnt/gentoo"; fi

  mount "$ROOT_DEV" "$MNT_ROOT"
  mkdir -p "$MNT_ROOT/boot"   # UEFI mount point; script should handle ESP seperately
  mount "$EFI_DEV" "$MNT_ROOT/boot"

  mkdir -p "$MNT_ROOT/etc" "$MNT_ROOT/var"
  mount -t proc proc "$MNT_ROOT/proc"
  mount --rbind /sys "$MNT_ROOT/sys"
  mount --make-rslave "$MNT_ROOT/sys"
  mount --rbind /dev "$MNT_ROOT/dev"
  mount --make-rslave "$MNT_ROOT/dev"

  cp --dereference /etc/resolv.conf "$MNT_ROOT/etc/"

  if [[ -f install.stage3 ]]; then
    log "[stage3] Using local tarball"
    tar xpvf install.stage3 -C "$MNT_ROOT" --xattrs --xattrs-include='*'
  else
    # TODO: resolve Stage3 URL
    curl -L "$STAGE3_URL" | tar xpvf - -C "$MNT_ROOT" --xattrs --xattrs-include='*'
  fi

  log "[stage3] Done"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then run; fi
