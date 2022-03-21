#!/bin/bash

# For Ubuntu/Debian based that use apt will install all updates, autoremove, cleanup
# Reboots only if necessary

LOGFILEPATH=/var/log/UPDATE-OS-JOB.log


# Redirect STDOUT as $LOG_FILE
exec 1>$LOGFILEPATH

# Redirect STDERR to STDOUT
exec 2>&1


# Don't assume this is set
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin


export DEBIAN_FRONTEND=noninteractive


/usr/bin/apt-get --quiet --assume-yes update

/usr/bin/apt-get --quiet --assume-yes -o 'Dpkg::Options::=--force-confdef' -o 'Dpkg::Options::=--force-confold' dist-upgrade

/usr/bin/apt-get --quiet --assume-yes autoremove

/usr/bin/apt-get --quiet --assume-yes autoclean

/usr/bin/apt-get --quiet --assume-yes clean


if [ -f /var/run/reboot-required ]; then
        /sbin/reboot;
fi;
