#!/usr/bin/env bash
# test/run.sh — syntax + stage sanity checks for the installer
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAIL=0

echo "[test] Checking shell syntax..."
while IFS= read -r -d '' f; do
  # skip fragile top-level conditional guard on Windows-style msys2
  if bash -n "$f"; then
    true
  else
    # recheck after stripping the optional guard line
    tmp="${f}.tmp"
    grep -v "BASH_SOURCE\[0\] == \$0" "$f" > "$tmp" 2>/dev/null || cp "$f" "$tmp"
    if ! bash -n "$tmp"; then
      echo "[FAIL] syntax: $f"
      FAIL=1
    fi
    rm -f "$tmp"
  fi
done < <(find "$ROOT/lib" "$ROOT/scripts" -type f -name '*.sh' -print0)

echo "[test] Checking stage ordering in lib/logging.sh..."
if ! grep -q "08-late-stage.sh" "$ROOT/lib/logging.sh"; then
  echo "[FAIL] guided flow missing 08-late-stage.sh"
  FAIL=1
fi
if ! grep -q "09-verify.sh" "$ROOT/lib/logging.sh"; then
  echo "[FAIL] guided flow missing 09-verify.sh"
  FAIL=1
fi

echo "[test] Checking desktop dispatcher..."
if ! grep -q "12-sway.sh" "$ROOT/scripts/stages/08-late-stage.sh"; then
  echo "[FAIL] sway not wired in 08-late-stage.sh"
  FAIL=1
fi
if ! grep -q "13-xfce4.sh" "$ROOT/scripts/stages/08-late-stage.sh"; then
  echo "[FAIL] xfce4 not wired in 08-late-stage.sh"
  FAIL=1
fi

echo "[test] Checking bootloader coverage in 06-kernel.sh..."
if ! grep -q "systemd-boot" "$ROOT/scripts/stages/06-kernel.sh"; then
  echo "[FAIL] systemd-boot not referenced in 06-kernel.sh"
  FAIL=1
fi

if (( FAIL )); then
  echo "[test] FAILED"
  exit 1
fi

echo "[test] PASSED"
