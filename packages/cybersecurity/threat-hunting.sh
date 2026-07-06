#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/cybersecurity/threat-hunting.sh
# Description: Threat hunting and forensics packages
# Depends: core/base
# ==============================================================================

install_cybersecurity_threat_hunting() {

        pkg_install_many \
                yara \
                volatility3 \
                capa

}
