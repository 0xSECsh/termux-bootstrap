#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/development/python.sh
# Description: Python development packages
# Depends: core/base
# ==============================================================================

install_development_python() {

	pkg_install_many \
		python \
		python-pip

}
