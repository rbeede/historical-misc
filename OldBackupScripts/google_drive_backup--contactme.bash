#!/bin/bash

YEAR=`date +%Y`
MONTH=`date +%m`
DAY=`date +%d`


GoogleBackupDir=/volumes/5tb_usb/GoogleDriveBackup/contactme/$YEAR/$MONTH/$DAY

mkdir --parents "$GoogleBackupDir"

# Where we want logs generated
cd /BackupProcessLogs/

rclone --config /volumes/5tb_usb/GoogleDriveBackup/BackupProgram/rclone_contactme.conf \
   --log-file /BackupProcessLogs/rclone_contactme--$YEAR-$MONTH-$DAY.log \
   --log-level INFO \
   copy GoogleDrive_contactme:  "$GoogleBackupDir"

if [ $? -ne 0 ]; then
    echo "Error in backup call" 1>&2
	exit 255
fi


# Place 7z archive at parent of YEAR folder
7z a "$GoogleBackupDir/../../../GoogleDrive-contactme_$YEAR-$MONTH-$DAY.7z" "$GoogleBackupDir/*" -mx=9 -ms=on -mmt=on -mtc=on -t7z -m0=LZMA2

cd /tmp/

# Remove files downloaded - removing the $YEAR folder
rm -Rf $(readlink -f "$GoogleBackupDir/../../")
