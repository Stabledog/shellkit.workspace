#!/bin/bash
# run_dockerized.sh
#

die() {
    echo "ERROR(run_dockerized.sh): $*" >&2
    exit 1
}

PS4='\033[0;33m+(${BASH_SOURCE}:${LINENO}):\033[0m ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

set -x

( sudo chown $(id -u):$(id -u) /var/run/docker.sock || die "Failed changing ownership of /var/run/docker.sock" )
( make setup-workspace || die "make setup-workspace failed in $PWD"; )
( # Bash history preservation:
    [[ -d /vdata ]] && {
        mkdir -p /vdata/home
        # We want ~/.bash_history to always be a symlink to /vdata/home
        [[ -L /vdata/home/.bash_history ]] && {
            rm /vdata/home/.bash_history
        }
        [[ -L ~/.bash_history ]] || {
            ln -sf /vdata/home/.bash_history ~/.bash_history
        }
        [[ -f /vdata/home/.bash_history ]] || {
            touch /vdata/home/.bash_history
        }
        HISTFILE=~/.bash_history
        history -s "run_dockerized.sh - history init"
        history -w
    }
)


sleep infinity;

