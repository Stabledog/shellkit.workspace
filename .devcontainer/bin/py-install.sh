#!/bin/bash
# py-install.sh

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

profile_pyenv_hook() {
    cat <<-EOF
export PYENV_ROOT="\$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="\$PYENV_ROOT/bin:\$PATH"
eval "\$(pyenv init -)"
EOF
}

install_py_build_depends() {
    apt update && apt install -y \
        make  \
        build-essential  \
        libssl-dev  \
        zlib1g-dev  \
        libbz2-dev  \
        libreadline-dev  \
        libsqlite3-dev  \
        wget  \
        curl  \
        llvm  \
        libncursesw5-dev  \
        xz-utils  \
        tk-dev  \
        libxml2-dev  \
        libxmlsec1-dev  \
        libffi-dev  \
        liblzma-dev
}

install_pyenv() {
    install_py_build_depends || die "install_py_build_depends failed"
    local pyenv_url=https://pyenv.run
    curl -I ${pyenv_url}  --max-time 4 &>/dev/null || die "Can't connect to ${pyenv_url}"
    touch ~/.tmp1-deleteme || die "Can't write to dir ~/"
    local bakFile=~/.profile-bak-$(date -I)
    [[ -f $bakFile  ]] || cp ~/.profile $bakFile
    (
        curl $pyenv_url | bash
    )

    cat <(profile_pyenv_hook) $bakFile > ~/.profile
}

do_install() {
    local target_version="$1"
    bash -l -c "python-${target_version} --version" && {
        echo "python-${target_version} is already installed: OK"
        return;
    }
    install_pyenv
    bash -l -c "pyenv install $target_version" || die "pyenv failed installing $target_version"
    bash -l -c "pyenv global $target_version" || die "pyenv failed setting global to $target_version"
}

main() {
    local target_version
    while [[ -n $1 ]]; do
        case $1 in
            --target-version) target_version="$2"; shift;;
            *) die "Unknown arg: $1" ;;
        esac
        shift
    done
    [[  $target_version =~ [0-9]+\.[0-9]+ ]] || die "Expected --target-version n.nn, e.g. \"3.8\" etc."
    do_install $target_version
}

[[ -z ${sourceMe} ]] && {
    stub "${FUNCNAME[0]}.${LINENO}" "calling main()" "$@"
    main "$@"
    builtin exit
}
command true
