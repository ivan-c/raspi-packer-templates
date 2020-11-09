#!/bin/sh -e


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

ensure_checkout() {
    # invoke `ansible-pull --check` to setup VCS repository
    local repo_url="$1"
    local checkout_dir="$2"
    if [ -d "$checkout_dir" ]; then
        return
    fi
    echo "Setting up checkout..."
    ansible-pull --check --url "$repo_url" --directory "$checkout_dir" > /dev/null || true
}

install_roles() {
    # install roles required by ansible repository
    local repo_url="$1"
    local checkout_dir="$2"
    ensure_checkout "$repo_url" "$checkout_dir"
    echo "Updating roles..."
    ansible-galaxy install --role-file="$checkout_dir"/requirements.yaml
}

# override $HOME if running via sudo
if [ "$USER" = root ]; then
    HOME=/root
fi

hostname="$(hostname)"
default_checkout_dir="${HOME}/.ansible/pull/${hostname}"
checkout_dir="$default_checkout_dir"

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

# add user-installed pip paths
PATH="${PATH}:${HOME}/.local/bin"

# TODO assign by filename pattern
export ANSIBLE_INVENTORY="${ANSIBLE_INVENTORY:-"$checkout_dir"/hosts.ini}"

default_repo_url="$(cd "$checkout_dir" 2> /dev/null && git remote get-url origin || true)"
# allow override of repository URL via environment variable
# precedence: environment variable, commandline option, default
repo_url="${REPO_URL:-${repo_url:-$default_repo_url}}"


install_roles "$repo_url" "$checkout_dir"

# if current machine explicitly listed in inventory
# limit ansible-pull plays to current machine
ensure_checkout "$repo_url" "$checkout_dir"
if [ -f "$ANSIBLE_INVENTORY" ] && grep --quiet "$hostname" "$ANSIBLE_INVENTORY"; then
    limit_opt="--limit $hostname"
fi
ansible-pull \
    $limit_opt \
    --url "$repo_url" \
    --directory "$checkout_dir" \
    --extra-vars ansible_python_interpreter=python3 \
    $ARGS
