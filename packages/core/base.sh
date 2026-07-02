#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/core/base.sh
# Description: Base system packages
# ==============================================================================

install_core_base() {

	pkg_install_many \
		termux-tools \
		termux-exec \
		openssh \
		binutils \
		make \
		pkg-config \
		which \
		git \
		curl \
		wget \
		jq \
		openssl-tool \
		man \
		less \
		tar \
		gzip \
		bzip2 \
		xz-utils \
		unzip

}
