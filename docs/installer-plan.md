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
- Allow custom partitions for advanced users
- NEVER run destructive operations without one more explicit confirmation

### 4.4 Filesystems
- Guided defaults:
  - ext4 if no user preference
  - xfs, btrfs, f2fs as options
- EFI System Partition formatted FAT32
- Optional ZFS/btrfs subvolume support later

### 4.5 Stage3 / Portage Prep
- Configure `--binhost` mirror, if available
- Extract stage3 tarball
- Copy resolv.conf and DNS info
- Mount required filesystems in order

### 4.6 Portage / make.conf / Mirrors
- Ask CPU microarchitecture or detect
- Set `COMMON_FLAGS` based on CPU
- Enable recommended global USE flags for beginners
- Configure `GENTOO_MIRRORS` with regional mirror selection
- Sync Portage

### 4.7 Kernel and Boot
- Guided choice:
  - Prebuilt kernel if supported
  - Distribution kernels
  - Manual `genkernel` workflow
- Build initramfs when needed
- Install and configure GRUB or systemd-boot
- Validate `/etc/fstab` from live stage

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
- Warn about changing from `liveuser` to installed environment

### 4.10 Late Stage Options
- Desktop environment explicitly separate from base
- GPU drivers prompted after reboot, not during base install
- Firmware packages prompted when hardware is detected

---

## 5. Safety Mechanisms

- Root lockfile during destructive operations
- Re-run detection on interrupted installs
- Complete `/var/log/gentoo-install.log`
- Rollback notes for common partition/fstab issues
- Dry-run mode reads-only everything

---

## 6. Beginner UX

- Explain terms inline using `ui.sh`
- One question at a time
- Sensible defaults prefilled when possible
- Visible progress indicators
- Explicit “This will erase disk X” confirmation

---

## 7. Testing Plan

1. VM matrix:
   - UEFI + ext4
   - BIOS + btrfs
   - GPT + systemd-boot
2. Boot verification
3. Network mode verification
4. Resume after simulated interruption
5. Auto mode config validation

---

## 8. Deliverables

- Working installer script
- README for live environment usage
- Example config
- Troubleshooting guide
