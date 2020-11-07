#!/bin/sh
set -e

cmdname="$(basename "$0")"

usage() {
   cat << USAGE >&2
Usage:
   $cmdname [-h] [--help]
   -h
   --help
          Show this help message
    Ansible bootstrapping script
    Install ansible and prerequisites
USAGE
   exit 1
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
fi


ensure_ansible() {
    # install ansible, or exit early

    # exit early if ansible present
    if command -v ansible; then return; fi

    echo 'Installing ansible ansible dependencies...'
    apt-get update

    local ansible_dependencies="$(apt-cache depends package-name ansible | grep 'Depends: [^<]' | awk '{print $NF}')"
    apt-get install --yes --no-install-recommends \
        python3 python3-pip python3-setuptools python3-wheel \
        ${ansible_dependencies} \
        aptitude git

    # prevent installing ansible to /
    # override implied default from debian-installer
    if [ "$USER" = root ]; then
        export XDG_CACHE_HOME=/root/.cache
        export PYTHONUSERBASE=/root/.local
    fi

    echo 'Installing ansible...'
    python3 -m pip install --user ansible
}


ensure_ansible
