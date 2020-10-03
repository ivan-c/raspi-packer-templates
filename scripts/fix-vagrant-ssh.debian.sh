#!/bin/sh -e

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y ca-certificates wget


#!/bin/sh -e


test -d ~vagrant/.ssh || mkdir ~vagrant/.ssh
wget -O - https://raw.github.com/hashicorp/vagrant/master/keys/vagrant.pub > ~vagrant/.ssh/authorized_keys


chown -R vagrant:vagrant /home/vagrant/.ssh
chmod 0700 /home/vagrant/.ssh
chmod 0600 /home/vagrant/.ssh/authorized_keys
