# Gentoo Installer — Usage Guide

## What this is

A guided Bash installer for Gentoo, designed for beginners. It covers:

- disk selection and safety
- guided partitioning
- base system bootstrap
- kernel + GRUB
- optional dwm + polybar preset
- logging and resume

It is **not** a one-size-fits-all Gentoo tool. It targets UEFI/BIUS systems with GPT and standard hardware.

---

## Requirements

- x86_64 live media with root access
- Internet unless you set `CONNECTIVITY=allow_offline`
- Packages: `bash`, `dialog`, `parted`, `gptfdisk`, `curl`, `tar`, `grub`

---

## Files

- `scripts/install.sh` — entrypoint
- `scripts/stages/*.sh` — install stages
- `lib/ui.sh` — dialog helpers
- `lib/disk.sh` — partition helpers
- `lib/logging.sh` — modes, logs, resume
- `lib/binhelp.sh` — source-build helper for dwm/polybar
- `config/example.conf` — auto-mode config

---

## Modes

### Guided

```bash
./scripts/install.sh --mode guided
```

One question per screen with a Cancel button at every step.

### Auto

```bash
./scripts/install.sh --mode auto --config config/example.conf
```

No prompts. Reads values from `config/example.conf`.

### Dry-run

```bash
./scripts/install.sh --mode dry-run
```

Runs checks and prints planned actions without touching disks.

---

## Config values

Key options in `config/example.conf`:

- `TARGET_DISK` — target disk, e.g. `/dev/sda`
- `EFI_SIZE` — ESP size, e.g. `512M`
- `SWAP_SIZE` — swap size, e.g. `4G`
- `FILESYSTEM` — `ext4`, `xfs`, `btrfs`, `f2fs`
- `CONNECTIVITY` — `require_network` or `allow_offline`
- `BINHOST_MIRROR` — optional binhost URL
- `COMMON_FLAGS` — compiler flags, e.g. `-O2 -march=native -pipe`
- `STAGE3_URL` — stage3 tarball URL
- `TIMEZONE`, `LOCALE`, `KEYMAP`
- `HOSTNAME`, `ROOT_PASSWORD`
- `USERNAME`, `USER_PASSWORD`
- `BOOTLOADER` — `grub` or `systemd-boot`
- `INSTALL_DESKTOP` — `dwm`, `sway`, `xfce4`, `gnome`, `kde`, `none`
- `DESKTOP_WITH_POLYBAR` — true/false
- `WALLPAPER_URL` — optional wallpaper download

---

## Stage flow

1. Preflight
2. Disk selection
3. Partitioning
4. Filesystems
5. Stage3 + mounts
6. Portage + make.conf
7. Kernel + initramfs + bootloader
8. Base system (timezone, locale, users)
9. Late stage (desktop prompt, GPU drivers)
10. Verification + first boot checklist

Logs: `/var/log/gentoo-install.log`
Status: `/tmp/gentoo-install.status`
Lock: `/tmp/gentoo-install.lock`

---

## Resume after interruption

If the installer stops:

- Lockfile is removed on clean exit
- If it crashes, remove `/tmp/gentoo-install.lock` manually
- Re-run with the same mode/config; destructive steps can be skipped or re-evaluated depending on what completed

---

## First boot checklist

Written to `/root/gentoo-first-boot-checklist` in the installed system:

- Verify GRUB entry appears
- Review `/etc/fstab`
- Set networking (`dhcpcd` or `NetworkManager`)
- Enable services as needed

---

## Troubleshooting

- Missing `dialog`: install it in the live environment first
- `grub-install` fails: confirm UEFI vs BIOS mode and ESP mount point
- `emerge --sync` fails: check DNS and `/etc/resolv.conf`
- Black screen after boot: ensure `/lib/firmware` was copied and initramfs exists

---

## Safety notes

- Disk wipe: confirm twice before destructive operations
- Snapshot or backup drives before running
- Dry-run does not modify disks
