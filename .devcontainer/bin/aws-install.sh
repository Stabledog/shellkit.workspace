#!/bin/bash
# aws-install.sh

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
    # Guidance for this procedure came from https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

    set -x
    touch /.foo || die "This script must run as root"
    type -P curl || die "No 'curl' on the PATH"
    type -P unzip || die "No 'unzip' on the PATH"
    local AWURL="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
    mkdir -p /tmp
    command curl -I "$AWURL" --max-time 3 || die "Can't curl $AWURL -- Proxy issue?"
    command curl -o /tmp/awscliv2.zip "$AWURL" || die "Failed downloading $AWURL"
    cd /tmp
    command unzip ./awscliv2.zip
    ./aws/install
    /usr/local/bin/aws --version
}

[[ -z ${sourceMe} ]] && {
    main "$@"
    builtin exit
}
command true
