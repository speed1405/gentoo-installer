# Troubleshooting

## Live environment

- `dialog not found`: `emerge --ask sys-apps/dialog` or use your live media’s package manager
- `parted: command not found`: install `sys-block/parted`
- `sgdisk not found`: install `sys-apps/gptfdisk`

## Mount / stage3

- `tar: invalid magic` on stage3 download:
  - Verify `STAGE3_URL`
  - Check system clock
- `mount: special device does not exist`:
  - Confirm partition numbering, especially on NVMe (`nvme0n1p1`)
- `cannot find /mnt/gentoo/dev`:
  - Ensure stage 4 ran fully
  - Verify bind-mounts are intact

## Portage

- `emerge --sync` hangs:
  - Check DNS in live env and chroot (`cat /etc/resolv.conf`)
  - Try `GENTOO_MIRRORS` reset
- `Permission denied` while writing `make.conf`:
  - Confirm `MNT_ROOT` is mounted correctly

## Kernel / boot

- `grub-install` targets /boot/efi but ESP is mounted at /boot`:
  - Adjust `--efi-directory` to match mount point
- Boot loops after install:
  - Confirm `/etc/fstab` UUIDs or device paths are correct
  - Check that initramfs exists under `/boot`
- Systemd-boot not detecting entry:
  - Ensure loader.conf and entry exist under `/boot/loader/`

## Desktop

- `startx` fails with “no protocol specified”:
  - Ensure `elogind` is enabled
  - Check seatd is running
- Black screen with dmenu:
  - Verify `~/.xinitrc` starts dwm last
