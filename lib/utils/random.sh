#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: utils/random.sh
# Description: Random string generation
# ==============================================================================

random_string() {

        tr -dc 'A-Za-z0-9' </dev/urandom | head -c "${1:-16}"

}
