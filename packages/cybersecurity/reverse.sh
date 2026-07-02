#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/cybersecurity/reverse.sh
# Description: Reverse engineering packages
# ==============================================================================

install_cybersecurity_reverse() {

	pkg_install_many \
		radare2 \
		gdb \
		strace \
		ltrace

}
