#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/cybersecurity/osint.sh
# Description: OSINT (Open Source Intelligence) packages
# ==============================================================================

install_cybersecurity_osint() {

        pkg_install_many \
                recon-ng \
                sherlock \
                holehe \
                maigret \
                photon

}
