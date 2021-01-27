#!/bin/sh
# fail on first error
set -e

cmdname="$(basename "$0")"

: "${PACKER_HTTP_ADDR?Packer HTTP server environment variable not set}"

BASE_URL="http://${PACKER_HTTP_ADDR}/provision"
TMP_DIR="$(mktemp --directory --suffix "-$cmdname")"

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y ca-certificates wget

get_file() {
    local filepath="$1"
    local temp_filepath="${TMP_DIR}/$(basename $filepath)"

    # ignore proxy settings for packer internal http server
    env --unset http_proxy \
        wget --quiet "${BASE_URL}${filepath}" --output-document "$temp_filepath"
    echo "$temp_filepath"
}


install -m 644 -o root -g root "$(get_file /etc/apt/apt.conf.d/90defaultrelease)" /etc/apt/apt.conf.d/90defaultrelease

install -m 644 -o root -g root "$(get_file /etc/apt/sources.list.d/stable.list)" /etc/apt/sources.list.d/stable.list
install -m 644 -o root -g root "$(get_file /etc/apt/sources.list.d/testing.list)" /etc/apt/sources.list.d/testing.list
install -m 644 -o root -g root "$(get_file /etc/apt/sources.list.d/security.list)" /etc/apt/sources.list.d/security.list

install -m 644 -o root -g root "$(get_file /etc/apt/preferences.d/stable.pref)" /etc/apt/preferences.d/stable.pref
install -m 644 -o root -g root "$(get_file /etc/apt/preferences.d/testing.pref)" /etc/apt/preferences.d/testing.pref
install -m 644 -o root -g root "$(get_file /etc/apt/preferences.d/security.pref)" /etc/apt/preferences.d/security.pref

rm -R "$TMP_DIR"
