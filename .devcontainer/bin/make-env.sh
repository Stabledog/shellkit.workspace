#!/bin/bash
# make-env.sh

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


getHostHome() {
    # The HostHome value should be defined in shellkit-environment.mk, but
    # we have to account for both host and docker build environments here.
    # By prioritizing docker, and falling back to host, we get the right value reliably
    local path
    local spec
    for path in /host_home/shellkit-environment.mk $HOME/shellkit-environment.mk; do
        [[ -f $path ]] && {
            spec="$(grep HostHome $path)"
            [[ -n $spec ]] || continue
            eval "$spec"
            [[ -n $HostHome ]] || die "bad HostHome spec in $path"
            echo "$HostHome"
            return
        }
    done
    die "Failed to identify HostHome value"
}

emitEnvText() {
    cat <<-EOF
# This is loaded by docker-compose automatically.  It's created make-env.sh
ShellkitWorkspace="$(dirname $(dirname $scriptDir))"
HostHome="$(getHostHome)"
EOF
}

main() {
    emitEnvText "$@"
}

[[ -z ${sourceMe} ]] && {
    main "$@"
    builtin exit
}
command true
