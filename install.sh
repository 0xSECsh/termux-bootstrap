#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap — Installer Entry Point
#
# Delegates to bootstrap.sh.  Run directly for a curl-based install:
#
#   bash <(curl -fsSL https://raw.githubusercontent.com/0xSECsh/termux-bootstrap/main/install.sh)
#
# Or clone the repo and run:
#
#   ./bootstrap.sh install --profile developer
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

exec "${SCRIPT_DIR}/bootstrap.sh" install --profile minimal "$@"
