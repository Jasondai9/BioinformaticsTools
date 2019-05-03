#!/bin/bash

#align_check.sh name_of_submit_folder
#must be called from bam folder in analyzed sample directory

echo "Incomplete tumor samples:" > missing_files.txt
for tsample in $(sed 1d ../../submits/$1/*.txt | cut -f2)
do
	tcount=$(ls -l $tsample* | wc -l) 

	if [ "$tcount" -eq 10 ];then
		echo "$tsample" "has enough files"
	else
		echo "$tsample" "is missing files! See missing_files.txt"
		echo "$tsample" >> missing_files.txt
	fi
done

echo "Incomplete normal samples:" >> missing_files.txt
for nsample in $(sed 1d ../../submits/$1/*.txt | cut -f3)
do
	ncount=$(ls -l $nsample* | sort | uniq | wc -l) 

	if [ "$ncount" -eq 10 ];then
		echo "$nsample" "has enough files"
	else
		echo "$nsample" "is missing files! See missing_files.txt"
		echo "$nsample" >> missing_files.txt
	fi
done
