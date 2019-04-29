#!/bin/bash

if [ "$1" == "" ] || ["$2" == ""]; then
    USAGE="USAGE: bam_convert.sh [path/to/fastq] [path/to/bam/directory]\n*Path to BAM directory should be a folder containing BAM files\n"
    printf "$USAGE"
else
	PATH_TO_FASTQ="$1"
	PATH_TO_BAM="$2"
	CONFIRMATION="$3"

	FILES=$2/*.bam

	#No confirmation
: '
	echo ${PATH_TO_FASTQ}
	echo ${PATH_TO_BAM}
	for f in $FILES
	do
		printf "Converting $f...\n"
		fname=`basename $f .bam`

		samtools bam2fq -1 ${PATH_TO_FASTQ}/${fname}_1.fastq -2 ${PATH_TO_FASTQ}/${fname}_2.fastq $f
	done
'

	#Ask for confirmation
	echo "Path to FASTQ is: ${PATH_TO_FASTQ}"
	echo "Path to BAM is: ${PATH_TO_BAM}"
	read -p "Is this correct? (Y/n)" -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		for f in $FILES
		do
			printf "Converting $f...\n"
			fname=`basename $f .bam`
			samtools bam2fq -1 ${PATH_TO_FASTQ}/${fname}_1.fastq -2 ${PATH_TO_FASTQ}/${fname}_2.fastq $f
		done
	fi

fi