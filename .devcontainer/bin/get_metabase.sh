#!/bin/bash
# get_metabase.sh

scriptName="$(readlink -f "$0")"
scriptDir=$(command dirname -- "${scriptName}")
PS4='\033[0;33m+(${BASH_SOURCE}:${LINENO}):\033[0m ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
script=$(basename $scriptName)

Environ=${Environ:-} #  internet or bbvpn are valid
Artprod=artprod.dev.bloomberg.com

die() {
    builtin echo "ERROR($(basename ${scriptName})): $*" >&2
    builtin exit 1
}

usage() {
    cat <<-EOF
Detects the environment and emits appropriate base image name for given component.
$script --list
    Show the component names and detected environment
$script [component-name]
    Show the docker build base URL for given component name/env
EOF
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

show_list() {
    components
    printf "# Environment detected: $Environ\n"
}

components() {
    cat <<-EOF
shellkit-pytest python:3.8-bullseye $Artprod/dpkg-python-development-base:3.8 # For python-based testing
shellkit-aws unk unk # For publishing to AWS S3
shellkit-gh unk unk # For github API
shellkit-compat unk unk # For shellkit compatibility testing
EOF
}

show_component() {
    local component_name=$1
    local environ=$2
    while read comp inet_id bbvpn_id _; do
        [[ $comp == ${component_name} ]] && {
            # stub { printf "[%s]" $inet_id $bbvpn_id ; echo; } >&2
            [[ $environ == internet ]] && {
                echo ${inet_id};
            } ||  {
                echo ${bbvpn_id};
            }
            return
        }
    done < <( components )
    die "Unknown component: $component_name"
}

main() {
    [[ $# -eq 0 ]] && { usage; die No arg provided; }
    [[ -z $Environ ]] && {
        curl -I --max-time 3 "https://$Artprod" &>/dev/null && {
            Environ=bbvpn
        } || {
            Environ=internet
        }
    }
    local components=()
    while [[ -n $1 ]]; do
        case $1 in
            -h|--help) usage; exit 1;;
            --list) shift; show_list "$@"; exit;;
            *) components+=($1) ;;
        esac
        shift
    done

    for component in ${components[@]}; do
        show_component $component $Environ
    done



    # curl -I --max-time 3 "https://artprod.dev.bloomberg.com" &>/dev/null && {
    #     #echo "artprod.dev.bloomberg.com/bbgo/golang:ubuntu20"
    #     echo "artprod.dev.bloomberg.com/dpkg-python-development-base:3.8"
    # } || {
    #     echo "golang:1.19-bullseye"
    # }
}

[[ -z ${sourceMe} ]] && {
    main "$@"
    builtin exit
}
command true
