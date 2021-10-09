#!/bin/sh
# fail on first error
set -e

# remove hardcoded hostname (assign from DHCP)
rm /etc/hostname

# replace libvirt DNS server config with google DNS
echo nameserver 8.8.8.8 > /etc/resolv.conf

export DEBIAN_FRONTEND=noninteractive

echo Removing language-specific development packages...
dpkg --list | awk '{ print $2 }' | grep -- '-dev' | xargs apt-get purge -y

echo Removing old kernels...
dpkg --list | grep -E 'linux-image-[0-9]' | awk '{ print $3,$2 }' | sort -nr | tail -n +2 | grep -v "$(uname -r)" | awk '{ print $2 }' | xargs apt-get purge -y

apt-get autoremove --purge -y

dpkg --list | grep '^rc' | awk '{ print $2 }' | xargs apt-get purge -y

apt-get autoclean -y

apt-get clean -y
rm -rf \
    /var/lib/apt/lists/* \
    /var/cache/apt/pkgcache.bin \
    /var/cache/apt/srcpkgcache.bin

echo Deleting non-copyright documentation...
find /usr/share/doc -depth -type f ! -name copyright -exec rm {} \;

echo Deleting empty documentation...
find /usr/share/doc -empty -delete

rm -rf \
    /usr/share/man/* \
    /usr/share/groff/* \
    /usr/share/info/* \
    /usr/share/lintian/* \
    /usr/share/linda/* \
    /var/cache/man/*

rm -rf \
    /dev/.udev \
    /var/lib/dhcp/* \
    /var/lib/dhcp3/*

# Clear log files
find /var/log -type f -exec truncate -s 0 {} \;

# Clear temporary files
rm -rf /tmp/*
