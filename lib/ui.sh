#!/usr/bin/env bash
# lib/ui.sh — dialog-based UI helpers

export DISABLE_UI=${DISABLE_UI:-0}

# Check dialog availability
check_dialog() {
  if ! command -v dialog >/dev/null 2>&1; then
    echo "ERROR: dialog not installed. Install and re-run."
    exit 1
  fi
}

ui_header() {
  check_dialog
  dialog --title "Gentoo Installer" --no-cancel --msgbox "$1\n\nPress Enter to continue." 10 60
}

ui_yesno() {
  check_dialog
  local title="$1"
  local text="$2"
  dialog --title "$title" --yesno "$text" 12 70
}

ui_input() {
  check_dialog
  local title="$1"
  local text="$2"
  local default="${3:-}"
  dialog --title "$title" --inputbox "$text" 10 70 "$default" 2>&1
}

ui_password() {
  check_dialog
  local title="$1"
  local text="$2"
  dialog --title "$title" --passwordbox "$text" 10 70 2>&1
}

ui_menu() {
  check_dialog
  local title="$1"
  local text="$2"
  shift 2
  dialog --menu "$text" 20 70 15 "$@" 2>&1
}

ui_radiolist() {
  check_dialog
  local title="$1"
  local text="$2"
  shift 2
  dialog --radiolist "$text" 20 70 15 "$@" 2>&1
}

ui_checklist() {
  check_dialog
  local title="$1"
  local text="$2"
  shift 2
  dialog --checklist "$text" 20 70 15 "$@" 2>&1
}

ui_progress() {
  check_dialog
  local pct="$1"
  local title="$2"
  local text="$3"
  echo "$pct"
  echo "XXX"
  echo "$text"
  dialog --title "$title" --gauge "$text" 10 70 "$pct" 2>&1
}

ui_success() {
  check_dialog
  dialog --title "Success" --msgbox "$1" 8 60
}

ui_die() {
  check_dialog
  dialog --title "Fatal" --msgbox "$1" 8 60
  exit "${2:-1}"
}
