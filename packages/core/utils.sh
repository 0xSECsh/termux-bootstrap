#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/core/utils.sh
# Description: General utility packages
# Depends: core/base
# ==============================================================================

install_core_utils() {

	pkg_install_many \
		tmux \
		htop \
		tree \
		fastfetch \
		ripgrep \
		fd \
		bat \
		eza

}
