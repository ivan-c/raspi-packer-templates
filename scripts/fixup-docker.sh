#!/bin/sh -eu

# set docker daemon configuration

# TODO remove script when storage backend solution found (overlay2 does not work over NFS)
cmdname="$(basename "$0")"

: "${PACKER_HTTP_ADDR?Packer HTTP server environment variable not set}"

BASE_URL="http://${PACKER_HTTP_ADDR}/provision"
TMP_DIR="$(mktemp --directory --suffix "-$cmdname")"

get_file() {
    local filepath="$1"
    local temp_filepath="${TMP_DIR}/$(basename $filepath)"

    wget --quiet "${BASE_URL}${filepath}" --output-document "$temp_filepath"
    echo "$temp_filepath"
}


install -m 644 -o root -g root "$(get_file /etc/docker/daemon.json)" /etc/docker/daemon.json

service docker restart
