#!/bin/bash
# run_dockerized.sh
#

die() {
    echo "ERROR(run_dockerized.sh): $*" >&2
    exit 1
}

set -x

( make setup-workspace || die "make setup-workspace failed in $PWD"; )


sleep infinity;

