#!/bin/bash

urls=$1
output=$2

if [ -z "$2" ]
then
	printf "\nUse with move_to_restricted.sh to automatically relocate to restricted storage.\n\nUSAGE: download.sh \\ \n\turls_file \\ \n\toutput_dir\n\n"
	exit 1
fi


for url in $(cat ${urls})
do
	objectid=$(echo $url | cut -f6 -d/ | cut -d? -f1)
	echo $objectid
	wget -c -O ${output}/${objectid}.bam "${url}"
	echo ${output}/${objectid}.bam >> finished_downloading.txt
done