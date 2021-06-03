#!/bin/bash

monitor=$1
destination=$2

if [ -z "$2" ]
then
	printf "\nChecks if a new bam or bai file finished downloading from monitored directory and moves to to a destination every 2m. \n\nUSAGE: move.sh \\ \n\tdirectory to monitor for files to move \\ \n\tdestination_dir\n\n"
	exit 1
fi

while :
do
	if ls ${monitor}/*.bam 1> /dev/null 2>&1
	then
		for file in ${monitor}/*.bam
		do
			# else move it
			echo moving $file to $destination
			echo $file >> files_relocated_score_client.txt
			mv ${file} ${destination}
		done
	fi

	if ls ${monitor}/*.bam.bai 1> /dev/null 2>&1
	then
		for file in ${monitor}/*.bam.bai
		do
			# else move it
			echo moving $file to $destination
			echo $file >> files_relocated_score_client.txt
			mv ${file} ${destination}
		done
	fi

	sleep 2m
done