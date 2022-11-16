#!/bin/bash
# docker-install.sh

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
    set -x
    grep -sql docker /proc/1/cgroup || die "This must run in a docker container as root, such as during Dockerfile build"

    local old_dc=$(which docker-compose 2>/dev/null )
    [[ -f $old_dc ]] && rm $old_dc
    touch /.touchtest && rm /.touchtest || die "Can't create /.touchtest"

    #  See also:  https://askubuntu.com/a/1388299/73165
    docker_cli_url="https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/docker-ce-cli_20.10.21~3-0~ubuntu-focal_amd64.deb"
    curl -I -L --max-time 4 "$docker_cli_url" \
        || die "Can't detect existence of $docker_cli_url"
    curl -L "$docker_cli_url" -o /tmp/docker-ce-cli.deb \
        || die "Can't download $docker_cli_url"
    dpkg -i /tmp/docker-ce-cli.deb \
        || die "Can't install /tmp/docker-ce-cli.deb"

    docker info

    # curl -I -L --max-time 4 https://download.docker.com/linux/ubuntu/gpg || die "Fail connecting to docker.com for gpg key"

    # mkdir -p /etc/apt/keyrings
    # rm -f /etc/apt/keyrings/docker.gpg &>/dev/null
    # curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    # echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    #     | tee /etc/apt/sources.list.d/docker.list > /dev/null
    # [[ $? -eq 0 ]] || die "Fail creating docker.list"

    # apt-get update && apt-get install -y docker-ce-cli || die "Failed installing docker-ce-cli"

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
