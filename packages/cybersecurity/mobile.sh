#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/cybersecurity/mobile.sh
# Description: Mobile security analysis packages
# Depends: core/base
# ==============================================================================

install_cybersecurity_mobile() {

        pkg_install_many \
                apktool \
                jadx \
                dex2jar

}
