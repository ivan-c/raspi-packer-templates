#!/bin/sh
# fail on first error
set -e

cmdname="$(basename "$0")"
DEFAULT_RPI_FIRMWARE_VERSION='1.20200601'

usage() {
   cat << USAGE >&2
Usage:
   $cmdname [-h] [--help] [firmware-version]
   -h
   --help
          Show this help message

   firmware-version
          Optional version of Raspberry Pi firmware to install. Defaults to $DEFAULT_RPI_FIRMWARE_VERSION

    Install Raspberry Pi firmware and configs
USAGE
   exit 1
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
fi

RPI_FIRMWARE_VERSION="${1:-$RPI_FIRMWARE_VERSION}"
rpi_firmware_version="${RPI_FIRMWARE_VERSION:-$DEFAULT_ANSIBLE_VERSION}"


TMP_DIR="$(mktemp --directory --suffix "-$cmdname")"

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y ca-certificates wget

wget --quiet --output-document "$TMP_DIR"/firmware.tar.gz \
"https://github.com/raspberrypi/firmware/archive/${rpi_firmware_version}.tar.gz"

firmware_staging_dir="$TMP_DIR"/firmware
mkdir "$firmware_staging_dir"
tar xf "$TMP_DIR"/firmware.tar.gz --directory "$TMP_DIR"
cd "${TMP_DIR}/firmware-${RPI_FIRMWARE_VERSION}"
firmware_filepaths="
/boot/start4.elf
/boot/fixup4.dat
"
for firmware_filepath in $firmware_filepaths; do
    cp --parents ".${firmware_filepath}" "$firmware_staging_dir"/
done

apt-get install -y \
    u-boot-rpi \
    u-boot-menu
cp /usr/lib/u-boot/rpi_4/* "${firmware_staging_dir}/boot/"

echo Copying staging firmware to /boot directory...
cp -R "${firmware_staging_dir}/boot/"* /boot/

raspi4_device_tree_blob="$(find /usr/lib/linux-image-*-arm64/broadcom/ -name bcm2711-rpi-4-b.dtb | sort | tail -n1)"
cp "$raspi4_device_tree_blob" /boot/


: "${PACKER_HTTP_ADDR?Packer HTTP server environment variable not set}"
BASE_URL="http://${PACKER_HTTP_ADDR}/provision"
get_file() {
    local filepath="$1"
    local temp_filepath; temp_filepath="${TMP_DIR}/$(basename "$filepath")"

    # ignore proxy settings for packer internal http server
    wget --no-proxy --quiet "${BASE_URL}${filepath}" --output-document "$temp_filepath"
    echo "$temp_filepath"
}

install -m 644 -o root -g root "$(get_file /boot/config.txt)" /boot/config.txt

rm -rf "$TMP_DIR"
