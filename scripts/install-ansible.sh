#!/bin/sh
set -e

cmdname="$(basename "$0")"
DEFAULT_ANSIBLE_VENV_DIR='/opt/ansible'
DEFAULT_ANSIBLE_VERSION='2.9.15'

usage() {
   cat << USAGE >&2
Usage:
   $cmdname [-h] [--help] [ansible-version] [ansible-venv-directory]
   -h
   --help
          Show this help message

   ansible-version
          Optional version of ansible to install. Defaults to $DEFAULT_ANSIBLE_VERSION

   ansible-venv-directory
          Optional directory to install ansible virtual environment to. Defaults to $DEFAULT_ANSIBLE_VENV_DIR

    Ansible bootstrapping script
    Install ansible and prerequisites
USAGE
   exit 1
}


ensure_ansible() {
    # install ansible, or exit early
    local ansible_version="$1"
    local ansible_venv_dir="$2"

    if [ -n "$ansible_version" ]; then
        local ansible_version_suffix="==${ansible_version}"
    fi

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
    echo "Installing ansible ${ansible_version} ..."
    "${ansible_venv_dir}/bin/python3" -m pip install "ansible${ansible_version_suffix}"

    echo "Linking installation into /usr/local/bin/"
    find "${ansible_venv_dir}/bin/" -executable -name "ansible*" -exec ln --symbolic "{}" /usr/local/bin \;
}


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
fi

ANSIBLE_VERSION="${1:-$ANSIBLE_VERSION}"
ansible_version="${ANSIBLE_VERSION:-$DEFAULT_ANSIBLE_VERSION}"

ANSIBLE_VENV_DIR="${2:-$ANSIBLE_VENV_DIR}"
ansible_venv_dir="${ANSIBLE_VENV_DIR:-$DEFAULT_ANSIBLE_VENV_DIR}"

ensure_ansible "$ansible_version" "$ansible_venv_dir"
