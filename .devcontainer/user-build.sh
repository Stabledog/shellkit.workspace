#!/bin/bash
# user-build.sh

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
    [[ $UID -eq 0 ]] || die "$scriptName must run as root"
    main "$@"
    builtin exit
}
command true
