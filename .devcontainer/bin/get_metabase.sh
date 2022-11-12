#!/bin/bash
# get_metabase.sh

scriptName="$(readlink -f "$0")"
scriptDir=$(command dirname -- "${scriptName}")
PS4='\033[0;33m+(${BASH_SOURCE}:${LINENO}):\033[0m ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

die() {
    builtin echo "ERROR($(basename ${scriptName})): $*" >&2
    builtin exit 1
}

stub() {
    # Print debug output to stderr.  Recommend to call like this:
    #   stub "${FUNCNAME[0]}.${LINENO}" "$@" "<Put your message here>"
    #
    [[ -n $NoStubs ]] && return
    [[ -n $__stub_counter ]] && (( __stub_counter++  )) || __stub_counter=1
    {
        builtin printf "  <=< STUB(%d:%s)" $__stub_counter "$(basename $scriptName)"
        builtin printf "[%s] " "$@"
        builtin printf " >=> \n"
    } >&2
}

main() {

    curl -I --max-time 3 "https://artprod.dev.bloomberg.com" && {
        echo "metabase_bb=artprod.dev.bloomberg.com/bbgo/golang:ubuntu20"
    } || {
        echo "golang:1.19-buster"
    }
}

[[ -z ${sourceMe} ]] && {
    main "$@"
    builtin exit
}
command true
