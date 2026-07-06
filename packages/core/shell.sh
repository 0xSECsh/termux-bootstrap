#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/core/shell.sh
# Description: Shell and terminal enhancement packages
# ==============================================================================

install_core_shell() {

        pkg_install_many \
                zsh \
                tmux \
                tree

}
