# Gentoo Installer Plan

**Scope:** Design a beginner-friendly Gentoo installer script that can run from live media and guide users through a complete base install with as much automation as possible, while still exposing Gentoo’s configurability.

**Audience:** New-to-Gentoo users.

**Key rules:**
- Every step must be reversible or identifiable.
- Interactive by default, non-interactive by design.
- Beginners win; experts still have a sane path.

---

## 1. Goals

1. Reduce install time from “all day research” to “follow the prompts.”
2. Avoid hidden decisions.
3. Produce a reproducible base install.
4. Keep the live environment dependencies minimal.
5. Make logs available for debugging without exposing the user to noise.

---

## 2. Operating Modes

- **guided:** menu-driven, explains each step
- **auto:** fully non-interactive using a config file
- **dry-run:** checks requirements and prints the planned actions without modifying disks

---

## 3. File Layout

- `scripts/install.sh` — entrypoint
- `scripts/stages/*.sh` — install stages
- `lib/ui.sh` — prompts and colors
- `lib/disk.sh` — partition helpers
- `lib/logging.sh` — log + resume support
- `config/example.conf` — auto-mode config
- `docs/installer-plan.md` — this file

---

## 4. Stages

### 4.1 Preflight
- Verify UEFI vs BIOS
- Verify `bash`, `dialog`, `parted`, `gptfdisk`, `network`, `archives`
- Write preflight report to disk if issues exist
- Offer to continue with warnings only when safe

### 4.2 Disk Selection and Safety
- List disks with sizes and device paths
- Require explicit confirmation before wiping
- Create a lock file after confirmation
- Record chosen disk and partition map to log

### 4.3 Partitioning Presets
- Offer:
  - UEFI guided layout
  - BIOS guided layout
  - Entire disk with swap
- Mark EFI System Partition with `boot` and `esp` flags on all GPT/UEFI layouts
- Allow custom partitions for advanced users
- NEVER run destructive operations without one more explicit confirmation

### 4.4 Filesystems
- Guided defaults:
  - ext4 if no user preference
  - xfs, btrfs, f2fs as options
- EFI System Partition formatted FAT32
- Optional ZFS/btrfs subvolume support later

### 4.5 Stage3 / Portage Prep
- Stage3 URL fallback: if primary mirror fails, try secondary mirror before aborting
- Verify at least 2 GB free in `/mnt/gentoo` after mount before extracting stage3
- Configure `--binhost` mirror, if available
- Extract stage3 tarball
- Copy resolv.conf and DNS info
- Mount required filesystems in order

### 4.6 Portage / make.conf / Mirrors
- Ask CPU microarchitecture or detect
- Set `COMMON_FLAGS` based on CPU
- Enable recommended global USE flags for beginners
- Configure `GENTOO_MIRRORS` with regional mirror selection
- Define connectivity policy in config: `require_network` vs `allow_offline`
- Sync Portage

### 4.7 Kernel and Boot
- Guided choice:
  - Prebuilt kernel if supported
  - Distribution kernels
  - Manual `genkernel` workflow
- Build initramfs when needed
- Validate `/etc/fstab` matches live mounts BEFORE installing bootloader
- Copy live `/lib/firmware` to installed root before reboot so hardware is supported on first boot
- Install and configure GRUB or systemd-boot

### 4.8 Base System Bootstrap
- Prompt for:
  - timezone
  - locale
  - hostname
  - root password
  - regular user + sudo
- Enable basic networking:
  - dhcpcd
  - NetworkManager if selected
- Install minimal service stack

### 4.9 Post-Install Verification
- Print a “first boot checklist”
- List files to review before reboot
- Verify `/etc/portage/make.conf` matches live environment selections before first `emerge --sync`
- Warn about changing from `liveuser` to installed environment

### 4.10 Late Stage Options
- Desktop environment explicitly separate from base
- GPU drivers prompted after reboot, not during base install
- Firmware packages prompted when hardware is detected

### 4.11 Desktop Environment / Window Manager (Post-Base)
- Optional, triggered after base bootstrap or during first-boot online setup
- Presets:
  - dwm — minimal, source build, patch-ready; install xorg-server, libX11, dmenu, st defaults
  - sway — Wayland, good defaults
  - xfce4 — full DE, beginner-friendly
  - gnome / kde — heavy, warn about build time
- dwm-specific handling:
  - Enable elogind and seatd automatically
  - Provide systemd user session or .xinitrc fallback
  - Pull a known-good config tarball unless skipped
  - Document `make clean install` recompile workflow for `config.h` edits
- Design rule: do not bake a display manager into base; use startx for dwm/sway

---

## 5. UI Design and Tooling

- Use `dialog` for all interactive components; avoid `whiptail` for consistency and live-media compatibility
- One question per screen — no stacked prompts
- Always include a **[Cancel]** button that exits cleanly and writes a resume-able log
- Default values pre-filled in text inputs (e.g., hostname = `gentoo`)
- Inline help via **F1** or a `[Help]` button, not external man pages
- **Visual hierarchy:**
  - Errors: red, exact fix text
  - Warnings: yellow, actionable
  - Progress: gauge bar with percentage + step name
  - Success: green, one-line confirmation with log path
- **Widget mapping:**
  - Disk wipe confirmation: `--yesno` with ALL-CAPS warning
  - Partition selection: `--radiolist` with size/type/flag columns
  - Bootloader choice: `--menu`
  - Passwords: `--passwordbox` (masked, no echo)
- **Progress flow:** Stages update a temp status file; parent UI repaints a gauge without spawning new dialogs
- **Beginner reinforcement:** after each step, print a one-line “What just happened” summary before the next prompt

---

## 6. Safety Mechanisms

- Root lockfile during destructive operations
- Re-run detection on interrupted installs
- Complete `/var/log/gentoo-install.log`
- Rollback notes for common partition/fstab issues
- Dry-run mode reads-only everything

---

## 7. Beginner UX

- Explain terms inline using `ui.sh`
- One question at a time
- Sensible defaults prefilled when possible
- Visible progress indicators
- Explicit “This will erase disk X” confirmation

---

## 8. Testing Plan

1. VM matrix:
   - UEFI + ext4
   - BIOS + btrfs
   - GPT + systemd-boot
2. Boot verification
3. Network mode verification
4. Resume after simulated interruption
5. Auto mode config validation

---

## 9. Deliverables

- Working installer script
- README for live environment usage
- Example config
- Troubleshooting guide
