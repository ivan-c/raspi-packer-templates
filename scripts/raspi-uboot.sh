#!/bin/sh -eu

: "${PACKER_HTTP_ADDR?Packer HTTP server environment variable not set}"

BASE_URL="http://${PACKER_HTTP_ADDR}/provision"
TMP_DIR="$(mktemp --directory)"

get_file() {
    local filepath="$1"
    local temp_filepath="${TMP_DIR}/$(basename $filepath)"

    wget --quiet "${BASE_URL}${filepath}" --output-document "$temp_filepath"
    echo "$temp_filepath"
}


install -m 644 -o root -g root "$(get_file /etc/kernel/cmdline)" /etc/kernel/cmdline
install -m 644 -o root -g root "$(get_file /etc/default/u-boot)" /etc/default/u-boot

rm -rf "$TMP_DIR"

u-boot-update
