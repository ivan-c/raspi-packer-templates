#!/bin/sh
# fail on first error
set -e

cmdname="$(basename "$0")"

usage() {
   cat << USAGE >&2
Usage:
   $cmdname [-h] [--help]
   -h
   --help
          Show this help message

    Modify initial ramdisk to allow RaspberryPi 3B+ to netboot
USAGE
   exit 1
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
fi

: "${PACKER_HTTP_ADDR?Packer HTTP server environment variable not set}"

BASE_URL="http://${PACKER_HTTP_ADDR}/provision"
TMP_DIR="$(mktemp --directory --suffix "-$cmdname")"

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y ca-certificates wget

get_file() {
    local filepath="$1"
    local temp_filepath; temp_filepath="${TMP_DIR}/$(basename "$filepath")"

    # ignore proxy settings for packer internal http server
    wget --no-proxy --quiet "${BASE_URL}${filepath}" --output-document "$temp_filepath"
    echo "$temp_filepath"
}

echo Updating initrd module list...
install -m 644 -o root -g root "$(get_file /etc/initramfs-tools/modules)" /etc/initramfs-tools/modules

echo Adding initrd script...
install -m 755 -o root -g root "$(get_file /etc/initramfs-tools/scripts/nfs-premount/network-check.sh)" /etc/initramfs-tools/scripts/nfs-premount/network-check.sh

rm -R "$TMP_DIR"

update-initramfs -vu
