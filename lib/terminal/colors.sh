#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: lib/colors.sh
# Description: ANSI colors and terminal formatting helpers
# ==============================================================================

# ------------------------------------------------------------------------------
# ANSI Support
# ------------------------------------------------------------------------------

if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
        readonly COLOR_SUPPORT=true
else
        readonly COLOR_SUPPORT=false
fi

# ------------------------------------------------------------------------------
# Colors
# ------------------------------------------------------------------------------

if [[ "$COLOR_SUPPORT" == true ]]; then

        readonly RESET="\033[0m"

        readonly BLACK="\033[30m"
        readonly RED="\033[31m"
        readonly GREEN="\033[32m"
        readonly YELLOW="\033[33m"
        readonly BLUE="\033[34m"
        readonly MAGENTA="\033[35m"
        readonly CYAN="\033[36m"
        readonly WHITE="\033[37m"

        readonly BRIGHT_RED="\033[91m"
        readonly BRIGHT_GREEN="\033[92m"
        readonly BRIGHT_YELLOW="\033[93m"
        readonly BRIGHT_BLUE="\033[94m"
        readonly BRIGHT_CYAN="\033[96m"

        readonly BOLD="\033[1m"
        readonly DIM="\033[2m"
        readonly ITALIC="\033[3m"
        readonly UNDERLINE="\033[4m"

else

        readonly RESET=""

        readonly BLACK=""
        readonly RED=""
        readonly GREEN=""
        readonly YELLOW=""
        readonly BLUE=""
        readonly MAGENTA=""
        readonly CYAN=""
        readonly WHITE=""

        readonly BRIGHT_RED=""
        readonly BRIGHT_GREEN=""
        readonly BRIGHT_YELLOW=""
        readonly BRIGHT_BLUE=""
        readonly BRIGHT_CYAN=""

        readonly BOLD=""
        readonly DIM=""
        readonly ITALIC=""
        readonly UNDERLINE=""

fi

export \
        COLOR_SUPPORT \
        RESET \
        BLACK \
        RED \
        GREEN \
        YELLOW \
        BLUE \
        MAGENTA \
        CYAN \
        WHITE \
        BRIGHT_RED \
        BRIGHT_GREEN \
        BRIGHT_YELLOW \
        BRIGHT_BLUE \
        BRIGHT_CYAN \
        BOLD \
        DIM \
        ITALIC \
        UNDERLINE

# ------------------------------------------------------------------------------
# Generic Printer
# ------------------------------------------------------------------------------

print() {

        printf "%s\n" "$*"

}

colorize() {

        local color="$1"

        shift

        printf "%b%s%b\n" "$color" "$*" "$RESET"

}

# ------------------------------------------------------------------------------
# Formatting
# ------------------------------------------------------------------------------

title() {

        local i
        local text="$*"
        local length="${#text}"

        printf "\n"

        colorize "${BOLD}${CYAN}" "$text"

        for ((i = 0; i < length; i++)); do
                printf "─"
        done

        printf "\n\n"

}

subtitle() {

        colorize "$BOLD" "$*"

}

separator() {

        local i

        for ((i = 0; i < 80; i++)); do
                printf "─"
        done

        printf "\n"

}

newline() {

        printf "\n"

}
