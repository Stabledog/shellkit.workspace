#!/bin/bash
# run_dockerized.sh
#

die() {
    echo "ERROR(run_dockerized.sh): $*" >&2
    exit 1
}

set -x

( sudo chown $(id -u):$(id -u) /var/run/docker.sock || die "Failed changing ownership of /var/run/docker.sock" )
( make setup-workspace || die "make setup-workspace failed in $PWD"; )
( # Bash history preservation:
    [[ -d /vdata ] && {
        mkdir -p /vdata/home
        [[ -f /vdata/home/.bash_history ]] && {
            ln -sf ~/.bash_history /vdata/home/
        } || {
            touch ~/.bash_history
            mv ~/.bash_history /vdata/home/ && ln -sf /vdata/home/.bash_history ~/
        }
    }
)


sleep infinity;

