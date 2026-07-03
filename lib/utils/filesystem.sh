#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: utils/filesystem.sh
# Description: Filesystem operations — create, copy, move, remove, size queries
# ==============================================================================

create_directory() {
        mkdir -p -- "$1"
}

remove_directory() {
        local directory="$1"

        [[ -n "$directory" && "$directory" != "/" ]] || return 1

        rm -rf -- "$directory"
}

create_file() {
        mkdir -p -- "$(dirname "$1")"

        touch -- "$1"
}

copy_file() {
        cp -- "$1" "$2"
}

move_file() {
        mv -- "$1" "$2"
}

backup_file() {

        local file="$1"

        [[ -f "$file" ]] || return 0

        cp -- "$file" "${file}.bak"

}

file_size() {

        local result

        result="$(stat -c%s "$1" 2>/dev/null)" || result="$(stat -f%z "$1" 2>/dev/null)"

        printf "%s\n" "$result"

}

directory_size() {

        du -sh -- "$1"

}
