#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/core/utils.sh
# Description: General utility packages
# ==============================================================================

install_core_utils() {

        pkg_install_many \
                fastfetch \
                htop \
                procps

}
