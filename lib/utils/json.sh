#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: utils/json.sh
# Description: JSON query helper using jq
# ==============================================================================

json_get() {

        local file="$1"
        local query="$2"

        assert_command jq

        jq -r "$query" "$file"

}
