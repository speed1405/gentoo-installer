#!/usr/bin/env bash
# lib/ui.sh — dialog-based UI helpers
export DISABLE_UI=${DISABLE_UI:-0}

check_dialog() {
  if ! command -v dialog >/dev/null 2>&1; then
    local alt="${DISABLE_UI:-0}"
    [[ "$alt" == "1" ]] && return 0
    log "UI dependency missing: dialog not found"
    die "Install dialog and re-run."
  fi
}

run_or_ui() {
  local title="$1"
  local text="$2"
  if [[ "${DISABLE_UI:-0}" == "1" ]]; then
    log "[ui] SKIP $title: $text"
  else
    ui_header "$title" "$text"
  fi
}

# Helpers
log() {
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
  echo "$msg" >> "${LOG_FILE:-/tmp/gentoo-install.log}"
}

die() {
  log "FATAL: $1"
  if [[ "${DISABLE_UI:-0}" != "1" ]]; then
    ui_die "ERROR: $1" "$2"
  else
    echo "FATAL: $1" >&2
    exit "${2:-1}"
  fi
}

set_status() {
  local step="$1"
  local pct="$2"
  echo "${step}|${pct}" > "${STATUS_FILE:-/tmp/gentoo-install.status}"
}

load_config() {
  if [[ -f "${CONFIG_FILE:-}" ]]; then
    source "$CONFIG_FILE"
    log "Config loaded from $CONFIG_FILE"
  fi
}

parse_args() {
  MODE="guided"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --mode)     MODE="$2"; shift 2 ;;
      --config)   CONFIG_FILE="$2"; shift 2 ;;
      --dry-run)  MODE="dry-run"; shift ;;
      -h|--help)
        echo "Usage: install.sh [--mode guided|auto|dry-run] [--config path] [--dry-run]"
        exit 0
        ;;
      *) die "Unknown argument: $1" ;;
    esac
  done
}

create_lockfile() {
  echo "$$" > "${LOCK_FILE:-/tmp/gentoo-install.lock}"
}

check_lockfile() {
  if [[ -f "${LOCK_FILE:-/tmp/gentoo-install.lock}" ]]; then
    local pid
    pid=$(cat "$LOCK_FILE")
    if kill -0 "$pid" 2>/dev/null; then
      die "Another installer instance (PID $pid) is running."
    else
      log "Removing stale lockfile (PID $pid not running)"
      rm -f "$LOCK_FILE"
    fi
  fi
  return 0
}

run_guided() {
  ui_header "Gentoo Installer (Guided Mode)"
  set_status "preflight" 5
  bash "$STAGES_DIR/00-preflight.sh"

  set_status "disk_selection" 15
  bash "$STAGES_DIR/01-disk.sh"

  set_status "partitioning" 25
  bash "$STAGES_DIR/02-partitioning.sh"

  set_status "filesystems" 35
  bash "$STAGES_DIR/03-filesystems.sh"

  set_status "stage3" 45
  bash "$STAGES_DIR/04-stage3.sh"

  set_status "portage" 55
  bash "$STAGES_DIR/05-portage.sh"

  set_status "kernel" 70
  bash "$STAGES_DIR/06-kernel.sh"

  set_status "base_setup" 85
  bash "$STAGES_DIR/07-base.sh"

  set_status "late_stage" 90
  bash "$STAGES_DIR/08-late-stage.sh"

  set_status "validation" 95
  bash "$STAGES_DIR/09-verify.sh"

  set_status "complete" 100
  ui_success "Install complete. Log saved to ${LOG_FILE:-/var/log/gentoo-install.log}"
}

run_auto() {
  [[ -f "${CONFIG_FILE:-}" ]] || die "Config file not found. Use --config."
  for stage in "$STAGES_DIR"/*.sh; do
    log "AUTO: $(basename "$stage")"
    DISABLE_UI=1 bash "$stage"
  done
  echo "Auto install complete. Log: ${LOG_FILE:-/var/log/gentoo-install.log}"
}

run_dry_run() {
  run_or_ui "Dry-Run Mode" "No changes will be made.\nReview actions in ${LOG_FILE:-/tmp/gentoo-install.log}."
  for stage in "$STAGES_DIR"/*.sh; do
    log "DRY-RUN: $(basename "$stage")"
    DISABLE_UI=1 DRY_RUN=1 bash "$stage"
  done
  ui_success "Dry-run complete. Review actions in ${LOG_FILE:-/tmp/gentoo-install.log}"
}
