#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: terminal/progress.sh
# Description: Terminal progress bar
# ==============================================================================

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

readonly PROGRESS_WIDTH=40

# ------------------------------------------------------------------------------
# Internal Helpers
# ------------------------------------------------------------------------------

_progress_percentage() {

        local current="$1"
        local total="$2"

        ((total == 0)) && total=1

        printf "%s\n" "$((current * 100 / total))"

}

_progress_filled() {

        local current="$1"
        local total="$2"

        ((total == 0)) && total=1

        printf "%s\n" "$((current * PROGRESS_WIDTH / total))"

}

_progress_empty() {

        local filled="$1"

        printf "%s\n" "$((PROGRESS_WIDTH - filled))"

}

_repeat() {

        local char="$1"
        local count="$2"

        printf "%${count}s" "" | tr ' ' "$char"

}

# ------------------------------------------------------------------------------
# Draw Progress Bar
# ------------------------------------------------------------------------------

progress_draw() {

        local current="$1"
        local total="$2"
        local message="${3:-}"

        local percent
        local filled
        local empty

        percent="$(_progress_percentage "$current" "$total")"

        filled="$(_progress_filled "$current" "$total")"

        empty="$(_progress_empty "$filled")"

        printf "\r"

        printf "["

        _repeat "█" "$filled"

        _repeat "░" "$empty"

        printf "] %3d%%" "$percent"

        if [[ -n "$message" ]]; then

                printf " %s" "$message"

        fi

}

# ------------------------------------------------------------------------------
# Finish Progress
# ------------------------------------------------------------------------------

progress_finish() {

        echo

}

# ------------------------------------------------------------------------------
# Progress Runner
# ------------------------------------------------------------------------------

progress_run() {

        local total="$1"

        shift

        local current=0

        local task

        for task in "$@"; do

                ((current++))

                progress_draw "$current" "$total" "$task"

                sleep 0.2

        done

        progress_finish

}
