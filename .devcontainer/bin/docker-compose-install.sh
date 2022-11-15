#!/bin/bash
# docker-compose-install.sh

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
    grep -sql docker /proc/1/cgroup || die "This must run in a docker container as root, such as during Dockerfile build"

    local old_dc=$(which docker-compose 2>/dev/null )
    [[ -f $old_dc ]] && rm $old_dc
    touch /.touchtest || die "Can't touch /.touchtest"
    rm /.touchtest

    cd /tmp \
        && curl -L https://github.com/docker/compose/releases/download/1.29.2/docker-compose-Linux-x86_64 -o /usr/local/bin/docker-compose \
        && chmod +x /usr/local/bin/docker-compose \
        || die "Failed download+install docker-compose"
    echo "docker-compose installed: OK"
}

[[ -z ${sourceMe} ]] && {
    stub "${FUNCNAME[0]}.${LINENO}" "calling main()" "$@"
    main "$@"
    builtin exit
}
command true
