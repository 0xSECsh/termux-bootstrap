#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/cybersecurity/wireless.sh
# Description: Wireless security audit packages
# ==============================================================================

install_cybersecurity_wireless() {

	pkg_install_many \
		aircrack-ng \
		reaver \
		wifite \
		bettercap \
		pixiewps

}
