#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/core/shell.sh
# Description: Shell and terminal enhancement packages
# Depends: core/base
# ==============================================================================

install_core_shell() {

	pkg_install_many \
		zsh \
		bash-completion \
		fzf

}
