#!/bin/bash

if [ "$1" == "" ] || [ "$2" == "" ]; then
    USAGE="USAGE: bam_convert.sh [path/to/fastq] [path/to/bam/directory]\n*Path to BAM directory should be a folder containing BAM files\n"
    printf "$USAGE"
else
	PATH_TO_FASTQ="$1"
	PATH_TO_BAM="$2"

	FILES=$2/*.bam

	#No confirmation
	for f in $FILES
	do
		printf "Converting $f...\n"
		fname=`basename $f .bam`

		samtools fastq -1 ${PATH_TO_FASTQ}/${fname}_1.fastq -2 ${PATH_TO_FASTQ}/${fname}_2.fastq $f
		printf "Finished converting ${fname}\n"
	done
fi