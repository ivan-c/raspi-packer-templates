#!/bin/sh -e


test -d ~root/.ssh || mkdir ~root/.ssh
wget -O - https://github.com/ivan-c.keys > ~root/.ssh/authorized_keys

test -d ~vagrant/.ssh || mkdir ~vagrant/.ssh
wget -O - https://github.com/ivan-c.keys > ~vagrant/.ssh/authorized_keys
