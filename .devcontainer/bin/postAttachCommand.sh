#!/bin/bash
# postAttachCommand.sh

scriptName="$(readlink -f "$0")"
scriptDir=$(command dirname -- "${scriptName}")

die() {
    builtin echo "ERROR($(basename ${scriptName}): $*" >&2
    builtin exit 1
}

stub() {
   builtin echo "  <<< STUB[$*] >>> " >&2
}
main() {
    builtin echo "args:[$*]"
}

[[ -z ${sourceMe} ]] && {
    echo "$scriptName starting" >&2
    cd /workspace && {
        dest=$(readlink -f /host_home/.shellkit-environment.mk)
        [[ -e $dest ]] && {
            ln -sf "$dest"  ./environment.mk
            echo "Updated $PWD/environment.mk OK" >&2
        }
    }
    builtin exit
}
command true
