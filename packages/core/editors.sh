#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/core/editors.sh
# Description: Text editor packages
# ==============================================================================

install_core_editors() {

        pkg_install_many \
                nano \
                vim

}
