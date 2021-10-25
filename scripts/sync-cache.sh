#!/bin/sh
# fail on first error
set -e

cmdname="$(basename "$0")"
bin_path="$(cd "$(dirname "$0")" && pwd)"
repo_path="$(readlink -f "${bin_path}/..")"
cache_dir="$repo_path/packer_cache/qemu"


usage() {
   cat << USAGE >&2
Usage:
   $cmdname [-h] [--help] [command] ssh-username ssh-password
   -h
   --help
          Show this help message
   command
          save cached files from VM or load cached files into VM
   ssh-username
          ssh username to ssh into VM
   ssh-password
          password to ssh into VM

USAGE
   exit 1
}

COMMAND="$1"

USERNAME="$2"
PASSWORD="$3"

# change to cache directory, for relative paths
cd "$cache_dir"
if [ "$COMMAND" = load ]; then
    SOURCE=.
    DESTINATION="$USERNAME@localhost:"
elif [ "$COMMAND" = save ]; then
    SOURCE="$USERNAME@localhost:"
    DESTINATION=.
else
    usage
fi


get_ssh_port() {
    # parse ssh communication port from qemu arguments
    local qemu_cli_command="$1"
    ssh_port=$(echo "$qemu_cli_command" | python3 -c "import sys;print([arg for arg in sys.stdin.read().strip().split(' -') if arg.startswith('netdev user') and arg.endswith('22')][0][-8:-4])")
    echo "$ssh_port"
}


get_qemu_command() {
    # get command for qemu process ID closest to given process ID in process tree
    local shell_process_id="$1"

    local parent_packer_process_id; parent_packer_process_id="$(pstree -aps "$shell_process_id" | grep packer, | head -n1 | grep -oP 'packer,\d+' | cut -d, -f2)"
    local qemu_child_process_id; qemu_child_process_id="$(pstree -aps "$parent_packer_process_id" | grep qemu-system | grep -oP 'qemu-system-\w+,\d+ ' | cut -d, -f2 | sed 's/ *$//g')"
    local qemu_cli_command; qemu_cli_command="$(ps -o args --no-headers -p "$qemu_child_process_id")"
    echo "$qemu_cli_command"
}


qemu_cli_command="$(get_qemu_command $PPID)"
echo "Found qemu provisioner command: $qemu_cli_command"

PORT=$(get_ssh_port "$qemu_cli_command")
echo "Found ssh port: $PORT"

apt_cache_dir=/var/cache/apt
pip_cache_dir=/root/.cache

echo "Starting cache $COMMAND..."

# TODO pass password as CLI arg to script
sshpass -v -p "$PASSWORD" \
    rsync \
        --verbose \
        --times \
        --recursive \
        --relative \
        --ignore-missing-args \
        --rsync-path "sudo rsync" \
        --rsh "ssh -o StrictHostKeyChecking=no -p $PORT" \
    "${SOURCE}${apt_cache_dir}/" "${SOURCE}${pip_cache_dir}/" \
    "${DESTINATION}/"
