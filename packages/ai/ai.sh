#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/ai/ai.sh
# Description: AI and machine learning packages
# Depends: core/base development/python
# ==============================================================================

install_ai_ai() {

	pkg_install_many \
		python \
		python-pip \
		python-numpy \
		clblast \
		openblas

}
