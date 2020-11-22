#!/bin/sh
set -e

cmdname="$(basename "$0")"
DEFAULT_ANSIBLE_VENV_DIR='/opt/ansible'

usage() {
   cat << USAGE >&2
Usage:
   $cmdname [-h] [--help] [ansible-venv-directory]
   -h
   --help
          Show this help message

   ansible-venv-directory
          Optional directory to install ansible virtual environment to. Defaults to $DEFAULT_ANSIBLE_VENV_DIR

    Ansible bootstrapping script
    Install ansible and prerequisites
USAGE
   exit 1
}


ensure_ansible() {
    # install ansible, or exit early
    local ansible_venv_dir="$1"

    if command -v ansible; then return; fi

    if [ -e "$ansible_venv_dir" ]; then
        echo "${ansible_venv_dir} already exists"
        exit 1
    fi

    echo 'Installing ansible ansible dependencies...'
    apt-get update

    local ansible_dependencies="$(apt-cache depends package-name ansible | grep 'Depends: [^<]' | awk '{print $NF}')"
    apt-get install --yes --no-install-recommends \
        python3 python3-pip python3-setuptools python3-venv python3-wheel \
        ${ansible_dependencies} \
        aptitude git

    echo "Creating virtual environment at ${ansible_venv_dir}..."
    python3 -m venv --system-site-packages "$ansible_venv_dir"
    "${ansible_venv_dir}/bin/python3" -m pip install ansible

    echo "Linking installation into /usr/local/bin/"
    find "${ansible_venv_dir}/bin/" -executable -name "ansible*" -exec ln --symbolic "{}" /usr/local/bin \;
}


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
fi

ANSIBLE_VENV_DIR="$1"
ansible_venv_dir="${2:-$DEFAULT_ANSIBLE_VENV_DIR}"

ensure_ansible "$ansible_venv_dir"
