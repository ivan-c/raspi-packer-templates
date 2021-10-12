#!/bin/sh
# fail on first error
set -e

cmdname="$(basename "$0")"

usage() {
   cat << USAGE >&2
Usage:
   $cmdname [-h] [--help]
   -h
   --help
          Show this help message

    Wait for network interfaces to become available, reboot if timeout exceeded
USAGE
   exit 1
}


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
fi


# load initramfs-tools common functions, built into initrd
# shellcheck disable=SC1091
. /scripts/functions

delay=${ROOTDELAY:-180}
count=0
log_begin_msg "Waiting for boot NIC"
while [ ${count} -lt "${delay}" ]; do
    network_interface="$(find /sys/class/net/ -type l ! -name lo -print -quit)"
    if [ -n "$network_interface" ]; then
        log_end_msg
        log_success_msg "Boot NIC ready after ${count} second(s):" "$(basename "$network_interface")"
        exit 0
    fi

    sleep 1
    count=$((count + 1))
done
log_end_msg

log_failure_msg "Boot NIC not found before timeout; rebooting"
sleep 10
reboot -f
