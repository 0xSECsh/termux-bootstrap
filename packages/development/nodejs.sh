#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/development/nodejs.sh
# Description: Node.js development packages
# ==============================================================================

install_development_nodejs() {

	pkg_install_many \
		nodejs \
		npm

}
