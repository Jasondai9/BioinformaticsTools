#!/bin/bash

if [ "$1" == "" ] || [ "$2" == "" ]; then
    USAGE="\nUSAGE: samtools_bam_convert.sh [path/to/fastq] [path/to/bam/directory] [OPTIONAL: text file containing path to individual bams] \n
	Path to BAM directory should be a folder containing BAM files 
	Can optionally pass in a txt file containing path to the files \n\n"
    printf "$USAGE"
else
	PATH_TO_FASTQ="$1"
	PATH_TO_BAM="$2"

	FILES=$2/*.bam
	if [ "$3" != "" ]; then
		printf "Using BAMs from $3"
		#the text file
		FILES=$(cat $3)
	fi
	#No confirmation
	for f in $FILES
	do
		printf "Converting $f...\n"
		fname=`basename $f .bam`
		
		samtools collate -o ${PATH_TO_FASTQ}/${fname}_collated.bam $f
		samtools fastq -N -1 ${PATH_TO_FASTQ}/${fname}_1.fastq.gz -2 ${PATH_TO_FASTQ}/${fname}_2.fastq.gz ${PATH_TO_FASTQ}/${fname}_collated.bam
		
		rm ${PATH_TO_FASTQ}/${fname}_collated.bam
		
		printf "Finished converting ${fname}\n"

		
	done
	chmod 775 ${PATH_TO_FASTQ}/*.fastq.gz
fi