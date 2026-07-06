#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/core/base.sh
# Description: Essential base packages
# ==============================================================================

install_core_base() {

        pkg_install_many \
                git \
                curl \
                wget \
                jq \
                zip \
                unzip \
                tar \
                gzip \
                xz-utils \
                openssh

}
