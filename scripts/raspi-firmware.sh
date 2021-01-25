#!/bin/sh
# fail on first error, or empty variables
set -eu

cmdname="$(basename "$0")"
TMP_DIR="$(mktemp --directory --suffix "-$cmdname")"

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y \
    linux-image-arm64/testing \
    u-boot-rpi/testing \
    u-boot-menu/testing

# TODO set firmware version via Packer environment variable
default_rpi_firmware_version='1.20200601'
RPI_FIRMWARE_VERSION=${RPI_FIRMWARE_VERSION:-$default_rpi_firmware_version}

wget --quiet --output-document "$TMP_DIR"/firmware.tar.gz \
"https://github.com/raspberrypi/firmware/archive/${RPI_FIRMWARE_VERSION}.tar.gz"

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

cp /usr/lib/u-boot/rpi_4/* "${firmware_staging_dir}/boot/"

echo Copying staging firmware to /boot directory...
cp -R "${firmware_staging_dir}/boot/"* /boot/

raspi4_device_tree_blob="$(find /usr/lib/linux-image-*-arm64/broadcom/ -name bcm2711-rpi-4-b.dtb | sort | tail -n1)"
cp "$raspi4_device_tree_blob" /boot/


: "${PACKER_HTTP_ADDR?Packer HTTP server environment variable not set}"
BASE_URL="http://${PACKER_HTTP_ADDR}/provision"
get_file() {
    local filepath="$1"
    local temp_filepath="${TMP_DIR}/$(basename $filepath)"

    # ignore proxy settings for packer internal http server
    env --unset http_proxy \
        wget --quiet "${BASE_URL}${filepath}" --output-document "$temp_filepath"
    echo "$temp_filepath"
}

install -m 644 -o root -g root "$(get_file /boot/config.txt)" /boot/config.txt

rm -rf "$TMP_DIR"
