#!/usr/bin/env bash
# lib/binhelp.sh — reusable source-build helper for dwm/polybar and similar packages
set -euo pipefail

_BUILD_DIR=/var/tmp/gentoo-installer-builds
_REQUIREMENTS_FILE=${1:-}
_PACKAGE=${2:-dwm}
_PACKAGE_DIR=${3:-$_BUILD_DIR/$_PACKAGE}
_SKIP_EMERGE=${SKIP_EMERGE:-0}

ensure_build_env() {
  mkdir -p "$_BUILD_DIR"
}

fetch_tarball() {
  local url="$1"
  local out="$2"
  curl -fsSL "$url" -o "$out"
}

build_from_tarball() {
  local tarball_url="$1"
  local pkg_dir="$2"
  local conf_cmd="${3:-make}"
  local make_install_cmd="${4:-make install}"
  ensure_build_env

  mkdir -p "$pkg_dir"
  fetch_tarball "$tarball_url" "$pkg_dir/pkg.tar.gz"

  tar -xzf "$pkg_dir/pkg.tar.gz" -C "$pkg_dir"
  pushd "$pkg_dir" >/dev/null
  ./config "$conf_cmd" > .build.log 2>&1 || {
    local status=$?
    popd >/dev/null
    die "Config failed for $_PACKAGE" "$status"
  }
  $make_install_cmd >> .build.log 2>&1
  popd >/dev/null
}

build_dwm() {
  build_from_tarball \
    "https://dl.suckless.org/dwm/dwm-6.3.tar.gz" \
    "$_PACKAGE_DIR" \
    "config.mk" \
    "make clean install"
}

build_polybar() {
  build_from_tarball \
    "https://github.com/polybar/polybar/releases/download/3.7.0/polybar-3.7.0.tar.gz" \
    "$_PACKAGE_DIR" \
    "./configure" \
    "make install"
}

check_requirements() {
  [[ -z "$_REQUIREMENTS_FILE" ]] && return 0
  [[ -f "$_REQUIREMENTS_FILE" ]] || die "Requirements file missing: $_REQUIREMENTS_FILE"
}

build_package() {
  check_requirements

  case "$_PACKAGE" in
    dwm) build_dwm ;;
    polybar) build_polybar ;;
    *) die "Unsupported package: $_PACKAGE" ;;
  esac
}
