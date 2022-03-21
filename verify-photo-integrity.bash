#!/bin/bash

# ImageMagik needs to be instlaled

export IFS=$'\n'

export LOGFILE=/BackupProcessLogs/`basename $0`.LOG

date --utc > "$LOGFILE"

# 0 is good, 1 is bad
echo "Filepath	ExitCode"


for filepath in $(find $1 -type f -iname '*.jpeg' -o -iname '*.jpg' -o -iname '*.png' -o -iname '*.gif'); do
	echo -n $filepath
	echo -n "	"
	
	cmdoutput=$(identify -verbose "$filepath" 2>&1)

	echo -n $?
	echo ""

	echo $cmdoutput >> "$LOGFILE"
done
