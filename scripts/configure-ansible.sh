#!/bin/sh -e

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

test -d /etc/ansible || mkdir /etc/ansible
install -m 644 -o root -g root "$(get_file /etc/ansible/hosts.ini)" /etc/ansible/hosts.ini

rm -R "$TMP_DIR"
