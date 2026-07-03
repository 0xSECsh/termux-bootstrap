#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: bootstrap.sh
# Description: Project entry point - CLI Dispatcher
# ==============================================================================

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 1

# shellcheck disable=SC1091
source "${SOURCE_DIR}/lib/common.sh"

framework_initialize

dispatch "$@"
