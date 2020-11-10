#!/bin/sh -eu

# update systemd version to workaround issue with ansible service module
# https://github.com/ansible/ansible/issues/71528#issuecomment-687620030

# TODO remove script when systemd issue resolved
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y \
    systemd/buster-backports \
    systemd-timesyncd/buster-backports
