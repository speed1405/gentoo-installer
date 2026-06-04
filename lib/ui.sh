#!/usr/bin/env bash
# lib/ui.sh — backwards-compat shim; UI functions now live in lib/logging.sh
if [[ -z "${LOGGING_SH_LOADED:-}" ]]; then
  source "$(dirname "${BASH_SOURCE[0]}")/logging.sh"
fi

# Backwards-compat exports
export DISABLE_UI=${DISABLE_UI:-0}
export LOG_FILE=${LOG_FILE:-/var/log/gentoo-install.log}
export STATUS_FILE=${STATUS_FILE:-/tmp/gentoo-install.status}
export LOCK_FILE=${LOCK_FILE:-/tmp/gentoo-install.lock}
