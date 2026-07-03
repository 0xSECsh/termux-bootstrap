#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: utils/archive.sh
# Description: Archive extraction — zip, tar.gz, tar.xz
# ==============================================================================

extract() {

        case "$1" in

                *.zip)

                        unzip -- "$1"
                        ;;

                *.tar.gz | *.tgz)

                        tar -xzf "$1"
                        ;;

                *.tar.xz)

                        tar -xJf "$1"
                        ;;

                *.tar)

                        tar -xf "$1"
                        ;;

                *)

                        return 1
                        ;;

        esac

}
