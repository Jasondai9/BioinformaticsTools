#!/bin/bash

monitor=$1
destination=$2

if [ -z "$2" ]
then
	printf "\nChecks if a new file finished downloading from log and moves to to a destination every 2m. \n\nUSAGE: move.sh \\ \n\tfile to monitor for files to move \\ \n\tdestination_dir\n\n"
	exit 1
fi

while :
do
	for file in $(cat ${monitor})
	do
		# if the file has already been moved
		if [ -f ${destination}/$(basename ${file}) ]
		then
			continue
		else
			# else move it
			echo moving $file to $destination
			echo moving $file to $destination >> files_relocated.txt
			mv ${file} ${destination}
		fi
	done
	sleep 2m
done