#!/bin/sh
# use nftables legacy iptables frontend until kubernetes supports nftables natively

# fail on first error, or empty variables
set -eu


# TODO remove script when native k8s nftables support available
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y iptables arptables ebtables

# switch to legacy versions
update-alternatives --set iptables /usr/sbin/iptables-legacy
update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
update-alternatives --set arptables /usr/sbin/arptables-legacy
update-alternatives --set ebtables /usr/sbin/ebtables-legacy
