#!/bin/bash

timestamp=`date --utc +%Y-%m-%d_%H-%M-%S`;

echo $timestamp

# We run each job in the background for speed.  We will  "wait"  for them to finish

echo "Size-bytes,Hash,File" > /BackupProcessLogs/nas_hashes.csv

md5deep -r -z -c /volumes/5tb_usb/ >> /BackupProcessLogs/nas_hashes.csv &

# In future if need more parallel jobs just add another one here


# Wait for any background processes to finish
wait


# Update log permissions to make sure they are right
chown root:root /BackupProcessLogs/nas_*hashes.csv
chmod 0644 /BackupProcessLogs/nas_*hashes.csv


cd /BackupProcessLogs/


# Get the likely location of this script (doesn't handle symlinks)
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
