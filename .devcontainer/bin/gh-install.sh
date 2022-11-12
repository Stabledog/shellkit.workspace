#!/bin/bash
# gh-install.sh

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
    # Baseline for this code came from https://github.com/cli/cli/blob/trunk/docs/install_linux.md:
    set -x
    touch /.foo || die "This script must run as root"
    type -P curl || die "No 'curl' on the PATH"
    Apt=$(which apt)
    stub Apt $Apt
    [[ -f $Apt ]] || {
        Apt=$(which apt-get)
        [[ -f $Apt ]] || die "No apt or apt-get available"
    }

    [[ -n $Apt ]] || die "No apt or apt-get available (2)"

    mkdir -p /usr/share/keyrings
    KRURL="https://cli.github.com/packages/githubcli-archive-keyring.gpg"
    curl -I "$KRURL" --max-time 3 || die "Can't curl to cli.github.com.  Proxy issue?"
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg  \
        || die "Failed fetching keyring"
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg || die 103.3
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
        || die 103.4
    $Apt update && $Apt install gh -y || die 103.5
    which gh || die 103.6
}

[[ -z ${sourceMe} ]] && {
    main "$@"
    builtin exit
}
command true
