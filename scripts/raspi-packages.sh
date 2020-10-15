#!/bin/sh -e

export DEBIAN_FRONTEND=noninteractive

apt-get update

apt-get install -y \
    linux-image-arm64/testing \
    u-boot-rpi/testing \
    u-boot-menu/testing
