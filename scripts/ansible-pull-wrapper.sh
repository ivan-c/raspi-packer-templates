#!/bin/sh


cmdname="$(basename "$0")"
bin_path="$(cd "$(dirname "$0")" && pwd)"
repo_path="${bin_path}/.."


usage() {
    cat << USAGE >&2
Usage:
    $cmdname [-h|--help] [ansible-pull options]
    -h     Show this help message
    Wrapper for ansible-pull
    Install dependencies and run ansible-pull with defaults
USAGE
    exit 1
}

die(){
    printf '%s\n' "$1" >&2
    exit 1
}


# copy arguments; option parsing is destructive
ARGS=$@

while :; do
    case $1 in

        # handle checkout dir option
        -d|--directory)
            test "$2" || die "ERROR: $1 requires a non-empty option argument."
            checkout_dir=$2
            shift
            ;;
        -d*)
            # Delete "-d" and assign the remainder
            checkout_dir=${1#*-d}
            ;;

        --directory=?*)
            # Delete everything up to "=" and assign the remainder
            checkout_dir=${1#*=}
            ;;

        # handle repo URL option
        -U|--url)
            test "$2" || die "ERROR: $1 requires a non-empty option argument."
            repo_url=$2
            shift
            ;;
        -U*)
            repo_url=${1#*-U}
            ;;
        --url=?*)
            repo_url=${1#*=}
            ;;


        -h|-\?|--help)
            usage
            exit
            ;;
        "")
            # no more options
            break
            ;;
    esac
    shift
done

default_checkout_dir=/tmp/ansible
checkout_dir="${checkout_dir:-$default_checkout_dir}"

default_repo_url='https://github.com/ivan-c/ansible-bootstrap'
repo_url="${repo_url:-$default_repo_url}"

# add user-installed pip paths
PATH="${PATH}:${HOME}/.local/bin"

# override implied default from debian-installer
if [ "$USER" = root ] && [ "$HOME" = / ]; then
    PATH="${PATH}:/root/.local/bin"
    # todo use `find`
    export PYTHONPATH=/root/.local/lib/python3.7/site-packages
fi

if [ ! -d "$checkout_dir" ]; then
    git clone "$repo_url" "$checkout_dir"
fi

# assume directory to checkout repository to contains requirements.yaml or requirements.yml
ansible-galaxy install --role-file="$checkout_dir"/requirements.yaml

export ANSIBLE_INVENTORY="${ANSIBLE_INVENTORY:-hosts.ini}"
# the below doesn't work
#export ANSIBLE_PYTHON_INTERPRETER=python3


# if current machine explicitly listed in inventory
# limit ansible-pull plays to current machine
hostname="$(hostname)"
if grep --quiet "$hostname" "$checkout_dir/hosts.ini"; then
    limit="--limit $hostname"
fi

ansible-pull \
    $ARGS \
    $limit \
    --directory "$checkout_dir" \
    --url $repo_url \
    --extra-vars ansible_python_interpreter=python3
