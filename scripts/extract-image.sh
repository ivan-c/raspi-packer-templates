#!/bin/sh -e

set -x
cmdname="$(basename "$0")"
bin_path="$(cd "$(dirname "$0")" && pwd)"
repo_path="${bin_path}/.."


usage() {
    cat << USAGE >&2
Usage:
    ${cmdname} [-h] [OUTPUT_DIR]

    Extract disk image to given directory

    -h
    --help
        Show this help message

USAGE
    exit 1
}

TMP_DIR="$(mktemp --directory --suffix "-$cmdname")"

mount_image() {
    local image_filepath="$1"
    local loopback_device=$(losetup --list --noheading --associated "$image_filepath" | awk '{print $1}')
    if [ -z "$loopback_device" ]; then
        loopback_device="$(losetup --partscan --find "$image_filepath" --show)"
    fi
    # TODO use largest partition instead of hardcoded index
    mkdir "${TMP_DIR}/p3"
    mount --read-only "${loopback_device}"p3 "${TMP_DIR}/p3"
    echo "${TMP_DIR}/p3"
}

cleanup_image() {
    local image_filepath="$1"
    local loopback_device=$(losetup --list --noheading --associated "$image_filepath" | awk '{print $1}')
    if [ -z "$loopback_device" ]; then
        return
    fi
    umount --quiet "$loopback_device"* || true
    losetup --detach "$loopback_device"
}


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
    exit 0
fi

OUTPUT_DIR="$1"
if [ ! -d "$OUTPUT_DIR" ]; then
    echo "Error: ${OUTPUT_DIR} is not a directory"
    exit 1
fi

image_filepath="${repo_path}/output-qemu/debian-arm64"
image_mountpoint="$(mount_image "$image_filepath")"

rsync -az "$image_mountpoint/" "$OUTPUT_DIR"

# TODO catch SIGTERM and cleanup
cleanup_image "$image_filepath"

rm -Rf "$TMP_DIR"
