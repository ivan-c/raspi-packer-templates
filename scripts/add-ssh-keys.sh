#!/bin/sh -e

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y ca-certificates wget


test -d ~root/.ssh || mkdir ~root/.ssh
wget -O - https://github.com/ivan-c.keys > ~root/.ssh/authorized_keys

test -d ~vagrant/.ssh || mkdir ~vagrant/.ssh
wget -O - https://github.com/ivan-c.keys > ~vagrant/.ssh/authorized_keys
