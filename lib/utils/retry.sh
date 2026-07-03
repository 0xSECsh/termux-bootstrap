#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: utils/retry.sh
# Description: Retry wrapper with configurable attempts
# ==============================================================================

retry() {

        local attempts="$1"

        shift

        [[ $# -gt 0 ]] || return 1

        local count=1

        until "$@"; do

                if ((count >= attempts)); then

                        return 1

                fi

                ((count++))

                sleep 1

        done

}
