#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/cybersecurity/reverse.sh
# Description: Reverse engineering packages
# Depends: core/base
# ==============================================================================

install_cybersecurity_reverse() {

        pkg_install_many \
                radare2 \
                gdb \
                strace \
                ltrace

}
