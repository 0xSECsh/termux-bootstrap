#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/core/editors.sh
# Description: Text editor packages
# Depends: core/base
# ==============================================================================

install_core_editors() {

	pkg_install_many \
		micro \
		nano \
		vim

}
