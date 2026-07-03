#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: utils/string.sh
# Description: String manipulation — case conversion, trimming
# ==============================================================================

to_lower() {

        printf "%s\n" "${1,,}"

}

to_upper() {

        printf "%s\n" "${1^^}"

}

trim() {

        local value="$*"

        value="${value#"${value%%[![:space:]]*}"}"
        value="${value%"${value##*[![:space:]]}"}"

        printf "%s\n" "$value"

}
