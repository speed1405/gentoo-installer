#!/usr/bin/env bash
# lib/logging.sh — log + resume support

export LOG_FILE STATUS_FILE

log() {
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
  echo "$msg" >> "$LOG_FILE"
}

die() {
  log "FATAL: $1"
  ui_die "ERROR: $1" "$2"
}

set_status() {
  local step="$1"
  local pct="$2"
  echo "${step}|${pct}" > "$STATUS_FILE"
}

load_config() {
  if [[ -f "$CONFIG_FILE" ]]; then
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
  echo "$$" > "$LOCK_FILE"
}

check_lockfile() {
  if [[ -f "$LOCK_FILE" ]]; then
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

  set_status "portage" 60
  bash "$STAGES_DIR/05-portage.sh"

  set_status "kernel" 75
  bash "$STAGES_DIR/06-kernel.sh"

  set_status "base_setup" 85
  bash "$STAGES_DIR/07-base.sh"

  set_status "validation" 95
  bash "$STAGES_DIR/09-verify.sh"

  set_status "complete" 100
  ui_success "Install complete. Log saved to $LOG_FILE"
}

run_auto() {
  [[ -f "$CONFIG_FILE" ]] || die "Config file not found: $CONFIG_FILE"
  # Auto mode runs each stage without UI prompts
  for stage in "$STAGES_DIR"/*.sh; do
    log "AUTO: Running $(basename "$stage")"
    DISABLE_UI=1 bash "$stage"
  done
  ui_success "Auto install complete. Log: $LOG_FILE"
}

run_dry_run() {
  ui_header "Gentoo Installer (Dry-Run Mode) — no changes will be made"
  for stage in "$STAGES_DIR"/*.sh; do
    log "DRY-RUN: $(basename "$stage")"
    if [[ -x "$stage" ]]; then
      DRY_RUN=1 bash "$stage"
    fi
  done
  ui_success "Dry-run complete. Review actions in $LOG_FILE"
}
