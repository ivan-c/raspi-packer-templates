#!/bin/sh
# fail on first error
set -e


export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y ca-certificates wget


if [ -z "$PUBLIC_KEY_URL" ]; then
    echo "Public key URL missing; skipping public key installation"
    exit 0
fi

user="${SUDO_USER:-$USER}"

test -d /root/.ssh || mkdir --parents /root/.ssh
wget --output-document - "$PUBLIC_KEY_URL" > /root/.ssh/authorized_keys

test -d "/home/${user}/.ssh" || mkdir "/home/${user}/.ssh"
chmod 0700 "/home/${user}/.ssh"

wget --output-document - "$PUBLIC_KEY_URL" > "/home/${user}/.ssh/authorized_keys"
chmod 0600 "/home/${user}/.ssh"/authorized_keys

chown --recursive "${user}:${user}" "/home/${user}/.ssh"
