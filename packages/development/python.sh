#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/development/python.sh
# Description: Python development environment
# ==============================================================================

install_development_python() {

        pkg_install_many \
                python \
                python-pip

}
