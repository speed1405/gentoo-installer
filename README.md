# gentoo-installer

Beginner-friendly Gentoo installer in Bash + `dialog`.

## Modes

- `guided` — step-by-step TUI prompts
- `auto` — non-interactive via `config/example.conf`
- `dry-run` — read-only plan output

## Quick Start

```bash
./scripts/install.sh --mode guided
```

```bash
./scripts/install.sh --mode auto --config config/example.conf
```

## Requirements

- Root
- `bash`, `dialog`, `parted`, `gptfdisk` (`sgdisk`), `curl`, `tar`
- Internet unless `CONNECTIVITY=allow_offline`

## Layout

- `lib/{logging,ui,disk,binhelp}.sh`
- `scripts/stages/00-preflight.sh` → `11-desktop.sh`
- `config/example.conf`

## Notes

- Guided mode asks one question per screen.
- `run_guided` in `lib/logging.sh` controls stage order and progress.
- Logs go to `/var/log/gentoo-install.log`.
