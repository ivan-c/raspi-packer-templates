#!/bin/sh -eu

# TODO set firmware version via environment variable
firmware_version='1.20200601'
wget --quiet --output-document /tmp/firmware.tar.gz \
"https://github.com/raspberrypi/firmware/archive/${firmware_version}.tar.gz"

tar xf /tmp/firmware.tar.gz --directory /tmp

firmware_staging_dir=/tmp/firmware
mv "/tmp/firmware-${firmware_version}" "$firmware_staging_dir"

rm -rf \
    "${firmware_staging_dir}"/boot/kernel*.img \
    "${firmware_staging_dir}/boot/overlays"

cp /usr/lib/u-boot/rpi_4/* "${firmware_staging_dir}/boot/"

echo Copying staging firmware to /boot directory...
cp -R "${firmware_staging_dir}/boot/"* /boot/


raspi4_device_tree_blob="$(find /usr/lib/linux-image-*-arm64/broadcom/ -name bcm2711-rpi-4-b.dtb | sort | tail -n1)"
cp "$raspi4_device_tree_blob" /boot/

: "${PACKER_HTTP_ADDR?Packer HTTP server environment variable not set}"

BASE_URL="http://${PACKER_HTTP_ADDR}/provision"
TMP_DIR="$(mktemp --directory)"

get_file() {
    local filepath="$1"
    local temp_filepath="${TMP_DIR}/$(basename $filepath)"

    wget --quiet "${BASE_URL}${filepath}" --output-document "$temp_filepath"
    echo "$temp_filepath"
}


install -m 644 -o root -g root "$(get_file /boot/config.txt)" /boot/config.txt

rm -rf "$TMP_DIR"
