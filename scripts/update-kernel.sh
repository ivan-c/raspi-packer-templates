#!/bin/sh
# fail on first error, or empty variables
set -eu

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y linux-image-arm64/testing
