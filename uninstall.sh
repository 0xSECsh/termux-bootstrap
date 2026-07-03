#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap — Uninstaller Entry Point
#
# Removes all packages installed by Termux Bootstrap profiles and modules.
#
# Usage:
#   ./uninstall.sh [--profile <name>]
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

echo "WARNING: This will remove Termux Bootstrap files and packages."
echo "This script is a stub.  Manual cleanup is currently required."
echo ""
echo "To remove Bootstrap files:"
echo "  rm -rf ~/.config/termux-bootstrap ~/.cache/termux-bootstrap ~/.local/share/termux-bootstrap"
echo "  rm -rf ${SCRIPT_DIR}"
