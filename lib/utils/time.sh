#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: utils/time.sh
# Description: Time utilities — timestamps, epoch, sleep
# ==============================================================================

timestamp() {

        date +"%Y-%m-%d %H:%M:%S"

}

epoch() {

        date +%s

}

pause() {

        sleep "${1:-1}"

}
