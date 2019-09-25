#!/bin/bash

if [ "$1" == "" ] || [ "$2" == "" ]; then
    USAGE="USAGE: cram2bam.sh [PATH_TO_BAMS] [PATH_TO_CRAMS]\n*Path to CRAM directory should be a folder containing CRAM files\n"
    printf "$USAGE"
else
	PATH_TO_BAMS="$1"
	PATH_TO_CRAMS="$2"
	PATH_TO_REF="/projects/ps-lalexandrov/shared/Reference_Genomes/hg38/hg38.fa"

	FILES=${PATH_TO_CRAMS}/*.cram

	for f in $FILES
	do
		fname=`basename $f .cram`
		printf "\nConverting ${fname}...\n"
		
		printf "samtools view -b -T $PATH_TO_REF -o ${PATH_TO_BAMS}/${fname}.bam $f"
		printf "\nFinished converting ${fname}\n"
	done
fi
